bindkey -v
export KEYTIMEOUT=1

# Cursor shape per vi mode: steady block in command/visual (always visible — a
# blinking cursor is what gets lost mid-selection), thin bar in insert.
#   \e[2 q = steady block   \e[5 q = blinking bar
zle-keymap-select() {
    case "${KEYMAP:-viins}" in
        vicmd|visual) echo -ne '\e[2 q' ;;
        *)            echo -ne '\e[5 q' ;;
    esac
}
zle -N zle-keymap-select
zle-line-init() { echo -ne '\e[5 q'; }
zle -N zle-line-init
echo -ne '\e[5 q'

# Light tint on the visual selection so the region (and the block cursor) read
# clearly. Other contexts keep their defaults.
zle_highlight=('region:bg=#45475a' 'special:standout' 'suffix:bold' 'isearch:underline' 'paste:standout')

bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search
bindkey -M vicmd 'k' up-line-or-beginning-search
bindkey -M vicmd 'j' down-line-or-beginning-search
