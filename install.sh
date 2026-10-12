#!/usr/bin/env bash
#
# Material Teal i3 rice — dotfiles installer
# Symlinks this repo's configs into $HOME and (optionally) installs packages.
#
#   ./install.sh                     # symlink configs + install packages
#   ./install.sh --no-packages       # only symlink configs
#   ./install.sh --with-picom-animations   # also build the picom animations fork
#
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
WALLPAPER_SRC="$REPO_DIR/wallpapers/long_way_from_home.png"
WALLPAPER_DST="$HOME/Pictures/long_way_from_home.png"

INSTALL_PKGS=1
BUILD_PICOM_ANIMATIONS=0
for arg in "$@"; do
  case "$arg" in
    --no-packages)           INSTALL_PKGS=0 ;;
    --with-picom-animations) BUILD_PICOM_ANIMATIONS=1 ;;
    -h|--help)
      grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "unknown option: $arg" >&2; exit 1 ;;
  esac
done

log()  { printf '\033[1;36m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m  %s\n' "$*" >&2; }

# ---------------------------------------------------------------------------
# Package installation (apt / pacman / dnf)
# ---------------------------------------------------------------------------
detect_pm() {
  for pm in apt-get pacman dnf zypper; do
    command -v "$pm" >/dev/null 2>&1 && { echo "$pm"; return; }
  done
  echo "none"
}

install_packages() {
  local pm; pm="$(detect_pm)"
  log "Detected package manager: $pm"
  case "$pm" in
    apt-get)
      sudo apt-get update
      sudo apt-get install -y \
        i3-wm polybar picom dunst rofi kitty feh xclip xdotool xinput \
        x11-xserver-utils brightnessctl pulseaudio-utils \
        network-manager network-manager-gnome flameshot ksnip trayer \
        fontconfig fonts-jetbrains-mono curl unzip git \
        build-essential meson ninja-build cmake pkg-config \
        libev-dev libevdev-dev uthash-dev libconfig-dev libdbus-1-dev \
        libpcre2-dev libpixman-1-dev libgl1-mesa-dev libepoxy-dev \
        libx11-dev libx11-xcb-dev libxext-dev libxcb1-dev libxcb-util-dev \
        libxcb-damage0-dev libxcb-xfixes0-dev libxcb-shape0-dev \
        libxcb-render-util0-dev libxcb-render0-dev libxcb-randr0-dev \
        libxcb-composite0-dev libxcb-image0-dev libxcb-present-dev \
        libxcb-xinerama0-dev libxcb-glx0-dev libxcb-shm0-dev libxcb-sync-dev \
        libxcb-xkb-dev libxkbcommon-dev libxkbcommon-x11-dev
      ;;
    pacman)
      sudo pacman -Sy --needed --noconfirm \
        i3-wm polybar picom dunst rofi kitty feh xclip xdotool xorg-xinput \
        xorg-xrdb brightnessctl pulseaudio networkmanager flameshot ksnip \
        trayer ttf-jetbrains-mono-nerd fontconfig curl unzip git \
        base-devel meson ninja cmake pkgconf libev libevdev uthash libconfig \
        dbus pcre2 pixman libepoxy libxcb libxcb-util libxcb-render-util \
        libxcb-image libxcb-glx libxcb-xfixes libxcb-shape libxcb-randr \
        libxcb-composite libxcb-present libxcb-xinerama libxkbcommon
      ;;
    dnf)
      sudo dnf install -y \
        i3 polybar picom dunst rofi kitty feh xclip xdotool xinput \
        xorg-x11-xserver-utils brightnessctl pulseaudio-utils \
        NetworkManager flameshot ksnip trayer \
        fontconfig jetbrains-mono-fonts-all curl unzip git \
        @development-tools meson ninja-build cmake pkgconf \
        libev-devel libevdev-devel uthash-devel libconfig-devel dbus-devel \
        pcre2-devel pixman-devel mesa-libGL-devel libepoxy-devel \
        libX11-devel libXext-devel libxcb-devel xcb-util-devel \
        xcb-util-image-devel xcb-util-renderutil-devel
      ;;
    zypper)
      sudo zypper --non-interactive install \
        i3 polybar picom dunst rofi kitty feh xclip xdotool xinput \
        xrdb brightnessctl pulseaudio-utils NetworkManager flameshot ksnip \
        trayer fontconfig curl unzip git gcc make meson ninja cmake pkg-config \
        libev-devel libevdev-devel uthash-devel libconfig-devel dbus-1-devel \
        libpcre2-8-0 libpixman-1-0 libepoxy-0 \
        libX11-devel libXext-devel libxcb-devel xcb-util-devel
      ;;
    none) warn "No supported package manager found; install packages manually." ;;
  esac
}

