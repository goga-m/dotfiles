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

-- copy the word under the cursor and search fzf live grep with the yanked text.
vim.keymap.set("n", "**", function()
  -- Yank the word under cursor
  vim.cmd("normal! yiw")
  local search_term = vim.fn.getreg('"')

  -- Use fzf-lua's live_grep_native with the pre-filled search term
  require("fzf-lua").live_grep_native({ search = search_term })
end, { silent = true })
