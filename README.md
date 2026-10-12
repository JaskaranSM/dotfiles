# dotfiles — Material Teal i3 rice

My personal **i3wm** desktop configuration: a clean dark _Material Teal_ theme
across the whole stack, plus real window animations.

![theme](https://img.shields.io/badge/theme-Material%20Teal-00bfa5)

## What's inside

| Component | What it is | Path |
|-----------|------------|------|
| **i3** | window manager + keybindings + helper scripts | `.config/i3/` |
| **polybar** | status bar (Material Teal, flat full-width) | `.config/polybar/` |
| **picom** | compositor — blur, shadows, rounded corners, **window animations** | `.config/picom/` |
| **dunst** | notifications | `.config/dunst/` |
| **rofi** | launcher | `.config/rofi/` |
| **kitty** | terminal (Material Teal 16-colour palette) | `.config/kitty/` |
| **wallpaper** | drawn with `feh` on i3 start | `wallpapers/` |

### Palette

| role | hex |
|------|-----|
| background | `#1e1e1e` |
| surface | `#2e2e2e` |
| foreground | `#e8eaed` |
| primary (teal) | `#00bfa5` |
| alert | `#ef5350` |
| success | `#66bb6a` |

## Install

```bash
git clone https://github.com/JaskaranSM/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh                      # packages + symlinks + font + wallpaper
```

Useful flags:

```bash
./install.sh --no-packages              # only symlink configs (packages already installed)
./install.sh --with-picom-animations    # also build the picom animations fork
```

The installer is distro-aware (apt / pacman / dnf / zypper) and **symlinks**
the configs into `$HOME`, backing up anything it replaces to
`~/.dotfiles-backup-<timestamp>/`.

After install, apply the wallpaper and reload:

```bash
feh --bg-scale ~/Pictures/long_way_from_home.png
i3-msg reload
```

## Window animations

The config in `.config/picom/picom.conf` uses the **`pijulius/picom`** fork for
open/close animations (`appear` / `disappear` presets). Ubuntu's packaged
`picom` (v10) does **not** support animations — build the fork with:

```bash
./scripts/install-picom-animations.sh
```

It installs to `~/.local/bin/picom` (keeping the distro `picom` in `/usr/bin`
untouched). Remove `~/.local/bin/picom` to revert.

## Keybindings (mod = Super)

| keys | action |
|------|--------|
| `mod+Return` | terminal (kitty) |
| `mod+d` | app launcher (rofi) |
| `mod+q` | close window |
| `mod+h/j/k/l`, arrows | focus |
| `mod+Shift+h/j/k/l` | move window |
| `mod+1..9` / `mod+Shift+1..9` | switch / move to workspace |
| `mod+f` | fullscreen |
| `mod+s/w/e` | stacking / tabbed / split |
| `mod+Shift+space` | toggle floating |
| `mod+v` | clipboard history (greenclip) |
| `Print` / `Shift+Print` | area / full screenshot |
| `mod+Control+l` | lock |
| `mod+Shift+r` | restart i3 |
| `mod+Shift+e` | exit i3 |

## Revert

Anything the installer replaced is in `~/.dotfiles-backup-<timestamp>/`.
The compositor can be reverted by deleting `~/.local/bin/picom`.

## Notes / extra dependencies

Some i3 bindings and polybar modules call tools that may not be in your distro
repos: `greenclip` (clipboard history), `rofi-bluetooth`,
`networkmanager_dmenu`, `dunstify`. Install them separately if you use those
bindings, or edit `.config/i3/config` accordingly.
