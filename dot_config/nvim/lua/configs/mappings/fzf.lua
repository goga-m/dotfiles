-- fzf-lua
-- Search files & grep

vim.keymap.set({ "n" }, "<C-p>", function()
  require("fzf-lua").files()
end, { silent = true })

-- Open last grep
vim.keymap.set({ "n" }, "<C-;>", function()
  require("fzf-lua").grep_last()
end, { silent = true })

-- Use grep_native as it's more performant than live_grep
vim.keymap.set("n", "<C-\\>", ':lua require"fzf-lua".live_grep_native()<CR><C-g>')
