# Internal helper — list files with detail, BSD/GNU compatible.
# Used by both the cd override and the ll alias.
_ls_detail() {
    if ls --color=auto &>/dev/null 2>&1; then
        ls -l -A -h -F --color=auto "$@"  # GNU ls (coreutils via Homebrew)
    else
        ls -l -A -h -F -G "$@"            # BSD ls (macOS default)
    fi
}

# Override cd to list directory contents after every jump.
function cd {
    builtin cd "$@" && _ls_detail
}

# Interactive alias browser — fuzzy search aliases and execute the selected one.
# Parses aliases.zsh at runtime so descriptions stay in sync with the source.
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

# Universal archive extractor — detects format by extension.
function extract() {
    if [ -f "$1" ]; then
        case $1 in
            *.tar.bz2) tar xvjf "$1" ;;
            *.tar.gz)  tar xvzf "$1" ;;
            *.bz2)     bunzip2 "$1" ;;
            *.rar)     7z x "$1" ;;  # Using 7z instead of unrar (no brew dependency)
            *.gz)      gunzip "$1" ;;
            *.tar)     tar xvf "$1" ;;
            *.tbz2)    tar xvjf "$1" ;;
            *.tgz)     tar xvzf "$1" ;;
            *.zip)     unzip "$1" ;;
            *.Z)       uncompress "$1" ;;
            *.7z)      7z x "$1" ;;
            *)         echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}
