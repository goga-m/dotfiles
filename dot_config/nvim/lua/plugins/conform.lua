return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      javascript = { "prettier" }, -- Use "prettier" not "prettierd"
      typescript = { "prettier" },
      typescriptreact = { "prettier" },
      json = { "prettier" },
      -- ... other filetypes
    },
  },
}
