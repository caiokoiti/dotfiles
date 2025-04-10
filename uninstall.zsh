#!/usr/bin/env zsh

set -e

# Source the configuration file
SCRIPT_DIR="${0:a:h}"
source "$SCRIPT_DIR/config.zsh"

# Function to confirm uninstallation
confirm_uninstall() {
  echo "This will remove all custom dotfiles configuration."
  read -q "REPLY?Are you sure you want to proceed? (y/n) "
  echo ""
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Uninstallation cancelled."
    exit 0
  fi
}

# Function to remove source line from .zshrc
remove_source_from_zshrc() {
  echo "Removing source line from $ZSHRC_PATH"
  sed -i '' "/# Source custom dotfiles configuration/d" "$ZSHRC_PATH"
  sed -i '' "/# To uninstall run: $DOTFILES_DIR\/uninstall.sh/d" "$ZSHRC_PATH"
  sed -i '' "/\[ -f $EXTENDED_ZSHRC \] && source $EXTENDED_ZSHRC/d" "$ZSHRC_PATH"
  echo "Removed custom dotfiles source from .zshrc"
}

# Function to remove symlinks
remove_symlinks() {
  echo "Removing symlinks..."
  
  for link in "${SYMLINK_FILES[@]}"; do
    local dest="${link##*:}"
    
    if [[ -L "$dest" ]]; then
      echo "Removing symlink: $dest"
      rm "$dest"
    fi
  done
}

# Function to restore most recent backup if available
restore_backup() {
  local latest_backup=$(find "$HOME_DIR/.dotfiles_backup" -type d -name "2*" | sort -r | head -n 1)
  
  if [[ -d "$latest_backup" ]]; then
    echo "Found backup at $latest_backup"
    read -q "REPLY?Would you like to restore the backup? (y/n) "
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      echo "Restoring backup..."
      
      # Restore .zshrc if it exists in backup
      if [[ -f "$latest_backup/.zshrc" ]]; then
        cp "$latest_backup/.zshrc" "$ZSHRC_PATH"
        echo "Restored .zshrc from backup"
      fi
      
      # Restore other configuration files as needed
      for link in "${SYMLINK_FILES[@]}"; do
        local dest="${link##*:}"
        local backup_file="$latest_backup/$(basename "$dest")"
        
        if [[ -f "$backup_file" ]]; then
          cp "$backup_file" "$dest"
          echo "Restored $(basename "$dest") from backup"
        fi
      done
      
      echo "Backup restoration complete"
    fi
  else
    echo "No backup found to restore"
  fi
}

# Main uninstallation function
uninstall() {
  echo "Starting uninstallation of custom dotfiles..."
  
  # Confirm uninstallation
  confirm_uninstall
  
  # Remove source line from .zshrc
  remove_source_from_zshrc
  
  # Remove symlinks
  remove_symlinks
  
  # Offer to restore backup
  restore_backup
  
  echo "Uninstallation complete!"
}

# Run uninstallation
uninstall