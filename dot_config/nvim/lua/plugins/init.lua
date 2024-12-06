return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    config = function()
      require "configs.conform"
    end,
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require("nvchad.configs.lspconfig").defaults()
      require "configs.lspconfig"
    end,
    version = "*",
    opts = {},
  },

  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "lua-language-server",
        "stylua",
        "html-lsp",
        "css-lsp",
        "prettier",
        "typescript-language-server",
        "eslint-lsp",
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim",
        "lua",
        "vimdoc",
        "html",
        "css",
        "tsx",
      },
    },
    filetypes = { "css", "pcss", "ini", "xml", "json" },
  },
  -- Custom plugins
  {
    "nvim-lua/plenary.nvim",
  },
  {
    "ruifm/gitlinker.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
  },
  {
    "heavenshell/vim-jsdoc",
    ft = { "javascript", "javascript.jsx", "typescript", "typescript.tsx" },
    build = "make install",
  },
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    opts = {},
  },
  -- {
  --   "rmagatti/auto-session",
  --   lazy = false, -- Required to load the plugin, otherwise, an event needs to be specified.
  --   opts = {}, -- Required to load the plugin.
  -- },
  {
    "David-Kunz/gen.nvim",
    lazy = false,
    config = function()
      require "configs.gen"
    end,
  },
  {
    "nvim-telescope/telescope-ui-select.nvim",
    lazy = false,
    config = function()
      require "configs.telescope-ui-select"
    end,
  },
  {
    "rbgrouleff/bclose.vim",
  },
  {
    "iberianpig/tig-explorer.vim",
    dependencies = { "rbgrouleff/bclose.vim" },
    lazy = false,
  },
  {
    "windwp/nvim-ts-autotag",
    lazy = false,
    opts = {},
  },
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      modes = {
        -- search = {
        --   enabled = true,
        --   highlight = { backdrop = true },
        -- },
      },
      label = {
        rainbow = {
          enabled = true,
          -- number between 1 and 9
          shade = 9,
        },
      },
    },
    -- stylua: ignore
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end,       desc = "Flash" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      -- { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      -- { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      -- { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
  },
  {
    "tpope/vim-fugitive",
    lazy = false,
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      lsp = {
        signature = {
          enabled = false,
        },
      },
      -- add any options here
    },
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      "MunifTanjim/nui.nvim",
      -- OPTIONAL:
      --   `nvim-notify` is only needed, if you want to use the notification view.
      --   If not available, we use `mini` as the fallback
      "rcarriga/nvim-notify",
    },
  },
  { "junegunn/fzf", build = "./install --bin" },
  {
    "ibhagwan/fzf-lua",
    -- optional for icon support
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("fzf-lua").setup {
        { "telescope" },
        winopts = { fullscreen = false },
        actions = {
          files = {
            -- Selection keybindings
            ["default"] = require("fzf-lua.actions").file_edit_or_qf,
            ["ctrl-h"] = require("fzf-lua.actions").file_split,
            ["ctrl-v"] = require("fzf-lua.actions").file_vsplit,
            ["ctrl-t"] = require("fzf-lua.actions").file_tabedit,
          },
        },
      }
    end,
  },
  -- Conflicts with ctrl-\\ for rg modal
  -- {
  --   "christoomey/vim-tmux-navigator",
  --   event = "VeryLazy",
  --   cmd = {
  --     "TmuxNavigateLeft",
  --     "TmuxNavigateDown",
  --     "TmuxNavigateUp",
  --     "TmuxNavigateRight",
  --     "TmuxNavigatePrevious",
  --   },
  --   keys = {
  --     { "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
  --     { "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
  --     { "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
  --     { "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
  --     -- { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
  --   },
  -- },
  {
    "RyanMillerC/better-vim-tmux-resizer",
    event = "VeryLazy",
  },
  {
    "luckasRanarison/tailwind-tools.nvim",
    event = "VeryLazy",
    name = "tailwind-tools",
    build = ":UpdateRemotePlugins",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-telescope/telescope.nvim", -- optional
      "neovim/nvim-lspconfig",         -- optional
    },
    opts = {},                         -- your configuration
  },
}
