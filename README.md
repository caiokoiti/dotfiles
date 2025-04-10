# Dotfiles

Personal configuration for macOS development environment.

## Features

- Modular organization with clear separation from system configs
- Automatic installation of Homebrew and packages
- Symlink management for configuration files
- Custom shell functions and aliases
- History optimization and zsh enhancements
- Built-in backup and restore functionality

## Installation

```bash
git clone https://github.com/caiokoiti/dotconfig.git
cd dotconfig
./install.zsh
```

## What's Included

- **Shell**: Enhanced zsh configuration with history management
- **Tools**: Starship prompt, direnv, zoxide, fzf
- **Development**: Neovim, git tools, ripgrep, fd
- **Utilities**: Custom scripts for file operations and media conversion
- **Node.js**: N version manager pre-configured

## Customization

All configurations are clearly organized:
- `config.zsh`: Central configuration variables
- `extended_zshrc.zsh`: Main shell enhancements
- `aliases.zsh`: Convenient command shortcuts
- `functions.zsh`: Custom shell functions
- `bin/`: Executable scripts added to PATH

## Uninstallation

```bash
./uninstall.zsh
```

The uninstall script cleanly removes all customizations and offers to restore from backup.

## Requirements

- macOS (Intel or Apple Silicon)
- Internet connection (for package installation)

## Notes

- Automatically creates backups before any modifications
- Configures for Australian locale and timezone
- Uses the Dracula theme for compatible tools