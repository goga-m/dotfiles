-- LazyVim markdown overrides: calm, Obsidian-like rendering.
--
-- THEME-CHANGE PLAYBOOK (all facts verified against the installed stack:
-- Neovim 0.12.2 + lazy.nvim 11.17.5 + current render-markdown).
--
-- 1. HIGHLIGHT WINS/LOSES
--    * The loud colors are the theme's tree-sitter captures
--      (@markup.heading.N, @markup.raw, @markup.link...). Override with
--      nvim_set_hl(0, ...) -- never `default = true` (that means "don't
--      override" and the theme always wins).
--    * Re-apply on ColorScheme (CalmMarkdown augroup in the render-markdown
--      config). Ordering is safe without priority: the theme paints
--      synchronously during :colorscheme, then the event fires and our
--      handler -- registered after render-markdown's own -- runs last.
--      NOTE: nvim_create_autocmd in 0.12 has NO `priority` key; passing it
--      is a hard error.
--
-- 2. THE TWO-PARSER TRAP (cost the most time)
--    Markdown uses TWO tree-sitter parsers and highlight groups are
--    namespaced by the parser's language:
--      * `markdown` (block parser): headings, quotes, lists, tables --
--        groups end in `.markdown`.
--      * `markdown_inline` (inline parser): **bold** (@markup.strong),
--        *italic*, `code` (@markup.raw), links, strikethrough -- groups
--        end in `.markdown_inline`.
--    Overriding only `.markdown` names leaves bold/italic/inline-code at
--    the theme's colors. apply_calm_palette mirrors into BOTH. Corollary:
--    italic inside a blockquote is painted by the INLINE capture, so
--    @markup.italic.markdown_inline is set to QUOTE_COLOR -- otherwise
--    italic quotes stay body-bright no matter what @markup.quote says.
--
-- 3. RENDER-MARKDOWN PAINTS VIRTUAL TEXT OVER YOUR CAPTURES
--    Pipe tables: even with border_enabled = false, the vertical pipes and
--    the delimiter row are virtual-text overlays -- buffer-level
--    highlights (@punctuation.special etc.) are COVERED and invisible.
--    The only lever is the two groups the overlay uses (pipe_table.head /
--    .row in settings.lua):
--      RenderMarkdownTableHead = delimiter row + header pipes + top line
--      RenderMarkdownTableRow  = body pipes + bottom line
--    This version has NO RenderMarkdownPipe group. Cell text keeps its own
--    tree-sitter highlight, so dimming those two groups dims only the
--    grid. (Header cells are bare @markup.heading -- pinned to fg bold.)
--
-- 4. BODY TEXT HAS NO CAPTURE AT ALL
--    Plain paragraphs ARE `Normal`. There is no per-buffer highlight; the
--    mechanism is window-local 'winhighlight' (Normal:DimNormal), set by
--    dim_markdown_window on FileType + BufWinEnter (it does not follow the
--    buffer into new splits by itself).
--
-- 5. SPEC-LEVEL `autocmds` ARE DEAD
--    The installed lazy.nvim (11.x) does NOT register the `autocmds = {}`
--    spec field -- silently ignored (grep the codebase: nothing consumes
--    it). ALL autocmds here are registered directly with
--    vim.api.nvim_create_autocmd inside the render-markdown config (runs
--    at startup because lazy = false). Do not move them back to spec form.
--
-- 6. TERMINAL LIMITS (asked and answered)
--    * No per-highlight font size anywhere (even GUIs) -- heading "size"
--      is faked with bands + color steps (see hierarchy below).
--    * No rounded corners on highlight backgrounds -- cells are
--      rectangles. Fenced blocks can fake round corners with glyph
--      borders (code.border = 'round'); inline code cannot.
--
-- TUNING KNOBS (just below): BODY_DIM / QUOTE_DIM = fade depth toward bg;
-- TINT = share of ACCENT blue mixed into dimmed text (0 = plain gray,
-- 0.25 = whisper, 0.4+ = obviously blue). Current balance was signed off
-- on screenshot: cool-gray page, saturated blue only on headings/links,
-- quotes fainter than body, table grid faintest.
--
-- Heading hierarchy (fake "size" with bands + color steps):
--   h1: blue, full-width band WITH border  -> reads as a big block
--   h2: blue, full-width band, lighter tint
--   h3: purple text, no band
--   h4: faded purple text
--   h5/h6: plain bold / gray bold
-- Links are the only other colored thing (accent blue, underlined).

local ACCENT = 0x7aa2f7 -- calm blue: h1/h2 + links
local ACCENT2 = 0xbb9af7 -- soft purple: h3/h4
local BODY_DIM = 0.35 -- fade markdown body text toward bg (0 = off, 0.5 = strong)
local QUOTE_DIM = 0.62 -- quote fade (higher = fainter than body)
local TINT = 0.25 -- whisper of ACCENT blue in dimmed text (0 = plain gray)

-- Final tinted colors, computed by apply_calm_palette (shared with the
-- window-local body dim).
local BODY_COLOR, QUOTE_COLOR

-- Blend two 0xRRGGBB colors: t=0 -> c1, t=1 -> c2
local function blend(c1, c2, t)
  local function ch(shift)
    local a = bit.band(bit.rshift(c1, shift), 0xff)
    local b = bit.band(bit.rshift(c2, shift), 0xff)
    return bit.lshift(math.floor(a + (b - a) * t + 0.5), shift)
  end
  return ch(16) + ch(8) + ch(0)
end

local function apply_calm_palette()
  local normal = vim.api.nvim_get_hl(0, { name = 'Normal', link = false })
  local fg = normal.fg or 0xc0caf5
  local bg = normal.bg or 0x1a1b26
  local gray = blend(fg, bg, 0.45)
  -- Color harmony: body and quotes share the heading-blue undertone; quotes
  -- fade further (QUOTE_DIM) than body (BODY_DIM + 0.2).
  -- BODY_COLOR is module-level so dim_markdown_window stays in sync.
  BODY_COLOR = blend(blend(fg, bg, BODY_DIM + 0.2), ACCENT, TINT)
  QUOTE_COLOR = blend(blend(fg, bg, QUOTE_DIM), ACCENT, TINT)
  -- Inline-code background: same blue-tinted family, just lifted off the bg.
  local code_bg = blend(bg, BODY_COLOR, 0.12)

  -- NOTE: no `default = true` anywhere -- we WANT to override the theme.
  local set = function(name, opts)
    vim.api.nvim_set_hl(0, name, opts)
  end

  -- Headings: two accents fading down the levels.
  -- H#Bg is the full-width band; H# is the text (and border prefix).
  local heading_fg = {
    ACCENT, -- h1
    blend(ACCENT, fg, 0.30), -- h2
    ACCENT2, -- h3
    blend(ACCENT2, fg, 0.45), -- h4
    blend(fg, bg, 0.15), -- h5
    gray, -- h6
  }
  local heading_bg = {
    blend(bg, ACCENT, 0.16), -- h1: visible band
    blend(bg, ACCENT, 0.08), -- h2: subtle band
    'NONE', -- h3
    'NONE', -- h4
    'NONE', -- h5
    'NONE', -- h6
  }
  for i = 1, 6 do
    set('RenderMarkdownH' .. i, { fg = heading_fg[i], bold = true })
    set('RenderMarkdownH' .. i .. 'Bg', { bg = heading_bg[i] })
    -- Keep the raw (insert-mode) source consistent with the rendered view.
    set('@markup.heading.' .. i .. '.markdown', { fg = heading_fg[i], bold = true })
  end
  set('@markup.title.markdown', { fg = ACCENT, bold = true })

  -- Emphasis: weight/style only, no color change.
  -- IMPORTANT: inline content is parsed by a SECOND parser (`markdown_inline`),
  -- so the groups that actually paint bold/italic/inline-code are namespaced
  -- `.markdown_inline`, NOT `.markdown`. The theme's loud orange lives there
  -- (@markup.strong.markdown_inline etc.) -- overriding only the `.markdown`
  -- names does nothing for inline text. Mirror the palette into both.
  local emphasis = {
    bold = { fg = fg, bold = true },
    -- Italic uses QUOTE_COLOR: italic spans inside quotes are painted by the
    -- inline parser and would otherwise stay body-bright over the dimmer quote.
    italic = { fg = QUOTE_COLOR, italic = true },
    strike = { fg = gray, strikethrough = true },
    raw = { fg = BODY_COLOR, bg = code_bg },
  }
  for _, ns in ipairs({ 'markdown', 'markdown_inline' }) do
    set('@markup.bold.' .. ns, emphasis.bold)
    set('@markup.strong.' .. ns, emphasis.bold)
    set('@markup.italic.' .. ns, emphasis.italic)
    set('@markup.strikethrough.' .. ns, emphasis.strike)
    set('@markup.raw.' .. ns, emphasis.raw)
    set('@markup.raw.inline.' .. ns, emphasis.raw)
  end
  set('@markup.raw.block.markdown', { bg = code_bg })
  set('RenderMarkdownCode', { bg = code_bg })
  set('RenderMarkdownCodeInline', { fg = BODY_COLOR, bg = code_bg })
  set('RenderMarkdownBold', emphasis.bold)
  set('RenderMarkdownItalic', emphasis.italic)
  set('RenderMarkdownBoldItalic', { fg = fg, bold = true, italic = true })

  -- Inline links also come from the markdown_inline parser -- keep them our
  -- accent blue so they match the headings.
  set('@markup.link.markdown_inline', { fg = ACCENT, underline = true })
  set('@markup.link.label.markdown_inline', { fg = ACCENT })
  set('@markup.link.url.markdown_inline', { fg = gray })

  -- Links: the only other colored thing on the page.
  set('@markup.link.markdown', { fg = ACCENT, underline = true })
  set('@markup.link.label.markdown', { fg = ACCENT })
  set('@markup.link.url.markdown', { fg = gray })
  set('RenderMarkdownLink', { fg = ACCENT, underline = true })
  set('RenderMarkdownLinkTitle', { fg = ACCENT })

  -- Quotes: lighter tint than body (see swap above); bar matches quote text.
  set('@markup.quote.markdown', { fg = QUOTE_COLOR, italic = true })
  for i = 1, 6 do
    set('RenderMarkdownQuote' .. i, { fg = QUOTE_COLOR })
  end

  -- Table grid lines: in this version of render-markdown the `│` pipes and the
  -- `───` delimiter row are VIRTUAL TEXT painted with the pipe_table `head`
  -- and `row` highlight groups (head = delimiter row + header pipes + top
  -- line; row = body pipes + bottom line). They cover the buffer, so
  -- @punctuation.special alone never shows through. Cell text keeps its own
  -- tree-sitter highlight, so dimming these two groups dims only the grid.
  local table_line = blend(blend(fg, bg, 0.70), ACCENT, TINT)
  set('RenderMarkdownTableHead', { fg = table_line })
  set('RenderMarkdownTableRow', { fg = table_line })
  -- Raw-source fallback (insert mode / unrendered tables).
  set('@punctuation.special.markdown', { fg = table_line })
  -- Header cells are captured as bare @markup.heading (no .N level) -- pin
  -- them to our palette so the theme's heading color can't leak through.
  set('@markup.heading.markdown', { fg = fg, bold = true })

  -- List / rule chrome: gray, never loud.
  set('@markup.list.markdown', { fg = gray })
  set('RenderMarkdownBullet', { fg = gray })
  set('RenderMarkdownRule', { fg = gray })

  -- Spellcheck safety net: the red "shader / rasterizes / DPR" undercurls are
  -- spellcheck (@spell -> SpellBad). We disable spell in markdown buffers (see
  -- autocmds), but if it's ever toggled on, make it a subtle gray undercurl
  -- instead of neon red.
  set('SpellBad', { fg = 'NONE', sp = gray, undercurl = true })
  set('SpellCap', { fg = 'NONE', sp = gray, undercurl = true })
  set('SpellLocal', { fg = 'NONE', sp = gray, undercurl = true })
  set('SpellRare', { fg = 'NONE', sp = gray, undercurl = true })
end

-- Dim paragraph body text in markdown windows only.
-- Plain paragraph text has NO tree-sitter capture at all -- it IS `Normal` -- so
-- capture-based dimming (@markup.normal.markdown etc.) does nothing. There is
-- also no nvim_win_set_hl in this API. The correct mechanism is the
-- window-local 'winhighlight' option: define DimNormal and remap Normal to it
-- on markdown windows only. Headings/bold/code keep their own highlights, so
-- the document stays scannable: dim body, bright structure.
local function dim_markdown_window(win)
  local normal = vim.api.nvim_get_hl(0, { name = 'Normal', link = false })
  local fg = normal.fg or 0xc0caf5
  local bg = normal.bg or 0x1a1b26
  local dim = BODY_COLOR or fg
  vim.api.nvim_set_hl(0, 'DimNormal', { fg = dim, bg = bg })
  vim.wo[win or 0].winhighlight = 'Normal:DimNormal'
end

return {
  -- Disable markdown lint warnings (the annoying diagnostics)
  {
    'mfussenegger/nvim-lint',
    opts = {
      linters_by_ft = {
        markdown = {}, -- override to remove markdownlint-cli2
      },
    },
  },

  -- Also disable via conform if it's installed
  {
    'stevearc/conform.nvim',
    optional = true,
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft.markdown = { 'prettier' }
    end,
  },

  -- Keep marksman LSP for completion but silence its semantic-token colors
  -- (marksman re-highlights headings/links on top of everything else).
  -- NOTE: the LspAttach handler lives in the render-markdown config below --
  -- the installed lazy.nvim (v11.x) does NOT register spec-level `autocmds`
  -- (verified: no code path consumes that field), so they were silently
  -- ignored and the body dim never applied. Register everything directly.
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        marksman = {},
      },
    },
  },

  -- render-markdown.nvim -- only schema-valid keys for the installed version.
  {
    'MeanderingProgrammer/render-markdown.nvim',
    lazy = false,
    order = 1,
    opts = {
      -- Keep the cursor line rendered like everything else.
      anti_conceal = { enabled = false },

      -- NOTE: no top-level `render_modes` in this version. Default behavior is
      -- exactly what we want: normal mode = rendered, insert mode = raw source.
      -- (Per-element `render_modes` would ADD modes; we want none of that.)

      code = {
        sign = false, -- no gutter signs
        language = false, -- no language label above blocks
        border = 'none', -- no box around code
        width = 'block', -- subtle bg fills the block width (Obsidian-like)
        left_pad = 1,
        right_pad = 1,
      },

      heading = {
        sign = false, -- no icons next to headings
        -- h1 gets a bordered band (our fake "larger font"); h2 a plain tinted
        -- band; h3-h6 are text-only. Virtual lines so content doesn't shift.
        border = { true, false, false, false, false, false },
        border_virtual = true,
        width = 'full',
      },

      -- NOTE: the key is `pipe_table`, not `table`.
      pipe_table = {
        border_enabled = false, -- no box borders
        head = 'RenderMarkdownTableHead',
        row = 'RenderMarkdownTableRow',
        alignment_indicator = 'none',
      },

      -- Obsidian shows small gray bullets; the palette grays them out.
      bullet = {
        enabled = true,
      },

      quote = {
        icon = '▎', -- thin bar instead of the chunky default
      },

      checkbox = {
        enabled = false, -- keep them off as before
      },
    },
    config = function(_, opts)
      require('render-markdown').setup(opts)
      apply_calm_palette()

      -- Register autocmds DIRECTLY: spec-level `autocmds` tables are ignored
      -- by the installed lazy.nvim, which is why the body dim (DimNormal via
      -- winhighlight) never ran and paragraph text stayed full-white.
      local group = vim.api.nvim_create_augroup('CalmMarkdown', { clear = true })

      -- Re-apply after every colorscheme change. Ordering is safe without a
      -- priority (0.12's keyset has none): the theme sets its highlights
      -- synchronously during :colorscheme, then ColorScheme fires -- and our
      -- autocmd is registered after render-markdown's own, so we run last.
      vim.api.nvim_create_autocmd('ColorScheme', {
        group = group,
        callback = function()
          apply_calm_palette()
          if vim.bo.buftype == '' and vim.bo.filetype == 'markdown' then
            dim_markdown_window(0)
          end
        end,
      })

      -- Dim markdown body text: on file open and when a buffer enters a new
      -- window (winhighlight is window-local and doesn't follow the buffer).
      vim.api.nvim_create_autocmd({ 'FileType', 'BufWinEnter' }, {
        group = group,
        callback = function(ev)
          if vim.bo[ev.buf].filetype ~= 'markdown' then
            return
          end
          -- No spellcheck noise in markdown (SpellBad is softened anyway).
          vim.wo[0].spell = false
          dim_markdown_window(0)
        end,
      })

      -- Silence marksman's semantic-token re-highlighting.
      vim.api.nvim_create_autocmd('LspAttach', {
        group = group,
        callback = function(ev)
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if client and client.name == 'marksman' then
            client.server_capabilities.semanticTokensProvider = nil
          end
        end,
      })
    end,
  },
}
