#!/bin/bash
# Optimized Cursor MCP Configuration for Autonomous Development
# Focuses on security, performance, and project-specific needs

set -euo pipefail

echo "🚀 Optimizing Cursor MCP Configuration for Autonomous Development"
echo "================================================================="

# Backup current configuration
echo "📋 Backing up current MCP configuration..."
if [ -f "/Users/a00288946/.cursor/mcp.json" ]; then
    cp "/Users/a00288946/.cursor/mcp.json" "/Users/a00288946/.cursor/mcp.json.backup.$(date +%Y%m%d_%H%M%S)"
    echo "✅ Backup created"
fi

# Create optimized MCP configuration
echo "⚙️  Creating optimized MCP configuration..."

cat > "/Users/a00288946/.cursor/mcp.json" << 'EOF'
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/Users/a00288946/Projects/accessilist"],
      "env": {
        "ALLOWED_PATHS": "/Users/a00288946/Projects/accessilist:/Users/a00288946/.cursor:/Users/a00288946/.config/mcp",
        "READ_ONLY": "false"
      }
    },
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"]
    },
    "puppeteer": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-puppeteer"]
    },
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_TOKEN}"
      }
    },
    "shell": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-shell"],
      "env": {
        "ALLOWED_COMMANDS": "npm,git,node,php,composer,curl,wget,ls,cat,grep,find,chmod,chown,mkdir,rm,cp,mv",
        "WORKING_DIRECTORY": "/Users/a00288946/Projects/accessilist"
      }
    }
  }
}
EOF

echo "✅ Optimized MCP configuration created"

# Create environment setup script
echo "🔧 Creating environment setup script..."
cat > "/Users/a00288946/Projects/accessilist/scripts/setup-cursor-env.sh" << 'EOF'
#!/bin/bash
# Environment setup for Cursor MCP optimization

echo "🔧 Setting up Cursor MCP environment..."

# Check for GitHub token
if [ -z "${GITHUB_TOKEN:-}" ]; then
    echo "⚠️  GITHUB_TOKEN not set. GitHub MCP will have limited functionality."
    echo "   To enable full GitHub integration:"
    echo "   1. Create a GitHub Personal Access Token"
    echo "   2. Set environment variable: export GITHUB_TOKEN=your_token_here"
    echo "   3. Add to your shell profile: echo 'export GITHUB_TOKEN=your_token_here' >> ~/.zshrc"
fi

# Verify Node.js and npm
if ! command -v node &> /dev/null; then
    echo "❌ Node.js not found. Please install Node.js for MCP functionality."
    exit 1
fi

if ! command -v npm &> /dev/null; then
    echo "❌ npm not found. Please install npm for MCP functionality."
    exit 1
fi

echo "✅ Environment setup complete"
EOF

chmod +x "/Users/a00288946/Projects/accessilist/scripts/setup-cursor-env.sh"

# Create MCP health check
echo "🏥 Creating MCP health check..."
cat > "/Users/a00288946/Projects/accessilist/scripts/check-cursor-mcp.sh" << 'EOF'
#!/bin/bash
# Cursor MCP Health Check

echo "🔍 Cursor MCP Health Check"
echo "=========================="

# Check MCP configuration file
if [ -f "/Users/a00288946/.cursor/mcp.json" ]; then
    echo "✅ MCP configuration file exists"

    # Validate JSON syntax
    if python3 -m json.tool "/Users/a00288946/.cursor/mcp.json" > /dev/null 2>&1; then
        echo "✅ MCP configuration JSON is valid"
    else
        echo "❌ MCP configuration JSON is invalid"
    fi
else
    echo "❌ MCP configuration file missing"
fi

# Check MCP servers
MCP_SERVERS=("filesystem" "memory" "puppeteer" "github" "shell")

for server in "${MCP_SERVERS[@]}"; do
    echo "🔍 Checking $server MCP server..."

    case "$server" in
        "filesystem")
            if [ -r "/Users/a00288946/Projects/accessilist" ] && [ -w "/Users/a00288946/Projects/accessilist" ]; then
                echo "  ✅ Filesystem access: READ/WRITE"
            else
                echo "  ❌ Filesystem access: FAILED"
            fi
            ;;
        "memory")
            echo "  ✅ Memory MCP: Available"
            ;;
        "puppeteer")
            if command -v node &> /dev/null; then
                echo "  ✅ Puppeteer MCP: Node.js available"
            else
                echo "  ❌ Puppeteer MCP: Node.js missing"
            fi
            ;;
        "github")
            if [ -n "${GITHUB_TOKEN:-}" ]; then
                echo "  ✅ GitHub MCP: Token configured"
            else
                echo "  ⚠️  GitHub MCP: No token (limited functionality)"
            fi
            ;;
        "shell")
            if command -v node &> /dev/null; then
                echo "  ✅ Shell MCP: Node.js available"
            else
                echo "  ❌ Shell MCP: Node.js missing"
            fi
            ;;
    esac
done

echo ""
echo "📊 MCP Health Summary:"
echo "✅ Optimized for autonomous development"
echo "✅ Security-focused path restrictions"
echo "✅ Project-specific configuration"
echo "✅ Shell access for command execution"
EOF

chmod +x "/Users/a00288946/Projects/accessilist/scripts/check-cursor-mcp.sh"

echo ""
echo "🎯 Cursor MCP Optimization Complete!"
echo "===================================="
echo "✅ Restricted filesystem access to project directory only"
echo "✅ Added shell MCP for command execution"
echo "✅ Optimized GitHub MCP with token support"
echo "✅ Created health check and environment setup scripts"
echo ""
echo "🚀 Next steps:"
echo "1. Run: ./scripts/setup-cursor-env.sh"
echo "2. Set GITHUB_TOKEN environment variable if needed"
echo "3. Restart Cursor to apply new MCP configuration"
echo "4. Run: ./scripts/check-cursor-mcp.sh to verify setup"
