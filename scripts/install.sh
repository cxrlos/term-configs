#!/usr/bin/env bash
set -euo pipefail

RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
BLUE=$'\033[0;34m'
BOLD=$'\033[1m'
DIM=$'\033[2m'
NC=$'\033[0m'

info() { printf "%s\n" "${BLUE}→${NC} $*"; }
success() { printf "%s\n" "${GREEN}✓${NC} $*"; }
warn() { printf "%s\n" "${YELLOW}!${NC} $*"; }
die() {
    printf "%s\n" "${RED}✗${NC} $*"
    exit 1
}

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TIMESTAMP="$(date +%Y%m%d%H%M%S)"

[[ "$(uname)" == "Darwin" ]] || die "This script targets macOS."

printf "\n%s\n\n" "${BOLD}Terminal config installer${NC}"

# ── Homebrew ──────────────────────────────────────────────────────────────────

if ! command -v brew &>/dev/null; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    success "Homebrew $(brew --version | head -1)"
fi

# ── Dependencies ──────────────────────────────────────────────────────────────

BREW_DEPS=(starship fzf gum bat ripgrep eza zoxide git-delta tldr fastfetch thefuck tmux lazygit)
for dep in "${BREW_DEPS[@]}"; do
    if brew list "$dep" &>/dev/null; then
        success "$dep"
    else
        info "Installing $dep..."
        brew install "$dep"
    fi
done

# ── Font ──────────────────────────────────────────────────────────────────────

FONT_DIR="$HOME/Library/Fonts"
if ls "$FONT_DIR"/HackNerdFont* &>/dev/null 2>&1; then
    success "Hack Nerd Font"
else
    info "Installing Hack Nerd Font..."
    brew install --cask font-hack-nerd-font
    success "Hack Nerd Font installed"
fi

# ── Backup helper ─────────────────────────────────────────────────────────────

backup_if_exists() {
    local target="$1"
    [[ -e "$target" || -L "$target" ]] || return 0

    local backup="${target}.bak.${TIMESTAMP}"
    mv "$target" "$backup"
    info "Backed up $(basename "$target") → $(basename "$backup")"
}

# ── Existing configs ──────────────────────────────────────────────────────────

TARGETS=("$HOME/.zshrc" "$HOME/.zsh" "$HOME/.config/starship.toml" "$HOME/.config/alacritty" "$HOME/.config/fastfetch" "$HOME/.tmux.conf")
HAS_EXISTING=false
for t in "${TARGETS[@]}"; do
    [[ -e "$t" || -L "$t" ]] && HAS_EXISTING=true && break
done

if $HAS_EXISTING; then
    warn "Existing config(s) found"
    read -r -p "  Replace them? Originals will be backed up. [y/N] " response
    [[ "$response" =~ ^[yY]$ ]] || {
        echo "Aborted."
        exit 0
    }

    for t in "${TARGETS[@]}"; do
        backup_if_exists "$t"
    done
fi

# ── Install mode ──────────────────────────────────────────────────────────────

printf "\n%s\n" "${BOLD}Install method:${NC}"
printf "  [1] Symlink — repo changes are instantly live ${DIM}(recommended)${NC}\n"
printf "  [2] Copy    — standalone, no dependency on repo path\n\n"
read -r -p "Choice [1/2]: " install_mode

# ── Apply ─────────────────────────────────────────────────────────────────────

link_or_copy() {
    local src="$1" dst="$2"
    mkdir -p "$(dirname "$dst")"
    if [[ "${install_mode:-1}" == "2" ]]; then
        cp -r "$src" "$dst"
    else
        ln -sf "$src" "$dst"
    fi
}

link_or_copy "$REPO_DIR/zsh" "$HOME/.zsh"
link_or_copy "$REPO_DIR/zsh/.zshrc" "$HOME/.zshrc"
link_or_copy "$REPO_DIR/starship/starship.toml" "$HOME/.config/starship.toml"
link_or_copy "$REPO_DIR/alacritty" "$HOME/.config/alacritty"
link_or_copy "$REPO_DIR/fastfetch" "$HOME/.config/fastfetch"
link_or_copy "$REPO_DIR/tmux/tmux.conf" "$HOME/.tmux.conf"
link_or_copy "$REPO_DIR/tmux/cheatsheet.sh" "$HOME/.tmux-cheatsheet.sh"
mkdir -p "$HOME/.local/bin"
link_or_copy "$REPO_DIR/scripts/tmux-sessionizer" "$HOME/.local/bin/tmux-sessionizer"

