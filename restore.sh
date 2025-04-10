#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$HOME/dotfiles_restore_$(date +%Y%m%d_%H%M%S).log"

# Source the backup script for shared functions (if needed)
source "$DOTFILES_DIR/backup.sh" || { echo "Failed to source backup.sh"; exit 1; }

log() { echo "$1" | tee -a "$LOG_FILE"; }
error() { echo -e "${RED}ERROR: $1${NC}" | tee -a "$LOG_FILE"; exit 1; }

# Function to list available backups for a specific file
list_backups() {
    local file="$1"
    local backup_pattern="${file}.backup_*"
    local backups_found=false

    log "Available backups for $file:"
    for backup in $backup_pattern; do
        if [ -e "$backup" ]; then
            backups_found=true
            local timestamp=$(echo "$backup" | grep -oE '[0-9]{8}_[0-9]{6}')
            if [ -n "$timestamp" ]; then
                local date_part=$(echo "$timestamp" | cut -c1-8)
                local time_part=$(echo "$timestamp" | cut -c10-15)
                # Portable date parsing
                local formatted_date=$(date -d "$date_part" "+%B %d, %Y" 2>/dev/null || date -jf "%Y%m%d" "$date_part" "+%B %d, %Y")
                local formatted_time=$(echo "$time_part" | sed 's/\(..\)\(..\)\(..\)/\1:\2:\3/')
                log "  $timestamp - $formatted_date $formatted_time"
            fi
        fi
    done

    if [ "$backups_found" = false ]; then
        log "No backups found for $file"
        exit 1
    fi
}

# Function to restore a specific file from a backup
restore_file() {
    local backup_file="$1"
    local target="$2"

    # Check if backup exists
    if [ ! -f "$backup_file" ]; then
        log "→ Skip: $backup_file (not found)"
        return 1
    fi

    # Check write permissions
    if [ ! -w "$(dirname "$target")" ]; then
        error "No write permission for $target"
    fi

    # Backup existing target if it exists
    if [ -e "$target" ]; then
        backup_file "$target"
        log "Backed up existing $target before restoration"
    fi

    # Restore the file
    mkdir -p "$(dirname "$target")"
    cp -p "$backup_file" "$target" || error "Failed to restore $target"
    log "✓ Restored: $target"
}

# Main restore function
restore() {
    local file="$1"
    local timestamp="$2"

    # Validate file
    if [ ! -f "$file" ] && [ ! -d "$file" ]; then
        error "File $file does not exist or is not a regular file/directory"
    fi

    # List backups if no timestamp is provided
    if [ -z "$timestamp" ]; then
        list_backups "$file"
        exit 0
    fi

    # Construct backup file path
    local backup_file="${file}.backup_${timestamp}"

    # Confirm restoration
    log "Restoring $file from backup $timestamp"
    read -p "Proceed? (y/N): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        log "Restoration cancelled"
        exit 0
    fi

    # Restore the file
    restore_file "$backup_file" "$file"
}

# Main script
case "$1" in
    "list")
        if [ -z "$2" ]; then
            error "Usage: $0 list <file>"
        fi
        list_backups "$2"
        ;;
    "restore")
        if [ -z "$2" ] || [ -z "$3" ]; then
            error "Usage: $0 restore <file> <timestamp>"
        fi
        restore "$2" "$3"
        ;;
    *)
        log "Usage:"
        log "  $0 list <file>             # List available backups for a file"
        log "  $0 restore <file> <timestamp>  # Restore a specific file from a backup"
        log ""
        log "Examples:"
        log "  $0 list ~/.zshrc"
        log "  $0 restore ~/.zshrc 20250218_123456"
        exit 1
        ;;
esac

log "${GREEN}Operation completed! Log saved to: $LOG_FILE${NC}"