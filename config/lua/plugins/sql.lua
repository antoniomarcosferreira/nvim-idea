-- SQL / MySQL: vim-dadbod-ui comes from the lang.sql extra (<leader>D toggles it).
-- Here: MySQL dialect for sqlfluff (lint + format) and a saved-connections location.
-- Add connections in the UI (A) or via env, e.g.:
--   export DB_UI_DEV="mysql://user:pass@localhost:3306/mydb"
local dialect = vim.env.SQLFLUFF_DIALECT or "mysql"

return {
  {
    "kristijanhusak/vim-dadbod-ui",
    optional = true,
    init = function()
      vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/db_ui"
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_show_database_icon = 1
      vim.g.db_ui_execute_on_save = false
    end,
  },
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = function(_, opts)
      opts.formatters = opts.formatters or {}
      opts.formatters.sqlfluff = { args = { "format", "--dialect=" .. dialect, "-" } }
    end,
  },
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = function(_, opts)
      opts.linters = opts.linters or {}
      opts.linters.sqlfluff = {
        args = { "lint", "--format=json", "--dialect=" .. dialect },
      }
    end,
  },
}
