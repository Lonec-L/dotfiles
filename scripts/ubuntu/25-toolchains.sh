#!/usr/bin/env bash
# Newer toolchains than Ubuntu ships: LLVM/clang from apt.llvm.org, Go from
# go.dev, Lua 5.4 + luarocks built from source.
set -euo pipefail
. "$(dirname "$0")/../lib.sh"

LUA_VERSION="5.4.8"
LUAROCKS_VERSION="3.12.2"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

log "LLVM / clang (apt.llvm.org, current stable)"
curl -fsSL -o "$tmp/llvm.sh" https://apt.llvm.org/llvm.sh
llvm_version="$(sed -n 's/^CURRENT_LLVM_STABLE=//p' "$tmp/llvm.sh")"
[[ -n "$llvm_version" ]] || die "could not read the stable LLVM version from llvm.sh"
sudo bash "$tmp/llvm.sh" "$llvm_version" all
# Make the unversioned names (clang, clangd, ...) point at this version
for tool in clang clang++ clangd clang-format clang-tidy lld lldb; do
	[[ -x "/usr/bin/$tool-$llvm_version" ]] &&
		sudo update-alternatives --install "/usr/bin/$tool" "$tool" "/usr/bin/$tool-$llvm_version" 100
done
clang --version | head -1

log "Go (latest from go.dev)"
go_version="$(curl -fsSL 'https://go.dev/VERSION?m=text' | head -1)"
if [[ "$(/usr/local/go/bin/go version 2>/dev/null | awk '{print $3}')" != "$go_version" ]]; then
	curl -fsSL -o "$tmp/go.tar.gz" "https://go.dev/dl/$go_version.linux-amd64.tar.gz"
	sudo rm -rf /usr/local/go
	sudo tar -C /usr/local -xzf "$tmp/go.tar.gz"
fi
/usr/local/go/bin/go version

log "Lua $LUA_VERSION + luarocks $LUAROCKS_VERSION"
apt_install libreadline-dev
if [[ "$(lua -v 2>/dev/null | awk '{print $2}')" != "$LUA_VERSION" ]]; then
	curl -fsSL "https://www.lua.org/ftp/lua-$LUA_VERSION.tar.gz" | tar -xz -C "$tmp"
	make -C "$tmp/lua-$LUA_VERSION" linux
	sudo make -C "$tmp/lua-$LUA_VERSION" install
fi
if ! have luarocks; then
	curl -fsSL "https://luarocks.github.io/luarocks/releases/luarocks-$LUAROCKS_VERSION.tar.gz" | tar -xz -C "$tmp"
	(cd "$tmp/luarocks-$LUAROCKS_VERSION" && ./configure --with-lua-include=/usr/local/include && make && sudo make install)
fi
lua -v
