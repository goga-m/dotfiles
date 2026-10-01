-- Personal keybindings — the Omarchy quattro (Lua) twin of the host's
-- Omarchy 3.x `~/.config/hypr/bindings.conf` + `tiling.conf`.
--
-- chezmoi applies the .conf set on Omarchy 3.x and this .lua set on quattro;
-- see .chezmoiignore. Change the pair that matches the machine you are on.
--
-- Two Lua rules the hyprlang .conf files did not have:
--   * A second bind on a key does NOT replace the first — both fire. Always
--     hl.unbind() before re-binding a key Omarchy already owns.
--   * hl.unbind() is case-sensitive and must match the exact string Omarchy
--     used ("SUPER + TAB", not "SUPER + Tab").
--
-- Check the live keymap:  omarchy menu keybindings --print
-- Validate after editing: hyprctl reload && hyprctl configerrors

-- Re-bind a key Omarchy owns, but only when the replacement is actually
-- installed on this machine. The quattro VM image does not ship every app the
-- host has; skipping keeps Omarchy's own default binding instead of leaving a
-- dead key. `binary` defaults to the first word of the command — pass it
-- explicitly when the command starts with a wrapper (uwsm-app, hyprctl, ...).
local function rebind(keys, description, command, binary)
  binary = binary or (type(command) == "string" and command:match("^%S+") or nil)
  if binary and o.cmd_missing(binary) then
    return
  end

  hl.unbind(keys)
  o.bind(keys, description, command)
end

-- ------------------------------------------------------------------ apps --

-- Terminal in the directory of the terminal that was focused. The host spelled
-- this `$TERMINAL --dir=$(omarchy-cmd-terminal-cwd)`; omarchy-launch-terminal
-- is quattro's equivalent of the same thing.
rebind("SUPER + RETURN", "Terminal", "omarchy-launch-terminal")
rebind("SUPER + ALT + RETURN", "Tmux", "omarchy-launch-terminal tmux new")

-- Chrome pinned as the browser, Wayland-native. Falls back to whatever
-- omarchy-launch-browser is if Chrome isn't installed here.
rebind("SUPER + SHIFT + B", "Browser",
  "uwsm-app -- google-chrome-stable --new-window --ozone-platform=wayland",
  "google-chrome-stable")
rebind("SUPER + SHIFT + ALT + B", "Browser (private)",
  "uwsm-app -- google-chrome-stable --new-window --ozone-platform=wayland --private",
  "google-chrome-stable")

-- Pinned to keep these keys stable across future Omarchy default changes.
rebind("SUPER + SHIFT + RETURN", "Browser", "omarchy-launch-browser")
rebind("SUPER + SHIFT + F", "File manager", "omarchy-launch-nautilus")
rebind("SUPER + SHIFT + N", "Editor", "omarchy-launch-editor")
rebind("SUPER + SHIFT + M", "Music", "omarchy-launch-or-focus spotify", "spotify")
rebind("SUPER + SHIFT + O", "Obsidian",
  { focus = "^obsidian$", launch = "obsidian -disable-gpu --enable-wayland-ime" },
  "obsidian")
rebind("SUPER + SHIFT + SLASH", "Passwords", "omarchy-launch-1password")
rebind("SUPER + SHIFT + Y", "YouTube", { webapp = "https://youtube.com/" })
rebind("SUPER + SHIFT + ALT + G", "WhatsApp",
  { webapp = "https://web.whatsapp.com/", focus = true })

-- ------------------------------------------------------------- clipboard --

-- cliphist + Rofi, as on the host. Skipped unless both are installed —
-- Omarchy 4's own clipboard manager stays on SUPER + CTRL + V either way.
rebind("SUPER + Z", "Clipboard history",
  "sh -c 'cliphist list | rofi -dmenu | cliphist decode | wl-copy'", "rofi")

