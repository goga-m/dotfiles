local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")
map("i", "jj", "<ESC>")

-- Keep cursor in place when you press * to search word under cursor
map(
  "n", -- mode: normal
  "*", -- lhs
  ":keepjumps normal! mi*`i<CR>", -- rhs
  { noremap = true, silent = true }
)

-- Multiple copy-paste without changing the clipboard..
map("x", "p", "pgvy", { noremap = true, silent = true, desc = "Paste and reselect pasted text" })

map("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
