#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# Instalador idempotente do Neovim (LazyVim) para macOS
# Stack: Java, Go, Python, JS/TS, Docker, Kubernetes/Helm, MySQL, Terraform,
#        Git (diff/merge/conflitos), Claude Code e autocomplete com IA.
#
# Uso:
#   ./install.sh                         # IA = codeium (padrão, grátis)
#   AI_PROVIDER=ollama ./install.sh      # codeium | ollama | copilot | claude | none
#   SKIP_GIT_CONFIG=1 ./install.sh       # não altera ~/.gitconfig (mergetool/difftool)
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="$SCRIPT_DIR/config"
NVIM_CONFIG_DIR="$HOME/.config/nvim"
MARKER="$NVIM_CONFIG_DIR/.managed_by_pro_setup"
BACKUP_STAMP=$(date +%Y%m%d_%H%M%S)
AI_PROVIDER="${AI_PROVIDER:-codeium}"

log()  { echo -e "\033[1;34m[SETUP]\033[0m $1"; }
ok()   { echo -e "\033[1;32m[OK]\033[0m    $1"; }
warn() { echo -e "\033[1;33m[WARN]\033[0m  $1"; }
die()  { echo -e "\033[1;31m[ERRO]\033[0m  $1"; exit 1; }

[[ "$(uname)" == "Darwin" ]] || die "Este instalador é para macOS."
[[ -d "$SRC_DIR" ]] || die "Pasta de configuração não encontrada: $SRC_DIR"

case "$AI_PROVIDER" in
    codeium|ollama|copilot|claude|none) ;;
    *) die "AI_PROVIDER inválido: '$AI_PROVIDER' (use codeium | ollama | copilot | claude | none)" ;;
esac

# ------------------------------------------------------------------------------
# 1. Xcode Command Line Tools (compilador C para parsers treesitter / fzf-native)
# ------------------------------------------------------------------------------
if ! xcode-select -p &> /dev/null; then
    warn "Xcode Command Line Tools ausente. Abrindo instalador; rode este script novamente ao terminar."
    xcode-select --install || true
    exit 1
fi
ok "Xcode Command Line Tools presente."

# ------------------------------------------------------------------------------
# 2. Homebrew
# ------------------------------------------------------------------------------
if ! command -v brew &> /dev/null; then
    log "Instalando Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
if [ -x "/opt/homebrew/bin/brew" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x "/usr/local/bin/brew" ]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi
ok "Homebrew: $(brew --version | head -1)"

# ------------------------------------------------------------------------------
# 3. Pacotes CLI (instala apenas o que falta)
# ------------------------------------------------------------------------------
# formato "formula:binário" — pula se a fórmula já está instalada OU o binário já
# existe no PATH (ex.: node via nvm, kubectl do Docker Desktop). Binário vazio =
# keg-only, verifica apenas a fórmula.
PACKAGES=(
    # editor + busca
    neovim:nvim ripgrep:rg fd:fd fzf:fzf tree-sitter-cli:tree-sitter luarocks:luarocks
    # git
    git:git lazygit:lazygit git-delta:delta gh:gh
    # linguagens / runtimes (openjdk@21 roda o jdtls; seus projetos podem usar 17)
    node:node go:go python3:python3 openjdk@21: maven:mvn
    # containers / kubernetes
    kubernetes-cli:kubectl helm:helm k9s:k9s
    # banco de dados (cliente mysql usado pelo vim-dadbod)
    mysql-client:
)

log "Verificando pacotes Homebrew..."
MISSING_PKGS=()
for entry in "${PACKAGES[@]}"; do
    pkg="${entry%%:*}"; bin="${entry#*:}"
    if [ -n "$bin" ] && command -v "$bin" &> /dev/null; then continue; fi
    brew list --formula "$pkg" &> /dev/null || MISSING_PKGS+=("$pkg")
