# Claude Code + Serena MCP Dev Container

VSCodeのDev Container環境でClaude CodeとSerena-MCPを使用するための設定です。

## 特徴

- **シンプルな構成**: 最小限の設定でSerena-MCPを導入
- **Python開発環境**: Python 3.11ベースのコンテナ
- **自動セットアップ**: uvの自動インストール
- **ダッシュボード**: Serenaのログと状態を確認できるWebダッシュボード

## セットアップ手順

### 1. リポジトリの準備

```bash
# プロジェクトディレクトリに移動
cd your-project

# .devcontainerディレクトリとファイルを配置
mkdir -p .devcontainer
# 上記のdevcontainer.jsonとsetup.shを配置
chmod +x .devcontainer/setup.sh
```

### 2. Dev Containerの起動

1. VSCodeでプロジェクトを開く
2. コマンドパレット（Cmd/Ctrl + Shift + P）で「Dev Containers: Reopen in Container」を選択
3. コンテナのビルドと起動を待つ

### 3. Claude Code CLIのインストール

Dev Container内で以下を実行：

```bash
# Claude Code CLIのインストール（公式の手順に従って）
# 詳細: https://github.com/anthropics/claude-code
```

### 4. Serena-MCPの登録

プロジェクトディレクトリで以下のコマンドを実行：

```bash
# Serena MCPサーバーを追加
claude mcp add serena -- uvx --from git+https://github.com/oraios/serena serena start-mcp-server --context ide-assistant --project $(pwd)
```

### 5. Claude Codeの起動

```bash
# Claude Codeを起動
claude

# 初回起動時、Serenaの指示を読み込む
# Claude内で以下のコマンドを実行するか、「read Serena's initial instructions」と伝える
/mcp__serena__initial_instructions
```

## 使い方

### 基本的なコマンド

Claude Code内で使える主なSerenaの機能：

- **プロジェクトの有効化**: "Activate the project /workspace"
- **コード検索**: "Find symbol named [function_name]"
- **コード編集**: "Replace the function [name] with..."
- **テスト実行**: "Run the tests"
- **ファイル作成**: "Create a new file..."

### Serenaダッシュボード

ブラウザで以下のURLにアクセス：
```
http://localhost:24282/dashboard/index.html
```

ダッシュボードでは：
- Serenaのログを確認
- ツールの使用統計を表示
- サーバーのシャットダウン

## ディレクトリ構造

```
your-project/
├── .devcontainer/
│   ├── devcontainer.json  # Dev Container設定
│   └── setup.sh           # セットアップスクリプト
├── .serena/               # Serena設定（自動生成）
│   ├── project.yml        # プロジェクト設定
│   └── memories/          # プロジェクトメモリー
└── your-code/
```

## 設定のカスタマイズ

### Serena設定

`~/.serena/serena_config.yml`を編集して設定をカスタマイズ：

```yaml
dashboard:
  enabled: true
  port: 24282

tools:
  execute_shell_command:
    enabled: true
    require_approval: true  # セキュリティのため
```

### プロジェクト設定

`.serena/project.yml`でプロジェクト固有の設定：

```yaml
name: my-project
read_only: false  # true にすると読み取り専用モード
included_tools:
  - all  # または特定のツールのみ
```

## トラブルシューティング

### Serenaが起動しない場合

```bash
# プロセスを確認
ps aux | grep serena

# 手動でuvxをインストール
curl -LsSf https://astral.sh/uv/install.sh | sh
source $HOME/.cargo/env
```

### ダッシュボードにアクセスできない場合

VSCodeのポートフォワーディングを確認：
1. VSCodeの「ポート」タブを開く
2. 24282ポートが転送されているか確認

### メモリ不足の場合

大規模プロジェクトでは初回のインデックス作成に時間がかかります：

```bash
# プロジェクトのインデックスを事前作成
uvx --from git+https://github.com/oraios/serena index-project
```

## 注意事項

- **セキュリティ**: `execute_shell_command`ツールは任意のコマンドを実行できるため、承認設定を推奨
- **バックアップ**: 重要なコードは必ずバージョン管理システムでバックアップ
- **コンテキスト**: 大規模なタスクでは新しい会話を開始することを推奨

## 参考リンク

- [Serena GitHub](https://github.com/oraios/serena)
- [Claude Code Documentation](https://github.com/anthropics/claude-code)
- [MCP Protocol](https://modelcontextprotocol.io/)