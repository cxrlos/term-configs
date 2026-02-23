#!/usr/bin/env zsh
# Temporary test reminder — self-deletes when you confirm you're done.
# Sourced automatically from .zshrc while this file exists.

() {
  local _self="${ZSH_CONFIG_DIR}/tmp.sh"
  local _h='\033[38;2;196;167;231m'   # purple  — headers
  local _k='\033[38;2;156;207;216m'   # cyan    — keys
  local _d='\033[38;2;144;140;170m'   # muted   — descriptions
  local _w='\033[38;2;235;111;146m'   # red/love — warnings
  local _g='\033[38;2;49;116;143m'    # green/pine
  local _r='\033[0m'

  printf '\n'
  printf "${_h}  ⚠  Pending tests (Wayland keybind changes)${_r}\n"
  printf '  \033[38;2;62;53;82m──────────────────────────────────────────${_r}\n\n'

  printf "${_h}  Hyprland${_r}\n"
  printf "  ${_k}%-24s${_r}${_d}%s${_r}\n" "Super+T"        "float terminal (was Super+E)"
  printf "  ${_k}%-24s${_r}${_d}%s${_r}\n" "Super+M"        "btop monitor (was Super+T)"
  printf '\n'

  printf "${_h}  Tmux${_r}\n"
  printf "  ${_k}%-24s${_r}${_d}%s${_r}\n" "\`t"            "popup shell in cwd (was \`b)"
  printf "  ${_k}%-24s${_r}${_d}%s${_r}\n" "\`m"            "htop (was \`t)"
  printf "  ${_k}%-24s${_r}${_d}%s${_r}\n" "\`?"            "cheatsheet (was \`/)"
  printf "  ${_k}%-24s${_r}${_d}%s${_r}\n" "\`H/J/K/L"      "resize pane (was arrows)"
  printf '\n'

  printf "${_h}  Neovim${_r}\n"
  printf "  ${_k}%-24s${_r}${_d}%s${_r}\n" "<leader>t"      "float terminal (was <leader>gt)"
  printf "  ${_k}%-24s${_r}${_d}%s${_r}\n" "<leader>gb"     "toggle blame (was bare gb)"
  printf "  ${_k}%-24s${_r}${_d}%s${_r}\n" "<leader>F"      "format project (was <leader>cf)"
  printf "  ${_k}%-24s${_r}${_d}%s${_r}\n" "<M-h/j/k/l>"   "resize window — needs Alt (was C-arrows)"
  printf "  ${_k}%-24s${_r}${_d}%s${_r}\n" "<leader>y/Y"    "confirm REMOVED, plain y goes to clipboard"
  printf "  ${_k}%-24s${_r}${_d}%s${_r}\n" "<leader>fb"     "only buffer picker now (leader+bp gone)"
  printf "  ${_k}%-24s${_r}${_d}%s${_r}\n" "?"              "cheatsheet still opens (not broken)"
  printf '\n'

  printf "${_h}  tmux prompt (new)${_r}\n"
  printf "  ${_k}%-24s${_r}${_d}%s${_r}\n" "fresh terminal"  "gum confirm → pick session or create new"
  printf "  ${_k}%-24s${_r}${_d}%s${_r}\n" "Super+T float"   "should skip prompt (TERM_FLOAT=1)"
  printf "  ${_k}%-24s${_r}${_d}%s${_r}\n" "\`t popup"       "should skip prompt (TERM_FLOAT=1)"
  printf '\n'

  if command -v gum &>/dev/null; then
    if gum confirm "Mark all tests done and remove this reminder?" \
        --prompt.foreground="#c4a7e7" \
        --selected.background="#31748f" \
        --default=false 2>/dev/null; then
      rm -f "$_self"
      printf "${_g}  Reminder removed.${_r}\n\n"
    fi
  else
    printf "  ${_d}Delete ${_k}${_self}${_d} when done testing.${_r}\n\n"
  fi
}
