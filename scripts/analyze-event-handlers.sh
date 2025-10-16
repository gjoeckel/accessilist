#!/bin/bash

# Event Handler Conflict Analysis Script
# Identifies potential duplicate event handlers across the codebase

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OUTPUT_FILE="$PROJECT_DIR/EVENT_HANDLERS_ANALYSIS.md"

echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║      Event Handler Conflict Analysis Tool             ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# Create report file
cat > "$OUTPUT_FILE" << 'EOF'
# Event Handler Conflict Analysis Report

**Generated:** $(date -u '+%Y-%m-%d %H:%M:%S UTC')

## Executive Summary

This report identifies all event handlers in the JavaScript codebase and flags potential conflicts where multiple handlers may be attached to the same elements.

---

## Analysis Results

EOF

echo -e "${CYAN}Step 1: Finding all addEventListener calls...${NC}"

# Find all addEventListener calls with context
grep -rn "addEventListener(" "$PROJECT_DIR/js" --include="*.js" -B 3 -A 2 > /tmp/event_handlers.txt || true

# Count total handlers
TOTAL_HANDLERS=$(grep -c "addEventListener(" /tmp/event_handlers.txt || echo "0")
echo -e "${GREEN}✅ Found $TOTAL_HANDLERS event handler registrations${NC}"
echo ""

# Analyze by event type
echo -e "${CYAN}Step 2: Analyzing by event type...${NC}"

cat >> "$OUTPUT_FILE" << EOF

### Event Types Summary

EOF

# Count by event type
for EVENT_TYPE in "click" "keydown" "input" "change" "submit" "focus" "blur" "resize" "scroll" "DOMContentLoaded" "contentBuilt" "beforeunload"; do
    COUNT=$(grep -c "addEventListener('$EVENT_TYPE'" /tmp/event_handlers.txt 2>/dev/null || echo "0")
    if [ "$COUNT" -gt 0 ]; then
        echo "  - $EVENT_TYPE: $COUNT handlers"
        echo "- **$EVENT_TYPE**: $COUNT handlers" >> "$OUTPUT_FILE"
    fi
done

echo ""

# Detailed analysis by event type
cat >> "$OUTPUT_FILE" << 'EOF'

---

## Detailed Event Handler Breakdown

### 1. Global Event Delegation (Potential Conflict Points)

EOF

echo -e "${CYAN}Step 3: Identifying global delegation patterns...${NC}"

# Find global document/window listeners
cat >> "$OUTPUT_FILE" << 'EOF'
Global event delegation catches events at the document/window level and can conflict with direct element listeners.

**Files with global delegation:**

EOF

