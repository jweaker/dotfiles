local wezterm = require("wezterm")
local os = require("os")

local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = 16.0
config.hide_tab_bar_if_only_one_tab = true
config.warn_about_missing_glyphs = false
config.window_background_opacity = 0.8
config.macos_window_background_blur = 10

config.window_padding = {
	left = 3,
	right = 0,
	top = "1cell",
	bottom = 0,
}

config.window_close_confirmation = "NeverPrompt"
config.bidi_enabled = true
config.bidi_direction = "AutoLeftToRight"
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE|MACOS_FORCE_ENABLE_SHADOW"

wezterm.on("update-right-status", function(window, pane)
	local process_name = pane:get_foreground_process_name()
	local has_tmux = process_name and string.find(process_name, "tmux")
	local mux_window = window:mux_window()
	local tab_count = #mux_window:tabs()

	local dims = window:get_dimensions()
	local isnt_maximized = dims.pixel_height and dims.pixel_height < 1900

	if (has_tmux or tab_count > 1) and isnt_maximized then
		-- Reduced paddin when tmux is active
		window:set_config_overrides({
			window_padding = {
				left = 3,
				right = 0,
				top = 3,
				bottom = 0,
			},
		})
	else
		-- Normal padding when tmux is not active
		window:set_config_overrides({
			window_padding = {
				left = 3,
				right = 0,
				top = "1cell",
				bottom = 0,
			},
		})
	end
end)

return config
