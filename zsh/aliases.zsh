alias vi='nvim'
alias vim='nvim'
alias edit='nvim'

alias python='python3'
alias pip='pip3'
alias py='python3'
alias venv='python3 -m venv .venv && source .venv/bin/activate'

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

if command -v eza &>/dev/null; then
    alias ls='eza --icons'
    alias ll='eza -la --icons --git --header'
    alias la='eza -a --icons'
    alias l='eza --icons'
    alias lt='eza --tree --icons --level=2 --git-ignore'
elif [[ "$OSTYPE" == "darwin"* ]]; then
    alias ls='ls -G'
    alias ll='ls -laG'
    alias la='ls -AG'
    alias l='ls -CFG'
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    alias ls='ls --color=auto'
    alias ll='ls -la --color=auto'
    alias la='ls -A --color=auto'
    alias l='ls -CF --color=auto'
fi

if [[ "$OSTYPE" == "darwin"* ]]; then
    alias showfiles="defaults write com.apple.finder AppleShowAllFiles YES; killall Finder"
    alias hidefiles="defaults write com.apple.finder AppleShowAllFiles NO; killall Finder"
fi

command -v bat &>/dev/null && alias cat='bat --style=plain'
command -v rg  &>/dev/null && alias grep='rg'

alias rat='ratatoist'
alias claude-cloud='unset ANTHROPIC_BASE_URL; unset ANTHROPIC_AUTH_TOKEN; unset ANTHROPIC_DEFAULT_HAIKU_MODEL; unset ANTHROPIC_DEFAULT_SONNET_MODEL; unset ANTHROPIC_DEFAULT_OPUS_MODEL; unset ANTHROPIC_MODEL; claude'
