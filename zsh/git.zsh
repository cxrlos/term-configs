gnb() {
    local type desc

    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        _gnb_usage; return 0
    fi

    if [[ $# -eq 0 ]]; then
        if command -v gum &>/dev/null; then
            type=$(gum choose --cursor-prefix "→ " \
                --cursor.foreground "#eb6f92" \
                --selected.foreground "#c4a7e7" \
                --header "Branch type" --header.foreground "#9ccfd8" \
                feat fix refactor docs test) || return 1
            desc=$(gum input \
                --header "Branch: $(date +%Y-%m-%d)/${type}/..." \
                --header.foreground "#908caa" \
                --placeholder "description (spaces become hyphens)" \
                --prompt "→ " --prompt.foreground "#9ccfd8" \
                --cursor.foreground "#eb6f92") || return 1
            [[ -n "$desc" ]] || { _err "Description required"; return 1; }
        else
            _gnb_usage; return 1
        fi
    elif [[ $# -eq 1 ]]; then
        type="$1"
        case "$type" in
            feat|fix|refactor|docs|test) ;;
            *) _err "Unknown type: ${_bold}$type${_nc}  ${_subtle}(valid: feat fix refactor docs test)${_nc}"; return 1 ;;
        esac
        if command -v gum &>/dev/null; then
            desc=$(gum input \
                --header "Branch: $(date +%Y-%m-%d)/${type}/..." \
                --header.foreground "#908caa" \
                --placeholder "description (spaces become hyphens)" \
                --prompt "→ " --prompt.foreground "#9ccfd8" \
                --cursor.foreground "#eb6f92") || return 1
            [[ -n "$desc" ]] || { _err "Description required"; return 1; }
        else
            _err "Missing description: ${_bold}gnb $type${_nc} ${_subtle}<desc...>${_nc}"
            return 1
        fi
    else
        type="$1"
        desc="${*:2}"
        case "$type" in
            feat|fix|refactor|docs|test) ;;
            *) _err "Unknown type: ${_bold}$type${_nc}  ${_subtle}(valid: feat fix refactor docs test)${_nc}"; return 1 ;;
        esac
    fi

    desc="${desc// /-}"
    desc="${(L)desc}"

    git rev-parse --git-dir &>/dev/null || { _err "Not a git repo"; return 1; }

    local branch
    branch="$(date +%Y-%m-%d)/${type}/${desc}"
    git checkout -b "$branch" && _ok "Branch: ${_iris}${branch}${_nc}"
}

_gnb_usage() {
    if command -v gum &>/dev/null; then
        gum style --border rounded --border-foreground "#c4a7e7" --padding "1 2" --margin "1 0" \
            "${_bold}gnb${_nc} ${_subtle}<type> <desc...>${_nc}" \
            "" \
            "${_subtle}Creates branch: YYYY-MM-DD/type/desc${_nc}" \
            "" \
            "  ${_iris}feat${_nc}       ${_subtle}new feature${_nc}" \
            "  ${_iris}fix${_nc}        ${_subtle}bug fix${_nc}" \
            "  ${_iris}refactor${_nc}   ${_subtle}code restructure${_nc}" \
            "  ${_iris}docs${_nc}       ${_subtle}documentation${_nc}" \
            "  ${_iris}test${_nc}       ${_subtle}test coverage${_nc}" \
            "" \
            "${_subtle}Shortcuts: gbf gbb gbr gbd gbt${_nc}"
    else
        printf '\n  %sgnb%s %s<type>%s %s<desc...>%s\n' "$_bold" "$_nc" "$_iris" "$_nc" "$_subtle" "$_nc"
        printf '  Creates: %sYYYY-MM-DD/type/desc%s\n\n' "$_subtle" "$_nc"
        printf '  %sfeat%s       %snew feature%s\n'       "$_iris" "$_nc" "$_subtle" "$_nc"
        printf '  %sfix%s        %sbug fix%s\n'            "$_iris" "$_nc" "$_subtle" "$_nc"
        printf '  %srefactor%s   %scode restructure%s\n'   "$_iris" "$_nc" "$_subtle" "$_nc"
        printf '  %sdocs%s       %sdocumentation%s\n'      "$_iris" "$_nc" "$_subtle" "$_nc"
        printf '  %stest%s       %stest coverage%s\n\n'    "$_iris" "$_nc" "$_subtle" "$_nc"
    fi
}

