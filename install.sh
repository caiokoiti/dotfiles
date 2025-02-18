#!/bin/bash

DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Check for macOS
if [[ $(uname) != "Darwin" ]]; then
   echo "This script is for macOS only"
   exit 1
fi

# Install Homebrew if not present
if ! command -v brew >/dev/null 2>&1; then
   echo "Installing Homebrew..."
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   
   if [[ $(uname -m) == 'arm64' ]]; then
       echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
       eval "$(/opt/homebrew/bin/brew shellenv)"
   fi
fi

CORE_UTILS=(
   # System utilities
   "git"
   "tar"
   "gzip"
   "bzip2"
   "unzip"
   "unrar"
   "make"
   "gcc"
   "xclip"
   "ghostty"
)

DEV_TOOLS=(
   # Shell enhancements
   "starship"
   "direnv"
   "zoxide"
   "fzf"
   
   # Search and file tools
   "ripgrep"
   "fd"
   "bat"
   
   # Development
   "n"  # Node version manager
   "neovim"
   "lua"
   "luarocks"
   
   # Fonts
   "font-fira-mono-nerd-font"
   "font-jetbrains-mono-nerd-font"
)

BREW_PACKAGES=("${CORE_UTILS[@]}" "${DEV_TOOLS[@]}")

# Update Homebrew font access
brew tap homebrew/cask-fonts

echo "Checking Homebrew packages..."
for package in "${BREW_PACKAGES[@]}"; do
   if ! brew list $package >/dev/null 2>&1; then
       echo "Installing $package..."
       if [[ $package == font-* ]]; then
           brew install --cask $package
       else
           brew install $package
       fi
   fi
done

# Backup configuration
BACKUP_DIR="$HOME/.config/_backup/$(date +%Y%m%d_%H%M%S)"
BACKUP_LOG="$BACKUP_DIR/backup.log"

# Function to create backup directory and initialize log
init_backup() {
    mkdir -p "$BACKUP_DIR"
    echo "Backup started at $(date)" > "$BACKUP_LOG"
    echo "Source directory: $DOTFILES_DIR" >> "$BACKUP_LOG"
}

# Function to backup files with logging and error handling
backup_file() {
    local file="$1"
    local filename=$(basename "$file")
    
    if [ -e "$file" ]; then
        # Create directory structure if file is in subdirectory
        local relative_path=${file#$HOME/}
        local backup_path="$BACKUP_DIR/$relative_path"
        mkdir -p "$(dirname "$backup_path")"
        
        if [ -L "$file" ]; then
            # If it's a symlink, store both the link and its target
            local target=$(readlink "$file")
            cp -P "$file" "$backup_path"
            echo "SYMLINK: $relative_path -> $target" >> "$BACKUP_LOG"
        else
            # Regular file backup
            cp -p "$file" "$backup_path"
            echo "FILE: $relative_path ($(stat -f %z "$file") bytes)" >> "$BACKUP_LOG"
        fi
        
        # Create local .backup only if it doesn't exist
        if [ ! -f "$file.backup" ]; then
            cp -p "$file" "$file.backup"
            echo "Created local backup: $file.backup" >> "$BACKUP_LOG"
        fi
        
        return 0
    else
        echo "SKIP: $file (not found)" >> "$BACKUP_LOG"
        return 1
    fi
}

# Function to backup directories
backup_directory() {
    local dir="$1"
    if [ -d "$dir" ]; then
        local relative_path=${dir#$HOME/}
        local backup_path="$BACKUP_DIR/$relative_path"
        cp -R "$dir" "$(dirname "$backup_path")"
        echo "DIR: $relative_path" >> "$BACKUP_LOG"
        return 0
    else
        echo "SKIP: $dir (not found)" >> "$BACKUP_LOG"
        return 1
    fi
}

# Function to cleanup old backups (keep last 5 by default)
cleanup_old_backups() {
    local keep_count=${1:-5}
    local backup_root="$HOME/.config/_backup"
    
    if [ -d "$backup_root" ]; then
        ls -t "$backup_root" | tail -n +$((keep_count + 1)) | while read -r old_backup; do
            rm -rf "$backup_root/$old_backup"
            echo "Removed old backup: $old_backup" >> "$BACKUP_LOG"
        done
    fi
}

# Initialize backup
init_backup

# List of files and directories to backup
declare -a BACKUP_FILES=(
    "$HOME/.zshrc"
    "$HOME/.zsh_aliases"
    "$HOME/.functions.zsh"
    "$HOME/.config/nvim/init.lua"
    "$HOME/.config/starship.toml"
    "$HOME/.config/ghostty/config"
    "$HOME/.gitconfig"
)

declare -a BACKUP_DIRS=(
    "$HOME/.config/nvim"
)

# Perform backups
echo "Starting backup process..."
for file in "${BACKUP_FILES[@]}"; do
    if backup_file "$file"; then
        echo "✓ Backed up: $(basename "$file")"
    else
        echo "→ Skipped: $(basename "$file")"
    fi
done

for dir in "${BACKUP_DIRS[@]}"; do
    if backup_directory "$dir"; then
        echo "✓ Backed up directory: $(basename "$dir")"
    else
        echo "→ Skipped directory: $(basename "$dir")"
    fi
done

# Cleanup old backups (keep last 5)
cleanup_old_backups 5

# Create summary
echo -e "\nBackup Summary:" >> "$BACKUP_LOG"
echo "Total files backed up: $(find "$BACKUP_DIR" -type f -not -name 'backup.log' | wc -l)" >> "$BACKUP_LOG"
echo "Backup completed at $(date)" >> "$BACKUP_LOG"

# Create necessary directories
mkdir -p ~/.config/scripts
mkdir -p ~/.config

# Create all symlinks
echo "Creating symlinks..."
ln -sf "$DOTFILES_DIR/zshrc" "$HOME/.zshrc"
ln -sf "$DOTFILES_DIR/zsh_aliases" "$HOME/.zsh_aliases"
ln -sf "$DOTFILES_DIR/functions.zsh" "$HOME/.functions.zsh"
ln -sf "$DOTFILES_DIR/scripts/compress_screencaps.sh" "$HOME/.config/scripts/"
[ -f "$DOTFILES_DIR/apps/starship/starship.toml" ] && ln -sf "$DOTFILES_DIR/apps/starship/starship.toml" "$HOME/.config/starship.toml"

# restore.sh
ln -sf "$DOTFILES_DIR/restore.sh" "$HOME/.config/scripts/restore.sh"

# Setup Neovim
echo "Setting up Kickstart Neovim configuration..."
rm -rf ~/.config/nvim # Remove existing directory after backup
git clone https://github.com/nvim-lua/kickstart.nvim.git ~/.config/nvim
nvim --headless "+Lazy sync" +qa

# Source updated configuration
source ~/.zshrc

echo "Dotfiles installation completed successfully!"
echo "Backup location: $BACKUP_DIR"