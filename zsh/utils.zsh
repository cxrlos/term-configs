alias vi='nvim'
alias vim='nvim'
alias edit='nvim'

alias python='python3'
alias pip='pip3'
alias py='python3'
alias venv='python3 -m venv .venv && source .venv/bin/activate'

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

if command -v eza &>/dev/null; then
    alias ls='eza --icons'
    alias ll='eza -la --icons --git --header'
    alias la='eza -a --icons'
    alias l='eza --icons'
    alias lt='eza --tree --icons --level=2 --git-ignore'
elif [[ "$OSTYPE" == "darwin"* ]]; then
    alias ls='ls -G'
    alias ll='ls -laG'
    alias la='ls -AG'
    alias l='ls -CFG'
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    alias ls='ls --color=auto'
    alias ll='ls -la --color=auto'
    alias la='ls -A --color=auto'
    alias l='ls -CF --color=auto'
fi

if [[ "$OSTYPE" == "darwin"* ]]; then
    alias showfiles="defaults write com.apple.finder AppleShowAllFiles YES; killall Finder"
    alias hidefiles="defaults write com.apple.finder AppleShowAllFiles NO; killall Finder"
fi

command -v bat &>/dev/null && alias cat='bat --style=plain'
command -v rg  &>/dev/null && alias grep='rg'

mkcd() { mkdir -p "$1" && cd "$1"; }

extract() {
    if [[ "$1" == "-h" || "$1" == "--help" || $# -eq 0 ]]; then
        if command -v gum &>/dev/null; then
            gum style --border rounded --border-foreground "#c4a7e7" --padding "1 2" --margin "1 0" \
                "${_bold}extract${_nc} ${_subtle}<file>${_nc}" \
                "" \
                "${_subtle}Supported formats:${_nc}" \
                "  ${_iris}tar.gz${_nc}  ${_iris}tar.bz2${_nc}  ${_iris}tgz${_nc}  ${_iris}tbz2${_nc}" \
                "  ${_iris}gz${_nc}  ${_iris}bz2${_nc}  ${_iris}zip${_nc}  ${_iris}rar${_nc}  ${_iris}7z${_nc}  ${_iris}Z${_nc}  ${_iris}tar${_nc}"
        else
            printf '\n  %sextract%s %s<file>%s\n' "$_bold" "$_nc" "$_iris" "$_nc"
            printf '  Supported: %star.gz tar.bz2 tgz tbz2 gz bz2 zip rar 7z Z tar%s\n\n' "$_subtle" "$_nc"
        fi
        [[ "$1" == "-h" || "$1" == "--help" ]] && return 0 || return 1
    fi

    [[ -f "$1" ]] || { _err "Not a file: ${_bold}$1${_nc}"; return 1; }

    case "$1" in
        *.tar.bz2|*.tbz2) tar xjf "$1"    ;;
        *.tar.gz|*.tgz)   tar xzf "$1"    ;;
        *.bz2)            bunzip2 "$1"    ;;
        *.gz)             gunzip "$1"     ;;
        *.tar)            tar xf "$1"     ;;
        *.zip)            unzip "$1"      ;;
        *.Z)              uncompress "$1" ;;
        *.rar)            unrar e "$1"    ;;
        *.7z)             7z x "$1"       ;;
        *) _err "Unknown format: ${_bold}$1${_nc}"; return 1 ;;
    esac
}

_write_to_config() {
    local file="$1" line="$2"
    echo "$line" >> "$ZSH_CONFIG_DIR/$file"
    if [[ "$TERM_CONFIGS_MODE" == "copy" && -d "$TERM_CONFIGS_DIR" ]]; then
        echo "$line" >> "$TERM_CONFIGS_DIR/zsh/$file"
        _info "Written to both active config and repo"
    fi
}

