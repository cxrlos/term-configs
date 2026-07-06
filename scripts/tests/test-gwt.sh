#!/usr/bin/env bash
# Tests for scripts/gwt against a throwaway git repo.
set -u
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
# shellcheck source=scripts/tests/lib.sh
. "$HERE/lib.sh"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
TMP="$(cd "$TMP" && pwd -P)"   # resolve macOS /var -> /private/var so path asserts match git's output

git init -q "$TMP/proj"
cd "$TMP/proj" || exit 1
git config user.email t@t.t
git config user.name t
printf '.mise.toml\n' >.gitignore   # so the seeded file below doesn't block worktree removal
git add .gitignore
git commit -q -m init
printf 'tools\n' >.mise.toml   # a gitignored-style setup file to seed

GWT="$REPO/scripts/gwt"

# add
wt="$("$GWT" add feature-x --prefix feat)"
assert_eq "add returns worktree path" "$TMP/proj/.worktrees/feature-x" "$wt"
assert_eq "worktree dir exists" "yes" "$([[ -d "$TMP/proj/.worktrees/feature-x" ]] && echo yes || echo no)"
assert_eq "branch created" "feat/feature-x" "$(git -C "$TMP/proj/.worktrees/feature-x" rev-parse --abbrev-ref HEAD)"
assert_eq "setup file seeded" "yes" "$([[ -f "$TMP/proj/.worktrees/feature-x/.mise.toml" ]] && echo yes || echo no)"
assert_contains ".worktrees ignored" ".worktrees/" "$(cat "$TMP/proj/.git/info/exclude")"

# list
assert_contains "list shows worktree" "feature-x" "$("$GWT" list)"

# main
assert_eq "main prints primary checkout" "$TMP/proj" "$("$GWT" main)"

# remove
"$GWT" remove feature-x
assert_eq "worktree removed" "no" "$([[ -d "$TMP/proj/.worktrees/feature-x" ]] && echo yes || echo no)"

# _main_checkout must resolve the PRIMARY checkout even when invoked from inside a worktree
"$GWT" add wt-two --prefix feat >/dev/null
assert_eq "main from inside a worktree" "$TMP/proj" "$(cd "$TMP/proj/.worktrees/wt-two" && "$GWT" main)"
assert_eq "path from inside a worktree" "$TMP/proj/.worktrees/wt-two" "$(cd "$TMP/proj/.worktrees/wt-two" && "$GWT" path wt-two)"

# slug normalization
assert_eq "slug normalizes" "my-feature-name" "$("$GWT" slug 'My Feature Name')"

# guard seeds an idempotent personal-ignore block (run twice -> marker appears once)
"$GWT" guard >/dev/null
"$GWT" guard >/dev/null
assert_eq "guard marker present once" "1" "$(grep -c 'initiative-guard' "$TMP/proj/.git/info/exclude")"

# --repo targets a repo from outside its tree
assert_contains "list --repo finds worktree" "wt-two" "$(cd /tmp && "$GWT" list --repo "$TMP/proj")"

tests_summary
