# Navigation
alias ..='cd ../'                                                           # Go up 1 directory
alias ...='cd ../../'                                                       # Go up 2 directories
alias ....='cd ../../../'                                                   # Go up 3 directories

# File operations
alias c='clear'                                                             # Clear terminal
alias cleanupDS='find . -type f -name "*.DS_Store" -ls -delete'            # Remove .DS_Store files
alias cpwd='pwd | pbcopy'                                                   # Copy current path to clipboard
alias f='open -a Finder ./'                                                 # Open Finder in current dir
# List files (detailed) — use GNU ls flags if available, fallback to BSD
if ls --color=auto &>/dev/null 2>&1; then
    alias ll='ls -l -A -h -F --color=auto'  # GNU ls (coreutils via Homebrew)
else
    alias ll='ls -l -A -h -F -G'            # BSD ls (macOS default)
fi
alias mkdir='mkdir -pv'                                                     # Create dirs with parents
alias qfind='find . -name'                                                  # Quick find by name

# Tools and utilities
alias path='echo -e ${PATH//:/\\n}'                                        # Print PATH entries line by line
alias less='less -FSRXc'                                                    # Less with sane defaults
alias kk='kiro-cli chat --resume'                                           # Resume Kiro AI chat

# Custom scripts
alias compress='compress_screencaps.sh'                                     # Compress screen recordings
alias compressDesktop='compress_screencaps.sh ~/Desktop'                   # Compress from Desktop
alias compressDropbox='compress_screencaps.sh ~/Dropbox/Screenshots'       # Compress from Dropbox
alias compressOD='compress_screencaps.sh ~/Library/CloudStorage/OneDrive-Dabble/screenshots' # Compress from OneDrive

# Development tools
alias lg='lazygit'                                                          # Git TUI
alias ld='lazydocker'                                                       # Docker TUI

