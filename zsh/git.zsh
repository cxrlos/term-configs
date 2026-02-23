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
                    diff)   _g_diff --pick ;;
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

_g_log_fmt='%C(#9ccfd8)%h%Creset -%C(#eb6f92)%d%Creset %s %C(#31748f)(%cr) %C(#c4a7e7)<%an>%Creset'

_g_log() {
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
            oneline) git log --graph --pretty=format:"$_g_log_fmt" --abbrev-commit ;;
            stats)   git log --graph --pretty=format:"$_g_log_fmt" --abbrev-commit --stat ;;
            all)     git log --graph --pretty=format:"$_g_log_fmt" --abbrev-commit --all ;;
            full)    git log ;;
        esac
    else
        git log --graph --pretty=format:"$_g_log_fmt" --abbrev-commit "$@"
    fi
}

_g_diff() {
    if [[ "$1" == "--pick" ]] && command -v gum &>/dev/null; then
        local variant
        variant=$(gum choose --cursor-prefix "→ " \
            --cursor.foreground "#eb6f92" \
            --selected.foreground "#c4a7e7" \
            --header "Diff scope" --header.foreground "#9ccfd8" \
            "unstaged   working tree vs index" \
            "staged     index vs last commit" \
            "head       working tree vs last commit" \
            "stat       summary only") || return 1
        case "${variant%% *}" in
            unstaged) git diff ;;
            staged)   git diff --staged ;;
            head)     git diff HEAD ;;
            stat)     git diff --stat ;;
        esac
    else
        git diff "$@"
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
alias gco='git checkout'
alias gcb='git checkout -b'
alias gcl='git clone'
alias gclean='git clean -f'
alias grh='git reset --hard'
alias grhh='git reset HEAD --hard'

alias glol='git log --graph --pretty=format:"%C(#9ccfd8)%h%Creset -%C(#eb6f92)%d%Creset %s %C(#31748f)(%cr) %C(#c4a7e7)<%an>%Creset" --abbrev-commit'
alias glols='git log --graph --pretty=format:"%C(#9ccfd8)%h%Creset -%C(#eb6f92)%d%Creset %s %C(#31748f)(%cr) %C(#c4a7e7)<%an>%Creset" --abbrev-commit --stat'
alias glola='git log --graph --pretty=format:"%C(#9ccfd8)%h%Creset -%C(#eb6f92)%d%Creset %s %C(#31748f)(%cr) %C(#c4a7e7)<%an>%Creset" --abbrev-commit --all'

alias gbf='gnb feat'
alias gbb='gnb fix'
alias gbr='gnb refactor'
alias gbd='gnb docs'
alias gbt='gnb test'

# ── user-added ─────────────────────────────────────────────────────────────
# Git-related aliases and shortcuts.
# Add manually or use `u a` for interactive creation.