done
if [ ${#MISSING_PKGS[@]} -gt 0 ]; then
    log "Instalando: ${MISSING_PKGS[*]}"
    brew install "${MISSING_PKGS[@]}"
else
    ok "Todos os pacotes CLI já estão instalados."
fi

command -v docker &> /dev/null || warn "Docker não encontrado. Instale Docker Desktop ou OrbStack (brew install --cask orbstack)."

# Neovim >= 0.11.2 exigido pelo LazyVim
NVIM_VER=$(nvim --version | head -1 | sed -E 's/^NVIM v([0-9]+\.[0-9]+\.[0-9]+).*/\1/')
if [ "$(printf '%s\n%s\n' "0.11.2" "$NVIM_VER" | sort -V | head -1)" != "0.11.2" ]; then
    log "Neovim $NVIM_VER é antigo. Atualizando..."
    brew upgrade neovim
fi
ok "Neovim $(nvim --version | head -1)"

# ------------------------------------------------------------------------------
# 4. Nerd Font + Claude Code CLI
# ------------------------------------------------------------------------------
if ! brew list --cask font-jetbrains-mono-nerd-font &> /dev/null; then
    log "Instalando JetBrainsMono Nerd Font..."
    brew install --cask font-jetbrains-mono-nerd-font || warn "Falha ao instalar a fonte (talvez já instalada manualmente)."
else
    ok "JetBrainsMono Nerd Font já instalada."
fi

if ! command -v claude &> /dev/null; then
    log "Instalando Claude Code CLI..."
    brew install --cask claude-code || warn "Falha ao instalar Claude Code. Veja https://docs.claude.com/claude-code"
else
    ok "Claude Code CLI presente ($(command -v claude))."
fi

# Ollama: autocomplete local e gratuito (somente com AI_PROVIDER=ollama)
if [ "$AI_PROVIDER" == "ollama" ]; then
    OLLAMA_CODE_MODEL="${OLLAMA_CODE_MODEL:-qwen2.5-coder:3b-base}"
    if ! command -v ollama &> /dev/null; then
        log "Instalando Ollama..."
        brew install ollama
    fi
    if ! curl -fsS http://localhost:11434/api/version &> /dev/null; then
        log "Iniciando serviço do Ollama (brew services; inicia junto com o login)..."
        brew services start ollama
        for _ in $(seq 1 15); do
            curl -fsS http://localhost:11434/api/version &> /dev/null && break
            sleep 1
        done
    fi
    if ollama list 2> /dev/null | awk '{print $1}' | grep -qx "$OLLAMA_CODE_MODEL"; then
        ok "Modelo Ollama $OLLAMA_CODE_MODEL já baixado."
    else
        log "Baixando modelo $OLLAMA_CODE_MODEL (alguns GB, só na primeira vez)..."
        ollama pull "$OLLAMA_CODE_MODEL" || warn "Falha ao baixar modelo; rode depois: ollama pull $OLLAMA_CODE_MODEL"
    fi
fi

# ------------------------------------------------------------------------------
# 5. Backup de configuração não gerenciada (somente na primeira execução)
# ------------------------------------------------------------------------------
if [ ! -f "$MARKER" ]; then
    for target in "$NVIM_CONFIG_DIR" "$HOME/.local/share/nvim" "$HOME/.local/state/nvim" "$HOME/.cache/nvim"; do
        if [ -e "$target" ]; then
            warn "Movendo $target -> ${target}.bak_${BACKUP_STAMP}"
            mv "$target" "${target}.bak_${BACKUP_STAMP}"
        fi
    done
fi
mkdir -p "$NVIM_CONFIG_DIR"
touch "$MARKER"

# ------------------------------------------------------------------------------
# 6. Sincroniza arquivos de configuração (copia apenas o que mudou; não apaga
#    arquivos extras que você criar em ~/.config/nvim/lua/plugins/)
# ------------------------------------------------------------------------------
log "Sincronizando configuração em $NVIM_CONFIG_DIR..."
CHANGED=0
while IFS= read -r -d '' file; do
    rel="${file#"$SRC_DIR"/}"
    dest="$NVIM_CONFIG_DIR/$rel"
    if ! cmp -s "$file" "$dest"; then
        mkdir -p "$(dirname "$dest")"
        cp "$file" "$dest"
        ok "atualizado: $rel"
        CHANGED=1
    fi
done < <(find "$SRC_DIR" -type f -print0)

# Remove arquivos de versões antigas deste instalador
for old in "lua/plugins/custom_stack.lua" "lua/plugins/ai-claude.lua"; do
    if [ -f "$NVIM_CONFIG_DIR/$old" ]; then
        rm -f "$NVIM_CONFIG_DIR/$old"
        ok "removido (obsoleto): $old"
        CHANGED=1
    fi
done
[ "$CHANGED" -eq 0 ] && ok "Arquivos de configuração já atualizados."

# ------------------------------------------------------------------------------
# 7. lazyvim.json (extras do LazyVim). Gerado aqui por depender do AI_PROVIDER.
# ------------------------------------------------------------------------------
EXTRAS=(
    # IA
    ai.claudecode
    # editor
    coding.mini-surround
    coding.yanky
    editor.harpoon2
    editor.inc-rename
    editor.refactoring
    editor.outline
    editor.dial
    editor.overseer
    ui.treesitter-context
    util.dot
    util.project
    util.rest
    util.mini-hipatterns
    # debug + testes
    dap.core
    test.core
    # linguagens
    lang.java
    lang.go
    lang.python
    lang.typescript
    lang.json
    lang.yaml
    lang.toml
    lang.markdown
    lang.docker
    lang.helm
    lang.sql
    lang.terraform
    lang.tailwind
    lang.git
    # lint / format
    linting.eslint
    formatting.prettier
)
# copilot/codeium vêm de extras do LazyVim; ollama/claude usam lua/plugins/ai-minuet.lua
case "$AI_PROVIDER" in
    copilot|codeium) EXTRAS=("ai.$AI_PROVIDER" "${EXTRAS[@]}") ;;
esac

TMP_AI=$(mktemp)
{
    [ "$AI_PROVIDER" == "ollama" ] && echo "vim.g.ollama_code_model = \"$OLLAMA_CODE_MODEL\""
    echo "return \"$AI_PROVIDER\""
} > "$TMP_AI"
if ! cmp -s "$TMP_AI" "$NVIM_CONFIG_DIR/lua/config/ai_provider.lua"; then
    mkdir -p "$NVIM_CONFIG_DIR/lua/config"
    mv "$TMP_AI" "$NVIM_CONFIG_DIR/lua/config/ai_provider.lua"
else
    rm -f "$TMP_AI"
fi

TMP_JSON=$(mktemp)
{
    echo '{'
    echo '  "extras": ['
    sorted=$(printf '%s\n' "${EXTRAS[@]}" | sort)
    last=$(echo "$sorted" | tail -1)
    while IFS= read -r e; do
        sep=","; [ "$e" == "$last" ] && sep=""
        echo "    \"lazyvim.plugins.extras.$e\"$sep"
    done <<< "$sorted"
    echo '  ],'
    echo '  "install_version": 8,'
    echo '  "news": {},'
    echo '  "version": 8'
    echo '}'
} > "$TMP_JSON"
if ! cmp -s "$TMP_JSON" "$NVIM_CONFIG_DIR/lazyvim.json"; then
    mv "$TMP_JSON" "$NVIM_CONFIG_DIR/lazyvim.json"
    ok "lazyvim.json atualizado (IA: $AI_PROVIDER)."
else
    rm -f "$TMP_JSON"
    ok "lazyvim.json já atualizado (IA: $AI_PROVIDER)."
fi

# ------------------------------------------------------------------------------
# 8. Git: nvim como difftool/mergetool (somente se você ainda não definiu um)
# ------------------------------------------------------------------------------
if [ -z "${SKIP_GIT_CONFIG:-}" ]; then
    set_git_if_unset() {
        if [ -z "$(git config --global --get "$1" || true)" ]; then
            git config --global "$1" "$2"
            ok "git config --global $1 = $2"
        fi
    }
    set_git_if_unset merge.tool nvimdiff
    set_git_if_unset diff.tool nvimdiff
    set_git_if_unset mergetool.keepBackup false
    set_git_if_unset mergetool.prompt false
    set_git_if_unset difftool.prompt false
    set_git_if_unset merge.conflictstyle zdiff3
    set_git_if_unset rerere.enabled true
fi

# ------------------------------------------------------------------------------
# 9. Plugins, ferramentas Mason e parsers Treesitter
# ------------------------------------------------------------------------------
log "Sincronizando plugins (Lazy.nvim)..."
nvim --headless "+Lazy! sync" +qa < /dev/null || warn "Lazy sync retornou erro; abra o nvim e rode :Lazy sync."

MASON_TOOLS=(
    # Java
    jdtls java-debug-adapter java-test google-java-format
    # Go
    gopls goimports gofumpt gomodifytags impl delve golangci-lint
    # Python
    pyright ruff debugpy
    # JS / TS
    vtsls eslint-lsp prettier js-debug-adapter tailwindcss-language-server
    # Docker / Kubernetes / YAML / Terraform
    dockerfile-language-server docker-compose-language-service hadolint
    yaml-language-server helm-ls terraform-ls tflint
    # SQL
    sqlfluff
    # Misc
    json-lsp taplo marksman markdownlint-cli2 markdown-toc
    lua-language-server stylua shfmt shellcheck bash-language-server
)
MASON_DIR="$HOME/.local/share/nvim/mason/packages"
MISSING_TOOLS=()
for t in "${MASON_TOOLS[@]}"; do
    [ -d "$MASON_DIR/$t" ] || MISSING_TOOLS+=("$t")
done
if [ ${#MISSING_TOOLS[@]} -gt 0 ]; then
    log "Instalando via Mason: ${MISSING_TOOLS[*]}"
    nvim --headless "+Lazy! load mason.nvim" "+MasonInstall ${MISSING_TOOLS[*]}" +qa < /dev/null \
        || warn "Algumas ferramentas Mason falharam; abra o nvim e rode :Mason."
else
    ok "Ferramentas Mason já instaladas."
fi

log "Instalando parsers Treesitter..."
nvim --headless "+Lazy! load nvim-treesitter" \
    "+lua local ok, ts = pcall(require, 'nvim-treesitter'); if ok and ts.install then ts.install(LazyVim.opts('nvim-treesitter').ensure_installed or {}):wait(900000) end" \
    +qa < /dev/null || warn "Parsers serão instalados na primeira abertura do nvim."

# ------------------------------------------------------------------------------
echo ""
echo "=============================================================================="
ok "Setup concluído! (seguro para re-executar)"
echo "=============================================================================="
echo "1. Terminal: selecione a fonte 'JetBrainsMono Nerd Font'."
case "$AI_PROVIDER" in
    copilot)    echo "2. IA: abra o nvim e rode ':Copilot auth' (GitHub Copilot, plano Free disponível)." ;;
    claude)
        if [ -n "${ANTHROPIC_API_KEY:-}" ]; then
            echo "2. IA: Claude (minuet-ai) usando ANTHROPIC_API_KEY já definida."
        else
            echo "2. IA: crie uma API key em https://console.anthropic.com e adicione ao ~/.zshrc:"
            echo "      export ANTHROPIC_API_KEY=\"sk-ant-...\""
        fi ;;
    codeium)    echo "2. IA: abra o nvim, rode ':Codeium Auth', faça login no navegador e cole o token (gratuito)." ;;
    ollama)     echo "2. IA: Ollama local ativo (gratuito, offline). Nada a configurar." ;;
    none)       echo "2. IA: autocomplete com IA desativado." ;;
esac
echo "3. Claude Code: rode 'claude' uma vez no terminal para logar; no nvim use <Space>ac."
echo "4. Veja README.md para atalhos (Git, diff, conflitos, Java, Kubernetes, MySQL)."