a() {
    case "$1" in
        -h|--help)
            if command -v gum &>/dev/null; then
                gum style --border rounded --border-foreground "#c4a7e7" --padding "1 2" --margin "1 0" \
                    "${_bold}a${_nc} ${_subtle}[command]${_nc}" \
                    "" \
                    "  ${_iris}s${_nc}  ${_subtle}search${_nc}    fuzzy search aliases" \
                    "  ${_iris}a${_nc}  ${_subtle}add${_nc}       create new alias"
            else
                printf '\n  %sa%s %s[command]%s\n\n' "$_bold" "$_nc" "$_subtle" "$_nc"
                printf '  %ss%s  search    %sfuzzy search aliases%s\n' "$_iris" "$_nc" "$_subtle" "$_nc"
                printf '  %sa%s  add       %screate new alias%s\n\n'   "$_iris" "$_nc" "$_subtle" "$_nc"
            fi
            return 0
            ;;
        s|search) _a_search ;;
        a|add)    _a_add ;;
        "")
            if command -v gum &>/dev/null; then
                local choice
                choice=$(gum choose --cursor-prefix "→ " \
                    --cursor.foreground "#eb6f92" \
                    --selected.foreground "#c4a7e7" \
                    --header "Aliases" --header.foreground "#9ccfd8" \
                    "search    fuzzy search" \
                    "add       create new alias") || return 1
                case "${choice%% *}" in
                    search) _a_search ;;
                    add)    _a_add ;;
                esac
            else
                a --help; return 1
            fi
            ;;
        *) _err "Unknown: a $1"; return 1 ;;
    esac
}

_a_search() {
    command -v gum &>/dev/null || { _err "Requires gum"; return 1; }
    {
        printf '%-20s → %s\n' "g" "git hub: branch, commit, diff, log, status"
        printf '%-20s → %s\n' "g b" "git new branch (interactive)"
        printf '%-20s → %s\n' "g c" "git commit (interactive)"
        printf '%-20s → %s\n' "g d" "git diff (delta)"
        printf '%-20s → %s\n' "g l" "git log (rose pine)"
        printf '%-20s → %s\n' "g s" "git status --short"
        printf '%-20s → %s\n' "a" "alias hub: search, add"
        printf '%-20s → %s\n' "u" "utils hub: extract, help, path, ports, tree, dirs"
        printf '%-20s → %s\n' "u h <cmd>" "tldr cheatsheet"
        printf '%-20s → %s\n' "u z" "top zoxide directories"
        printf '%-20s → %s\n' "u t" "directory tree (eza)"
        printf '%-20s → %s\n' "u p" "show PATH entries"
        printf '%-20s → %s\n' "f" "fix last failed command (thefuck)"
        printf '%-20s → %s\n' "z <dir>" "smart cd (zoxide)"
        echo "──────────────────── ─ ──────────────────"
        alias | sort | while read -r line; do
            printf '%-20s → %s\n' "${line%%=*}" "${${line#*=}//\'/}"
        done
    } | gum filter \
        --placeholder "Search commands & aliases..." \
        --indicator.foreground "#eb6f92" \
        --match.foreground "#c4a7e7" \
        --prompt.foreground "#9ccfd8" \
        --header "Type to filter" --header.foreground "#908caa"
}

_a_add() {
    command -v gum &>/dev/null || { _err "Requires gum"; return 1; }
    [[ -n "$TERM_CONFIGS_DIR" ]] || { _err "Run install.sh first — TERM_CONFIGS_DIR not set"; return 1; }

    local file name cmd

    file=$(gum choose --cursor-prefix "→ " \
        --cursor.foreground "#eb6f92" \
        --selected.foreground "#c4a7e7" \
        --header "Add alias to:" --header.foreground "#9ccfd8" \
        "git.zsh" \
        "utils.zsh") || return 1

    local file_hint
    case "$file" in
        git.zsh)   file_hint="git-related aliases and shortcuts" ;;
        utils.zsh) file_hint="general aliases, tools, and shortcuts" ;;
    esac
    gum style --foreground "#908caa" --margin "0 2" "  ${file}: ${file_hint}"

    name=$(gum input \
        --header "Alias name" --header.foreground "#9ccfd8" \
        --placeholder "e.g. gd, serve, mycommand" \
        --prompt "→ " --prompt.foreground "#9ccfd8" \
        --cursor.foreground "#eb6f92") || return 1
    [[ -n "$name" ]] || { _err "Name required"; return 1; }

    cmd=$(gum input \
        --header "Command for '${name}'" --header.foreground "#9ccfd8" \
        --placeholder "e.g. git diff, python -m http.server" \
        --prompt "→ " --prompt.foreground "#9ccfd8" \
        --cursor.foreground "#eb6f92" --width 80) || return 1
    [[ -n "$cmd" ]] || { _err "Command required"; return 1; }

    local escaped_cmd="${cmd//\'/\'\\\'\'}"
    local alias_line="alias ${name}='${escaped_cmd}'"

    gum style --border rounded --border-foreground "#c4a7e7" --padding "1 2" --margin "1 0" \
        "${_bold}Preview${_nc}" \
        "" \
        "  ${_iris}${alias_line}${_nc}" \
        "" \
        "  ${_subtle}→ ${file} (${TERM_CONFIGS_MODE:-symlink})${_nc}"

    gum confirm "Add this alias?" \
        --affirmative "Yes" --negative "Cancel" \
        --selected.foreground "#c4a7e7" || { _info "Cancelled"; return 0; }

    _write_to_config "$file" "$alias_line"
    eval "$alias_line"
    _ok "Added ${_iris}${name}${_nc} → ${_subtle}${cmd}${_nc}"
}

