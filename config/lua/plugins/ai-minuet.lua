-- Inline AI autocomplete via minuet-ai.nvim, for providers LazyVim has no extra for.
-- Enabled when the installer was run with AI_PROVIDER=ollama or AI_PROVIDER=claude
-- (it writes the choice to lua/config/ai_provider.lua).
--   ollama: free, local, offline. Model comes from the installer (OLLAMA_CODE_MODEL).
--   claude: Anthropic API, paid per use. Needs ANTHROPIC_API_KEY.
--           MINUET_CLAUDE_MODEL overrides the model (default: claude-haiku-4-5).

local ok, provider = pcall(require, "config.ai_provider")
if not ok or (provider ~= "ollama" and provider ~= "claude") then
  return {}
end

local provider_opts = {
  ollama = {
    provider = "openai_fim_compatible",
    context_window = 2048, -- small context keeps local inference fast; raise if your machine keeps up
    request_timeout = 3,
    provider_options = {
      openai_fim_compatible = {
        name = "Ollama",
        api_key = "TERM", -- ollama needs no key; minuet only requires a non-empty env var
        end_point = "http://localhost:11434/v1/completions",
        model = vim.env.OLLAMA_CODE_MODEL or vim.g.ollama_code_model or "qwen2.5-coder:3b-base",
        stream = true,
        optional = { max_tokens = 96, top_p = 0.9 },
      },
    },
  },
  claude = {
    provider = "claude",
    context_window = 12000,
    request_timeout = 3,
    provider_options = {
      claude = {
        model = vim.env.MINUET_CLAUDE_MODEL or "claude-haiku-4-5",
        max_tokens = 256,
        stream = true,
        api_key = "ANTHROPIC_API_KEY",
      },
    },
  },
}

return {
  {
    "milanglacier/minuet-ai.nvim",
    event = "InsertEnter",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = vim.tbl_deep_extend("force", {
      n_completions = 1,
      throttle = 1000,
      debounce = 400,
      notify = "warn",
      virtualtext = {
        auto_trigger_ft = { "*" },
        auto_trigger_ignore_ft = { "snacks_picker_input", "snacks_input", "dbui", "gitcommit" },
        keymap = {
          accept_line = "<M-l>",
          accept_word = "<M-w>",
          next = "<M-]>",
          prev = "<M-[>",
          dismiss = "<M-e>",
        },
      },
    }, provider_opts[provider]),
    config = function(_, opts)
      require("minuet").setup(opts)
      -- <Tab> accepts the suggestion (LazyVim's blink keymap calls ai_accept)
      LazyVim.cmp.actions.ai_accept = function()
        local vt = require("minuet.virtualtext").action
        if vt.is_visible() then
          LazyVim.create_undo()
          vt.accept()
          return true
        end
      end
    end,
    keys = {
      { "<leader>at", "<cmd>Minuet virtualtext toggle<cr>", desc = "Toggle AI autocomplete" },
    },
  },
}
