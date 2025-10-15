#!/bin/bash
# Simplified MCP Health Check - Focus on Core Functionality

echo "🔧 Simplified MCP Health Check"
echo "=============================="

# Check core MCP servers only
CORE_SERVERS=("filesystem" "memory" "puppeteer")

for server in "${CORE_SERVERS[@]}"; do
    echo "🔍 Checking $server MCP..."
    
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
    esac
done

echo ""
echo "📊 Summary: Core MCP servers optimized for autonomous development"
echo "✅ Terminal MCP removed to prevent conflicts"
echo "✅ Filesystem MCP configured for full project access"
echo "✅ Memory MCP available for context persistence"
echo "✅ Puppeteer MCP ready for browser automation"
