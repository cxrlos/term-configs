# term-configs

Terminal setup shared by two machines: `thinkpunk` (Fedora 44, sway) and the macOS work Mac
(`carlos`). `./install.sh` sets up either machine (packages, font, links) and is safe to re-run;
`./install.sh --check` reports what's missing without changing anything.

## Layout
| Path | Linked to | What |
|---|---|---|
| `install.sh` | — | Installer (bash 3.2). Fedora packages (`DNF_PKGS`), pinned + hash-checked font, links (real files are backed up to `~/.local/state/term-configs/`), then what's left for you |
| `Brewfile` | — | macOS packages and casks (`brew bundle`) |
| `alacritty/` | `~/.config/alacritty` | Terminal (Fedora); Tokyo Night theme in `tokyonight.toml` (folke/tokyonight.nvim extras) |
| `ghostty/config` | `~/.config/ghostty/config` (macOS) | Terminal (macOS); mirrors Alacritty: Commit Mono, built-in `TokyoNight Night` theme |
| `zsh/.zshenv`, `zsh/.zprofile`, `zsh/.zshrc` | `~/.zshenv`, `~/.zprofile`, `~/.zshrc` | Env for every zsh; login (re-applies `zsh/path.zsh` after macOS path_helper); interactive shell |
| `git/config` | `~/.config/git/config` | Shared git settings; includes machine-local `config.local` (identity, signing key) |
| `git/ignore` | `~/.config/git/ignore` | Global ignores: `.review.md` (nvim review notes for the agent) |
| `git/hooks/` | `~/.config/git/hooks` (`core.hooksPath`) | Every repo: gitleaks pre-commit, signed-only pre-push; other hook names → `chain`, which runs the repo's own `.git/hooks/<name>` |
| `ssh/config` | `~/.ssh/config` | Shared ssh client; includes machine-local `config.local` |
| `tmux/tmux.conf` | `~/.config/tmux/tmux.conf` | Sessions, windows, copy mode; no plugins; every bind has `-N` |
| `scripts/tmux-sessionizer` | `~/.local/bin/tmux-sessionizer` (`tm`, prefix f) | Repos under `$TS_ROOTS`, browsed org → repo; session named by path (`nu/api`). Main checkout: editor, shell. Linked worktree: editor, agent, shell. Repo `.tmux-sessionizer` hook runs only after `--allow` (hash-pinned) |
| `scripts/wt` | `~/.local/bin/wt` | Worktree per task at `<repo>.wt/<branch>`; `wt new`, `wt rm`. Setup runs from the repo's allowed hook, not from wt |
| `examples/tmux-sessionizer` | — | Template repo hook: `setup` window in new worktrees (`just setup`), optional extras |
| `scripts/agent-run` | `~/.local/bin/agent-run` | Starts `$AGENT` with an allowlisted env (no ssh-agent, tokens, D-Bus, tmux). Linux: inside bubblewrap, basics only: whole filesystem + network as usual; control sockets (`$XDG_RUNTIME_DIR`, tmux), key material and other processes hidden |
| `oh-my-posh/prompt.toml` | `~/.config/oh-my-posh/prompt.toml` | Prompt (Fedora/brew `oh-my-posh`): path, git, slow-command time, ❯; upgrade notices off |
| `atuin/config.toml` | `~/.config/atuin/config.toml` | History search UI (Ctrl+R): AI off, secret filter; non-defaults only |
| `direnv/direnv.toml` | `~/.config/direnv/direnv.toml` | Quiet per-project env loading |
| `CHEATSHEET.md` | `cheat` alias | Keys and commands that have no keybind source |

Machine-only shell config goes in `~/.zshrc.local` (never committed).

## Workflow map (one owner per job; check here before adding config)
| Job | Owner |
|---|---|
| Apps, workspaces, launch, notifications, lock, screenshots, clipboard history | sway + DankMaterialShell (fedora-configs) |
| One terminal window, fonts, opening URLs | Alacritty (Fedora) / Ghostty (macOS) |
| Projects: one persistent session each; windows editor, agent, shell (+ server/ad-hoc per project); scrollback search and copy mode | tmux + sessionizer |
| Command line: editing (vi mode), history, dir jumps, file finding, small helpers (`gnb`) | zsh (+ atuin, zoxide, fzf) |
| Code: editing, LSP navigation, review of changes, hunks, blame, commit, rebase/fixup | nvim (gitsigns + neogit) |
| GitHub: PRs | gh |
| AI agent | any CLI agent (`$AGENT`) in a worktree session's `agent` window, started by `agent-run`. Agents edit files only: humans stage, commit, sign, push. Never tie config to one provider |
| Per-project env / tasks | direnv / just |

## Rules
- Both OSes must keep working. Shared files have no OS-specific paths; branch on
  `$OSTYPE` / `$HOMEBREW_PREFIX`, or put it in `~/.zshrc.local`. The installer's macOS path
  must stay bash 3.2 compatible.
- One owner per feature (terminal, shell, tmux, nvim, desktop). Don't configure a tool's
  default, and don't rebuild something a tool already does.
- Packaged tools only (dnf / brew). No plugin managers. A new tool goes in both `DNF_PKGS`
  (install.sh) and `Brewfile`; a new linked file goes in `LINKS` (install.sh) and the table above.

## Keybind documentation
- Every binding documents itself: tmux `bind -N "…"`, nvim `desc = "…"`, sway (fedora-configs)
  `bindsym … exec … # Description` (built-in sway commands: no trailing text; see fedora-configs AGENTS.md). A bind added or changed without its note is incomplete.
- Things with no binding source (zsh vi mode, atuin/fzf/zoxide, CLI tools, Alacritty keys)
  live ONLY in `CHEATSHEET.md`. Whenever such a command, alias or keybind is created, updated
  or deleted, update `CHEATSHEET.md` in the same commit. Never copy sway, tmux or nvim binds
  into it; keep it to about 50 lines.
