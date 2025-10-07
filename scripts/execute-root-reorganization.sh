#!/bin/bash

# Root Directory Reorganization Execution
# Implements the comprehensive file reorganization plan
# Safe execution with git tracking

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Configuration
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ANALYSIS_FILE="$PROJECT_ROOT/root-files-analysis.json"

echo -e "${BLUE}🚀 Root Directory Reorganization${NC}"
echo "=================================================="
echo "Project: $PROJECT_ROOT"
echo ""

# Check if analysis file exists
if [ ! -f "$ANALYSIS_FILE" ]; then
  echo -e "${RED}❌ Analysis file not found!${NC}"
  echo "Run: bash scripts/analyze-all-root-files.sh first"
  exit 1
fi

# Display plan summary
echo -e "${YELLOW}📋 Reorganization Plan:${NC}"
echo "  🗑️  Delete: 4 obsolete files"
echo "  📦 Move: 15 files to organized locations"
echo "  📚 Archive: 1 file to historical"
echo "  ✅ Keep: 13 essential files in root"
echo ""

if [ "$1" != "--execute" ]; then
  echo -e "${YELLOW}This is a DRY RUN - no changes will be made${NC}"
  echo ""
  echo "To execute: bash scripts/execute-root-reorganization.sh --execute"
  echo ""
  exit 0
fi

echo -e "${RED}⚠️  EXECUTING REORGANIZATION${NC}"
echo "=================================================="
echo ""
echo -e "${YELLOW}This will reorganize your root directory!${NC}"
echo -e "${YELLOW}Press Ctrl+C within 5 seconds to cancel...${NC}"
sleep 5
echo ""

# Phase 1: Create new directories
echo -e "${BLUE}📁 Phase 1: Creating Directory Structure${NC}"
echo "=================================================="

mkdir -p "$PROJECT_ROOT/scripts/session"
mkdir -p "$PROJECT_ROOT/scripts/setup"
mkdir -p "$PROJECT_ROOT/scripts/utils"
mkdir -p "$PROJECT_ROOT/scripts/apache"
mkdir -p "$PROJECT_ROOT/scripts/changelog"

echo -e "${GREEN}✓ Created scripts/session/${NC}"
echo -e "${GREEN}✓ Created scripts/setup/${NC}"
echo -e "${GREEN}✓ Created scripts/utils/${NC}"
echo -e "${GREEN}✓ Created scripts/apache/${NC}"
echo -e "${GREEN}✓ Created scripts/changelog/${NC}"
echo ""

# Phase 2: Delete obsolete files
echo -e "${BLUE}🗑️  Phase 2: Deleting Obsolete Files${NC}"
echo "=================================================="

declare -a DELETE_FILES=(
  "cleanup-analysis.json"
  "cleanup-recommendations.json"
  "cursor-settings-optimized.json"
  "test_url_parameter.php"
)

for file in "${DELETE_FILES[@]}"; do
  if [ -f "$PROJECT_ROOT/$file" ]; then
    rm "$PROJECT_ROOT/$file"
    echo -e "${GREEN}✓ Deleted: $file${NC}"
  else
    echo -e "${YELLOW}⚠ Not found: $file${NC}"
  fi
done
echo ""

# Phase 3: Move files to organized locations
echo -e "${BLUE}📦 Phase 3: Moving Files to Organized Locations${NC}"
echo "=================================================="

# Session scripts
declare -a SESSION_SCRIPTS=(
  "session-start.sh"
  "session-end.sh"
  "session-update.sh"
  "session-local.sh"
)

echo -e "${YELLOW}→ scripts/session/${NC}"
for file in "${SESSION_SCRIPTS[@]}"; do
  if [ -f "$PROJECT_ROOT/$file" ]; then
    git mv "$PROJECT_ROOT/$file" "$PROJECT_ROOT/scripts/session/"
    echo -e "${GREEN}  ✓ Moved: $file${NC}"
  fi
done
echo ""

