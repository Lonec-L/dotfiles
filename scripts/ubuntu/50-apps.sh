#!/usr/bin/env bash
# Optional desktop apps from their official apt repos. Asks per app,
# unless ASSUME_YES=1.
set -euo pipefail
. "$(dirname "$0")/../lib.sh"

KEYRINGS=/etc/apt/keyrings
sudo install -d -m 0755 "$KEYRINGS"
ARCH="$(dpkg --print-architecture)"
CODENAME="$(. /etc/os-release && echo "$VERSION_CODENAME")"

# Usage: add_repo <name> <key url> <deb line without signed-by>
add_repo() {
	local name="$1" key_url="$2" line="$3"
	curl -fsSL "$key_url" | sudo gpg --dearmor --yes -o "$KEYRINGS/$name.gpg"
	echo "deb [arch=$ARCH signed-by=$KEYRINGS/$name.gpg] $line" |
		sudo tee "/etc/apt/sources.list.d/$name.list" >/dev/null
}

if ! have docker && ask "Install Docker Engine?"; then
	add_repo docker https://download.docker.com/linux/ubuntu/gpg \
		"https://download.docker.com/linux/ubuntu $CODENAME stable"
	sudo apt-get update
	apt_install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
	sudo usermod -aG docker "$USER"
	warn "added $USER to docker group, log out and back in"
fi

if ! have code && ask "Install VS Code?"; then
	add_repo vscode https://packages.microsoft.com/keys/microsoft.asc \
		"https://packages.microsoft.com/repos/code stable main"
	sudo apt-get update
	apt_install code
fi

if ! have signal-desktop && ask "Install Signal?"; then
	add_repo signal https://updates.signal.org/desktop/apt/keys.asc \
		"https://updates.signal.org/desktop/apt xenial main"
	sudo apt-get update
	apt_install signal-desktop
fi

if ask "Install VLC and GIMP?"; then
	apt_install vlc gimp
fi
