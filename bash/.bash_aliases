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

# 🤖 AI Agent Helpers
# 現在のディレクトリにエージェント用ルールファイルをリンクする
ai-rules() {
    local target_dir="${1:-.}"
    ln -sf ~/dotfiles/agents/CLAUDE.md "$target_dir/CLAUDE.md"
    ln -sf ~/dotfiles/agents/GEMINI.md "$target_dir/GEMINI.md"
    # AGENTS.md への直接リンクも予備として作成
    ln -sf ~/dotfiles/agents/AGENTS.md "$target_dir/AGENTS.md"
    echo "AI Agent rules (CLAUDE.md, GEMINI.md, AGENTS.md) linked to $target_dir"
}
