local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.color_scheme = 'Hyper-OLED'
config.default_cursor_style = 'BlinkingBlock'

config.font = wezterm.font 'Hack Nerd Font'
config.font_size = 11.0

config.window_decorations = 'NONE'
config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
config.window_background_opacity = 1.0

config.tab_bar_at_bottom = false
config.use_fancy_tab_bar = false

config.color_schemes = {
  ['Hyper-OLED'] = {
    background = '#000000',
    foreground = '#ffffff',
    cursor_bg = '#ffffff',
    cursor_fg = '#F81CE5',
    cursor_border = '#F81CE5',
    selection_bg = '#F81CE5',
    selection_fg = '#000000',
    scrollbar_thumb = '#1a1a1a',
    split = '#000000',
    ansi = {
      '#000000',
      '#cc2a2a',
      '#33cc33',
      '#cccc33',
      '#3366cc',
      '#aa33cc',
      '#33cccc',
      '#b0b0b0',
    },
    brights = {
      '#555555',
      '#fe4d4d',
      '#7fe57f',
      '#ffff66',
      '#6699ff',
      '#e066ff',
      '#66ffff',
      '#e0e0e0',
    },
    tab_bar = {
      background = '#000000',
      active_tab = {
        bg_color = '#000000',
        fg_color = '#ffffff',
        intensity = 'Normal',
        italic = false,
        underline = 'None',
        strikethrough = false,
      },
      inactive_tab = {
        bg_color = '#000000',
        fg_color = '#808080',
        intensity = 'Half',
      },
      inactive_tab_hover = {
        bg_color = '#000000',
        fg_color = '#cccccc',
        intensity = 'Normal',
      },
      new_tab = {
        bg_color = '#000000',
        fg_color = '#808080',
      },
      new_tab_hover = {
        bg_color = '#000000',
        fg_color = '#F81CE5',
        intensity = 'Bold',
      },
    },
  },
}

return config