g() {
    case "$1" in
        -h|--help)
            if command -v gum &>/dev/null; then
                gum style --border rounded --border-foreground "#c4a7e7" --padding "1 2" --margin "1 0" \
                    "${_bold}g${_nc} ${_subtle}[command]${_nc}" \
                    "" \
                    "  ${_iris}b${_nc}  ${_subtle}branch${_nc}    create conventional branch" \
                    "  ${_iris}c${_nc}  ${_subtle}commit${_nc}    interactive commit" \
                    "  ${_iris}d${_nc}  ${_subtle}diff${_nc}      diff with delta" \
                    "  ${_iris}l${_nc}  ${_subtle}log${_nc}       pretty git log" \
                    "  ${_iris}s${_nc}  ${_subtle}status${_nc}    short status"
            else
                printf '\n  %sg%s %s[command]%s\n\n' "$_bold" "$_nc" "$_subtle" "$_nc"
                printf '  %sb%s  branch    %screate conventional branch%s\n' "$_iris" "$_nc" "$_subtle" "$_nc"
                printf '  %sc%s  commit    %sinteractive commit%s\n'         "$_iris" "$_nc" "$_subtle" "$_nc"
                printf '  %sd%s  diff      %sdiff with delta%s\n'            "$_iris" "$_nc" "$_subtle" "$_nc"
                printf '  %sl%s  log       %spretty git log%s\n'             "$_iris" "$_nc" "$_subtle" "$_nc"
                printf '  %ss%s  status    %sshort status%s\n\n'             "$_iris" "$_nc" "$_subtle" "$_nc"
            fi
            return 0
            ;;
        b|branch)  shift; gnb "$@" ;;
        c|commit)  shift; _g_commit "$@" ;;
        d|diff)    shift; _g_diff "$@" ;;
        l|log)     shift; _g_log "$@" ;;
        s|status)  shift; _g_status "$@" ;;
        "")
            if command -v gum &>/dev/null; then
                local choice
                choice=$(gum choose --cursor-prefix "→ " \
                    --cursor.foreground "#eb6f92" \
                    --selected.foreground "#c4a7e7" \
                    --header "Git" --header.foreground "#9ccfd8" \
                    "branch    create conventional branch" \
                    "commit    interactive commit" \
                    "diff      compare changes" \
                    "log       commit history" \
                    "status    working tree state") || return 1
                case "${choice%% *}" in
                    branch) gnb ;;
                    commit) _g_commit ;;
                    diff)   _g_diff ;;
                    log)    _g_log --pick ;;
                    status) _g_status --pick ;;
                esac
            else
                g --help; return 1
            fi
            ;;
        *) _err "Unknown: g $1"; return 1 ;;
    esac
}

_g_commit() {
    git rev-parse --git-dir &>/dev/null || { _err "Not a git repo"; return 1; }

    if [[ -n "$*" ]]; then
        git commit -m "$*"; return
    fi

    if ! git diff --cached --quiet 2>/dev/null; then
        _info "Staged changes ready"
    elif ! git diff --quiet 2>/dev/null; then
        if command -v gum &>/dev/null; then
            gum confirm "Nothing staged. Stage all changes?" \
                --affirmative "Yes" --negative "No" \
                --selected.foreground "#c4a7e7" && git add .
        else
            _warn "Nothing staged — run ga/gaa first"
            return 1
        fi
    else
        _warn "No changes to commit"
        return 1
    fi

    if command -v gum &>/dev/null; then
        local msg
        msg=$(gum input \
            --header "Commit message" --header.foreground "#9ccfd8" \
            --placeholder "feat: add user authentication" \
            --prompt "→ " --prompt.foreground "#9ccfd8" \
            --cursor.foreground "#eb6f92" --width 72) || return 1
        [[ -n "$msg" ]] || { _err "Message required"; return 1; }
        git commit -m "$msg"
    else
        git commit
    fi
}

