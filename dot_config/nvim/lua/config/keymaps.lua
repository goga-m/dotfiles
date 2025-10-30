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
