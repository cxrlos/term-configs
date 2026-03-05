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
    head "Your stack"
    code "log-pose    main product — frontend (primary daily session)"
    code "poneglyph   Rust API + background jobs"
    code "ohara       Python ML / data services"
    code "impel-down  Rust service"
    code "pluton      Terraform infrastructure for all of the above"
    gap
    tip  "SCAN_DIRS includes ~/Documents/sustainlabs-ai — all repos show in \`f."

    head "Typical daily session: log-pose"
    body "Start: tm → pick log-pose (or \`f if already in tmux)."
    gap
    code "session: log-pose"
    code "  window 1  nvim .                  (editor)"
    code "  window 2  yarn dev / npm run dev  (dev server)"
    code "  window 3  free terminal           (git, scripts)"
    gap
    body "Open windows with \`c (inherits current dir). Label with \`,."
    tip  "Single-service session — low reconstruction cost. Sessionizer gets"
    tip  "you back instantly. No need to save unless mid-feature."

    head "Feature touching infra (your main pattern)"
    body "A log-pose feature that needs infra changes in pluton  →  one session."
    body "Name it after the feature or just keep it as log-pose."
    gap
    code "session: <feature>  (e.g. billing, auth, data-pipeline)"
    code "  window 1  log-pose   cd ~/Documents/sustainlabs-ai/log-pose"
    code "             nvim ., code changes"
    code "  window 2  pluton     cd ~/Documents/sustainlabs-ai/pluton"
    code "             terraform plan / apply"
    code "  window 3  shared     docker build, AWS CLI, curl smoke tests"
    gap
    tip  "Switch windows with \`n/p or \`1/2/3 — faster than session switching"
    tip  "for tightly coupled work in the same deploy."
    gap
    body "This session is worth saving (\`C-s) — cross-repo layout with context"
    body "is slow to reconstruct. Save before stepping away."

    head "Deployment run  (following the runbook)"
    body "Create a dedicated session when deploying across multiple services."
    gap
    code "session: deploy-dev  (or deploy-prod)"
    code "  window 1  pluton      terraform init && terraform apply"
    code "  window 2  ohara       docker build + push to ECR"
    code "  window 3  poneglyph   docker build + push (api + jobs)"
    code "  window 4  log-pose    env wiring, final smoke test"
    gap
    body "Save (\`C-s) after each runbook gate. If something fails mid-deploy,"
    body "\`C-r puts you back at the exact window/pane state."
    gap
    tip  "Kill the deploy session once deployment is confirmed good — don't"
    tip  "leave stale deploy sessions polluting your session list."

    head "Poneglyph / ohara: quick debug sessions"
    body "Most poneglyph or ohara work is short-lived: investigate, fix, move on."
    gap
    code "session: poneglyph"
    code "  window 1  nvim . / cargo build"
    code "  window 2  cargo watch -x run  (or logs from ECS)"
    gap
    tip  "Low reconstruction cost. Skip the resurrect save — sessionizer"
    tip  "recreates the session in two keystrokes."

    head "When to resurrect"
    body "Save (\`C-s):"
    body "  • log-pose + pluton cross-repo sessions"
    body "  • any active deployment session mid-runbook"
    body "  • multi-window session you spent time setting up"
    gap
    body "Skip:"
    body "  • solo poneglyph / ohara debug (fast to recreate)"
    body "  • throwaway sessions"
    gap
    body "After a reboot:"
    body "  tm  →  existing sessions listed if server was still running."
    body "  \`C-r  →  restore last saved layout if server was stopped."
    gap
    tip  "Saves are intentional (no auto-save). \`C-s when it matters."

    head "Per-project layout (hydration)"
    body "Drop a .tmux-sessionizer file in any project root. It runs once when"
    body "the session is first created — not on re-attach."
    gap
    code "#!/usr/bin/env bash"
    code "# log-pose/.tmux-sessionizer"
    code "tmux rename-window -t \"\$TMUX_SESSION\" editor"
    code "tmux send-keys -t \"\$TMUX_SESSION\" 'nvim .' Enter"
    code "tmux new-window -t \"\$TMUX_SESSION\" -n server -c \"\$PWD\""
    code "tmux send-keys -t \"\$TMUX_SESSION\" 'yarn dev' Enter"
    code "tmux new-window -t \"\$TMUX_SESSION\" -n shell  -c \"\$PWD\""
    code "tmux select-window -t \"\$TMUX_SESSION:editor\""
    gap
    tip  "Make it executable: chmod +x .tmux-sessionizer"
    tip  "TMUX_SESSION is set by the sessionizer — use it to target the right session."
    gap

    head "Session naming conventions"
    code "log-pose            active product work"
    code "<feature-name>      cross-repo feature session (e.g. billing)"
    code "deploy-dev          deployment run against dev"
    code "deploy-prod         deployment run against prod"
    code "poneglyph           backend debug / feature"
    code "ohara               data / ML work"
    code "pluton              standalone infra investigation"
    gap
    tip  "Consistent names mean \`f muscle memory. You'll know where you are"
    tip  "without reading the full session list."

    gap
} >"$tmpfile"

fzf <"$tmpfile" \
    --ansi \
    --no-sort \
    --layout=reverse \
    --no-info \
    --header="  jk scroll  ·  i search  ·  ESC exit  ·  sustainlabs workflow" \
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
