#!/bin/bash

set -e

echo "Setting up Claude Code + Serena MCP environment..."

# 1. uvのインストール
echo "Installing uv..."
curl -LsSf https://astral.sh/uv/install.sh | sh
source $HOME/.cargo/env

# 2. Claude Code CLIのインストール（手動で必要）
echo "======================================="
echo "Claude Code CLI installation:"
echo "Please install Claude Code CLI manually by:"
echo "1. Visit: https://github.com/anthropics/claude-code"
echo "2. Follow the installation instructions for your system"
echo "======================================="

# 3. 基本的なPythonツールのインストール
echo "Installing Python tools..."
pip install --upgrade pip

# 4. Serena設定ディレクトリの準備
echo "Preparing Serena configuration..."
mkdir -p ~/.serena

# 5. 基本的な設定ファイルの作成（オプション）
if [ ! -f ~/.serena/serena_config.yml ]; then
  cat > ~/.serena/serena_config.yml << 'EOF'
# Serena Configuration
# This file will be auto-updated when you first run Serena

# Dashboard settings
dashboard:
  enabled: true
  open_browser: false  # Dev containerなのでブラウザは開かない
  port: 24282

# Logging
logging:
  level: INFO
  
# Tool settings
tools:
  execute_shell_command:
    enabled: true
    require_approval: true  # 安全のため承認を必要とする
EOF
  echo "Created basic Serena config at ~/.serena/serena_config.yml"
fi

# 6. gitの設定（Windowsホストの場合）
git config --global core.autocrlf input

echo "======================================="
echo "Setup completed!"
echo ""
echo "Next steps:"
echo "1. Install Claude Code CLI manually if not already installed"
echo "2. Run the following command in your project directory:"
echo "   claude mcp add serena -- uvx --from git+https://github.com/oraios/serena serena start-mcp-server --context ide-assistant --project \$(pwd)"
echo "3. Start using Claude Code with: claude"
echo ""
echo "Serena dashboard will be available at: http://localhost:24282/dashboard/index.html"
echo "======================================="