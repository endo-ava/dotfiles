# My Dotfiles

開発環境を迅速にセットアップするためのドットファイル管理リポジトリです。
`GNU Stow` を使用して、各設定ファイルをホームディレクトリにシンボリックリンクとして配置します。

## 🚀 はじめに

このリポジトリには、Ubuntu/Debianベースのシステム（WSL2含む）向けの自動セットアップスクリプトが含まれています。

### 含まれるツール群
- **Shell**: Bash
- **Languages**: Python (uv), Node.js (nvm)
- **Modern CLI**: ripgrep, bat, eza, zoxide, fzf
- **AI Tools**: Claude Code, Codex, Gemini CLI, CodeRabbit
- **Others**: Git, GitHub CLI

## 🛠 インストール方法

1. リポジトリをクローンします：
   ```bash
   git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ```

2. インストールスクリプトを実行します：
   ```bash
   chmod +x install.sh
   ./install.sh
   ```

3. シェルを再起動するか、設定を反映させます：
   ```bash
   source ~/.bashrc
   ```

## 📂 ディレクトリ構成

- `bash/`: Bashの設定 (`.bashrc`, `.bash_aliases` など)
- `git/`: Gitの設定 (`.gitconfig`, `.gitignore_global`)
- `vscode/`: VS Code の設定
- `scripts/`: 自作のユーティリティスクリプト

## 🌲 ディレクトリ構成

```text
/root/dotfiles
├── README.md
├── install.sh
├── .bash_local (optional, ignored)
├── bash/
│   ├── .bash_aliases
│   └── .bashrc
├── git/
│   ├── .gitconfig
│   └── .gitignore_global
└── vscode/
    └── .config/
        └── Code/
            └── User/
                └── settings.json
```

## 🔧 手動でのリンク適用 (GNU Stow)

特定のディレクトリのみを適用したい場合は、`stow` コマンドを使用します：

```bash
# 例: gitの設定のみを適用
stow git
```