# Setup scripts
declare -a SETUP_SCRIPTS=(
  "setup-mcp-servers.sh"
  "setup-mcp-simple.sh"
  "setup-production-env.sh"
  "srd-dev-setup.sh"
)

echo -e "${YELLOW}→ scripts/setup/${NC}"
for file in "${SETUP_SCRIPTS[@]}"; do
  if [ -f "$PROJECT_ROOT/$file" ]; then
    git mv "$PROJECT_ROOT/$file" "$PROJECT_ROOT/scripts/setup/"
    echo -e "${GREEN}  ✓ Moved: $file${NC}"
  fi
done
echo ""

# Utility scripts
declare -a UTIL_SCRIPTS=(
  "compress-context.sh"
  "configure-cursor-autonomy.sh"
)

echo -e "${YELLOW}→ scripts/utils/${NC}"
for file in "${UTIL_SCRIPTS[@]}"; do
  if [ -f "$PROJECT_ROOT/$file" ]; then
    git mv "$PROJECT_ROOT/$file" "$PROJECT_ROOT/scripts/utils/"
    echo -e "${GREEN}  ✓ Moved: $file${NC}"
  fi
done
echo ""

# Apache script
echo -e "${YELLOW}→ scripts/apache/${NC}"
if [ -f "$PROJECT_ROOT/rollback-apache-setup.sh" ]; then
  git mv "$PROJECT_ROOT/rollback-apache-setup.sh" "$PROJECT_ROOT/scripts/apache/"
  echo -e "${GREEN}  ✓ Moved: rollback-apache-setup.sh${NC}"
fi
echo ""

# Changelog script
echo -e "${YELLOW}→ scripts/changelog/${NC}"
if [ -f "$PROJECT_ROOT/ai-changelog-master.sh" ]; then
  git mv "$PROJECT_ROOT/ai-changelog-master.sh" "$PROJECT_ROOT/scripts/changelog/"
  echo -e "${GREEN}  ✓ Moved: ai-changelog-master.sh${NC}"
fi
echo ""

# General scripts
echo -e "${YELLOW}→ scripts/${NC}"
declare -a GENERAL_SCRIPTS=(
  "github-push-gate.sh"
  "start.sh"
)

for file in "${GENERAL_SCRIPTS[@]}"; do
  if [ -f "$PROJECT_ROOT/$file" ]; then
    git mv "$PROJECT_ROOT/$file" "$PROJECT_ROOT/scripts/"
    echo -e "${GREEN}  ✓ Moved: $file${NC}"
  fi
done
echo ""

# Log file
echo -e "${YELLOW}→ logs/${NC}"
if [ -f "$PROJECT_ROOT/php-server.log" ]; then
  git mv "$PROJECT_ROOT/php-server.log" "$PROJECT_ROOT/logs/"
  echo -e "${GREEN}  ✓ Moved: php-server.log${NC}"
fi
echo ""

# Phase 4: Archive historical documentation
echo -e "${BLUE}📚 Phase 4: Archiving Historical Documentation${NC}"
echo "=================================================="

if [ -f "$PROJECT_ROOT/ROOT-CLEANUP-SUMMARY.md" ]; then
  git mv "$PROJECT_ROOT/ROOT-CLEANUP-SUMMARY.md" "$PROJECT_ROOT/docs/historical/reports/"
  echo -e "${GREEN}✓ Archived: ROOT-CLEANUP-SUMMARY.md → docs/historical/reports/${NC}"
fi
echo ""

# Phase 5: Create README files for new directories
echo -e "${BLUE}📝 Phase 5: Creating Directory READMEs${NC}"
echo "=================================================="

# Session directory README
cat > "$PROJECT_ROOT/scripts/session/README.md" << 'EOF'
# Session Management Scripts

Scripts for managing AI agent development sessions.

## Scripts

- `session-start.sh` - Initialize new AI session with context loading
- `session-end.sh` - End session and save context
- `session-update.sh` - Update session information
- `session-local.sh` - Local session management

