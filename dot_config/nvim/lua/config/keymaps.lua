-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = LazyVim.safe_keymap_set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jj", "<ESC>")
map("x", "p", "pgvy", { noremap = true, silent = true, desc = "Paste and reselect pasted text" })

-- Half page navigation with ctrl-k/j
map("n", "<C-S-j>", "<C-d>")
map("n", "<C-S-k>", "<C-u>")

-- Copy current filepath.
map("n", "y<C-g>", '"+:let @+=expand("%:p")<CR>', { desc = "Copy file path" })

-- Delete current buffer.
map("n", "<leader>q", "<cmd>bdelete<cr>", { desc = "Delete buffer" })

-- Keep cursor in place when you press * to search word under cursor
map(
  "n", -- mode: normal
  "*", -- lhs
  ":keepjumps normal! mi*`i<CR>", -- rhs
  { noremap = true, silent = true }
)

-- Preserve yanked text, preventing it from being overridden by selections.
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    -- Store the yanked text in a variable that persists
    local yanked_text = vim.fn.getreg('"')
    vim.api.nvim_set_var("preserved_yank", yanked_text)
  end,
  group = vim.api.nvim_create_augroup("PreserveYank", { clear = true }),
})

map("n", "y", '"0y', { desc = "Yank to register 0" })
vim.keymap.set("v", "y", '"0y', { desc = "Yank to register 0" })
vim.keymap.set("n", "p", '"0p', { desc = "Paste from register 0" })
vim.keymap.set("v", "p", '"0p', { desc = "Paste from register 0" })
