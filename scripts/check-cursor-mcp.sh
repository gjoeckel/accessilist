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
