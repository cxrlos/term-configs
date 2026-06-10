# Terminal Config

Personal terminal stack: Alacritty + Zsh + tmux + Starship. Rose Pine everywhere, ProFont Nerd Font. Targets macOS and Arch Linux.

## Stack

| Layer        | Choice                                                |
|--------------|-------------------------------------------------------|
| Terminal     | Alacritty (`alacritty/alacritty.toml`)                |
| Shell        | Zsh + zinit (plugins loaded by `zsh/.zshrc`)          |
| Multiplexer  | tmux + TPM (resurrect, fzf, thumbs, extrakto, open)   |
| Prompt       | Starship (`starship/starship.toml`)                   |
| History      | Atuin · Dir-jump: zoxide · Env: direnv                |
| Fuzzy        | fzf everywhere — sessionizer, branch switcher, gum    |

## Layout

| Dir / file                  | Purpose                                                       |
|-----------------------------|---------------------------------------------------------------|
| `alacritty/`                | Terminal config (font, padding, Rose Pine theme)              |
| `starship/`                 | Prompt config                                                 |
| `tmux/tmux.conf`            | tmux config — prefix is backtick (`` ` ``)                    |
| `tmux/cheatsheet.sh`        | `` `? `` popup — key reference                                 |
| `zsh/`                      | Modular shell config (one concern per file)                   |
| `zsh/palette.sh`            | **Only** place hex codes live. Source it, use `$_iris` etc.   |
| `zsh/nubank.zsh`            | Work overlay — gitignored, sensitive                          |
| `scripts/install.sh`        | Bootstrap installer (macOS + Arch)                            |
| `scripts/tmux-sessionizer`  | The session picker (`tm` from shell, `` `f `` from tmux)       |
| `scripts/sessionizer-add`   | Register / scaffold a project at `pwd`                        |
| `scripts/new-project.sh`    | (Legacy) Project scaffolder — superseded by sessionizer-add   |
| `scripts/lidrun.sh`         | One-shot script runner                                        |
| `scripts/format.sh`         | Bulk formatter                                                |
| `sessionizer/projects.yaml` | **Cross-machine** project registry (see "Sessionizer" below)  |

## Conventions

Inherits all global conventions (Rose Pine, rounded popups, foam/iris/pine/gold semantics, sensitive-file rules). Specific to this repo:

- **All shell scripts target Bash 3.2.** macOS ships ancient bash; Homebrew bash isn't on PATH at install time. No `local -n` (namedref, 4.3+), no `${var,,}` (lowercase, 4.0+), no associative arrays without `declare -A` guards, no `mapfile`/`readarray`. Pass array contents as positional args (`shift`+`"$@"`).
- **Color codes via `palette.sh` only.** Source `$REPO_DIR/zsh/palette.sh` and use `$_iris`, `$_foam`, `$_pine`, `$_gold`, `$_love`, `$_rose`, `$_subtle`. Never hardcode hex in scripts.
- **Status helpers from palette:** `_err`, `_warn`, `_info`, `_ok`, `_dim` — single-character glyph + colored prefix. Use these instead of raw printf for user-facing status lines.
- **`_` prefix = private.** Functions like `_apply_map`, `_register_project`, `_ensure_yaml` aren't called outside the script.
- **Repo path resolution from a subdir-script:**
  ```bash
  REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  ```
- **zsh module load order is in `.zshrc`** — env → shell → vim → git → aliases → utils → nubank (if present) → fzf → tmux. Don't add new top-level concerns without picking a position.

## Sessionizer & cross-machine projects

This is the architectural choice that everything else hangs on. **Read this section before touching `projects.yaml`, `sessionizer-add`, `new-project.sh`, or `tmux-sessionizer`.**

`sessionizer/projects.yaml` is a registry of projects shared across all my machines. Each project has one ID and a `locations` map keyed by `hostname -s`:

```yaml
projects:
  - id: term-configs
    locations:
      carlos:  /Users/carlos.garcia/Documents/configs/term-configs
      laptop:  ~/code/term-configs
  - id: itaipu
    locations:
      carlos:  /Users/carlos.garcia/dev/nu/itaipu
```

**The intent:** the same logical project lives at different absolute paths on different machines. The YAML maps `id` → `(machine, path)`. The file is git-tracked and synced via push/pull. `tmux-sessionizer` filters by `hostname -s` and surfaces only the entries that exist on the current machine.

**Behavior of `sessionizer-add`:**
- If `id` doesn't exist → adds new project entry with `(this machine, this path)`.
- If `id` exists but no entry for this machine → adds this machine's path to the existing project (preserving other machines' entries).
- If this machine already has an entry → warns, no-op.

**THE RULE FOR AGENTS (Claude on any machine):**

> **When editing `projects.yaml`, you ONLY add or update entries for the current machine's hostname. You NEVER remove or modify entries for other hostnames.**

If you see `locations.foo: /Users/foo/...` on a machine called `bar`, that's data for machine `foo` — leave it alone. It's not stale, it's not wrong, it's just not yours. Removing it breaks the cross-machine sync the next time `foo` pulls.

Past incident: a Claude session on a second MacBook decided unknown hostnames in `projects.yaml` were "stale" and pruned them. The next pull on the primary machine wiped its project list. This caveat exists because of that.

If you genuinely need to delete a hostname's entries (machine retired), do it manually — never automate.

## Hydration: `.tmux-sessionizer` per project

Optional executable script at the root of any project. `tmux-sessionizer` runs it once when creating the session (re-attach skips it). Pattern:

```bash
#!/usr/bin/env bash
tmux rename-window -t "$TMUX_SESSION" 'editor'
tmux send-keys    -t "$TMUX_SESSION:editor" 'nvim .' Enter

tmux new-window   -t "$TMUX_SESSION" -n 'claude' -c "$PROJECT_DIR"
tmux send-keys    -t "$TMUX_SESSION:claude" 'claude --ide' Enter

tmux new-window   -t "$TMUX_SESSION" -n 'shell'  -c "$PROJECT_DIR"
tmux select-window -t "$TMUX_SESSION:editor"
```

Rules:
- Use `$TMUX_SESSION` for targeting (set by the sessionizer before invocation).
- Use `$PROJECT_DIR` for `-c` (also set by the sessionizer — this machine's project path). Never hardcode an absolute path; it's git-tracked and breaks when the repo syncs to another machine.
- Rename window 1 (it always exists); don't create a duplicate `editor`.
- End by selecting the window you want focused.
- Include `claude --ide` so Claude Code auto-connects to Neovim's `claudecode.nvim` WebSocket bridge.
- Make it executable: `chmod +x .tmux-sessionizer`.

If no `.tmux-sessionizer` exists, the default layout is `editor` (nvim .) + `shell`.

## tmux

Prefix: `` ` `` (backtick, send-prefix via double-backtick). Picked for speed — one key, no modifier.

| Binding         | Action                                                           |
|-----------------|------------------------------------------------------------------|
| `` `f ``        | Sessionizer (fzf project picker)                                 |
| `` `g ``        | lazygit popup                                                    |
| `` `t ``        | Floating shell popup (current pane's cwd)                        |
| `` `? ``        | tmux keys cheatsheet                                             |
| `` `m ``        | htop popup                                                       |
| `` `c ``        | New window in current path                                       |
| `` `n / p ``    | Next / prev window                                               |
| `` `v / `s ``   | Split right / down                                               |
| `` `z ``        | Zoom pane                                                        |
| `` `x / `X ``   | Kill pane / window                                               |
| `` `r ``        | Reload tmux.conf                                                 |
| `` `C-s / `C-r``| Save / restore session (tmux-resurrect)                          |
| `C-h/j/k/l`     | Pane navigation (no prefix, vim-tmux-navigator aware)            |

Window 1-9 jump via `` `1 ``…`` `9 ``. Resize panes (repeatable) via `` `H/J/K/L ``. Last window `` `^ ``.

Status bar: session name on left (iris background), git branch + clock on right (iris/foam/subtle). Inactive panes have darker bg so active appears to float.

## Known caveats

**Bash 3.2 compatibility (macOS default)**
macOS ships `/bin/bash` 3.2 (last GPLv2 release, frozen since 2007). Homebrew bash lives at `/opt/homebrew/bin/bash` but isn't on PATH before Homebrew is installed. Script syntax must work on 3.2.

Burnt: `_apply_map` in `install.sh` originally used `local -n map=$1` (namedref, bash 4.3+) → cryptic `local: -n: invalid option` on fresh MacBook. Fix: pass array contents as `"${ARRAY[@]}"` positional args, not array name. Pattern:

```bash
# Wrong (bash 4.3+):
_fn() { local -n arr=$1; for x in "${arr[@]}"; do ...; done; }
_fn MY_ARRAY

# Right (bash 3.2+):
_fn() { for x in "$@"; do ...; done; }
_fn "${MY_ARRAY[@]}"
```

Use `bash -n script.sh` and `/bin/bash -n script.sh` to catch this before commit.

**`projects.yaml`: additive across machines — never remove other hostnames' entries**
See "Sessionizer & cross-machine projects" above. This is the #1 thing an agent can break.

**`sessionizer-add` reads `pwd`**
`cd` into the project directory first. Running it elsewhere registers the wrong path. The `entry_id` is `basename "$(pwd)"`.

**`new-project.sh` parses Claude output**
The script shells out to `claude --print --dangerously-skip-permissions` and `grep`s for a `HYDRATE:` line at the tail. If Claude's wrapping ever changes, this breaks silently. Prefer `sessionizer-add → Scaffold` for new projects — it's the actively-maintained path.

**Sensitive: never commit**
`zsh/nubank.zsh` (work overlay) is gitignored. Contains paths like `$NU_HOME`, `$NUCLI_HOME`, customer-specific aliases, and work S3 prefixes. Don't echo it in commits, don't include its contents in PRs, don't hard-code its paths into shared scripts. If you reference work patterns, gate behind `[[ -f "$ZSH_CONFIG_DIR/nubank.zsh" ]]`.

Same rule applies to anything containing real customer IDs, account IDs, S3 paths from work pipelines, or API tokens.

**`palette.sh` is the single source of color truth**
Never reintroduce inline hex literals in shell scripts. Source `palette.sh`, use `$_iris`, `$_foam`, etc. Adding a new color: edit `palette.sh` first. Same applies for tmux color strings — keep them centralized in `tmux.conf` near the Rose Pine palette comment block.

**TPM auto-installs plugins on first tmux launch**
The bottom of `tmux.conf` clones TPM if missing. First tmux session: prefix + I to install plugins. After that: no-op. If plugins look broken, run `~/.tmux/plugins/tpm/bin/install_plugins`.

**`.zshrc` ends with `tm`**
Last line of `.zshrc` launches the sessionizer (`tm`) automatically. Shell never lands on a bare prompt — you always pick or open a session. If you ssh in and want a plain shell, prefix `BASH_ENV= zsh -f` or comment out the line for that session.

**Status helpers write to `~/.cache/zsh_bg_jobs`**
`_bg_write_count` (in `zsh/shell.zsh`) is a precmd hook that writes a count of background jobs to a cache file, read by tmux's status bar. If the status bar shows a stale job count, the file may be stale; `touch ~/.cache/zsh_bg_jobs` or just type `enter` to retrigger.

**Sessionizer hostname keys**
`MACHINE_NAME=$(hostname -s)`. If your hostname changes (e.g., macOS prompts to rename your Mac), existing entries in `projects.yaml` don't auto-migrate. Add a new entry under the new hostname; the old one becomes harmless dead weight (won't show up for any machine).

## Debugging strategy

1. **`install.sh` failures**: re-run with `bash -x scripts/install.sh` to see exact failing line. If error mentions "invalid option" or "namedref" → bash version. Check `bash --version`; install via `brew install bash` and re-run. The Homebrew bash auto-resolves via the script's `#!/usr/bin/env bash` shebang once Homebrew's bin is on PATH.
2. **Sessionizer not finding a project**: run `hostname -s` and grep `sessionizer/projects.yaml` for that exact key. If missing or wrong → `cd` into the project and run `sessionizer-add`.
3. **tmux config not reloading**: prefix + r reloads. `tmux source ~/.tmux.conf` from any shell also works. `tmux show-options -g` to inspect live config.
4. **TPM not installing**: prefix + I from inside tmux. If still nothing, `ls ~/.tmux/plugins/` to confirm TPM cloned, then `~/.tmux/plugins/tpm/bin/install_plugins`.
5. **`claude --ide` doesn't connect** (from a project hydrated by `.tmux-sessionizer`): `ls ~/.claude/ide/*.lock`. If empty, Neovim isn't running with `claudecode.nvim` loaded yet — start Neovim first, then `/ide` inside Claude.
