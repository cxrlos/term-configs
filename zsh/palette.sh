# ANSI truecolor escapes — for printf-based status helpers below.
_love=$'\033[38;2;251;73;52m'
_gold=$'\033[38;2;250;189;47m'
_foam=$'\033[38;2;142;192;124m'
_pine=$'\033[38;2;184;187;38m'
_rose=$'\033[38;2;254;128;25m'
_iris=$'\033[38;2;211;134;155m'
_subtle=$'\033[38;2;168;153;132m'
_muted=$'\033[38;2;124;111;100m'
_bold=$'\033[1m'
_nc=$'\033[0m'

# Plain hex — for tools that take literal color strings (fzf --color, tmux
# color specs) rather than ANSI escapes.
_hex_base=#282828
_hex_surface=#3c3836
_hex_overlay=#504945
_hex_muted=#7c6f64
_hex_subtle=#a89984
_hex_text=#ebdbb2
_hex_love=#fb4934
_hex_gold=#fabd2f
_hex_rose=#fe8019
_hex_pine=#b8bb26
_hex_foam=#8ec07c
_hex_iris=#d3869b

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
