function cd {
    builtin cd "$@" && ls -l -A -h -F --color=auto
}

# Universal archive extractor
function extract() {
    local target_dir=""
    local dry_run=false
    local file=""

    # Parse options
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -o|--output)
                target_dir="$2"
                shift 2
                ;;
            --dry-run)
                dry_run=true
                shift
                ;;
            *)
                file="$1"
                shift
                ;;
        esac
    done

    if [[ -z "$file" ]]; then
        echo "extract: No file specified" >&2
        return 1
    fi

    if [[ ! -f "$file" ]]; then
        echo "extract: '$file' is not a valid file" >&2
        return 1
    fi

    # Create target directory if specified
    if [[ -n "$target_dir" ]]; then
        mkdir -p "$target_dir" || { echo "extract: Failed to create directory '$target_dir'" >&2; return 1; }
    fi

    # Helper function to check if a command exists
    check_cmd() {
        command -v "$1" >/dev/null 2>&1 || { echo "extract: '$1' is required but not installed" >&2; return 1; }
    }

    # Dry-run output
    dry_run_cmd() {
        if [[ "$dry_run" == true ]]; then
            echo "Would execute: $@"
            return 0
        fi
        "$@"
    }

    local cmd=""
    case "$file" in
        *.tar.bz2|*.tbz2)
            check_cmd tar && cmd="tar -xjf \"$file\""
            ;;
        *.tar.gz|*.tgz)
            check_cmd tar && cmd="tar -xzf \"$file\""
            ;;
        *.tar.xz)
            check_cmd tar && cmd="tar -xJf \"$file\""
            ;;
        *.tar)
            check_cmd tar && cmd="tar -xf \"$file\""
            ;;
        *.bz2)
            check_cmd bunzip2 && cmd="bunzip2 -k \"$file\""
            ;;
        *.gz)
            check_cmd tar && cmd="tar -xzf \"$file\""
            ;;
        *.rar)
            check_cmd unrar && cmd="unrar x \"$file\""
            ;;
        *.zip)
            check_cmd unzip && cmd="unzip \"$file\""
            ;;
        *.Z)
            check_cmd uncompress && cmd="uncompress \"$file\""
            ;;
        *.7z)
            check_cmd 7z && cmd="7z x \"$file\""
            ;;
        *)
            echo "extract: '$file' cannot be extracted (unsupported format)" >&2
            return 1
            ;;
    esac

    if [[ -n "$cmd" ]]; then
        if [[ -n "$target_dir" ]]; then
            cmd="$cmd -C \"$target_dir\""
        fi
        if dry_run_cmd bash -c "$cmd"; then
            [[ "$dry_run" == false ]] && echo "extract: Successfully extracted '$file'"
            return 0
        else
            echo "extract: Failed to extract '$file'" >&2
            return 1
        fi
    fi
    return 1
}