#!/bin/bash
# Restart MCP Servers - Quick Restart for Development
# Use this when you need to restart MCP servers without full setup

set -euo pipefail

echo "🔄 RESTARTING MCP SERVERS"
echo "=========================="

PROJECT_ROOT="/Users/a00288946/Projects/accessilist"

# Stop existing servers
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

# Wait for cleanup
sleep 2

# Start servers using the main startup script
echo "🚀 Restarting MCP servers..."
"$PROJECT_ROOT/scripts/start-mcp-servers.sh"

echo "✅ MCP servers restarted successfully!"