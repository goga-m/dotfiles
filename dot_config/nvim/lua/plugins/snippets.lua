return {
  {
    "L3MON4D3/LuaSnip",
    dependencies = {
      "rafamadriz/friendly-snippets",
    },
    opts = {
      history = true,
      update_events = "TextChanged,TextChangedI",
      enable_autosnippets = true,
      store_selection_keys = "<Tab>",
    },
    config = function(_, opts)
      local ls = require("luasnip")
      ls.config.set_config(opts)

      require("luasnip.loaders.from_vscode").lazy_load({
        paths = { vim.fn.stdpath("config") .. "/snippets" }
      })
    end,
  },

  {
    "chrisgrieser/nvim-scissors",
    dependencies = "nvim-telescope/telescope.nvim",
    opts = {
      snippetDir = vim.fn.stdpath("config") .. "/snippets",
    },
    keys = {
      { "<leader>se", function() require("scissors").editSnippet() end, desc = "Edit snippet" },
      { "<leader>sa", function() require("scissors").addNewSnippet() end, mode = { "n", "x" }, desc = "Add snippet" },
    },
  },
}
