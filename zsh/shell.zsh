source "$ZSH_CONFIG_DIR/palette.sh"

touch ~/.hushlogin
mkdir -p ~/.cache && : > ~/.cache/zsh_bg_jobs

_bg_write_count() {
    local n=${#jobstates}
    if (( n > 0 )); then
        printf '#[fg=#eb6f92]%d ● #[fg=#393552]│ ' "$n" > "$HOME/.cache/zsh_bg_jobs"
    else
        : > "$HOME/.cache/zsh_bg_jobs"
    fi
}

setopt PROMPT_SUBST
autoload -Uz add-zsh-hook
add-zsh-hook precmd _bg_write_count

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS

setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_MINUS

zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-syntax-highlighting

autoload -Uz compinit
compinit

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|?=** m:{a-z}={A-Z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

autoload -Uz up-line-or-beginning-search
autoload -Uz down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

command -v zoxide &>/dev/null && eval "$(zoxide init zsh)"
command -v thefuck &>/dev/null && eval "$(thefuck --alias f)"

