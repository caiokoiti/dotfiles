# Source configs
[[ -f ~/.zsh_aliases ]] && source ~/.zsh_aliases
[[ -f ~/.functions.zsh ]] && source ~/.functions.zsh

# History settings
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS

if command -v bat > /dev/null; then
 alias cat="bat"
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

# Initialize Starship
eval "$(starship init zsh)"

# Initialize direnv
eval "$(direnv hook zsh)"

# Initialize zoxide
eval "$(zoxide init zsh)"

# N Node Version Manager
export N_PREFIX="$HOME/.n"
export PATH="$N_PREFIX/bin:$PATH"

# Ripgrep config
export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"

# FD config (if needed)
export FD_OPTIONS="--follow --exclude .git --exclude node_modules"

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)