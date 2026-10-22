#!/usr/bin/env bash
# Neovim (latest stable release tarball in /opt) and its plugins. The config
# itself is nvim/ in this repo, linked to ~/.config/nvim by link.sh.
set -euo pipefail
. "$(dirname "$0")/../lib.sh"

NVIM_DIR="/opt/nvim-linux-x86_64"

log "Neovim (stable)"
tmp="$(mktemp -d)"
curl -fsSL -o "$tmp/nvim.tar.gz" \
	https://github.com/neovim/neovim/releases/download/stable/nvim-linux-x86_64.tar.gz
sudo rm -rf "$NVIM_DIR"
sudo tar -C /opt -xzf "$tmp/nvim.tar.gz"
sudo ln -sf "$NVIM_DIR/bin/nvim" /usr/local/bin/nvim
rm -rf "$tmp"
nvim --version | head -1

[[ "$(readlink "$HOME/.config/nvim")" == "$DOTFILES/nvim" ]] ||
	die "$HOME/.config/nvim is not linked to this repo, run ./link.sh first"

log "Installing plugins (headless)"
nvim --headless "+Lazy! sync" +qa || warn "Lazy sync failed, open nvim and run :Lazy sync"
