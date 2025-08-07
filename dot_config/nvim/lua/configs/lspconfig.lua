-- load defaults i.e lua_lsp
require("nvchad.configs.lspconfig").defaults()

local lspconfig = require "lspconfig"

-- EXAMPLE
local servers = { "html", "cssls", "ts_ls", "eslint", "pyright" }
local nvlsp = require "nvchad.configs.lspconfig"

local function set_diagnostic_virtual_text_colors()
  -- Set background to none for all diagnostic virtual text types
  -- vim.api.nvim_set_hl(0, "DiagnosticVirtualTextError", { bg = "none", fg = "#444444" }) -- Example: light grey for errors
  vim.api.nvim_set_hl(0, "DiagnosticVirtualTextWarn", { bg = "none", fg = "#44475a" }) -- Example: light grey for warnings
  vim.api.nvim_set_hl(0, "DiagnosticVirtualTextInfo", { bg = "none", fg = "#44475a" }) -- Example: light grey for info
  vim.api.nvim_set_hl(0, "DiagnosticVirtualTextHint", { bg = "none", fg = "#44475a" }) -- Example: light grey for hints

  -- You can also experiment with different foreground colors for each severity
  -- For example, a slightly different shade of grey, or a very desaturated version of the default diagnostic color.
  -- Example:
  -- vim.api.nvim_set_hl(0, "DiagnosticVirtualTextError", { bg = "none", fg = "#EE6666", blend = 0.8 }) -- Faded red
  -- vim.api.nvim_set_hl(0, "DiagnosticVirtualTextWarn", { bg = "none", fg = "#EEEE66", blend = 0.8 })  -- Faded yellow
end

-- lsps with default config
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = nvlsp.on_attach,
    on_init = nvlsp.on_init,
    capabilities = nvlsp.capabilities,
  }
end

-- Disable underlining the whole line on diagnostic errors & warnings
vim.diagnostic.config {
  underline = false,
  -- virtual_text = false,
}

-- vim.keymap.set("n", "<leader>do", vim.diagnostic.open_float)
-- vim.api.nvim_create_autocmd("CursorHold", {
--   pattern = "*",
--   callback = function()
--     vim.diagnostic.open_float { focusable = true }
--   end,
-- })

local function open_focusable_diagnostic_float()
  vim.diagnostic.open_float { focusable = true }
end

-- Create the keymap for <leader>do
vim.keymap.set("n", "<leader>do", open_focusable_diagnostic_float, {
  desc = "Open focusable diagnostic float on current line",
})

set_diagnostic_virtual_text_colors()
