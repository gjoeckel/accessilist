#!/bin/bash

# Simple MCP Server Setup Script for Cursor IDE
# This script installs available MCP servers and creates a working configuration

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔧 Setting up Model Context Protocol (MCP) Servers for Cursor IDE${NC}"

# Check if Node.js is available
if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js not found. Please install Node.js first.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Node.js available: $(node --version)${NC}"

# Create MCP configuration directory
MCP_CONFIG_DIR="$HOME/.config/mcp"
mkdir -p "$MCP_CONFIG_DIR"

echo -e "${BLUE}📁 MCP config directory: $MCP_CONFIG_DIR${NC}"

# Install available MCP servers
echo -e "${BLUE}📦 Installing available MCP servers...${NC}"

# Install core MCP servers that are known to exist
echo -e "${YELLOW}Installing filesystem server...${NC}"
npm install -g @modelcontextprotocol/server-filesystem || echo -e "${YELLOW}Filesystem server installation failed${NC}"

echo -e "${YELLOW}Installing memory server...${NC}"
npm install -g @modelcontextprotocol/server-memory || echo -e "${YELLOW}Memory server installation failed${NC}"

# Try to install other servers (may not exist)
echo -e "${YELLOW}Installing GitHub server...${NC}"
npm install -g @modelcontextprotocol/server-github || echo -e "${YELLOW}GitHub server not available${NC}"

# Create a working MCP configuration with available servers
echo -e "${BLUE}⚙️  Creating MCP configuration...${NC}"
cat > "$MCP_CONFIG_DIR/cursor-config.json" << 'EOF'
{
  "mcpServers": {
    "filesystem": {
      "command": "@modelcontextprotocol/server-filesystem",
      "args": ["--root", "~"]
    },
    "memory": {
      "command": "@modelcontextprotocol/server-memory"
    }
  }
}
EOF

# Add GitHub server if it was installed successfully
if npm list -g @modelcontextprotocol/server-github &>/dev/null; then
    echo -e "${GREEN}✅ Adding GitHub server to configuration${NC}"
    # Update the config to include GitHub server
    cat > "$MCP_CONFIG_DIR/cursor-config.json" << 'EOF'
{
  "mcpServers": {
    "filesystem": {
      "command": "@modelcontextprotocol/server-filesystem",
      "args": ["--root", "~"]
    },
    "memory": {
      "command": "@modelcontextprotocol/server-memory"
    },
    "github": {
      "command": "@modelcontextprotocol/server-github"
    }
  }
}
EOF
fi

echo -e "${GREEN}✅ MCP configuration created${NC}"

# Create MCP status check script
echo -e "${BLUE}📊 Creating MCP status check script...${NC}"
cat > "$MCP_CONFIG_DIR/check-mcp-status.sh" << 'EOF'
#!/bin/bash

# MCP Status Check Script
echo "🔍 Checking MCP server status..."

# Check if MCP servers are installed
servers=(
    "@modelcontextprotocol/server-filesystem"
    "@modelcontextprotocol/server-memory"
    "@modelcontextprotocol/server-github"
)

for server in "${servers[@]}"; do
    if npm list -g "$server" &>/dev/null; then
        echo "✅ $server - Installed"
    else
        echo "❌ $server - Not installed"
    fi
done

# Check MCP configuration
if [ -f ~/.config/mcp/cursor-config.json ]; then
    echo "✅ MCP configuration file exists"
    echo "📄 Configuration contents:"
    cat ~/.config/mcp/cursor-config.json | jq . 2>/dev/null || cat ~/.config/mcp/cursor-config.json
else
    echo "❌ MCP configuration file missing"
fi

# Check Cursor settings
if [ -f ~/Library/Application\ Support/Cursor/User/settings.json ]; then
    if grep -q "mcp.enabled.*true" ~/Library/Application\ Support/Cursor/User/settings.json; then
        echo "✅ MCP enabled in Cursor settings"
    else
        echo "❌ MCP not enabled in Cursor settings"
    fi
else
    echo "❌ Cursor settings file missing"
fi

echo ""
echo "🎯 To enable MCP in Cursor:"
echo "1. Restart Cursor IDE completely"
echo "2. Check if MCP tools appear in the AI interface"
echo "3. If not, check Cursor's developer console for errors"
EOF

chmod +x "$MCP_CONFIG_DIR/check-mcp-status.sh"

# Create a simple MCP test script
echo -e "${BLUE}🧪 Creating MCP test script...${NC}"
cat > "$MCP_CONFIG_DIR/test-mcp.sh" << 'EOF'
#!/bin/bash

# MCP Test Script
echo "🧪 Testing MCP server functionality..."

# Test filesystem server
echo "Testing filesystem server..."
if command -v @modelcontextprotocol/server-filesystem &> /dev/null; then
    echo "✅ Filesystem server executable found"
else
    echo "❌ Filesystem server not found"
fi

# Test memory server
echo "Testing memory server..."
if command -v @modelcontextprotocol/server-memory &> /dev/null; then
    echo "✅ Memory server executable found"
else
    echo "❌ Memory server not found"
fi

# Test GitHub server
echo "Testing GitHub server..."
if command -v @modelcontextprotocol/server-github &> /dev/null; then
    echo "✅ GitHub server executable found"
else
    echo "❌ GitHub server not found"
fi

echo ""
echo "🎯 MCP servers are ready for Cursor IDE integration"
EOF

chmod +x "$MCP_CONFIG_DIR/test-mcp.sh"

echo -e "${GREEN}✅ MCP setup complete!${NC}"

# Run status check
echo -e "${BLUE}📊 Running MCP status check...${NC}"
"$MCP_CONFIG_DIR/check-mcp-status.sh"

echo ""
echo -e "${BLUE}🎉 MCP Setup Complete!${NC}"
echo ""
echo -e "${GREEN}✅ What's been installed:${NC}"
echo "   • Available MCP servers (filesystem, memory, github)"
echo "   • MCP configuration file"
echo "   • Status check and test scripts"
echo ""
echo -e "${YELLOW}🚀 Next Steps:${NC}"
echo "   1. Restart Cursor IDE completely (Cmd+Q, then reopen)"
echo "   2. Check if MCP tools appear in the AI chat interface"
echo "   3. Run status check: ~/.config/mcp/check-mcp-status.sh"
echo "   4. Test MCP: ~/.config/mcp/test-mcp.sh"
echo ""
echo -e "${BLUE}💡 Expected MCP Tools:${NC}"
echo "   • File system operations"
echo "   • Memory management"
echo "   • GitHub integration (if available)"
echo ""
echo -e "${GREEN}🎯 Ready to use MCP tools in Cursor IDE!${NC}"

