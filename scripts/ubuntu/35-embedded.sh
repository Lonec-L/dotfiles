#!/usr/bin/env bash
# Embedded / firmware tooling: cross compiler, debuggers, serial consoles,
# flashing tools and Zephyr's west.
set -euo pipefail
. "$(dirname "$0")/../lib.sh"

log "Embedded apt packages"
apt_install gcc-arm-none-eabi gdb-multiarch openocd stlink-tools dfu-util \
	minicom picocom tio can-utils device-tree-compiler

log "Serial port access (dialout group)"
if ! id -nG "$USER" | grep -qw dialout; then
	sudo usermod -aG dialout "$USER"
	warn "added $USER to dialout, log out and back in to use serial ports"
fi

log "pipx: west"
pipx list --short 2>/dev/null | grep -q "^west " || pipx install west
