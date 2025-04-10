#!/usr/bin/env zsh

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$HOME/dotfiles_install_$(date +%Y%m%d_%H%M%S).log"

# Function to append a source command to a file if not already present
append_source_if_not_present() {
    local config_file="$1"
    local source_file="$2"
    local marker="# Added by dotfiles install.sh"

    # Backup the config file before modifying
    backup_file "$config_file"

    # Check if the source command is already present
    if ! grep -q "source $source_file" "$config_file" 2>/dev/null; then
        log "Appending 'source $source_file' to $config_file..."
        # Add a marker and the source command
        echo -e "\n$marker" >> "$config_file"
        echo "[[ -f $source_file ]] && source $source_file" >> "$config_file"
    else
        log "Source command for $source_file already present in $config_file. Skipping."
    fi
}


# Source the backup script
source "$DOTFILES_DIR/backup.sh" || { echo "Failed to source backup.sh"; exit 1; }

log() { echo "$1" | tee -a "$LOG_FILE"; }
error() { echo -e "${RED}ERROR: $1${NC}" | tee -a "$LOG_FILE"; exit 1; }


append_source_if_not_present ~/.zshrc "$DOTFILES_DIR/zshrc.zsh"


create_symlink() {
    local source="$1"
    local target="$2"
    
    # Check if source file exists
    if [ ! -f "$source" ] && [ ! -d "$source" ]; then
        log "Warning: Source file does not exist: $source. Skipping symlink creation for $target."
        return 0
    fi

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
    "git" "gnu-tar" "gzip" "bzip2" "unzip" "the-unarchiver" "p7zip" "bzip2"
    "make" "gcc" "xclip" "ghostty"
)

DEV_TOOLS=(
    "starship" "direnv" "zoxide" "fzf"    # Shell enhancements
    "ripgrep" "fd" "bat"                  # Search and file tools
    "n" "neovim" "lua" "luarocks"         # Development
    "lazygit" "lazydocker"                # Added for aliases
    "ffmpeg"                              # for the scripts/compress_screencaps.sh
    "font-fira-mono-nerd-font"            # Fonts
    "font-jetbrains-mono-nerd-font"
)

BREW_PACKAGES=("${CORE_UTILS[@]}" "${DEV_TOOLS[@]}")

install_packages() {
    log "Updating Homebrew..."
    brew update >> "$LOG_FILE" 2>&1 || error "Failed to update Homebrew"

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

    # install_homebrew
    # install_packages

    backup_file ~/.config/scripts
    backup_file ~/.config/nvim
    mkdir -p ~/.config/scripts ~/.config/nvim || error "Failed to create config directories"

    create_symlink "$DOTFILES_DIR/zshrc" ~/.zshrc
    create_symlink "$DOTFILES_DIR/aliases.zsh" ~/.aliases.zsh
    create_symlink "$DOTFILES_DIR/functions.zsh" ~/.functions.zsh
    create_symlink "$DOTFILES_DIR/scripts/compress_screencaps.sh" ~/.config/scripts/compress_screencaps.sh
    create_symlink "$DOTFILES_DIR/apps/starship/starship.toml" ~/.config/starship.toml
    create_symlink "$DOTFILES_DIR/apps/ripgrep/.ripgreprc" ~/.ripgreprc  # Fixed path

    # Check if Kickstart.nvim is already cloned
    if [ -d ~/.config/nvim/.git ]; then
        # Verify it's the correct repository
        cd ~/.config/nvim
        remote_url=$(git config --get remote.origin.url 2>/dev/null || echo "")
        if [[ "$remote_url" == *"nvim-lua/kickstart.nvim"* ]]; then
            log "Kickstart.nvim already cloned in ~/.config/nvim. Skipping clone."
        else
            log "Existing ~/.config/nvim is not Kickstart.nvim. Backing up and re-cloning..."
            backup_file ~/.config/nvim
            rm -rf ~/.config/nvim || error "Failed to remove existing ~/.config/nvim"
            log "Cloning Kickstart.nvim..."
            git clone https://github.com/nvim-lua/kickstart.nvim.git ~/.config/nvim 2>&1 | tee -a "$LOG_FILE" || error "Failed to clone Kickstart.nvim. Check the log for details: $LOG_FILE"
            log "Kickstart.nvim cloned successfully."
        fi
        cd - >/dev/null
    else
        log "Cloning Kickstart.nvim..."
        git clone https://github.com/nvim-lua/kickstart.nvim.git ~/.config/nvim 2>&1 | tee -a "$LOG_FILE" || error "Failed to clone Kickstart.nvim. Check the log for details: $LOG_FILE"
        log "Kickstart.nvim cloned successfully."
    fi

    # Install Neovim plugins
    log "Installing Neovim plugins with Lazy..."
    nvim --headless "+Lazy sync" +qa 2>> "$LOG_FILE" || error "Failed to install Neovim plugins. Check the log for details: $LOG_FILE"
    log "Neovim plugins installed successfully."

    if command -v zsh >/dev/null 2>&1; then
        source ~/.zshrc 2>/dev/null || log "Warning: Failed to source .zshrc"
    fi

    log "${GREEN}Dotfiles and Kickstart.nvim installed successfully!${NC}"
    log "Installation log saved to: $LOG_FILE"
}

main