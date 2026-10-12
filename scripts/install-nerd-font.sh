#!/usr/bin/env bash
#
# Install JetBrainsMono Nerd Font into ~/.local/share/fonts
#
set -euo pipefail

FONT_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/fonts"
URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "==> Downloading JetBrainsMono Nerd Font"
curl -fL "$URL" -o "$TMP/JetBrainsMono.zip"

echo "==> Installing to $FONT_DIR"
mkdir -p "$FONT_DIR"
unzip -o "$TMP/JetBrainsMono.zip" -d "$TMP/out" >/dev/null
find "$TMP/out" -name '*.ttf' -exec cp -f {} "$FONT_DIR/" \;

echo "==> Refreshing font cache"
fc-cache -f >/dev/null

echo "==> Done. Installed families:"
fc-list | grep -i "JetBrainsMono Nerd Font" | sed 's/:.*style/ style/' | sort -u | head
