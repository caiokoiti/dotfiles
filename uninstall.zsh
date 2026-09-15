#!/usr/bin/env zsh

set -euo pipefail

# Source the configuration file
SCRIPT_DIR="${0:a:h}"
source "$SCRIPT_DIR/config.zsh"

# ── Helpers ───────────────────────────────────────────────────────────────────

confirm_uninstall() {
  echo "This will remove all custom dotfiles configuration."
  read -q "REPLY?Are you sure you want to proceed? (y/n) "
  echo ""
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Uninstallation cancelled."
    exit 0
  fi
}

# Removes the DOTFILES_START...DOTFILES_END block from ~/.zshrc.
# Also handles the legacy format written by older versions of install.zsh.
remove_source_from_zshrc() {
  echo "Removing dotfiles source block from $ZSHRC_PATH"

  # New format: sentinel-delimited block
  if grep -q "# DOTFILES_START" "$ZSHRC_PATH" 2>/dev/null; then
    sed -i '' '/# DOTFILES_START/,/# DOTFILES_END/d' "$ZSHRC_PATH"
    echo "Removed dotfiles source block (new format)"
    return
  fi

  # Legacy format: individual lines written by older install.zsh
  sed -i '' "/# Source custom dotfiles configuration/d" "$ZSHRC_PATH"
  sed -i '' "/# To uninstall run:.*uninstall/d" "$ZSHRC_PATH"
  sed -i '' "/\[ -f.*extended_zshrc.zsh \] && source/d" "$ZSHRC_PATH"
  sed -i '' "/if \[\[.*extended_zshrc/,/^fi$/d" "$ZSHRC_PATH"
  echo "Removed dotfiles source block (legacy format)"
}

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

restore_backup() {
  local latest_backup
  latest_backup=$(find "$HOME_DIR/.dotfiles_backup" -type d -name "2*" | sort -r | head -n 1)

  if [[ -z "$latest_backup" || ! -d "$latest_backup" ]]; then
    echo "No backup found to restore"
    return
  fi

  local file_count
  file_count=$(ls "$latest_backup" 2>/dev/null | wc -l | tr -d ' ')

  if [[ "$file_count" -eq 0 ]]; then
    echo "Backup at $latest_backup is empty — nothing to restore"
    return
  fi

  echo "Found backup at $latest_backup ($file_count files)"
  read -q "REPLY?Would you like to restore the backup? (y/n) "
  echo ""

  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Restoring backup..."

    if [[ -f "$latest_backup/.zshrc" ]]; then
      cp "$latest_backup/.zshrc" "$ZSHRC_PATH"
      echo "Restored .zshrc from backup"
    fi

    for link in "${SYMLINK_FILES[@]}"; do
      local dest="${link##*:}"
      local backup_path="$latest_backup/$(basename "$dest")"

      if [[ -f "$backup_path" ]]; then
        cp "$backup_path" "$dest"
        echo "Restored $(basename "$dest") from backup"
      fi
    done

    echo "Backup restoration complete"
  fi
}

# ── Main ──────────────────────────────────────────────────────────────────────

uninstall() {
  echo "Starting uninstallation of custom dotfiles..."

  confirm_uninstall
  remove_source_from_zshrc
  remove_symlinks
  restore_backup

  echo "Uninstallation complete!"
}

uninstall
