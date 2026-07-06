# Terminal Configuration

Alacritty + Zsh + tmux + Starship. Catppuccin Mocha, Monaspace Neon Nerd Font. macOS and Arch Linux.

## Install

```bash
git clone https://github.com/cxrlos/term-configs.git
cd term-configs
bash scripts/install.sh
```

## Project management

```bash
sessionizer-add          # cd into dir first — import or scaffold
tm                       # fzf picker from shell
# `f from inside tmux
```

Projects registered in `sessionizer/projects.yaml`, synced across machines via git.

## tmux

Prefix: `` ` ``

`` `f `` sessionizer · `` `g `` lazygit · `` `t `` popup shell · `` `? `` cheatsheet

`C-h/j/k/l` pane nav (no prefix) · `` `v `` split right · `` `s `` split down · `` `z `` zoom · `` `x `` kill

## Initiatives

An **initiative** binds a metadata workspace (`~/Documents/projects/<id>/`) to its code
checkout(s) under `~/dev/nu`, so one tmux session opens both. The link is a manifest at
`~/Documents/projects/<id>/.initiative.yaml`:

```yaml
id: clp-new-source
title: CLP New Spend Source Validation
checkouts:
  - repo: itaipu
    worktree: clp-new-source   # omit for the main checkout
  - repo: squidward
```

- `` `p `` opens the initiatives picker. Selecting one hydrates a session with a `notes`
  window (the workspace), one editor window per checkout, a `claude` window rooted in the
  workspace (with `--add-dir` to each checkout, so metadata stays out of the code repo),
  and a `shell`.
- Worktrees live at `<repo>/.worktrees/<slug>` and are managed with `gwt` (`gwta`/`gwts`/`gwtr`
  in zsh). This lets two initiatives work the same big repo (e.g. itaipu) without re-cloning.
- I create initiatives with the `start-initiative` Claude skill; past projects are untouched
  until I retrofit one by dropping in a manifest.
