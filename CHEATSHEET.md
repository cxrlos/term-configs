# Cheatsheet: things with no keybind source

Elsewhere: sway keys `Super+?` · tmux keys `prefix ?` · nvim keys `<leader>` and wait.

## zsh vi mode (Esc = normal, block cursor · i/a/A/I = insert, bar cursor)
- Move: `w b e` · `0 ^ $` · `f t ; ,`. Edit: `x r ~ . u`, Ctrl+R = redo (normal mode)
- Text objects: `ciw` `ci"` `da(` `yi{` `dt/`. Visual: `v` `V`
- Surround: `saiw"` add · `sd"` delete · `sr"'` replace · visual `S"` wrap
- `vv` (normal) or Ctrl+X Ctrl+E (insert): edit the line in nvim. `:wq` puts it back; Enter runs it
- `y` and `p` use zsh's own buffer, not the system clipboard

## History
- Type a prefix, then `↑` / `↓`: this session's commands starting with it
- `Ctrl+R` (or Esc `/`): atuin over all history. Ctrl+R again cycles the filter
  (global, host, session, directory, workspace = this git repo). Enter/Tab puts the
  command on the line; Enter again runs it
- Leading space: ` cmd` is not saved; lines with `password=`/`token=`/`api_key=`… never are

## Finding and jumping
- `Ctrl+T`: pick a file and insert its path · `cmd **<Tab>`: fuzzy-complete a path
- `Tab`: completion menu (hjkl or arrows; case-insensitive)
- `z foo` jump to the best match for foo · `z foo bar` (several words) · `zi` interactive
- `..` or a directory name alone cds into it · `cd -<Tab>`: recent directories
- `fd name` find files · `rg text` search contents · `jq '.a.b' f.json` read JSON

## Prompt and reading
- path (@ = ~/dev) · branch `+`staged `*`changed ⇡⇣ `✗gone` `≡`stash · (venv) :PORT · time >5s;
  next line: ✦jobs, exit code, ❯ (red = failed) · `ll` = `ls -lah` · `tldr cmd` examples

## Git (nvim owns review/staging/history; these are the shell bits)
- `gnb`: new branch `type/slug`: pick the type, type a description
- `gh pr create` / `gh pr checkout <n>` / `gh pr view --web`
- Commits and tags are SSH-signed (`git log --show-signature`); pre-push refuses unsigned ones
- gitleaks blocks commits with secrets. False positive: `# gitleaks:allow` on the line, or `git commit --no-verify` once
- delta diffs are side-by-side, links Ctrl+click; one narrow diff: `git -c delta.side-by-side=false diff`

## Projects and worktrees (tmux)
- `tm` / prefix f: org → repo (Enter opens, Esc up, `*` open; typing searches full paths). prefix s: tree
- Main checkout = editor, shell. `wt new feat "Add X"` → `<repo>.wt/feat-add-x` session
  from fresh origin default (`--from upstream` / `--from origin/rel`); editor, agent, shell.
  Agent edits only; you commit. `wt rm` cleans up (refuses if dirty or unpushed)
- Repo hook `.tmux-sessionizer` runs only after `tmux-sessionizer --allow <dir>`

## Per project
- `.envrc` + `direnv allow`: env vars load on cd and unload on leave
- `just`: list the justfile recipes · `just <recipe> [args]`

## Alacritty
- Mouse: wheel scrolls, clicks do nothing (also tmux, nvim). Copy: tmux copy mode, or vi mode below then Ctrl+Shift+C
- Ctrl+Shift+V paste · Ctrl+Shift+F / B search · Ctrl+Shift+O pick a URL to open
- Ctrl+Shift+Space: vi mode over scrollback (v select, y copy) · Ctrl+= / - / 0 font size
- Shift+Return: newline without sending (Claude Code)
