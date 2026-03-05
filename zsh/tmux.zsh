# tm — enter tmux from the shell: runs the sessionizer to pick or create a session.
# Once inside tmux, use prefix+f to switch sessions/open projects.
# Resurrect: prefix C-s save, C-r restore. Older save: ln -sf <file> <resurrect_dir>/last then C-r.
# Optional: TMUX_SESSIONIZER (default ~/.local/bin/tmux-sessionizer)

tm() {
  [[ -n "$TMUX" || "$TERM_FLOAT" == "1" ]] && return 0
  command -v tmux &>/dev/null || return 0
  local exe="${TMUX_SESSIONIZER:-$HOME/.local/bin/tmux-sessionizer}"
  [[ -x "$exe" ]] || { echo "tmux-sessionizer not found: $exe"; return 1; }
  "$exe"
}
