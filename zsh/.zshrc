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
source "$ZSH_CONFIG_DIR/utils.zsh"

[[ -f "$ZSH_CONFIG_DIR/nubank.zsh" ]] && source "$ZSH_CONFIG_DIR/nubank.zsh"
[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh

# Tmux: `tm` to enter — runs sessionizer to pick/create a session. Inside tmux: prefix+f.
[[ -f "$ZSH_CONFIG_DIR/tmux.zsh" ]] && source "$ZSH_CONFIG_DIR/tmux.zsh"

[[ -f "$ZSH_CONFIG_DIR/tmp.sh" ]] && source "$ZSH_CONFIG_DIR/tmp.sh"

local _max_shlvl=2
[[ "$OSTYPE" == "linux"* ]] && _max_shlvl=3
if [[ "$SHLVL" -le $_max_shlvl ]]; then
    if [[ -n "$TMUX" ]] && [[ "$TERM" == tmux-* ]]; then
        printf '\n'
        printf '%s░▒▓████████▓▒░▒▓██████████████▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░%s\n' "$_love" "$_nc"
        printf '%s   ░▒▓█▓▒░   ░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░%s\n' "$_gold" "$_nc"
        printf '%s   ░▒▓█▓▒░   ░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░%s\n' "$_rose" "$_nc"
        printf '%s   ░▒▓█▓▒░   ░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░░▒▓██████▓▒░%s\n'  "$_iris" "$_nc"
        printf '%s   ░▒▓█▓▒░   ░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░%s\n' "$_iris" "$_nc"
        printf '%s   ░▒▓█▓▒░   ░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░%s\n' "$_foam" "$_nc"
        printf '%s   ░▒▓█▓▒░   ░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░░▒▓██████▓▒░░▒▓█▓▒░░▒▓█▓▒░%s\n' "$_pine" "$_nc"
    else
        printf '\n'
        printf ' %s__%s %s__%s %s__%s %s__%s %s__%s %s__%s %s__%s %s__%s %s__%s %s__%s\n' \
            "$_love" "$_nc" "$_love" "$_nc" "$_gold" "$_nc" "$_gold" "$_nc" "$_rose" "$_nc" \
            "$_iris" "$_nc" "$_iris" "$_nc" "$_foam" "$_nc" "$_pine" "$_nc" "$_pine" "$_nc"
        printf ' %s\\ \\%s%s\\ \\%s%s\\ \\%s%s\\ \\%s%s\\ \\%s%s\\ \\%s%s\\ \\%s%s\\ \\%s%s\\ \\%s%s\\ \\%s\n' \
            "$_love" "$_nc" "$_love" "$_nc" "$_gold" "$_nc" "$_gold" "$_nc" "$_rose" "$_nc" \
            "$_iris" "$_nc" "$_iris" "$_nc" "$_foam" "$_nc" "$_pine" "$_nc" "$_pine" "$_nc"
        printf '  %s) )%s%s) )%s%s) )%s%s) )%s%s) )%s%s) )%s%s) )%s%s) )%s%s) )%s%s) )%s\n' \
            "$_love" "$_nc" "$_love" "$_nc" "$_gold" "$_nc" "$_gold" "$_nc" "$_rose" "$_nc" \
            "$_iris" "$_nc" "$_iris" "$_nc" "$_foam" "$_nc" "$_pine" "$_nc" "$_pine" "$_nc"
        printf ' %s/_/%s%s/_/%s%s/_/%s%s/_/%s%s/_/%s%s/_/%s%s/_/%s%s/_/%s%s/_/%s%s/_/%s\n' \
            "$_love" "$_nc" "$_love" "$_nc" "$_gold" "$_nc" "$_gold" "$_nc" "$_rose" "$_nc" \
            "$_iris" "$_nc" "$_iris" "$_nc" "$_foam" "$_nc" "$_pine" "$_nc" "$_pine" "$_nc"
    fi
    printf '\n'
    printf ' %s●%s %s●%s %s●%s %s●%s %s●%s %s●%s %s●%s\n' \
        "$_love" "$_nc" "$_gold" "$_nc" "$_rose" "$_nc" \
        "$_iris" "$_nc" "$_foam" "$_nc" "$_pine" "$_nc" "$_subtle" "$_nc"
    printf '\n'
fi

eval "$(starship init zsh)"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

alias rat='ratatoist'
export NU_HOME=${HOME}/dev/nu
export NUCLI_HOME=${NU_HOME}/nucli
export PATH=${NUCLI_HOME}:${PATH}

eval $(thefuck --alias)
