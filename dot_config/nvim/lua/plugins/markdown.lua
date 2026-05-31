-- Override LazyVim markdown extras for a cleaner experience
return {
  -- Disable markdown lint warnings (the annoying diagnostics)
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        markdown = {}, -- override to remove markdownlint-cli2
      },
    },
  },

  -- Also disable via conform if it's installed
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft.markdown = { "prettier" } -- remove markdownlint-cli2 and markdown-toc
    end,
  },

  -- Keep marksman LSP for completion but silence its diagnostics
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        marksman = {},
      },
    },
  },

  -- Cleaner render-markdown.nvim: minimal, no borders, no icons
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      code = {
        sign = false,          -- no gutter signs
        width = "none",        -- no surrounding block borders
        right_pad = 0,         -- no extra padding
        background = false,    -- no highlight background
        italic = true,         -- keep italic for emphasis
        bold = true,           -- keep bold
      },
      heading = {
        sign = false,          -- no icons next to headings
        styles = {
          -- Use subtle underline/bold instead of heavy borders
          [1] = "bold",
          [2] = "bold",
          [3] = "italic",
          [4] = "italic",
          [5] = "italic",
          [6] = "italic",
        },
      },
      link = {
        underline = true,      -- keep links underlined for discoverability
      },
      checkbox = {
        enabled = false,       -- no fancy checkboxes
      },
      bullet = {
        enabled = false,       -- no custom bullet rendering
      },
      table = {
        enabled = false,       -- no fancy table borders
        width = "none",
        left_pad = 0,
      },
    },
    ft = { "markdown", "norg", "rmd", "org", "codecompanion" },
  },
}
