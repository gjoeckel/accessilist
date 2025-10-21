#!/bin/bash

################################################################################
# PHASE 2: PERMISSIONS VERIFICATION
################################################################################
#
# PURPOSE: Verify file system permissions for session storage
# RATIONALE: If app can't write files, save/restore won't work
#
# USAGE: ./phase-2-permissions.sh <url> <environment>
#
################################################################################

set -o pipefail

URL=${1:?"URL required"}
ENVIRONMENT=${2:-"staging"}

# Source common helpers
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/test-helpers.sh" ]; then
    source "$SCRIPT_DIR/test-helpers.sh"
else
    GREEN='\033[0;32m'; BLUE='\033[0;34m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; CYAN='\033[0;36m'; NC='\033[0m'
    TOTAL_TESTS=0; PASSED_TESTS=0; FAILED_TESTS=0
    increment_test_counter() { TOTAL_TESTS=$((TOTAL_TESTS + 1)); }
    record_pass() { PASSED_TESTS=$((PASSED_TESTS + 1)); echo -e " ${GREEN}✅ PASS${NC} $2"; }
    record_fail() { FAILED_TESTS=$((FAILED_TESTS + 1)); echo -e " ${RED}❌ FAIL${NC} $2"; }
fi

echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  PHASE 2: PERMISSIONS (File System Access)             ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}Purpose:${NC} Verify file/directory permissions"
echo -e "${CYAN}Impact:${NC} If this fails, users cannot save/restore data"
echo ""

# Test 1: Sessions directory exists
echo -n "  Checking etc/sessions directory..."
increment_test_counter

if [ "$ENVIRONMENT" = "live" ] || [ "$ENVIRONMENT" = "staging" ]; then
    session_dir_check=$(timeout 10 ssh -i ~/.ssh/GeorgeWebAIMServerKey.pem \
        -o ConnectTimeout=5 \
        -o StrictHostKeyChecking=no \
        george@ec2-3-20-59-76.us-east-2.compute.amazonaws.com \
        "[ -d /var/websites/webaim/htdocs/training/online/etc/sessions ] && echo 'exists' || echo 'missing'" 2>&1)

    if echo "$session_dir_check" | grep -q "exists"; then
        record_pass "Sessions directory" "(exists)"
    else
        record_fail "Sessions directory" "(missing)"
    fi

    # Test 2: Sessions directory writable
    echo -n "  Checking write permissions..."
    increment_test_counter
    perm_check=$(timeout 10 ssh -i ~/.ssh/GeorgeWebAIMServerKey.pem \
        -o ConnectTimeout=5 \
        -o StrictHostKeyChecking=no \
        george@ec2-3-20-59-76.us-east-2.compute.amazonaws.com \
        "[ -w /var/websites/webaim/htdocs/training/online/etc/sessions ] && echo 'writable' || echo 'not-writable'" 2>&1)

    if echo "$perm_check" | grep -q "writable"; then
        record_pass "Write permissions" "(www-data can write)"
    else
        record_fail "Write permissions" "(no write access)"
    fi
else
    echo -e "  ${YELLOW}⊘ SKIPPED${NC} (Local environment)"
fi

echo ""

# Summary
echo -e "${CYAN}Phase 2 Summary:${NC} $PASSED_TESTS/$TOTAL_TESTS passed"
echo ""

# Export results
echo "PHASE2_TOTAL=$TOTAL_TESTS"
echo "PHASE2_PASSED=$PASSED_TESTS"
echo "PHASE2_FAILED=$FAILED_TESTS"

exit $FAILED_TESTS
