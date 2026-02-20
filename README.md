# My Terminal Configuration

My personal terminal setup: Alacritty + Zsh + Starship prompt, unified under the Rose Pine
theme with Hack Nerd Font Mono.

## What's inside

- **Alacritty** — GPU-accelerated terminal with Rose Pine colors, transparency, smooth scrolling
- **Zsh** — modular config with aliases, functions, plugins, vim mode
- **Starship** — fast cross-shell prompt with git status, python venv, command duration

## Structure

```
alacritty/          alacritty.toml → ~/.config/alacritty/alacritty.toml
zsh/                .zshrc + modular *.zsh files → ~/
starship/           starship.toml → ~/.config/starship.toml
scripts/            install.sh, format, check
```

## Install

```bash
./scripts/install.sh
```

## Prerequisites

- macOS with Homebrew
- [Hack Nerd Font Mono](https://www.nerdfonts.com/)

## License

MIT
