local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")
map("i", "jj", "<ESC>")

-- Dismiss noice messages
map("n", "<leader>mm", ":NoiceDismiss<CR>", { noremap = true, silent = true })