# %x09 embeds a literal tab in git format — awk splits on it to read fields without
# ANSI interference. Fields: $1=graph+commit, $2=unix-ts, $3=name, $4=email.
_g_log_fmt_cols() {
    local raw=${COLUMNS:-0}
    (( raw > 0 )) || raw=$(tput cols 2>/dev/null)
    (( ${raw:-0} > 0 )) || raw=120
    local cols=$(( raw - 2 ))
    local sw=$(( cols - 70 ))
    (( sw < 20 )) && sw=20
    echo "%C(#9ccfd8)%h%Creset -%C(#eb6f92)%d%Creset %<(${sw},trunc)%s%x09%ct%x09%aN%x09%aE"
}

# Requires -v me=NAME -v now=EPOCH -v cols=COLS (macOS awk lacks systime(); pass now from shell).
# GitHub no-reply format: N+handle@users.noreply.github.com → handle extracted after +.
# -> in refs is replaced with → (U+2192).
# "you" matched against user.name; hardcoded aliases cover past machine-specific user.name values.
_g_log_awk='
function ansi_trunc(s, maxw,    i, c, seq, vis, out) {
    seq = 0; vis = 0; out = ""
    for (i = 1; i <= length(s); i++) {
        c = substr(s, i, 1)
        if (seq) { out = out c; if (c == "m") seq = 0 }
        else if (c == "\033") { seq = 1; out = out c }
        else { if (vis >= maxw) { out = out ".."; break }; out = out c; vis++ }
    }
    return out
}
BEGIN { FS = "\t"; if (cols == 0) cols = 120 }
NF >= 4 {
    ts = $2 + 0; d = now - ts
    if      (d < 60)        t = d "s"
    else if (d < 3600)      t = int(d / 60) "m"
    else if (d < 86400)     t = int(d / 3600) "h"
    else if (d < 604800)    t = int(d / 86400) "d"
    else if (d < 2592000)   t = int(d / 604800) "w"
    else if (d < 31536000)  t = int(d / 2592000) "mo"
    else                    t = int(d / 31536000) "y"
    email = $4
    if (split(email, ep, "@") == 2 && ep[2] == "users.noreply.github.com") {
        n = split(ep[1], up, "+"); handle = up[n]
    } else {
        handle = ep[1]
    }
    sub(/\[bot\]$/, "", handle)
    if (length(handle) > 17) handle = substr(handle, 1, 17)
    if ($3 == "cxrlos" || $3 == "Carlos Garcia" || $3 == "carloss.garciag" || (me != "" && $3 == me)) {
        avis = 3; author = "\033[1;3;38;2;196;167;231myou\033[0m"
    } else {
        h = "@" handle; avis = length(h)
        author = "\033[38;2;196;167;231m" h "\033[0m"
    }
    v1 = $1; gsub(/\033\[[0-9;]*m/, "", v1)
    n_arr = split(v1, _a, "->") - 1
    vlen = length(v1) - n_arr
    min_right = avis + 8; if (min_right < 22) min_right = 22
    if (vlen > cols - min_right) {
        $1 = ansi_trunc($1, cols - min_right - 2)
        vlen = cols - min_right
    }
    gsub(/->/, "\342\206\222", $1)
    mid = cols - vlen - avis - 6; if (mid < 2) mid = 2
    printf "%s%*s\033[38;2;49;116;143m%4s\033[0m %s\n", $1, mid, "", t, author; next
}
{ print }'

_g_log_awk_pipe() {
    local offset=${1:-0}
    local raw=${COLUMNS:-0}
    (( raw > 0 )) || raw=$(tput cols 2>/dev/null)
    (( ${raw:-0} > 0 )) || raw=120
    local cols=$(( raw - offset ))
    awk -v me="$(git config user.name 2>/dev/null)" -v now="$(date +%s)" -v cols="$cols" "$_g_log_awk"
}

_g_log_footer() {
    printf '\n  %sh%s hash  %s\342\216\267%s ref  %s~%s age  %s@%s author\n\n' \
        "$_foam" "$_nc" "$_love" "$_nc" "$_pine" "$_nc" "$_iris" "$_nc"
}

_glol_fzf() {
    local tmpcount tmpscript modefile total_commits
    tmpcount=$(mktemp)
    tmpscript=$(mktemp)
    modefile=$(mktemp)
    echo normal > "$modefile"

    local rev_args=()
    for a in "$@"; do [[ $a == --* ]] && rev_args+=("$a"); done
    if (( ${#rev_args} )); then
        total_commits=$(git rev-list --count "${rev_args[@]}" 2>/dev/null) || total_commits=99999
    else
        total_commits=$(git rev-list --count HEAD 2>/dev/null) || total_commits=99999
    fi

    local paginate=0
    (( total_commits > 1000 )) && paginate=1
    echo $(( paginate ? 1000 : total_commits )) > "$tmpcount"

    # Bake format + awk + extra git args into a reload script to avoid quoting hell
    {
        printf '#!/bin/zsh\n'
        printf 'n=$(cat %q)\n' "$tmpcount"
        printf 'me=$(git config user.name 2>/dev/null)\n'
        printf 'now=$(date +%%s)\n'
        printf 'cols=$(tput cols 2>/dev/null); (( ${cols:-0} > 0 )) || cols=120\n'
        printf 'acols=$(( cols - 2 ))\n'
        printf 'sw=$(( acols - 70 ))\n'
        printf '(( sw < 20 )) && sw=20\n'
        printf 'fmt="%%C(#9ccfd8)%%h%%Creset -%%C(#eb6f92)%%d%%Creset %%<(${sw},trunc)%%s%%x09%%ct%%x09%%aN%%x09%%aE"\n'
        printf 'git log --graph --color=always --pretty=format:"$fmt" --abbrev-commit'
        for a in "$@"; do printf ' %q' "$a"; done
        printf ' --max-count=$n | awk -v me="$me" -v now="$now" -v cols="$acols" %q\n' "$_g_log_awk"
    } > "$tmpscript"
    chmod +x "$tmpscript"

    local _hints='  ?  preview    ctrl-y  copy'
    (( paginate )) && _hints+='    ctrl-f  +1000'
    _hints+='    i  search    esc  back/quit'

    local _header
    (( paginate )) && _header="  1000 loaded+$_hints" || _header="$_hints"

    local max_flag=()
    (( paginate )) && max_flag=(--max-count=1000)

    local fzf_args=(
        --ansi --no-sort --reverse
        --info default
        --prompt '  '
        --pointer '→'
        --preview "h=\$(echo {} | /usr/bin/grep -oE '[0-9a-f]{7,}' | head -1); [[ -n \$h ]] && git show --color=always \"\$h\" || true"
        --preview-window 'right:55%:hidden:wrap'
        --bind 'start:disable-search'
        --bind 'j:down'
        --bind 'k:up'
        --bind 'h:preview-half-page-up'
        --bind 'l:preview-half-page-down'
        --bind "i:enable-search+change-prompt(/ )+unbind(j,k,h,l)+execute-silent(echo insert > '$modefile')"
        --bind "esc:transform(m=\$(cat '$modefile'); if [[ \$m == insert ]]; then printf '%s' 'disable-search+change-prompt(  )+rebind(j,k,h,l)+execute-silent(echo normal > $modefile)'; else printf '%s' abort; fi)"
        --bind '?:toggle-preview'
        --bind "ctrl-y:execute-silent(echo {} | /usr/bin/grep -oE '[0-9a-f]{7,}' | head -1 | pbcopy)"
        --header "$_header"
        --color 'fg:#908caa,fg+:#e0def4,hl:#c4a7e7,hl+:#eb6f92,pointer:#eb6f92,header:#908caa,border:#c4a7e7,info:#9ccfd8'
    )

    if (( paginate )); then
        fzf_args+=(
            --bind "ctrl-f:execute-silent(c=\$(cat '$tmpcount'); echo \$((c+1000)) > '$tmpcount')+reload('$tmpscript')+transform-header(printf '  %s loaded+%s\n' \"\$(cat '$tmpcount')\" '$_hints')"
        )
    fi

    git log --graph --color=always --pretty=format:"$(_g_log_fmt_cols)" --abbrev-commit "$@" "${max_flag[@]}" \
        | _g_log_awk_pipe 2 \
        | fzf "${fzf_args[@]}"

    rm -f "$tmpcount" "$tmpscript" "$modefile"
}

glol() {
    git rev-parse --git-dir &>/dev/null || { _err "Not a git repo"; return 1; }
    local branch
    branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
    printf '\n  %s\356\234\245  %s%s%s\n\n' "$_subtle" "$_foam" "$branch" "$_nc"
    if [[ -t 1 ]] && command -v fzf &>/dev/null; then
        _glol_fzf "$@"
    else
        git log --graph --color=always --pretty=format:"$(_g_log_fmt_cols)" --abbrev-commit "$@" | _g_log_awk_pipe
        _g_log_footer
    fi
}

glols() {
    git rev-parse --git-dir &>/dev/null || { _err "Not a git repo"; return 1; }
    local branch
    branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
    {
        printf '\n  %s\356\234\245  %s%s%s  %swith stats%s\n\n' "$_subtle" "$_foam" "$branch" "$_nc" "$_subtle" "$_nc"
        git log --graph --color=always --pretty=format:"$(_g_log_fmt_cols)" --abbrev-commit --stat "$@" | _g_log_awk_pipe
        _g_log_footer
    } | less -R
}

glola() {
    git rev-parse --git-dir &>/dev/null || { _err "Not a git repo"; return 1; }
    printf '\n  %s\356\234\245  %sall branches%s\n\n' "$_subtle" "$_foam" "$_nc"
    if [[ -t 1 ]] && command -v fzf &>/dev/null; then
        _glol_fzf --all "$@"
    else
        git log --graph --color=always --pretty=format:"$(_g_log_fmt_cols)" --abbrev-commit --all "$@" | _g_log_awk_pipe
        _g_log_footer
    fi
}

_g_log() {
    git rev-parse --git-dir &>/dev/null || { _err "Not a git repo"; return 1; }
    if [[ "$1" == "--pick" ]] && command -v gum &>/dev/null; then
        local variant
        variant=$(gum choose --cursor-prefix "→ " \
            --cursor.foreground "#eb6f92" \
            --selected.foreground "#c4a7e7" \
            --header "Log format" --header.foreground "#9ccfd8" \
            "oneline    compact graph" \
            "stats      with file changes" \
            "all        all branches" \
            "full       default git log") || return 1
        case "${variant%% *}" in
            oneline) glol ;;
            stats)   glols ;;
            all)     glola ;;
            full)    git log ;;
        esac
    else
        glol "$@"
    fi
}

