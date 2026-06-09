mkcd() { mkdir -p "$1" && cd "$1"; }

extract() {
    if [[ $# -eq 0 ]]; then
        printf '\n  %sextract%s %s<file>%s\n' "$_bold" "$_nc" "$_subtle" "$_nc"
        printf '  Supported: %star.gz tar.bz2 tgz tbz2 gz bz2 zip rar 7z Z tar%s\n\n' "$_subtle" "$_nc"
        return 1
    fi
    [[ -f "$1" ]] || { _err "Not a file: $1"; return 1; }
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
        *) _err "Unknown format: $1"; return 1 ;;
    esac
}

y() {
    local tmp cwd
    tmp="$(mktemp -t yazi-cwd.XXXXX)"
    yazi "$@" --cwd-file="$tmp"
    cwd="$(cat -- "$tmp")"
    [[ -n "$cwd" && "$cwd" != "$PWD" ]] && cd -- "$cwd"
    rm -f -- "$tmp"
}

bj() {
    local n=${#jobstates}
    (( n )) || { _info "No background jobs"; return 0; }

    local modefile actionfile
    modefile=$(mktemp);   printf 'normal' > "$modefile"
    actionfile=$(mktemp); printf 'fg'     > "$actionfile"

    local line
    line=$(jobs -l | fzf --ansi --reverse --no-sort \
        --header '  enter fg  ·  d disown  ·  x kill  ·  j/k nav  ·  i search  ·  esc quit' \
        --prompt '  jobs → ' \
        --pointer '→' \
        --bind 'start:disable-search' \
        --bind 'j:down' \
        --bind 'k:up' \
        --bind "i:enable-search+change-prompt(/ )+unbind(j,k)+execute-silent(printf insert > '$modefile')" \
        --bind "esc:transform(m=\$(cat '$modefile'); if [[ \$m == insert ]]; then printf '%s' 'disable-search+change-prompt(  jobs → )+rebind(j,k)+execute-silent(printf normal > $modefile)'; else printf '%s' abort; fi)" \
        --bind "enter:execute-silent(printf fg     > '$actionfile')+accept" \
        --bind "d:execute-silent(printf disown > '$actionfile')+accept" \
        --bind "x:execute-silent(printf kill   > '$actionfile')+accept" \
        --color 'fg:#908caa,fg+:#e0def4,hl:#c4a7e7,hl+:#eb6f92,pointer:#eb6f92,header:#908caa,border:#c4a7e7,info:#9ccfd8')

    local action; action=$(cat "$actionfile")
    rm -f "$modefile" "$actionfile"
    [[ -z "$line" ]] && return 0

    local jobnum
    jobnum=$(printf '%s' "$line" | /usr/bin/grep -oE '\[([0-9]+)\]' | head -1 | tr -d '[]')
    [[ -z "$jobnum" ]] && return 0

    case "$action" in
        fg)     fg %"$jobnum" ;;
        disown) disown %"$jobnum" && _ok "Disowned job %${jobnum}" ;;
        kill)   kill %"$jobnum"   && _ok "Killed job %${jobnum}" ;;
    esac
}

_u_search() {
    {
        cat <<'COMMANDS'
help                 → command reference (git, utils, tmux)
u s                  → fuzzy search aliases+commands
u e <file>           → extract archive
u h <cmd>            → tldr cheatsheet
u z                  → top zoxide directories
u t                  → directory tree (eza)
u p                  → show PATH entries
u P                  → show listening ports
u j                  → manage background jobs (fg/disown/kill)
f                    → fix last failed command (thefuck)
z <dir>              → smart cd (zoxide)
y                    → yazi file manager
COMMANDS
        alias | sort | while read -r line; do
            printf '%-20s → %s\n' "${line%%=*}" "${${line#*=}//\'/}"
        done
    } | fzf --ansi --reverse --no-sort \
        --prompt '  ' \
        --header '  type to filter' \
        --color 'fg:#908caa,fg+:#e0def4,hl:#c4a7e7,hl+:#eb6f92,pointer:#eb6f92,header:#908caa,info:#9ccfd8'
}

_u_path() {
    local i=0
    echo
    echo "$PATH" | tr ':' '\n' | while read -r dir; do
        i=$((i + 1))
        local display="${dir/#$HOME/~}"
        local mark=""
        [[ -d "$dir" ]] || mark=" ${_love}✗${_nc}"
        printf '  %s%2d%s  %s%-50s%s%s\n' "$_subtle" "$i" "$_nc" "$_iris" "$display" "$_nc" "$mark"
    done
    echo
}

