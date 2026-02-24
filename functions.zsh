function cd {
    builtin cd "$@" && ls -l -A -h -F --color=auto
}

# Universal archive extractor
function aliases() {
    local selected
    selected=$(
        grep -E '^alias ' "$ALIASES_FILE" | sed 's/^alias //' | while IFS= read -r line; do
            printf "%-15s  %s\n" \
                "$(echo "$line" | cut -d'=' -f1)" \
                "$(echo "$line" | grep -o '#[^#]*$' | sed 's/^#[[:space:]]*//')"
        done | fzf --header="Aliases  |  Enter to execute  |  Esc to cancel"
    )
    [[ -z "$selected" ]] && return
    local name="${selected%%  *}"
    name="${name// /}"
    eval "$name"
}
function extract() {
    if [ -f "$1" ]; then
        case $1 in
            *.tar.bz2) tar xvjf "$1" ;;
            *.tar.gz) tar xvzf "$1" ;;
            *.bz2) bunzip2 "$1" ;;
            *.rar) 7z x "$1" ;;  # Using 7z instead of unrar
            *.gz) gunzip "$1" ;;
            *.tar) tar xvf "$1" ;;
            *.tbz2) tar xvjf "$1" ;;
            *.tgz) tar xvzf "$1" ;;
            *.zip) unzip "$1" ;;
            *.Z) uncompress "$1" ;;
            *.7z) 7z x "$1" ;;
            *) echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}