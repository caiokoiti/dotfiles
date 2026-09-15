# Dotfiles

Personal configuration for macOS development environment.

## Features

- Modular organization with clear separation from system configs
- Automatic installation of Homebrew and packages
- Symlink management for configuration files
- Custom shell functions and aliases
- History optimization and zsh enhancements
- Built-in backup and restore functionality
- Optional work dotfiles loaded automatically if present

## Installation

```bash
git clone https://github.com/caiokoiti/dotfiles.git
cd dotfiles
./install.zsh
```

Open a new terminal after installation for changes to take effect.

## What's Included

- **Shell**: Enhanced zsh configuration with history management and autosuggestions
- **Prompt**: Starship with Dracula theme
- **Terminal**: Ghostty and iTerm2 (preferences versioned in `iterm2/`)
- **Editor**: Helix (`hx`) with LSP for TypeScript/JavaScript
- **Tools**: direnv, zoxide, fzf, ripgrep, fd, bat
- **Utilities**: Custom scripts for file operations and media conversion
- **Node.js**: N version manager pre-configured

## Performance

Shell startup is optimized to minimize terminal open delay:

- **Homebrew** env vars are hardcoded instead of running `brew shellenv` on every startup
- **Starship, direnv, zoxide, fzf** init scripts are cached in `~/.zsh_cache/` and only regenerated when the binary changes — eliminates one subprocess fork per tool per terminal open
- **compinit** uses zsh glob qualifiers instead of a `find` subprocess for the cache freshness check

To force a cache regeneration (e.g. after upgrading a tool):

```bash
rm -rf ~/.zsh_cache && reload
```

## Customization

All configurations are clearly organized:
- `config.zsh`: Central configuration variables and symlink registry
- `extended_zshrc.zsh`: Main shell enhancements
- `aliases.zsh`: Convenient command shortcuts
- `functions.zsh`: Custom shell functions
- `bin/`: Executable scripts added to PATH
- `.config/`: Tool-specific configs (Starship, Helix, Ghostty, ripgrep)

## Work Dotfiles

Work-specific aliases and configuration live in a separate private repo
to keep company tooling and commands out of this public repo.

If `~/dotfiles-work/init.zsh` exists, it is sourced automatically on
shell startup — no extra setup needed on personal machines.

```bash
# On a work machine:
git clone git@github.com:caiokoiti/dotfiles-work.git ~/dotfiles-work
```

## Uninstallation

```bash
./uninstall.zsh
```

The uninstall script cleanly removes all customizations and offers to restore from backup.

## Health Check

```bash
./doctor.zsh
```

Checks the full installation state: `.zshrc` source block, symlinks, required tools, iTerm2 config, zsh cache, backups, and work dotfiles. Reports issues with fix instructions.

## Requirements

- macOS (Intel or Apple Silicon)
- Internet connection (for package installation)

## Notes

- Automatically creates backups before any modifications (handles both files and symlinks)
- Configures for Australian locale and timezone (Perth)
- Dracula theme applied consistently across all compatible tools
- `reload` alias reloads everything (personal + work dotfiles) in the current session
