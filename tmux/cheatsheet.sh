#!/usr/bin/env bash

h='\033[38;2;196;167;231m'   # #c4a7e7 purple  — section headers
k='\033[38;2;156;207;216m'   # #9ccfd8 cyan    — keys
d='\033[38;2;144;140;170m'   # #908caa muted   — descriptions
s='\033[38;2;62;53;82m'      # #3e3552 dim     — separator
r='\033[0m'

section() { printf "\n${h}  %s${r}\n  ${s}──────────────────────────────${r}\n" "$1"; }
row()     { printf "  ${k}%-22s${r}${d}%s${r}\n" "$1" "$2"; }

vh="  jk navigate  ·  h/l sections  ·  i search  ·  ESC exit"
ih="  type to filter  ·  ESC back to visual"

# ── Temp files ─────────────────────────────────────────────────────────────────
tmpfile=$(mktemp)
navscript=$(mktemp)
trap "rm -f $tmpfile $navscript" EXIT

# ── Generate content ────────────────────────────────────────────────────────────
{
  section "Sessions  (shell)"
  row "tmux"                  "new session"
  row "tmux new -s name"      "new named session"
  row "tmux ls"               "list sessions"
  row "tmux a"                "attach last session"
  row "tmux a -t name"        "attach named session"
  row "tmux kill-ses -t name" "kill session"

  section "Sessions  (prefix)"
  row '$'       "rename session"
  row "d"       "detach"
  row "( / )"   "previous / next session"
  row "L"       "last session"

  section "Windows  (prefix)"
  row ","  "rename window"
  row "X"  "kill window (custom)"
  row "&"  "kill window with confirm (built-in)"

  section "Panes  (prefix)"
  row ";"      "last active pane"
  row "o"      "cycle panes"
  row "q"      "show pane numbers"
  row "{ / }"  "swap pane left / right"
  row "!"      "break pane → new window"

  section "Navigation"
  row "C-h/j/k/l"  "seamless pane nav (vim+tmux, no prefix)"
  row "h/j/k/l"    "select pane (prefix, repeatable)"
  row "←/→/↑/↓"    "resize pane (prefix + arrow, repeatable)"

  section "Prefix  (\`)"
  row "v"      "split right (vertical divider)"
  row "s"      "split down (horizontal divider)"
  row "c"      "new window (inherits current dir)"
  row "1..9"   "jump to window N"
  row "n / p"  "next / prev window (repeatable)"
  row "< / >"  "move window left / right"
  row "^"      "last window (toggle)"
  row "z"      "zoom pane (fullscreen toggle)"
  row "x"      "kill pane"
  row "X"      "kill window"

  section "Popups  (prefix)"
  row "/"  "this cheatsheet"
  row "f"  "sessionizer (project switcher)"
  row "g"  "lazygit"
  row "t"  "htop"
  row "T"  "scratch terminal (persistent)"
  row "w"  "fzf session/window/pane picker"
  row "b"  "popup shell in current directory"

  section "Plugins"
  row "Space"  "thumbs — hint-based yank (URLs, paths, hashes)"
  row "Enter"  "enter copy mode"
  row "C-s"    "save session  (tmux-resurrect)"
  row "C-r"    "restore session (tmux-resurrect)"

  section "Copy mode  (vi)"
  row "Enter / ["   "enter copy mode"
  row "q / Escape"  "exit copy mode"
  row "v"           "begin selection"
  row "C-v"         "rectangle (block) selection"
  row "y"           "yank selection → clipboard"
  row "Y"           "yank entire line → clipboard"
  row "P"           "paste tmux buffer (prefix + P)"
  row "]"           "paste tmux buffer (built-in)"
  row "o"           "open file / URL under cursor (tmux-open)"

  section "Copy mode — navigation"
  row "h/j/k/l"    "move cursor"
  row "w / b / e"  "word forward / back / end"
  row '0 / $'      "line start / end"
  row "g / G"      "top / bottom of scrollback"
  row "C-u / C-d"  "half page up / down"
  row "C-b / C-f"  "full page up / down"
  row "/ / ?"      "search forward / backward"
  row "n / N"      "next / prev match"

  section "Other"
  row "r"     "reload config"
  row "I"     "install plugins (TPM)"
  row "U"     "update plugins (TPM)"
  row "\`\`"  "send literal backtick"

  printf "\n"
} > "$tmpfile"

# ── Detect section positions (1-based to match $FZF_POS) ───────────────────────
section_pos=()
i=0
while IFS= read -r line; do
  (( i++ ))
  if [[ "$line" == $'\033[38;2;196;167;231m'* ]]; then
    section_pos+=("$i")
  fi
done < "$tmpfile"

export SECTION_POS="${section_pos[*]}"
export TOTAL_LINES=$i

# ── Navigation script (always runs under bash for consistent array behaviour) ──
cat > "$navscript" << 'EOF'
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
  # Next section
  target=""
  for s in $SECTION_POS; do
    if (( s > pos )); then target=$s; break; fi
  done
  if [[ -z "$target" ]]; then
    # Wrap: jump to first section via first+down*N
    first=${SECTION_POS%% *}
    act="first"
    for ((i=1; i<first; i++)); do act="$act+down"; done
    echo "$act"
  else
    acts_down $(( target - pos ))
  fi

elif [[ "$dir" == "h" ]]; then
  # Prev section
  prev=""
  for s in $SECTION_POS; do
    if (( s >= pos )); then break; fi
    prev=$s
  done
  if [[ -n "$prev" ]]; then
    acts_up $(( pos - prev ))
  else
    # Wrap: jump to last section via last+up*N
    last=${SECTION_POS##* }
    act="last"
    for ((i=0; i < TOTAL_LINES - last; i++)); do act="$act+up"; done
    echo "$act"
  fi
fi
EOF
chmod +x "$navscript"

# ── Launch ─────────────────────────────────────────────────────────────────────
cat "$tmpfile" | fzf \
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
