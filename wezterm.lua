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
config.tab_and_split_indices_are_zero_based = true

config.leader = { key = 'b', mods = 'CTRL', timeout_milliseconds = 1000 }
config.status_update_interval = 1000

-- Per-window state used by tmux-faithful leader bindings that don't have a
-- direct wezterm action (last-pane toggle, last-workspace jump).
local leader_state = {
  last_pane_idx = {},   -- [window_id] = int   (0-based; pane last focused)
  last_workspace = {},   -- [window_id] = string (workspace we just left)
  _current_ws = {},      -- [window_id] = string (workspace we last rendered)
}

config.keys = {
  -- Window / tab control (tmux `prefix c`, `prefix x`, `prefix &`)
  { mods = 'LEADER', key = 'c', action = act.SpawnTab 'CurrentPaneDomain' },
  { mods = 'LEADER', key = 'x', action = act.CloseCurrentPane { confirm = true } },
  { mods = 'LEADER|SHIFT', key = '&', action = act.CloseCurrentTab { confirm = true } },

  -- Splits (tmux `prefix %` L/R, `prefix "` T/B)
  { mods = 'LEADER|SHIFT', key = '%', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { mods = 'LEADER|SHIFT', key = '"', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },

  -- Pane navigation (LEADER + arrow key, tmux-style repeat on subsequent arrow presses)
  { mods = 'LEADER', key = 'LeftArrow',
    action = act.Multiple {
      act.ActivatePaneDirection 'Left',
      act.ActivateKeyTable { name = 'pane_nav', timeout_milliseconds = 1000,
                            one_shot = false, replace_current = true },
    } },
  { mods = 'LEADER', key = 'RightArrow',
    action = act.Multiple {
      act.ActivatePaneDirection 'Right',
      act.ActivateKeyTable { name = 'pane_nav', timeout_milliseconds = 1000,
                            one_shot = false, replace_current = true },
    } },
  { mods = 'LEADER', key = 'DownArrow',
    action = act.Multiple {
      act.ActivatePaneDirection 'Down',
      act.ActivateKeyTable { name = 'pane_nav', timeout_milliseconds = 1000,
                            one_shot = false, replace_current = true },
    } },
  { mods = 'LEADER', key = 'UpArrow',
    action = act.Multiple {
      act.ActivatePaneDirection 'Up',
      act.ActivateKeyTable { name = 'pane_nav', timeout_milliseconds = 1000,
                            one_shot = false, replace_current = true },
    } },

  -- Pane resize (LEADER + CTRL + arrow key, same tmux-style repeat behavior)
  { mods = 'LEADER|CTRL', key = 'LeftArrow',
    action = act.Multiple {
      act.AdjustPaneSize { 'Left', 5 },
      act.ActivateKeyTable { name = 'pane_resize', timeout_milliseconds = 1000,
                            one_shot = false, replace_current = true },
    } },
  { mods = 'LEADER|CTRL', key = 'RightArrow',
    action = act.Multiple {
      act.AdjustPaneSize { 'Right', 5 },
      act.ActivateKeyTable { name = 'pane_resize', timeout_milliseconds = 1000,
                            one_shot = false, replace_current = true },
    } },
  { mods = 'LEADER|CTRL', key = 'DownArrow',
    action = act.Multiple {
      act.AdjustPaneSize { 'Down', 5 },
      act.ActivateKeyTable { name = 'pane_resize', timeout_milliseconds = 1000,
                            one_shot = false, replace_current = true },
    } },
  { mods = 'LEADER|CTRL', key = 'UpArrow',
    action = act.Multiple {
      act.AdjustPaneSize { 'Up', 5 },
      act.ActivateKeyTable { name = 'pane_resize', timeout_milliseconds = 1000,
                            one_shot = false, replace_current = true },
    } },

  -- Pane ops (tmux `prefix o` rotate, `prefix ;` last, `prefix q` display,
  -- `prefix {` / `prefix }` swap, `prefix z` zoom, `prefix !` break-pane)
  { mods = 'LEADER', key = 'o', action = act.RotatePanes 'Clockwise' },
  {
    mods = 'LEADER',
    key = ';',
    action = wezterm.action_callback(function(win, _)
      local prev = leader_state.last_pane_idx[win:window_id()]
      if prev then win:perform_action(act.ActivatePaneByIndex(prev), win:active_pane()) end
    end),
  },
  { mods = 'LEADER', key = 'q', action = act.PaneSelect { show_pane_ids = true } },
  {
    mods = 'LEADER|SHIFT',
    key = '{',
    action = act.PaneSelect { mode = 'SwapWithActiveKeepFocus' },
  },
  {
    mods = 'LEADER|SHIFT',
    key = '}',
    action = act.PaneSelect { mode = 'SwapWithActive' },
  },
  { mods = 'LEADER', key = 'z', action = act.TogglePaneZoomState },
  {
    mods = 'LEADER|SHIFT',
    key = '!',
    action = wezterm.action_callback(function(_, pane)
      pane:move_to_new_tab()
    end),
  },

  -- Window / tab navigation (tmux `prefix n` next, `prefix p` prev,
  -- `prefix '` choose-by-index, `prefix .` move-to-index, `prefix f` find,
  -- `prefix ,` rename, `prefix w` list, `prefix 0-9` select)
  { mods = 'LEADER', key = 'n', action = act.ActivateTabRelative(1) },
  { mods = 'LEADER', key = 'p', action = act.ActivateTabRelative(-1) },
  {
    mods = 'LEADER',
    key = "'",
    action = act.PromptInputLine {
      description = wezterm.format {
        { Attribute = { Intensity = 'Bold' } },
        { Text = 'Tab index (0-based)' },
      },
      initial_value = '',
      action = wezterm.action_callback(function(win, _, line)
        if line and line ~= '' then
          local idx = tonumber(line)
          if idx then win:perform_action(act.ActivateTab(idx), win:active_pane()) end
        end
      end),
    },
  },
  {
    mods = 'LEADER',
    key = '.',
    action = act.PromptInputLine {
      description = wezterm.format {
        { Attribute = { Intensity = 'Bold' } },
        { Text = 'Move current tab to index' },
      },
      initial_value = '',
      action = wezterm.action_callback(function(win, _, line)
        if line and line ~= '' then
          local idx = tonumber(line)
          if idx then win:perform_action(act.MoveTab(idx), win:active_pane()) end
        end
      end),
    },
  },
  { mods = 'LEADER', key = 'f', action = act.ShowLauncherArgs { flags = 'FUZZY|TABS' } },
  {
    mods = 'LEADER',
    key = ',',
    action = act.PromptInputLine {
      description = wezterm.format {
        { Attribute = { Intensity = 'Bold' } },
        { Text = 'Rename tab' },
      },
      initial_value = '',
      action = wezterm.action_callback(function(win, _, line)
        if line and line ~= '' then win:active_tab():set_title(line) end
      end),
    },
  },
  { mods = 'LEADER', key = 'w', action = act.ShowTabNavigator },

  -- Copy / paste (tmux `prefix [` copy-mode, `prefix ]` paste)
  { mods = 'LEADER', key = '[', action = act.ActivateCopyMode },
  { mods = 'LEADER', key = ']', action = act.PasteFrom 'Clipboard' },

  -- Command-prompt style (tmux `prefix s` sessions, `prefix :` command, `prefix ?` keys)
  { mods = 'LEADER', key = 's', action = act.ShowLauncherArgs { flags = 'FUZZY|WORKSPACES' } },
  { mods = 'LEADER|SHIFT', key = ':', action = act.ActivateCommandPalette },
  { mods = 'LEADER|SHIFT', key = '?', action = act.ActivateCommandPalette },

  -- Detach (tmux `prefix d`)
  { mods = 'LEADER', key = 'd', action = act.DetachDomain 'CurrentPaneDomain' },

  -- Workspaces as tmux sessions (tmux `prefix (` / `)` prev/next session,
  -- `prefix $` rename session, `prefix L` last session)
  { mods = 'LEADER|SHIFT', key = '(', action = act.SwitchWorkspaceRelative(-1) },
  { mods = 'LEADER|SHIFT', key = ')', action = act.SwitchWorkspaceRelative(1) },
  {
    mods = 'LEADER|SHIFT',
    key = '$',
    action = act.PromptInputLine {
      description = wezterm.format {
        { Attribute = { Intensity = 'Bold' } },
        { Text = 'Rename workspace' },
      },
      initial_value = '',
      action = wezterm.action_callback(function(win, _, line)
        if line and line ~= '' then wezterm.mux.rename_workspace(line) end
      end),
    },
  },
  {
    mods = 'LEADER|SHIFT',
    key = 'L',
    action = wezterm.action_callback(function(win, _)
      local prev = leader_state.last_workspace[win:window_id()]
      if prev then wezterm.mux.set_active_workspace(prev) end
    end),
  },

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

config.key_tables = {
  pane_nav = {
    { key = 'LeftArrow',  action = act.ActivatePaneDirection 'Left'  },
    { key = 'RightArrow', action = act.ActivatePaneDirection 'Right' },
    { key = 'UpArrow',    action = act.ActivatePaneDirection 'Up'    },
    { key = 'DownArrow',  action = act.ActivatePaneDirection 'Down'  },
    { key = 'Escape',     action = act.PopKeyTable },
  },
  pane_resize = {
    { key = 'LeftArrow',  mods = 'CTRL', action = act.AdjustPaneSize { 'Left',  5 } },
    { key = 'RightArrow', mods = 'CTRL', action = act.AdjustPaneSize { 'Right', 5 } },
    { key = 'UpArrow',    mods = 'CTRL', action = act.AdjustPaneSize { 'Up',    5 } },
    { key = 'DownArrow',  mods = 'CTRL', action = act.AdjustPaneSize { 'Down',  5 } },
    { key = 'Escape',     action = act.PopKeyTable },
  },
}

local function tab_title(tab_info)
  local title = tab_info.tab_title
  if title and #title > 0 then
    return title
  end
  return tab_info.active_pane.title
end

wezterm.on('format-tab-title', function(tab, tabs, panes, cfg, hover, max_width)
  local index = tab.tab_index
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
      { Foreground = { Color = '#808080' } },
      { Text = left_edge },
      { Background = { Color = '#808080' } },
      { Foreground = { Color = '#000000' } },
      { Attribute = { Intensity = 'Bold' } },
      { Text = title_text },
      { Background = { Color = '#000000' } },
      { Foreground = { Color = '#808080' } },
      { Text = right_edge },
    }
  end
end)

local function active_workspace(window)
  return window:active_workspace() or 'default'
end

wezterm.on('update-status', function(window, _)
  -- Track pane-focus history for LEADER + ; (last-pane toggle).
  -- We store the active pane's 0-based index per window; LEADER + ;
  -- reactivates the previously-focused pane.
  local pane = window:active_pane()
  local wid = window:window_id()
  if pane then
    local panes = pane:tab():panes_with_info()
    for i, info in ipairs(panes) do
      if info.pane_id == pane:pane_id() then
        leader_state.last_pane_idx[wid] = i - 1
        break
      end
    end
  end

  -- Track workspace history for LEADER + SHIFT + L (last-workspace jump).
  -- _current_ws holds the workspace name we last rendered for this window;
  -- on a change, we promote it to last_workspace so LEADER + SHIFT + L
  -- returns there.
  local workspace = active_workspace(window)
  if leader_state._current_ws[wid] == nil then
    leader_state._current_ws[wid] = workspace
  elseif leader_state._current_ws[wid] ~= workspace then
    leader_state.last_workspace[wid] = leader_state._current_ws[wid]
    leader_state._current_ws[wid] = workspace
  end
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
  local arrow_fg = { Foreground = { Color = '#808080' } }
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
          arrow_bg = { Foreground = { Color = '#808080' } }
          left_arrow = wezterm.nerdfonts.pl_right_hard_divider
          break
        end
      end
    end
  end

  local is_default = workspace == 'default'
  local segments = {}

  if not is_default then
    table.insert(segments, { Background = { Color = '#808080' } })
    table.insert(segments, { Foreground = { Color = '#000000' } })
    table.insert(segments, { Attribute = { Intensity = 'Bold' } })
    table.insert(segments, { Text = ' ' .. workspace .. ' ' })
  end

  table.insert(segments, { Background = { Color = is_default and '#000000' or '#1a1a1a' } })
  table.insert(segments, { Foreground = { Color = '#ffffff' } })
  table.insert(segments, { Text = is_default and title or (' ' .. title .. ' ') })

  table.insert(segments, { Background = { Color = '#000000' } })
  table.insert(segments, { Foreground = { Color = '#808080' } })
  table.insert(segments, { Text = prefix })
  table.insert(segments, arrow_fg)
  table.insert(segments, arrow_bg)
  table.insert(segments, { Text = left_arrow })

  window:set_left_status(wezterm.format(segments))

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
