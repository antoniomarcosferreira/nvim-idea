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

`<Space>` é a tecla Leader. Pressione `<Space>` e espere para ver todos os atalhos (which-key). `<Space> s k` busca qualquer atalho pelo nome.

Notação: `<C-x>` = Ctrl+x, `<A-x>` / `Alt-x` = Option+x (no macOS, configure o terminal para usar Option como Meta/Esc+), `<S-x>` = Shift+x. "(visual)" = com texto selecionado; "(insert)" = no modo de inserção.

### Claude Code dentro do Neovim (claudecode.nvim)

| Atalho | Ação |
| :--- | :--- |
| `<Space> a c` | Abre/fecha o Claude Code (terminal lateral) |
| `<Space> a f` | Foca o Claude Code |
| `<Space> a r` | Retoma uma sessão anterior (`--resume`) |
| `<Space> a C` | Continua a última sessão (`--continue`) |
| `<Space> a m` | Escolhe o modelo do Claude |
| `<Space> a b` | Envia o buffer atual como contexto |
| `<Space> a s` (visual) | Envia a seleção para o Claude |
| `<Space> a s` (no explorador) | Adiciona o arquivo/pasta sob o cursor ao contexto |
| `<Space> a a` | Aceita o diff proposto pelo Claude |
| `<Space> a d` | Rejeita o diff proposto pelo Claude |
| `:w` (no buffer de diff) | Também aceita o diff |
| `<C-\><C-n>` (no terminal) | Sai do modo terminal para o modo normal (rolar, copiar) |
| `<C-h>` / `<C-l>` | Pula entre o editor e o painel do Claude |

Comandos úteis: `:ClaudeCode`, `:ClaudeCodeAdd <arquivo>`, `:ClaudeCodeSend`, `:ClaudeCodeStatus`.

Os arquivos editados pelo Claude são recarregados automaticamente no Neovim (autocmd `checktime`).

### Claude Code no terminal (CLI)

Teclas dentro da sessão do `claude`:

