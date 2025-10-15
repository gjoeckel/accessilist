#!/bin/bash
# Optimize MCP Configuration for 40-Tool Limit
# This script creates a minimal MCP configuration to stay under the limit

set -euo pipefail

echo "🎯 OPTIMIZING MCP FOR 40-TOOL LIMIT"
echo "===================================="

PROJECT_ROOT="/Users/a00288946/Projects/accessilist"

# Backup current configuration
if [ -f "$PROJECT_ROOT/.cursor/mcp.json" ]; then
    cp "$PROJECT_ROOT/.cursor/mcp.json" "$PROJECT_ROOT/.cursor/mcp.json.backup"
    echo "✅ Current MCP config backed up to mcp.json.backup"
fi

# Create optimized configuration with only essential servers
echo "🔧 Creating optimized MCP configuration..."

cat > "$PROJECT_ROOT/.cursor/mcp.json" << 'EOF'
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
    }
  }
}
EOF

echo "✅ Optimized MCP configuration created"

# Calculate estimated tool count
echo ""
echo "📊 ESTIMATED TOOL COUNT:"
echo "========================"
echo "• filesystem server: ~15 tools"
echo "• memory server: ~8 tools"
echo "• puppeteer server: ~12 tools"
echo "Total estimated: ~35 tools"
echo "✅ Under 40-tool limit!"

echo ""
echo "🚫 REMOVED SERVERS (to stay under limit):"
echo "========================================="
echo "• github server (~20 tools) - REMOVED"
echo "• sequential-thinking server (~5 tools) - REMOVED"
echo "• everything server (~25 tools) - REMOVED"
echo "• shell server (~10 tools) - REMOVED"

# Create alternative configurations for optional use
echo ""
echo "🔧 Creating alternative configurations..."

# GitHub-only configuration (for when you need GitHub features)
cat > "$PROJECT_ROOT/.cursor/mcp-with-github.json" << 'EOF'
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
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_TOKEN}"
      }
    }
  }
}
EOF

echo "✅ GitHub configuration created: mcp-with-github.json"

# Create startup script for optimized configuration
cat > "$PROJECT_ROOT/scripts/start-optimized-mcp.sh" << 'EOF'
#!/bin/bash
# Start Optimized MCP Servers (Under 40-Tool Limit)

set -euo pipefail

echo "🚀 STARTING OPTIMIZED MCP SERVERS"
echo "================================="

PROJECT_ROOT="/Users/a00288946/Projects/accessilist"

# Stop any existing MCP servers
echo "🛑 Stopping existing MCP servers..."
for pid_file in "$PROJECT_ROOT/.cursor"/*.pid; do
    if [ -f "$pid_file" ]; then
        pid=$(cat "$pid_file")
        if kill -0 "$pid" 2>/dev/null; then
            echo "Stopping process $pid..."
            kill "$pid" 2>/dev/null || true
        fi
        rm -f "$pid_file"
    fi
done

sleep 2

# Start optimized MCP servers
echo "🚀 Starting optimized MCP servers..."

# Filesystem MCP
echo "Starting filesystem MCP server..."
nohup npx -y @modelcontextprotocol/server-filesystem /Users/a00288946/Projects/accessilist > "$PROJECT_ROOT/logs/mcp-filesystem.log" 2>&1 &
echo $! > "$PROJECT_ROOT/.cursor/filesystem.pid"
echo "✅ Filesystem MCP server started (PID: $!)"

# Memory MCP
echo "Starting memory MCP server..."
nohup npx -y @modelcontextprotocol/server-memory > "$PROJECT_ROOT/logs/mcp-memory.log" 2>&1 &
echo $! > "$PROJECT_ROOT/.cursor/memory.pid"
echo "✅ Memory MCP server started (PID: $!)"

# Puppeteer MCP
echo "Starting puppeteer MCP server..."
nohup npx -y @modelcontextprotocol/server-puppeteer > "$PROJECT_ROOT/logs/mcp-puppeteer.log" 2>&1 &
echo $! > "$PROJECT_ROOT/.cursor/puppeteer.pid"
echo "✅ Puppeteer MCP server started (PID: $!)"

sleep 3

echo ""
echo "🎯 OPTIMIZED MCP SERVERS STARTED"
echo "================================"
echo "✅ 3 servers running (under 40-tool limit)"
echo "✅ Estimated ~35 tools available"
echo "✅ Autonomous operation ready"
echo ""
echo "📋 Available MCP Operations:"
echo "  • File System: Read, write, list, search files"
echo "  • Memory: Store and retrieve knowledge"
echo "  • Browser: Navigate, screenshot, automation"
echo ""
echo "🚀 Ready for autonomous development!"
EOF

chmod +x "$PROJECT_ROOT/scripts/start-optimized-mcp.sh"
echo "✅ Optimized startup script created: start-optimized-mcp.sh"

echo ""
echo "🎯 OPTIMIZATION COMPLETE!"
echo "========================"
echo "✅ MCP configuration optimized for 40-tool limit"
echo "✅ Only essential servers enabled"
echo "✅ Backup created of original configuration"
echo "✅ Alternative configurations available"
echo ""
echo "🚀 NEXT STEPS:"
echo "1. Run: ./scripts/start-optimized-mcp.sh"
echo "2. Restart Cursor IDE"
echo "3. Verify tool count is under 40"
echo "4. Begin autonomous development"