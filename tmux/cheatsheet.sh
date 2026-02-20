#!/usr/bin/env bash
clear
printf '\033[38;2;156;207;216m'
cat <<'EOF'

  Navigation
  ──────────────────────────────
  C-h/j/k/l    seamless pane nav (vim+tmux)
  M-←/→/↑/↓    resize pane (Option+Arrow)

  Prefix (`)
  ──────────────────────────────
  v            split vertical
  s            split horizontal
  c            new window (current dir)
  1..9         jump to window
  n / p        next / prev window
  ^            last window (toggle)
  z            zoom pane (fullscreen)
  x            kill pane
  X            kill window

  Popups
  ──────────────────────────────
  /            this cheatsheet
  f            sessionizer (projects)
  g            lazygit
  t            htop
  w            fzf session/window picker

  Plugins
  ──────────────────────────────
  Space        thumbs (vimium hints → copy)
  Tab          fingers (highlight IPs/paths)
  Enter        copy mode (vi keys)
  C-s          save session (resurrect)
  C-r          restore session (resurrect)

  Copy mode (vi)
  ──────────────────────────────
  v            begin selection
  y            yank to clipboard
  o            open file/URL (tmux-open)

  Other
  ──────────────────────────────
  r            reload config
  I            install plugins (TPM)
  ``           literal backtick

EOF
printf '\033[0m'
printf '\033[38;2;144;140;170m  q or Esc to close\033[0m'
while true; do
    read -rsn1 key
    [[ "$key" == "q" || "$key" == $'\e' || -z "$key" ]] && break
done
