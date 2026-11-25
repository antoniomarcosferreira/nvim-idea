# Neovim Pro Setup para macOS

Configuração baseada no **LazyVim** para desenvolvimento diário com **Java, Go, Python, JavaScript/TypeScript, Docker, Kubernetes/Helm, MySQL, Terraform e Git**, com **Claude Code** integrado e **autocomplete com IA** (ghost text, igual IntelliJ/VS Code).

## Instalação

```bash
chmod +x install.sh
./install.sh                        # autocomplete IA com Codeium (padrão, grátis)
AI_PROVIDER=ollama ./install.sh     # IA local com Ollama (grátis, offline, privado)
AI_PROVIDER=copilot ./install.sh    # GitHub Copilot (plano Free limitado ou pago)
AI_PROVIDER=claude ./install.sh     # Claude via API Anthropic (pago por uso)
AI_PROVIDER=none ./install.sh       # sem IA no autocomplete
SKIP_GIT_CONFIG=1 ./install.sh      # não mexe no ~/.gitconfig
```

O instalador é **idempotente**: pode rodar quantas vezes quiser. Ele instala só o que falta, sincroniza só os arquivos alterados e faz backup da config antiga apenas na primeira execução (`~/.config/nvim.bak_<data>`).

Depois de instalar:

1. Configure o terminal para usar a fonte **JetBrainsMono Nerd Font**.
2. Abra o `nvim` e autentique a IA: `:Codeium Auth` (Ollama não precisa; Copilot: `:Copilot auth`).
3. Rode `claude` uma vez no terminal para logar no Claude Code.
4. Use `:checkhealth` e `:Mason` para conferir LSPs e ferramentas.

### Estrutura

```
install.sh            # instalador (brew, mason, treesitter, git config)
config/               # copiado para ~/.config/nvim
  lua/config/         # options, keymaps, autocmds, bootstrap do lazy
  lua/plugins/        # git, java, kubernetes, sql, ui
```

Para customizar: edite os arquivos em `config/` e rode `./install.sh` de novo. Arquivos novos que você criar direto em `~/.config/nvim/lua/plugins/` são preservados. A lista de extras do LazyVim fica no `install.sh` (seção 7); se ativar extras pelo `:LazyExtras`, adicione também lá, senão o instalador sobrescreve.

### Qual IA de autocomplete escolher

| Opção | Custo | Prós | Contras |
| :--- | :--- | :--- | :--- |
| `codeium` (padrão) | Grátis, ilimitado | Rápido, boa qualidade | Exige conta; plugin em modo de manutenção pela Cognition (dona do Windsurf/Devin) |
| `ollama` | Grátis | Offline, código não sai da máquina, nunca é descontinuado | Usa RAM/CPU; qualidade menor que os serviços na nuvem |
| `copilot` | Free: 2.000 sugestões/mês; pago: US$ 10/mês | Melhor qualidade | Limite no plano Free |
| `claude` | Pago por uso | Modelos Claude | Mais lento e caro para autocomplete |

Trocar é só rodar o instalador de novo com outro `AI_PROVIDER`.

### Autocomplete local com Ollama

Com `AI_PROVIDER=ollama`, o instalador instala o Ollama, inicia o serviço (`brew services`, sobe junto com o login) e baixa o modelo `qwen2.5-coder:3b-base` (~2 GB), bom equilíbrio entre velocidade e qualidade num Mac com 16 GB.

- Modelo menor e mais rápido: `OLLAMA_CODE_MODEL=qwen2.5-coder:1.5b-base AI_PROVIDER=ollama ./install.sh`
- Modelo maior e melhor (mais lento): `OLLAMA_CODE_MODEL=qwen2.5-coder:7b-base AI_PROVIDER=ollama ./install.sh`
- Parar o serviço: `brew services stop ollama`.

### Autocomplete com Claude

