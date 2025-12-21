# .bashrc

# プロンプトの設定 (シンプル)
export PS1='\[\e[1;32m\]\u@\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]\$ '

# パスの追加
export PATH="$HOME/.local/bin:$PATH"

# エイリアスの読み込み
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# ==========================================
# 🔧 Tool Initializations
# ==========================================

# 1. Rust & uv Env (Path)
if [ -f "$HOME/.cargo/env" ]; then
    . "$HOME/.cargo/env"
elif [ -f "$HOME/.local/bin/env" ]; then
    . "$HOME/.local/bin/env"
fi

# 2. NVM (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# 3. Zoxide (Smart cd)
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init bash)"
fi

# 4. fzf (Fuzzy Finder)
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# 5. Direnv (もし入れたら)
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
