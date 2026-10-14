# Every zsh (scripts and `ssh host cmd` too): environment only, no forks.
export XDG_CONFIG_HOME=$HOME/.config XDG_CACHE_HOME=$HOME/.cache XDG_STATE_HOME=$HOME/.local/state
export LANG=en_US.UTF-8
export EDITOR=nvim VISUAL=nvim PAGER=less LESS=-RFi

typeset -U path fpath
if [[ $OSTYPE == darwin* && -d /opt/homebrew ]]; then
    export HOMEBREW_PREFIX=/opt/homebrew
    path=($HOMEBREW_PREFIX/bin $HOMEBREW_PREFIX/sbin $path)
fi
path=(~/.local/bin ~/.cargo/bin(N) $path) # ~/.local/bin first: the wl-copy shim must win

export AGENT=${AGENT:-claude} # CLI agent for the sessionizer's `agent` window; swap freely
export TS_ROOTS=${TS_ROOTS:-$HOME/dev} # sessionizer: git repos under these (colon-separated); override in ~/.zshrc.local

export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
export FZF_CTRL_T_COMMAND=$FZF_DEFAULT_COMMAND
export FZF_DEFAULT_OPTS='--height=40% --layout=reverse --border --highlight-line
  --color=bg+:#283457,fg:#c0caf5,hl:#2ac3de,hl+:#2ac3de,info:#545c7e,prompt:#2ac3de,pointer:#ff007c,marker:#ff007c,border:#27a1b9,header:#ff9e64,spinner:#ff007c'
