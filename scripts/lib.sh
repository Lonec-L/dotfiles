#!/usr/bin/env bash
# Shared helpers, sourced by install.sh, link.sh and scripts/ubuntu/*.sh.

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export DOTFILES

log() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }
warn() { printf '\033[1;33m!!  %s\033[0m\n' "$*" >&2; }
die() {
	printf '\033[1;31mxx  %s\033[0m\n' "$*" >&2
	exit 1
}

have() { command -v "$1" >/dev/null 2>&1; }

# Usage: ask "Question?" -> returns 0 on yes. ASSUME_YES=1 answers yes to all.
ask() {
	[[ "${ASSUME_YES:-0}" == 1 ]] && return 0
	local reply
	read -r -p "$1 [y/N] " reply
	[[ "$reply" =~ ^[Yy]$ ]]
}

# Usage: apt_install pkg...  (skips packages that are already installed)
apt_install() {
	local missing=()
	for pkg in "$@"; do
		dpkg -s "$pkg" >/dev/null 2>&1 || missing+=("$pkg")
	done
	((${#missing[@]})) || return 0
	sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "${missing[@]}"
}

# Usage: git_clone_or_pull url dir [extra git clone args...]
git_clone_or_pull() {
	local url="$1" dir="$2"
	shift 2
	if [[ -d "$dir/.git" ]]; then
		git -C "$dir" pull --ff-only --quiet || warn "could not update $dir"
	else
		git clone --quiet "$@" "$url" "$dir"
	fi
}

distro_id() { . /etc/os-release && echo "$ID"; }

# Usage: ubuntu_at_least 26.04 -> true on Ubuntu with VERSION_ID >= 26.04
ubuntu_at_least() {
	[[ "$(distro_id)" == ubuntu ]] &&
		dpkg --compare-versions "$(. /etc/os-release && echo "$VERSION_ID")" ge "$1"
}

# Ask for the git author name and email and store them in ~/.gitconfig.local,
# which is not tracked. Current values are offered as defaults, so pressing
# Enter keeps them. Without a terminal, existing values are kept as they are.
setup_git_identity() {
	local local_cfg="$HOME/.gitconfig.local" name email input
	name="$(git config --file "$local_cfg" user.name 2>/dev/null ||
		git config --global user.name 2>/dev/null || true)"
	email="$(git config --file "$local_cfg" user.email 2>/dev/null ||
		git config --global user.email 2>/dev/null || true)"

	if [[ -t 0 ]]; then
		log "Git author (stored in $local_cfg)"
		read -r -p "   name  [$name]: " input
		name="${input:-$name}"
		read -r -p "   email [$email]: " input
		email="${input:-$email}"
	fi
	if [[ -z "$name" || -z "$email" ]]; then
		warn "no git author set, run: git config --file $local_cfg user.name/user.email"
		return 0
	fi
	git config --file "$local_cfg" user.name "$name"
	git config --file "$local_cfg" user.email "$email"
	echo "   git author: $name <$email>"
}
