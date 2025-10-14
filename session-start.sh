#!/bin/bash

# AI Session Start Handler - Load relevant context
# Run this at the start of each AI session to load context

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}📋 Loading context for new AI session...${NC}"

# Create changelog directory if it doesn't exist
CHANGELOG_DIR="$HOME/.ai-changelogs"
mkdir -p "$CHANGELOG_DIR"
mkdir -p "$CHANGELOG_DIR/projects"

# Get current project info
PROJECT_NAME=$(basename $(pwd))
TIMESTAMP=$(date)

echo -e "${YELLOW}Project: $PROJECT_NAME${NC}"
echo -e "${YELLOW}Working Directory: $(pwd)${NC}"

# Load project-specific context
PROJECT_FILE="$CHANGELOG_DIR/projects/$PROJECT_NAME.md"
if [ -f "$PROJECT_FILE" ]; then
    echo -e "${GREEN}📁 Project context found:${NC}"
    echo "=================================="
    head -30 "$PROJECT_FILE"
    echo "=================================="
    echo ""
else
    echo -e "${YELLOW}⚠️  No project context found for: $PROJECT_NAME${NC}"
    echo -e "${BLUE}💡 Run session-end.sh after your first session to create project context${NC}"
    echo ""
fi

# Load last session summary
SUMMARY_FILE="$CHANGELOG_DIR/last-session-summary.md"
if [ -f "$SUMMARY_FILE" ]; then
    echo -e "${GREEN}📊 Last session summary:${NC}"
    echo "=================================="
    cat "$SUMMARY_FILE"
    echo "=================================="
    echo ""
else
    echo -e "${YELLOW}⚠️  No last session summary found${NC}"
    echo ""
fi

# Load recent session summaries (last 3)
echo -e "${GREEN}🔍 Recent session summaries:${NC}"
echo "=================================="
RECENT_SESSIONS=$(ls -t "$CHANGELOG_DIR"/session-*.md 2>/dev/null | head -3)
if [ -n "$RECENT_SESSIONS" ]; then
    for session in $RECENT_SESSIONS; do
        SESSION_NAME=$(basename "$session" .md)
        echo -e "${BLUE}📝 $SESSION_NAME:${NC}"
        grep -E "## 🎯|## 🔧|## 🚀|## 💡" "$session" | head -4
        echo ""
    done
else
    echo -e "${YELLOW}⚠️  No recent session summaries found${NC}"
fi
echo "=================================="
echo ""

# Load context summary if available
CONTEXT_SUMMARY="$CHANGELOG_DIR/context-summary.md"
if [ -f "$CONTEXT_SUMMARY" ]; then
    echo -e "${GREEN}📋 Context summary:${NC}"
    echo "=================================="
    head -20 "$CONTEXT_SUMMARY"
    echo "=================================="
    echo ""
fi

# Check for MCP memory context
if command -v mcp-server-memory &> /dev/null; then
    echo -e "${BLUE}🧠 MCP memory available for context storage/retrieval${NC}"
    echo -e "${YELLOW}💡 Use MCP memory tools to store and retrieve session context${NC}"
    echo ""
fi

# Display current project state
echo -e "${GREEN}🎯 Current Project State:${NC}"
echo "=================================="
echo "**Project**: $PROJECT_NAME"
echo "**Directory**: $(pwd)"
echo "**Git Repository**: $(git remote get-url origin 2>/dev/null || echo "No remote repository")"
echo "**Git Branch**: $(git branch --show-current 2>/dev/null || echo "Not a git repository")"
echo "**Node Version**: $(node --version 2>/dev/null || echo "Node.js not available")"
echo "**Shell**: $SHELL"
echo ""

# Check for common development files
echo -e "${GREEN}📊 Project Structure:${NC}"
echo "=================================="
if [ -f "package.json" ]; then
    echo "✅ package.json found"
    echo "   Project: $(grep '"name"' package.json | head -1 || echo "Unknown")"
fi

if [ -f ".eslintrc.js" ] || [ -f ".eslintrc.json" ]; then
    echo "✅ ESLint configuration found"
fi

if [ -f ".prettierrc" ] || [ -f ".prettierrc.json" ]; then
    echo "✅ Prettier configuration found"
fi

if [ -f "jest.config.js" ] || [ -f "jest.config.json" ]; then
    echo "✅ Jest configuration found"
fi

if [ -f "tsconfig.json" ]; then
    echo "✅ TypeScript configuration found"
fi

if [ -f "README.md" ]; then
    echo "✅ README.md found"
fi

echo "=================================="
echo ""

# Load SRD context if available
if [ -f "$HOME/Developer/srd-templates/SRD-DEVELOPMENT-GUIDE.md" ]; then
    echo -e "${GREEN}🎯 SRD Development Environment:${NC}"
    echo "=================================="
    echo "✅ SRD (Simple, Reliable, DRY) development tools available"
    echo "✅ ESLint with SRD rules configured"
    echo "✅ Prettier for consistent formatting"
    echo "✅ Jest with 80% coverage requirements"
    echo "✅ Code analysis tools (complexity, duplication, dependencies)"
    echo "=================================="
    echo ""
fi

# Display MCP tools status
echo -e "${GREEN}🤖 MCP Tools Status:${NC}"
echo "=================================="
MCP_TOOLS=("mcp-server-memory" "mcp-server-github" "mcp-server-filesystem" "mcp-server-sequential-thinking" "mcp-server-everything" "mcp-server-puppeteer" "enhanced-postgres-mcp-server")

for tool in "${MCP_TOOLS[@]}"; do
    if command -v "$tool" &> /dev/null; then
        echo "✅ $tool - Available"
    else
        echo "❌ $tool - Not available"
    fi
done
echo "=================================="
echo ""

# Final summary
echo -e "${BLUE}🎉 Context loading complete!${NC}"
echo -e "${YELLOW}📋 Context loaded:${NC}"
echo "   • Project-specific context"
echo "   • Last session summary"
echo "   • Recent session summaries"
echo "   • Current project state"
echo "   • Development environment status"
echo "   • MCP tools status"
echo ""
echo -e "${YELLOW}💡 Ready for AI session with full context!${NC}"
echo -e "${BLUE}🔧 Remember to run session-end.sh at the end of this session${NC}"