-- ============================================ NAVIGATION (host parity) ===
--
-- The host drives everything with SUPER + h/j/k/l. In quattro those keys are
-- already taken, so they are released first and the displaced actions are
-- re-homed below them.
--
--   SUPER + J         was  Toggle window split      ->  SUPER + CTRL + J
--   SUPER + K        was  Keybindings menu         ->  SUPER + CTRL + K
--   SUPER + L        was  Toggle workspace layout  ->  SUPER + N
--   SUPER + CTRL + K was  Herdr keybindings       ->  the keybindings menu again

hl.unbind("SUPER + J")
hl.unbind("SUPER + K")
hl.unbind("SUPER + L")
hl.unbind("SUPER + CTRL + K")

-- Focus on hjkl, using the exact same dispatcher as the arrow keys
-- (SUPER + LEFT/RIGHT/UP/DOWN below), so it behaves identically.
--
-- NOTE: the host's `hyprctl dispatch focusgroup <dir>` lines were never live --
-- `focusgroup` is not a valid Hyprland dispatcher (`hyprctl dispatch focusgroup
-- left` reports "Invalid dispatcher"). The host was really navigating with the
-- older `movefocus` binds, so that is what is ported here.
o.bind("SUPER + H", "Focus left", hl.dsp.focus({ direction = "l" }))
o.bind("SUPER + J", "Focus down", hl.dsp.focus({ direction = "d" }))
o.bind("SUPER + K", "Focus up", hl.dsp.focus({ direction = "u" }))
o.bind("SUPER + L", "Focus right", hl.dsp.focus({ direction = "r" }))

-- The quattro defaults that SUPER + J/K/L used to be, relocated.
-- SUPER + CTRL + K replaces quattro's Herdr keybindings overlay.
o.bind("SUPER + CTRL + J", "Toggle window split", hl.dsp.layout("togglesplit"))
o.bind("SUPER + CTRL + K", "Keybindings", "omarchy-menu-keybindings")
o.bind("SUPER + N", "Toggle workspace layout", "omarchy-hyprland-workspace-layout-toggle")

-- Move the focused window.
o.bind("SUPER + SHIFT + H", "Move window left", "hyprctl dispatch movewindow l")
o.bind("SUPER + SHIFT + J", "Move window down", "hyprctl dispatch movewindow d")
o.bind("SUPER + SHIFT + K", "Move window up", "hyprctl dispatch movewindow u")
o.bind("SUPER + SHIFT + L", "Move window right", "hyprctl dispatch movewindow r")

-- Join the group next door. SUPER + ALT + UP/DOWN already do this by default.
o.bind("SUPER + ALT + H", "Move window to group on left", hl.dsp.window.move({ into_group = "l" }))
o.bind("SUPER + ALT + L", "Move window to group on right", hl.dsp.window.move({ into_group = "r" }))

-- ================================ DISPLACES A QUATTRO DEFAULT (review me)
--
-- These three keys are useful Omarchy 4 defaults that the host's parity path
-- overrules. Delete the pair you do not want in order to keep the default.
--
--   SUPER + X     was  Universal cut (sends CTRL+X)
--   SUPER + TAB   was  Next workspace        (SUPER + CTRL + TAB and the
--                                           number keys still switch)
--   SUPER + T     was  Toggle floating/tiling

hl.unbind("SUPER + X")
o.bind("SUPER + X", "Kill window", hl.dsp.window.close())

hl.unbind("SUPER + TAB")
o.bind("SUPER + TAB", "Cycle window", hl.dsp.window.cycle_next())

hl.unbind("SUPER + T")
o.bind("SUPER + T", "Toggle window group", hl.dsp.group.toggle())

-- ---------------------------------------------------------- screenshot --

-- Screenshot of a window on SUPER + CTRL + P, as on the host.
-- NOTE: in quattro that key opens the Power menu. Delete these two lines to
-- keep Power there — PRINT is already a full screenshot.
hl.unbind("SUPER + CTRL + P")
o.bind("SUPER + CTRL + P", "Screenshot of window", "omarchy-capture-screenshot windows")
