#!/usr/bin/env bash
set -euo pipefail

# ── Colors & helpers ──────────────────────────────────────────────────────────

RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
BOLD=$'\033[1m'
DIM=$'\033[2m'
NC=$'\033[0m'

warn() { printf "%s\n" "${YELLOW}!${NC} $*"; }
err() { printf "%s\n" "${RED}✗${NC} $*"; }
die() {
    err "$@"
    exit 1
}

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TIMESTAMP="$(date +%Y%m%d%H%M%S)"

# ── OS detection ──────────────────────────────────────────────────────────────

OS="unknown"
[[ "$(uname)" == "Darwin" ]] && OS="macos"
[[ -f /etc/arch-release ]] && OS="arch"
[[ "$OS" == "unknown" ]] && die "Unsupported OS — targets macOS and Arch Linux."

printf "\n%s\n" "${BOLD}Terminal config installer  [${OS}]${NC}"

# ── Reinstall detection ──────────────────────────────────────────────────────

INSTALL_MODE="fresh"

if [[ -f "$HOME/.zsh/.local" ]]; then
    printf "\n  Existing installation detected.\n\n"
    printf "  [1] Update     — install missing pieces, skip what's correct %s(default)%s\n" "$DIM" "$NC"
    printf "  [2] Reinstall  — remove all configs and start fresh\n\n"
    read -r -p "  Choice [1/2]: " choice
    case "${choice:-1}" in
        1) INSTALL_MODE="update" ;;
        2) INSTALL_MODE="reinstall" ;;
        *) die "Invalid choice" ;;
    esac
fi

printf "\n"

# ── Counters ──────────────────────────────────────────────────────────────────

deps_installed=0 deps_ok=0 deps_failed=0
links_new=0 links_ok=0 links_backed=0
extras_done=0 extras_ok=0

# ── Package managers ──────────────────────────────────────────────────────────

_ensure_brew() {
    if ! command -v brew &>/dev/null; then
        warn "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
}

_ensure_yay() {
    command -v yay &>/dev/null && return 0
    warn "yay (AUR helper) not found"
    read -r -p "  Install yay? Required for AUR packages. [y/N] " yn
    [[ "$yn" =~ ^[yY]$ ]] || return 1
    sudo pacman -S --needed --noconfirm git base-devel
    local tmp
    tmp=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$tmp/yay"
    (cd "$tmp/yay" && makepkg -si)
    rm -rf "$tmp"
}

# ── Dependencies ──────────────────────────────────────────────────────────────

BREW_DEPS=(starship fzf gum bat ripgrep eza zoxide git-delta tldr thefuck tmux lazygit git-absorb atuin direnv yq fd hyperfine yazi)
BREW_CASKS=(font-profont-nerd-font)
PACMAN_DEPS=(starship fzf bat ripgrep eza zoxide tldr tmux ttf-profont-nerd go-yq fd hyperfine yazi)
AUR_DEPS=(gum git-delta thefuck lazygit)

_install_deps() {
    case "$OS" in
        macos)
            _ensure_brew
            for dep in "${BREW_DEPS[@]}"; do
                if brew list "$dep" &>/dev/null; then
                    ((++deps_ok))
                else
                    # shellcheck disable=SC2015
                    brew install "$dep" &>/dev/null && ((++deps_installed)) || {
                        warn "Failed: $dep"
                        ((++deps_failed))
                    }
                fi
            done
            for cask in "${BREW_CASKS[@]}"; do
                if brew list --cask "$cask" &>/dev/null; then
                    ((++deps_ok))
                else
                    # shellcheck disable=SC2015
                    brew install --cask "$cask" &>/dev/null && ((++deps_installed)) || {
                        warn "Failed: $cask"
                        ((++deps_failed))
                    }
                fi
            done
            ;;
        arch)
            sudo pacman -Sy --noconfirm &>/dev/null
            for dep in "${PACMAN_DEPS[@]}"; do
                if pacman -Qi "$dep" &>/dev/null; then
                    ((++deps_ok))
                else
                    # shellcheck disable=SC2015
                    sudo pacman -S --noconfirm "$dep" &>/dev/null && ((++deps_installed)) || {
                        warn "Failed: $dep"
                        ((++deps_failed))
                    }
                fi
            done
            if _ensure_yay; then
                for dep in "${AUR_DEPS[@]}"; do
                    if yay -Qi "$dep" &>/dev/null; then
                        ((++deps_ok))
                    else
                        # shellcheck disable=SC2015
                        yay -S --noconfirm "$dep" &>/dev/null && ((++deps_installed)) || {
                            warn "Failed: $dep"
                            ((++deps_failed))
                        }
                    fi
                done
            else
                warn "Skipped AUR: ${AUR_DEPS[*]}"
            fi
            ;;
    esac
}

_install_deps

# ── Link map ──────────────────────────────────────────────────────────────────

LINKS=(
    "zsh/.zshrc          : .zshrc"
    "zsh                 : .zsh"
    "starship/starship.toml : .config/starship.toml"
    "alacritty           : .config/alacritty"
    "tmux/tmux.conf      : .tmux.conf"
    "tmux/cheatsheet.sh  : .tmux-cheatsheet.sh"
)
BINS=(
    "scripts/tmux-sessionizer : .local/bin/tmux-sessionizer"
    "scripts/tmux-sessions    : .local/bin/tmux-sessions"
    "scripts/sessionizer-add  : .local/bin/sessionizer-add"
    "scripts/lidrun.sh        : .local/bin/lidrun"
)

