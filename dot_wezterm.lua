-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

config.color_scheme = 'Dracula (Official)'

config.enable_tab_bar = false
config.font_size = 16

-- and finally, return the configuration to wezterm
return config
