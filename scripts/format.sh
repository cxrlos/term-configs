#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "→ Formatting shell scripts..."
if command -v shfmt &>/dev/null; then
    shfmt -w -i 4 -ci "$ROOT/scripts/"*.sh "$ROOT/scripts/tmux-sessionizer" "$ROOT/tmux/cheatsheet.sh"
    echo "✓ Formatted"
else
    echo "✗ shfmt not installed (brew install shfmt)"
    exit 1
fi