_path_label() {
    case "$1" in
        */homebrew/*)                echo "HOMEBREW" ;;
        */.jenv/*)                   echo "JENV"     ;;
        */miniforge3/*|*/conda/*)    echo "CONDA"    ;;
        */nucli*|*/dev/nu/*)         echo "NU"       ;;
        */zinit/*)                   echo "ZINIT"    ;;
        */fzf/*)                     echo "FZF"      ;;
        */go/*)                      echo "GO"       ;;
        *TeX*|*texbin*)              echo "TEX"      ;;
        *MacGPG*)                    echo "GPG"      ;;
        *JetBrains*)                 echo "JETBRAINS";;
        *Cryptexes*|*cryptex*)       echo "SYSTEM"   ;;
        /usr/*|/bin|/sbin)           echo "SYSTEM"   ;;
        "$HOME"/*|~*)                echo "USER"     ;;
        *)                           echo ""         ;;
    esac
}

_path_color() {
    case "$1" in
        USER)      printf '%s' "$_iris"   ;;
        HOMEBREW)  printf '%s' "$_foam"   ;;
        SYSTEM)    printf '%s' "$_subtle" ;;
        "")        printf '%s' "$_subtle" ;;
        *)         printf '%s' "$_gold"   ;;
    esac
}

u() {
    case "$1" in
        -h|--help)
            if command -v gum &>/dev/null; then
                gum style --border rounded --border-foreground "#c4a7e7" --padding "1 2" --margin "1 0" \
                    "${_bold}u${_nc} ${_subtle}[command]${_nc}" \
                    "" \
                    "  ${_iris}e${_nc}  ${_subtle}extract${_nc}   unpack archive files" \
                    "  ${_iris}h${_nc}  ${_subtle}help${_nc}      tldr cheatsheet for a command" \
                    "  ${_iris}p${_nc}  ${_subtle}path${_nc}      show PATH entries" \
                    "  ${_iris}P${_nc}  ${_subtle}ports${_nc}     show listening ports" \
                    "  ${_iris}t${_nc}  ${_subtle}tree${_nc}      directory tree" \
                    "  ${_iris}z${_nc}  ${_subtle}dirs${_nc}      top zoxide directories" \
                    "" \
                    "  ${_iris}f${_nc}  ${_subtle}fix${_nc}       type after a failed command to auto-fix"
            else
                printf '\n  %su%s %s[command]%s\n\n' "$_bold" "$_nc" "$_subtle" "$_nc"
                printf '  %se%s  extract   %sunpack archive files%s\n'   "$_iris" "$_nc" "$_subtle" "$_nc"
                printf '  %sh%s  help      %stldr cheatsheet for a command%s\n' "$_iris" "$_nc" "$_subtle" "$_nc"
                printf '  %sp%s  path      %sshow PATH entries%s\n'      "$_iris" "$_nc" "$_subtle" "$_nc"
                printf '  %sP%s  ports     %sshow listening ports%s\n'   "$_iris" "$_nc" "$_subtle" "$_nc"
                printf '  %st%s  tree      %sdirectory tree%s\n'         "$_iris" "$_nc" "$_subtle" "$_nc"
                printf '  %sz%s  dirs      %stop zoxide directories%s\n\n' "$_iris" "$_nc" "$_subtle" "$_nc"
            fi
            return 0
            ;;
        e|extract) shift; extract "$@" ;;
        h|help)    shift; _u_tldr "$@" ;;
        p|path)    _u_path ;;
        P|ports)   lsof -iTCP -sTCP:LISTEN -P -n ;;
        t|tree)    shift; _u_tree "$@" ;;
        z|dirs)    _u_dirs ;;
        "")
            if command -v gum &>/dev/null; then
                local choice
                choice=$(gum choose --cursor-prefix "→ " \
                    --cursor.foreground "#eb6f92" \
                    --selected.foreground "#c4a7e7" \
                    --header "Utils" --header.foreground "#9ccfd8" \
                    "extract   unpack archive files" \
                    "help      tldr cheatsheet" \
                    "path      show PATH entries" \
                    "ports     show listening ports" \
                    "tree      directory tree" \
                    "dirs      top zoxide directories") || return 1
                case "${choice%% *}" in
                    extract) extract ;;
                    help)    _u_tldr ;;
                    path)    _u_path ;;
                    ports)   lsof -iTCP -sTCP:LISTEN -P -n ;;
                    tree)    _u_tree ;;
                    dirs)    _u_dirs ;;
                esac
            else
                u --help; return 1
            fi
            ;;
        *) _err "Unknown: u $1"; return 1 ;;
    esac
}

_u_path() {
    local i=0
    echo
    echo "$PATH" | tr ':' '\n' | while read -r dir; do
        i=$((i + 1))
        local display="${dir/#$HOME/~}"
        local label=$(_path_label "$dir")
        local color=$(_path_color "$label")
        local mark=""

        [[ -d "$dir" ]] || mark=" ${_love}✗${_nc}"

        if [[ -n "$label" ]]; then
            printf '  %s%2d%s  %s%-45s%s  %s%-10s%s%s\n' \
                "$_subtle" "$i" "$_nc" \
                "$color" "$display" "$_nc" \
                "$_subtle" "$label" "$_nc" \
                "$mark"
        else
            printf '  %s%2d%s  %s%-45s%s%s\n' \
                "$_subtle" "$i" "$_nc" \
                "$color" "$display" "$_nc" \
                "$mark"
        fi
    done
    echo
}

_u_tldr() {
    command -v tldr &>/dev/null || { _err "Install tldr: brew install tldr"; return 1; }
    if [[ $# -gt 0 ]]; then
        tldr "$@"
    elif command -v gum &>/dev/null; then
        local cmd
        cmd=$(gum input \
            --header "Look up command" --header.foreground "#9ccfd8" \
            --placeholder "e.g. tar, git-rebase, curl" \
            --prompt "→ " --prompt.foreground "#9ccfd8" \
            --cursor.foreground "#eb6f92") || return 1
        [[ -n "$cmd" ]] || return 1
        tldr "$cmd"
    else
        _err "Usage: u h <command>"
        return 1
    fi
}

_u_dirs() {
    command -v zoxide &>/dev/null || { _err "Install zoxide: brew install zoxide"; return 1; }
    echo
    zoxide query -l -s 2>/dev/null | head -20 | while read -r score dir; do
        local display="${dir/#$HOME/~}"
        printf '  %s%6.1f%s  %s%s%s\n' "$_subtle" "$score" "$_nc" "$_iris" "$display" "$_nc"
    done
    echo
}

_u_tree() {
    local depth="${1:-2}" dir="${2:-.}"
    if command -v eza &>/dev/null; then
        eza --tree --icons --level="$depth" --git-ignore --group-directories-first "$dir"
    elif command -v tree &>/dev/null; then
        tree -C -L "$depth" --dirsfirst -I 'node_modules|.git|__pycache__|.venv|.DS_Store' "$dir"
    else
        find "$dir" -maxdepth "$depth" -print | head -100 | while read -r f; do
            local indent=$(( ($(echo "$f" | tr -cd '/' | wc -c) - $(echo "$dir" | tr -cd '/' | wc -c)) ))
            printf '%*s%s\n' $((indent * 2)) '' "$(basename "$f")"
        done
    fi
}

# ── user-added ─────────────────────────────────────────────────────────────
# General aliases, tools, and shortcuts.
# Add manually or use `a a` for interactive creation.
