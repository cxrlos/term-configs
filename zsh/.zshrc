autoload -U +X compinit && compinit
autoload -U +X bashcompinit && bashcompinit

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
[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh
[[ -f "$ZSH_CONFIG_DIR/tmux.zsh" ]] && source "$ZSH_CONFIG_DIR/tmux.zsh"

eval "$(starship init zsh)"
command -v atuin  &>/dev/null && eval "$(atuin init zsh)"
command -v direnv &>/dev/null && eval "$(direnv hook zsh)"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

tm
