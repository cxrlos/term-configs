#!/usr/bin/env bash
# Visual checks only a human can confirm. Run inside Alacritty, then again inside tmux.

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=zsh/palette.sh
. "$REPO_DIR/zsh/palette.sh"

_section() { printf '\n%s%s── %s%s\n' "$_bold" "$_subtle" "$1" "$_nc"; }

_section "1. truecolor — one smooth gradient, no banding into blocks"
for i in $(seq 0 4 255); do
    printf '\033[48;2;%d;%d;%dm \033[0m' "$i" $((255 - i)) $((i / 2))
done
printf '\n'

_section "2. palette — each name in its own color"
printf '%slove%s %sgold%s %sfoam%s %spine%s %srose%s %siris%s %ssubtle%s %smuted%s\n' \
    "$_love" "$_nc" "$_gold" "$_nc" "$_foam" "$_nc" "$_pine" "$_nc" \
    "$_rose" "$_nc" "$_iris" "$_nc" "$_subtle" "$_nc" "$_muted" "$_nc"

_section "3. status helpers — glyph + colored prefix"
_ok "ok"
_info "info"
_warn "warn"
_err "err" 2>&1

_section "4. nerd font glyphs — every box below shows an icon, none are tofu (□) or ?"
printf '  [] branch   [] folder   [] git   [] rust   [] node   [] apple   [] arch   [󰥔] clock (tmux)   [󰌾] lock (starship)\n'
printf '  [✓] [✗] [→] [●] [│] [▶] [✘]\n'

_section "5. text styles"
printf '  \033[1mbold\033[0m  \033[3mitalic\033[0m  \033[4munderline\033[0m  \033[4:3mundercurl\033[0m  \033[9mstrike\033[0m  \033[2mdim\033[0m\n'

_section "6. alignment — the right edge of both rows lines up"
printf '  %s|\n' '0123456789'
printf '  %s|\n' '󰥔󰥔󰥔󰥔󰥔'

_section "7. terminal identity"
printf '  TERM=%s  COLORTERM=%s  TMUX=%s\n' "$TERM" "${COLORTERM:-unset}" "${TMUX:+yes}"
