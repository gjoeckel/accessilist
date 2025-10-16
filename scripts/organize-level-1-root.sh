#!/usr/local/bin/bash
# Level 1: Root Directory Analysis (REPORT ONLY)
# Reviews all root files and generates comprehensive reports
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
COMPREHENSIVE_REPORT="$REPORT_DIR/root-level-comprehensive-$TIMESTAMP.md"
CONCISE_REPORT="$REPORT_DIR/root-level-concise-$TIMESTAMP.txt"
ACTIONS_FILE="$REPORT_DIR/root-level-actions-$TIMESTAMP.json"
LATEST_LINK="$REPORT_DIR/root-level-latest.json"

mkdir -p "$REPORT_DIR"

echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Level 1: Root Directory Organization Analysis        ║${NC}"
echo -e "${BLUE}║  (REPORT ONLY - No Changes Made)                       ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# ========================================
# CATEGORIZATION RULES (Best Practices)
# ========================================

# Core files that MUST stay in root
CORE_FILES=(
    "README.md" "LICENSE" "LICENSE.txt" "CHANGELOG.md" "changelog.md"
    "CONTRIBUTING.md" ".gitignore" ".gitattributes" "package.json"
    "package-lock.json" "composer.json" "composer.lock" "Gemfile"
    "Gemfile.lock" "requirements.txt" "Pipfile" "pyproject.toml"
    "Dockerfile" "docker-compose.yml" "Makefile" ".env.example"
    "workflows.md" "tsconfig.json" "jest.config.js" "webpack.config.js"
    "vite.config.js" "config.json" "index.php" "router.php" "jest.config.srd.js"
)

# Patterns that should be organized
declare -A MOVE_PATTERNS=(
    ["*-COMPLETE.md"]="docs/status-reports"
    ["*-REQUIRED.md"]="docs/status-reports"
    ["*-SUCCESS.md"]="docs/status-reports"
    ["*-IMPLEMENTATION*.md"]="docs/implementation"
    ["*-MIGRATION*.md"]="docs/implementation"
    ["WORKFLOW-*.md"]="docs/workflows"
    ["*-ANALYSIS*.md"]="docs/analysis"
    ["*-RESEARCH*.md"]="docs/analysis"
    ["SESSION-SUMMARY*.md"]="docs/sessions"
    ["*-REPORT*.md"]="docs/reports"
    ["console-*.md"]="docs/development"
    ["*.log"]="DELETE"
    ["*.bak"]="DELETE"
    ["*.tmp"]="DELETE"
    ["*~"]="DELETE"
)

# ========================================
# ANALYZE ROOT FILES
# ========================================

echo -e "${CYAN}🔍 Analyzing root directory files...${NC}"
echo ""

declare -A KEEP_FILES
declare -A MOVE_FILES
declare -A DELETE_FILES

# Get all files in root (not directories)
while IFS= read -r -d '' file; do
    filename=$(basename "$file")

    # Skip hidden files except important ones
    if [[ $filename == .* ]] && [[ ! " ${CORE_FILES[@]} " =~ " ${filename} " ]]; then
        continue
    fi

    # Check if core file
    if [[ " ${CORE_FILES[@]} " =~ " ${filename} " ]]; then
        KEEP_FILES["$filename"]="Core project file (required)"
        continue
    fi

    # Check move patterns
    moved=false
    for pattern in "${!MOVE_PATTERNS[@]}"; do
        if [[ $filename == $pattern ]]; then
            destination="${MOVE_PATTERNS[$pattern]}"
            if [[ $destination == "DELETE" ]]; then
                DELETE_FILES["$filename"]="Temporary/backup file"
            else
                MOVE_FILES["$filename"]="$destination"
            fi
            moved=true
            break
        fi
    done

    # If no pattern matched, analyze by extension and content
    if [ "$moved" = false ]; then
        case "$filename" in
            *.md)
                # Markdown files - analyze content/purpose
                if grep -qi "status\|complete\|summary" "$file" 2>/dev/null; then
                    MOVE_FILES["$filename"]="docs/status-reports/"
                else
                    MOVE_FILES["$filename"]="docs/"
                fi
                ;;
            *.txt)
                MOVE_FILES["$filename"]="docs/development/"
                ;;
            *.sh)
                MOVE_FILES["$filename"]="scripts/"
                ;;
            *.json)
                if [[ $filename == *"config"* ]]; then
                    KEEP_FILES["$filename"]="Configuration file"
                else
                    MOVE_FILES["$filename"]="data/"
                fi
                ;;
            *.php|*.js|*.css|*.html)
                MOVE_FILES["$filename"]="src/"
                ;;
            *)
                MOVE_FILES["$filename"]="docs/review-needed/"
                ;;
        esac
    fi

done < <(find . -maxdepth 1 -type f -print0)

# ========================================
# GENERATE COMPREHENSIVE REPORT
# ========================================

