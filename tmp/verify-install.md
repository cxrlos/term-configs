# Verify term-configs install on this machine

Run from the repo root on the new machine, after `bash scripts/install.sh` and `exec zsh`:

```bash
claude "$(cat tmp/verify-install.md)"
```

---

You are verifying that `term-configs` installed correctly on this machine. Read `AGENTS.md` first, especially **Machines** and **Sessionizer & cross-machine projects**. The repo is shared by a macOS laptop (arm64), an Arch desktop (`bastion`, x86_64) and this machine, probably the ThinkPad T14 (Arch, Intel Core Ultra 5, x86_64).

## Ground rules

- **Read-only.** Don't install, edit or delete anything. Each fix is a proposal in the report, and I decide.
- The one write you may offer, and only after asking me: filling this machine's host key into the Machines table in `AGENTS.md`.
- Never edit `sessionizer/projects.yaml`. Entries under other host keys are other machines' data, not stale.
- Never print the contents of `zsh/nubank.zsh` or `~/.nurc`.
- No `git commit` or `git push`.
- Your shell may load this repo's aliases: `cat` is bat, `grep` is rg (where `-E` means encoding) and `ls` is eza. Prefix those with `command`, as in `command grep -iE`.
- Derive expected values from the repo (`scripts/install.sh` arrays, `tmux/tmux.conf`, `alacritty/alacritty.toml`), never from this prompt, so the check stays correct as the repo changes.

## Checks

Run each group and record PASS / WARN / FAIL with the command output that proves it.

1. **Machine identity.** `uname -n`, `uname -m`, `lscpu | grep 'Model name'`, `lspci | grep -iE 'vga|3d|display'`, `ls /sys/class/power_supply/`, `echo $XDG_SESSION_TYPE $XDG_CURRENT_DESKTOP`. FAIL if the host key equals a key already in the Machines table (`bastion`, `carlos`). WARN if `hostname` isn't installed; that's expected on Arch.
2. **Packages.** Parse `PACMAN_DEPS` from `scripts/install.sh` and run `pacman -Qi` on each. FAIL for any missing.
3. **Links.** For each `LINKS` and `BINS` entry in `scripts/install.sh`, confirm `$HOME/<dst>` is a symlink resolving to `<repo>/<src>`. Confirm `~/.zsh/.local` sets `TERM_CONFIGS_DIR` to this repo and that `CLAUDE.md` (`@AGENTS.md`) exists at the repo root. WARN on dangling symlinks into this repo under `~` and `~/.config`.
4. **Shell.**
   - Login shell is zsh: `getent passwd "$USER" | cut -d: -f7`.
   - A clean start prints nothing: `script -qec 'zsh -i -c exit' /dev/null 2>&1 | command cat -v`. The only expected output is the cursor escape `^[[5 q`. FAIL on anything else, especially `setlocale`, `gh`, `command not found` or zinit errors. Run it under `script`, because without a TTY zsh prints spurious `can't change option: zle` lines.
   - Startup time: `for i in 1 2 3; do /usr/bin/time -f %e zsh -i -c exit; done`. WARN above 0.5s.
   - Locale: `locale 2>&1` with no errors and `en_US.utf8` in `locale -a`.
   - Functions load: `zsh -i -c 'whence -w tm u help gsb gnb gwta y bj'`.
   - zinit plugins were cloned: `ls ~/.local/share/zinit/plugins`.
5. **tmux.** Use a throwaway server so you don't touch my sessions:
   - `tmux -V`. `popup-border-lines` needs 3.3 or newer.
   - `tmux -L verify -f ~/.tmux.conf new-session -d -s v && tmux -L verify show-messages; tmux -L verify show -g prefix; tmux -L verify show -gv @clip_copy; tmux -L verify kill-server`. FAIL on config errors or a prefix other than backtick.
   - The resolved `@clip_copy` binary exists (`wl-copy` on Wayland).
   - `infocmp tmux-256color` succeeds.
   - Every `@plugin` in `tmux.conf` has a directory under `~/.tmux/plugins/`. WARN, not FAIL, if `cargo` is missing (tmux-thumbs builds on first use; known gap in AGENTS.md).
6. **Prompt and terminal configs.**
   - `starship print-config >/dev/null` and `STARSHIP_LOG=warn starship prompt >/dev/null` with no warnings.
   - Alacritty: `alacritty --version`, then `alacritty -vv -e true 2>&1 | grep -iE 'error|warn|font'`. It briefly opens a window; tell me before running it.
   - Font: `fc-list : family | grep -i 'Mononoki Nerd Font Mono'` and `fc-match 'Mononoki Nerd Font Mono'`. FAIL if fc-match falls back to another family.
   - The alacritty URL hint opener exists: `command -v xdg-open`.
7. **Sessionizer.** `yq --version` must say mikefarah. List this host's projects: `yq -r '.projects[] | select(.locations["'"$(uname -n)"'"]) | .id' sessionizer/projects.yaml`. An empty list on a new machine is a WARN: tell me to `cd` into each project and run `sessionizer-add`. Don't do it yourself.
8. **Git and auth.** `git config --global --get core.pager` is `delta`; `core.editor` is `nvim` and `command -v nvim` succeeds. `gh auth status` is informational only.
9. **Rendering (needs my eyes).** You can't see the terminal, so hand this part to me. Ask me to run `bash tmp/render-test.sh` in a plain Alacritty window, then again inside tmux, and to confirm each numbered section:
   1. The gradient is smooth, which means truecolor works.
   2. Each palette name shows in a distinct Gruvbox color.
   3. The status helpers show ✓ → ! ✗ with colored glyphs.
   4. Every Nerd Font box shows an icon, with no tofu.
   5. Bold, italic, underline, undercurl, strike and dim each look different.
   6. The two `|` markers line up.
   7. Inside tmux, `TERM=tmux-256color`.

   Then ask me to confirm these by hand:
   - **Prompt:** the directory and git branch sit on the left, the time is right-aligned on the same row, and the input goes on the next line.
   - **Vi mode:** the cursor is a bar in insert mode and a steady block after `Esc`.
   - **Window:** it's translucent with blur.
   - **Font size:** it's readable at this panel's scale (`hyprctl monitors | grep scale`). On a laptop, size is the compositor's job, not alacritty's (AGENTS.md).
   - **tmux status bar:** two lines, with the session name on the left and the branch and clock on the right.
   - **Pane border:** the active pane's border is foam green.
   - **Popups:** `` `? `` `` `f `` `` `g `` `` `t `` all open with rounded iris borders.
   - **Clipboard:** copy mode `` `Enter ``, select with `v`, yank with `y`, then `wl-paste` prints the selection.
   - **Navigation:** `C-h/j/k/l` moves between tmux panes and nvim splits.
   - **URL hint:** a Super+click on a URL in Alacritty opens the browser. It may conflict with Hyprland's Super+drag; report what happens.

## Report

End with:

1. A table with one row per check group: group, status, and one line of evidence.
2. Each FAIL and WARN with a proposed fix, tagged:
   - **machine**: only this machine needs it, for example a package, a locale or a hostname.
   - **repo**: the tracked config needs it. Say whether the fix is safe for the macOS laptop and `bastion` per the Machines rules, and which of them you couldn't verify.
3. The rendering items I confirmed or rejected.

Don't apply fixes. I'll pick which ones to do.
