#!/usr/bin/env bash

h='\033[38;2;196;167;231m' # iris   — section headers
t='\033[38;2;224;222;244m' # text   — body
c='\033[38;2;156;207;216m' # foam   — commands / examples
g='\033[38;2;246;193;119m' # gold   — tips / key points
s='\033[38;2;62;53;82m'    # dim    — separator
r='\033[0m'

head() { printf "\n${h}  %s${r}\n  ${s}──────────────────────────────────────${r}\n" "$1"; }
body() { printf "  ${t}%s${r}\n" "$1"; }
code() { printf "  ${c}    %s${r}\n" "$1"; }
tip()  { printf "  ${g}  → %s${r}\n" "$1"; }
gap()  { printf "\n"; }

tmpfile=$(mktemp)
trap 'rm -f "$tmpfile"' EXIT

{
    head "The mental model"
    body "Think in workspaces, not terminals."
    gap
    body "Session  =  a named workspace for one project or context."
    body "Window   =  a view inside that session  (editor / server / logs)."
    body "Pane     =  a split within a window for things you need side-by-side."
    gap
    tip  "Detaching is not closing. Sessions outlive your terminal."
    tip  "A session you detach from stays fully alive in the background."

    head "Starting your day"
    body "Open a terminal and type:"
    code "tm"
    body "fzf shows running sessions at the top, registered projects below."
    body "Pick a running session  →  resume exactly where you left off."
    body "Pick a project dir      →  create a new session in that directory."
    gap
    body "Register new projects from the shell:"
    code "cd ~/path/to/project && sessionizer-add"
    body "Import existing, bulk-import a folder of repos, or scaffold new."
    gap
    body "Once inside tmux, switch sessions without leaving:"
    code "\`f   (prefix + f)"
    tip  "You rarely need to leave tmux once you're in. \`f is your nav hub."

    head "Deciding the structure"
    body "New project or a context you'll return to later  →  new session."
    body "Different phase of the same project              →  new window."
    body "Two things you need visible at the same time     →  split pane."
    gap
    tip  "Don't over-split. A clean window per phase beats 6 tiny panes."
    tip  "If you'd want to 'put it aside and come back', it deserves a session."

    head "Windows vs panes"
    body "Use windows when work is sequential or conceptually separate:"
    code "window 1  editor"
    code "window 2  running server or watcher"
    code "window 3  free terminal"
    gap
    body "Use panes when you genuinely need two outputs visible at once:"
    code "left pane   editor or command"
    code "right pane  logs or test output"
    gap
    tip  "Name your windows (\`, then type). A labelled window list is readable."

    head "Cross-repo and cross-service work"
    body "When two repos are tightly coupled for a task, keep them in one session."
    body "Use one window per repo. Name the session after the feature or task."
    gap
    code "session: <feature-name>"
    code "  window 1  service code"
    code "  window 2  infrastructure / config"
    code "  window 3  deploy / integration"
    gap
    tip  "Switching windows (\`n/p) is faster than switching sessions for tightly"
    tip  "coupled work. Reserve session switches for independent contexts."

    head "Saving and restoring"
    body "Save the session layout before you close your laptop or step away"
    body "from complex cross-repo work:"
    code "\`C-s   save"
    code "\`C-r   restore"
    gap
    body "Save when:"
    body "  • multi-window session you spent time setting up"
    body "  • cross-repo session (service + infra)"
    body "  • mid-task and you'll want the exact pane layout back"
    gap
    body "Skip when:"
    body "  • simple single-window session — sessionizer recreates it in seconds"
    body "  • throwaway debug session"
    gap
    tip  "Rule: if reconstructing the session would take > 30 seconds, save it."

    head "Per-project layout (hydration)"
    body "Drop a .tmux-sessionizer file in any project root to define a default"
    body "window layout. The sessionizer runs it once when the session is first"
    body "created — re-attaching an existing session skips it."
    gap
    body "Structure:"
    code "#!/usr/bin/env bash"
    code ""
    code "# Rename the first window (always exists after session creation)"
    code "tmux rename-window -t \"\${TMUX_SESSION}:1\" editor"
    code "tmux send-keys    -t \"\${TMUX_SESSION}:editor\" 'nvim .' Enter"
    code ""
    code "# Add more windows as needed"
    code "tmux new-window -t \"\${TMUX_SESSION}\" -n server"
    code "tmux send-keys  -t \"\${TMUX_SESSION}:server\" 'npm run dev' Enter"
    code ""
    code "tmux new-window -t \"\${TMUX_SESSION}\" -n shell"
    code ""
    code "# Return focus to the first window"
    code "tmux select-window -t \"\${TMUX_SESSION}:editor\""
    gap
    body "Rules:"
    body "  • Always use \$TMUX_SESSION to target the right session"
    body "  • Rename window 1 first — it already exists, don't create a duplicate"
    body "  • End by selecting the window you want focus on"
    body "  • Keep it short: editor, server/watcher, shell — that's usually enough"
    body "  • Make it executable: chmod +x .tmux-sessionizer"
    gap
    tip  "Don't auto-start things that need manual confirmation (e.g. migrations)."
    tip  "Auto-start dev servers and watchers only — safe to run unconditionally."
    gap

    head "Git shortcuts  (shell)"
    body "Branch switching and creation without tab completion issues:"
    code "gsb          fzf branch switcher  (local, sorted by recency)"
    code "gnb          new branch  (pick type → describe → auto-slug)"
    body "gnb creates branches like feat/add-user-auth, fix/null-pointer, etc."
    gap

    head "Session hygiene"
    body "Kill sessions you're fully done with:"
    code "\`x on the last pane   (or tmux kill-session -t name)"
    gap
    body "Keep names meaningful — project name or feature name, not 'work2'."
    body "A clean session list makes \`f navigation fast and intentional."
    gap
    tip  "Dead sessions add noise to the fzf picker. Clean up as you go."

    gap
} >"$tmpfile"

fzf <"$tmpfile" \
    --ansi \
    --no-sort \
    --layout=reverse \
    --no-info \
    --header="  jk scroll  ·  i search  ·  ESC exit  ·  generic workflow" \
    --prompt="  " \
    --pointer="▶" \
    --bind="start:disable-search" \
    --bind="change:transform:if [[ \"\$FZF_PROMPT\" != *search* ]]; then echo 'clear-query'; fi" \
    --bind="i:enable-search+clear-query+change-prompt(  search  )" \
    --bind="j:transform:if [[ \"\$FZF_PROMPT\" != *search* ]]; then echo 'down'; else echo 'put(j)'; fi" \
    --bind="k:transform:if [[ \"\$FZF_PROMPT\" != *search* ]]; then echo 'up'; else echo 'put(k)'; fi" \
    --bind="enter:abort" \
    --bind="esc:transform:if [[ \"\$FZF_PROMPT\" != *search* ]]; then echo 'abort'; else echo 'disable-search+clear-query+change-prompt(  )'; fi" \
    --color="bg:#191724,bg+:#26233a,fg:#e0def4,fg+:#e0def4,\
hl:#c4a7e7,hl+:#c4a7e7,prompt:#9ccfd8,pointer:#eb6f92,\
gutter:#191724,separator:#393552,header:#6e6a86,border:#9ccfd8"