{
echo "# Level 1: Root Directory Organization Analysis"
echo ""
echo "**Generated**: $(date)"
echo "**Project**: $(basename "$PROJECT_DIR")"
echo "**Total Root Files Analyzed**: $((${#KEEP_FILES[@]} + ${#MOVE_FILES[@]} + ${#DELETE_FILES[@]}))"
echo ""
echo "---"
echo ""
echo "## 📊 Analysis Summary"
echo ""
echo "| Category | Count | Action |"
echo "|----------|-------|--------|"
echo "| ✅ Keep in Root | ${#KEEP_FILES[@]} | No action needed |"
echo "| 📦 Move to Folders | ${#MOVE_FILES[@]} | Organize into structure |"
echo "| 🗑️  Delete | ${#DELETE_FILES[@]} | Remove temporary files |"
echo ""
echo "---"
echo ""
echo "## ✅ Files to Keep in Root (${#KEEP_FILES[@]} files)"
echo ""
echo "**These are core project files that should remain in the root directory:**"
echo ""

for file in "${!KEEP_FILES[@]}"; do
    reason="${KEEP_FILES[$file]}"
    echo "- \`$file\` - $reason"
done | sort

echo ""
echo "---"
echo ""
echo "## 📦 Files to Move (${#MOVE_FILES[@]} files)"
echo ""
echo "**These files should be organized into appropriate directories:**"
echo ""

# Group by destination
declare -A destinations
for file in "${!MOVE_FILES[@]}"; do
    dest="${MOVE_FILES[$file]}"
    if [[ -z "${destinations[$dest]}" ]]; then
        destinations[$dest]="$file"
    else
        destinations[$dest]="${destinations[$dest]}|$file"
    fi
done

for dest in $(printf '%s\n' "${!destinations[@]}" | sort); do
    echo "### → \`$dest\`"
    echo ""
    IFS='|' read -ra files <<< "${destinations[$dest]}"
    for file in "${files[@]}"; do
        echo "- \`$file\`"
    done | sort
    echo ""
done

echo "---"
echo ""
echo "## 🗑️  Files to Delete (${#DELETE_FILES[@]} files)"
echo ""
echo "**These are temporary or backup files that can be safely removed:**"
echo ""

for file in "${!DELETE_FILES[@]}"; do
    reason="${DELETE_FILES[$file]}"
    echo "- \`$file\` - $reason"
done | sort

echo ""
echo "---"
echo ""
echo "## ⚠️  IMPORTANT: Next Steps"
echo ""
echo "This is a REPORT ONLY. No changes have been made."
echo ""
echo "To apply these changes, run:"
echo "\`\`\`bash"
echo "proj-organize-level-1-apply"
echo "\`\`\`"
echo ""
echo "Or review and apply manually."
echo ""
echo "---"
echo ""
echo "_Generated by: organize-level-1-root.sh_"
echo "_Status: Analysis complete, awaiting approval_"

} > "$COMPREHENSIVE_REPORT"

# ========================================
# GENERATE CONCISE REPORT
# ========================================

{
echo "╔════════════════════════════════════════════════════════╗"
echo "║     Level 1: Root Directory Analysis - Summary        ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
echo "📊 Analysis Complete: $(date)"
echo ""
echo "Total Files Analyzed: $((${#KEEP_FILES[@]} + ${#MOVE_FILES[@]} + ${#DELETE_FILES[@]}))"
echo ""
echo "✅ Keep in Root:        ${#KEEP_FILES[@]} files"
echo "📦 Move to Folders:     ${#MOVE_FILES[@]} files"
echo "🗑️  Delete:             ${#DELETE_FILES[@]} files"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📦 Files to Move (ALL ${#MOVE_FILES[@]} files):"

# Show ALL files grouped by destination
for dest in $(printf '%s\n' "${!destinations[@]}" | sort); do
    echo ""
    echo "→ $dest:"
    IFS='|' read -ra files <<< "${destinations[$dest]}"
    for file in "${files[@]}"; do
        echo "   $file"
    done | sort
done

echo ""
echo "🗑️  Files to Delete:"
if [ ${#DELETE_FILES[@]} -eq 0 ]; then
    echo "   (none)"
else
    for file in "${!DELETE_FILES[@]}"; do
        echo "   $file"
    done
fi

echo ""
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
echo "  \"level\": 1,"
echo "  \"summary\": {"
echo "    \"total_files\": $((${#KEEP_FILES[@]} + ${#MOVE_FILES[@]} + ${#DELETE_FILES[@]})),"
echo "    \"keep\": ${#KEEP_FILES[@]},"
echo "    \"move\": ${#MOVE_FILES[@]},"
echo "    \"delete\": ${#DELETE_FILES[@]}"
echo "  },"
echo "  \"actions\": {"
echo "    \"keep\": ["

first=true
for file in $(printf '%s\n' "${!KEEP_FILES[@]}" | sort); do
    if [ "$first" = true ]; then
        first=false
    else
        echo ","
    fi
    reason="${KEEP_FILES[$file]}"
    echo -n "      {\"file\": \"$file\", \"reason\": \"$reason\"}"
done

echo ""
echo "    ],"
echo "    \"move\": ["

first=true
for file in $(printf '%s\n' "${!MOVE_FILES[@]}" | sort); do
    if [ "$first" = true ]; then
        first=false
    else
        echo ","
    fi
    dest="${MOVE_FILES[$file]}"
    echo -n "      {\"file\": \"$file\", \"destination\": \"$dest\"}"
done

echo ""
echo "    ],"
echo "    \"delete\": ["

first=true
for file in $(printf '%s\n' "${!DELETE_FILES[@]}" | sort); do
    if [ "$first" = true ]; then
        first=false
    else
        echo ","
    fi
    reason="${DELETE_FILES[$file]}"
    echo -n "      {\"file\": \"$file\", \"reason\": \"$reason\"}"
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
echo -e "   ${YELLOW}proj-level-1-apply${NC}"
echo ""
echo -e "${CYAN}Cursor will ask for your approval before making any changes.${NC}"
echo ""
