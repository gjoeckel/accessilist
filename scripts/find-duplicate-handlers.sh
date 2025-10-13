#!/bin/bash

# Simple Event Handler Duplicate Finder
# Compatible with bash 3.x (macOS default)

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}   Event Handler Duplicate Finder${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
echo ""

# Step 1: Find all event listeners by selector
echo -e "${CYAN}Analyzing event handlers for potential conflicts...${NC}"
echo ""

# Known selectors that might have duplicates
SELECTORS=(
    ".toggle-strip"
    ".status-button"
    ".restart-button"
    ".checkpoint-btn"
    ".filter-button"
    ".info-link"
    ".save-button"
)

for SELECTOR in "${SELECTORS[@]}"; do
    # Count in StateEvents.js (global delegation)
    GLOBAL_COUNT=$(grep -c "$SELECTOR" "$PROJECT_DIR/js/StateEvents.js" 2>/dev/null || echo "0")

    # Count in other files (direct listeners)
    DIRECT_COUNT=0
    for FILE in "$PROJECT_DIR/js"/*.js; do
        if [ "$FILE" != "$PROJECT_DIR/js/StateEvents.js" ]; then
            MATCHES=$(grep -c "$SELECTOR.*addEventListener" "$FILE" 2>/dev/null || echo "0")
            DIRECT_COUNT=$((DIRECT_COUNT + MATCHES))
        fi
    done

    # Report if both exist
    if [ "$GLOBAL_COUNT" -gt 0 ] && [ "$DIRECT_COUNT" -gt 0 ]; then
        echo -e "${YELLOW}⚠️  POTENTIAL CONFLICT: $SELECTOR${NC}"
        echo "   └─ Global delegation: $GLOBAL_COUNT (StateEvents.js)"
        echo "   └─ Direct listeners: $DIRECT_COUNT (other files)"
        echo ""

        # Show which files have direct listeners
        for FILE in "$PROJECT_DIR/js"/*.js; do
            if [ "$FILE" != "$PROJECT_DIR/js/StateEvents.js" ]; then
                if grep -q "$SELECTOR.*addEventListener" "$FILE" 2>/dev/null; then
                    FILENAME=$(basename "$FILE")
                    echo "      📁 $FILENAME"
                fi
            fi
        done
        echo ""
    elif [ "$GLOBAL_COUNT" -gt 0 ] || [ "$DIRECT_COUNT" -gt 0 ]; then
        echo -e "${GREEN}✅ $SELECTOR - No conflict${NC}"
        if [ "$GLOBAL_COUNT" -gt 0 ]; then
            echo "   └─ Global delegation only (StateEvents.js)"
        else
            echo "   └─ Direct listeners only"
        fi
        echo ""
    fi
done

echo -e "${CYAN}─────────────────────────────────────────────────────────${NC}"
echo ""

# Step 2: List all files with addEventListener
echo -e "${CYAN}Files with event listeners:${NC}"
echo ""

for FILE in "$PROJECT_DIR/js"/*.js; do
    COUNT=$(grep -c "addEventListener" "$FILE" 2>/dev/null || echo "0")
    if [ "$COUNT" -gt 0 ]; then
        FILENAME=$(basename "$FILE")
        printf "  %-30s %2d handlers\n" "$FILENAME" "$COUNT"
    fi
done

echo ""
echo -e "${CYAN}─────────────────────────────────────────────────────────${NC}"
echo ""

# Step 3: Show event types
echo -e "${CYAN}Event types in use:${NC}"
echo ""

for EVENT in "click" "keydown" "input" "change" "DOMContentLoaded" "contentBuilt" "beforeunload" "resize"; do
    COUNT=$(grep -r "addEventListener('$EVENT'" "$PROJECT_DIR/js" 2>/dev/null | wc -l | tr -d ' ')
    if [ "$COUNT" -gt 0 ]; then
        printf "  %-20s %2d handlers\n" "$EVENT" "$COUNT"
    fi
done

echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${GREEN}Analysis complete!${NC}"
echo ""
echo -e "${YELLOW}Recommendations:${NC}"
echo "  1. Review any conflicts shown above"
echo "  2. If global delegation exists, remove direct listeners"
echo "  3. Document which elements use global vs. direct handlers"
echo ""

