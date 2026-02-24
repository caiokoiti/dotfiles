# Navigation
alias ..='cd ../'                                                           # Go up 1 directory
alias ...='cd ../../'                                                       # Go up 2 directories
alias ....='cd ../../../'                                                   # Go up 3 directories

# File operations
alias c='clear'                                                             # Clear terminal
alias cleanupDS='find . -type f -name "*.DS_Store" -ls -delete'            # Remove .DS_Store files
alias cpwd='pwd | pbcopy'                                                   # Copy current path to clipboard
alias f='open -a Finder ./'                                                 # Open Finder in current dir
alias ll='ls -l -A -h -F --color=auto'                                     # List files (detailed)
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

# ============================================
# Zellij Aliases
# ============================================

alias zj='zellij attach -c $(basename "$PWD")'                             # Attach/create session named after cwd
alias zls='zellij list-sessions'                                            # List all sessions
alias zk='zellij kill-session'                                              # Kill a specific session
alias zka='zellij kill-all-sessions'                                        # Kill all sessions
alias zdel='zellij delete-session'                                          # Delete a specific session
alias zclean='zellij list-sessions --no-formatting 2>/dev/null | grep "EXITED" | awk "{print \$1}" | xargs -I {} zellij delete-session {}' # Clean exited sessions
alias zdetach='zellij action detach'                                        # Detach from current session

# Fuzzy find + attach sessão
zz() {
    local session=$(zellij list-sessions --no-formatting 2>/dev/null | fzf | awk '{print $1}')
    if [[ -n "$session" ]]; then
        zellij attach "$session"
    fi
}

# Cria nova sessão com nome customizado
zn() {
    if [ -z "$1" ]; then
        echo "Usage: zn <session-name>"
        return 1
    fi
    zellij attach -c "$1"
}
