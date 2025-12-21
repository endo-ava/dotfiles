# .bash_aliases

# 一般的なエイリアス
alias ls='ls --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# モダンツールの代替
if command -v eza >/dev/null 2>&1; then
    alias ls='eza --icons'
    alias ll='eza -al --icons'
fi

if command -v batcat >/dev/null 2>&1; then
    alias bat='batcat'
fi

# Git エイリアス
alias gst='git status'
alias gad='git add'
alias gcm='git commit -m'
alias gpl='git pull'
alias gps='git push'
alias glo='git log --oneline --graph'