_backup() {
    local target="$1"
    [[ -e "$target" || -L "$target" ]] || return 0
    local backup="${target}.bak.${TIMESTAMP}"
    mv "$target" "$backup"
    ((++links_backed))
}

_remove() {
    local target="$1"
    [[ -e "$target" || -L "$target" ]] || return 0
    rm -rf "$target"
}

_is_correct_link() {
    local src="$1" dst="$2"
    [[ -L "$dst" ]] && [[ "$(readlink "$dst")" == "$src" ]]
}

_clean_all_links() {
    for entry in "${LINKS[@]}" "${BINS[@]}"; do
        local rel_dst="${entry##*:}"
        rel_dst="${rel_dst// /}"
        _remove "$HOME/$rel_dst"
    done
    _remove "$HOME/.zsh/.local"
}

_apply_map() {
    local is_bin=$1
    shift

    for entry in "$@"; do
        local rel_src="${entry%%:*}"
        local rel_dst="${entry##*:}"
        rel_src="${rel_src// /}"
        rel_dst="${rel_dst// /}"

        local src="$REPO_DIR/$rel_src"
        local dst="$HOME/$rel_dst"

        [[ -e "$src" ]] || {
            warn "Source missing: $rel_src"
            continue
        }

        if [[ "$INSTALL_MODE" != "reinstall" ]] && _is_correct_link "$src" "$dst"; then
            ((++links_ok))
            continue
        fi

        [[ "$INSTALL_MODE" == "reinstall" ]] || _backup "$dst"
        mkdir -p "$(dirname "$dst")"
        ln -sf "$src" "$dst"
        $is_bin && chmod +x "$dst"
        ((++links_new))
    done
}

[[ "$INSTALL_MODE" == "reinstall" ]] && _clean_all_links

_apply_map false "${LINKS[@]}"
_apply_map true "${BINS[@]}"

chmod +x "$HOME/.tmux-cheatsheet.sh" 2>/dev/null || true

# ── Local config ──────────────────────────────────────────────────────────────

cat >"$HOME/.zsh/.local" <<EOF
TERM_CONFIGS_DIR="$REPO_DIR"
EOF

# ── Sessionizer ──────────────────────────────────────────────────────────────

mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}/sessionizer"
((++extras_ok))

# ── zinit ─────────────────────────────────────────────────────────────────────

ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [[ ! -d "$ZINIT_HOME" ]]; then
    mkdir -p "$(dirname "$ZINIT_HOME")"
    git clone --quiet https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
    ((++extras_done))
else
    ((++extras_ok))
fi

# ── TPM ───────────────────────────────────────────────────────────────────────

TPM_DIR="$HOME/.tmux/plugins/tpm"
if [[ ! -d "$TPM_DIR" ]]; then
    git clone --quiet https://github.com/tmux-plugins/tpm "$TPM_DIR"
    ((++extras_done))
else
    ((++extras_ok))
fi
"$TPM_DIR/bin/install_plugins" >/dev/null 2>&1 || true

# ── Git config ────────────────────────────────────────────────────────────────

git_configs=(
    "push.autoSetupRemote  true"
    "push.default          current"
    "pull.rebase           true"
    "fetch.prune           true"
    "fetch.all             true"
    "fetch.pruneTags       true"
    "rerere.enabled        true"
    "init.defaultBranch    main"
    "core.editor           nvim"
    "diff.colorMoved       default"
    "diff.algorithm        histogram"
    "diff.mnemonicPrefix   true"
    "diff.renames          true"
    "merge.conflictstyle   zdiff3"
    "rebase.autoStash      true"
    "rebase.autoSquash     true"
    "rebase.updateRefs     true"
    "commit.verbose        true"
    "help.autocorrect      prompt"
    "push.followTags       true"
    "tag.sort              version:refname"
    "column.ui             auto"
    "branch.sort           -committerdate"
)

for cfg in "${git_configs[@]}"; do
    read -r key val <<<"$cfg"
    git config --global "$key" "$val"
done
((++extras_done))

if command -v delta &>/dev/null; then
    git config --global core.pager delta
    git config --global interactive.diffFilter 'delta --color-only'
    git config --global delta.navigate true
    git config --global delta.line-numbers true
fi

# ── macOS key repeat ──────────────────────────────────────────────────────────

if [[ "$OS" == "macos" ]]; then
    defaults write -g ApplePressAndHoldEnabled -bool false
    defaults write -g InitialKeyRepeat -int 15
    defaults write -g KeyRepeat -int 2
    ((++extras_done))
fi

# ── Summary ───────────────────────────────────────────────────────────────────

printf "\n"
printf "  deps:   %s installed, %s ok" "$deps_installed" "$deps_ok"
((deps_failed > 0)) && printf ", ${RED}%s failed${NC}" "$deps_failed"
printf "\n"
printf "  links:  %s new, %s ok" "$links_new" "$links_ok"
((links_backed > 0)) && printf ", %s backed up" "$links_backed"
printf "\n"
printf "  extras: %s configured, %s ok\n" "$extras_done" "$extras_ok"
# shellcheck disable=SC2059
printf "\n  ${GREEN}done${NC} — run ${BOLD}exec zsh${NC}\n\n"
