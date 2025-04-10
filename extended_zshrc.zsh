#!/usr/bin/env zsh

set -e

# Source the config file to get DOTFILES_DIR and other constants
SCRIPT_DIR="${0:a:h}"
source "$SCRIPT_DIR/config.zsh"

# Add custom bin directory to PATH
export PATH="$PATH:$DOTFILES_DIR/bin"

# Source custom aliases
[ -f "$ALIASES_FILE" ] && source "$ALIASES_FILE"

# Source custom functions
[ -f "$FUNCTIONS_FILE" ] && source "$FUNCTIONS_FILE"

# History settings
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
HIST_STAMPS="dd-mm-yyyy"

setopt EXTENDED_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt SHARE_HISTORY
setopt AUTO_MENU

# Replace cat with bat if available
if command -v bat >/dev/null 2>&1; then
    alias cat='bat -p'
fi

# Language & Encoding
export LANG=en_AU.UTF-8
export LC_ALL=en_AU.UTF-8
export TZ='Australia/Perth'

# Editor
export EDITOR='nvim'
export VISUAL='nvim'

# Colors
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad

# BAT Theme
export BAT_THEME="Dracula"

# Homebrew path (dynamic for ARM and Intel Macs)
if [[ -d /opt/homebrew/bin ]]; then
    # ARM Macs
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -d /usr/local/Homebrew/bin ]]; then
    # Intel Macs
    eval "$(/usr/local/Homebrew/bin/brew shellenv)"
fi

# N Node Version Manager
export N_PREFIX="$HOME/.n"
export PATH="$N_PREFIX/bin:$PATH"

# Ripgrep config
export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"


# FD config
export FD_OPTIONS="--follow --exclude .git --exclude node_modules"

# Initialize tools if available
if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
    # Prompt customization handled via ~/.config/starship.toml (symlinked by install.sh)
fi

if command -v direnv >/dev/null 2>&1; then
    eval "$(direnv hook zsh)"
fi

if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
fi

# FZF setup
if command -v fzf >/dev/null 2>&1; then
    source <(fzf --zsh)
    # Customize fzf defaults
    export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"
    export FZF_DEFAULT_COMMAND="fd --type f $FD_OPTIONS"
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    # Custom key bindings
    bindkey '^R' fzf-history-widget  # Ctrl+R for history search
    bindkey '^T' fzf-file-widget     # Ctrl+T for file search (default)
fi

# Autocompletion with performance optimization
autoload -Uz compinit
if [[ ! -f ~/.zcompdump || $(find ~/.zcompdump -mtime +1) ]]; then
    compinit
else
    compinit -C  # Skip checking if cache is fresh (faster)
fi

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

echo "Custom dotfiles loaded successfully"