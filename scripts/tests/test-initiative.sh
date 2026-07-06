#!/usr/bin/env bash
# Tests for scripts/initiative. Runs against temp fixtures; touches no real dirs.
set -u
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
# shellcheck source=scripts/tests/lib.sh
. "$HERE/lib.sh"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

export INITIATIVE_PROJECTS_ROOT="$TMP/projects"
export INITIATIVE_DEV_ROOT="$TMP/dev"
mkdir -p "$INITIATIVE_PROJECTS_ROOT/2026-07-clp" "$INITIATIVE_DEV_ROOT/itaipu"

cat >"$INITIATIVE_PROJECTS_ROOT/2026-07-clp/.initiative.yaml" <<'YAML'
id: clp
title: CLP New Source
checkouts:
  - repo: itaipu
YAML

# a plain project dir WITHOUT a manifest must be ignored
mkdir -p "$INITIATIVE_PROJECTS_ROOT/2025-11-old"

out="$("$REPO/scripts/initiative" list)"
assert_eq "list shows manifested id" "clp" "$out"

# resolve: main checkout that exists
res="$("$REPO/scripts/initiative" resolve clp)"
assert_contains "resolve emits workspace" "$(printf 'workspace\t%s/2026-07-clp' "$INITIATIVE_PROJECTS_ROOT")" "$res"
assert_contains "resolve main is ok" "$(printf 'checkout\titaipu\t%s/itaipu\tok' "$INITIATIVE_DEV_ROOT")" "$res"

# resolve: declared worktree missing but main exists -> fellback
cat >"$INITIATIVE_PROJECTS_ROOT/2026-07-clp/.initiative.yaml" <<'YAML'
id: clp
checkouts:
  - repo: itaipu
    worktree: wt-a
YAML
res="$("$REPO/scripts/initiative" resolve clp)"
assert_contains "missing worktree falls back to main" "$(printf '\titaipu\t%s/itaipu\tfellback' "$INITIATIVE_DEV_ROOT")" "$res"

# resolve: worktree exists -> ok, path points at the worktree
mkdir -p "$INITIATIVE_DEV_ROOT/itaipu/.worktrees/wt-a"
res="$("$REPO/scripts/initiative" resolve clp)"
assert_contains "existing worktree resolves to worktree path" "$(printf '\titaipu\t%s/itaipu/.worktrees/wt-a\tok' "$INITIATIVE_DEV_ROOT")" "$res"

# resolve: repo dir absent -> missing
cat >"$INITIATIVE_PROJECTS_ROOT/2026-07-clp/.initiative.yaml" <<'YAML'
id: clp
checkouts:
  - repo: ghost
YAML
res="$("$REPO/scripts/initiative" resolve clp)"
assert_contains "absent repo is missing" "$(printf '\tghost\t%s/ghost\tmissing' "$INITIATIVE_DEV_ROOT")" "$res"

tests_summary
