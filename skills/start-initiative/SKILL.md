---
name: start-initiative
description: Scaffold or open an "initiative" that bridges a metadata workspace (~/Documents/projects/<id>) with its code checkout(s) under your configured code root (INITIATIVE_DEV_ROOT), optionally on git worktrees. Use when starting a new project/initiative, or linking (retrofitting) an existing project dir to its code. Triggered by phrases like "new initiative", "start a project", "scaffold a project", "set up a worktree for", "link this project to a repo".
argument-hint: [new | retrofit <existing-dir>]
allowed-tools: [Read, Glob, Grep, Bash, Edit, Write, AskUserQuestion]
---

# Start Initiative

Create or link an **initiative**: a `~/Documents/projects/<id>` metadata workspace bound to one or more code checkouts (under the code root `initiative` resolves against) via a `.initiative.yaml` manifest, opened as a single tmux session (`` `p `` picker).

## Git carve-out (important)

`~/Documents/projects/shared/AGENT_RULES.md` §0 says the agent never runs git. This skill has ONE explicit exception, authorized by the user: it MAY run `gwt add` / `gwt remove` (git worktree add/remove) to provision code checkouts. It must NEVER `commit`, `push`, `pull`, `switch`, `merge`, or `rebase`. Everything else in §0 still holds.

## Mode: new

1. Read `~/Documents/projects/shared/INIT.md`, `shared/AGENT_RULES.md`, and `shared/README.md` — the folder-structure and section conventions live there. If a well-structured existing project `README.md` is present, use it as the format example.
2. Ask the INIT.md questions (identity, type, repo(s), scope, success criteria). Ask which repo(s) the work touches and their paths under your code root, and for each whether it needs an isolated git **worktree** (yes when another branch/initiative is already using that repo).
3. On confirmation, scaffold `~/Documents/projects/<YYYY-MM-topic>/`:
   - `README.md` (mirror the example structure), `TASK.md` (from `shared/templates/TASK_TEMPLATE.md`), empty `docs/`, `logs/`, `archive/`.
4. Write `.initiative.yaml` with `id`, `title`, and a `checkouts:` list — each entry a `repo:` name, plus `worktree: <slug>` for each checkout that needs isolation.
5. For each checkout that needs a worktree, run `gwt add <slug> --repo <path-to-repo>` (the repo's path under your code root — the same root `initiative resolve` uses). Then run `gwt guard --repo <path-to-repo>` once per repo to seed the personal-ignore safety net in `.git/info/exclude`.
6. Verify: `initiative resolve <id>` prints the workspace and each checkout as `ok`.
7. Tell the user: "Open it with `` `p `` → <id>." Do not attach the session yourself.

## Mode: retrofit <existing-dir>

For an existing `~/Documents/projects/<dir>` (e.g. a past project). Touch nothing except adding the manifest:

1. Confirm with the user which repo(s)/worktree the project maps to.
2. Write only `~/Documents/projects/<dir>/.initiative.yaml`.
3. Confirm `initiative list` now shows it. Do not modify any existing file in the dir.

## Notes

- The manifest `id` becomes the tmux session name (`.`/`/` → `_`). Keep it a single token.
- Metadata stays in the workspace; the code checkout stays pristine (the session's `claude` window is rooted in the workspace with `--add-dir` to the checkouts).
- `initiative` and `gwt` are on PATH (installed from term-configs).
