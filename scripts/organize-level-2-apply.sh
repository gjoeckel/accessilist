#!/usr/local/bin/bash
# Level 2: Apply Folder Organization
# Applies changes from the latest Level 2 analysis report
# USER MUST HAVE REVIEWED REPORTS FIRST

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

PROJECT_DIR=$(pwd)
REPORT_DIR=".organize-reports"
LATEST_LINK="$REPORT_DIR/folder-level-latest.json"

echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Level 2: Apply Folder Organization                   ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if analysis exists
if [ ! -f "$LATEST_LINK" ]; then
    echo -e "${RED}❌ No Level 2 analysis found${NC}"
    echo -e "${CYAN}Run this first: ${YELLOW}proj-level-2${NC}"
    exit 1
fi

# Read JSON file
ACTIONS_FILE=$(readlink "$LATEST_LINK" | xargs basename)
ACTIONS_PATH="$REPORT_DIR/$ACTIONS_FILE"

echo -e "${CYAN}📋 Loading analysis from: ${BLUE}$ACTIONS_PATH${NC}"
echo ""

# Parse JSON
CONSOLIDATE_COUNT=$(cat "$ACTIONS_PATH" | jq '.actions.consolidate | length')

echo -e "${YELLOW}This will:${NC}"
echo -e "  • Consolidate ${CONSOLIDATE_COUNT} folders into organized structure"
echo ""

# Apply consolidations
if [ "$CONSOLIDATE_COUNT" -gt 0 ]; then
    echo -e "${CYAN}🔄 Consolidating folders...${NC}"

    mapfile -t consolidate_entries < <(cat "$ACTIONS_PATH" | jq -c '.actions.consolidate[]')

    for entry in "${consolidate_entries[@]}"; do
        folder=$(echo "$entry" | jq -r '.folder')
        action=$(echo "$entry" | jq -r '.action')

        # Extract destination from action (format: "Consolidate → destination")
        dest=$(echo "$action" | sed 's/.*→ //')

        if [ -d "$folder" ]; then
            mkdir -p "$dest"
            # Move contents
            if [ "$(ls -A "$folder" 2>/dev/null)" ]; then
                mv "$folder"/* "$dest/" 2>/dev/null || mv "$folder"/.* "$dest/" 2>/dev/null || true
            fi
            # Remove empty folder
            rmdir "$folder" 2>/dev/null || rm -rf "$folder"
            echo -e "   Consolidated: ${CYAN}$folder/${NC} → ${BLUE}$dest${NC}"
        fi
    done
fi

# Handle empty folders
EMPTY_COUNT=$(cat "$ACTIONS_PATH" | jq '.actions.empty | length')
if [ "$EMPTY_COUNT" -gt 0 ]; then
    echo ""
    echo -e "${CYAN}📭 Removing empty folders...${NC}"

    mapfile -t empty_entries < <(cat "$ACTIONS_PATH" | jq -c '.actions.empty[]')

    for entry in "${empty_entries[@]}"; do
        folder=$(echo "$entry" | jq -r '.folder')

        if [ -d "$folder" ] && [ -z "$(ls -A "$folder" 2>/dev/null)" ]; then
            rmdir "$folder"
            echo -e "   Removed: ${RED}$folder/${NC} (was empty)"
        fi
    done
fi

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  ✅ Level 2 Organization Applied Successfully!        ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}📋 Next Steps:${NC}"
echo -e "   1. Review folder structure: ${BLUE}tree -L 2 -d${NC}"
echo -e "   2. Check archive directory: ${BLUE}ls -la archive/${NC}"
echo -e "   3. Run Level 3 for final recommendations: ${YELLOW}proj-level-3${NC}"
echo ""
