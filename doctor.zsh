#!/usr/bin/env zsh

# doctor.zsh — Health check for the dotfiles installation.
# Reports what's working, what's missing, and what needs attention.

SCRIPT_DIR="${0:a:h}"
source "$SCRIPT_DIR/config.zsh"

# ── Output helpers ────────────────────────────────────────────────────────────

_ok()   { printf "  \033[32m✓\033[0m  %s\n" "$1" }
_warn() { printf "  \033[33m!\033[0m  %s\n" "$1" }
_fail() { printf "  \033[31m✗\033[0m  %s\n" "$1" }
_info() { printf "      \033[2m%s\033[0m\n" "$1" }
_section() { printf "\n\033[1m%s\033[0m\n" "$1" }

ISSUES=0

_issue() {
  _fail "$1"
  (( ISSUES++ ))
}

# ── Checks ────────────────────────────────────────────────────────────────────

check_zshrc() {
  _section "~/.zshrc"

  if grep -q "DOTFILES_START" "$ZSHRC_PATH" 2>/dev/null; then
    _ok "Dotfiles source block present (new format)"
  elif grep -q "extended_zshrc" "$ZSHRC_PATH" 2>/dev/null; then
    _warn "Dotfiles source present (legacy format) — re-run install.zsh to upgrade"
  else
    _issue "Dotfiles source block missing from $ZSHRC_PATH"
    _info "Fix: ./install.zsh"
  fi
}

check_symlinks() {
  _section "Symlinks"

  for link in "${SYMLINK_FILES[@]}"; do
    local src="${link%%:*}"
    local dest="${link##*:}"

    if [[ -L "$dest" ]]; then
      local target=""
      target=$(readlink "$dest") 2>/dev/null
      if [[ "$target" == "$src" ]]; then
        _ok "$dest"
      else
        _issue "$dest points to wrong target"
        _info "Expected: $src"
        _info "Got:      $target"
        _info "Fix: ./install.zsh"
      fi
    elif [[ -f "$dest" ]]; then
      _issue "$dest exists but is not a symlink"
      _info "Fix: ./install.zsh"
    else
      _issue "$dest is missing"
      _info "Fix: ./install.zsh"
    fi
  done
}

check_tools() {
  _section "Tools"

  local tools=(
    "brew:Homebrew"
    "starship:Starship prompt"
    "hx:Helix editor"
    "fzf:fzf fuzzy finder"
    "fd:fd (find replacement)"
    "rg:ripgrep"
    "bat:bat (cat replacement)"
    "zoxide:zoxide"
    "direnv:direnv"
    "lazygit:lazygit"
    "lazydocker:lazydocker"
    "just:just"
    "n:n (Node version manager)"
  )

  for entry in $tools; do
    local cmd="${entry%%:*}"
    local name="${entry##*:}"
    if command -v "$cmd" >/dev/null 2>&1; then
      _ok "$name ($cmd)"
    else
      _issue "$name not found ($cmd)"
      _info "Fix: brew install $cmd  or  ./install.zsh"
    fi
  done
}

check_iterm2() {
  _section "iTerm2"

  local pref_folder
  pref_folder=$(defaults read com.googlecode.iterm2 PrefsCustomFolder 2>/dev/null)
  local load_from_custom
  load_from_custom=$(defaults read com.googlecode.iterm2 LoadPrefsFromCustomFolder 2>/dev/null)

  if [[ "$pref_folder" == "$DOTFILES_DIR/iterm2" && "$load_from_custom" == "1" ]]; then
    _ok "Loading preferences from $DOTFILES_DIR/iterm2"
  elif [[ -n "$pref_folder" ]]; then
    _issue "iTerm2 loading preferences from wrong path"
    _info "Expected: $DOTFILES_DIR/iterm2"
    _info "Got:      $pref_folder"
    _info "Fix: ./install.zsh"
  else
    _issue "iTerm2 not configured to load from dotfiles"
    _info "Fix: ./install.zsh"
  fi

  if [[ -f "$DOTFILES_DIR/iterm2/com.googlecode.iterm2.plist" ]]; then
    _ok "com.googlecode.iterm2.plist present in repo"
  else
    _warn "com.googlecode.iterm2.plist missing from repo"
    _info "Fix: cp ~/Library/Preferences/com.googlecode.iterm2.plist $DOTFILES_DIR/iterm2/"
  fi
}

check_zsh_cache() {
  _section "Zsh cache (~/.zsh_cache)"

  local cache_dir="$HOME/.zsh_cache"
  if [[ ! -d "$cache_dir" ]]; then
    _warn "Cache directory missing — will be created on next shell startup"
    return
  fi

  local tools=("starship" "direnv" "zoxide" "fzf")
  for tool in $tools; do
    if [[ -f "$cache_dir/$tool.zsh" ]]; then
      _ok "$tool.zsh cached"
    else
      _warn "$tool.zsh not cached yet — will be generated on next shell startup"
    fi
  done
}

check_backups() {
  _section "Backups (~/.dotfiles_backup)"

  local backup_count
  backup_count=$(find "$HOME/.dotfiles_backup" -maxdepth 1 -type d -name "2*" 2>/dev/null | wc -l | tr -d ' ')

  if [[ "$backup_count" -eq 0 ]]; then
    _warn "No backups found"
    return
  fi

  local latest
  latest=$(find "$HOME/.dotfiles_backup" -maxdepth 1 -type d -name "2*" | sort -r | head -n 1)
  local file_count
  file_count=$(ls "$latest" 2>/dev/null | wc -l | tr -d ' ')

  _ok "$backup_count backup(s) found"
  if [[ "$file_count" -gt 0 ]]; then
    _ok "Latest backup ($latest:t) has $file_count file(s)"
  else
    _warn "Latest backup ($latest:t) is empty"
    _info "This is normal if install ran when symlinks were already in place"
  fi
}

check_work_dotfiles() {
  _section "Work dotfiles"

  if [[ -d "$HOME/dotfiles-work" ]]; then
    _ok "~/dotfiles-work exists"
    if [[ -f "$HOME/dotfiles-work/init.zsh" ]]; then
      _ok "init.zsh present"
    else
      _issue "init.zsh missing from ~/dotfiles-work"
    fi
    if [[ -x "$HOME/dotfiles-work/bin/dab" ]]; then
      _ok "bin/dab is executable"
    else
      _issue "bin/dab missing or not executable"
    fi
  else
    _info "~/dotfiles-work not present (personal machine — OK)"
  fi
}

# ── Summary ───────────────────────────────────────────────────────────────────

run_doctor() {
  echo "\033[1mdotfiles doctor\033[0m"
  echo "Checking installation health...\n"

  check_zshrc
  check_symlinks
  check_tools
  check_iterm2
  check_zsh_cache
  check_backups
  check_work_dotfiles

  echo ""
  if [[ "$ISSUES" -eq 0 ]]; then
    printf "\033[32mAll checks passed.\033[0m\n"
  else
    printf "\033[31m$ISSUES issue(s) found.\033[0m Run the fixes above to resolve them.\n"
  fi
}

run_doctor 2>/dev/null