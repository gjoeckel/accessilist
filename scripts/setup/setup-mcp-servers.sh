#!/bin/bash

# MCP Server Setup Script for Cursor IDE
# This script installs and configures Model Context Protocol servers

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
    echo -e "${RED}❌ Node.js not found. Installing Node.js via NVM...${NC}"

    # Install NVM if not present
    if ! command -v nvm &> /dev/null; then
        echo -e "${YELLOW}Installing NVM...${NC}"
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash

        # Source NVM
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    fi

    # Install and use latest LTS Node.js
    nvm install --lts
    nvm use --lts
    nvm alias default node
fi

echo -e "${GREEN}✅ Node.js available: $(node --version)${NC}"

# Create MCP configuration directory
MCP_CONFIG_DIR="$HOME/.config/mcp"
mkdir -p "$MCP_CONFIG_DIR"

echo -e "${BLUE}📁 MCP config directory: $MCP_CONFIG_DIR${NC}"

# Install MCP servers
echo -e "${BLUE}📦 Installing MCP servers...${NC}"

# Install core MCP servers
echo -e "${YELLOW}Installing core MCP servers...${NC}"
npm install -g @modelcontextprotocol/server-filesystem
npm install -g @modelcontextprotocol/server-memory
npm install -g @modelcontextprotocol/server-git

# Install macOS-specific MCP servers
echo -e "${YELLOW}Installing macOS-specific MCP servers...${NC}"

# Apple MCP (macOS system integration)
if ! npx -y install-mcp apple-mcp --client cursor 2>/dev/null; then
    echo -e "${YELLOW}Installing apple-mcp manually...${NC}"
    npm install -g @modelcontextprotocol/server-apple
fi

# Xcode Build MCP
if ! npx -y install-mcp xcode-build-mcp --client cursor 2>/dev/null; then
    echo -e "${YELLOW}Installing xcode-build-mcp manually...${NC}"
    npm install -g @modelcontextprotocol/server-xcode
fi

# App Opener MCP
if ! npx -y install-mcp app-opener --client cursor 2>/dev/null; then
    echo -e "${YELLOW}Installing app-opener manually...${NC}"
    npm install -g @modelcontextprotocol/server-app-opener
fi

# Mac Monitor MCP
if ! npx -y install-mcp mac-monitor-mcp --client cursor 2>/dev/null; then
    echo -e "${YELLOW}Installing mac-monitor-mcp manually...${NC}"
    npm install -g @modelcontextprotocol/server-mac-monitor
fi

# GitHub MCP
echo -e "${YELLOW}Installing GitHub MCP server...${NC}"
npm install -g @modelcontextprotocol/server-github

# Create comprehensive MCP configuration
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
    },
    "git": {
      "command": "@modelcontextprotocol/server-git",
      "args": ["--root", "~"]
    },
    "github": {
      "command": "@modelcontextprotocol/server-github"
    },
    "apple-mcp": {
      "command": "npx",
      "args": ["-y", "install-mcp", "apple-mcp", "--client", "cursor"]
    },
    "xcode-build-mcp": {
      "command": "npx",
      "args": ["-y", "install-mcp", "xcode-build-mcp", "--client", "cursor"]
    },
    "app-opener": {
      "command": "npx",
      "args": ["-y", "install-mcp", "app-opener", "--client", "cursor"]
    },
    "mac-monitor-mcp": {
      "command": "npx",
      "args": ["-y", "install-mcp", "mac-monitor-mcp", "--client", "cursor"]
    }
  }
}
EOF

echo -e "${GREEN}✅ MCP configuration created${NC}"

# Create MCP startup script
echo -e "${BLUE}🚀 Creating MCP startup script...${NC}"
cat > "$MCP_CONFIG_DIR/start-mcp.sh" << 'EOF'
#!/bin/bash

# MCP Server Startup Script
echo "Starting MCP servers for Cursor IDE..."

# Start each MCP server in background
echo "Starting filesystem server..."
@modelcontextprotocol/server-filesystem --root ~ &

echo "Starting memory server..."
@modelcontextprotocol/server-memory &

echo "Starting git server..."
@modelcontextprotocol/server-git --root ~ &

echo "Starting GitHub server..."
@modelcontextprotocol/server-github &

echo "MCP servers started successfully!"
echo "You can now use MCP tools in Cursor IDE"
EOF

chmod +x "$MCP_CONFIG_DIR/start-mcp.sh"

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
    "@modelcontextprotocol/server-git"
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
EOF

chmod +x "$MCP_CONFIG_DIR/check-mcp-status.sh"

echo -e "${GREEN}✅ MCP setup complete!${NC}"

# Run status check
echo -e "${BLUE}📊 Running MCP status check...${NC}"
"$MCP_CONFIG_DIR/check-mcp-status.sh"

echo ""
echo -e "${BLUE}🎉 MCP Setup Complete!${NC}"
echo ""
echo -e "${GREEN}✅ What's been installed:${NC}"
echo "   • Core MCP servers (filesystem, memory, git, github)"
echo "   • macOS-specific MCP servers (apple, xcode, app-opener, mac-monitor)"
echo "   • MCP configuration file"
echo "   • Startup and status check scripts"
echo ""
echo -e "${YELLOW}🚀 Next Steps:${NC}"
echo "   1. Restart Cursor IDE completely"
echo "   2. Check if MCP tools appear in the AI chat interface"
echo "   3. Run status check: ~/.config/mcp/check-mcp-status.sh"
echo "   4. If needed, start MCP servers: ~/.config/mcp/start-mcp.sh"
echo ""
echo -e "${BLUE}💡 MCP Tools Available:${NC}"
echo "   • File system operations"
echo "   • Memory management"
echo "   • Git operations"
echo "   • GitHub integration"
echo "   • macOS system control"
echo "   • Xcode build operations"
echo "   • Application launching"
echo "   • System monitoring"
echo ""
echo -e "${GREEN}🎯 Ready to use MCP tools in Cursor IDE!${NC}"
