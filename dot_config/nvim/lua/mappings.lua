require "nvchad.mappings"
require "configs.nvim-tree"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- Custom
-- Escape with jj
map("i", "jj", "<Esc>", { noremap = true, silent = true })

-- Resize panes using control + arrow keys
map("n", "<C-Left>", "<C-w><", { noremap = true, silent = true })
map("n", "<C-Right>", "<C-w>>", { noremap = true, silent = true })
map("n", "<C-Up>", "<C-w>-", { noremap = true, silent = true })
map("n", "<C-Down>", "<C-w>+", { noremap = true, silent = true })

-- fzf-lua
-- Search files & grep
map({ "n" }, "<C-p>", function()
  require("fzf-lua").files()
end, { silent = true })

-- Open last grep
map({ "n" }, "<C-;>", function()
  require("fzf-lua").grep_last()
end, { silent = true })

-- Use grep_native as it's more performant than live_grep
map("n", "<C-\\>", ':lua require"fzf-lua".live_grep_native()<CR><C-g>')

-- Search files & grep
map({ "n" }, "<C-p>", function()
  require("fzf-lua").files()
end, { silent = true })

-- Search word under cursor
map({ "n" }, "<C-.>", function()
  require("fzf-lua").grep_cword()
end, { silent = true })

-- Search visual selection
map({ "v" }, "<C-.>", function()
  require("fzf-lua").grep_visual()
end, { silent = true })

-- Find path on insert mode.
map({ "i" }, "<C-.>", function()
  require("fzf-lua").complete_path()
end, { silent = true })

-- Don't jump to the next occurence when selecting with *
map("n", "*", "*``", { noremap = true, silent = true })

-- Go to definition in a new split with gdd.
map("n", "gdd", "<C-w>]", { noremap = true, silent = true })

-- Gilinker mappings.
map(
  "n",
  "<leader>gy",
  '<cmd>lua require"gitlinker".get_buf_range_url("n", {action_callback = require"gitlinker.actions".open_in_browser})<cr>',
  { silent = true }
)

-- Gen
-- map({ "n", "v" }, "<leader>gg", ":Gen<CR>")
-- map("v", "<leader>]", ":Gen Enhance_Grammar_Spelling<CR>")
-- map({ "n", "v" }, "<leader>gg", ":Gen<CR>")
-- map("v", "<leader>]", ":Gen Enhance_Grammar_Spelling<CR>")

-- Copy current filepath in clipboard.
map("n", "<leader>cf", ':let @+=expand("%:p")<CR>', { noremap = true, silent = true, desc = "Copy file path" })

-- Custom git mappings
require "configs.git-mappings"

map("n", "<C-Left>", ":TmuxResizeLeft<CR>", { noremap = true, silent = true })
map("n", "<C-Down>", ":TmuxResizeDown<CR>", { noremap = true, silent = true })
map("n", "<C-Up>", ":TmuxResizeUp<CR>", { noremap = true, silent = true })
map("n", "<C-Right>", ":TmuxResizeRight<CR>", { noremap = true, silent = true })

-- Dismiss noice messages
map("n", "<leader>mm", ":NoiceDismiss<CR>", { noremap = true, silent = true })

-- Terminal mappings
-- https://nvchad.com/docs/config/nvchad_ui/#term
-- map({ "n", "t" }, "<space>t", function()
--   local file_path = vim.fn.expand "%:p"
--   local cmd = "pnpm test " .. file_path
--
--   require("nvchad.term").runner {
--     pos = "vsp",
--     cmd = cmd,
--     id = "test",
--     clear_cmd = false,
--   }
-- end, { desc = "Terminal Toggle Floating term" })

-- TODO: Persist yanked text for multiple paste support