_u_tldr() {
    command -v tldr &>/dev/null || { _err "tldr not installed"; return 1; }
    [[ $# -gt 0 ]] && { tldr "$@"; return; }
    _err "Usage: u h <command>"
    return 1
}

_u_dirs() {
    command -v zoxide &>/dev/null || { _err "zoxide not installed"; return 1; }
    echo
    zoxide query -l -s 2>/dev/null | head -20 | while read -r score dir; do
        printf '  %s%6.1f%s  %s%s%s\n' "$_subtle" "$score" "$_nc" "$_iris" "${dir/#$HOME/\~}" "$_nc"
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
        find "$dir" -maxdepth "$depth" -print | head -100
    fi
}

_u_ports() {
    if command -v lsof &>/dev/null; then
        lsof -iTCP -sTCP:LISTEN -P -n
    elif command -v ss &>/dev/null; then
        ss -tlnp
    else
        _err "Neither lsof nor ss found"
    fi
}

help() {
    local i="$_iris" n="$_nc" s="$_subtle"
    _hr() { printf '  %s── %s %s\n' "$s" "$1" "$n"; }
    _r()  { printf '  %s%-5s%s %-14s' "$i" "$1" "$n" "$2"; }
    _rn() { printf '  %s%-5s%s %s\n' "$i" "$1" "$n" "$2"; }

    printf '\n'
    _hr "git"
    _r "ga"   "add"         ; _r "gaa"  "add --all"     ; _rn "gc"   "commit"
    _r "gcm"  "commit -m"   ; _r "gcam" "add+commit -m" ; _rn "gp"   "push"
    _r "gpf"  "push --force"; _r "gl"   "pull"          ; _rn "gcb"  "checkout -b"
    _r "gd"   "diff"        ; _r "gds"  "diff --staged" ; _rn "gst"  "status"
    _r "gco"  "checkout"    ; _r "gsw"  "switch"        ; _rn "glog" "log --graph"
    _r "gsta" "stash"       ; _r "gstp" "stash pop"     ; _rn "grb"  "rebase"
    _r "grbi" "rebase -i"   ; _r "gab"  "absorb+rebase" ; _rn "gsb"  "switch branch"
    _rn "gnb" "new branch"
    printf '\n'

    _hr "utils"
    _r "u s"  "search"      ; _r "u e"  "extract"       ; _rn "u h"  "tldr"
    _r "u p"  "PATH"        ; _r "u P"  "ports"         ; _rn "u t"  "tree"
    _r "u z"  "zoxide dirs" ; _r "u j"  "bg jobs"       ; _rn "y"    "yazi"
    _r "f"    "thefuck"     ; _rn "z"   "zoxide cd"
    printf '\n'

    _hr "tmux (\`)"
    _r "v"    "split right" ; _r "s"    "split down"    ; _rn "c"    "new window"
    _r "z"    "zoom"        ; _r "x"    "kill pane"     ; _rn "X"    "kill window"
    _r "f"    "sessionizer" ; _r "g"    "lazygit"       ; _rn "t"    "popup shell"
    _r "w"    "fzf picker"  ; _r "?"    "cheatsheet"    ; _rn "/"    "guide"
    _r "Space" "thumbs"     ; _r "e"    "extrakto"      ; _rn "Enter" "copy mode"
    _r "C-s"  "save"        ; _rn "C-r" "restore"
    printf '  %sC-h/j/k/l%s  vim+tmux nav (no prefix)\n' "$i" "$n"
    printf '\n'

    _hr "projects"
    _rn "tm"  "sessionizer"
    _rn "sessionizer-add" "register or scaffold"
    printf '\n'
}

u() {
    case "${1:-}" in
        s|search)  _u_search ;;
        e|extract) shift; extract "$@" ;;
        h|help)    shift; _u_tldr "$@" ;;
        p|path)    _u_path ;;
        P|ports)   _u_ports ;;
        t|tree)    shift; _u_tree "$@" ;;
        z|dirs)    _u_dirs ;;
        j|jobs)    bj ;;
        *)
            printf '\n  %su%s %s<command>%s\n\n' "$_bold" "$_nc" "$_subtle" "$_nc"
            printf '  %ss%s  search    %sfuzzy search aliases+commands%s\n' "$_iris" "$_nc" "$_subtle" "$_nc"
            printf '  %se%s  extract   %sunpack archive files%s\n'         "$_iris" "$_nc" "$_subtle" "$_nc"
            printf '  %sh%s  help      %stldr cheatsheet for a command%s\n' "$_iris" "$_nc" "$_subtle" "$_nc"
            printf '  %sp%s  path      %sshow PATH entries%s\n'            "$_iris" "$_nc" "$_subtle" "$_nc"
            printf '  %sP%s  ports     %sshow listening ports%s\n'         "$_iris" "$_nc" "$_subtle" "$_nc"
            printf '  %st%s  tree      %sdirectory tree%s\n'               "$_iris" "$_nc" "$_subtle" "$_nc"
            printf '  %sz%s  dirs      %stop zoxide directories%s\n'       "$_iris" "$_nc" "$_subtle" "$_nc"
            printf '  %sj%s  jobs      %smanage background jobs%s\n\n'     "$_iris" "$_nc" "$_subtle" "$_nc"
            ;;
    esac
}
