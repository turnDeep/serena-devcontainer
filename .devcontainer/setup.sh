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
npm install -g @anthropic-ai/sdk

# 3. gitの設定
echo "🔧 Configuring git..."
git config --global core.autocrlf input
git config --global init.defaultBranch main

# 4. Serena設定ディレクトリの準備
echo "📁 Preparing Serena configuration..."
mkdir -p ~/.serena

# 5. 基本的なSerena設定ファイルの作成
if [ ! -f ~/.serena/serena_config.yml ]; then
  cat > ~/.serena/serena_config.yml << 'EOF'
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
mkdir -p ~/.claude/config

# 7. MCPサーバー設定ファイルの作成
cat > ~/.claude/config/mcp_setup.sh << 'SCRIPT'
#!/bin/bash
# MCPサーバーを設定するスクリプト

echo "🚀 Setting up MCP servers..."

# Serena MCPを追加
echo "Adding Serena MCP..."
claude mcp add serena -- uvx --from git+https://github.com/oraios/serena serena start-mcp-server --context ide-assistant --project $(pwd)

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

chmod +x ~/.claude/config/mcp_setup.sh

# 8. 便利なエイリアスの設定（システム全体で有効化）
echo "🔧 Setting up system-wide aliases..."
sudo bash -c "cat > /etc/profile.d/claude_aliases.sh" << 'ALIASES'
#!/bin/bash

# Claude Code aliases
alias cc='claude'
alias cc-setup='~/.claude/config/mcp_setup.sh'
alias cc-status='claude mcp list'

# Serena dashboard
alias serena-dashboard='echo "Serena Dashboard: http://localhost:24282/dashboard/index.html"'

# Project helpers
alias project-index='uvx --from git+https://github.com/oraios/serena index-project'
ALIASES

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
echo "   Run: claude"
echo ""
echo "4. In Claude, load Serena instructions:"
echo "   Type: /mcp__serena__initial_instructions"
echo ""
echo "📦 Available commands:"
echo "   cc          - Start Claude Code"
echo "   cc-setup    - Configure MCP servers"
echo "   cc-status   - Check MCP server status"
echo ""
echo "🌐 Serena Dashboard:"
echo "   http://localhost:24282/dashboard/index.html"
echo "================================================"