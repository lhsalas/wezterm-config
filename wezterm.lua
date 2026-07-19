local wezterm = require 'wezterm'
local act = wezterm.action
local config = wezterm.config_builder()

-- Toggle for tab title shape: "square" (default) or "rounded" (nerdfont edges).
-- Only takes effect with the retro tab bar.
local tab_style = 'square'

config.color_scheme = 'Hyper-OLED'
config.default_cursor_style = 'BlinkingBlock'

config.font = wezterm.font 'Hack Nerd Font'
config.font_size = 11.0

config.window_decorations = 'NONE'
config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
config.window_background_opacity = 1.0

config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false

config.leader = { key = 'b', mods = 'CTRL', timeout_milliseconds = 1000 }
config.status_update_interval = 1000

config.keys = {
  { mods = 'LEADER', key = 'c', action = act.SpawnTab 'CurrentPaneDomain' },
  { mods = 'LEADER', key = 'x', action = act.CloseCurrentPane { confirm = true } },

  { mods = 'LEADER', key = '|', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { mods = 'LEADER', key = '-', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },

  { mods = 'LEADER', key = 'h', action = act.ActivatePaneDirection 'Left' },
  { mods = 'LEADER', key = 'j', action = act.ActivatePaneDirection 'Down' },
  { mods = 'LEADER', key = 'k', action = act.ActivatePaneDirection 'Up' },
  { mods = 'LEADER', key = 'l', action = act.ActivatePaneDirection 'Right' },

  { mods = 'LEADER', key = 'LeftArrow',  action = act.AdjustPaneSize { 'Left',  5 } },
  { mods = 'LEADER', key = 'RightArrow', action = act.AdjustPaneSize { 'Right', 5 } },
  { mods = 'LEADER', key = 'DownArrow',  action = act.AdjustPaneSize { 'Down',  5 } },
  { mods = 'LEADER', key = 'UpArrow',    action = act.AdjustPaneSize { 'Up',    5 } },

  { mods = 'LEADER', key = 'b', action = act.ActivateTabRelative(-1) },
  { mods = 'LEADER', key = 'n', action = act.ActivateTabRelative(1) },

  { mods = 'LEADER', key = 'z', action = act.TogglePaneZoomState },
  {
    mods = 'LEADER',
    key = '!',
    action = wezterm.action_callback(function(win, pane)
      pane:move_to_new_tab()
    end),
  },
  { mods = 'LEADER', key = 'o', action = act.RotatePanes 'Clockwise' },

  { mods = 'LEADER', key = '[', action = act.ActivateCopyMode },
  { mods = 'LEADER', key = ']', action = act.PasteFrom 'Clipboard' },

  {
    mods = 'LEADER',
    key = ',',
    action = act.PromptInputLine {
      description = 'Rename tab',
      initial_value = '',
      action = wezterm.action_callback(function(window, pane, line)
        if line and line ~= '' then
          window:active_tab():set_title(line)
        end
      end),
    },
  },
  { mods = 'LEADER', key = '&', action = act.CloseCurrentTab { confirm = true } },

  { mods = 'LEADER', key = 'w', action = act.ShowTabNavigator },
  { mods = 'LEADER', key = 's', action = act.ActivateCommandPalette },
  { mods = 'LEADER', key = ':', action = act.ActivateCommandPalette },
  { mods = 'LEADER', key = '?', action = act.ActivateCommandPalette },

  { mods = 'LEADER', key = 'd', action = act.DetachDomain 'CurrentPaneDomain' },

  {
    key = 'r',
    mods = 'CTRL|SHIFT',
    action = act.ReloadConfiguration,
  },
}

for i = 0, 9 do
  table.insert(config.keys, {
    key = tostring(i),
    mods = 'LEADER',
    action = act.ActivateTab(i),
  })
end

local function tab_title(tab_info)
  local title = tab_info.tab_title
  if title and #title > 0 then
    return title
  end
  return tab_info.active_pane.title
end

wezterm.on('format-tab-title', function(tab, tabs, panes, cfg, hover, max_width)
  local index = tab.tab_index + 1
  local title_text = ' ' .. index .. ': ' .. tab_title(tab) .. ' '
  local left_edge = ''
  local right_edge = ''

  if tab_style == 'rounded' then
    title_text = index .. ': ' .. tab_title(tab)
    title_text = wezterm.truncate_right(title_text, max_width - 2)
    left_edge = wezterm.nerdfonts.ple_left_half_circle_thick
    right_edge = wezterm.nerdfonts.ple_right_half_circle_thick
  end

  if tab.is_active then
    return {
      { Background = { Color = '#000000' } },
      { Foreground = { Color = '#F81CE5' } },
      { Text = left_edge },
      { Background = { Color = '#F81CE5' } },
      { Foreground = { Color = '#000000' } },
      { Attribute = { Intensity = 'Bold' } },
      { Text = title_text },
      { Background = { Color = '#000000' } },
      { Foreground = { Color = '#F81CE5' } },
      { Text = right_edge },
    }
  end
end)

local function active_workspace(window)
  return window:active_workspace() or 'default'
end

wezterm.on('update-status', function(window, _)
  local workspace = active_workspace(window)
  local tab = window:active_tab()
  local title = ''
  if tab then
    local t = tab:get_title()
    if t and t ~= '' then
      title = t
    end
  end

  local leader_active = window:leader_is_active()
  local wave = utf8.char(0x1f30a)
  local left_arrow = ''
  local arrow_fg = { Foreground = { Color = '#F81CE5' } }
  local arrow_bg = { Background = { Color = '#000000' } }
  local prefix = ''

  if leader_active then
    prefix = ' ' .. wave

    if tab_style == 'rounded' then
      left_arrow = wezterm.nerdfonts.ple_right_half_circle_thick
    else
      left_arrow = wezterm.nerdfonts.pl_left_hard_divider
    end

    if tab_style ~= 'rounded' then
      local tabs = window:mux_window():tabs_with_info()
      for _, tab_info in ipairs(tabs) do
        if tab_info.is_active and tab_info.index == 0 then
          arrow_bg = { Foreground = { Color = '#F81CE5' } }
          left_arrow = wezterm.nerdfonts.pl_right_hard_divider
          break
        end
      end
    end
  end

  window:set_left_status(wezterm.format {
    { Background = { Color = '#F81CE5' } },
    { Foreground = { Color = '#000000' } },
    { Attribute = { Intensity = 'Bold' } },
    { Text = ' ' .. workspace .. ' ' },
    { Background = { Color = '#1a1a1a' } },
    { Foreground = { Color = '#ffffff' } },
    { Text = ' ' .. title .. ' ' },
    { Background = { Color = '#F81CE5' } },
    { Foreground = { Color = '#000000' } },
    { Text = prefix },
    arrow_fg,
    arrow_bg,
    { Text = left_arrow },
  })

  window:set_right_status('')
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