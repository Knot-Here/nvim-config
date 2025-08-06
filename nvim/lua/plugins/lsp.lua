return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        tsserver = {
          settings = {
            javascript = {
              suggest = {
                completeFunctionCalls = true,
              },
              format = {
                enable = false, -- Add this
              },
            },
            typescript = {
              format = {
                enable = false, -- Add this
              },
            },
          },
          on_attach = function(client, bufnr)
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
          end,
        },
      },
      -- Disable format on save globally
      format = {
        enabled = false,
      },
    },
  },
  -- Disable conform.nvim completely
  {
    "stevearc/conform.nvim",
    enabled = false, -- Nuclear option
  },
}
