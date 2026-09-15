#!/usr/bin/env zsh

set -euo pipefail

# Source the configuration file
SCRIPT_DIR="${0:a:h}"
source "$SCRIPT_DIR/config.zsh"

# ── Helpers ───────────────────────────────────────────────────────────────────

create_backup_dir() {
  echo "Creating backup directory at $BACKUP_DIR"
  mkdir -p "$BACKUP_DIR"
}

# Backs up a file whether it's a regular file or a symlink.
# Symlinks are dereferenced — the actual content is copied, not the link.
backup_file() {
  local file=$1
  if [[ -L "$file" ]]; then
    echo "Backing up symlink target: $file"
    cp -L "$file" "$BACKUP_DIR/$(basename "$file")"
  elif [[ -f "$file" ]]; then
    echo "Backing up $file"
    cp "$file" "$BACKUP_DIR/$(basename "$file")"
  fi
}

# Appends the dotfiles source block to ~/.zshrc if not already present.
# Uses a sentinel comment so the block can be reliably removed by uninstall.zsh.
append_source_to_zshrc() {
  if grep -qF "# DOTFILES_START" "$ZSHRC_PATH" 2>/dev/null; then
    echo "Source block already exists in .zshrc"
    return
  fi

  echo "Appending source block to $ZSHRC_PATH"
  cat >> "$ZSHRC_PATH" <<EOF

# DOTFILES_START — managed by $DOTFILES_DIR/install.zsh (remove with uninstall.zsh)
[ -f $EXTENDED_ZSHRC ] && source $EXTENDED_ZSHRC
# DOTFILES_END
EOF
  echo "Added dotfiles source to .zshrc"
}

install_homebrew() {
  if command -v brew &>/dev/null; then
    echo "Homebrew is already installed"
  else
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    if [[ "$(uname -m)" == "arm64" ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    else
      eval "$(/usr/local/bin/brew shellenv)"
    fi

    echo "Homebrew installed successfully"
  fi
}

install_packages() {
  echo "Installing packages..."
  install_homebrew

  echo "Updating Homebrew..."
  brew update

  echo "Installing Homebrew packages..."
  brew bundle --file="$DOTFILES_DIR/Brewfile" || {
    echo "Warning: Some packages in Brewfile failed to install"
  }

  echo "Package installation complete"
}

create_symlinks() {
  echo "Creating symlinks..."

  for link in "${SYMLINK_FILES[@]}"; do
    local src="${link%%:*}"
    local dest="${link##*:}"
    local dest_dir="$(dirname "$dest")"

    if [[ ! -d "$dest_dir" ]]; then
      echo "Creating directory: $dest_dir"
      mkdir -p "$dest_dir"
    fi

    # Backup existing file or symlink before replacing
    backup_file "$dest"

    # Remove existing symlink or file
    [[ -L "$dest" || -f "$dest" ]] && rm "$dest"

    echo "Creating symlink: $src -> $dest"
    ln -s "$src" "$dest"
  done
}

configure_iterm2() {
  echo "Configuring iTerm2 to load preferences from dotfiles..."
  defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$DOTFILES_DIR/iterm2"
  defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
  echo "iTerm2 will load preferences from $DOTFILES_DIR/iterm2"
}

# ── Main ──────────────────────────────────────────────────────────────────────

install() {
  echo "Starting installation of custom dotfiles..."

  create_backup_dir
  backup_file "$ZSHRC_PATH"
  append_source_to_zshrc
  install_homebrew
  install_packages
  create_symlinks
  configure_iterm2

  echo "Installation complete! Open a new terminal for changes to take effect."
}

install
