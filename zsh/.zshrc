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

# ── tmux session prompt (once per boot, skipped in float/popup terminals) ────
() {
  local _flag="/tmp/.zsh-tmux-$(id -u)"
  if [[ -z "$TMUX" && "$TERM_FLOAT" != "1" && ! -f "$_flag" ]]; then
    touch "$_flag"
    if command -v gum &>/dev/null && command -v tmux &>/dev/null; then
      if gum confirm "Start a tmux session?" \
          --prompt.foreground="#c4a7e7" \
          --selected.background="#31748f" 2>/dev/null; then
        local _sessions
        _sessions=$(tmux ls -F "#{session_name}" 2>/dev/null || true)
        if [[ -n "$_sessions" ]]; then
          local _choice
          _choice=$(printf '%s\n' "[ new session ]" "${(f)_sessions}" | \
            gum choose --header "Pick a session" \
              --header.foreground="#9ccfd8" \
              --cursor.foreground="#c4a7e7" 2>/dev/null)
          if [[ "$_choice" == "[ new session ]" || -z "$_choice" ]]; then
            exec tmux
          else
            exec tmux attach -t "$_choice"
          fi
        else
          exec tmux
        fi
      fi
    fi
  fi
}

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

# opencode
export PATH=/home/cxrlos/.opencode/bin:$PATH

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
