#!/usr/bin/env bash
# Base CLI tools, compilers and build dependencies from apt.
set -euo pipefail
. "$(dirname "$0")/../lib.sh"

log "PPAs: latest git, diff-so-fancy"
apt_install software-properties-common curl wget gpg ca-certificates
sudo add-apt-repository -y -n ppa:git-core/ppa
sudo add-apt-repository -y -n ppa:aos1/diff-so-fancy

log "Kitware apt repo: latest CMake"
sudo install -d -m 0755 /etc/apt/keyrings
curl -fsSL https://apt.kitware.com/keys/kitware-archive-latest.asc |
	sudo gpg --dearmor --yes -o /etc/apt/keyrings/kitware.gpg
echo "deb [signed-by=/etc/apt/keyrings/kitware.gpg] https://apt.kitware.com/ubuntu/ $(. /etc/os-release && echo "$VERSION_CODENAME") main" |
	sudo tee /etc/apt/sources.list.d/kitware.list >/dev/null

log "apt upgrade"
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

log "Base packages"
apt_install \
	git git-lfs zsh tmux vim xclip wl-clipboard tree unzip zip xz-utils jq htop \
	ripgrep fd-find diff-so-fancy gh neofetch figlet lolcat xxd rsync \
	inotify-tools file pandoc nmap iperf3 \
	build-essential gcc g++ gcc-multilib g++-multilib make cmake ninja-build \
	pkg-config ccache gdb bison gperf \
	python3 python3-pip python3-venv python3-setuptools python3-wheel pipx \
	ruby-dev \
	flameshot zathura dconf-editor
