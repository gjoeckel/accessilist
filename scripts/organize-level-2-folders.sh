#!/usr/local/bin/bash
# Level 2: Folder Organization Analysis (REPORT ONLY)
# Reviews all project folders and identifies consolidation opportunities
# NO CHANGES MADE - analysis only

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
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
COMPREHENSIVE_REPORT="$REPORT_DIR/folder-level-comprehensive-$TIMESTAMP.md"
CONCISE_REPORT="$REPORT_DIR/folder-level-concise-$TIMESTAMP.txt"
ACTIONS_FILE="$REPORT_DIR/folder-level-actions-$TIMESTAMP.json"
LATEST_LINK="$REPORT_DIR/folder-level-latest.json"

mkdir -p "$REPORT_DIR"

echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Level 2: Folder Organization Analysis                ║${NC}"
echo -e "${BLUE}║  (REPORT ONLY - No Changes Made)                       ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# ========================================
# FOLDER CATEGORIZATION RULES
# ========================================

# Folders to keep as-is (core structure)
KEEP_FOLDERS=(
    "src" "tests" "test" "scripts" "docs" "config" "public" "dist" "build"
    "node_modules" ".git" ".github" "vendor" "css" "js" "images" "assets"
    "php" "json" "data" "logs" "sessions" "saves"
)

# ========================================
# ANALYZE FOLDERS
# ========================================

echo -e "${CYAN}🔍 Analyzing project folders...${NC}"
echo ""

declare -A KEEP_FOLDER_MAP
declare -A CONSOLIDATE_MAP
declare -A UNUSUAL_MAP
declare -A EMPTY_FOLDERS

# Analyze each directory
while IFS= read -r -d '' dir; do
    dirname=$(basename "$dir")

    # Skip hidden directories except important ones
    if [[ $dirname == .* ]] && [[ $dirname != ".github" ]]; then
        continue
    fi

    # Check if empty
    if [ -z "$(ls -A "$dir" 2>/dev/null)" ]; then
        EMPTY_FOLDERS["$dirname"]="Empty directory"
        continue
    fi

    # Check if it's a keep folder
    if [[ " ${KEEP_FOLDERS[@]} " =~ " ${dirname} " ]]; then
        file_count=$(find "$dir" -type f 2>/dev/null | wc -l | tr -d ' ')
        KEEP_FOLDER_MAP["$dirname"]="Core project folder ($file_count files)"
        continue
    fi

    # Identify issues
    case "$dirname" in
        backups|backup)
            CONSOLIDATE_MAP["$dirname"]="Consolidate → archive/backups/"
            ;;
        cleanup-archive)
            CONSOLIDATE_MAP["$dirname"]="Consolidate → archive/cleanup/"
            ;;
        _notes)
            CONSOLIDATE_MAP["$dirname"]="Move → docs/notes/"
            ;;
        ~)
            UNUSUAL_MAP["$dirname"]="Unusual directory (shouldn't exist in project root)"
            ;;
        old|deprecated|archive-old)
            CONSOLIDATE_MAP["$dirname"]="Consolidate → archive/"
            ;;
        archive)
            file_count=$(find "$dir" -type f 2>/dev/null | wc -l | tr -d ' ')
            KEEP_FOLDER_MAP["$dirname"]="Archive folder ($file_count files) - review contents periodically"
            ;;
        *)
            file_count=$(find "$dir" -type f 2>/dev/null | wc -l | tr -d ' ')
            UNUSUAL_MAP["$dirname"]="Uncommon folder ($file_count files) - manual review recommended"
            ;;
    esac

done < <(find . -maxdepth 1 -type d ! -path . -print0)

# ========================================
# GENERATE COMPREHENSIVE REPORT
# ========================================

