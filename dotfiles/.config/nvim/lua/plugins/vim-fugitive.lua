return {
  {
    "tpope/vim-fugitive",
    config = function()
      -- Function to get the list of git branches
      local function get_git_branches()
        local branches = {}
        local handle = io.popen('git branch --format="%(refname:short)" 2>/dev/null')
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

      function _G.GvdiffInBranch()
        local branch_name = vim.fn.input("Enter branch name to show diff: ", "", "customlist,v:lua.complete_branches")
        if branch_name == "" then
          return
        end
        local file_path = vim.fn.expand("%:p")
        local command = string.format(":Gvdiffsplit %s:%s", branch_name, file_path)
        vim.cmd(command)
      end

      function _G.GeditInBranch()
        local branch_name = vim.fn.input("Enter branch name to view file: ", "", "customlist,v:lua.complete_branches")
        if branch_name == "" then
          return
        end
        local file_path = vim.fn.expand("%:p")
        local command = string.format("belowright split | Gedit %s:%s", branch_name, file_path)
        vim.cmd(command)
      end

      -- Set keybindings
      vim.keymap.set("n", "gv", ":lua GvdiffInBranch()<CR>", { noremap = true, silent = true })
      vim.keymap.set("n", "ge", ":lua GeditInBranch()<CR>", { noremap = true, silent = true })
    end,
  },
}
