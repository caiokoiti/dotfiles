#!/bin/bash

DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BACKUP_ROOT="$HOME/.config/_backup"

# Function to list available backups
list_backups() {
    if [ -d "$BACKUP_ROOT" ]; then
        echo "Available backups:"
        ls -t "$BACKUP_ROOT" | while read -r backup; do
            local backup_date=$(echo "$backup" | cut -c1-8)
            local backup_time=$(echo "$backup" | cut -c10-15)
            local formatted_date=$(date -j -f "%Y%m%d" "$backup_date" "+%B %d, %Y")
            local formatted_time=$(echo "$backup_time" | sed 's/\(..\)\(..\)\(..\)/\1:\2:\3/')
            local file_count=$(find "$BACKUP_ROOT/$backup" -type f -not -name 'backup.log' | wc -l | tr -d ' ')
            echo "  $backup - $formatted_date $formatted_time ($file_count files)"
        done
    else
        echo "No backups found in $BACKUP_ROOT"
        exit 1
    fi
}

# Function to restore a specific file from backup
restore_file() {
    local backup_dir="$1"
    local file="$2"
    local target="$HOME/${file#.config/_backup/*/}"
    
    if [ -f "$backup_dir/$file" ]; then
        mkdir -p "$(dirname "$target")"
        cp -p "$backup_dir/$file" "$target"
        echo "✓ Restored: $target"
        return 0
    else
        echo "→ Skip: $file (not found in backup)"
        return 1
    fi
}

# Function to restore a specific backup
restore_backup() {
    local backup_dir="$1"
    local specific_file="$2"
    
    if [ ! -d "$backup_dir" ]; then
        echo "Error: Backup directory not found: $backup_dir"
        exit 1
    fi
    
    # Read backup log
    if [ -f "$backup_dir/backup.log" ]; then
        echo "Restoring from backup created at: $(head -n 1 "$backup_dir/backup.log" | cut -d 'at' -f2-)"
    fi
    
    # If a specific file is requested, restore only that
    if [ -n "$specific_file" ]; then
        if [ -f "$backup_dir/$specific_file" ]; then
            restore_file "$backup_dir" "$specific_file"
        else
            echo "Error: File $specific_file not found in backup"
            exit 1
        fi
        return
    fi
    
    # Otherwise restore all files from backup
    echo "Starting restoration..."
    find "$backup_dir" -type f -not -name 'backup.log' | while read -r file; do
        local relative_file=${file#$backup_dir/}
        restore_file "$backup_dir" "$relative_file"
    done
    
    echo "Restoration complete!"
}

# Main script
case "$1" in
    "list")
        list_backups
        ;;
    "restore")
        if [ -z "$2" ]; then
            echo "Usage:"
            echo "  $0 restore <backup-timestamp> [specific-file]"
            echo "  $0 list                    # List available backups"
            echo ""
            list_backups
            exit 1
        fi
        
        backup_dir="$BACKUP_ROOT/$2"
        restore_backup "$backup_dir" "$3"
        ;;
    *)
        echo "Usage:"
        echo "  $0 list                    # List available backups"
        echo "  $0 restore <backup-timestamp> [specific-file]"
        echo ""
        echo "Examples:"
        echo "  $0 list"
        echo "  $0 restore 20250218_123456"
        echo "  $0 restore 20250218_123456 .zshrc"
        ;;
esac