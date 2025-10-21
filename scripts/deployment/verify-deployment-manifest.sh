#!/bin/bash
# ============================================================================
# Verify Deployment Manifest
# ============================================================================
# Purpose: Verify all 89 production files exist locally before deployment
# Reference: DEVELOPER/CORE2.md
# ============================================================================

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Production Manifest Verification                     ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if we're in project root
if [ ! -f "index.php" ] || [ ! -f ".htaccess" ]; then
    echo -e "${RED}❌ Must run from project root directory${NC}"
    exit 1
fi

# Verify deployment files exist
echo -e "${BLUE}📋 Checking deployment infrastructure...${NC}"

if [ -f ".deployignore" ]; then
    echo -e "${GREEN}✅ Method 1: .deployignore found${NC}"
else
    echo -e "${YELLOW}⚠️  Method 1: .deployignore missing${NC}"
fi

if [ -f "scripts/deployment/upload-production-files.sh" ]; then
    echo -e "${GREEN}✅ Method 2: upload-production-files.sh found${NC}"
else
    echo -e "${RED}❌ Method 2: upload-production-files.sh missing${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}📦 Verifying production files (89 total)...${NC}"
echo ""

# Create array of all production files
declare -a PRODUCTION_FILES=(
    # Root (2 files)
    "index.php"
    ".htaccess"

    # Config (1 file)
    "config/checklist-types.json"

    # PHP Pages (6 files)
    "php/index.php"
    "php/home.php"
    "php/list.php"
    "php/list-report.php"
    "php/systemwide-report.php"
    "php/aeit.php"

    # PHP API (8 files)
    "php/api/save.php"
    "php/api/restore.php"
    "php/api/list.php"
    "php/api/list-detailed.php"
    "php/api/delete.php"
    "php/api/instantiate.php"
    "php/api/generate-key.php"
    "php/api/health.php"

    # PHP Includes (9 files)
    "php/includes/config.php"
    "php/includes/api-utils.php"
    "php/includes/html-head.php"
    "php/includes/footer.php"
    "php/includes/noscript.php"
    "php/includes/common-scripts.php"
    "php/includes/session-utils.php"
    "php/includes/type-manager.php"
    "php/includes/type-formatter.php"

    # JavaScript (20 files)
    "js/main.js"
    "js/StateManager.js"
    "js/StateEvents.js"
    "js/StatusManager.js"
    "js/buildCheckpoints.js"
    "js/buildDemo.js"
    "js/addRow.js"
    "js/simple-modal.js"
    "js/ModalActions.js"
    "js/side-panel.js"
    "js/scroll.js"
    "js/path-utils.js"
    "js/simple-path-config.js"
    "js/type-manager.js"
    "js/date-utils.js"
    "js/list-report.js"
    "js/systemwide-report.js"
    "js/ui-components.js"
    "js/debug-utils.js"
    "js/postcss.config.js"

    # CSS (16 files)
    "css/base.css"
    "css/header.css"
    "css/footer.css"
    "css/landing.css"
    "css/list.css"
    "css/list-report.css"
    "css/reports.css"
    "css/systemwide-report.css"
    "css/simple-modal.css"
    "css/form-elements.css"
    "css/table.css"
    "css/scroll.css"
    "css/focus.css"
    "css/loading.css"
    "css/demo-inline-icons.css"
    "css/aeit.css"

    # Images (15 files)
    "images/active-1.svg"
    "images/done.svg"
    "images/done-1.svg"
    "images/ready-1.svg"
    "images/add-plus.svg"
    "images/delete.svg"
    "images/reset.svg"
    "images/info-.svg"
    "images/show-all.svg"
    "images/show-all-1.svg"
    "images/show-all-2.svg"
    "images/show-one.svg"
    "images/show-one-1.svg"
    "images/show-one-2.svg"
    "images/cc-icons.svg"

    # JSON (11 files)
    "json/demo.json"
    "json/word.json"
    "json/powerpoint.json"
    "json/excel.json"
    "json/docs.json"
    "json/slides.json"
    "json/camtasia.json"
    "json/dojo.json"
    "json/test-5.json"
    "json/test-7.json"
    "json/test-10-checkpoints.json"

    # Sessions - NOTE: No longer deploying sessions/.htaccess
    # Sessions now stored in etc/sessions (outside web root) - no .htaccess needed
)

