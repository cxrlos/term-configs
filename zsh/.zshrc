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

if [[ "$SHLVL" -le 2 ]]; then
    local _splash_marker="/tmp/.tmux_splash_$(tmux display-message -p '#{pid}' 2>/dev/null)"
    if [[ -n "$TMUX" ]] && [[ ! -f "$_splash_marker" ]]; then
        touch "$_splash_marker"
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
