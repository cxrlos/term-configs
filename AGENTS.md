# term-configs

Terminal setup shared by two machines: `thinkpunk` (Fedora 44, sway) and the macOS work Mac
(`carlos`). Being rebuilt element by element on branch `rebuild` (draft PR #19); main still
holds the old config until the rebuild merges.

## Layout
| Path | Linked to | What |
|---|---|---|
| `alacritty/` | `~/.config/alacritty` | Terminal; Tokyo Night theme in `tokyonight.toml` (folke/tokyonight.nvim extras) |
| `zsh/.zshenv`, `zsh/.zshrc` | `~/.zshenv`, `~/.zshrc` | Env/PATH for every zsh; interactive shell |
| `git/config` | `~/.config/git/config` | Shared git settings; includes machine-local `config.local` (identity, signing key) |
| `ssh/config` | `~/.ssh/config` | Shared ssh client; includes machine-local `config.local` |
| `tmux/tmux.conf` | `~/.config/tmux/tmux.conf` | Sessions, windows, copy mode; no plugins; every bind has `-N` |
| `scripts/tmux-sessionizer` | `~/.local/bin/tmux-sessionizer` (`tm`, prefix f) | Repos under `$TS_ROOTS` → session named by path (`work/api`); windows editor, agent (`$AGENT`), shell; repo `.tmux-sessionizer` adds extras |
| `atuin/config.toml` | `~/.config/atuin/config.toml` | History search UI (Ctrl+R); non-defaults only |
| `direnv/direnv.toml` | `~/.config/direnv/direnv.toml` | Quiet per-project env loading |
| `CHEATSHEET.md` | `cheat` alias | Keys and commands that have no keybind source |

Machine-only shell config goes in `~/.zshrc.local` (never committed).

## Workflow map (one owner per job; check here before adding config)
| Job | Owner |
|---|---|
| Apps, workspaces, launch, notifications, lock, screenshots, clipboard history | sway + DankMaterialShell (fedora-configs) |
| One terminal window, fonts, opening URLs | Alacritty |
| Projects: one persistent session each; windows editor, agent, shell (+ server/ad-hoc per project); scrollback search and copy mode | tmux + sessionizer |
| Command line: editing (vi mode), history, dir jumps, file finding, small helpers (`gnb`) | zsh (+ atuin, zoxide, fzf) |
| Code: editing, LSP navigation, review of changes, hunks, blame, commit, rebase/fixup | nvim (gitsigns + neogit) |
| GitHub: PRs | gh |
| AI agent | any CLI agent in the project's `agent` window. Never tie config to one provider |
| Per-project env / tasks | direnv / just |

## Rules
- Both OSes must keep working. Shared files have no OS-specific paths; branch on
  `$OSTYPE` / `$HOMEBREW_PREFIX`, or put it in `~/.zshrc.local`. The installer's macOS path
  must stay bash 3.2 compatible.
- One owner per feature (terminal, shell, tmux, nvim, desktop). Don't configure a tool's
  default, and don't rebuild something a tool already does.
- Packaged tools only (dnf / brew). No plugin managers.

## Keybind documentation
- Every binding documents itself: tmux `bind -N "…"`, nvim `desc = "…"`, sway (fedora-configs)
  `bindsym … # Description`. A bind added or changed without its note is incomplete.
- Things with no binding source (zsh vi mode, atuin/fzf/zoxide, CLI tools, Alacritty keys)
  live ONLY in `CHEATSHEET.md`. Whenever such a command, alias or keybind is created, updated
  or deleted, update `CHEATSHEET.md` in the same commit. Never copy sway, tmux or nvim binds
  into it; keep it to about 50 lines.

## TODO for the next session on the Mac (then delete this section)
The work-only lines below used to live in the shared zsh files (main @76fda80,
`zsh/.zshrc` lines 41-60 and `zsh/aliases.zsh` lines 48-52). Move what is still needed into the
Mac's `~/.zshrc.local`, drop the `fmt-itaipu` alias (Metals/Scala setup is retired), then
delete this section.

```zsh

# Source nucli environment (managed by Jamf)
[ -f "${HOME}/.nurc" ] && source "${HOME}/.nurc"

# >>> Nubank SSL Inspection CA — managed by: nu zscaler setup env >>>
# mode: baseline
# Commented out on this machine — no Zscaler cert bundle present here, and the
# missing file was breaking AWS CLI/curl/npm SSL validation. Re-enable (or let
# `nu zscaler setup env` regenerate this block) on a machine that has it.
# NUBANK_CA_CERT="$HOME/dev/nu/.nu/certificates/zscaler/ca-bundle-with-zscaler.pem"


# BASELINE — Essential SSL/TLS trust
# export SSL_CERT_FILE="$NUBANK_CA_CERT"
export SSL_CERT_DIR="/etc/ssl/certs"
# export REQUESTS_CA_BUNDLE="$NUBANK_CA_CERT"              # Python requests, urllib3
# export CURL_CA_BUNDLE="$NUBANK_CA_CERT"                  # curl, libcurl
# export AWS_CA_BUNDLE="$NUBANK_CA_CERT"                   # AWS CLI, boto3, AWS SDKs
# export NODE_EXTRA_CA_CERTS="$NUBANK_CA_CERT"             # Node.js, Bun, Claude Code, Cursor, VS Code, Copilot
# <<< Nubank SSL Inspection CA <<<
alias claude-cloud='unset ANTHROPIC_BASE_URL; unset ANTHROPIC_AUTH_TOKEN; unset ANTHROPIC_DEFAULT_HAIKU_MODEL; unset ANTHROPIC_DEFAULT_SONNET_MODEL; unset ANTHROPIC_DEFAULT_OPUS_MODEL; unset ANTHROPIC_MODEL; claude'

# scalafmt for itaipu files while inside a linked git worktree (sbt-git/JGit can't read worktrees).
# Auto-resolves the main checkout; run from anywhere in the worktree. See the script header for usage.
alias fmt-itaipu='/Users/carlos.garcia/Documents/projects/2025-11-risk-adjusted-margin-reorg/scripts/fmt-itaipu-worktree.zsh'
```
