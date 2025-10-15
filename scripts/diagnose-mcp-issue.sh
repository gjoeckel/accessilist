#!/bin/bash
# MCP Configuration Diagnosis Script
# Identifies issues preventing autonomous command execution

set -euo pipefail

echo "🔍 MCP Configuration Diagnosis"
echo "=============================="

# Check if MCP configuration file exists
echo "📋 Checking MCP configuration file..."
if [ -f "/Users/a00288946/.cursor/mcp.json" ]; then
    echo "✅ MCP configuration file exists at /Users/a00288946/.cursor/mcp.json"
    
    # Check file permissions
    ls -la "/Users/a00288946/.cursor/mcp.json"
    
    # Validate JSON syntax
    if python3 -m json.tool "/Users/a00288946/.cursor/mcp.json" > /dev/null 2>&1; then
        echo "✅ MCP configuration JSON is valid"
    else
        echo "❌ MCP configuration JSON is invalid"
        echo "📄 Content preview:"
        head -10 "/Users/a00288946/.cursor/mcp.json"
    fi
    
    # Check for shell MCP server
    if grep -q "shell" "/Users/a00288946/.cursor/mcp.json"; then
        echo "✅ Shell MCP server found in configuration"
    else
        echo "❌ Shell MCP server NOT found in configuration"
    fi
    
    # Check for allowed commands
    if grep -q "ALLOWED_COMMANDS" "/Users/a00288946/.cursor/mcp.json"; then
        echo "✅ ALLOWED_COMMANDS found in configuration"
        echo "📋 Allowed commands:"
        grep -A 1 "ALLOWED_COMMANDS" "/Users/a00288946/.cursor/mcp.json" | tail -1
    else
        echo "❌ ALLOWED_COMMANDS NOT found in configuration"
    fi
    
else
    echo "❌ MCP configuration file missing at /Users/a00288946/.cursor/mcp.json"
fi

echo ""
echo "🔧 Checking Cursor configuration directory..."
if [ -d "/Users/a00288946/.cursor" ]; then
    echo "✅ Cursor configuration directory exists"
    echo "📁 Contents:"
    ls -la "/Users/a00288946/.cursor/"
else
    echo "❌ Cursor configuration directory missing"
fi

echo ""
echo "🔍 Checking for alternative MCP configuration locations..."
ALTERNATIVE_LOCATIONS=(
    "/Users/a00288946/.config/mcp"
    "/Users/a00288946/.cursor/mcp"
    "/Users/a00288946/Projects/accessilist/.cursor"
)

for location in "${ALTERNATIVE_LOCATIONS[@]}"; do
    if [ -d "$location" ]; then
        echo "✅ Found alternative location: $location"
        ls -la "$location"
    fi
done

echo ""
echo "🧪 Testing MCP server availability..."
echo "Available MCP tools:"
echo "- mcp_filesystem: $(if command -v mcp_filesystem &> /dev/null; then echo "✅ Available"; else echo "❌ Not available"; fi)"
echo "- mcp_memory: $(if command -v mcp_memory &> /dev/null; then echo "✅ Available"; else echo "❌ Not available"; fi)"
echo "- mcp_puppeteer: $(if command -v mcp_puppeteer &> /dev/null; then echo "✅ Available"; else echo "❌ Not available"; fi)"
echo "- mcp_github: $(if command -v mcp_github &> /dev/null; then echo "✅ Available"; else echo "❌ Not available"; fi)"

echo ""
echo "📊 Diagnosis Summary:"
echo "===================="

# Check if we can run terminal commands
if command -v run_terminal_cmd &> /dev/null; then
    echo "✅ Terminal command execution available"
else
    echo "❌ Terminal command execution NOT available"
fi

# Check if we can access filesystem
if command -v mcp_filesystem &> /dev/null; then
    echo "✅ Filesystem MCP available"
else
    echo "❌ Filesystem MCP NOT available"
fi

echo ""
echo "💡 Recommendations:"
echo "=================="
echo "1. Check if Cursor is using the correct MCP configuration"
echo "2. Verify MCP servers are installed and running"
echo "3. Restart Cursor if configuration changes were made"
echo "4. Check Cursor logs for MCP server errors"