export EDITOR='nvim'
export VISUAL='nvim'
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

typeset -U path
_path=()
# Cargo (Rust) — only if installed (e.g. cargo install, rustup)
[[ -d "$HOME/.cargo/bin" ]]    && _path+=("$HOME/.cargo/bin")
[[ -d "$HOME/.local/bin" ]]   && _path+=("$HOME/.local/bin")
[[ -d "$HOME/bin" ]]          && _path+=("$HOME/bin")
export PATH="${(j.:.)_path}:${PATH}"

if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi
