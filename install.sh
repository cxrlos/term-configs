#!/usr/bin/env bash
# Install term-configs on Fedora or macOS: packages, font, symlinks; then list what's left for
# you. Idempotent; prints only what it changed. Must stay bash 3.2 compatible (macOS /bin/bash):
# no associative arrays, no mapfile, no empty-array expansion under set -u.
#   ./install.sh          install / repair
#   ./install.sh --check  report only; exits 1 if anything is missing or wrong
set -euo pipefail
cd "$(dirname "$0")"
repo=$PWD
check=; [ "${1-}" = --check ] && check=1
problems=0
note() { printf '  %s\n' "$*"; }
todo() { note "$*"; problems=$((problems + 1)); }
section() { printf '── %s ──\n' "$1"; }

case $OSTYPE in
    darwin*) os=mac ;;
    linux*) [ -f /etc/fedora-release ] && os=fedora || { echo "Fedora or macOS only" >&2; exit 1; } ;;
    *) echo "Fedora or macOS only" >&2; exit 1 ;;
esac

# ── Packages: Fedora list here, macOS in Brewfile (keep both in sync) ─────────────
DNF_PKGS="zsh git alacritty neovim tmux fzf ripgrep fd-find zoxide atuin direnv oh-my-posh
  git-delta git-absorb gitleaks gh just jq zsh-autosuggestions zsh-syntax-highlighting wl-clipboard
  curl fontconfig unzip tree-sitter-cli gcc nodejs22-npm ruff nodejs-bash-language-server ShellCheck"
section packages
if [ $os = fedora ]; then
    missing=
    for p in $DNF_PKGS; do rpm -q "$p" >/dev/null 2>&1 || missing="$missing $p"; done
    if [ -z "$missing" ]; then note "dnf: all present"
    elif [ -n "$check" ]; then todo "dnf missing:$missing"
    else sudo dnf install -y $missing; fi
elif ! command -v brew >/dev/null; then
    todo "Homebrew missing: install it from https://brew.sh, then re-run"
elif brew bundle check --file=Brewfile --no-upgrade >/dev/null 2>&1; then note "brew: all present"
elif [ -n "$check" ]; then todo "brew: missing packages (brew bundle check --file=Brewfile --verbose)"
else brew bundle install --file=Brewfile --no-upgrade; fi

# ── Font (macOS: Brewfile cask). Pinned and hash-checked; to upgrade, change both lines ──
NF_VERSION=v3.5.1
NF_SHA256=7ee1e16909f0fd05cee30db4299753c33a6134c418c828d6d8523d246ee3f836
NF_FILES="CommitMonoNerdFontMono-Regular.otf CommitMonoNerdFontMono-Bold.otf
  CommitMonoNerdFontMono-Italic.otf CommitMonoNerdFontMono-BoldItalic.otf"
if [ $os = fedora ]; then
    section font
    font_dir=${XDG_DATA_HOME:-$HOME/.local/share}/fonts/CommitMonoNerdFont
    have=1; for f in $NF_FILES; do [ -f "$font_dir/$f" ] || have=; done
    if [ -n "$have" ]; then note "CommitMono Nerd Font $NF_VERSION ok"
    elif [ -n "$check" ]; then todo "CommitMono Nerd Font missing"
    else
        tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
        curl -fsSL -o "$tmp/f.tar.xz" \
            "https://github.com/ryanoasis/nerd-fonts/releases/download/$NF_VERSION/CommitMono.tar.xz"
        echo "$NF_SHA256  $tmp/f.tar.xz" | sha256sum -c --quiet - ||
            { echo "font download doesn't match the pinned SHA-256; not installing" >&2; exit 1; }
        mkdir -p "$font_dir"
        tar -xJf "$tmp/f.tar.xz" -C "$font_dir" $NF_FILES
        fc-cache -f "$font_dir"
        note "CommitMono Nerd Font $NF_VERSION installed"
    fi
fi

# ── Language servers for nvim (macOS: Brewfile). Pinned; to upgrade, change version + hash ──
# npm packages land in ~/.local (commands in ~/.local/bin); --ignore-scripts: nothing runs on install.
# typescript stays on 6.x: 7 has no tsserver, which ts_ls drives.
NPM_PKGS="typescript-language-server@6.0.2 typescript@6.0.3 basedpyright@1.40.2
  vscode-langservers-extracted@4.10.0 yaml-language-server@1.25.0"
# Release binaries: name version sha256 url path-in-archive (- = the file itself).
# GitHub: the release's sha256 digest. HashiCorp: SHA256SUMS, GPG-verified against their key.
BINS="lua-language-server 3.19.2 93ad326b10f6c00911dd8c450fa098332dbd8f9f45d1052f5636a2d54479b947 https://github.com/LuaLS/lua-language-server/releases/download/3.19.2/lua-language-server-3.19.2-linux-x64.tar.gz bin/lua-language-server
marksman 2026-02-08 be5098e8213219269c47fc0d916a66fa31ce0602ec967475c722260aabf26087 https://github.com/artempyanykh/marksman/releases/download/2026-02-08/marksman-linux-x64 -
terraform 1.16.6 38034b38d03096399a7a1264a14561a8029b2b496fd1f169452656e53968f1b7 https://releases.hashicorp.com/terraform/1.16.6/terraform_1.16.6_linux_amd64.zip terraform
terraform-ls 0.39.0 7750edc736845fd8c04ff0fc6332423c12d8275b358668c8c17e8aedc43ef971 https://releases.hashicorp.com/terraform-ls/0.39.0/terraform-ls_0.39.0_linux_amd64.zip terraform-ls"
if [ $os = fedora ]; then
    section "language servers"
    missing=
    for p in $NPM_PKGS; do
        v=$(jq -r .version "$HOME/.local/lib/node_modules/${p%@*}/package.json" 2>/dev/null || true)
        [ "$v" = "${p##*@}" ] || missing="$missing $p"
    done
    npm=$(command -v npm || command -v npm-22 || true)
    if [ -z "$missing" ]; then note "npm: pinned versions present"
    elif [ -n "$check" ]; then todo "npm missing or wrong version:$missing"
    elif [ -z "$npm" ]; then todo "npm not installed (nodejs22-npm); re-run after the dnf step"
    else
        "$npm" install --global --prefix "$HOME/.local" --ignore-scripts --no-fund --no-audit $missing >/dev/null
        note "npm installed:$missing"
    fi
    while read -r name ver sha url path; do
        dir=$HOME/.local/opt/$name-$ver link=$HOME/.local/bin/$name
        if [ "$path" = - ]; then target=$dir/$name; else target=$dir/$path; fi
        if [ "$(readlink "$link" 2>/dev/null)" = "$target" ] && [ -x "$target" ]; then note "$name $ver ok"; continue; fi
        if [ -n "$check" ]; then todo "$name $ver missing"; continue; fi
        tmp=$(mktemp -d) && file=$tmp/${url##*/}
        curl -fsSL -o "$file" "$url"
        echo "$sha  $file" | sha256sum -c --quiet - ||
            { echo "$name download doesn't match the pinned SHA-256; not installing" >&2; exit 1; }
        rm -rf "$dir" && mkdir -p "$dir" "$HOME/.local/bin"
        case $file in
            *.tar.gz) tar -xzf "$file" -C "$dir" ;;
            *.zip) unzip -q "$file" -d "$dir" ;;
            *) install -m 755 "$file" "$dir/$name" ;;
        esac
        rm -rf "$tmp"
        ln -sfn "$target" "$link"
        note "$name $ver installed"
    done <<EOF
$BINS
EOF
fi

# ── Links: "repo path:home path". Real files in the way are backed up, never deleted ──
LINKS="zsh/.zshenv:.zshenv zsh/.zprofile:.zprofile zsh/.zshrc:.zshrc
  git/config:.config/git/config git/hooks:.config/git/hooks ssh/config:.ssh/config tmux/tmux.conf:.config/tmux/tmux.conf
  oh-my-posh/prompt.toml:.config/oh-my-posh/prompt.toml atuin/config.toml:.config/atuin/config.toml
  direnv/direnv.toml:.config/direnv/direnv.toml scripts/tmux-sessionizer:.local/bin/tmux-sessionizer
  scripts/wt:.local/bin/wt scripts/agent-run:.local/bin/agent-run"
if [ $os = fedora ]; then LINKS="$LINKS alacritty:.config/alacritty"; else LINKS="$LINKS ghostty/config:.config/ghostty/config"; fi
section links
backup=${XDG_STATE_HOME:-$HOME/.local/state}/term-configs/backup-$(date +%Y%m%d-%H%M%S)
ok=0 backed=
for l in $LINKS; do
    src=$repo/${l%%:*} rel=${l#*:} dst=$HOME/${l#*:}
    if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then ok=$((ok + 1)); continue; fi
    if [ -n "$check" ]; then
        if [ -L "$dst" ]; then todo "~/$rel points at $(readlink "$dst")"
        elif [ -e "$dst" ]; then todo "~/$rel is a real file (would be backed up)"
        else todo "~/$rel missing"; fi
        continue
    fi
    if [ -L "$dst" ]; then note "~/$rel relinked (was → $(readlink "$dst"))"; rm "$dst"
    elif [ -e "$dst" ]; then
        mkdir -p "$backup/$(dirname "$rel")"; mv "$dst" "$backup/$rel"; backed=1
        note "~/$rel was a real file: backed up"
    else note "~/$rel linked"; fi
    mkdir -p "$(dirname "$dst")"
    ln -s "$src" "$dst"
done
[ $ok -gt 0 ] && note "$ok links ok"
[ -n "$backed" ] && note "Backups: $backup"
chmod 700 "$HOME/.ssh" 2>/dev/null || true

# ── You: machine-local things the script never writes ───────────────────────────────
section you
local_git=$HOME/.config/git/config.local
if git config -f "$local_git" user.name >/dev/null 2>&1 && git config -f "$local_git" user.email >/dev/null 2>&1 &&
    git config -f "$local_git" user.signingkey >/dev/null 2>&1; then
    note "git identity ok ($(git config -f "$local_git" user.email))"
else
    todo "git identity missing (commits fail: commit.gpgsign is on). Run:"
    note "  f=~/.config/git/config.local"
    note "  git config -f \$f user.name \"…\""
    note "  git config -f \$f user.email \"…\"        # work email on the Mac"
    note "  git config -f \$f user.signingkey ~/.ssh/id_ed25519_signing.pub"
fi
case $(basename "${SHELL-}") in
    zsh) ;;
    *) todo "login shell is ${SHELL-unset}; run: chsh -s \"\$(command -v zsh)\"" ;;
esac
rust-analyzer --version >/dev/null 2>&1 || note "Rust: rustup component add rust-analyzer (LSP for nvim)"
[ -f "$HOME/.zshrc.local" ] || note "optional: ~/.zshrc.local (TS_ROOTS, work-only env)"
[ -f "$HOME/.ssh/config.local" ] || note "optional: ~/.ssh/config.local (machine-only hosts)"

if [ -n "$check" ] && [ $problems -gt 0 ]; then exit 1; fi
[ $problems -gt 0 ] && echo "Done, with $problems item(s) for you above." || echo "Done."
