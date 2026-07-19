local wezterm = require 'wezterm'
local act = wezterm.action
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

config.leader = { key = 'b', mods = 'CTRL', timeout_milliseconds = 1000 }
config.status_update_interval = 1000

config.keys = {
  {
    key = 'b',
    mods = 'CTRL',
    action = act.ActivateKeyTable({ name = 'leader', timeout_milliseconds = 1000, one_shot = false, prevent_default = false }),
  },
  {
    key = 'r',
    mods = 'CTRL|SHIFT',
    action = act.ReloadConfiguration,
  },
}

config.key_tables = {
  leader = {
    { key = 'c', action = act.SpawnTab('CurrentPaneDomain') },
    { key = 'C', action = act.SpawnTab('CurrentPaneDomain') },

    { key = '"', action = act.SplitHorizontal({ domain = 'CurrentPaneDomain' }) },
    { key = '%', action = act.SplitVertical({ domain = 'CurrentPaneDomain' }) },

    { key = 'LeftArrow',  action = act.ActivatePaneDirection('Left') },
    { key = 'RightArrow', action = act.ActivatePaneDirection('Right') },
    { key = 'UpArrow',    action = act.ActivatePaneDirection('Up') },
    { key = 'DownArrow',  action = act.ActivatePaneDirection('Down') },
    { key = 'h', action = act.ActivatePaneDirection('Left') },
    { key = 'l', action = act.ActivatePaneDirection('Right') },
    { key = 'k', action = act.ActivatePaneDirection('Up') },
    { key = 'j', action = act.ActivatePaneDirection('Down') },

    { key = 'x', action = act.CloseCurrentPane({ confirm = true }) },
    { key = 'z', action = act.TogglePaneZoomState },
    { key = '!', action = act.MovePaneToNewTab() },
    { key = 'o', action = act.RotatePanes('Clockwise') },

    { key = '[', action = act.ActivateCopyMode({ prior_cwd_mode = 'NoChange' }) },
    { key = ']', action = act.PasteFrom('Clipboard') },

    { key = 'n', action = act.ActivateTabRelative(1) },
    { key = 'p', action = act.ActivateTabRelative(-1) },
    { key = 'L', action = act.ActivateLastTab },
    { key = 'Tab', action = act.ActivateLastTab },

    { key = '0', action = act.ActivateTab(0) },
    { key = '1', action = act.ActivateTab(1) },
    { key = '2', action = act.ActivateTab(2) },
    { key = '3', action = act.ActivateTab(3) },
    { key = '4', action = act.ActivateTab(4) },
    { key = '5', action = act.ActivateTab(5) },
    { key = '6', action = act.ActivateTab(6) },
    { key = '7', action = act.ActivateTab(7) },
    { key = '8', action = act.ActivateTab(8) },
    { key = '9', action = act.ActivateTab(9) },

    { key = ',', action = act.PromptInputLine({
      prompt = 'Rename tab: ',
      action = act.SwitchToWorkspace,
    }) },
    { key = '&', action = act.CloseCurrentTab({ confirm = true }) },

    { key = 'w', action = act.ShowTabNavigator },
    { key = 's', action = act.ActivateCommandPalette },
    { key = ':', action = act.ActivateCommandPalette },
    { key = '?', action = act.ActivateCommandPalette },

    { key = 'd', action = act.DetachDomain('unix') },

    { key = 'q', action = act.PopKeyTable },
    { key = 'Escape', action = act.PopKeyTable },
  },
}

wezterm.on('update-status', function(window, pane)
  local kt = window:active_key_table()
  local mode_badge = ''
  if kt == 'leader' then
    mode_badge = wezterm.format({
      { Background = { Color = '#F81CE5' } },
      { Foreground = { Color = '#000000' } },
      { Attribute = { Intensity = 'Bold' } },
      { Text = ' LEADER ' },
    })
  elseif kt then
    mode_badge = wezterm.format({ { Text = '[' .. kt .. ']' } })
  end

  window:set_right_status(wezterm.format({
    { Text = wezterm.strftime('%H:%M:%S') .. '  ' },
    { Text = mode_badge },
  }))

  local workspace = window:active_workspace() or 'default'
  local tab = window:active_tab()
  local title = ''
  if tab then
    local t = tab:get_title()
    if t and t ~= '' then
      title = t
    end
  end

  window:set_left_status(wezterm.format({
    { Background = { Color = '#F81CE5' } },
    { Foreground = { Color = '#000000' } },
    { Attribute = { Intensity = 'Bold' } },
    { Text = ' ' .. workspace .. ' ' },
    { Background = { Color = '#1a1a1a' } },
    { Foreground = { Color = '#ffffff' } },
    { Text = ' ' .. title .. ' ' },
  }))
end)

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
