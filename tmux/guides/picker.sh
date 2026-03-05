#!/usr/bin/env bash

GUIDES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

selected=$(printf 'Generic workflow\nSustainLabs AI\n' |
    fzf --prompt="  " \
        --header="  pick a guide" \
        --no-info \
        --layout=reverse \
        --color="bg:#191724,bg+:#26233a,fg:#e0def4,fg+:#e0def4,\
hl:#c4a7e7,hl+:#c4a7e7,prompt:#9ccfd8,pointer:#eb6f92,\
gutter:#191724,header:#6e6a86,border:#9ccfd8") || exit 0

case "$selected" in
    "Generic workflow")    exec "$GUIDES_DIR/generic.sh" ;;
    "SustainLabs AI")      exec "$GUIDES_DIR/sustainlabs.sh" ;;
esac
