#!/usr/bin/env bash
# zsh + Oh My Zsh (with autosuggestions and syntax highlighting), fzf, tmux
# plugin manager. Run after link.sh so the tmux plugins in ~/.tmux.conf get installed.
set -euo pipefail
. "$(dirname "$0")/../lib.sh"

log "Oh My Zsh"
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
	# KEEP_ZSHRC: our .zshrc is already linked, do not let the installer replace it.
	RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c \
		"$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

log "Oh My Zsh plugins: autosuggestions, syntax highlighting"
zsh_custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
git_clone_or_pull https://github.com/zsh-users/zsh-autosuggestions "$zsh_custom/plugins/zsh-autosuggestions" --depth 1
git_clone_or_pull https://github.com/zsh-users/zsh-syntax-highlighting "$zsh_custom/plugins/zsh-syntax-highlighting" --depth 1

log "fzf"
git_clone_or_pull https://github.com/junegunn/fzf.git "$HOME/.fzf" --depth 1
"$HOME/.fzf/install" --key-bindings --completion --no-update-rc --no-bash --no-fish

log "tmux plugin manager + plugins"
git_clone_or_pull https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
"$HOME/.tmux/plugins/tpm/bin/install_plugins" || warn "tpm: open tmux and press prefix + I"

if [[ "$(getent passwd "$USER" | cut -d: -f7)" != "$(command -v zsh)" ]]; then
	log "Default shell -> zsh"
	sudo chsh -s "$(command -v zsh)" "$USER"
fi
