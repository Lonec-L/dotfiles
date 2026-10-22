# Shared between the Ubuntu work PC and the Arch home PC. Anything that only
# exists on one machine is guarded, so a missing tool never breaks the shell.
# Machine-specific or private settings go in ~/.zshrc.local (not in this repo).

# --- PATH ---------------------------------------------------------------------
fpath+=${ZDOTDIR:-~}/.zsh_functions
export PATH="$HOME/.local/bin:$PATH"
[[ -d /opt/nvim ]] && export PATH="$PATH:/opt/nvim"
[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"
[[ -d /usr/local/go/bin ]] && export PATH="/usr/local/go/bin:$PATH"
[[ -d "$HOME/go/bin" ]] && export PATH="$PATH:$HOME/go/bin"
command -v ruby >/dev/null && export PATH="$(ruby -e 'print Gem.user_dir')/bin:$PATH"

# --- Aliases ------------------------------------------------------------------
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias sl="ls"
alias python="python3"
alias pip="pip3"
alias vimdiff='nvim -d'
alias f="fvm flutter"
alias d="fvm dart"
# Ubuntu ships fd as fdfind
command -v fd >/dev/null || { command -v fdfind >/dev/null && alias fd='fdfind'; }

# --- Oh My Zsh ----------------------------------------------------------------
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=()
[[ -f $ZSH/oh-my-zsh.sh ]] && source $ZSH/oh-my-zsh.sh

unsetopt share_history      # don't pull other shells' commands into this one live
setopt inc_append_history   # still write every command to ~/.histfile right away
setopt hist_ignore_all_dups hist_reduce_blanks

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
    export EDITOR='vim'
else
    export EDITOR="nvim"
    export VISUAL="nvim"
    export SUDO_EDITOR="nvim"
fi

# --- History / keys -----------------------------------------------------------
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
bindkey -v

# --- Language version managers ------------------------------------------------
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
command -v pyenv >/dev/null && eval "$(pyenv init - zsh)"

# --- fzf ----------------------------------------------------------------------
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
command -v fzf >/dev/null && source <(fzf --zsh)

bindkey -s ^F "tmux-sessionizer\n"

# --- ROS 2 (Ubuntu work PC) ---------------------------------------------------
if [[ -f /opt/ros/jazzy/setup.zsh ]]; then
    source /opt/ros/jazzy/setup.zsh
    if command -v register-python-argcomplete >/dev/null; then
        eval "$(register-python-argcomplete ros2)"
        eval "$(register-python-argcomplete colcon)"
    fi
    alias ugv-rviz='rviz2 -d ~/.config/ugv/ugv.rviz'
    alias ugv-nav='rviz2 -d ~/.config/ugv/ugv_nav.rviz'
fi

# --- Local overrides (not tracked) --------------------------------------------
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
