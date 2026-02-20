# Terminal Configuration

Alacritty + Zsh + tmux + Starship, unified under Rose Pine with BerkeleyMono Nerd Font.

## Install

```bash
git clone https://github.com/cxrlos/term-configs.git
cd term-configs
bash scripts/install.sh
```

The installer handles brew dependencies, symlinks, font detection, git config, and macOS key repeat settings.

## Structure

```
alacritty/          terminal emulator (transparent, blur, Rose Pine)
zsh/
  .zshrc            orchestrator (zinit, splash screen, starship init)
  shell.zsh         history, options, plugins, completion, tool inits
  env.zsh           EDITOR, LANG, PATH, homebrew
  vim.zsh           vi mode, cursor shape, key bindings
  git.zsh           gnb, g hub, git aliases, Rose Pine log
  utils.zsh         a hub, u hub, eza/extract/path/ports/tree
  nubank.zsh        work-specific (git-ignored)
starship/           prompt (Rose Pine palette, fill line, time)
tmux/
  tmux.conf         prefix=`, vim-tmux-nav, popups, Rose Pine status
  cheatsheet.sh     floating keybinding reference (` /)
fastfetch/          system info config (Rose Pine themed)
scripts/
  install.sh        brew deps, symlinks, git config, macOS settings
  tmux-sessionizer  fzf project picker for tmux sessions
```

## Hub commands

Three single-letter entry points with gum-powered menus:

| Command | What                                                           |
| ------- | -------------------------------------------------------------- |
| `g`     | git: branch, commit, diff, log, status (with format variants)  |
| `a`     | aliases: fuzzy search all commands, interactive alias creation |
| `u`     | utils: extract, tldr, path, ports, tree, zoxide dirs           |

## tmux keybindings

Prefix: `` ` `` (backtick)

| Key           | Action                              |
| ------------- | ----------------------------------- |
| `C-h/j/k/l`   | seamless pane navigation (vim+tmux) |
| `M-Arrow`     | resize pane (Option+Arrow)          |
| `` ` v ``     | split vertical                      |
| `` ` s ``     | split horizontal                    |
| `` ` c ``     | new window                          |
| `` ` 1-9 ``   | jump to window                      |
| `` ` f ``     | sessionizer (project picker)        |
| `` ` g ``     | lazygit (floating)                  |
| `` ` t ``     | htop (floating)                     |
| `` ` / ``     | cheatsheet                          |
| `` ` Enter `` | copy mode (vi)                      |

## Tools

Installed via `brew` by the install script:

starship, fzf, gum, bat, ripgrep, eza, zoxide, git-delta, tldr, fastfetch, thefuck, tmux, lazygit

## Theme

Rose Pine (main) everywhere. Named palette in starship, true-color ANSI helpers in zsh, matching colors in alacritty, tmux, and git log.

## License

MIT
