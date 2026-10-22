#!/usr/bin/env bash
# Niri + DankMaterialShell from the DankLinux PPAs (Ubuntu 26.04+ only).
set -euo pipefail
. "$(dirname "$0")/../lib.sh"

MIN_UBUNTU="26.04"

if ! ubuntu_at_least "$MIN_UBUNTU"; then
	warn "skipping niri: the DankLinux PPAs need Ubuntu $MIN_UBUNTU or newer"
	exit 0
fi

log "DankLinux PPAs (niri, DankMaterialShell and their dependencies)"
sudo add-apt-repository -y -n ppa:avengemedia/danklinux
sudo add-apt-repository -y -n ppa:avengemedia/dms
sudo apt-get update

log "niri, dms and the tools the niri config launches"
apt_install niri dms swaylock fuzzel brightnessctl waybar wireplumber
# Runs X11 apps under niri, install it if this release packages it
if apt-cache show xwayland-satellite >/dev/null 2>&1; then
	apt_install xwayland-satellite
fi

log "Linking niri and swaylock configs"
bash "$DOTFILES/link.sh"

warn "log out and pick 'Niri' on the login screen to use it"