{
echo "# Level 2: Folder Organization Analysis"
echo ""
echo "**Generated**: $(date)"
echo "**Project**: $(basename "$PROJECT_DIR")"
echo "**Folders Analyzed**: $((${#KEEP_FOLDER_MAP[@]} + ${#CONSOLIDATE_MAP[@]} + ${#UNUSUAL_MAP[@]} + ${#EMPTY_FOLDERS[@]}))"
echo ""
echo "---"
echo ""
echo "## 📊 Analysis Summary"
echo ""
echo "| Category | Count | Action |"
echo "|----------|-------|--------|"
echo "| ✅ Keep Structure | ${#KEEP_FOLDER_MAP[@]} | Well-organized |"
echo "| 🔄 Consolidate | ${#CONSOLIDATE_MAP[@]} | Merge into archives |"
echo "| ⚠️ Unusual/Review | ${#UNUSUAL_MAP[@]} | Manual review needed |"
echo "| 📭 Empty | ${#EMPTY_FOLDERS[@]} | Consider removal |"
echo ""
echo "---"
echo ""
echo "## ✅ Folders to Keep (${#KEEP_FOLDER_MAP[@]} folders)"
echo ""

for folder in $(printf '%s\n' "${!KEEP_FOLDER_MAP[@]}" | sort); do
    reason="${KEEP_FOLDER_MAP[$folder]}"
    echo "- \`$folder/\` - $reason"
done

echo ""
echo "---"
echo ""
echo "## 🔄 Folders to Consolidate (${#CONSOLIDATE_MAP[@]} folders)"
echo ""

for folder in $(printf '%s\n' "${!CONSOLIDATE_MAP[@]}" | sort); do
    action="${CONSOLIDATE_MAP[$folder]}"
    echo "- \`$folder/\` → $action"
done

echo ""
echo "---"
echo ""
echo "## ⚠️ Unusual/Review Folders (${#UNUSUAL_MAP[@]} folders)"
echo ""

for folder in $(printf '%s\n' "${!UNUSUAL_MAP[@]}" | sort); do
    note="${UNUSUAL_MAP[$folder]}"
    echo "- \`$folder/\` - $note"
done

echo ""
echo "---"
echo ""
echo "## 📭 Empty Folders (${#EMPTY_FOLDERS[@]} folders)"
echo ""

if [ ${#EMPTY_FOLDERS[@]} -eq 0 ]; then
    echo "✅ No empty folders found"
else
    for folder in $(printf '%s\n' "${!EMPTY_FOLDERS[@]}" | sort); do
        echo "- \`$folder/\`"
    done
fi

echo ""
echo "---"
echo ""
echo "## ⚠️ IMPORTANT: Next Steps"
echo ""
echo "This is a REPORT ONLY. No changes have been made."
echo ""
echo "To apply these changes, run:"
echo "\`\`\`bash"
echo "proj-level-2-apply"
echo "\`\`\`"
echo ""
echo "---"
echo ""
echo "_Generated by: organize-level-2-folders.sh_"
echo "_Status: Analysis complete, awaiting approval_"

} > "$COMPREHENSIVE_REPORT"

# ========================================
# GENERATE CONCISE REPORT
# ========================================

{
echo "╔════════════════════════════════════════════════════════╗"
echo "║     Level 2: Folder Analysis - Summary                ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
echo "📊 Analysis Complete: $(date)"
echo ""
echo "Folders Analyzed: $((${#KEEP_FOLDER_MAP[@]} + ${#CONSOLIDATE_MAP[@]} + ${#UNUSUAL_MAP[@]} + ${#EMPTY_FOLDERS[@]}))"
echo ""
echo "✅ Keep Structure:      ${#KEEP_FOLDER_MAP[@]} folders"
echo "🔄 Consolidate:         ${#CONSOLIDATE_MAP[@]} folders"
echo "⚠️  Unusual/Review:      ${#UNUSUAL_MAP[@]} folders"
echo "📭 Empty:               ${#EMPTY_FOLDERS[@]} folders"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ ${#CONSOLIDATE_MAP[@]} -gt 0 ]; then
    echo "🔄 Folders to Consolidate:"
    for folder in $(printf '%s\n' "${!CONSOLIDATE_MAP[@]}" | sort); do
        action="${CONSOLIDATE_MAP[$folder]}"
        echo "   $folder/ → $action"
    done
    echo ""
fi

if [ ${#UNUSUAL_MAP[@]} -gt 0 ]; then
    echo "⚠️  Unusual Folders Found:"
    for folder in $(printf '%s\n' "${!UNUSUAL_MAP[@]}" | sort); do
        note="${UNUSUAL_MAP[$folder]}"
        echo "   $folder/ - $note"
    done
    echo ""
fi

if [ ${#EMPTY_FOLDERS[@]} -gt 0 ]; then
    echo "📭 Empty Folders:"
    for folder in $(printf '%s\n' "${!EMPTY_FOLDERS[@]}" | sort); do
        echo "   $folder/"
    done
    echo ""
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📄 Full Report: $COMPREHENSIVE_REPORT"
echo ""
echo "⚠️  REVIEW COMPLETE LIST ABOVE"
echo ""
echo "You will be asked to approve applying these changes."
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

} > "$CONCISE_REPORT"

# ========================================
# GENERATE ACTIONS JSON
# ========================================

{
echo "{"
echo "  \"generated\": \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\","
echo "  \"level\": 2,"
echo "  \"summary\": {"
echo "    \"keep\": ${#KEEP_FOLDER_MAP[@]},"
echo "    \"consolidate\": ${#CONSOLIDATE_MAP[@]},"
echo "    \"unusual\": ${#UNUSUAL_MAP[@]},"
echo "    \"empty\": ${#EMPTY_FOLDERS[@]}"
echo "  },"
echo "  \"actions\": {"
echo "    \"consolidate\": ["

first=true
for folder in $(printf '%s\n' "${!CONSOLIDATE_MAP[@]}" | sort); do
    if [ "$first" = true ]; then
        first=false
    else
        echo ","
    fi
    action="${CONSOLIDATE_MAP[$folder]}"
    echo -n "      {\"folder\": \"$folder\", \"action\": \"$action\"}"
done

echo ""
echo "    ],"
echo "    \"unusual\": ["

first=true
for folder in $(printf '%s\n' "${!UNUSUAL_MAP[@]}" | sort); do
    if [ "$first" = true ]; then
        first=false
    else
        echo ","
    fi
    note="${UNUSUAL_MAP[$folder]}"
    echo -n "      {\"folder\": \"$folder\", \"note\": \"$note\"}"
done

echo ""
echo "    ],"
echo "    \"empty\": ["

first=true
for folder in $(printf '%s\n' "${!EMPTY_FOLDERS[@]}" | sort); do
    if [ "$first" = true ]; then
        first=false
    else
        echo ","
    fi
    echo -n "      {\"folder\": \"$folder\"}"
done

echo ""
echo "    ]"
echo "  }"
echo "}"

} > "$ACTIONS_FILE"

# Create symlink to latest
ln -sf "$(basename "$ACTIONS_FILE")" "$LATEST_LINK"

# ========================================
# DISPLAY RESULTS
# ========================================

cat "$CONCISE_REPORT"

echo ""
echo -e "${GREEN}📄 Reports Generated:${NC}"
echo -e "   Comprehensive: ${BLUE}$COMPREHENSIVE_REPORT${NC}"
echo -e "   Concise:       ${BLUE}$CONCISE_REPORT${NC}"
echo -e "   Actions JSON:  ${BLUE}$ACTIONS_FILE${NC}"
echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}✅ Analysis complete - NO CHANGES MADE${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${GREEN}To apply these changes, type in Cursor Chat:${NC}"
echo -e "   ${YELLOW}proj-level-2-apply${NC}"
echo ""
echo -e "${CYAN}Cursor will ask for your approval before making any changes.${NC}"
echo ""
