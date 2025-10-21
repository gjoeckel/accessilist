#!/bin/bash

################################################################################
# TEST ORCHESTRATOR - External Production/Staging Testing
################################################################################
#
# PURPOSE: Orchestrate all test phases in correct order with failure handling
#
# USAGE: ./test-orchestrator.sh [live|staging]
#   - live:    Tests https://webaim.org/training/online/accessilist
#   - staging: Tests https://webaim.org/training/online/accessilist2 (default)
#
# PHASES (New Order - CSRF/Rate Limiting First):
#   Phase 1: Programmatic Tests (API, CSRF, Rate Limiting, Security)
#   Phase 2: Permissions (File/Directory access)
#   Phase 3: Browser UI Testing (Playwright - real user workflows)
#
################################################################################

set -o pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

# Environment argument
ENVIRONMENT=${1:-staging}

if [ "$ENVIRONMENT" != "live" ] && [ "$ENVIRONMENT" != "staging" ]; then
    echo -e "${RED}❌ Invalid environment: $ENVIRONMENT${NC}"
    echo "Usage: $0 [live|staging]"
    exit 1
fi

# Set URL based on environment
if [ "$ENVIRONMENT" = "live" ]; then
    TEST_URL="https://webaim.org/training/online/accessilist"
    ENV_NAME="LIVE Production (accessilist)"
    ENV_LABEL="⚠️  LIVE PRODUCTION"
else
    TEST_URL="https://webaim.org/training/online/accessilist2"
    ENV_NAME="TEST Staging (accessilist2)"
    ENV_LABEL="🧪 STAGING (accessilist2)"
fi

# Log file
LOG_FILE="$PROJECT_DIR/logs/external-test-$ENVIRONMENT-$(date +%Y%m%d-%H%M%S).log"
mkdir -p "$PROJECT_DIR/logs"

# Display banner
echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   External Production Testing Orchestrator            ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}$ENV_LABEL${NC}"
echo -e "${CYAN}Environment:${NC} $ENV_NAME"
echo -e "${CYAN}URL:${NC} $TEST_URL"
echo -e "${CYAN}Log:${NC} $LOG_FILE"
echo -e "${CYAN}Date:${NC} $(date)"
echo ""

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

log "=== Starting $ENV_NAME Tests ==="

# Initialize totals
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

################################################################################
# PHASE 1: PROGRAMMATIC TESTS (API, CSRF, Rate Limiting, Security)
################################################################################

echo -e "${YELLOW}Running Phase 1: Programmatic Tests...${NC}"
echo ""

PHASE1_OUTPUT=$("$SCRIPT_DIR/phase-1-programmatic.sh" "$TEST_URL" "$ENVIRONMENT" 2>&1)
PHASE1_EXIT=$?

echo "$PHASE1_OUTPUT"
echo "$PHASE1_OUTPUT" >> "$LOG_FILE"

# Extract phase results
PHASE1_TOTAL=$(echo "$PHASE1_OUTPUT" | grep "PHASE1_TOTAL=" | cut -d= -f2)
PHASE1_PASSED=$(echo "$PHASE1_OUTPUT" | grep "PHASE1_PASSED=" | cut -d= -f2)
PHASE1_FAILED=$(echo "$PHASE1_OUTPUT" | grep "PHASE1_FAILED=" | cut -d= -f2)

TOTAL_TESTS=$((TOTAL_TESTS + PHASE1_TOTAL))
PASSED_TESTS=$((PASSED_TESTS + PHASE1_PASSED))
FAILED_TESTS=$((FAILED_TESTS + PHASE1_FAILED))

if [ $PHASE1_EXIT -ne 0 ]; then
    echo -e "${RED}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║  ❌ PHASE 1 FAILED - CSRF/Security Issues Detected    ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Critical issues with CSRF protection or rate limiting.${NC}"
    echo -e "${YELLOW}These must be fixed before continuing.${NC}"
    echo ""

    # Run diagnostic analysis
    if [ -f "$SCRIPT_DIR/diagnose-test-failures.sh" ]; then
        "$SCRIPT_DIR/diagnose-test-failures.sh" "$LOG_FILE" "$ENVIRONMENT" "Phase 1" "CSRF/Security"
    fi

    exit 1
fi

echo -e "${GREEN}✅ PHASE 1 PASSED${NC}"
echo ""

