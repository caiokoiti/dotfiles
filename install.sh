#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$HOME/dotfiles_install_$(date +%Y%m%d_%H%M%S).log"

# Source the backup script
source "$DOTFILES_DIR/backup.sh" || { echo "Failed to source backup.sh"; exit 1; }

log() { echo "$1" | tee -a "$LOG_FILE"; }
error() { echo -e "${RED}ERROR: $1${NC}" | tee -a "$LOG_FILE"; exit 1; }

create_symlink() {
    local source="$1"
    local target="$2"
    
    backup_file "$target"
    [ -e "$target" ] && rm -rf "$target" || true
    mkdir -p "$(dirname "$target")" || error "Failed to create parent directory for $target"
    ln -sf "$source" "$target" || error "Failed to create symlink: $target"
    log "Created symlink: $target -> $source"
}

install_homebrew() {
    if ! command -v brew >/dev/null 2>&1; then
        log "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" >> "$LOG_FILE" 2>&1 || error "Failed to install Homebrew"
        
        if [[ $(uname -m) == 'arm64' ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
    fi
}

CORE_UTILS=(
    "git" "tar" "gzip" "bzip2" "unzip" "unrar" "p7zip" "bunzip2" "uncompress"
    "make" "gcc" "xclip" "ghostty"
)

DEV_TOOLS=(
    "starship" "direnv" "zoxide" "fzf"    # Shell enhancements
    "ripgrep" "fd" "bat"                  # Search and file tools
    "n" "neovim" "lua" "luarocks"         # Development
    "lazygit" "lazydocker"                # Added for aliases
    "font-fira-mono-nerd-font"            # Fonts
    "font-jetbrains-mono-nerd-font"
)

BREW_PACKAGES=("${CORE_UTILS[@]}" "${DEV_TOOLS[@]}")

install_packages() {
    log "Updating Homebrew font access..."
    brew tap homebrew/cask-fonts >> "$LOG_FILE" 2>&1 || error "Failed to tap homebrew/cask-fonts"

    log "Checking and installing packages..."
    for package in "${BREW_PACKAGES[@]}"; do
        if ! brew list "$package" >/dev/null 2>&1; then
            log "Installing $package..."
            if [[ $package == font-* ]]; then
                brew install --cask "$package" >> "$LOG_FILE" 2>&1 || error "Failed to install $package"
            else
                brew install "$package" >> "$LOG_FILE" 2>&1 || error "Failed to install $package"
            fi
        fi
    done
}

main() {
    log "Starting dotfiles installation..."

    install_homebrew
    install_packages

    backup_file ~/.config/scripts
    backup_file ~/.config/nvim
    mkdir -p ~/.config/scripts ~/.config/nvim || error "Failed to create config directories"

    create_symlink "$DOTFILES_DIR/zshrc" ~/.zshrc
    create_symlink "$DOTFILES_DIR/zsh_aliases" ~/.zsh_aliases
    create_symlink "$DOTFILES_DIR/functions.zsh" ~/.functions.zsh
    create_symlink "$DOTFILES_DIR/scripts/compress_screencaps.sh" ~/.config/scripts/compress_screencaps.sh
    
    create_symlink "$DOTFILES_DIR/apps/starship/starship.toml" ~/.config/starship.toml
    create_symlink "$DOTFILES_DIR/apps/.ripgreprc" ~/.ripgreprc

    backup_file ~/.config/nvim
    git clone https://github.com/nvim-lua/kickstart.nvim.git ~/.config/nvim >> "$LOG_FILE" 2>&1 || error "Failed to clone Kickstart.nvim"
    nvim --headless "+Lazy sync" +qa 2>> "$LOG_FILE" || error "Failed to install Neovim plugins"

    if command -v zsh >/dev/null 2>&1; then
        source ~/.zshrc 2>/dev/null || log "Warning: Failed to source .zshrc"
    fi

    log "${GREEN}Dotfiles and Kickstart.nvim installed successfully!${NC}"
    log "Installation log saved to: $LOG_FILE"
}

main