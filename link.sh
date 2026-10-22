#!/usr/bin/env bash
# Symlink the configs in this repo into $HOME. Safe to re-run.
# Existing files are moved to <file>.bak.<timestamp>, never deleted.
#
# Usage: ./link.sh [--dry-run]
set -euo pipefail
. "$(dirname "$0")/scripts/lib.sh"

DRY_RUN=0
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=1
STAMP="$(date +%Y%m%d-%H%M%S)"

run() {
	if ((DRY_RUN)); then echo "   [dry-run] $*"; else "$@"; fi
}

# Usage: link <path in repo> <target path>
link() {
	local src="$DOTFILES/$1" dst="$2"
	[[ -e "$src" ]] || die "missing in repo: $1"
	if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
		echo "   ok      $dst"
		return
	fi
	((DRY_RUN)) || mkdir -p "$(dirname "$dst")"
	if [[ -e "$dst" || -L "$dst" ]]; then
		echo "   backup  $dst -> $dst.bak.$STAMP"
		run mv "$dst" "$dst.bak.$STAMP"
	fi
	echo "   link    $dst -> $src"
	run ln -s "$src" "$dst"
}

# install.sh asks for the git author up front and sets GIT_IDENTITY_SET=1.
if ! ((DRY_RUN)) && [[ "${GIT_IDENTITY_SET:-0}" != 1 ]]; then
	setup_git_identity
fi

log "Shell, tmux, git, prettier"
link .zshrc "$HOME/.zshrc"
link .tmux.conf "$HOME/.tmux.conf"
link git/.gitconfig "$HOME/.gitconfig"
link prettier/.prettierrc "$HOME/.prettierrc"
link tmux-sessionizer/tmux-sessionizer "$HOME/.local/bin/tmux-sessionizer"
link tmux-sessionizer/tmux-sessionizer.conf "$HOME/.config/tmux-sessionizer/tmux-sessionizer.conf"

log "Neovim"
link nvim "$HOME/.config/nvim"

log "Alacritty"
link alacritty/alacritty.toml "$HOME/.config/alacritty/alacritty.toml"
link alacritty/tokyo-night.toml "$HOME/.config/alacritty/tokyo-night.toml"
if have git && ! ((DRY_RUN)); then
	git_clone_or_pull https://github.com/alacritty/alacritty-theme "$HOME/.config/alacritty/themes" --depth 1
fi

if [[ "$(distro_id)" == "arch" ]]; then
	log "Arch only: niri, swaylock"
	link niri "$HOME/.config/niri"
	link swaylock "$HOME/.config/swaylock"
fi

log "Done linking"
