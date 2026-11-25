-- Options are automatically loaded before lazy.nvim startup
-- LazyVim defaults: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
local opt = vim.opt

-- AI suggestions as inline ghost text (like IntelliJ/VS Code). Accept with <Tab>.
-- Set to true to show AI suggestions inside the completion menu instead.
vim.g.ai_cmp = false

opt.autoread = true -- reload files changed outside nvim (Claude Code, git checkout, etc.)
opt.scrolloff = 8
opt.wrap = false
opt.colorcolumn = "120"

-- Homebrew keg-only tools used inside nvim (mysql client for vim-dadbod)
for _, dir in ipairs({ "/opt/homebrew/opt/mysql-client/bin", "/usr/local/opt/mysql-client/bin" }) do
  if vim.uv.fs_stat(dir) and not vim.env.PATH:find(dir, 1, true) then
    vim.env.PATH = dir .. ":" .. vim.env.PATH
  end
end

-- Better diff/merge view
opt.diffopt:append({ "algorithm:histogram", "indent-heuristic", "linematch:60" })
opt.fillchars:append({ diff = "╱" })