# Verify each file
MISSING_COUNT=0
FOUND_COUNT=0
declare -a MISSING_FILES=()

for file in "${PRODUCTION_FILES[@]}"; do
    if [ -f "$file" ]; then
        FOUND_COUNT=$((FOUND_COUNT + 1))
    else
        echo -e "${RED}❌ Missing: $file${NC}"
        MISSING_FILES+=("$file")
        MISSING_COUNT=$((MISSING_COUNT + 1))
    fi
done

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}📊 Verification Results${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "   Files Found:   ${GREEN}$FOUND_COUNT${NC} / 89"
echo -e "   Files Missing: $([ $MISSING_COUNT -eq 0 ] && echo -e ${GREEN} || echo -e ${RED})$MISSING_COUNT${NC}"
echo ""

# Check sessions directory (can be real directory or symlink to etc/sessions)
SESSIONS_EXISTS=0
if [ -d "sessions" ] || [ -L "sessions" ]; then
    if [ -L "sessions" ]; then
        echo -e "${GREEN}✅ sessions/ symlink exists (points to etc/sessions - secure)${NC}"
    else
        echo -e "${YELLOW}⚠️  sessions/ is a real directory (consider migrating to etc/sessions)${NC}"
    fi
    SESSIONS_EXISTS=1
else
    echo -e "${YELLOW}⚠️  sessions/ directory missing (will be created in etc/ on deployment)${NC}"
fi

TOTAL_FOUND=$((FOUND_COUNT + SESSIONS_EXISTS))
echo ""
echo -e "   ${BLUE}Total Production Items:${NC} ${GREEN}$TOTAL_FOUND${NC} / 90 (89 files + 1 directory)"

echo ""

# Total production items: 89 files + 1 directory (sessions/)
EXPECTED_FILE_COUNT=89
TOTAL_ITEMS=90  # includes sessions/ directory

if [ $MISSING_COUNT -eq 0 ] && [ $FOUND_COUNT -eq $EXPECTED_FILE_COUNT ] && [ $SESSIONS_EXISTS -eq 1 ]; then
    echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  ✅ ALL PRODUCTION FILES VERIFIED                     ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BLUE}🚀 Ready for deployment!${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Run tests: proj-test-mirror"
    echo "  2. Deploy: proj-push-deploy-github"
    echo ""
    exit 0
elif [ $FOUND_COUNT -ne $EXPECTED_FILE_COUNT ] || [ $TOTAL_FOUND -ne $TOTAL_ITEMS ]; then
    echo -e "${YELLOW}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║  ⚠️  FILE COUNT MISMATCH                              ║${NC}"
    echo -e "${YELLOW}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Expected $EXPECTED_FILE_COUNT files + 1 directory = $TOTAL_ITEMS items${NC}"
    echo -e "${YELLOW}Found $FOUND_COUNT files + $SESSIONS_EXISTS directory = $TOTAL_FOUND items${NC}"
    echo -e "${YELLOW}This may indicate the manifest needs updating${NC}"
    echo ""

    if [ ${#MISSING_FILES[@]} -gt 0 ]; then
        echo -e "${RED}Missing files:${NC}"
        for mf in "${MISSING_FILES[@]}"; do
            echo -e "  - ${RED}$mf${NC}"
        done
        echo ""
    fi

    exit 1
else
    echo -e "${RED}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║  ❌ MANIFEST VERIFICATION FAILED                      ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${RED}Cannot proceed with deployment - missing files detected:${NC}"
    for mf in "${MISSING_FILES[@]}"; do
        echo -e "  - ${RED}$mf${NC}"
    done
    echo ""
    exit 1
fi