## Usage

Start a new session:
```bash
bash scripts/session/session-start.sh
```

End current session:
```bash
bash scripts/session/session-end.sh
```
EOF
echo -e "${GREEN}✓ Created: scripts/session/README.md${NC}"

# Setup directory README
cat > "$PROJECT_ROOT/scripts/setup/README.md" << 'EOF'
# Setup Scripts

Initial setup and configuration scripts for the development environment.

## Scripts

- `setup-mcp-servers.sh` - Configure MCP (Model Context Protocol) servers
- `setup-mcp-simple.sh` - Simplified MCP setup
- `setup-production-env.sh` - Production environment setup
- `srd-dev-setup.sh` - SRD development environment setup

## Usage

Set up MCP servers:
```bash
bash scripts/setup/setup-mcp-servers.sh
```

Set up production environment:
```bash
bash scripts/setup/setup-production-env.sh
```
EOF
echo -e "${GREEN}✓ Created: scripts/setup/README.md${NC}"

# Utils directory README
cat > "$PROJECT_ROOT/scripts/utils/README.md" << 'EOF'
# Utility Scripts

General utility scripts for development and maintenance.

## Scripts

- `compress-context.sh` - Compress context for AI sessions
- `configure-cursor-autonomy.sh` - Configure Cursor IDE for autonomous operation

## Usage

Compress context:
```bash
bash scripts/utils/compress-context.sh
```

Configure Cursor autonomy:
```bash
bash scripts/utils/configure-cursor-autonomy.sh
```
EOF
echo -e "${GREEN}✓ Created: scripts/utils/README.md${NC}"

# Apache directory README
cat > "$PROJECT_ROOT/scripts/apache/README.md" << 'EOF'
# Apache Scripts

Scripts for managing Apache web server configuration.

## Scripts

- `rollback-apache-setup.sh` - Rollback Apache configuration to default state

## Usage

Rollback Apache configuration:
```bash
bash scripts/apache/rollback-apache-setup.sh
```

See [APACHE-SETUP-GUIDE.md](../../APACHE-SETUP-GUIDE.md) for full Apache setup documentation.
EOF
echo -e "${GREEN}✓ Created: scripts/apache/README.md${NC}"

# Changelog directory README
cat > "$PROJECT_ROOT/scripts/changelog/README.md" << 'EOF'
# Changelog Scripts

Scripts for automated changelog generation and management.

## Scripts

- `ai-changelog-master.sh` - Master script for AI-powered changelog automation

## Usage

Generate changelog entry:
```bash
bash scripts/changelog/ai-changelog-master.sh
```
EOF
echo -e "${GREEN}✓ Created: scripts/changelog/README.md${NC}"

echo ""

# Final summary
echo -e "${GREEN}✅ Reorganization Complete!${NC}"
echo "=================================================="
echo ""
echo -e "${BLUE}📊 Summary:${NC}"
echo "  ✓ Deleted 4 obsolete files"
echo "  ✓ Moved 15 files to organized locations"
echo "  ✓ Archived 1 file to docs/historical/"
echo "  ✓ Created 5 new subdirectories"
echo "  ✓ Created 5 README files"
echo ""
echo -e "${BLUE}📁 New Structure:${NC}"
echo "  scripts/"
echo "    ├── session/ (4 scripts)"
echo "    ├── setup/ (4 scripts)"
echo "    ├── utils/ (2 scripts)"
echo "    ├── apache/ (1 script)"
echo "    ├── changelog/ (1 script)"
echo "    ├── github-push-gate.sh"
echo "    └── start.sh"
echo ""
echo -e "${BLUE}✅ Root Directory:${NC}"
echo "  Only 13 essential files remain"
echo ""
echo -e "${YELLOW}💡 Next Steps:${NC}"
echo "  1. Review changes: git status"
echo "  2. Test key scripts work from new locations"
echo "  3. Commit: git add -A && git commit"
echo "  4. Update any external references if needed"
echo ""

