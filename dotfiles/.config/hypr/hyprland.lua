-- Hyprland entry point for Omarchy quattro (4.x, Lua config).
--
-- Mirrors the stock Omarchy 4.0.4 ~/.config/hypr/hyprland.lua so that
-- `omarchy refresh hyprland` produces an obvious diff. Kept in chezmoi so a
-- fresh quattro machine (the VM) boots with the same load order as the host.
--
-- On Omarchy 3.x (the host) Hyprland reads hyprland.conf instead; chezmoi
-- ignores this file there. See .chezmoiignore.

-- Omarchy's bootstrap keeps path setup out of this user config.
dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")

-- Disable all Omarchy default bindings. Add your own in hypr/bindings.lua.
-- omarchy_default_bindings = false
--
-- Or disable only bindings for Omarchy's preinstalled apps/web apps while
-- keeping core window-manager bindings:
-- omarchy_preinstalled_bindings = false

-- Load Omarchy defaults.
require("default.hypr.omarchy")

-- Personal overrides. Loaded after the defaults, so package updates can improve
-- Omarchy without rewriting these files.
require("hypr.monitors")
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")

-- Toggle config flags dynamically.
require("default.hypr.toggles")

-- Add any other personal Hyprland configuration below.
-- o.window("qemu", { workspace = "5" })