_g_diff() {
    git rev-parse --git-dir &>/dev/null || { _err "Not a git repo"; return 1; }

    local -a diff_args=() preview_extra=()
    local scope_label='unstaged'

    case "$1" in
        --staged|--cached) diff_args=(--staged); preview_extra=(--staged); scope_label='staged' ;;
        HEAD)              diff_args=(HEAD);     preview_extra=(HEAD);     scope_label='vs HEAD' ;;
        ""|-p|--pick)      ;;
        *)                 git diff "$@"; return ;;
    esac

    if [[ -t 1 ]] && command -v fzf &>/dev/null; then
        local files
        files=$(git diff --name-only "${diff_args[@]}" 2>/dev/null)
        if [[ -z "$files" ]]; then
            _info "No $scope_label changes"; return 0
        fi
        local preview_cmd="git diff --color=always ${preview_extra[*]} -- {}"
        local modefile
        modefile=$(mktemp)
        echo normal > "$modefile"
        printf '%s\n' "$files" \
        | fzf --ansi --reverse \
            --preview "$preview_cmd" \
            --preview-window 'right:65%:wrap' \
            --prompt "  $scope_label → " \
            --pointer '→' \
            --header "  ?  diff    j/k  nav    i  search    ctrl-y  copy    esc  back/quit" \
            --bind 'start:disable-search' \
            --bind 'j:down' \
            --bind 'k:up' \
            --bind 'h:preview-half-page-up' \
            --bind 'l:preview-half-page-down' \
            --bind "i:enable-search+change-prompt(/ )+unbind(j,k,h,l)+execute-silent(echo insert > '$modefile')" \
            --bind "esc:transform(m=\$(cat '$modefile'); if [[ \$m == insert ]]; then printf '%s' 'disable-search+change-prompt(  ${scope_label} → )+rebind(j,k,h,l)+execute-silent(echo normal > $modefile)'; else printf '%s' abort; fi)" \
            --bind '?:toggle-preview' \
            --bind "ctrl-y:execute-silent(echo {} | pbcopy)" \
            --color 'fg:#908caa,fg+:#e0def4,hl:#c4a7e7,hl+:#eb6f92,pointer:#eb6f92,header:#908caa,border:#c4a7e7,info:#9ccfd8'
        rm -f "$modefile"
    else
        git diff "${diff_args[@]}"
    fi
}

