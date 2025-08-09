return {
  "williamboman/mason.nvim",
  url = "https://github.com/williamboman/mason.nvim.git",

  opts = {
    ensure_installed = {
      -- LSPs
      "lua-language-server",
      "typescript-language-server", 
      "pyright",
      "json-lsp",
      "yaml-language-server",
      "bash-language-server",
      
      -- Formatters
      "stylua",
      "prettier",
      "black",
      
      -- Linters
      "eslint_d",
      "flake8",
      "shellcheck",
    },
  },
}
