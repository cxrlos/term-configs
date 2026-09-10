# ANSI truecolor escapes — for printf-based status helpers below.
_love=$'\033[38;2;235;111;146m'
_gold=$'\033[38;2;246;193;119m'
_foam=$'\033[38;2;156;207;216m'
_pine=$'\033[38;2;49;116;143m'
_rose=$'\033[38;2;235;188;186m'
_iris=$'\033[38;2;196;167;231m'
_subtle=$'\033[38;2;144;140;170m'
_muted=$'\033[38;2;110;106;134m'
_bold=$'\033[1m'
_nc=$'\033[0m'

# Plain hex — for tools that take literal color strings (fzf --color, tmux
# color specs) rather than ANSI escapes.
_hex_base=#191724
_hex_surface=#1f1d2e
_hex_overlay=#26233a
_hex_muted=#6e6a86
_hex_subtle=#908caa
_hex_text=#e0def4
_hex_love=#eb6f92
_hex_gold=#f6c177
_hex_rose=#ebbcba
_hex_pine=#31748f
_hex_foam=#9ccfd8
_hex_iris=#c4a7e7

# Shared fzf theme — reused by git.zsh, utils.zsh, and tmux/cheatsheet.sh so
# all fzf pickers agree on which token plays which role.
_fzf_colors="--color=fg:${_hex_subtle},fg+:${_hex_text},bg:${_hex_base},bg+:${_hex_overlay},\
hl:${_hex_iris},hl+:${_hex_foam},pointer:${_hex_foam},header:${_hex_iris},\
info:${_hex_muted},gutter:${_hex_base},border:${_hex_iris},prompt:${_hex_iris},separator:${_hex_muted}"

_err()  { printf '%s✗%s %s\n' "$_love"  "$_nc" "$*" >&2; }
_warn() { printf '%s!%s %s\n' "$_gold"  "$_nc" "$*" >&2; }
_info() { printf '%s→%s %s\n' "$_foam"  "$_nc" "$*"; }
_ok()   { printf '%s✓%s %s\n' "$_pine"  "$_nc" "$*"; }
_dim()  { printf '%s%s%s'     "$_subtle" "$*"  "$_nc"; }
