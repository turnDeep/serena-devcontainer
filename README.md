# Claude Code + Serena MCP + Brave Search Dev Container

VSCodeのDev Container環境でClaude Code、Serena-MCP、Brave Search（Web検索）を統合した開発環境です。

## 🚀 クイックスタート

### 1. 環境変数の設定（オプション but 推奨）

プロジェクトルートに`.env`ファイルを作成：

```bash
# .env
BRAVE_API_KEY=your-brave-api-key-here
```

> 💡 **Brave API keyの取得方法:**
> 1. [Brave Search API](https://brave.com/search/api/)にアクセス
> 2. 無料アカウントを作成（月2,000クエリまで無料）
> 3. APIキーを取得して上記`.env`に設定

### 2. Dev Containerの起動

1. VSCodeでプロジェクトを開く
2. `Cmd/Ctrl + Shift + P`で「Dev Containers: Reopen in Container」を選択
3. コンテナのビルドを待つ（初回は数分かかります）

### 3. Claude Code CLIのインストール

**Dev Container環境では、この手順はコンテナ起動時に自動的に実行されるため不要です。**

もしDev Containerを使用しない環境の場合は、以下のコマンドで手動でインストールしてください。

```bash
# Claude Code公式インストーラー
# 詳細: https://github.com/anthropics/claude-code
npm install -g @anthropic/claude-code
```

### 4. MCPサーバーの設定

```bash
# 自動設定スクリプトを実行
cc-setup

# または手動で設定
# Serena MCP（コーディング支援）
claude mcp add serena -- uvx --from git+https://github.com/oraios/serena serena start-mcp-server --context ide-assistant --project $(pwd)

# Brave Search MCP（Web検索 - APIキーが必要）
claude mcp add brave-search -- npx -y @modelcontextprotocol/server-brave-search
```

### 5. Claude Codeの起動

```bash
# Claude Codeを起動
claude

# MCPサーバーの状態確認
/mcp

# Serenaの初期設定を読み込む
/mcp__serena__initial_instructions
```

## 📁 ファイル構成

必要最低限の3ファイルのみ：

```
your-project/
├── .devcontainer/
│   ├── devcontainer.json  # コンテナ設定
│   └── setup.sh           # 自動セットアップスクリプト
├── .env                   # 環境変数（APIキー）
└── README.md              # このファイル
```

## 🎯 使用例

### コーディング + Web検索の組み合わせ

```bash
# Claude Code内で以下のような指示が可能：

# Web検索してから実装
"Search for the latest Next.js 15 App Router best practices and implement a sample page"

# エラー解決
"Search for solutions to this TypeScript error: TS2339 and fix the code"

# ドキュメント参照しながらコーディング
"Look up the React 19 use() hook documentation and create an example"

# 最新情報を調べて比較
"Search and compare Bun vs Node.js performance in 2025, then optimize our build script"
```

### 便利なエイリアス

```bash
cc           # Claude Codeを起動
cc-setup     # MCPサーバーを設定
cc-status    # MCPサーバーの状態確認
project-index # 大規模プロジェクトの事前インデックス作成
```

## ⚙️ 設定のカスタマイズ

### Brave Search APIキーの設定方法

#### 方法1: 環境変数（推奨）
```bash
# .envファイル
BRAVE_API_KEY=BSA-xxxxxxxxxxxxx
```

#### 方法2: devcontainer.jsonで直接設定
```json
"remoteEnv": {
  "BRAVE_API_KEY": "BSA-xxxxxxxxxxxxx"
}
```

#### 方法3: コンテナ内で設定
```bash
export BRAVE_API_KEY="BSA-xxxxxxxxxxxxx"
cc-setup  # 再度セットアップ
```

### Serenaの設定

`~/.serena/serena_config.yml`を編集：

```yaml
# 読み取り専用モード（安全に試したい場合）
default_project:
  read_only: true

# ダッシュボードのポート変更
dashboard:
  port: 24283  # デフォルト: 24282
```

## 🛠️ トラブルシューティング

### Brave Search APIが動作しない

```bash
# APIキーが設定されているか確認
echo $BRAVE_API_KEY

# MCPサーバーを再設定
claude mcp remove brave-search
export BRAVE_API_KEY="your-key"
claude mcp add brave-search -- npx -y @modelcontextprotocol/server-brave-search

# Claude Codeを再起動
claude
```

### Serenaが起動しない

```bash
# プロセスを確認
ps aux | grep serena

# 手動でテスト
uvx --from git+https://github.com/oraios/serena serena start-mcp-server --help

# ログを確認
cat ~/.serena/*.log
```

### ポート24282にアクセスできない

VSCodeの「ポート」タブでフォワーディングを確認：
1. アクティビティバーの「ポート」をクリック
2. 24282が表示されているか確認
3. 必要に応じて手動で追加

## 📊 Serenaダッシュボード

ブラウザでアクセス：
```
http://localhost:24282/dashboard/index.html
```

機能：
- リアルタイムログ表示
- ツール使用統計
- サーバー管理（シャットダウン）

## 🔒 セキュリティ注意事項

1. **APIキーの管理**
   - `.env`ファイルは`.gitignore`に追加
   - 本番環境のキーは使用しない

2. **シェルコマンド実行**
   - Serenaの`execute_shell_command`は承認制に設定済み
   - 不明なコマンドは実行前に確認

3. **プロジェクト権限**
   - 重要なプロジェクトでは`read_only: true`を検討

## 🚀 パフォーマンス最適化

### 大規模プロジェクトの場合

```bash
# 事前にインデックスを作成
project-index

# または特定ディレクトリのみ
uvx --from git+https://github.com/oraios/serena index-project src/
```

### コンテキスト管理

- 長いタスクは分割して実行
- 定期的に新しい会話を開始
- メモリー機能で継続性を保持

## 📚 参考リンク

- [Serena GitHub](https://github.com/oraios/serena)
- [Claude Code](https://github.com/anthropics/claude-code)
- [Brave Search API](https://brave.com/search/api/)
- [MCP Protocol](https://modelcontextprotocol.io/)

## 💡 Tips

- **無料枠**: Brave Search APIは月2,000クエリまで無料
- **代替検索**: APIキーなしでもSerenaのコーディング機能は全て使用可能
- **複数プロジェクト**: `cc-setup`を各プロジェクトで実行して切り替え

---

**問題が発生した場合**: まずは`cc-setup`を再実行してください。