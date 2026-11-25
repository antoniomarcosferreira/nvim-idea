-- Autocmds are automatically loaded on the VeryLazy event
-- LazyVim defaults: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua

-- Reload buffers when files change on disk (Claude Code edits, git operations)
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "TermLeave" }, {
  group = vim.api.nvim_create_augroup("user_autoread", { clear = true }),
  callback = function()
    if vim.fn.mode() ~= "c" and vim.fn.getcmdwintype() == "" then
      vim.cmd("silent! checktime")
    end
  end,
})

-- Kubernetes/Helm-ish files: 2-space indent
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("user_yaml_indent", { clear = true }),
  pattern = { "yaml", "helm" },
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
  end,
})
