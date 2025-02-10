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

# Create backups and symlinks
[ -f ~/.zshrc ] && mv ~/.zshrc ~/.zshrc.backup
[ -f ~/.zsh_aliases ] && mv ~/.zsh_aliases ~/.zsh_aliases.backup
[ -f ~/.functions.zsh ] && mv ~/.functions.zsh ~/.functions.zsh.backup

ln -sf $DOTFILES_DIR/zshrc ~/.zshrc
ln -sf $DOTFILES_DIR/zsh_aliases ~/.zsh_aliases
ln -sf $DOTFILES_DIR/functions.zsh ~/.functions.zsh

mkdir -p ~/.config/scripts
ln -sf $DOTFILES_DIR/scripts/compress_screencaps.sh ~/.config/scripts/

# APPS CONFIGURATION
## Starship
mkdir -p ~/.config
[ -f $DOTFILES_DIR/apps/starship/starship.toml ] && ln -sf $DOTFILES_DIR/apps/starship/starship.toml ~/.config/starship.toml

# Backup existing Neovim configuration
[ -d ~/.config/nvim ] && mv ~/.config/nvim ~/.config/nvim.backup
[ -f ~/.config/nvim/init.lua ] && mv ~/.config/nvim/init.lua ~/.config/nvim/init.lua.backup

# Clone Kickstart.nvim
echo "Setting up Kickstart Neovim configuration..."
git clone https://github.com/nvim-lua/kickstart.nvim.git ~/.config/nvim

# Install Neovim plugins
nvim --headless "+Lazy sync" +qa

source ~/.zshrc

echo "Dotfiles and Kickstart.nvim installed successfully!"