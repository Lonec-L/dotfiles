#!/usr/bin/env bash
# Language toolchains: Rust (rustup + rustfmt, clippy, rust-analyzer; then
# alacritty, eza, git-absorb via cargo), Node via nvm,
# Python via pyenv, and pipx CLI tools.
set -euo pipefail
. "$(dirname "$0")/../lib.sh"

NVM_VERSION="v0.40.3"

log "Rust (rustup)"
if ! have rustup && [[ ! -x "$HOME/.cargo/bin/rustup" ]]; then
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
fi
. "$HOME/.cargo/env"
rustup update stable
rustup component add rustfmt clippy rust-analyzer

log "Alacritty build deps"
apt_install cmake g++ pkg-config libfreetype6-dev libfontconfig1-dev \
	libxcb-xfixes0-dev libxkbcommon-dev python3 desktop-file-utils

log "cargo tools: alacritty eza git-absorb"
for crate in alacritty eza git-absorb; do
	have "$crate" || cargo install --locked "$crate"
done

log "Alacritty desktop entry + terminfo"
if [[ ! -f "$HOME/.local/share/applications/Alacritty.desktop" ]]; then
	tmp="$(mktemp -d)"
	git clone --quiet --depth 1 https://github.com/alacritty/alacritty.git "$tmp/alacritty"
	sudo tic -xe alacritty,alacritty-direct "$tmp/alacritty/extra/alacritty.info"
	mkdir -p "$HOME/.local/share/applications" "$HOME/.local/share/icons/hicolor/scalable/apps" "$HOME/.zsh_functions"
	cp "$tmp/alacritty/extra/logo/alacritty-term.svg" "$HOME/.local/share/icons/hicolor/scalable/apps/Alacritty.svg"
	sed "s|^Exec=alacritty|Exec=$HOME/.cargo/bin/alacritty|; s|^TryExec=alacritty|TryExec=$HOME/.cargo/bin/alacritty|" \
		"$tmp/alacritty/extra/linux/Alacritty.desktop" >"$HOME/.local/share/applications/Alacritty.desktop"
	cp "$tmp/alacritty/extra/completions/_alacritty" "$HOME/.zsh_functions/_alacritty"
	rm -rf "$tmp"
	update-desktop-database "$HOME/.local/share/applications" || true
fi
# Make Alacritty the terminal for Ctrl+Alt+T in GNOME
if have gsettings; then
	gsettings set org.gnome.desktop.default-applications.terminal exec "$HOME/.cargo/bin/alacritty" || true
fi

log "Nautilus: 'Open in Alacritty' instead of 'Open in Terminal'"
if have nautilus; then
	apt_install python3-nautilus
	sudo apt-get purge -y nautilus-extension-gnome-terminal || true
	pip3 install --user --break-system-packages --upgrade nautilus-open-any-terminal
	glib-compile-schemas "$HOME/.local/share/glib-2.0/schemas/"
	gsettings set com.github.stunkymonkey.nautilus-open-any-terminal terminal alacritty
	gsettings set com.github.stunkymonkey.nautilus-open-any-terminal keybindings '<Ctrl><Alt>t'
	gsettings set com.github.stunkymonkey.nautilus-open-any-terminal new-tab true
	nautilus -q 2>/dev/null || true
fi

log "Node (nvm, latest LTS) + tree-sitter CLI"
if [[ ! -d "$HOME/.nvm" ]]; then
	PROFILE=/dev/null bash -c "$(curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh)"
fi
export NVM_DIR="$HOME/.nvm"
set +u
. "$NVM_DIR/nvm.sh"
nvm install --lts
nvm alias default 'lts/*'
set -u
# nvim-treesitter (main branch) needs the tree-sitter CLI to build parsers
have tree-sitter || npm install -g tree-sitter-cli

log "Python (pyenv)"
apt_install libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev \
	libncursesw5-dev tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
if [[ ! -d "$HOME/.pyenv" ]]; then
	curl -fsSL https://pyenv.run | bash
fi

log "pipx tools"
pipx ensurepath >/dev/null
for tool in tldr pre-commit prek grip; do
	pipx list --short 2>/dev/null | grep -q "^$tool " || pipx install "$tool"
done