_g_status() {
    if [[ "$1" == "--pick" ]] && command -v gum &>/dev/null; then
        local variant
        variant=$(gum choose --cursor-prefix "→ " \
            --cursor.foreground "#eb6f92" \
            --selected.foreground "#c4a7e7" \
            --header "Status format" --header.foreground "#9ccfd8" \
            "short      compact one-liner per file" \
            "full       default verbose output" \
            "branch     branch tracking info") || return 1
        case "${variant%% *}" in
            short)  gss ;;
            full)   git status ;;
            branch) git status --short --branch ;;
        esac
    else
        gss
    fi
}

gss() {
    git rev-parse --git-dir &>/dev/null || { _err "Not a git repo"; return 1; }

    local porcelain branch
    porcelain=$(git status --porcelain -u 2>/dev/null)
    [[ -z "$porcelain" ]] && { printf '\n  %s✓%s  clean\n\n' "$_pine" "$_nc"; return 0; }
    branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)

    printf '%s\n' "$porcelain" | awk \
        -v branch="$branch" \
        -v subtle="$_subtle" -v nc="$_nc" \
        -v love="$_love" -v gold="$_gold" -v pine="$_pine" \
        -v foam="$_foam" -v iris="$_iris" \
    'BEGIN { n=0; nd=0; ns=0; nu=0; nk=0 }
    {
        X=substr($0,1,1); Y=substr($0,2,1); raw=substr($0,4)
        if (raw ~ / -> /) { split(raw,p," -> "); raw=p[2] }
        sub(/\/$/, "", raw)
        if (X!=" " && X!="?") ns++
        if (Y!=" " && Y!="?") nu++
        if (X=="?" && Y=="?") nk++
        if      (X=="U"||Y=="U") sym="!"
        else if (X=="D"||Y=="D") sym="-"
        else if (X=="R")         sym="r"
        else if (X=="A")         sym="+"
        else if (X=="M"||Y=="M") sym="~"
        else if (X=="?"&&Y=="?") sym="?"
        else                     sym="."
        if (raw~/\//) { dir=raw; sub(/\/[^\/]*$/,"",dir); fname=raw; sub(/.*\//,"",fname) }
        else          { dir="."; fname=raw }
        syms[++n]=sym; fnames[n]=fname; dirs[n]=dir
        if (!seen[dir]++) dir_order[++nd]=dir
    }
    END {
        printf "\n  %s\356\234\245  %s%s%s", subtle, foam, branch, nc
        if (ns>0) printf "    %s%d staged%s",   pine, ns, nc
        if (nu>0) printf "  %s%d modified%s",   gold, nu, nc
        if (nk>0) printf "  %s%d untracked%s",  iris, nk, nc
        printf "\n\n"
        for (di=1; di<=nd; di++) {
            dir=dir_order[di]; ld=(di==nd)
            dc = ld ? "\342\224\224\342\224\200\342\224\200" : "\342\224\234\342\224\200\342\224\200"
            dt = ld ? "    " : "\342\224\202   "
            if (dir!=".") printf "  %s%s%s %s%s/%s\n", subtle,dc,nc, subtle,dir,nc
            ind = (dir==".") ? "  " : "  "dt
            fc=0; for (fi=1;fi<=n;fi++) if (dirs[fi]==dir) fc++
            fic=0
            for (fi=1;fi<=n;fi++) {
                if (dirs[fi]!=dir) continue
                fic++
                fconn = (fic==fc) ? "\342\224\224\342\224\200\342\224\200" : "\342\224\234\342\224\200\342\224\200"
                s=syms[fi]; f=fnames[fi]
                if      (s=="?") col=iris
                else if (s=="+") col=pine
                else if (s=="~") col=gold
                else if (s=="-"||s=="!") col=love
                else if (s=="r") col=foam
                else             col=subtle
                ds = (s=="r") ? "\342\206\222" : s
                printf "%s%s%s%s %s%s%s %s\n", ind,subtle,fconn,nc, col,ds,nc, f
            }
        }
        printf "\n  %s+%s added  %s~%s modified  %s-%s deleted  %s\342\206\222%s renamed  %s?%s untracked  %s!%s conflict\n\n", \
            pine,nc, gold,nc, love,nc, foam,nc, iris,nc, love,nc
    }'
}

