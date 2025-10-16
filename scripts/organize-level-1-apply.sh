#!/usr/local/bin/bash
# Level 1: Apply Root Directory Organization
# Applies changes from the latest Level 1 analysis report
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
LATEST_LINK="$REPORT_DIR/root-level-latest.json"

echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Level 1: Apply Root Directory Organization           ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if analysis exists
if [ ! -f "$LATEST_LINK" ]; then
    echo -e "${RED}❌ No Level 1 analysis found${NC}"
    echo -e "${CYAN}Run this first: ${YELLOW}proj-organize-level-1${NC}"
    exit 1
fi

# Read JSON file
ACTIONS_FILE=$(readlink "$LATEST_LINK" | xargs basename)
ACTIONS_PATH="$REPORT_DIR/$ACTIONS_FILE"

echo -e "${CYAN}📋 Loading analysis from: ${BLUE}$ACTIONS_PATH${NC}"
echo ""

# Parse JSON and extract move actions
MOVE_COUNT=$(cat "$ACTIONS_PATH" | jq '.actions.move | length')
DELETE_COUNT=$(cat "$ACTIONS_PATH" | jq '.actions.delete | length')

echo -e "${YELLOW}This will:${NC}"
echo -e "  • Move ${MOVE_COUNT} files to organized directories"
echo -e "  • Delete ${DELETE_COUNT} temporary/backup files"
echo ""

# Extract destinations and create directories
echo -e "${CYAN}📁 Creating destination directories...${NC}"

mapfile -t destinations < <(cat "$ACTIONS_PATH" | jq -r '.actions.move[].destination' | sort -u)

for dest in "${destinations[@]}"; do
    mkdir -p "$dest"
    echo -e "   Created: ${BLUE}$dest${NC}"
done

echo ""
echo -e "${CYAN}📦 Moving files...${NC}"

# Move files
mapfile -t move_entries < <(cat "$ACTIONS_PATH" | jq -c '.actions.move[]')

for entry in "${move_entries[@]}"; do
    file=$(echo "$entry" | jq -r '.file')
    dest=$(echo "$entry" | jq -r '.destination')

    if [ -f "$file" ]; then
        mv "$file" "$dest/"
        echo -e "   Moved: ${CYAN}$file${NC} → ${BLUE}$dest/${NC}"
    else
        echo -e "   ${YELLOW}Skipped: $file (not found)${NC}"
    fi
done

# Delete files
if [ "$DELETE_COUNT" -gt 0 ]; then
    echo ""
    echo -e "${CYAN}🗑️  Deleting temporary files...${NC}"

    mapfile -t delete_entries < <(cat "$ACTIONS_PATH" | jq -c '.actions.delete[]')

    for entry in "${delete_entries[@]}"; do
        file=$(echo "$entry" | jq -r '.file')

        if [ -f "$file" ]; then
            rm "$file"
            echo -e "   Deleted: ${RED}$file${NC}"
        fi
    done
fi

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  ✅ Level 1 Organization Applied Successfully!        ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}📋 Next Steps:${NC}"
echo -e "   1. Review organized directories: ${BLUE}ls -la${NC}"
echo -e "   2. Check docs structure: ${BLUE}tree docs -L 2${NC}"
echo -e "   3. Run Level 2: ${YELLOW}proj-organize-level-2${NC}"
echo ""
