-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
	config = wezterm.config_builder()
end

config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = 16.0
config.hide_tab_bar_if_only_one_tab = true
config.window_background_opacity = 0.75
config.macos_window_background_blur = 10
config.window_padding = {
	left = 3,
	right = 0,
	top = "0.9cell",
	bottom = 0,
}
config.window_close_confirmation = "NeverPrompt"
config.bidi_enabled = true
config.bidi_direction = "AutoLeftToRight"
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE|MACOS_FORCE_ENABLE_SHADOW"

return config
