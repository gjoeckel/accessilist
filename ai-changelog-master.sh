#!/bin/bash

# AI Changelog Master Script - Complete automation system
# Manages the entire AI session context lifecycle

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}🤖 AI Changelog Automation System${NC}"
echo -e "${BLUE}===================================${NC}"
echo ""

# Function to display usage
show_usage() {
    echo -e "${YELLOW}Usage: $0 [command]${NC}"
    echo ""
    echo -e "${GREEN}Commands:${NC}"
    echo "  start     - Load context for new AI session"
    echo "  update    - Record progress mid-session (without ending)"
    echo "  local     - Commit changes to local branch"
    echo "  end       - Generate changelog for completed session"
    echo "  repeat           - AI returns VERY CONCISE understanding, critical questions only, wait for proceed"
    echo "  repeat-full      - AI returns DETAILED understanding, critical questions only, wait for proceed"
    echo "  repeat-questions - AI returns DETAILED understanding, SRD scope questions, wait for proceed"
    echo "  compress  - Compress context into summary"
    echo "  status    - Show current context status"
    echo "  clean     - Clean old context files"
    echo "  setup     - Initial setup of changelog system"
    echo "  help      - Show this help message"
    echo ""
    echo -e "${YELLOW}Examples:${NC}"
    echo "  $0 start     # Start new AI session with context"
    echo "  $0 update    # Record progress mid-session"
    echo "  $0 local     # Commit changes to local branch"
    echo "  $0 end       # End current session and generate changelog"
    echo "  $0 repeat    # AI repeats understanding of preceding content"
    echo "  $0 compress  # Compress context for efficiency"
    echo "  $0 status    # Check current context status"
}

# Function to setup the changelog system
setup_system() {
    echo -e "${BLUE}🔧 Setting up AI Changelog System...${NC}"

    # Create directories
    CHANGELOG_DIR="$HOME/.ai-changelogs"
    mkdir -p "$CHANGELOG_DIR"
    mkdir -p "$CHANGELOG_DIR/projects"
    mkdir -p "$CHANGELOG_DIR/backups"

    echo -e "${GREEN}✅ Created directory structure${NC}"

    # Create initial configuration
    cat > "$CHANGELOG_DIR/config.json" << EOF
{
  "version": "1.0.0",
  "maxSessions": 100,
  "maxAge": 30,
  "compressionEnabled": true,
  "mcpIntegration": true,
  "srdFocus": true
}
EOF

    echo -e "${GREEN}✅ Created configuration file${NC}"

    # Create initial context summary
    cat > "$CHANGELOG_DIR/context-summary.md" << EOF
# AI Development Context Summary
*Initial Setup: $(date)*

## 🎯 **Current Development State**
- **Active Focus**: SRD Development (Simple, Reliable, DRY)
- **MCP Tools**: 7 servers configured and operational
- **Development Environment**: macOS Tahoe with Cursor IDE

## 🔧 **Recent Key Changes**
- Initial AI changelog automation system setup
- SRD development environment configured
- MCP tools installed and operational

## 💡 **Key Decisions & Context**
- Focus on Simple, Reliable, DRY development principles
- Automated context management for AI sessions
- GitHub push gate with token "push to github"

## 🚀 **Current Priorities & Next Steps**
- Implement automated changelog generation
- Optimize context size for AI session efficiency
- Integrate with MCP memory for persistent storage

## 📊 **Active Configurations**
- **MCP Servers**: memory, github, filesystem, sequential-thinking, everything, puppeteer, postgres
- **SRD Tools**: ESLint, Prettier, Jest with SRD-specific rules
- **GitHub Push Gate**: Requires token "push to github"

## 🛠️ **Available Tools & Capabilities**
- **Code Quality**: ESLint with complexity limits, Prettier formatting
- **Testing**: Jest with 80% coverage requirements
- **Analysis**: Complexity, duplication, and dependency analysis
- **Automation**: Browser automation via Puppeteer
- **Database**: PostgreSQL operations via MCP
- **Memory**: Persistent context storage via MCP memory

---
*This summary is automatically generated and updated*
EOF

    echo -e "${GREEN}✅ Created initial context summary${NC}"

    # Create aliases for easy access
    cat > "$HOME/.ai-changelog-aliases" << EOF
# AI Changelog Aliases
alias ai-start='$SCRIPT_DIR/ai-changelog-master.sh start'
alias ai-end='$SCRIPT_DIR/ai-changelog-master.sh end'
alias ai-repeat='$SCRIPT_DIR/ai-changelog-master.sh repeat'
alias ai-repeat-full='$SCRIPT_DIR/ai-changelog-master.sh repeat-full'
alias ai-repeat-questions='$SCRIPT_DIR/ai-changelog-master.sh repeat-questions'
alias ai-compress='$SCRIPT_DIR/ai-changelog-master.sh compress'
alias ai-status='$SCRIPT_DIR/ai-changelog-master.sh status'
alias ai-clean='$SCRIPT_DIR/ai-changelog-master.sh clean'
EOF

    echo -e "${GREEN}✅ Created aliases file${NC}"
    echo -e "${YELLOW}💡 Add 'source ~/.ai-changelog-aliases' to your shell profile${NC}"

    echo ""
    echo -e "${BLUE}🎉 AI Changelog System setup complete!${NC}"
    echo -e "${YELLOW}📋 Next steps:${NC}"
    echo "   1. Add aliases to your shell: source ~/.ai-changelog-aliases"
    echo "   2. Start your first session: ai-start"
    echo "   3. End your session: ai-end"
    echo "   4. Compress context: ai-compress"
}

