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

_fzf_git_colors="--color=fg:#908caa,hl:#c4a7e7,fg+:#e0def4,hl+:#eb6f92,info:#9ccfd8,pointer:#eb6f92,header:#9ccfd8,bg+:#26233a"

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
