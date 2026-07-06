alias ga='git add'
alias gaa='git add --all'
alias gc='git commit'
alias gcm='git commit -m'
alias gcam='git add . && git commit -m'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gl='git pull'
alias gcb='git checkout -b'
alias gd='git diff'
alias gds='git diff --staged'
alias gst='git status'
alias gco='git checkout'
alias gsw='git switch'
alias glog='git log --oneline --graph --decorate'
alias gsta='git stash'
alias gstp='git stash pop'
alias grb='git rebase'
alias grbi='git rebase -i'
alias gab='git absorb --and-rebase'

_fzf_git_colors="--color=fg:#a6adc8,hl:#89dceb,fg+:#cdd6f4,hl+:#f38ba8,info:#89dceb,pointer:#f38ba8,header:#89dceb,bg+:#313244"

gsb() {
    local branch
    branch=$(git branch --sort=-committerdate --format='%(refname:short)' 2>/dev/null |
        fzf --prompt="  " --header="  switch branch" $_fzf_git_colors) || return
    git switch "$branch"
}

gnb() {
    local prefix desc slug
    prefix=$(printf 'feat\nfix\nchore\nrefactor\ndocs\ntest\nci' |
        fzf --prompt="  " --header="  branch type" $_fzf_git_colors) || return
    read -r "desc?  description: "
    [[ -z "$desc" ]] && return 1
    slug=$(printf '%s' "$desc" | tr '[:upper:]' '[:lower:]' | tr -cs '[:alnum:]' '-' | sed 's/^-//;s/-$//')
    git switch -c "${prefix}/${slug}"
}

gwta() {
    local prefix desc slug
    prefix=$(printf 'feat\nfix\nchore\nrefactor\ndocs\ntest\nci' |
        fzf --prompt="  " --header="  branch type" $_fzf_git_colors) || return
    read -r "desc?  description: "
    [[ -z "$desc" ]] && return 1
    slug=$(command gwt slug "$desc")
    command gwt add "$slug" --prefix "$prefix"
}

gwts() {
    local main wt
    main=$(command gwt main 2>/dev/null) || { print -r -- "not a git repo"; return 1; }
    wt=$(command gwt list 2>/dev/null |
        fzf --prompt="  " --header="  switch worktree" $_fzf_git_colors) || return
    cd "$main/.worktrees/$wt" || return
}

gwtr() {
    local wt
    wt=$(command gwt list 2>/dev/null |
        fzf --prompt="  " --header="  remove worktree" $_fzf_git_colors) || return
    command gwt remove "$wt"
}
