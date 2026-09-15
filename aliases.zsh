# Navigation
alias ..='cd ../'                                                           # Go up 1 directory
alias ...='cd ../../'                                                       # Go up 2 directories
alias ....='cd ../../../'                                                   # Go up 3 directories

# File operations
alias c='clear'                                                             # Clear terminal
alias cleanupDS='find . -type f -name "*.DS_Store" -ls -delete'            # Remove .DS_Store files
alias cpwd='pwd | pbcopy'                                                   # Copy current path to clipboard
alias f='open -a Finder ./'                                                 # Open Finder in current dir
# List files (detailed) — delegates to _ls_detail() in functions.zsh for BSD/GNU compat
alias ll='_ls_detail'
alias mkdir='mkdir -pv'                                                     # Create dirs with parents
alias qfind='find . -name'                                                  # Quick find by name

# Tools and utilities
alias path='print -l ${(s/:/)PATH}'                                        # Print PATH entries line by line
alias less='less -FSRXc'                                                    # Less with sane defaults
alias kk='kiro-cli chat --resume'                                           # Resume Kiro AI chat
alias reload='source ~/.zshrc'                                              # Reload shell config (personal + work)

# Custom scripts
alias compress='compress_screencaps.sh'                                     # Compress screen recordings
alias compressDesktop='compress_screencaps.sh ~/Desktop'                   # Compress from Desktop
alias compressDropbox='compress_screencaps.sh ~/Dropbox/Screenshots'       # Compress from Dropbox
alias compressOD='compress_screencaps.sh ~/Library/CloudStorage/OneDrive-Dabble/screenshots' # Compress from OneDrive

# Development tools
alias lg='lazygit'                                                          # Git TUI
alias ld='lazydocker'                                                       # Docker TUI

