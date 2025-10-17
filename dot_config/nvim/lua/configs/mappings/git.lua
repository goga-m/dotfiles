-- Function to get the list of git branches
local function get_git_branches()
  local branches = {}
  local handle = io.popen('git branch --format="%(refname:short)"')
  if handle then
    for branch in handle:lines() do
      table.insert(branches, branch)
    end
    handle:close()
  end
  return branches
end

-- Set the global function for branch completion
_G.complete_branches = function(arg_lead, _, _)
  local branches = get_git_branches()
  local matches = {}
  for _, branch in ipairs(branches) do
    if branch:match("^" .. arg_lead) then
      table.insert(matches, branch)
    end
  end
  return matches
end

function GvdiffInBranch()
  local branch_name = vim.fn.input("Enter branch name to show diff: ", "", "customlist,v:lua.complete_branches")
  local file_path = vim.fn.expand("%:p")
  local command = string.format(":Gvdiffsplit %s:%s", branch_name, file_path)
  vim.cmd(command)
end

function GeditInBranch()
  local branch_name = vim.fn.input("Enter branch name to view file: ", "", "customlist,v:lua.complete_branches")
  local file_path = vim.fn.expand("%:p")
  local command = string.format("belowright split | Gedit %s:%s", branch_name, file_path)
  vim.cmd(command)
end

vim.api.nvim_set_keymap("n", "gv", ":lua GvdiffInBranch()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "ge", ":lua GeditInBranch()<CR>", { noremap = true, silent = true })

vim.api.nvim_set_keymap("n", "ggr", ":diffget RE<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "ggl", ":diffget LO<CR>", { noremap = true, silent = true })
