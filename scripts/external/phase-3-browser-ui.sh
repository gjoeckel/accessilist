#!/bin/bash

################################################################################
# PHASE 3: BROWSER UI TESTING (Playwright)
################################################################################
#
# PURPOSE: Test actual user workflows with real browser automation
# RATIONALE: Verify users can actually USE the application
#
# USAGE: ./phase-3-browser-ui.sh <url> [browser]
#   url: Base URL to test
#   browser: chromium|firefox|webkit (default: chromium)
#
################################################################################

set -e

URL=${1:?"URL required"}
BROWSER=${2:-"chromium"}

# Source common helpers
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/test-helpers.sh" ]; then
    source "$SCRIPT_DIR/test-helpers.sh"
else
    GREEN='\033[0;32m'; BLUE='\033[0;34m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; CYAN='\033[0;36m'; NC='\033[0m'
fi

echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  PHASE 3: BROWSER UI TESTING (User Workflows)          ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}Purpose:${NC} Verify users can actually USE the application"
echo -e "${CYAN}Method:${NC} Playwright browser automation (real clicks/typing)"
echo -e "${CYAN}Browser:${NC} $BROWSER"
echo ""

# Check if Playwright is available
if ! command -v npx >/dev/null 2>&1; then
    echo -e "${RED}❌ npx not found - cannot run Playwright${NC}"
    echo -e "${YELLOW}   Install Node.js to enable browser testing${NC}"
    exit 1
fi

# Run browser test via dedicated Playwright script
if [ -f "$SCRIPT_DIR/browser-test-playwright.sh" ]; then
    "$SCRIPT_DIR/browser-test-playwright.sh" "$URL" "$BROWSER"
    exit $?
else
    echo -e "${RED}❌ Browser test script not found${NC}"
    echo -e "${YELLOW}   Expected: $SCRIPT_DIR/browser-test-playwright.sh${NC}"
    exit 1
fi