grep -n "document\.addEventListener\|window\.addEventListener" "$PROJECT_DIR/js"/*.js | while IFS=: read -r file line content; do
    filename=$(basename "$file")
    echo "- **$filename:$line** - \`$content\`" >> "$OUTPUT_FILE"
done

cat >> "$OUTPUT_FILE" << 'EOF'

---

### 2. Direct Element Listeners (Potential Duplicates)

EOF

echo -e "${CYAN}Step 4: Finding direct element listeners...${NC}"

# Find direct element listeners (querySelector, getElementById, etc.)
grep -B 5 "addEventListener(" "$PROJECT_DIR/js"/*.js | grep -E "(querySelector|getElementById|getElementsBy)" -A 5 > /tmp/direct_listeners.txt || true

cat >> "$OUTPUT_FILE" << 'EOF'
Direct element listeners can conflict with global delegation if both handle the same event on the same element.

**Common Patterns:**

EOF

# Analyze common element selections
for SELECTOR in ".toggle-strip" ".status-button" ".restart-button" ".info-link" ".checkpoint-btn" ".filter-button"; do
    if grep -q "$SELECTOR" /tmp/direct_listeners.txt 2>/dev/null; then
        echo "- **$SELECTOR** - Found in direct listeners" >> "$OUTPUT_FILE"
    fi
done

cat >> "$OUTPUT_FILE" << 'EOF'

---

### 3. HIGH RISK: Potential Conflict Analysis

EOF

echo -e "${CYAN}Step 5: Analyzing for potential conflicts...${NC}"
echo ""

# Known conflict patterns
declare -A CONFLICTS

# Check for toggle-strip conflicts
if grep -q "\.toggle-strip.*addEventListener.*click" "$PROJECT_DIR/js/StateEvents.js" 2>/dev/null && \
   grep -q "\.toggle-strip.*addEventListener.*click" "$PROJECT_DIR/js/side-panel.js" 2>/dev/null; then
    CONFLICTS[".toggle-strip"]="StateEvents.js + side-panel.js"
fi

# Check for status-button conflicts
if grep -q "\.status-button.*addEventListener" "$PROJECT_DIR/js/StateEvents.js" 2>/dev/null; then
    STATUS_COUNT=$(grep -c "\.status-button.*addEventListener" "$PROJECT_DIR/js"/*.js 2>/dev/null || echo "0")
    if [ "$STATUS_COUNT" -gt 1 ]; then
        CONFLICTS[".status-button"]="Multiple files handle status buttons"
    fi
fi

# Report conflicts
if [ ${#CONFLICTS[@]} -gt 0 ]; then
    cat >> "$OUTPUT_FILE" << 'EOF'
#### ⚠️ Potential Conflicts Detected

EOF
    for key in "${!CONFLICTS[@]}"; do
        echo -e "${YELLOW}⚠️  Potential conflict: $key - ${CONFLICTS[$key]}${NC}"
        echo "- **$key**: ${CONFLICTS[$key]}" >> "$OUTPUT_FILE"
    done
else
    cat >> "$OUTPUT_FILE" << 'EOF'
#### ✅ No Obvious Conflicts Detected

Based on automated analysis, no duplicate event handlers were found. Manual review recommended for complex cases.

EOF
    echo -e "${GREEN}✅ No obvious conflicts detected${NC}"
fi

echo ""

cat >> "$OUTPUT_FILE" << 'EOF'

---

### 4. Event Delegation vs. Direct Listeners Comparison

EOF

# Create comparison table
cat >> "$OUTPUT_FILE" << 'EOF'
| Element Selector | Global Delegation | Direct Listeners | Risk Level |
|------------------|-------------------|------------------|------------|
EOF

# Check common elements
for SELECTOR in ".toggle-strip" ".status-button" ".restart-button" ".checkpoint-btn" ".filter-button" ".info-link"; do
    GLOBAL=$(grep -c "closest('$SELECTOR')" "$PROJECT_DIR/js/StateEvents.js" 2>/dev/null || echo "0")
    DIRECT=$(grep -c "querySelector.*$SELECTOR.*addEventListener" "$PROJECT_DIR/js"/*.js 2>/dev/null || echo "0")

    if [ "$GLOBAL" -gt 0 ] && [ "$DIRECT" -gt 0 ]; then
        RISK="${RED}HIGH${NC}"
        RISK_MD="🔴 HIGH"
    elif [ "$GLOBAL" -gt 0 ] || [ "$DIRECT" -gt 0 ]; then
        RISK="${GREEN}LOW${NC}"
        RISK_MD="🟢 LOW"
    else
        RISK="${CYAN}NONE${NC}"
        RISK_MD="⚪ NONE"
    fi

    echo "| \`$SELECTOR\` | $GLOBAL | $DIRECT | $RISK_MD |" >> "$OUTPUT_FILE"
done

cat >> "$OUTPUT_FILE" << 'EOF'

---

## Recommendations

### 1. Event Delegation Strategy
- ✅ **StateEvents.js** handles global delegation for list.php
- ✅ Use global delegation for common elements (status buttons, toggle buttons, etc.)
- ⚠️ Avoid adding direct listeners to elements already handled by global delegation

### 2. Code Organization
- Keep all global event delegation in **StateEvents.js**
- Document which elements are handled by global delegation
- Use comments to prevent duplicate handlers

### 3. Testing Checklist
When adding new event handlers:
1. Check if element is already handled by StateEvents.js
2. If yes, add logic to StateEvents.js instead of creating direct listener
3. If no, document why direct listener is needed
4. Test both mouse and keyboard interactions

### 4. File-Specific Patterns

**StateEvents.js:**
- Global `click` delegation for: status-button, restart-button, toggle-strip, checklist-caption
- Global `input` delegation for: all textareas

**side-panel.js:**
- Direct listeners for: checkpoint navigation buttons
- Keyboard-only listener for: toggle-strip (click handled by StateEvents)

**list-report.js:**
- Direct listeners for: filter buttons, checkpoint buttons, toggle-strip
- No global delegation (separate page)

---

## Full Event Handler List

EOF

echo -e "${CYAN}Step 6: Generating complete event handler list...${NC}"

# List all handlers by file
for FILE in "$PROJECT_DIR/js"/*.js; do
    FILENAME=$(basename "$FILE")
    HANDLER_COUNT=$(grep -c "addEventListener(" "$FILE" 2>/dev/null || echo "0")

    if [ "$HANDLER_COUNT" -gt 0 ]; then
        echo "" >> "$OUTPUT_FILE"
        echo "### $FILENAME ($HANDLER_COUNT handlers)" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
        echo '```javascript' >> "$OUTPUT_FILE"
        grep -n "addEventListener(" "$FILE" | head -20 >> "$OUTPUT_FILE"
        echo '```' >> "$OUTPUT_FILE"
    fi
done

cat >> "$OUTPUT_FILE" << 'EOF'

---

## Conclusion

This automated analysis provides a starting point for identifying event handler conflicts. Manual code review is recommended for:
- Complex event delegation patterns
- Dynamic element creation
- Third-party library integrations

**Last Updated:** $(date -u '+%Y-%m-%d %H:%M:%S UTC')

EOF

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║              Analysis Complete!                        ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}Report saved to:${NC} $OUTPUT_FILE"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "  1. Review the generated report"
echo "  2. Check HIGH RISK conflicts"
echo "  3. Update documentation for event delegation patterns"
echo ""

# Open report in default editor (optional)
if command -v open &> /dev/null; then
    read -p "Open report now? (y/N): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        open "$OUTPUT_FILE"
    fi
fi