Com `AI_PROVIDER=claude`, o plugin [minuet-ai.nvim](https://github.com/milanglacier/minuet-ai.nvim) envia o código ao redor do cursor para a API da Anthropic e mostra a sugestão como ghost text.

- Precisa de uma API key (https://console.anthropic.com), cobrada por uso. A assinatura Claude Pro/Max **não** cobre a API.
- Modelo padrão: `claude-haiku-4-5` (o mais rápido e barato: US$ 1 por milhão de tokens de entrada, US$ 5 de saída). Para trocar: `export MINUET_CLAUDE_MODEL=claude-sonnet-5-5`.
- A chave fica no shell: `export ANTHROPIC_API_KEY="sk-ant-..."` no `~/.zshrc`.

---

## O que é instalado

| Área | Ferramentas |
| :--- | :--- |
| Java | jdtls (com Lombok), debug, testes JUnit, google-java-format. jdtls roda com JDK 21+, mas todos os JDKs instalados (8/11/17/21/25) são registrados como runtimes |
| Go | gopls, gofumpt, goimports, golangci-lint, delve, gomodifytags, impl |
| Python | pyright, ruff, debugpy, seletor de venv |
| JS/TS | vtsls, eslint, prettier, js-debug-adapter, tailwind |
| Docker | dockerfile-ls, docker-compose-ls, hadolint |
| Kubernetes | yaml-ls com schemas (k8s + SchemaStore), helm-ls, kubectl.nvim, k9s |
| MySQL | vim-dadbod + UI + autocomplete de tabelas/colunas, sqlfluff (dialeto MySQL) |
| Git | gitsigns, lazygit, diffview, git-conflict, fugitive, delta, gh |
| IA | Claude Code (claudecode.nvim) + autocomplete com Codeium, Ollama, Copilot ou Claude |
| Geral | debugger (DAP), test runner (neotest), REST client, refactoring, outline, harpoon, task runner (overseer) |

---

## Atalhos

`<Space>` é a tecla Leader. Pressione `<Space>` e espere para ver todos os atalhos (which-key).

### IA

| Atalho | Ação |
| :--- | :--- |
| `<Tab>` (insert) | Aceita sugestão da IA (ghost text) |
| `Alt-]` / `Alt-[` | Próxima / anterior sugestão |
| `Alt-l` / `Alt-w` | Aceita só a linha / só a palavra (Ollama/Claude) |
| `Alt-e` | Descarta a sugestão (Ollama/Claude) |
| `<Space> a t` | Liga/desliga o autocomplete (Ollama/Claude) |
| `<Space> a c` | Abre/fecha o Claude Code |
| `<Space> a f` | Foca o Claude Code |
| `<Space> a r` / `a C` | Retomar / continuar sessão |
| `<Space> a b` | Envia o buffer atual como contexto |
| `<Space> a s` (visual) | Envia a seleção para o Claude |
| `<Space> a a` / `a d` | Aceita / rejeita o diff proposto pelo Claude |

### Git: diff, compare e conflitos

| Atalho | Ação |
| :--- | :--- |
| `<Space> g g` | LazyGit (commit, push, rebase, stash, branches) |
| `<Space> g v o` | Diffview: todas as alterações (estilo IDE) |
| `<Space> g v s` | Diffview: só o que está em stage |
| `<Space> g v b` | Compara com branch/tag/commit/range (ex.: `origin/main`, `HEAD~3`, `main...feature`) |
| `<Space> g v f` | Histórico do arquivo atual (visual: histórico das linhas selecionadas) |
| `<Space> g v F` | Histórico do repositório |
| `<Space> g v m` | Merge tool 3 vias durante conflitos (OURS / BASE / THEIRS + resultado) |
| `<Space> g v c` | Fecha o Diffview |
| `<Space> g w w` / `g w o` | Compara as duas janelas visíveis / desliga o diff |
| `]x` / `[x` | Próximo / anterior conflito |
| `co` / `ct` / `cb` / `c0` | Escolhe ours / theirs / ambos / nenhum (no conflito sob o cursor) |
| `<Space> g x l` | Lista todos os conflitos no quickfix |
| `<Space> g 3` | Split 3 vias do fugitive (`:Gvdiffsplit!`) |
| `]h` / `[h` | Próximo / anterior hunk alterado |
| `<Space> g h s` / `g h r` | Stage / reset do hunk |
| `<Space> g h p` | Preview do hunk |
| `<Space> g b` / `g A` | Blame da linha / do arquivo |
| `<Space> g f` | Histórico do arquivo (picker) |
| `<Space> g d` | Diff em hunks (picker) |
| `<Space> g B` | Abre o arquivo no GitHub/GitLab |

Dentro do Diffview: `<Tab>` alterna arquivos, `-` faz stage/unstage, `X` restaura o arquivo, `[x`/`]x` navega conflitos, `<Space>co`/`ct`/`cb`/`ca` escolhe ours/theirs/base/todos.

No terminal, `git mergetool` e `git difftool` abrem o nvim (configurado apenas se você não tinha outra ferramenta definida). Também são ativados `merge.conflictstyle=zdiff3` (mostra a base no conflito) e `rerere` (lembra resoluções repetidas).

### Código (todas as linguagens)

| Atalho | Ação |
| :--- | :--- |
| `gd` / `gr` / `gI` / `gy` | Definição / referências / implementações / tipo |
| `K` | Documentação |
| `<Space> c a` | Code actions (imports, quick fix) |
| `<Space> c r` | Renomear símbolo |
| `<Space> c f` | Formatar |
| `<Space> c s` | Outline de símbolos |
| `<Space> c o` | Organizar imports (Java) |
| `<Space> c x v/c/m` | Extrair variável / constante / método (Java) |
| `<Space> d b` / `d c` | Breakpoint / iniciar-continuar debug |
| `<Space> t t` / `t r` / `t s` | Rodar testes do arquivo / teste mais próximo / painel |
| `<Space> o o` | Rodar tarefa (overseer) |

### Busca

| Atalho | Ação |
| :--- | :--- |
| `<Space> <Space>` | Buscar arquivos |
| `<Space> /` | Grep no projeto |
| `<Space> s b` | Buscar no arquivo atual |
| `<Space> s w` | Grep da palavra sob o cursor |
| `<Space> s r` | Buscar e substituir no projeto (grug-far) |
| `<Space> s s` / `s S` | Símbolos do arquivo / workspace |
| `<Space> f p` | Projetos recentes |
| `s` + letras | Pular para qualquer lugar visível (flash) |
| `<Space> e` | Explorador de arquivos |

### Kubernetes, Docker e MySQL

| Atalho | Ação |
| :--- | :--- |
| `<Space> k k` | kubectl.nvim (pods, logs, describe, exec, port-forward) |
| `<Space> k 9` | k9s em janela flutuante |
| `<Space> D` | UI do banco de dados (dadbod) |

YAML em `k8s/`, `kubernetes/`, `manifests/`, `deploy/` ou `*.k8s.yaml` recebe validação e autocomplete do schema Kubernetes; `docker-compose.yml`, GitHub Actions etc. vêm do SchemaStore.

Conexão MySQL: na UI do banco aperte `A` e informe uma URL como `mysql://user:senha@localhost:3306/banco`, ou exporte no shell `export DB_UI_DEV="mysql://..."`. Para usar outro dialeto no sqlfluff: `export SQLFLUFF_DIALECT=postgres`.
