# .bashrc

# プロンプトの設定 (シンプル)
export PS1='\[\e[1;32m\]\u@\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]\$ '

# エイリアスの読み込み
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# ==========================================
# 🔧 Tool Initializations
# ==========================================

# 1. Zoxide (Smart cd)
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init bash)"
fi

# 2. fzf (Fuzzy Finder)
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# 3. Direnv (もし入れたら)
if command -v direnv &> /dev/null; then
    eval "$(direnv hook bash)"
fi

# Add manually
parse_git_branch() {
  local b
  b=$(git symbolic-ref --quiet --short HEAD 2>/dev/null) || return 0
  printf " (%s)" "$b"
}
export PS1="\u@\h \[\033[32m\]\w\[\033[33m\]\$(parse_git_branch)\[\033[00m\] $ "
