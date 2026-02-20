bindkey -v
export KEYTIMEOUT=1

zle-keymap-select() {
    case "${KEYMAP:-viins}" in
        vicmd) echo -ne '\e[1 q' ;;
        *)     echo -ne '\e[5 q' ;;
    esac
}
zle -N zle-keymap-select

echo -ne '\e[5 q'

bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search
bindkey -M vicmd 'k' up-line-or-beginning-search
bindkey -M vicmd 'j' down-line-or-beginning-search
