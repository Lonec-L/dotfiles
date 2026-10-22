#!/usr/bin/env bash
# Set up a fresh Ubuntu machine from this repo.
#
# Usage:
#   ./install.sh                 run every step in order
#   ./install.sh 30-dev 40-neovim  run only the named steps
#   ./install.sh --list          list the steps
#   ASSUME_YES=1 ./install.sh    answer yes to every optional prompt
#
# On Arch only ./link.sh is supported for now.
set -euo pipefail
. "$(dirname "$0")/scripts/lib.sh"

STEPS_DIR="$DOTFILES/scripts/ubuntu"

[[ "$(distro_id)" == "ubuntu" ]] || die "install.sh supports Ubuntu only. On other distros run ./link.sh"
[[ $EUID -ne 0 ]] || die "run as your normal user, not root (sudo is used where needed)"

if [[ "${1:-}" == "--list" ]]; then
	for f in "$STEPS_DIR"/*.sh; do
		printf '%-14s %s\n' "$(basename "$f" .sh)" "$(sed -n '2s/^# //p' "$f")"
	done
	exit 0
fi

steps=("$@")
if ((${#steps[@]} == 0)); then
	for f in "$STEPS_DIR"/*.sh; do steps+=("$(basename "$f" .sh)"); done
fi

# Ask everything interactive up front, so the rest can run unattended
setup_git_identity
export GIT_IDENTITY_SET=1
sudo -v

for step in "${steps[@]}"; do
	script="$STEPS_DIR/${step%.sh}.sh"
	[[ -f "$script" ]] || die "unknown step: $step (see ./install.sh --list)"
	log "Step $step"
	bash "$script"
	# Configs must be linked before the shell step installs tmux plugins.
	[[ "$step" == 00-base ]] && bash "$DOTFILES/link.sh"
done

log "All done. Log out and back in (default shell, docker and dialout groups)."