# ---------------------------------------------------------------------------
# Symlink configs into $HOME (backs up anything it replaces)
# ---------------------------------------------------------------------------
link_file() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -L "$dst" ] && [ "$(readlink -- "$dst")" = "$src" ]; then
    return
  fi
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    mkdir -p "$BACKUP_DIR"
    mv -- "$dst" "$BACKUP_DIR/$(printf '%s' "${dst#"$HOME"/}" | tr '/' '_')"
  fi
  ln -s -- "$src" "$dst"
}

link_dotfiles() {
  log "Linking configs into \$HOME (backups: $BACKUP_DIR)"
  local app f rel
  for app in i3 polybar picom dunst rofi kitty; do
    [ -d "$REPO_DIR/.config/$app" ] || continue
    while IFS= read -r -d '' f; do
      rel="${f#"$REPO_DIR/.config/"}"
      link_file "$f" "$HOME/.config/$rel"
    done < <(find "$REPO_DIR/.config/$app" -type f -print0)
  done
  for f in .Xresources .gtkrc-2.0; do
    [ -e "$REPO_DIR/$f" ] && link_file "$REPO_DIR/$f" "$HOME/$f"
  done
  chmod +x "$HOME/.config/i3/"*.sh 2>/dev/null || true
  chmod +x "$HOME/.config/polybar/launch.sh" 2>/dev/null || true
}

# ---------------------------------------------------------------------------
# Wallpaper
# ---------------------------------------------------------------------------
set_wallpaper() {
  [ -e "$WALLPAPER_SRC" ] || { warn "wallpaper missing: $WALLPAPER_SRC"; return; }
  mkdir -p "$HOME/Pictures"
  cp -a "$WALLPAPER_SRC" "$WALLPAPER_DST"
  if command -v feh >/dev/null 2>&1 && [ -n "${DISPLAY:-}" ]; then
    feh --bg-scale "$WALLPAPER_DST" && log "Wallpaper set."
  else
    log "Wallpaper copied to $WALLPAPER_DST (feh will apply it from i3 on login)."
  fi
}

# ---------------------------------------------------------------------------
main() {
  log "Dotfiles repo: $REPO_DIR"
  [ "$INSTALL_PKGS" -eq 1 ] && install_packages
  link_dotfiles
  set_wallpaper
  if [ -x "$REPO_DIR/scripts/install-nerd-font.sh" ]; then
    log "Installing Nerd Font (JetBrainsMono)..."
    "$REPO_DIR/scripts/install-nerd-font.sh" || warn "Font install failed."
  fi
  if [ "$BUILD_PICOM_ANIMATIONS" -eq 1 ]; then
    "$REPO_DIR/scripts/install-picom-animations.sh"
  fi
  if command -v i3-msg >/dev/null 2>&1 && pgrep -x i3 >/dev/null 2>&1; then
    i3-msg reload >/dev/null 2>&1 && log "Reloaded i3." || true
  fi
  log "Done. Log out/in (or reload i3) to see everything."
  [ -d "$BACKUP_DIR" ] && log "Previous configs backed up to: $BACKUP_DIR"
}

main "$@"