# Function to show status
show_status() {
    echo -e "${BLUE}📊 AI Changelog System Status${NC}"
    echo "=================================="

    CHANGELOG_DIR="$HOME/.ai-changelogs"

    if [ -d "$CHANGELOG_DIR" ]; then
        echo -e "${GREEN}✅ System Directory: $CHANGELOG_DIR${NC}"

        # Count sessions
        SESSION_COUNT=$(find "$CHANGELOG_DIR" -name "session-*.md" 2>/dev/null | wc -l)
        echo -e "${GREEN}✅ Total Sessions: $SESSION_COUNT${NC}"

        # Count projects
        PROJECT_COUNT=$(find "$CHANGELOG_DIR/projects" -name "*.md" 2>/dev/null | wc -l)
        echo -e "${GREEN}✅ Active Projects: $PROJECT_COUNT${NC}"

        # Recent activity
        RECENT_SESSIONS=$(find "$CHANGELOG_DIR" -name "session-*.md" -mtime -1 2>/dev/null | wc -l)
        echo -e "${GREEN}✅ Sessions (24h): $RECENT_SESSIONS${NC}"

        # File sizes
        if [ -f "$CHANGELOG_DIR/context-summary.md" ]; then
            SUMMARY_SIZE=$(wc -c < "$CHANGELOG_DIR/context-summary.md")
            echo -e "${GREEN}✅ Context Summary: ${SUMMARY_SIZE} bytes${NC}"
        fi

        if [ -f "$CHANGELOG_DIR/quick-context.md" ]; then
            QUICK_SIZE=$(wc -c < "$CHANGELOG_DIR/quick-context.md")
            echo -e "${GREEN}✅ Quick Context: ${QUICK_SIZE} bytes${NC}"
        fi

        # MCP integration status
        if command -v mcp-server-memory &> /dev/null; then
            echo -e "${GREEN}✅ MCP Memory: Available${NC}"
        else
            echo -e "${YELLOW}⚠️  MCP Memory: Not available${NC}"
        fi

    else
        echo -e "${RED}❌ System not initialized${NC}"
        echo -e "${YELLOW}💡 Run: $0 setup${NC}"
    fi

    echo "=================================="
}

