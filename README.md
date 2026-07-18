# wezterm-config

OLED-friendly [WezTerm](https://wezterm.org/) configuration based on the
[Hyper](https://hyper.is/) color scheme. Designed to turn off as many OLED
pixels as possible while staying readable.

The Alacritty sibling theme that inspired this one lives at
`~/Develop/Alacritty-Theme/Hyper-OLED.toml` and shares the same palette,
decorations, and padding rules for cross-terminal visual consistency.

## Features

- **True-black background** (`#000000`) — OLED pixels are fully off, no
  residual glow.
- **No window decorations** — title bar and borders removed so the title bar
  pixels stay off too.
- **Zero window padding** — the terminal area extends to the edge of the
  window; no illuminated frame around your text.
- **OLED-tuned ANSI palette** — saturated channels (especially blue, which
  is the least efficient OLED sub-pixel) are dimmed ~20% vs. the original
  Hyper palette to reduce sub-pixel usage without hurting readability.
- **Hyper-magenta cursor + selection** (`#F81CE5`) — high-contrast accent
  color that pops on true black.
- **Retro tab bar** in solid `#000000`; active vs. inactive tabs differ only
  by font intensity (Normal / Half) and foreground, so no tab-area pixels
  are lit to indicate focus.

## Requirements

- [WezTerm](https://wezterm.org/installation.html) (this config was written
  against `wezterm 20260716`; it should work on any recent build that
  supports the `color_schemes`, `window_decorations`, and `tab_bar`
  configuration keys).
- [Hack Nerd Font](https://github.com/ryanoasis/nerd-fonts) — installed
  system-wide. WezTerm falls back to its bundled default if the font is
  missing, but the icon glyphs in Nerd Font will not render.

## Install

### Clone in place (recommended)

This repo is meant to live at `~/.config/wezterm/` directly, so the
easiest install is to back up any existing config and clone:

```bash
mv ~/.config/wezterm ~/.config/wezterm.bak   # if you have existing config
gh repo clone lhsalas/wezterm-config ~/.config/wezterm
```

Restart WezTerm (or press `Ctrl+Shift+R` to reload the config).

### Clone elsewhere + symlink

If you prefer to keep the repo elsewhere:

```bash
git clone https://github.com/lhsalas/wezterm-config.git ~/Develop/wezterm-config
ln -s ~/Develop/wezterm-config/wezterm.lua ~/.config/wezterm/wezterm.lua
```

## Palette

| Slot        | Hex       | Notes                                  |
| ----------- | --------- | -------------------------------------- |
| Background  | `#000000` | True black                             |
| Foreground  | `#ffffff` | Default text                           |
| Cursor      | `#F81CE5` | Magenta border on a block cursor       |
| Selection   | `#F81CE5` | Magenta background, black text         |

### ANSI (normal)

| Color  | Hex       |
| ------ | --------- |
| Black  | `#000000` |
| Red    | `#cc2a2a` |
| Green  | `#33cc33` |
| Yellow | `#cccc33` |
| Blue   | `#3366cc` |
| Magenta| `#aa33cc` |
| Cyan   | `#33cccc` |
| White  | `#b0b0b0` |

### ANSI (bright)

| Color  | Hex       |
| ------ | --------- |
| Black  | `#555555` |
| Red    | `#fe4d4d` |
| Green  | `#7fe57f` |
| Yellow | `#ffff66` |
| Blue   | `#6699ff` |
| Magenta| `#e066ff` |
| Cyan   | `#66ffff` |
| White  | `#e0e0e0` |

## Why each choice

| Decision                                  | Rationale                                                       |
| ----------------------------------------- | --------------------------------------------------------------- |
| `background = '#000000'`                  | On OLED, pure black pixels consume ~0 power; off-black wastes it. |
| `window_decorations = 'NONE'`             | Title bars and window borders would otherwise stay lit even with no terminal content. |
| `window_padding = { 0, 0, 0, 0 }`         | Padding is part of the window surface; zero padding keeps the entire surface as pure black. |
| `window_background_opacity = 1.0`         | Explicitly disables any compositor-side blur, which lights up the background. |
| `scrollbar_thumb = '#1a1a1a'`             | Almost-black scrollbar thumb: discoverable, but minimal sub-pixel use. |
| `split = '#000000'`                       | Pane split lines disappear into the background. |
| Normal ANSI ~`#xxCCxx` instead of `#xxFFxx`| Cuts each channel's brightness ~20% — large savings on green/red/blue sub-pixels. |
| Blue dimmed most aggressively             | The blue OLED sub-pixel has the lowest luminous efficacy; dimming it saves the most power per perceived-luminance drop. |
| Tab bar `bg_color = '#000000'`            | No tab-area pixels are lit; focus state communicated only via fg color and font intensity. |
| Bright white stays below `#FFFFFF`        | Avoids maxing out all three sub-pixels for routine text.        |

## Customization

Open `wezterm.lua` and adjust:

- `config.font_size` — start at `11.0`; raise for HiDPI screens.
- `config.font` — change to any Nerd Font you have installed
  (e.g. `wezterm.font 'JetBrainsMono Nerd Font'`).
- The `ansi` / `brights` tables — paste in your own palette. The OLED
  rationale above still applies: prefer colors where at least one channel
  sits below `#CC`.
- `cursor_border` / `selection_bg` — change the Hyper-magenta to any
  accent color; keep the saturation high so it remains visible on black.

WezTerm auto-reloads the config on save. To force a reload, press
`Ctrl+Shift+R` inside any WezTerm window.

## Related

- Alacritty sister theme: `~/Develop/Alacritty-Theme/Hyper-OLED.toml`
- WezTerm configuration reference: <https://wezterm.org/config/files.html>
- WezTerm color schemes: <https://wezterm.org/colorschemes/index.html>

## License

[MIT](./LICENSE)
