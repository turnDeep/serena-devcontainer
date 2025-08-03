#!/bin/bash

set -e

echo "================================================"
echo "Setting up Claude Code + Serena MCP + Brave Search"
echo "================================================"

# 1. uvのインストール
echo "📦 Installing uv package manager..."
curl -LsSf https://astral.sh/uv/install.sh | sh

# 2. Claude Code CLIのインストール
echo "📦 Installing Claude Code CLI via npm..."
npm install -g @anthropic-ai/claude-code

# 3. gitの設定
echo "🔧 Configuring git..."
git config --global core.autocrlf input
git config --global init.defaultBranch main

# 4. Serena設定ディレクトリの準備
echo "📁 Preparing Serena configuration..."
mkdir -p "$HOME/.serena"

# 5. 基本的なSerena設定ファイルの作成
if [ ! -f "$HOME/.serena/serena_config.yml" ]; then
  cat > "$HOME/.serena/serena_config.yml" << 'EOF'
# Serena Configuration
dashboard:
  enabled: true
  open_browser: false  # Dev containerなのでブラウザは開かない
  port: 24282

logging:
  level: INFO
  
tools:
  execute_shell_command:
    enabled: true
    require_approval: true  # 安全のため承認を必要とする

# プロジェクトのデフォルト設定
default_project:
  read_only: false
  auto_index: true
EOF
  echo "✅ Created Serena config"
fi

# 6. Claude設定ディレクトリの準備
echo "📁 Preparing Claude configuration..."
mkdir -p "$HOME/.claude/config"

# 7. MCPサーバー設定ファイルの作成
cat > "$HOME/.claude/config/mcp_setup.sh" << 'SCRIPT'
#!/bin/bash
# MCPサーバーを設定するスクリプト

echo "🚀 Setting up MCP servers..."

# Serena MCPを追加
echo "Adding Serena MCP..."
claude mcp add serena -- uvx --from git+https://github.com/oraios/serena serena start-mcp-server --context ide-assistant --project "$(pwd)"

# Brave Search MCPを追加（APIキーが設定されている場合のみ）
if [ ! -z "$BRAVE_API_KEY" ]; then
  echo "Adding Brave Search MCP..."
  claude mcp add brave-search -- npx -y @modelcontextprotocol/server-brave-search
  echo "✅ Brave Search MCP added"
else
  echo "⚠️  BRAVE_API_KEY not set. Skipping Brave Search MCP."
  echo "   To enable web search, set BRAVE_API_KEY environment variable."
fi

echo "✅ MCP servers setup complete!"
echo ""
echo "Run 'claude' to start Claude Code"
SCRIPT

chmod +x "$HOME/.claude/config/mcp_setup.sh"

# 8. コマンドラッパーの作成（システム全体で有効化）
echo "🔧 Creating system-wide command wrappers..."

# cc
sudo bash -c "cat > /usr/local/bin/cc" << 'EOF'
#!/bin/bash
set -e
exec claude "$@"
EOF

# cc-setup
# スクリプトのフルパスを指定
sudo bash -c "cat > /usr/local/bin/cc-setup" << 'EOF'
#!/bin/bash
set -e
exec $HOME/.claude/config/mcp_setup.sh "$@"
EOF

# cc-status
sudo bash -c "cat > /usr/local/bin/cc-status" << 'EOF'
#!/bin/bash
set -e
exec claude mcp list "$@"
EOF

# serena-dashboard
sudo bash -c "cat > /usr/local/bin/serena-dashboard" << 'EOF'
#!/bin/bash
echo "Serena Dashboard: http://localhost:24282/dashboard/index.html"
EOF

# project-index
# uvxは$HOME/.local/binにインストールされるためフルパスを指定
sudo bash -c "cat > /usr/local/bin/project-index" << 'EOF'
#!/bin/bash
set -e
exec $HOME/.local/bin/uvx --from git+https://github.com/oraios/serena index-project "$@"
EOF

# 作成したスクリプトに実行権限を付与
sudo chmod +x /usr/local/bin/cc /usr/local/bin/cc-setup /usr/local/bin/cc-status /usr/local/bin/serena-dashboard /usr/local/bin/project-index

# 9. 完了メッセージ
echo ""
echo "================================================"
echo "✅ Setup completed!"
echo "================================================"
echo ""
echo "📋 Next steps:"
echo ""
echo "1. Set up Brave Search API key (optional):"
echo "   - Get API key from: https://brave.com/search/api/"
echo "   - Set in .env file or export BRAVE_API_KEY='your-key'"
echo ""
echo "2. Configure MCP servers:"
echo "   Run: cc-setup"
echo ""
echo "3. Start Claude Code:"
echo "   Run: cc"
echo ""
echo "4. In Claude, load Serena instructions:"
echo "   Type: /mcp__serena__initial_instructions"
echo ""
echo "📦 Available commands:"
echo "   cc          - Start Claude Code (alias for claude)"
echo "   cc-setup    - Configure MCP servers"
echo "   cc-status   - Check MCP server status"
echo ""
echo "🌐 Serena Dashboard:"
echo "   http://localhost:24282/dashboard/index.html"
echo "================================================"
