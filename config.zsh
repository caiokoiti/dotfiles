# Base directory of the dotfiles repository
export DOTFILES_DIR="${0:a:h}"

# User home directory
export HOME_DIR="$HOME"

# Backup directory for existing configurations
export BACKUP_DIR="$HOME_DIR/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"

# Path to .zshrc
export ZSHRC_PATH="$HOME_DIR/.zshrc"

# Path to extended zsh configuration
export EXTENDED_ZSHRC="$DOTFILES_DIR/extended_zshrc.zsh"

# Path to aliases file
export ALIASES_FILE="$DOTFILES_DIR/aliases.zsh"

# Path to functions file
export FUNCTIONS_FILE="$DOTFILES_DIR/functions.zsh"

# Configuration files to symlink (format: source:destination)
export SYMLINK_FILES=(
  "$DOTFILES_DIR/.config/starship.toml:$HOME_DIR/.config/starship.toml"
  "$DOTFILES_DIR/.config/.ripgreprc:$HOME_DIR/.ripgreprc"
  "$DOTFILES_DIR/.config/ghostty/config:$HOME_DIR/.config/ghostty/config"
  "$DOTFILES_DIR/.config/helix/config.toml:$HOME_DIR/.config/helix/config.toml"
  "$DOTFILES_DIR/.config/helix/languages.toml:$HOME_DIR/.config/helix/languages.toml"
)