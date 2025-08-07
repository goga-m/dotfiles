vim.keymap.set("n", "<leader>gl", function()
  local line = vim.fn.line "."
  vim.cmd("Glog -n 5 -L " .. line .. "," .. line .. " %")
end, { desc = "Git line history (Fugitive)" })
