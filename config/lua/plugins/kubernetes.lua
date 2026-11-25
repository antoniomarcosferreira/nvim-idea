-- Kubernetes: kubectl.nvim (k9s-like UI inside nvim), k9s in a floating terminal,
-- and Kubernetes JSON schema for manifests in common folders.
return {
  {
    "ramilito/kubectl.nvim",
    version = "2.*", -- release tags ship pre-built binaries
    dependencies = "saghen/blink.lib",
    cmd = { "Kubectl", "Kubectx", "Kubens" },
    keys = {
      { "<leader>k", "", desc = "+kubernetes" },
      {
        "<leader>kk",
        function()
          require("kubectl").toggle({ tab = true })
        end,
        desc = "kubectl.nvim",
      },
      {
        "<leader>k9",
        function()
          Snacks.terminal("k9s", { win = { style = "float", width = 0.95, height = 0.95 } })
        end,
        desc = "k9s (float)",
      },
    },
    config = function()
      require("kubectl").setup()
    end,
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        yamlls = {
          settings = {
            yaml = {
              schemas = {
                kubernetes = {
                  "k8s/**/*.yaml",
                  "k8s/**/*.yml",
                  "kubernetes/**/*.yaml",
                  "kubernetes/**/*.yml",
                  "manifests/**/*.yaml",
                  "manifests/**/*.yml",
                  "deploy/**/*.yaml",
                  "deploy/**/*.yml",
                  "*.k8s.yaml",
                  "*.k8s.yml",
                },
              },
            },
          },
        },
      },
    },
  },
}
