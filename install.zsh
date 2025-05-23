#!/usr/bin/env zsh

set -e

# Source the configuration file
SCRIPT_DIR="${0:a:h}"
source "$SCRIPT_DIR/config.zsh"

# Function to create backup directory
create_backup_dir() {
  echo "Creating backup directory at $BACKUP_DIR"
  mkdir -p "$BACKUP_DIR"
}

# Function to backup existing configuration files
backup_file() {
  local file=$1
  if [[ -f "$file" ]]; then
    echo "Backing up $file"
    cp "$file" "$BACKUP_DIR/$(basename "$file")"
  fi
}

# Function to append source line to .zshrc if not already present
append_source_to_zshrc() {
  local source_line="# Source custom dotfiles configuration\n# To uninstall run: $DOTFILES_DIR/uninstall.sh\n[ -f $EXTENDED_ZSHRC ] && source $EXTENDED_ZSHRC"
  
  if ! grep -qF "$EXTENDED_ZSHRC" "$ZSHRC_PATH"; then
    echo "Appending source line to $ZSHRC_PATH"
    echo -e "\n$source_line" >> "$ZSHRC_PATH"
    echo "Added custom dotfiles source to .zshrc"
  else
    echo "Source line already exists in .zshrc"
  fi
}

# Function to install Homebrew if not already installed
install_homebrew() {
  if command -v brew &>/dev/null; then
    echo "Homebrew is already installed"
  else
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for the current session
    if [[ "$(uname -m)" == "arm64" ]]; then
      # For Apple Silicon Macs
      eval "$(/opt/homebrew/bin/brew shellenv)"
      echo "Added Homebrew to PATH for Apple Silicon Mac"
    else
      # For Intel Macs
      eval "$(/usr/local/bin/brew shellenv)"
      echo "Added Homebrew to PATH for Intel Mac"
    fi
    
    echo "Homebrew installed successfully"
  fi
}

# Function to install packages via Homebrew
install_packages() {
  echo "Installing packages..."
  
  # Make sure Homebrew is installed
  install_homebrew
  
  # Update Homebrew
  echo "Updating Homebrew..."
  brew update
  
  # Install packages
  echo "Installing Homebrew packages..."
  brew bundle --file="$DOTFILES_DIR/Brewfile" || {
    echo "Warning: Some packages in Brewfile failed to install"
  }
  
  echo "Package installation complete"
}

create_symlinks() {
  echo "Creating symlinks..."
  
  for link in "${SYMLINK_FILES[@]}"; do
    local src="${link%%:*}"
    local dest="${link##*:}"
    local dest_dir="$(dirname "$dest")"
    
    # Create the destination directory if it doesn't exist
    if [[ ! -d "$dest_dir" ]]; then
      echo "Creating directory: $dest_dir"
      mkdir -p "$dest_dir"
    fi
    
    # Backup existing file if it's not a symlink
    if [[ -f "$dest" && ! -L "$dest" ]]; then
      backup_file "$dest"
    fi
    
    # Remove existing symlink if it exists
    if [[ -L "$dest" ]]; then
      rm "$dest"
    fi
    
    # Create the symlink
    echo "Creating symlink: $src -> $dest"
    ln -s "$src" "$dest"
  done
}

# Function to install Neovim Kickstart
install_nvim_kickstart() {
  # Check if Neovim is installed
  if ! command -v nvim &>/dev/null; then
    echo "Neovim not found, skipping Kickstart installation"
    return 0
  fi

  echo "Neovim detected - setting up Kickstart configuration..."

  if [[ ! -d "$HOME/.config/nvim" ]]; then
    # Clone the Kickstart repository
    echo "Downloading Neovim Kickstart..."
    git clone https://github.com/nvim-lua/kickstart.nvim.git "$HOME/.config/nvim"


    echo "Neovim Kickstart installed successfully!"
  else
    echo "Neovim Kickstart is already installed!"
  fi
  
  nvim --headless "+Lazy sync" +qa
}

# Main installation function
install() {
  echo "Starting installation of custom dotfiles..."
  
  create_backup_dir
  
  backup_file "$ZSHRC_PATH"
  
  append_source_to_zshrc
  
  install_homebrew
  
  install_packages

  install_nvim_kickstart
  
  create_symlinks

  echo "Installation complete!"
  source "$ZSHRC_PATH"
  echo "Configuration applied!"
}

# Run installation
install