| Atalho | Ação |
| :--- | :--- |
| `Enter` | Envia a mensagem |
| `\` + `Enter` / `Option+Enter` / `Shift+Enter` | Nova linha (rode `/terminal-setup` se `Shift+Enter` não funcionar) |
| `Esc` | Interrompe o Claude (para a resposta ou a ferramenta em execução) |
| `Esc` `Esc` | Volta para uma mensagem anterior para editar/refazer (`/rewind`) |
| `Shift+Tab` | Alterna modo: normal → aceitar edições automaticamente → plan mode |
| `Ctrl+C` | Cancela a entrada/geração atual (duas vezes: sai) |
| `Ctrl+D` | Sai da sessão |
| `Ctrl+L` | Limpa a tela (mantém a conversa) |
| `Ctrl+R` | Busca reversa no histórico de prompts |
| `↑` / `↓` | Navega no histórico de prompts |
| `Ctrl+O` | Liga/desliga o transcript detalhado (saída completa das ferramentas) |
| `Ctrl+T` | Mostra/esconde a lista de tarefas |
| `Ctrl+B` | Manda o comando bash em execução para segundo plano |
| `Ctrl+G` | Abre o prompt no `$EDITOR` (nvim) para escrever textos longos |
| `Ctrl+V` | Cola imagem da área de transferência (print de tela, por exemplo) |
| `Option+P` | Troca o modelo |
| `Option+T` | Liga/desliga o raciocínio estendido (thinking) |

Prefixos no prompt:

| Prefixo | Ação |
| :--- | :--- |
| `/` | Comandos (slash commands) |
| `@` | Menciona arquivo/pasta (`@src/main/App.java`) com autocomplete |
| `!` | Modo bash: roda o comando direto e o resultado entra na conversa (`! mvn test`) |

Slash commands:

| Comando | Ação |
| :--- | :--- |
| `/help` | Ajuda e lista de comandos |
| `/init` | Cria o `CLAUDE.md` do projeto (instruções e contexto permanentes) |
| `/memory` | Edita os arquivos de memória (`CLAUDE.md`) |
| `/clear` | Limpa a conversa (começa do zero) |
| `/compact [foco]` | Resume a conversa para liberar contexto |
| `/context` | Mostra o uso da janela de contexto |
| `/resume` | Retoma uma conversa anterior |
| `/rewind` | Volta a conversa e/ou o código para um ponto anterior |
| `/model` | Troca o modelo |
| `/review` | Revisão de código das alterações / PR |
| `/security-review` | Revisão de segurança das alterações |
| `/permissions` | Gerencia permissões de ferramentas |
| `/config` | Configurações (tema, editor, etc.) |
| `/status` / `/usage` / `/cost` | Status da conta, uso do plano, custo da sessão |
| `/mcp` | Gerencia servidores MCP |
| `/agents` | Gerencia subagentes |
| `/hooks` | Configura hooks |
| `/add-dir <pasta>` | Adiciona outro diretório à sessão |
| `/export` | Exporta a conversa |
| `/vim` | Ativa edição estilo Vim no prompt |
| `/terminal-setup` | Configura `Shift+Enter` no terminal |
| `/ide` | Conecta a sessão a um Neovim/IDE aberto |
| `/doctor` | Diagnóstico da instalação |
| `/login` / `/logout` | Entra / sai da conta |
| `/bug` | Reporta um problema |
| `/exit` | Sai |

Atalhos personalizados do CLI ficam em `~/.claude/keybindings.json`.

### Autocomplete com IA (ghost text)

| Atalho | Ação |
| :--- | :--- |
| `<Tab>` (insert) | Aceita a sugestão da IA |
| `Alt-]` / `Alt-[` | Próxima / anterior sugestão |
| `Alt-l` / `Alt-w` | Aceita só a linha / só a palavra (Ollama/Claude) |
| `Alt-e` | Descarta a sugestão (Ollama/Claude) |
| `<Space> a t` | Liga/desliga o autocomplete (Ollama/Claude) |

### Completion (menu de sugestões do LSP)

| Atalho | Ação |
| :--- | :--- |
| `<C-Space>` | Abre o menu de sugestões |
| `<C-n>` / `<C-p>` ou `↓` / `↑` | Próximo / anterior item |
| `Enter` | Confirma o item |
| `<C-e>` | Fecha o menu |
| `<C-b>` / `<C-f>` | Rola a documentação |
| `<Tab>` / `<S-Tab>` | Pula entre os campos do snippet |
| `<C-k>` (insert) | Assinatura da função (parâmetros) |
| `jk` (insert) | Sai do modo de inserção (atalho próprio desta config) |

### Arquivos, buffers e projetos

| Atalho | Ação |
| :--- | :--- |
| `<Space> <Space>` | Buscar arquivos (raiz do projeto) |
| `<Space> f f` / `f F` | Buscar arquivos (raiz / diretório atual) |
| `<Space> f g` | Arquivos do git |
| `<Space> f r` / `f R` | Arquivos recentes (geral / diretório atual) |
| `<Space> f c` | Arquivos de configuração do Neovim |
| `<Space> f n` | Novo arquivo |
| `<Space> f p` | Projetos recentes |
| `<Space> e` / `E` | Explorador de arquivos (raiz / diretório atual) |
| `<Space> ,` / `f b` | Lista de buffers abertos |
| `<S-h>` / `<S-l>` | Buffer anterior / próximo |
| `[b` / `]b` | Buffer anterior / próximo |
| `<Space> b b` ou ``<Space> ` `` | Alterna com o último buffer |
| `<Space> b d` | Fecha o buffer |
| `<Space> b o` | Fecha todos os outros buffers |
| `<Space> b D` | Fecha o buffer e a janela |
| `<Space> b p` / `b P` | Fixa o buffer / fecha os não fixados |
| `<Space> b l` / `b r` | Fecha buffers à esquerda / direita |
| `<C-s>` | Salva o arquivo |
| `<Space> q q` | Sai de tudo |

Dentro do explorador: `a` cria arquivo/pasta, `d` apaga, `r` renomeia, `c` copia, `m` move, `y` copia o caminho, `H` mostra ocultos, `I` mostra ignorados pelo git, `?` ajuda.

### Harpoon (arquivos favoritos)

| Atalho | Ação |
| :--- | :--- |
| `<Space> H` | Marca o arquivo atual |
| `<Space> h` | Menu do Harpoon (reordenar/remover com edição normal) |
| `<Space> 1` … `<Space> 9` | Vai para o arquivo marcado 1 … 9 |

### Janelas e abas

| Atalho | Ação |
| :--- | :--- |
| `<C-h>` / `<C-j>` / `<C-k>` / `<C-l>` | Vai para a janela à esquerda / abaixo / acima / à direita |
| `<C-↑>` / `<C-↓>` / `<C-←>` / `<C-→>` | Redimensiona a janela |
| `<Space> -` | Divide na horizontal |
| `<Space> \|` | Divide na vertical |
| `<Space> w d` | Fecha a janela |
| `<Space> w m` / `u Z` | Maximiza/restaura a janela (zoom) |
| `<Space> u z` | Modo zen |
| `<Space> <Tab> <Tab>` | Nova aba |
| `<Space> <Tab> ]` / `<Tab> [` | Próxima / anterior aba |
| `<Space> <Tab> d` / `<Tab> o` | Fecha a aba / fecha as outras |
| `<Space> <Tab> f` / `<Tab> l` | Primeira / última aba |

### Terminal

| Atalho | Ação |
| :--- | :--- |
| `<C-/>` | Abre/fecha o terminal flutuante (raiz do projeto) |
| `<Space> f t` / `f T` | Terminal (raiz / diretório atual) |
| `<C-\><C-n>` | Sai do modo terminal |

### Busca

| Atalho | Ação |
| :--- | :--- |
| `<Space> /` / `s g` | Grep no projeto |
| `<Space> s G` | Grep no diretório atual |
| `<Space> s w` | Grep da palavra sob o cursor (visual: da seleção) |
| `<Space> s b` | Buscar linhas no arquivo atual |
| `<Space> s r` | Buscar e substituir no projeto (grug-far) |
| `<Space> s s` / `s S` | Símbolos do arquivo / do workspace |
| `<Space> s k` | Atalhos de teclado |
| `<Space> s h` | Ajuda do Neovim |
| `<Space> s c` / `s C` / `<Space> :` | Histórico de comandos / comandos |
| `<Space> s d` / `s D` | Diagnósticos (projeto / buffer) |
| `<Space> s m` / `s j` | Marcas / jumps |
| `<Space> s "` | Registradores (o que foi copiado) |
| `<Space> s u` | Histórico de undo |
| `<Space> s q` / `s l` | Quickfix / location list |
| `<Space> s t` / `s T` | TODO/FIXME do projeto |
| `<Space> s R` | Reabre a última busca |
| `<Space> n` | Histórico de notificações |
| `<Space> u C` | Trocar colorscheme |

### Movimentação rápida (flash)

| Atalho | Ação |
| :--- | :--- |
| `s` + letras | Pula para qualquer lugar visível |
| `S` | Seleciona um bloco pela árvore de sintaxe (treesitter) |
| `r` (após operador) | Opera em texto remoto, ex.: `yr` + alvo copia sem mover o cursor |
| `<C-s>` (na busca `/`) | Liga/desliga o flash na busca |
| `<C-Space>` / `<BS>` | Expande / reduz a seleção pela sintaxe |
| `]f` / `[f` | Próxima / anterior função |
| `]c` / `[c` | Próxima / anterior classe |
| `]]` / `[[` | Próxima / anterior referência do símbolo sob o cursor |

### Código e LSP (todas as linguagens)

| Atalho | Ação |
| :--- | :--- |
| `gd` | Ir para definição |
| `gr` | Referências |
| `gI` | Implementações |
| `gy` | Definição do tipo |
| `gD` | Declaração |
| `K` | Documentação (hover) |
| `gK` | Assinatura da função |
| `<C-o>` / `<C-i>` | Volta / avança na lista de saltos (após `gd`) |
| `<Space> c a` | Code actions (imports, quick fix) |
| `<Space> c A` | Source actions |
| `<Space> c r` | Renomear símbolo (preview ao vivo) |
| `<Space> c R` | Renomear arquivo (atualiza imports) |
| `<Space> c f` | Formatar (visual: formata a seleção) |
| `<Space> c d` | Diagnóstico da linha |
| `<Space> c s` | Outline de símbolos (painel lateral) |
| `<Space> c c` / `c C` | Executa / atualiza CodeLens |
| `<Space> c l` | Info do LSP |
| `<Space> c m` | Mason (instalar LSPs/ferramentas) |
| `]d` / `[d` | Próximo / anterior diagnóstico |
| `]e` / `[e` | Próximo / anterior erro |
| `]w` / `[w` | Próximo / anterior aviso |
| `gcc` / `gc` (visual) | Comenta/descomenta linha / seleção |
| `gco` / `gcO` | Adiciona comentário abaixo / acima |
| `<A-j>` / `<A-k>` | Move a linha (ou seleção) para baixo / cima |
| `<C-a>` / `<C-x>` | Incrementa/decrementa número, data, `true/false` etc. (dial) |

### Refatoração

| Atalho | Ação |
| :--- | :--- |
| `<Space> r s` | Menu de refatorações |
| `<Space> r i` | Inline de variável |
| `<Space> r x` (visual) | Extrair variável |
| `<Space> r f` (visual) | Extrair função |
| `<Space> r F` (visual) | Extrair função para arquivo |
| `<Space> r b` | Extrair bloco |
| `<Space> r p` / `r P` | Debug print da variável / debug print |
| `<Space> r c` | Remove os debug prints |

### Java

| Atalho | Ação |
| :--- | :--- |
| `<Space> c o` | Organizar imports |
| `<Space> c x v` | Extrair variável |
| `<Space> c x c` | Extrair constante |
| `<Space> c x m` (visual) | Extrair método |
| `gs` | Ir para a superclasse/método sobrescrito |
| `<Space> t t` / `t r` | Roda os testes da classe / o teste mais próximo |

### TypeScript / JavaScript

| Atalho | Ação |
| :--- | :--- |
| `<Space> c o` | Organizar imports |
| `<Space> c M` | Adicionar imports faltando |
| `<Space> c u` | Remover imports não usados |
| `<Space> c D` | Corrigir todos os diagnósticos |
| `gD` | Ir para o código-fonte da definição |
| `gR` | Referências do arquivo |

### Python e Markdown

| Atalho | Ação |
| :--- | :--- |
| `<Space> c v` | Selecionar virtualenv (Python) |
| `<Space> c p` | Preview do Markdown no navegador |

### Debug (DAP)

| Atalho | Ação |
| :--- | :--- |
| `<Space> d b` | Liga/desliga breakpoint |
| `<Space> d B` | Breakpoint condicional |
| `<Space> d c` | Inicia / continua |
| `<Space> d a` | Roda com argumentos |
| `<Space> d C` | Roda até o cursor |
| `<Space> d i` | Step into |
| `<Space> d O` | Step over |
| `<Space> d o` | Step out |
| `<Space> d l` | Repete a última execução |
| `<Space> d P` | Pausa |
| `<Space> d t` | Encerra |
| `<Space> d u` | Abre/fecha a UI do debug |
| `<Space> d e` | Avalia expressão (visual: a seleção) |
| `<Space> d r` | REPL |
| `<Space> d w` | Widgets (escopos, variáveis) |

### Testes (neotest)

| Atalho | Ação |
| :--- | :--- |
| `<Space> t t` | Roda os testes do arquivo |
| `<Space> t T` | Roda todos os testes |
| `<Space> t r` | Roda o teste mais próximo |
| `<Space> t l` | Repete o último teste |
| `<Space> t d` | Debuga o teste mais próximo |
| `<Space> t s` | Painel de testes |
| `<Space> t o` / `t O` | Saída do teste / painel de saída |
| `<Space> t w` | Modo watch (roda ao salvar) |
| `<Space> t S` | Para os testes |

### Tarefas (overseer) e REST client

| Atalho | Ação |
| :--- | :--- |
| `<Space> o o` | Roda uma tarefa (make, npm, mvn, go etc.) |
| `<Space> o w` | Lista de tarefas |
| `<Space> o q` | Ações da última tarefa |
| `<Space> o t` | Ações de uma tarefa |
| `<Space> R s` | Envia a requisição HTTP sob o cursor (arquivos `.http`) |
| `<Space> R a` | Envia todas as requisições do arquivo |
| `<Space> R r` | Repete a última requisição |
| `<Space> R b` | Abre um rascunho de requisições |
| `<Space> R c` | Copia a requisição como cURL |

### Diagnósticos e listas (trouble)

| Atalho | Ação |
| :--- | :--- |
| `<Space> x x` / `x X` | Diagnósticos do projeto / do buffer |
| `<Space> c S` | Referências e definições do LSP |
| `<Space> x q` / `x Q` | Quickfix |
| `<Space> x l` / `x L` | Location list |
| `<Space> x t` | TODOs |
| `]q` / `[q` | Próximo / anterior item do quickfix |
| `]t` / `[t` | Próximo / anterior TODO |

### Git: diff, compare e conflitos

| Atalho | Ação |
| :--- | :--- |
| `<Space> g g` / `g G` | LazyGit (raiz / diretório atual): commit, push, rebase, stash, branches |
| `<Space> g s` | Status do git (picker) |
| `<Space> g l` / `g L` | Log do git (raiz / diretório atual) |
| `<Space> g S` | Stashes |
| `<Space> g F` | Status do fugitive (`:Git`) |
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
| `<Space> g x o` / `x t` / `x b` / `x n` | Mesmo que acima, via leader |
| `<Space> g x l` | Lista todos os conflitos no quickfix |
| `<Space> g 3` | Split 3 vias do fugitive (`:Gvdiffsplit!`) |
| `]h` / `[h` | Próximo / anterior hunk alterado |
| `<Space> g h s` / `g h r` | Stage / reset do hunk |
| `<Space> g h S` / `g h R` | Stage / reset do arquivo inteiro |
| `<Space> g h u` | Desfaz o stage do hunk |
| `<Space> g h p` | Preview do hunk |
| `<Space> g h d` | Diff do arquivo contra o index |
| `<Space> g b` / `g A` | Blame da linha / do arquivo |
| `<Space> g f` | Histórico do arquivo (picker) |
| `<Space> g d` | Diff em hunks (picker) |
| `<Space> g B` | Abre o arquivo no GitHub/GitLab |

Dentro do Diffview: `<Tab>` alterna arquivos, `-` faz stage/unstage, `X` restaura o arquivo, `[x`/`]x` navega conflitos, `<Space>co`/`ct`/`cb`/`ca` escolhe ours/theirs/base/todos.

Dentro do LazyGit: `space` stage, `c` commit, `P` push, `p` pull, `b` branches, `s` stash, `r` rebase, `?` ajuda, `q` sai.

No terminal, `git mergetool` e `git difftool` abrem o nvim (configurado apenas se você não tinha outra ferramenta definida). Também são ativados `merge.conflictstyle=zdiff3` (mostra a base no conflito) e `rerere` (lembra resoluções repetidas).

### Kubernetes, Docker e MySQL

| Atalho | Ação |
| :--- | :--- |
| `<Space> k k` | kubectl.nvim (pods, logs, describe, exec, port-forward) |
| `<Space> k 9` | k9s em janela flutuante |
| `<Space> D` | UI do banco de dados (dadbod) |
| `<Space> S` (buffer SQL da UI) | Executa a query (visual: só a seleção) |
| `<Space> W` (buffer SQL da UI) | Salva a query |

YAML em `k8s/`, `kubernetes/`, `manifests/`, `deploy/` ou `*.k8s.yaml` recebe validação e autocomplete do schema Kubernetes; `docker-compose.yml`, GitHub Actions etc. vêm do SchemaStore.

Conexão MySQL: na UI do banco aperte `A` e informe uma URL como `mysql://user:senha@localhost:3306/banco`, ou exporte no shell `export DB_UI_DEV="mysql://..."`. Para usar outro dialeto no sqlfluff: `export SQLFLUFF_DIALECT=postgres`.

### Edição (surround, yank, texto)

| Atalho | Ação |
| :--- | :--- |
| `gsa` + movimento + caractere | Envolve com aspas/parênteses (ex.: `gsaiw"`) |
| `gsd` + caractere | Remove o envoltório (ex.: `gsd"`) |
| `gsr` + antigo + novo | Troca o envoltório (ex.: `gsr"'`) |
| `<Space> p` | Histórico de cópias (yank history) |
| `[y` / `]y` (depois de colar) | Alterna entre cópias anteriores |
| `vaf` / `vif` | Seleciona a função inteira / o corpo |
| `vac` / `vic` | Seleciona a classe |
| `vaa` / `via` | Seleciona o argumento |
| `vaq` / `viq` | Seleciona entre aspas |
| `vab` / `vib` | Seleciona entre parênteses/colchetes/chaves |

### Interface (toggles)

| Atalho | Ação |
| :--- | :--- |
| `<Space> u f` / `u F` | Liga/desliga formatar ao salvar (global / buffer) |
| `<Space> u w` | Quebra de linha |
| `<Space> u l` / `u L` | Números de linha / números relativos |
| `<Space> u d` | Diagnósticos |
| `<Space> u h` | Inlay hints |
| `<Space> u s` | Corretor ortográfico |
| `<Space> u t` | Contexto do treesitter (cabeçalho da função no topo) |
| `<Space> u g` | Guias de indentação |
| `<Space> u b` | Fundo claro/escuro |
| `<Space> u n` | Fecha as notificações |
| `<Esc>` | Limpa o destaque da busca |
| `<Space> l` | Lazy (gerenciador de plugins) |
| `<Space> L` | Changelog do LazyVim |

---

## Comandos mais utilizados no dia a dia

### Vim: o essencial

| Comando | Ação |
| :--- | :--- |
| `i` / `a` / `o` / `O` | Insere antes / depois do cursor / nova linha abaixo / acima |
| `I` / `A` | Insere no início / fim da linha |
| `Esc` ou `jk` | Volta ao modo normal |
| `v` / `V` / `<C-v>` | Seleção por caractere / linha / bloco (coluna) |
| `w` / `b` / `e` | Próxima palavra / anterior / fim da palavra |
| `0` / `^` / `$` | Início da linha / primeiro caractere / fim da linha |
| `gg` / `G` / `42G` | Início / fim do arquivo / linha 42 |
| `%` | Pula para o parêntese/chave correspondente |
| `<C-d>` / `<C-u>` | Meia página para baixo / cima |
| `zz` | Centraliza a tela no cursor |
| `dd` / `yy` / `p` / `P` | Recorta / copia a linha / cola depois / antes |
| `ciw` / `ci"` / `ci(` | Troca a palavra / o texto entre aspas / entre parênteses |
| `diw` / `dap` | Apaga a palavra / o parágrafo |
| `x` / `r` | Apaga o caractere / substitui o caractere |
| `u` / `<C-r>` | Desfaz / refaz |
| `.` | Repete a última alteração |
| `>>` / `<<` / `=` | Indenta / desindenta / reindenta |
| `/texto` + `n` / `N` | Busca e vai para a próxima / anterior ocorrência |
| `*` / `#` | Busca a palavra sob o cursor (frente / trás) |
| `ma` / `` `a `` | Marca a posição `a` / volta para ela |
| `qa` … `q` / `@a` / `@@` | Grava macro em `a` / executa / repete |
| `za` / `zR` / `zM` | Abre-fecha dobra / abre todas / fecha todas |

### Comandos do Neovim

| Comando | Ação |
| :--- | :--- |
| `:w` / `:wa` | Salva / salva todos |
| `:q` / `:qa` / `:q!` | Fecha / fecha tudo / fecha sem salvar |
| `:wq` ou `ZZ` | Salva e fecha |
| `:e!` | Descarta as alterações e recarrega o arquivo |
| `:%s/antigo/novo/gc` | Substitui no arquivo pedindo confirmação |
| `:'<,'>s/antigo/novo/g` | Substitui só na seleção |
| `:g/padrão/d` | Apaga todas as linhas que casam com o padrão |
| `:sort` / `:sort u` | Ordena linhas / ordena e remove duplicadas |
| `:Lazy` / `:Lazy sync` | Plugins / atualiza plugins |
| `:Mason` | LSPs, formatters e linters |
| `:LazyExtras` | Extras do LazyVim |
| `:checkhealth` | Diagnóstico geral |
| `:LspInfo` / `:LspRestart` | Info do LSP / reinicia o LSP |
| `:ConformInfo` | Formatters ativos no buffer |
| `:TSUpdate` | Atualiza parsers do treesitter |
| `:Git <comando>` | Qualquer comando git (fugitive) |
| `:DiffviewOpen origin/main` | Compara com outro branch |
| `:ClaudeCode` | Abre o Claude Code |

### Claude Code (terminal)

```bash
claude                               # inicia sessão interativa no diretório atual
claude "explique a arquitetura"      # inicia já com um prompt
claude -c                            # continua a última conversa
claude -r                            # escolhe uma conversa anterior para retomar
claude -p "resuma o README"          # modo não interativo (responde e sai)
git diff | claude -p "revise"        # envia a saída de um comando como contexto
tail -200 app.log | claude -p "por que falhou?"
claude --model opus                  # escolhe o modelo
claude --permission-mode plan        # começa em plan mode (só planeja, não edita)
claude --add-dir ../outro-projeto    # dá acesso a outro diretório
claude mcp list                      # lista servidores MCP
claude mcp add <nome> -- <comando>   # adiciona servidor MCP
claude update                        # atualiza o Claude Code
claude doctor                        # diagnóstico da instalação
```

Fluxo típico: `<Space> a c` para abrir o Claude ao lado do código, selecione um trecho e `<Space> a s` para enviar, peça a mudança, revise o diff e aceite com `<Space> a a` (ou rejeite com `<Space> a d`). Para tarefas grandes, comece em plan mode (`Shift+Tab` duas vezes).

### Git

```bash
git status -sb                       # status resumido
git switch -c feature/x              # cria e troca de branch
git switch main && git pull --rebase # atualiza a main
git add -p                           # stage interativo por hunk
git commit -m "feat: ..."            # commit
git commit --amend --no-edit         # adiciona ao último commit
git push -u origin HEAD              # publica o branch atual
git fetch && git rebase origin/main  # atualiza o branch com a main
git stash / git stash pop            # guarda / recupera alterações
git log --oneline --graph -20        # histórico resumido
git diff main...HEAD                 # o que o branch mudou
git restore <arquivo>                # descarta alterações do arquivo
git reset --soft HEAD~1              # desfaz o último commit mantendo as alterações
git mergetool                        # resolve conflitos no nvim
gh pr create --fill                  # abre PR
gh pr checkout 123                   # baixa o PR 123
gh pr view --web                     # abre o PR no navegador
```

### Docker e Kubernetes

```bash
docker ps                            # containers rodando
docker compose up -d                 # sobe os serviços
docker compose logs -f <serviço>     # acompanha logs
docker compose down                  # derruba os serviços
docker exec -it <container> sh       # shell dentro do container
docker build -t app:dev .            # build da imagem

kubectl config get-contexts          # contextos disponíveis
kubectl config use-context <ctx>     # troca de contexto
kubectl get pods -n <ns>             # pods do namespace
kubectl logs -f <pod> -n <ns>        # acompanha logs
kubectl describe pod <pod> -n <ns>   # detalhes e eventos
kubectl exec -it <pod> -n <ns> -- sh # shell no pod
kubectl port-forward svc/<svc> 8080:80 -n <ns>
kubectl apply -f k8s/                # aplica manifests
kubectl rollout restart deploy/<app> -n <ns>
helm upgrade --install <rel> ./chart -n <ns> -f values.yaml
k9s                                  # UI do cluster no terminal
```

### Build e testes

```bash
mvn clean verify                     # Maven: build + testes
mvn test -Dtest=MinhaClasseTest      # Maven: um teste
./gradlew build                      # Gradle: build + testes
./gradlew test --tests '*MinhaClasse*'
go test ./...                        # Go: todos os testes
go run .                             # Go: executa
pytest -k nome_do_teste              # Python: filtra testes
npm run dev / npm test               # JS/TS
terraform fmt && terraform plan      # Terraform
```
