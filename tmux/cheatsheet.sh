#!/usr/bin/env bash

h='\033[38;2;196;167;231m' # #c4a7e7 iris    — section headers
k='\033[38;2;156;207;216m' # #9ccfd8 foam    — keys
d='\033[38;2;144;140;170m' # #908caa muted   — descriptions
s='\033[38;2;62;53;82m'    # #3e3552 dim     — separator
r='\033[0m'

section() { printf "\n${h}  %s${r}\n  ${s}─────────────────────────────────────${r}\n" "$1"; }
row() { printf "  ${k}%-18s${r} ${d}%s${r}\n" "$1" "$2"; }

vh="  jk navigate  ·  h/l sections  ·  i search  ·  ESC exit"
ih="  type to filter  ·  ESC back to visual"

# ── Temp files ─────────────────────────────────────────────────────────────────
tmpfile=$(mktemp)
navscript=$(mktemp)
trap 'rm -f "$tmpfile" "$navscript"' EXIT

# ── Generate content ────────────────────────────────────────────────────────────
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
    row "( / )" "prev / next session"

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

# ── Detect section positions (1-based to match $FZF_POS) ───────────────────────
section_pos=()
i=0
while IFS= read -r line; do
    ((i++))
    if [[ "$line" == $'\033[38;2;196;167;231m'* ]]; then
        section_pos+=("$i")
    fi
done <"$tmpfile"

export SECTION_POS="${section_pos[*]}"
export TOTAL_LINES=$i

# ── Navigation script (always runs under bash for consistent array behaviour) ──
cat >"$navscript" <<'EOF'
#!/usr/bin/env bash
# $1 = h|l   Env: FZF_PROMPT, FZF_POS, SECTION_POS, TOTAL_LINES

dir=$1
if [[ "$FZF_PROMPT" != *VISUAL* ]]; then
  echo "put($dir)"
  exit 0
fi

pos=$FZF_POS  # 1-based

acts_down() {
  local n=$1 a=""
  for ((i=0; i<n; i++)); do a="${a}down+"; done
  echo "${a%+}"
}
acts_up() {
  local n=$1 a=""
  for ((i=0; i<n; i++)); do a="${a}up+"; done
  echo "${a%+}"
}

if [[ "$dir" == "l" ]]; then
  target=""
  for s in $SECTION_POS; do
    if (( s > pos )); then target=$s; break; fi
  done
  if [[ -z "$target" ]]; then
    first=${SECTION_POS%% *}
    act="first"
    for ((i=1; i<first; i++)); do act="$act+down"; done
    echo "$act"
  else
    acts_down $(( target - pos ))
  fi

elif [[ "$dir" == "h" ]]; then
  prev=""
  for s in $SECTION_POS; do
    if (( s >= pos )); then break; fi
    prev=$s
  done
  if [[ -n "$prev" ]]; then
    acts_up $(( pos - prev ))
  else
    last=${SECTION_POS##* }
    act="last"
    for ((i=0; i < TOTAL_LINES - last; i++)); do act="$act+up"; done
    echo "$act"
  fi
fi
EOF
chmod +x "$navscript"

# ── Launch ─────────────────────────────────────────────────────────────────────
fzf <"$tmpfile" \
    --ansi \
    --no-sort \
    --layout=reverse \
    --no-info \
    --header="$vh" \
    --prompt="  VISUAL  " \
    --pointer="▶" \
    --bind="start:disable-search" \
    --bind="change:transform:if [[ \"\$FZF_PROMPT\" == *VISUAL* ]]; then echo 'clear-query'; fi" \
    --bind="i:enable-search+clear-query+change-prompt(  INSERT  )+change-header($ih)" \
    --bind="j:transform:if [[ \"\$FZF_PROMPT\" == *VISUAL* ]]; then echo 'down'; else echo 'put(j)'; fi" \
    --bind="k:transform:if [[ \"\$FZF_PROMPT\" == *VISUAL* ]]; then echo 'up'; else echo 'put(k)'; fi" \
    --bind="h:transform:$navscript h" \
    --bind="l:transform:$navscript l" \
    --bind="g:transform:if [[ \"\$FZF_PROMPT\" == *VISUAL* ]]; then echo 'first'; else echo 'put(g)'; fi" \
    --bind="G:transform:if [[ \"\$FZF_PROMPT\" == *VISUAL* ]]; then echo 'last'; else echo 'put(G)'; fi" \
    --bind="enter:abort" \
    --bind="esc:transform:if [[ \"\$FZF_PROMPT\" == *VISUAL* ]]; then echo 'abort'; else echo 'disable-search+clear-query+change-prompt(  VISUAL  )+change-header($vh)'; fi" \
    --color="bg:#191724,bg+:#26233a,fg:#e0def4,fg+:#e0def4,\
hl:#c4a7e7,hl+:#c4a7e7,prompt:#9ccfd8,pointer:#eb6f92,\
gutter:#191724,separator:#393552,header:#6e6a86,border:#9ccfd8"
