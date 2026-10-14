# PATH order, sourced by .zshenv (every zsh) and .zprofile (login shells: on macOS,
# /etc/zprofile's path_helper runs after .zshenv and puts /usr/bin first). typeset -U keeps the
# first copy, so re-running only moves ours back to the front.
typeset -U path fpath
if [[ $OSTYPE == darwin* && -d /opt/homebrew ]]; then
    export HOMEBREW_PREFIX=/opt/homebrew HOMEBREW_NO_ANALYTICS=1
    path=($HOMEBREW_PREFIX/bin $HOMEBREW_PREFIX/sbin $path)
fi
path=(~/.local/bin ~/.cargo/bin(N) $path) # ~/.local/bin first: the wl-copy shim must win
