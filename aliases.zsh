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
alias kk='kiro-cli chat --resume'

# Custom scripts
alias compress='compress_screencaps.sh'
alias compressDesktop='compress_screencaps.sh ~/Desktop'
alias compressDropbox='compress_screencaps.sh ~/Dropbox/Screenshots'
alias compressOD='compress_screencaps.sh ~/Library/CloudStorage/OneDrive-Dabble/screenshots'

# Development tools
alias lg='lazygit'
alias ld='lazydocker'

# ============================================
# Zellij Aliases
# ============================================

# Attach/cria sessão com nome do diretório atual
alias zj='zellij attach -c $(basename "$PWD")'

# Lista todas as sessões
alias zls='zellij list-sessions'

# Kill sessão específica
alias zk='zellij kill-session'

# Kill todas as sessões
alias zka='zellij kill-all-sessions'

# Deleta sessão específica (usa com zls pra ver o nome)
alias zdel='zellij delete-session'

# Limpa sessões que já terminaram (EXITED)
alias zclean='zellij list-sessions --no-formatting 2>/dev/null | grep "EXITED" | awk "{print \$1}" | xargs -I {} zellij delete-session {}'

# Detach da sessão atual (também pode usar Ctrl+o,d)
alias zdetach='zellij action detach'

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