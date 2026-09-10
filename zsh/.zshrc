ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [[ ! -d "$ZINIT_HOME" ]]; then
    mkdir -p "$(dirname "$ZINIT_HOME")"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

ZSH_CONFIG_DIR="${ZDOTDIR:-$HOME}/.zsh"
[[ -f "$ZSH_CONFIG_DIR/.local" ]] && source "$ZSH_CONFIG_DIR/.local"

source "$ZSH_CONFIG_DIR/env.zsh"
source "$ZSH_CONFIG_DIR/shell.zsh"
source "$ZSH_CONFIG_DIR/vim.zsh"
source "$ZSH_CONFIG_DIR/git.zsh"
source "$ZSH_CONFIG_DIR/aliases.zsh"
source "$ZSH_CONFIG_DIR/utils.zsh"

[[ -f "$ZSH_CONFIG_DIR/nubank.zsh" ]] && source "$ZSH_CONFIG_DIR/nubank.zsh"
command -v fzf &>/dev/null && source <(fzf --zsh)   # universal (mac + linux); was mac-only ~/.fzf.zsh
[[ -f "$ZSH_CONFIG_DIR/tmux.zsh" ]] && source "$ZSH_CONFIG_DIR/tmux.zsh"

eval "$(starship init zsh)"
command -v atuin  &>/dev/null && eval "$(atuin init zsh)"
command -v direnv &>/dev/null && eval "$(direnv hook zsh)"

export NVM_DIR="$HOME/.nvm"
nvm() {
    unset -f nvm node npm npx
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    nvm "$@"
}
node() { nvm >/dev/null; node "$@"; }
npm()  { nvm >/dev/null; npm "$@"; }
npx()  { nvm >/dev/null; npx "$@"; }

fpath+=~/.zfunc; autoload -Uz compinit; compinit

zstyle ':completion:*' menu select
export PATH="$HOME/miniforge3/condabin:$PATH"

<<<<<<< Updated upstream
<<<<<<< Updated upstream
# Source nucli environment (managed by Jamf)
[ -f "${HOME}/.nurc" ] && source "${HOME}/.nurc"

# >>> Nubank SSL Inspection CA — managed by: nu zscaler setup env >>>
# mode: baseline
NUBANK_CA_CERT="$HOME/dev/nu/.nu/certificates/zscaler/ca-bundle-with-zscaler.pem"


# BASELINE — Essential SSL/TLS trust
export SSL_CERT_FILE="$NUBANK_CA_CERT"
export SSL_CERT_DIR="/etc/ssl/certs"
export REQUESTS_CA_BUNDLE="$NUBANK_CA_CERT"              # Python requests, urllib3
export CURL_CA_BUNDLE="$NUBANK_CA_CERT"                  # curl, libcurl
export AWS_CA_BUNDLE="$NUBANK_CA_CERT"                   # AWS CLI, boto3, AWS SDKs
export NODE_EXTRA_CA_CERTS="$NUBANK_CA_CERT"             # Node.js, Bun, Claude Code, Cursor, VS Code, Copilot
# <<< Nubank SSL Inspection CA <<<
||||||| Stash base
=======

# Added by Antigravity CLI installer
export PATH="/home/cxrlos/.local/bin:$PATH"
>>>>>>> Stashed changes
||||||| Stash base
=======

# Added by Antigravity CLI installer
export PATH="/home/cxrlos/.local/bin:$PATH"
>>>>>>> Stashed changes
