#!/usr/bin/env bash
# Remove snap for good and install Firefox from Mozilla's apt repo instead.
set -euo pipefail
. "$(dirname "$0")/../lib.sh"

if dpkg -s snapd >/dev/null 2>&1; then
	log "Removing snap (all snaps, snapd and its dirs)"
	# Purging snapd also removes every installed snap
	sudo systemctl disable --now snapd.socket snapd.service snapd.seeded.service 2>/dev/null || true
	sudo apt-get purge -y --autoremove snapd
	sudo rm -rf /snap /var/snap /var/lib/snapd /var/cache/snapd /usr/lib/snapd "$HOME/snap"
fi

log "Pin snapd so apt never installs it again"
printf 'Package: snapd\nPin: release a=*\nPin-Priority: -10\n' |
	sudo tee /etc/apt/preferences.d/no-snap.pref >/dev/null

log "Firefox from packages.mozilla.org"
sudo install -d -m 0755 /etc/apt/keyrings
curl -fsSL https://packages.mozilla.org/apt/repo-signing-key.gpg |
	sudo tee /etc/apt/keyrings/packages.mozilla.org.asc >/dev/null
echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" |
	sudo tee /etc/apt/sources.list.d/mozilla.list >/dev/null
# Prefer Mozilla's firefox over Ubuntu's snap wrapper package
printf 'Package: *\nPin: origin packages.mozilla.org\nPin-Priority: 1000\n' |
	sudo tee /etc/apt/preferences.d/mozilla.pref >/dev/null
sudo apt-get update
sudo apt-get install -y --allow-downgrades firefox
