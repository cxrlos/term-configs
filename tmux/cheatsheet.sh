#!/usr/bin/env bash

h='\033[38;2;196;167;231m' # #c4a7e7 iris    — section headers
k='\033[38;2;156;207;216m' # #9ccfd8 foam    — keys
d='\033[38;2;144;140;170m' # #908caa muted   — descriptions
s='\033[38;2;62;53;82m'    # #3e3552 dim     — separator
r='\033[0m'

section() { printf "\n${h}  %s${r}\n  ${s}─────────────────────────────────────${r}\n" "$1"; }
row() { printf "  ${k}%-18s${r} ${d}%s${r}\n" "$1" "$2"; }

tmpfile=$(mktemp)
trap 'rm -f "$tmpfile"' EXIT

{
    section "Sessions (shell)"
    row "tm" "sessionizer — pick or create"
    row "tmux ls" "list sessions"
    row "tmux a" "attach last"
    row "tmux a -t name" "attach named"
    row "tmux kill-ses -t" "kill session"

    section "Sessions (\`)"
    row "f" "sessionizer"
    row "\$" "rename session"
    row "d" "detach"
    row "Tab" "last session (toggle)"
    row "S-Tab" "session menu — enter switch, C-x kill"
    row "( / )" "prev / next session"
    row "Q" "kill session (confirm)"

    section "Windows (\`)"
    row "c" "new window"
    row "1..9" "jump to window"
    row "n / p" "next / prev window"
    row "^" "last window"
    row "< / >" "move window left / right"
    row "," "rename window"
    row "X" "kill window"

    section "Panes (\`)"
    row "v" "split right"
    row "s" "split down"
    row "z" "zoom toggle"
    row "x" "kill pane"
    row ";" "last pane"
    row "o" "cycle panes"
    row "q" "show pane numbers"
    row "{ / }" "swap pane left / right"
    row "!" "break pane → window"

    section "Navigation"
    row "C-h/j/k/l" "pane nav (vim+tmux, no prefix)"
    row "h/j/k/l" "select pane (prefix)"
    row "H/J/K/L" "resize pane (prefix)"

    section "Popups (\`)"
    row "?" "cheatsheet"
    row "/" "workflow guide"
    row "f" "sessionizer"
    row "g" "lazygit"
    row "t" "popup shell"
    row "m" "htop"
    row "w" "fzf picker (tmux-fzf)"

    section "Plugins (\`)"
    row "Space" "thumbs — hint yank"
    row "e" "extrakto — fzf pane text"
    row "Enter" "copy mode"
    row "C-s / C-r" "save / restore (resurrect)"

    section "Copy mode (vi)"
    row "Enter / [" "enter"
    row "q / Escape" "exit"
    row "v" "begin selection"
    row "C-v" "rectangle selection"
    row "y" "yank → clipboard"
    row "Y" "yank line → clipboard"
    row "P" "paste buffer"
    row "o" "open URL / file (tmux-open)"

    section "Copy nav"
    row "h/j/k/l" "move"
    row "w / b / e" "word fwd / back / end"
    row '0 / $' "line start / end"
    row "g / G" "top / bottom"
    row "C-u / C-d" "half page up / down"
    row "/ / ?" "search fwd / back"
    row "n / N" "next / prev match"

    section "Other"
    row "r" "reload config"
    row "I / U" "install / update plugins"
    row "\`\`" "literal backtick"

    printf "\n"
} >"$tmpfile"

fzf <"$tmpfile" \
    --ansi \
    --no-sort \
    --layout=reverse \
    --no-info \
    --header="  type to filter  ·  ESC close" \
    --prompt="  " \
    --pointer="▶" \
    --bind="enter:abort" \
    --bind="esc:abort" \
    --color="bg:#191724,bg+:#26233a,fg:#e0def4,fg+:#e0def4,\
hl:#c4a7e7,hl+:#c4a7e7,prompt:#9ccfd8,pointer:#eb6f92,\
gutter:#191724,separator:#393552,header:#6e6a86,border:#9ccfd8"
