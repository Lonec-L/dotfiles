#!/usr/bin/env bash
# JetBrains Mono (from this repo) and JetBrainsMono Nerd Font (for nvim icons).
set -euo pipefail
. "$(dirname "$0")/../lib.sh"

NERD_FONTS_VERSION="v3.4.0"
FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"

log "JetBrains Mono"
cp "$DOTFILES"/JetBrainsMono-2.304/fonts/ttf/*.ttf "$FONT_DIR/"

log "JetBrainsMono Nerd Font $NERD_FONTS_VERSION"
if ! fc-list | grep -q "JetBrainsMono Nerd Font"; then
	tmp="$(mktemp -d)"
	curl -fsSL -o "$tmp/font.tar.xz" \
		"https://github.com/ryanoasis/nerd-fonts/releases/download/$NERD_FONTS_VERSION/JetBrainsMono.tar.xz"
	mkdir -p "$FONT_DIR/JetBrainsMonoNerd"
	tar -xf "$tmp/font.tar.xz" -C "$FONT_DIR/JetBrainsMonoNerd"
	rm -rf "$tmp"
fi

fc-cache -f