# Function to clean old files
clean_system() {
    echo -e "${BLUE}🧹 Cleaning AI Changelog System...${NC}"

    CHANGELOG_DIR="$HOME/.ai-changelogs"

    if [ -d "$CHANGELOG_DIR" ]; then
        # Remove old session files (older than 30 days)
        OLD_SESSIONS=$(find "$CHANGELOG_DIR" -name "session-*.md" -mtime +30 2>/dev/null | wc -l)
        if [ "$OLD_SESSIONS" -gt 0 ]; then
            find "$CHANGELOG_DIR" -name "session-*.md" -mtime +30 -delete
            echo -e "${GREEN}✅ Removed $OLD_SESSIONS old session files${NC}"
        else
            echo -e "${GREEN}✅ No old session files to remove${NC}"
        fi

        # Compress large files
        find "$CHANGELOG_DIR" -name "*.md" -size +1M -exec gzip {} \;
        echo -e "${GREEN}✅ Compressed large files${NC}"

        # Create backup
        BACKUP_DIR="$CHANGELOG_DIR/backups/backup-$(date +%Y%m%d-%H%M%S)"
        mkdir -p "$BACKUP_DIR"
        cp -r "$CHANGELOG_DIR"/*.md "$BACKUP_DIR/" 2>/dev/null || true
        echo -e "${GREEN}✅ Created backup: $BACKUP_DIR${NC}"

    else
        echo -e "${RED}❌ System not initialized${NC}"
    fi

    echo -e "${GREEN}✅ Cleanup complete${NC}"
}

# Main command handling
case "${1:-help}" in
    "start")
        echo -e "${BLUE}🚀 Starting AI session with context...${NC}"
        "$SCRIPT_DIR/session-start.sh"
        ;;
    "update")
        echo -e "${BLUE}📝 Recording mid-session progress...${NC}"
        "$SCRIPT_DIR/session-update.sh"
        ;;
    "local")
        echo -e "${BLUE}💾 Committing changes to local branch...${NC}"
        "$SCRIPT_DIR/session-local.sh"
        ;;
    "end")
        echo -e "${BLUE}📝 Ending AI session and generating changelog...${NC}"
        "$SCRIPT_DIR/session-end.sh"
        ;;
    "repeat")
        echo -e "${BLUE}🔄 AI Repeat Mode - VERY CONCISE${NC}"
        echo -e "${BLUE}===============================${NC}"
        echo ""
        echo -e "${YELLOW}📋 MANDATORY WORKFLOW FOR AI AGENT:${NC}"
        echo -e "${YELLOW}1. Return VERY CONCISE understanding of developer's request${NC}"
        echo -e "${YELLOW}2. Ask ONLY questions to avoid CRITICAL failure or gaps${NC}"
        echo -e "${YELLOW}3. WAIT - Do not take any actions${NC}"
        echo -e "${YELLOW}4. Proceed only when token 'proceed' is returned by developer${NC}"
        echo ""
        echo -e "${RED}⚠️  CRITICAL ENFORCEMENT:${NC}"
        echo -e "${RED}• DO NOT take any actions until 'proceed' token is received${NC}"
        echo -e "${RED}• BE VERY CONCISE - minimal detail, essential points only${NC}"
        echo -e "${RED}• WAIT for developer to type 'proceed' in chat${NC}"
        echo ""
        echo -e "${BLUE}🤖 AI AGENT: Start with VERY CONCISE understanding...${NC}"
        ;;
    "repeat-full")
        echo -e "${BLUE}🔄 AI Repeat Mode - DETAILED${NC}"
        echo -e "${BLUE}===========================${NC}"
        echo ""
        echo -e "${YELLOW}📋 MANDATORY WORKFLOW FOR AI AGENT:${NC}"
        echo -e "${YELLOW}1. Return DETAILED understanding of developer's request${NC}"
        echo -e "${YELLOW}2. Ask ONLY questions to avoid CRITICAL failure or gaps${NC}"
        echo -e "${YELLOW}3. WAIT - Do not take any actions${NC}"
        echo -e "${YELLOW}4. Proceed only when token 'proceed' is returned by developer${NC}"
        echo ""
        echo -e "${RED}⚠️  CRITICAL ENFORCEMENT:${NC}"
        echo -e "${RED}• DO NOT take any actions until 'proceed' token is received${NC}"
        echo -e "${RED}• PROVIDE DETAILED understanding - comprehensive analysis${NC}"
        echo -e "${RED}• WAIT for developer to type 'proceed' in chat${NC}"
        echo ""
        echo -e "${BLUE}🤖 AI AGENT: Start with DETAILED understanding...${NC}"
        ;;
    "repeat-questions")
        echo -e "${BLUE}🔄 AI Repeat Mode - DETAILED WITH SRD QUESTIONS${NC}"
        echo -e "${BLUE}============================================${NC}"
        echo ""
        echo -e "${YELLOW}📋 MANDATORY WORKFLOW FOR AI AGENT:${NC}"
        echo -e "${YELLOW}1. Return DETAILED understanding of developer's request${NC}"
        echo -e "${YELLOW}2. Ask ANY questions within SRD scope related to request${NC}"
        echo -e "${YELLOW}3. WAIT - Do not take any actions${NC}"
        echo -e "${YELLOW}4. Proceed only when token 'proceed' is returned by developer${NC}"
        echo ""
        echo -e "${GREEN}📚 SRD SCOPE: Simple, Reliable, DRY principles${NC}"
        echo -e "${GREEN}• Simple: Clear, straightforward implementations${NC}"
        echo -e "${GREEN}• Reliable: Robust, error-free, well-tested${NC}"
        echo -e "${GREEN}• DRY: Don't Repeat Yourself - efficient, maintainable${NC}"
        echo ""
        echo -e "${RED}⚠️  CRITICAL ENFORCEMENT:${NC}"
        echo -e "${RED}• DO NOT take any actions until 'proceed' token is received${NC}"
        echo -e "${RED}• PROVIDE DETAILED understanding with SRD-focused questions${NC}"
        echo -e "${RED}• WAIT for developer to type 'proceed' in chat${NC}"
        echo ""
        echo -e "${BLUE}🤖 AI AGENT: Start with DETAILED understanding and SRD questions...${NC}"
        ;;
    "compress")
        echo -e "${BLUE}🗜️  Compressing context...${NC}"
        "$SCRIPT_DIR/compress-context.sh"
        ;;
    "status")
        show_status
        ;;
    "clean")
        clean_system
        ;;
    "setup")
        setup_system
        ;;
    "help"|*)
        show_usage
        ;;
esac


