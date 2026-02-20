# Rose Pine true-color palette (RGB escapes — requires true-color terminal)
_love=$'\033[38;2;235;111;146m'
_gold=$'\033[38;2;246;193;119m'
_foam=$'\033[38;2;156;207;216m'
_pine=$'\033[38;2;49;116;143m'
_rose=$'\033[38;2;235;188;186m'
_iris=$'\033[38;2;196;167;231m'
_subtle=$'\033[38;2;144;140;170m'
_bold=$'\033[1m'
_nc=$'\033[0m'

_err()  { printf '%s✗%s %s\n' "$_love"  "$_nc" "$*" >&2; }
_warn() { printf '%s!%s %s\n' "$_gold"  "$_nc" "$*" >&2; }
_info() { printf '%s→%s %s\n' "$_foam"  "$_nc" "$*"; }
_ok()   { printf '%s✓%s %s\n' "$_pine"  "$_nc" "$*"; }
_dim()  { printf '%s%s%s'     "$_subtle" "$*"  "$_nc"; }

touch ~/.hushlogin

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

zinit light Aloxaf/fzf-tab

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|?=** m:{a-z}={A-Z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache
zstyle ':fzf-tab:*' fzf-flags --color='fg:#908caa,hl:#c4a7e7,fg+:#e0def4,hl+:#eb6f92,info:#9ccfd8,pointer:#eb6f92,marker:#f6c177,header:#9ccfd8'

autoload -Uz up-line-or-beginning-search
autoload -Uz down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

command -v zoxide &>/dev/null && eval "$(zoxide init zsh)"
command -v thefuck &>/dev/null && eval "$(thefuck --alias f)"
