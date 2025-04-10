# Navigation
alias ..='cd ../'
alias ...='cd ../../'
alias ....='cd ../../../'

# File operations
alias c='clear'
alias cleanupDS='find . -type f -name "*.DS_Store" -ls -delete'
alias cpwd='pwd | pbcopy'
alias f='open -a Finder ./'
alias ll='ls -l -A -h -F --color=auto'
alias mkdir='mkdir -pv'
alias qfind='find . -name'

# Tools and utilities
alias path='echo -e ${PATH//:/\\n}'
alias less='less -FSRXc'

# Custom scripts
alias compress='compress_screencaps'
alias compressDesktop='compress_screencaps ~/Desktop'

# Development tools
alias lg='lazygit'
alias ld='lazydocker'