################################################################################
# PHASE 2: PERMISSIONS
################################################################################

echo -e "${YELLOW}Running Phase 2: Permissions Check...${NC}"
echo ""

PHASE2_OUTPUT=$("$SCRIPT_DIR/phase-2-permissions.sh" "$TEST_URL" "$ENVIRONMENT" 2>&1)
PHASE2_EXIT=$?

echo "$PHASE2_OUTPUT"
echo "$PHASE2_OUTPUT" >> "$LOG_FILE"

# Extract phase results
PHASE2_TOTAL=$(echo "$PHASE2_OUTPUT" | grep "PHASE2_TOTAL=" | cut -d= -f2)
PHASE2_PASSED=$(echo "$PHASE2_OUTPUT" | grep "PHASE2_PASSED=" | cut -d= -f2)
PHASE2_FAILED=$(echo "$PHASE2_OUTPUT" | grep "PHASE2_FAILED=" | cut -d= -f2)

TOTAL_TESTS=$((TOTAL_TESTS + PHASE2_TOTAL))
PASSED_TESTS=$((PASSED_TESTS + PHASE2_PASSED))
FAILED_TESTS=$((FAILED_TESTS + PHASE2_FAILED))

if [ $PHASE2_EXIT -ne 0 ]; then
    echo -e "${RED}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║  ❌ PHASE 2 FAILED - Permission Issues Detected       ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Cannot write to sessions directory.${NC}"
    echo -e "${YELLOW}Users cannot save or restore data.${NC}"
    echo ""

    if [ -f "$SCRIPT_DIR/diagnose-test-failures.sh" ]; then
        "$SCRIPT_DIR/diagnose-test-failures.sh" "$LOG_FILE" "$ENVIRONMENT" "Phase 2" "Permissions"
    fi

    exit 1
fi

echo -e "${GREEN}✅ PHASE 2 PASSED${NC}"
echo ""

################################################################################
# PHASE 3: BROWSER UI TESTING
################################################################################

echo -e "${YELLOW}Running Phase 3: Browser UI Testing...${NC}"
echo ""

PHASE3_OUTPUT=$("$SCRIPT_DIR/phase-3-browser-ui.sh" "$TEST_URL" "chromium" 2>&1)
PHASE3_EXIT=$?

echo "$PHASE3_OUTPUT"
echo "$PHASE3_OUTPUT" >> "$LOG_FILE"

# Browser test has its own pass/fail counting
if [ $PHASE3_EXIT -eq 0 ]; then
    echo -e "${GREEN}✅ PHASE 3 PASSED - Browser UI tests successful${NC}"
    PASSED_TESTS=$((PASSED_TESTS + 10))  # Browser test runs ~10 tests
    TOTAL_TESTS=$((TOTAL_TESTS + 10))
else
    echo -e "${RED}❌ PHASE 3 FAILED - Browser UI tests failed${NC}"
    FAILED_TESTS=$((FAILED_TESTS + 1))
    TOTAL_TESTS=$((TOTAL_TESTS + 10))

    if [ -f "$SCRIPT_DIR/diagnose-test-failures.sh" ]; then
        "$SCRIPT_DIR/diagnose-test-failures.sh" "$LOG_FILE" "$ENVIRONMENT" "Phase 3" "Browser UI"
    fi

    exit 1
fi

echo ""

################################################################################
# FINAL SUMMARY
################################################################################

echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║              Test Results Summary                      ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}Environment:${NC} $ENV_NAME"
echo -e "${CYAN}Total Tests:${NC} $TOTAL_TESTS"
echo -e "${GREEN}Passed:${NC}      $PASSED_TESTS"
echo -e "${RED}Failed:${NC}      $FAILED_TESTS"
echo -e "${CYAN}Success Rate:${NC} $(echo "scale=1; ($PASSED_TESTS * 100) / $TOTAL_TESTS" | bc)%"
echo ""

log "=== Test Complete: $PASSED_TESTS/$TOTAL_TESTS passed ==="

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  ✅ ALL TESTS PASSED! $ENV_NAME verified! ✅  ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
    exit 0
else
    echo -e "${YELLOW}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║  ⚠️  SOME TESTS FAILED - Review details above  ⚠️     ║${NC}"
    echo -e "${YELLOW}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}Log file:${NC} $LOG_FILE"
    exit 1
fi
