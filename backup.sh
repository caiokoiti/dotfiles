#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Log file (can be overridden by caller)
LOG_FILE="${LOG_FILE:-$HOME/backup_$(date +%Y%m%d_%H%M%S).log}"

# Log function
log() { echo "$1" | tee -a "$LOG_FILE"; }
error() { echo -e "${RED}ERROR: $1${NC}" | tee -a "$LOG_FILE"; exit 1; }

backup_file() {
    local target="$1"
    local backup_suffix=".backup_$(date +%Y%m%d_%H%M%S)"
    
    # Skip if target doesn't exist
    if [ ! -e "$target" ]; then
        return 0
    fi
    
    # Skip if target is already a symlink
    if [ -L "$target" ]; then
        log "Skipping backup of $target (already a symlink)"
        return 0
    fi
    
    # Check write permissions
    if [ ! -w "$(dirname "$target")" ]; then
        error "No write permission for backup at $(dirname "$target")"
    fi
    
    local backup_path="${target}${backup_suffix}"
    
    # Handle files and directories differently
    if [ -d "$target" ]; then
        cp -R "$target" "$backup_path" || error "Failed to backup directory $target"
    elif [ -f "$target" ]; then
        cp "$target" "$backup_path" || error "Failed to backup file $target"
    fi
    
    # Verify backup exists
    if [ ! -e "$backup_path" ]; then
        error "Backup verification failed for $target"
    fi
    
    log "Created backup: $target -> $backup_path"
    return 0
}

# If called directly, provide usage
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [ $# -eq 0 ]; then
        echo "Usage: $0 <file_or_directory_to_backup>"
        exit 1
    fi
    backup_file "$1"
fi