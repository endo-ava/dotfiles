#!/bin/bash

# ==========================================
# Development Environment Setup Script
# ==========================================

# -e: コマンドが失敗したら即終了
# -u: 未定義の変数を使おうとしたらエラー
# -o pipefail: パイプの途中でエラーが起きても検知
set -euo pipefail

# ログ出力用関数
log() {
    echo -e "\n\033[1;36m>> $1\033[0m"
}

# コマンドの存在確認
exists() {
    command -v "$1" >/dev/null 2>&1
}

log "セットアップを開始します..."

# ------------------------------------------
# 1. 基本パッケージ (APT)
# ------------------------------------------
install_base_packages() {
    log "システム更新と基本依存パッケージのインストール"
    sudo apt update && sudo apt upgrade -y
    
    # リストを見やすく整理
    local packages=(
        curl wget git unzip tar jq
        build-essential
        libsecret-1-dev
        stow
        python3-pip python3-venv
    )
    
    sudo apt install -y "${packages[@]}"
}

# ------------------------------------------
# 2. モダンRust製ツール群
# ------------------------------------------
install_modern_tools() {
    log "Rust製モダンツールのインストール (ripgrep, bat, eza, zoxide)"

    # ripgrep (grepの代替)
    if ! exists rg; then
        sudo apt install -y ripgrep
    fi

    # bat (catの代替)
    if ! exists batcat; then
        sudo apt install -y bat
        mkdir -p ~/.local/bin
        ln -sf /usr/bin/batcat ~/.local/bin/bat
    fi

    # eza (lsの代替)
    if ! exists eza; then
        # aptで入らない場合はcargo等が必要だが、ここではエラーを許容して続行
        if sudo apt install -y eza 2>/dev/null; then
            echo "Installed eza via apt."
        else
            echo "Warning: eza not found in apt. Install manually later."
        fi
    fi

    # zoxide (cdの代替)
    if ! exists zoxide; then
        curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
    fi
}

# ------------------------------------------
# 3. ユーティリティ (fzf, gh)
# ------------------------------------------
install_utils() {
    log "ユーティリティツールのセットアップ"

    # fzf
    if [ ! -d ~/.fzf ]; then
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
        ~/.fzf/install --all
    fi

    # GitHub CLI
    if ! exists gh; then
        echo "Installing GitHub CLI..."
        # 鍵リングのディレクトリ作成（無い場合のエラー防止）
        sudo mkdir -p -m 755 /etc/apt/keyrings
        
        wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
        sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
        
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
        
        sudo apt update && sudo apt install gh -y
    fi
}

# ------------------------------------------
# 4. Python環境 (uv)
# ------------------------------------------
install_python_env() {
    log "Python環境 (uv) のインストール"
    
    if ! exists uv; then
        curl -LsSf https://astral.sh/uv/install.sh | sh
    else
         echo "uv is already installed."
    fi

    # 現在のセッションのPATHに反映 (install.sh の後半で uv を使う可能性があるため)
    # uv はデフォルトで ~/.local/bin に入る
    export PATH="$HOME/.local/bin:$PATH"
    
    # cargo環境がある場合も考慮
    if [ -f "$HOME/.cargo/env" ]; then
        source "$HOME/.cargo/env"
    fi
}

# ------------------------------------------
# 5. Node.js環境 (NVM & npm packages)
# ------------------------------------------
install_node_env() {
    log "Node.js環境 (NVM) のセットアップ"
    
    export NVM_DIR="$HOME/.nvm"
    if [ ! -d "$NVM_DIR" ]; then
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
    fi

    # nvmをロード
    set +u
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    
    # LTS版のインストールと適用
    if ! exists node; then
        echo "Installing Node.js LTS..."
        nvm install --lts
        nvm use --lts
        nvm alias default 'lts/*'
    fi
    set -u

    log "npmグローバルパッケージのインストール"
    local npm_packages=(
        "@anthropic-ai/claude-code"
        "@openai/codex"
        "@google/gemini-cli"
    )

    if [ ${#npm_packages[@]} -gt 0 ]; then
        npm install -g "${npm_packages[@]}"
    else
        echo "No npm packages to install."
    fi
}

# ------------------------------------------
# 6. スタンドアロンバイナリ (Curl | sh)
# ------------------------------------------
install_binaries() {
    log "スタンドアロンツールのインストール"

    # CodeRabbit
    if ! exists coderabbit; then
        echo "Installing CodeRabbit..."
        curl -fsSL https://cli.coderabbit.ai/install.sh | sh
    fi
}

# ------------------------------------------
# 7. Dotfiles適用 (Stow)
# ------------------------------------------
apply_dotfiles() {
    log "Dotfilesのリンク適用 (Stow)"
    
    # スクリプトが存在するディレクトリに移動
    cd "$(dirname "$0")" || return

    # 管理対象のディレクトリリスト
    local targets=(bash git vscode agents)

    for target in "${targets[@]}"; do
        if [ -d "$target" ]; then
            echo "Stowing $target..."
            # stowのシミュレーションを実行して衝突を確認
            # 衝突がある場合（実ファイルが存在する場合）、それらをバックアップする
            # pipefail対策として、一時的にセットを解除するか、パイプの出口で真を返す
            local conflicts
            conflicts=$(stow -n -R "$target" 2>&1 | grep "existing target is neither a link nor a directory" | awk '{print $NF}' || true)
            
            if [ -n "$conflicts" ]; then
                echo "$conflicts" | while read -r file; do
                    if [ -f "$HOME/$file" ] && [ ! -L "$HOME/$file" ]; then
                        echo "Backing up existing file: $HOME/$file to $HOME/$file.bak"
                        mv "$HOME/$file" "$HOME/$file.bak"
                    fi
                done
            fi

            # リンクの適用
            stow -R "$target"
        else
            echo "Skipping $target (directory not found)"
        fi
    done
}

# ==========================================
# Main Execution Flow
# ==========================================

install_base_packages
install_modern_tools
install_utils
install_python_env
install_node_env
install_binaries
apply_dotfiles

log "✨ 全てのセットアップが完了しました。"
log "シェルを再起動するか、'source ~/.bashrc' を実行してください。"