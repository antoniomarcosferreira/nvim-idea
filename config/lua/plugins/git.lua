-- Git tooling on top of LazyVim defaults (gitsigns, lazygit, snacks git pickers)
--   diffview.nvim     -> IDE-like diff/compare, file history, 3-way merge tool
--   git-conflict.nvim -> resolve conflict markers inline (ours/theirs/both)
--   vim-fugitive      -> :Git, :Gvdiffsplit!, :Git blame, etc.

local function compare_with()
  vim.ui.input({ prompt = "Compare with (branch/tag/commit/range): ", default = "origin/main" }, function(rev)
    if rev and rev ~= "" then
      vim.cmd("DiffviewOpen " .. rev)
    end
  end)
end

return {
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory", "DiffviewToggleFiles", "DiffviewRefresh" },
    keys = {
      { "<leader>gv", "", desc = "+diffview" },
      { "<leader>gvo", "<cmd>DiffviewOpen<cr>", desc = "Open (working tree vs index)" },
      { "<leader>gvc", "<cmd>DiffviewClose<cr>", desc = "Close" },
      { "<leader>gvm", "<cmd>DiffviewOpen<cr>", desc = "Merge tool (during conflicts)" },
      { "<leader>gvb", compare_with, desc = "Compare with branch/commit" },
      { "<leader>gvf", "<cmd>DiffviewFileHistory %<cr>", desc = "Current file history" },
      { "<leader>gvF", "<cmd>DiffviewFileHistory<cr>", desc = "Repo history" },
      { "<leader>gvf", ":DiffviewFileHistory<cr>", mode = "x", desc = "Selection history" },
      { "<leader>gvs", "<cmd>DiffviewOpen --staged<cr>", desc = "Staged changes" },
    },
    opts = {
      enhanced_diff_hl = true,
      view = {
        merge_tool = { layout = "diff3_mixed", disable_diagnostics = true },
      },
      hooks = {
        diff_buf_read = function()
          vim.opt_local.wrap = false
        end,
      },
    },
  },

  {
    "akinsho/git-conflict.nvim",
    version = "*",
    event = "BufReadPre",
    opts = {
      -- buffer-local: co (ours), ct (theirs), cb (both), c0 (none), ]x / [x (next/prev)
      default_mappings = true,
      disable_diagnostics = true,
    },
    keys = {
      { "<leader>gx", "", desc = "+conflicts" },
      { "<leader>gxl", "<cmd>GitConflictListQf<cr>", desc = "List conflicts (quickfix)" },
      { "<leader>gxo", "<cmd>GitConflictChooseOurs<cr>", desc = "Choose ours" },
      { "<leader>gxt", "<cmd>GitConflictChooseTheirs<cr>", desc = "Choose theirs" },
      { "<leader>gxb", "<cmd>GitConflictChooseBoth<cr>", desc = "Choose both" },
      { "<leader>gxn", "<cmd>GitConflictChooseNone<cr>", desc = "Choose none" },
      { "<leader>gxr", "<cmd>GitConflictRefresh<cr>", desc = "Refresh" },
    },
  },

  {
    "tpope/vim-fugitive",
    cmd = { "Git", "G", "Gdiffsplit", "Gvdiffsplit", "Gread", "Gwrite", "Gedit", "GBrowse" },
    keys = {
      { "<leader>gF", "<cmd>Git<cr>", desc = "Fugitive status" },
      { "<leader>gA", "<cmd>Git blame<cr>", desc = "Blame (full file)" },
      { "<leader>g3", "<cmd>Gvdiffsplit!<cr>", desc = "3-way merge split (fugitive)" },
    },
  },

  {
    "lewis6991/gitsigns.nvim",
    opts = {
      current_line_blame = true,
      current_line_blame_opts = { delay = 600 },
    },
  },
}
