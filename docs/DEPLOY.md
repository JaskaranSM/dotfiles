# End-to-end deployment guide

This documents deploying this rice from scratch on a **bare, minimal distro with
no desktop environment**. It was validated end-to-end in a KVM virtual machine
running the **Ubuntu 24.04 cloud image** (no DE) — the installer's `apt` path.

> The same `install.sh` supports `pacman` (Arch), `dnf` (Fedora) and `zypper`
> (openSUSE); only the package list differs.

## 1. Prerequisites

- A minimal install (no DE) with internet access and `sudo`.
- An X server (installed by the installer via the i3/polybar/X deps) and a way
  to start i3 — a display manager, or `startx`.

## 2. Install

```bash
sudo apt-get install -y git          # or pacman -S / dnf install
git clone https://github.com/JaskaranSM/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh                         # packages + symlinks + font + wallpaper
```

Add `--with-picom-animations` to also build the `pijulius/picom` fork (real
window animations). If you run it separately later:

```bash
./scripts/install-picom-animations.sh
```

### What the installer does

1. Detects your package manager and installs: i3, polybar, picom, dunst, rofi,
   kitty, feh, screenshot/volume/brightness helpers, fonts, and build tools.
2. **Symlinks** every config into `$HOME` (existing files are backed up to
   `~/.dotfiles-backup-<timestamp>/`). You edit the repo, the system follows.
3. Copies the wallpaper to `~/Pictures/` and applies it with `feh` **only if an
   X display is available** (safe on headless installs).
4. Installs the **JetBrainsMono Nerd Font**.
5. Reloads i3 if it is running.

## 3. Start the desktop

With a display manager: pick the **i3** session and log in.

Without one (e.g. a truly minimal system), install `xinit` and use `~/.xinitrc`:

```bash
echo 'exec i3' > ~/.xinitrc
startx
```

i3's `exec_always` lines then launch polybar, picom, dunst, greenclip and the
wallpaper automatically.

## 4. Optional dependencies

Some i3 bindings / polybar modules call tools that are not in every distro's
repos. Install them or remove the matching binding/module:

| tool | used by | note |
|------|---------|------|
| `greenclip` | `mod+v` clipboard history | not packaged; build from source |
| `rofi-bluetooth` | polybar bluetooth module, click | optional (module degrades gracefully) |
| `networkmanager_dmenu` | polybar wifi click, `mod+Shift+w` | optional |
| `dunstify` | volume/brightness OSD | ships with `dunst` |
| `ksnip` | screenshot bindings | in most repos |
| `flameshot` | `screenshot.sh` | in most repos |

## 5. Verification checklist

```bash
i3 -C -c ~/.config/i3/config            # i3 config valid
polybar -c ~/.config/polybar/config.ini -s main | head   # polybar parses
picom --config ~/.config/picom/picom.conf --help >/dev/null && echo ok
```

In a live session: the Material Teal bar appears, `mod+d` opens rofi, terminal
opens with `mod+Return`, windows animate on open/close (fork build).

Headless verification (no display) can use `xvfb-run`:

```bash
xvfb-run -a --server-args="-screen 0 1920x1080x24" \
  polybar -c ~/.config/polybar/config.ini -p /tmp/bar.png main
```

## 6. Gotchas (learned during testing)

- **Headless installs:** `feh` needs a display; the installer skips it and the
  wallpaper is applied by i3 on login.
- **PATH for the picom fork:** `i3` must find `~/.local/bin/picom` before
  `/usr/bin/picom`. The animations installer ensures `~/.local/bin` is on the
  PATH (via `~/.profile`). Log out/in after building it.
- **Building the fork:** needs `cmake` in addition to `meson`/`ninja` — the
  build pulls `libconfig >= 1.7` as a subproject when your distro ships an
  older one. Use CMake < 4 (CMake 4 breaks the old libconfig `CMakeLists.txt`).
- **Under Xvfb/software GL:** picom logs a harmless `Failed to enable vsync`.
- **VM/module noise:** on machines without a wireless NIC / battery / thermal
  sensor, polybar disables those modules automatically.

## 7. Revert

- Installer backups: `~/.dotfiles-backup-<timestamp>/`
- Compositor: delete `~/.local/bin/picom` to fall back to the distro picom.