alias ga='git add'
alias gaa='git add --all'
alias gc='git commit'
alias gcm='git commit -m'
alias gcam='git add . && git commit -m'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gl='git pull'
alias glom='git pull origin master'
alias glomm='git pull origin main'
gco() {
    git rev-parse --git-dir &>/dev/null || { _err "Not a git repo"; return 1; }

    if [[ "$1" == -* ]] || [[ $# -gt 1 ]]; then
        git checkout "$@"; return
    fi

    if ! command -v fzf &>/dev/null || [[ ! -t 1 ]]; then
        git checkout "$@"; return
    fi

    if [[ $# -eq 1 ]] && git rev-parse --verify --quiet "$1" &>/dev/null; then
        git checkout "$1" && _ok "→ ${_iris}$1${_nc}"; return
    fi

    local query="${1:-}"
    local modefile branch ret
    modefile=$(mktemp)
    echo normal > "$modefile"

    branch=$(git branch --all --format='%(refname:short)' \
        | sed 's|^origin/||' \
        | grep -v '^HEAD$' \
        | sort -u \
        | fzf --ansi --reverse \
            --query "$query" \
            --preview 'git log --color=always --pretty=format:"%C(#9ccfd8)%h%Creset %<(50,trunc)%s %C(#31748f)%cr%Creset %C(#c4a7e7)%aN%Creset" --abbrev-commit -15 {}' \
            --preview-window 'right:55%:wrap' \
            --header '  enter  checkout    ?  preview    j/k  nav    i  search    esc  back/quit' \
            --prompt '  branch → ' \
            --pointer '→' \
            --bind 'start:disable-search' \
            --bind 'j:down' \
            --bind 'k:up' \
            --bind 'h:preview-half-page-up' \
            --bind 'l:preview-half-page-down' \
            --bind "i:enable-search+change-prompt(/ )+unbind(j,k,h,l)+execute-silent(echo insert > '$modefile')" \
            --bind "esc:transform(m=\$(cat '$modefile'); if [[ \$m == insert ]]; then printf '%s' 'disable-search+change-prompt(  branch → )+rebind(j,k,h,l)+execute-silent(echo normal > $modefile)'; else printf '%s' abort; fi)" \
            --bind '?:toggle-preview' \
            --color 'fg:#908caa,fg+:#e0def4,hl:#c4a7e7,hl+:#eb6f92,pointer:#eb6f92,header:#908caa,border:#c4a7e7,info:#9ccfd8')
    ret=$?
    rm -f "$modefile"
    (( ret != 0 )) && return 0

    [[ -z "$branch" ]] && return 0
    git checkout "$branch" && _ok "→ ${_iris}${branch}${_nc}"
}

grh() {
    git rev-parse --git-dir &>/dev/null || { _err "Not a git repo"; return 1; }

    if [[ $# -gt 0 ]]; then
        if command -v gum &>/dev/null; then
            gum confirm "Hard reset to ${_bold}$*${_nc}? Uncommitted changes will be lost." \
                --affirmative "Reset" --negative "Cancel" \
                --selected.foreground "#c4a7e7" || return 0
        fi
        git reset --hard "$@"; return
    fi

    command -v fzf &>/dev/null || { _err "Requires fzf"; return 1; }

    local modefile target ret
    modefile=$(mktemp)
    echo normal > "$modefile"

    target=$(git log --color=always --pretty=format:"$(_g_log_fmt_cols)" --abbrev-commit -100 \
        | _g_log_awk_pipe 2 \
        | fzf --ansi --no-sort --reverse \
            --preview 'h=$(echo {} | /usr/bin/grep -oE "[0-9a-f]{7,}" | head -1); [[ -n $h ]] && git show --color=always --stat "$h" || true' \
            --preview-window 'right:55%:hidden:wrap' \
            --header '  enter  reset to    ?  changes    j/k  nav    i  search    esc  back/quit' \
            --prompt '  reset → ' \
            --pointer '→' \
            --bind 'start:disable-search' \
            --bind 'j:down' \
            --bind 'k:up' \
            --bind 'h:preview-half-page-up' \
            --bind 'l:preview-half-page-down' \
            --bind "i:enable-search+change-prompt(/ )+unbind(j,k,h,l)+execute-silent(echo insert > '$modefile')" \
            --bind "esc:transform(m=\$(cat '$modefile'); if [[ \$m == insert ]]; then printf '%s' 'disable-search+change-prompt(  reset → )+rebind(j,k,h,l)+execute-silent(echo normal > $modefile)'; else printf '%s' abort; fi)" \
            --bind '?:toggle-preview' \
            --color 'fg:#908caa,fg+:#e0def4,hl:#c4a7e7,hl+:#eb6f92,pointer:#eb6f92,header:#908caa,border:#c4a7e7,info:#9ccfd8')
    ret=$?
    rm -f "$modefile"
    (( ret != 0 )) && return 0

    local hash
    hash=$(echo "$target" | /usr/bin/grep -oE '[0-9a-f]{7,}' | head -1)
    [[ -z "$hash" ]] && return 1

    if command -v gum &>/dev/null; then
        gum confirm "Hard reset to ${_iris}${hash}${_nc}? Uncommitted changes will be lost." \
            --affirmative "Reset" --negative "Cancel" \
            --selected.foreground "#c4a7e7" || return 0
    else
        printf '\n  %s!%s Hard reset to %s%s%s? Uncommitted changes will be lost. [y/N] ' \
            "$_gold" "$_nc" "$_iris" "$hash" "$_nc"
        read -r confirm
        [[ "${confirm:l}" == y* ]] || return 0
    fi

    git reset --hard "$hash" && _ok "Reset to ${_iris}${hash}${_nc}"
}

alias gcb='git checkout -b'
alias gcl='git clone'
alias gclean='git clean -f'
alias grhh='git reset HEAD --hard'

alias gbf='gnb feat'
alias gbb='gnb fix'
alias gbr='gnb refactor'
alias gbd='gnb docs'
alias gbt='gnb test'

# ── user-added ─────────────────────────────────────────────────────────────
# Add manually or use `u a` for interactive creation.
