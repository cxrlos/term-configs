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
- Leading space: ` cmd` is not saved

## Finding and jumping
- `Ctrl+T`: pick a file and insert its path · `cmd **<Tab>`: fuzzy-complete a path
- `Tab`: completion menu (hjkl or arrows; case-insensitive)
- `z foo` jump to the best match for foo · `z foo bar` (several words) · `zi` interactive
- `..` or a directory name alone cds into it · `cd -<Tab>`: recent directories
- `fd name` find files · `rg text` search contents · `jq '.a.b' f.json` read JSON

## Listing and reading
- `ls` `ll` (git status) `la` `lt` (tree)
- `tldr cmd`: practical examples (`tldr --update` refreshes the pages)

## Git (nvim owns review/staging/history; these are the shell bits)
- `gnb`: new branch `type/slug`: pick the type, type a description
- `gh pr create` / `gh pr checkout <n>` / `gh pr view --web`
- Commits and tags are SSH-signed (`git log --show-signature`)

## Projects and worktrees (tmux)
- `tm` / prefix f: org → repo (Enter opens, Esc up, `*` open). prefix s: session tree
- Main checkout = editor, shell. `wt new feat "Add X"` → `<repo>.wt/feat-add-x` session
  with editor, agent, shell (agent edits only; you commit). `wt rm` cleans up (refuses if dirty)
- Repo hook `.tmux-sessionizer` runs only after `tmux-sessionizer --allow <dir>`

## Per project
- `.envrc` + `direnv allow`: env vars load on cd and unload on leave
- `just`: list the justfile recipes · `just <recipe> [args]`

## Alacritty
- Ctrl+Shift+C / V copy / paste · select + middle-click pastes the selection
- Ctrl+Shift+F / B search · Ctrl+Shift+O open a URL (or click it)
- Ctrl+Shift+Space: vi mode over scrollback · Ctrl+= / - / 0 font size
- Shift+Return: newline without sending (Claude Code)
