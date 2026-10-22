#!/usr/bin/env bash
# Optional desktop apps, asked one by one (ASSUME_YES=1 answers yes to all):
# Docker, VS Code, Signal and VLC from their official apt repos, and GIMP as
# the latest official AppImage from gimp.org.
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

# Usage: want <name> <command> -> true when <command> is missing and the user
# says yes. Already installed apps are reported and skipped.
want() {
	if have "$2"; then
		echo "   $1: already installed, skipping"
		return 1
	fi
	ask "   Install $1?"
}

log "Desktop apps"
echo "   Asked one by one: Docker, VS Code, Signal, VLC (apt), and GIMP"
echo "   (latest official AppImage from gimp.org). Installed apps are skipped,"
echo "   except GIMP, which is offered as an update."

log "Optional apps"
if want "Docker Engine" docker; then
	add_repo docker https://download.docker.com/linux/ubuntu/gpg \
		"https://download.docker.com/linux/ubuntu $CODENAME stable"
	sudo apt-get update
	apt_install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
	sudo usermod -aG docker "$USER"
	warn "added $USER to docker group, log out and back in"
fi

if want "VS Code" code; then
	add_repo vscode https://packages.microsoft.com/keys/microsoft.asc \
		"https://packages.microsoft.com/repos/code stable main"
	sudo apt-get update
	apt_install code
fi

if want Signal signal-desktop; then
	add_repo signal https://updates.signal.org/desktop/apt/keys.asc \
		"https://updates.signal.org/desktop/apt xenial main"
	sudo apt-get update
	apt_install signal-desktop
fi

if want VLC vlc; then
	apt_install vlc
fi

# GIMP: latest official AppImage from gimp.org, verified against the SHA256
# published on the downloads page.
# Re-running with "yes" updates it when a new release is out.
install_gimp() {
	apt_install libfuse2t64
	APP_DIR="$HOME/Applications"
	page="$(curl -fsSL https://www.gimp.org/downloads/)"
	gimp_path="$(grep -oE '//download\.gimp\.org/[^"]*-x86_64\.AppImage' <<<"$page" | head -1)"
	gimp_file="${gimp_path##*/}"
	gimp_sha="$(grep -oE "${gimp_file//./\\.}</code>: <kbd>[0-9a-f]{64}" <<<"$page" | grep -oE '[0-9a-f]{64}$' || true)"
	[[ -n "$gimp_path" && -n "$gimp_sha" ]] || die "could not find the GIMP AppImage link or hash on gimp.org"
	gimp="$APP_DIR/$gimp_file"

	if [[ -x "$gimp" ]]; then
		echo "   $gimp_file is already the latest"
	else
		echo "   downloading $gimp_file (about 250 MB)..."
		tmp="$(mktemp -d)"
		curl -fL --progress-bar -o "$tmp/$gimp_file" "https:$gimp_path"
		echo "$gimp_sha  $tmp/$gimp_file" | sha256sum -c --quiet || die "GIMP AppImage hash mismatch"
		chmod +x "$tmp/$gimp_file"
		mkdir -p "$APP_DIR"
		find "$APP_DIR" -maxdepth 1 -name 'GIMP-*-x86_64.AppImage' -delete
		mv "$tmp/$gimp_file" "$gimp"
		rm -rf "$tmp"
		echo "   installed $gimp"
	fi
	mkdir -p "$HOME/.local/bin"
	ln -sf "$gimp" "$HOME/.local/bin/gimp"

	# Menu entry and icon, taken from the AppImage. GIMP's window reports the
	# Wayland app id "gimp", so the entry must be gimp.desktop for the dock to
	# match the running window to its icon.
	tmp="$(mktemp -d)"
	(cd "$tmp" && "$gimp" --appimage-extract 'usr/share/applications/*' >/dev/null &&
		"$gimp" --appimage-extract 'org.gimp.GIMP.Stable.svg' >/dev/null)
	mkdir -p "$HOME/.local/share/applications" "$HOME/.local/share/icons/hicolor/scalable/apps"
	cp "$tmp/squashfs-root/org.gimp.GIMP.Stable.svg" "$HOME/.local/share/icons/hicolor/scalable/apps/"
	sed "s|^Exec=org.gimp.GIMP.Stable|Exec=$gimp|; s|^TryExec=.*|TryExec=$gimp|; s|^StartupWMClass=.*|StartupWMClass=gimp|" \
		"$tmp/squashfs-root/usr/share/applications/org.gimp.GIMP.Stable.desktop" \
		>"$HOME/.local/share/applications/gimp.desktop"
	rm -f "$HOME/.local/share/applications/org.gimp.GIMP.Stable.desktop"
	update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
	rm -rf "$tmp"
	echo "   menu entry: ~/.local/share/applications/gimp.desktop"

	# Drop the old 2.10 apt package so `gimp` and file associations use the AppImage
	if dpkg -s gimp >/dev/null 2>&1; then
		echo "   removing the apt gimp 2.10 package"
		sudo apt-get purge -y -qq gimp gimp-data >/dev/null
	fi
}

log "GIMP"
if have gimp; then
	gimp_question="Update GIMP to the latest official AppImage (if newer)?"
else
	gimp_question="Install GIMP (latest official AppImage, replaces apt GIMP 2.10)?"
fi
if ask "   $gimp_question"; then
	install_gimp
else
	echo "   GIMP: skipped"
fi
