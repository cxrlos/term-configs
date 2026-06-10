#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$REPO_DIR/zsh/palette.sh"

YAML="$REPO_DIR/sessionizer/projects.yaml"

_get_machine_id() {
    local id_file="${XDG_CONFIG_HOME:-$HOME/.config}/sessionizer/machine-id"
    if [[ -f "$id_file" ]]; then
        cat "$id_file"
        return
    fi
    local mid=""
    if [[ "$(uname)" == "Darwin" ]]; then
        mid=$(ioreg -rd1 -c IOPlatformExpertDevice | awk -F'"' '/IOPlatformUUID/{print $4}')
    elif [[ -f /etc/machine-id ]]; then
        mid=$(cat /etc/machine-id)
    fi
    [[ -n "$mid" ]] || {
        echo "unknown"
        return 1
    }
    mkdir -p "$(dirname "$id_file")"
    printf '%s' "$mid" >"$id_file"
    echo "$mid"
}

MACHINE_ID=$(_get_machine_id)

printf '\n'
read -r -p "  Project path (e.g. ~/Documents/projects/my-app): " project_path
[[ -z "$project_path" ]] && exit 1
project_path="${project_path/#\~/$HOME}"

if [[ -d "$project_path" ]]; then
    _warn "Directory already exists: $project_path"
    read -r -p "  Continue anyway? [y/N] " yn
    [[ "$yn" =~ ^[yY]$ ]] || exit 1
fi

read -r -p "  What kind of project? (e.g. rust cli, next.js app, python api): " description
[[ -z "$description" ]] && exit 1

printf '\n'
_info "Scaffolding with Claude Code..."
printf '\n'

mkdir -p "$project_path"

project_name=$(basename "$project_path")
yaml_path="${project_path/#$HOME/~}"

claude --print --dangerously-skip-permissions -p \
    "Create a new project at $project_path. Type: $description.

Requirements:
- Create the directory structure and initial files following $description conventions
- Create a README.md with project name and a one-line description
- Keep everything minimal — only what's needed to start working
- Do NOT install dependencies, just set up the files
- Output ONLY a YAML snippet for tmux hydration windows on the LAST line, formatted as:
  HYDRATE: [{\"name\": \"editor\", \"cmd\": \"nvim .\"}, {\"name\": \"claude\", \"cmd\": \"claude --ide\"}, {\"name\": \"dev\", \"cmd\": \"npm run dev\"}, {\"name\": \"shell\"}]
  Adapt the windows to the project type. Always include editor (nvim .), claude (claude --ide), and shell. The --ide flag is required so Claude auto-connects to the Neovim WebSocket bridge." 2>/dev/null | tee /tmp/scaffold-output.txt

hydrate_line=$(grep '^HYDRATE: ' /tmp/scaffold-output.txt 2>/dev/null | tail -1 || true)
rm -f /tmp/scaffold-output.txt

if [[ -f "$YAML" ]]; then
    if ! yq -e ".projects[] | select(.id == \"$project_name\")" "$YAML" &>/dev/null; then
        yq -i ".projects += [{\"id\": \"$project_name\", \"locations\": {\"$MACHINE_ID\": \"$yaml_path\"}}]" "$YAML"
    fi
else
    mkdir -p "$(dirname "$YAML")"
    cat >"$YAML" <<EOF
machines: {}
orgs: []
projects:
  - id: $project_name
    locations:
      $MACHINE_ID: $yaml_path
EOF
fi

if [[ -n "$hydrate_line" ]]; then
    local_json="${hydrate_line#HYDRATE: }"
    proj_idx=$(yq ".projects | to_entries | .[] | select(.value.id == \"$project_name\") | .key" "$YAML")
    if [[ -n "$proj_idx" ]]; then
        yq -i ".projects[$proj_idx].hydrate = $local_json" "$YAML"
    fi
fi

printf '\n'
_ok "Project ready at $project_path"
printf '\n'

echo "$project_path"
