# dotfiles

Configs for zsh, tmux, alacritty, git, Neovim and tmux-sessionizer, plus install
scripts for a fresh Ubuntu machine (24.04 and newer). Niri and swaylock are used on
Arch, and on Ubuntu 26.04 and newer.

The Neovim config is in `nvim/`, based on
[kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) (MIT, see `nvim/LICENSE.md`).

## Fresh Ubuntu install

```bash
sudo apt install -y git
git clone https://github.com/Lonec-L/dotfiles.git ~/personal/dotfiles
cd ~/personal/dotfiles
./install.sh
```

Then log out and back in.

`./install.sh` runs every step in `scripts/ubuntu/` in order and links the configs
right after the first step. Every step can be re-run safely.

| Step          | What it does                                                         |
| ------------- | -------------------------------------------------------------------- |
| `00-base`     | apt packages (git, tmux, zsh, ripgrep, fd, build tools), Kitware CMake |
| `05-snap`     | removes snap for good, installs Firefox from Mozilla's apt repo       |
| `10-shell`    | Oh My Zsh, fzf, tmux plugin manager + plugins, zsh as default shell   |
| `20-fonts`    | JetBrains Mono (from this repo) and JetBrainsMono Nerd Font          |
| `25-toolchains` | clang/LLVM from apt.llvm.org, latest Go, Lua 5.4 + luarocks         |
| `30-dev`      | Rust (rustup, rustfmt, clippy, rust-analyzer), zoxide, lazygit, alacritty (+ Nautilus "Open in Alacritty"), eza, git-absorb, nvm + Node LTS, pyenv, pipx tools |
| `35-embedded` | arm-none-eabi gcc, openocd, serial tools, west                        |
| `40-neovim`   | latest stable Neovim in `/opt`, installs plugins and treesitter parsers |
| `50-apps`     | asks for each: Docker, VS Code, Signal, VLC, GIMP (latest official AppImage) |
| `60-niri`     | Ubuntu 26.04+ only: niri + DankMaterialShell from the DankLinux PPAs, swaylock, fuzzel, waybar |

Useful variants:

```bash
./install.sh --list              # show steps
./install.sh 30-dev 40-neovim    # run only some steps
ASSUME_YES=1 ./install.sh        # say yes to every optional app
```

## Only link the configs

```bash
./link.sh --dry-run   # show what would change
./link.sh
```

`link.sh` symlinks each config into `$HOME`. An existing file is moved to
`<file>.bak.<timestamp>`, never deleted. This includes `~/.config/nvim`. It also links
`niri/` and `swaylock/` on Arch, or on Ubuntu once niri is installed.

`install.sh` is Ubuntu only. On Arch, install packages yourself and run `./link.sh`.

## Private and machine-specific settings

These files are not in the repo. Keep secrets and per-machine settings there.

- `~/.gitconfig.local`: git author name and email. `install.sh` and `link.sh` ask for
  them, with your current values as defaults (press Enter to keep).
- `~/.zshrc.local`: tokens, work-only aliases, extra `PATH` entries.
- `~/.config/nvim.local/servers.lua`: per-machine LSP overrides, merged over
  `servers` in `nvim/init.lua`, e.g. `return { clangd = { cmd = { 'my-clangd' } } }`.

## Layout

```
.zshrc  .tmux.conf       shell and tmux
alacritty/               terminal config + tokyo-night theme
git/.gitconfig           git aliases and settings (no identity)
prettier/.prettierrc     global prettier options
nvim/                    Neovim config
tmux-sessionizer/        script + search paths
niri/  swaylock/         Arch, and Ubuntu 26.04+
JetBrainsMono-2.304/     font files
wallpapers/
install.sh  link.sh  scripts/
```
