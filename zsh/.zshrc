# Interactive zsh. Environment lives in .zshenv; machine-only bits in ~/.zshrc.local.

# History: zsh's own file feeds ↑ (this session) and autosuggestions; atuin owns Ctrl+R.
HISTFILE=$XDG_STATE_HOME/zsh/history
HISTSIZE=50000 SAVEHIST=50000
setopt EXTENDED_HISTORY INC_APPEND_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE \
       HIST_REDUCE_BLANKS HIST_EXPIRE_DUPS_FIRST HIST_VERIFY
setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT INTERACTIVE_COMMENTS NO_BEEP NO_FLOW_CONTROL
mkdir -p $XDG_STATE_HOME/zsh $XDG_CACHE_HOME/zsh

# Completion (once, after every fpath change)
fpath=(~/.zfunc(N) ${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/share/zsh/site-functions} $fpath)
zmodload zsh/complist
autoload -Uz compinit && compinit -d $XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' use-cache on cache-path $XDG_CACHE_HOME/zsh/zcompcache
bindkey -M menuselect h vi-backward-char j vi-down-line-or-history k vi-up-line-or-history l vi-forward-char

# Vi mode (zsh owns line editing). Esc = normal mode, block cursor; insert = bar cursor.
bindkey -v; KEYTIMEOUT=1
bindkey -M viins '^?' backward-delete-char '^H' backward-delete-char '^W' backward-kill-word
autoload -Uz edit-command-line select-bracketed select-quoted surround
zle -N edit-command-line; zle -N select-bracketed; zle -N select-quoted
zle -N add-surround surround; zle -N delete-surround surround; zle -N change-surround surround
bindkey -M visual v edit-command-line; bindkey -M viins '^X^E' edit-command-line # vv / ^X^E: line in nvim
for m in viopp visual; do                                                     # ci" da( yi{ ...
    for c in {a,i}${(s..)^:-'()[]{}<>bB'}; do bindkey -M $m -- $c select-bracketed; done
    for c in {a,i}{\',\",\`}; do bindkey -M $m -- $c select-quoted; done
done
# Surround on sa/sd/sr (mini.surround keys, same as nvim); plain s is freed so they need no timeout
bindkey -M vicmd -r s
bindkey -M vicmd sa add-surround sd delete-surround sr change-surround; bindkey -M visual S add-surround
_vi_cursor() { [[ $KEYMAP == vicmd ]] && print -n '\e[2 q' || print -n '\e[6 q' }
zle-keymap-select() { _vi_cursor }; zle -N zle-keymap-select
zle-line-init() { _vi_cursor }; zle -N zle-line-init

# Tools (zoxide after compinit; atuin after fzf so it wins Ctrl+R)
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
FZF_CTRL_R_COMMAND= FZF_ALT_C_COMMAND= source <(fzf --zsh)
eval "$(atuin init zsh --disable-up-arrow)"
eval "$(direnv hook zsh)"

# ↑/↓: prefix search ("git" then ↑)
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search; zle -N down-line-or-beginning-search
for km in viins vicmd; do
    bindkey -M $km '^[[A' up-line-or-beginning-search '^[OA' up-line-or-beginning-search \
                   '^[[B' down-line-or-beginning-search '^[OB' down-line-or-beginning-search
done

alias ls='eza --icons=auto --group-directories-first' ll='ls -la --git --header' la='ls -a' lt='ls --tree --level=2 --git-ignore'
alias vi=nvim vim=nvim tm=tmux-sessionizer
alias cheat="less ${${(%):-%N}:A:h:h}/CHEATSHEET.md" # repo root, resolved through the ~/.zshrc symlink

# gnb: new branch named type/slug ("feat" + "Add CLI flag" -> feat/add-cli-flag)
gnb() {
    setopt localoptions extendedglob
    local type desc
    type=$(print -l feat fix chore refactor docs test ci | fzf --prompt='type> ' --height=10) || return
    read -r "desc?description: "; [[ -n $desc ]] || return 1
    desc=${${(L)desc}//[^a-z0-9]##/-}
    git switch -c "$type/${${desc#-}%-}"
}

# Plugins from dnf/brew; syntax highlighting must load last
_zp() { local f; for f in /usr/share/$1/$1.zsh ${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/share/$1/$1.zsh}; do [[ -r $f ]] && { source $f; return }; done }
_zp zsh-autosuggestions
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
[[ -r ~/.zshrc.local ]] && source ~/.zshrc.local
_zp zsh-syntax-highlighting; unfunction _zp
