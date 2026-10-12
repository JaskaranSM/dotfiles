#!/usr/bin/env bash
#
# Build & install the pijulius/picom fork (window animations) into ~/.local
# This gives you real open/close animations used by picom.conf.
#
#   ./scripts/install-picom-animations.sh
#
set -euo pipefail

REPO_URL="https://github.com/pijulius/picom.git"
SRC="${XDG_CACHE_HOME:-$HOME/.cache}/picom-animations"
PREFIX="${PREFIX:-$HOME/.local}"

need() { command -v "$1" >/dev/null 2>&1 || { echo "error: '$1' is required" >&2; exit 1; }; }
need git
need meson
need ninja
command -v cmake >/dev/null 2>&1 || \
  echo "warning: cmake not found — needed to build libconfig if your system has < 1.7" >&2

echo "==> Cloning $REPO_URL"
rm -rf "$SRC"
git clone --depth 1 --recurse-submodules "$REPO_URL" "$SRC"

cd "$SRC"
echo "==> Configuring (prefix: $PREFIX)"
meson setup build --buildtype=release --prefix="$PREFIX" -Dwith_docs=false

echo "==> Building"
ninja -C build

echo "==> Installing"
ninja -C build install

echo
echo "==> Done. Installed binary:"
command -v picom
picom --version | head -1

cat <<'EOF'

Note: make sure ~/.local/bin is before /usr/bin in your PATH so that
`picom` resolves to this build (it usually is on most distros).
To revert, delete ~/.local/bin/picom (the distro picom remains in /usr/bin).
EOF
