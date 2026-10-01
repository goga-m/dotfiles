-- Personal input overrides — Omarchy quattro twin of the host's input.conf.
-- Anything set here replaces the Omarchy default; see
-- https://wiki.hypr.land/Configuring/Basics/Variables/#input

hl.config({
  input = {
    -- English + Greek, switched with Alt + Shift.
    kb_layout = "us,gr",
    kb_options = "grp:alt_shift_toggle",

    -- Keyboard repeat.
    repeat_rate = 40,
    repeat_delay = 250,

    -- External mouse scroll speed.
    scroll_factor = 0.4,

    touchpad = {
      scroll_factor = 1,
    },
  },
})

-- Faster touchpad scrolling in terminals. The host matched Alacritty/kitty;
-- foot is added because it is the terminal Omarchy 4 ships (and the VM has).
o.window("(Alacritty|kitty|foot)", { scroll_touchpad = 1.5 })
o.window("com.mitchellh.ghostty", { scroll_touchpad = 0.2 })
