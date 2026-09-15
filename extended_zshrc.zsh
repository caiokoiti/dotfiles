#!/usr/bin/env zsh

# Source the config file to get DOTFILES_DIR and other constants
SCRIPT_DIR="${0:a:h}"
source "$SCRIPT_DIR/config.zsh"

# Add custom bin directory to PATH
export PATH="$PATH:$DOTFILES_DIR/bin"

# Source custom aliases
[ -f "$ALIASES_FILE" ] && source "$ALIASES_FILE"

# Source custom functions
[ -f "$FUNCTIONS_FILE" ] && source "$FUNCTIONS_FILE"

# ── History ───────────────────────────────────────────────────────────────────
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
HIST_STAMPS="dd-mm-yyyy"

setopt EXTENDED_HISTORY       # Save timestamp + duration with each entry
setopt HIST_IGNORE_ALL_DUPS   # Remove older duplicate entries (subsumes HIST_IGNORE_DUPS)
setopt HIST_REDUCE_BLANKS     # Strip extra whitespace before saving
setopt HIST_VERIFY            # Show expanded !! before executing
setopt SHARE_HISTORY          # Share history across all open sessions
setopt AUTO_MENU              # Show completion menu on second tab

# ── Language & Encoding ───────────────────────────────────────────────────────
export LANG=en_AU.UTF-8
export LC_ALL=en_AU.UTF-8
export TZ='Australia/Perth'

# ── Editor ────────────────────────────────────────────────────────────────────
export EDITOR='hx'
export VISUAL='hx'

# ── Colors ────────────────────────────────────────────────────────────────────
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad
export BAT_THEME="Dracula"

# Replace cat with bat if available
if command -v bat >/dev/null 2>&1; then
    alias cat='bat -p'
fi

# ── Homebrew ──────────────────────────────────────────────────────────────────
# Hardcoded instead of eval "$(brew shellenv)" to avoid a fork on every startup.
# If you reinstall Homebrew or switch architectures, update these values.
if [[ -d /opt/homebrew ]]; then
    # Apple Silicon
    export HOMEBREW_PREFIX="/opt/homebrew"
    export HOMEBREW_CELLAR="/opt/homebrew/Cellar"
    export HOMEBREW_REPOSITORY="/opt/homebrew"
    export PATH="/opt/homebrew/bin:/opt/homebrew/sbin${PATH+:$PATH}"
    export MANPATH="/opt/homebrew/share/man${MANPATH+:$MANPATH}:"
    export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}"
elif [[ -d /usr/local/Homebrew ]]; then
    # Intel
    export HOMEBREW_PREFIX="/usr/local"
    export HOMEBREW_CELLAR="/usr/local/Cellar"
    export HOMEBREW_REPOSITORY="/usr/local/Homebrew"
    export PATH="/usr/local/bin:/usr/local/sbin${PATH+:$PATH}"
    export MANPATH="/usr/local/share/man${MANPATH+:$MANPATH}:"
    export INFOPATH="/usr/local/share/info:${INFOPATH:-}"
fi

# ── Node (n) ──────────────────────────────────────────────────────────────────
export N_PREFIX="$HOME/.n"
export PATH="$N_PREFIX/bin:$PATH"

# ── Ripgrep ───────────────────────────────────────────────────────────────────
export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"

# ── fd ────────────────────────────────────────────────────────────────────────
export FD_OPTIONS="--follow --exclude .git --exclude node_modules"

# ── Tool init cache ───────────────────────────────────────────────────────────
# Each tool's init script is cached in ~/.zsh_cache/ and only regenerated when
# the binary changes (mtime check). This eliminates one fork per tool per
# terminal open — the main source of shell startup delay.
_ZSH_CACHE_DIR="$HOME/.zsh_cache"
[[ -d "$_ZSH_CACHE_DIR" ]] || mkdir -p "$_ZSH_CACHE_DIR"

_load_cached_init() {
    local cmd="$1"          # binary name, e.g. "starship"
    local args="$2"         # init args, e.g. "init zsh"
    local cache="$_ZSH_CACHE_DIR/${cmd}.zsh"
    local bin

    bin="$(command -v "$cmd" 2>/dev/null)" || return 0  # tool not installed — skip silently

    # Regenerate cache if it doesn't exist or the binary is newer than the cache
    if [[ ! -f "$cache" || "$bin" -nt "$cache" ]]; then
        "$bin" $=args > "$cache" 2>/dev/null
    fi

    source "$cache"
}

_load_cached_init "starship" "init zsh"
_load_cached_init "direnv"   "hook zsh"
_load_cached_init "zoxide"   "init zsh"

# ── fzf ───────────────────────────────────────────────────────────────────────
if command -v fzf >/dev/null 2>&1; then
    _fzf_cache="$_ZSH_CACHE_DIR/fzf.zsh"
    _fzf_bin="$(command -v fzf)"
    if [[ ! -f "$_fzf_cache" || "$_fzf_bin" -nt "$_fzf_cache" ]]; then
        fzf --zsh > "$_fzf_cache" 2>/dev/null
    fi
    source "$_fzf_cache"

    export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"
    export FZF_DEFAULT_COMMAND="fd --type f $FD_OPTIONS"
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    bindkey '^R' fzf-history-widget
    bindkey '^T' fzf-file-widget
fi

# ── zsh-autosuggestions ───────────────────────────────────────────────────────
# Suggests commands in grey as you type based on history (fish-style).
# Press → or End to accept the full suggestion, or keep typing to ignore it.
# Uses $HOMEBREW_PREFIX set above — no extra fork needed.
if [[ -f "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
    source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

# ── Work dotfiles fpath (must be before compinit) ─────────────────────────────
# Register completions from ~/dotfiles-work before compinit runs so _dab is
# picked up. The full init.zsh is sourced again after compinit for everything else.
[[ -d "$HOME/dotfiles-work/completions" ]] && fpath=("$HOME/dotfiles-work/completions" $fpath)

# ── Autocompletion ────────────────────────────────────────────────────────────
# Uses zsh glob qualifiers instead of a find subprocess for the mtime check.
autoload -Uz compinit
if [[ ! -f ~/.zcompdump || -n ~/.zcompdump(#qNmh+24) ]]; then
    compinit
else
    compinit -C  # Cache is fresh — skip the slow filesystem scan
fi

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# ── Work dotfiles (private repo, optional) ────────────────────────────────────
# Sourced automatically if ~/dotfiles-work exists. No-op on personal machines.
[ -f "$HOME/dotfiles-work/init.zsh" ] && source "$HOME/dotfiles-work/init.zsh"
