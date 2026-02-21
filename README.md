# Terminal Configuration

Alacritty + Zsh + tmux + Starship, unified under Rose Pine with BerkeleyMono Nerd Font.

Targets **macOS** and **Arch Linux**.

## Install

```bash
git clone https://github.com/cxrlos/term-configs.git
cd term-configs
bash scripts/install.sh
```

The installer detects the OS, installs dependencies (brew on macOS, pacman + yay on Arch), checks for BerkeleyMono Nerd Font, symlinks or copies all configs, bootstraps zinit and TPM, and sets git globals.

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
starship/           prompt (Rose Pine palette, fill line, time)
tmux/
  tmux.conf         prefix=`, vim-tmux-nav, popups, Rose Pine status
  cheatsheet.sh     floating keybinding reference (` /)
fastfetch/          system info config (Rose Pine themed)
scripts/
  install.sh        deps, symlinks, git config, macOS settings
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

| Key               | Action                                        |
| ----------------- | --------------------------------------------- |
| `C-h/j/k/l`       | seamless pane navigation (vim+tmux, no prefix)|
| `` ` h/j/k/l ``   | select pane (repeatable)                      |
| `` ` Arrow ``     | resize pane (repeatable)                      |
| `` ` v ``         | split right                                   |
| `` ` s ``         | split down                                    |
| `` ` c ``         | new window (inherits cwd)                     |
| `` ` 1-9 ``       | jump to window                                |
| `` ` n/p ``       | next / prev window (repeatable)               |
| `` ` < / > ``     | move window left / right                      |
| `` ` ^ ``         | last window (toggle)                          |
| `` ` z ``         | zoom pane                                     |
| `` ` x / X ``     | kill pane / window                            |
| `` ` / ``         | cheatsheet (fzf, VISUAL/INSERT modal)         |
| `` ` f ``         | sessionizer (project picker)                  |
| `` ` g ``         | lazygit                                       |
| `` ` t ``         | htop                                          |
| `` ` T ``         | scratch terminal (persistent)                 |
| `` ` w ``         | fzf session/window/pane picker                |
| `` ` b ``         | popup shell in current directory              |
| `` ` Enter ``     | copy mode (vi)                                |
| `` ` Space ``     | thumbs — hint-based yank (URLs, paths, hashes)|

## Tools

**macOS** — installed via `brew`:

starship, fzf, gum, bat, ripgrep, eza, zoxide, git-delta, tldr, fastfetch, thefuck, tmux, lazygit

**Arch Linux** — via `pacman` + AUR (`yay`):

pacman: starship, fzf, bat, ripgrep, eza, zoxide, tldr, fastfetch, tmux
AUR: gum, git-delta, thefuck, lazygit

## Theme

Rose Pine (main) everywhere. Named palette in starship, true-color ANSI helpers in zsh, matching colors in alacritty, tmux, and git log.

## TODO

- [ ] `` ` e `` — open last command output in nvim (read-only, relative numbers). Capture scrollback delta via `preexec` hook + `tmux capture-pane`, display in a popup. Blocked on reliable pane-id passing into `display-popup`.

## License

MIT