if [[ "${install_mode:-1}" == "2" ]]; then
    success "Configs copied"
else
    success "Symlinked: ~/.zshrc → zsh/.zshrc"
    success "Symlinked: ~/.zsh/ → zsh/"
    success "Symlinked: ~/.config/starship.toml → starship/starship.toml"
    success "Symlinked: ~/.config/alacritty/ → alacritty/"
    success "Symlinked: ~/.config/fastfetch/ → fastfetch/"
    success "Symlinked: ~/.tmux.conf → tmux/tmux.conf"
fi

# ── Local config ─────────────────────────────────────────────────────────────

if [[ "${install_mode:-1}" == "2" ]]; then
    _mode="copy"
else
    _mode="symlink"
fi

cat >"$HOME/.zsh/.local" <<EOF
TERM_CONFIGS_DIR="$REPO_DIR"
TERM_CONFIGS_MODE="$_mode"
EOF
success "Wrote ~/.zsh/.local (repo: $REPO_DIR, mode: $_mode)"

# ── zinit bootstrap ──────────────────────────────────────────────────────────

ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [[ ! -d "$ZINIT_HOME" ]]; then
    info "Installing zinit..."
    mkdir -p "$(dirname "$ZINIT_HOME")"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
    success "zinit ready"
else
    success "zinit"
fi

# ── macOS key repeat ─────────────────────────────────────────────────────────

defaults write -g ApplePressAndHoldEnabled -bool false
defaults write -g InitialKeyRepeat -int 15
defaults write -g KeyRepeat -int 2
success "Key repeat configured (logout required to take effect)"

# ── Git config ───────────────────────────────────────────────────────────────

git config --global push.autoSetupRemote true
git config --global push.default current
git config --global pull.rebase true
git config --global fetch.prune true
git config --global rerere.enabled true
git config --global init.defaultBranch main
git config --global core.editor nvim
git config --global diff.colorMoved default
git config --global merge.conflictstyle diff3
git config --global rebase.autoStash true
git config --global column.ui auto
git config --global branch.sort -committerdate
success "git defaults configured"

if command -v delta &>/dev/null; then
    git config --global core.pager delta
    git config --global interactive.diffFilter 'delta --color-only'
    git config --global delta.navigate true
    git config --global delta.side-by-side true
    git config --global delta.line-numbers true
    success "delta configured as git pager"
fi

# ── TPM (tmux plugin manager) ────────────────────────────────────────────────

TPM_DIR="$HOME/.tmux/plugins/tpm"
if [[ ! -d "$TPM_DIR" ]]; then
    info "Installing TPM..."
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
    success "TPM ready"
else
    success "TPM"
fi

info "Installing tmux plugins..."
"$TPM_DIR/bin/install_plugins" >/dev/null 2>&1 || true
success "tmux plugins installed"

# ── Done ──────────────────────────────────────────────────────────────────────

printf "\n%s\n" "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
printf "  %s\n\n" "${GREEN}Installation complete!${NC}"
printf "  Restart your shell or run:\n"
printf "    %s\n\n" "${BOLD}exec zsh${NC}"
printf "  Plugins will auto-install on first launch via zinit.\n"
printf "%s\n" "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

printf "\n%s  (all should be visible — no blank boxes)\n" "${BOLD}Character check:${NC}"
printf "  Diagnostics   ✘  ▲  ◆  ●\n"
printf "  UI            ▶  ◀  ▸  …  ●\n"
printf "  Box drawing   ─  │  ╭  ╮  ╯  ╰\n"
printf "  Powerline     \ue0b0  \ue0b1  \ue0b2  \ue0b3   %s\n\n" "${DIM}(requires Nerd Font — blank = font missing)${NC}"
