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

tests_summary
