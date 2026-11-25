-- Keymaps are automatically loaded on the VeryLazy event
-- LazyVim defaults: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
local map = vim.keymap.set

map("i", "jk", "<Esc>", { desc = "Exit insert mode" })

-- Diff the two visible windows (quick compare of any two buffers/files)
map("n", "<leader>gww", "<cmd>windo diffthis<cr>", { desc = "Diff visible windows" })
map("n", "<leader>gwo", "<cmd>diffoff!<cr>", { desc = "Diff off" })
pcall(function()
  require("which-key").add({ { "<leader>gw", group = "window diff" } })
end)
