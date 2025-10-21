#!/bin/bash

################################################################################
# PHASE 1: PROGRAMMATIC TESTING (API, CSRF, Rate Limiting, Security)
################################################################################
#
# PURPOSE: Test API endpoints, security headers, CSRF, and rate limiting
# RATIONALE: Catch CSRF/rate limiting issues FIRST (recurring problems)
#
# USAGE: ./phase-1-programmatic.sh <url> <environment>
#
################################################################################

set -o pipefail

URL=${1:?"URL required"}
ENVIRONMENT=${2:-"staging"}

# Source common test helpers if available
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/test-helpers.sh" ]; then
    source "$SCRIPT_DIR/test-helpers.sh"
else
    # Minimal inline helpers
    GREEN='\033[0;32m'; BLUE='\033[0;34m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; CYAN='\033[0;36m'; NC='\033[0m'
    TOTAL_TESTS=0; PASSED_TESTS=0; FAILED_TESTS=0
    increment_test_counter() { TOTAL_TESTS=$((TOTAL_TESTS + 1)); }
    record_pass() { PASSED_TESTS=$((PASSED_TESTS + 1)); echo -e " ${GREEN}✅ PASS${NC} $2"; }
    record_fail() { FAILED_TESTS=$((FAILED_TESTS + 1)); echo -e " ${RED}❌ FAIL${NC} $2"; }
fi

echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  PHASE 1: PROGRAMMATIC TESTS (API/CSRF/Security)       ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}Purpose:${NC} Catch CSRF/rate limiting issues early (recurring problems)"
echo -e "${CYAN}Method:${NC} API calls, header checks, security scans"
echo -e "${CYAN}Impact:${NC} If CSRF/rate limiting broken, nothing else will work"
echo ""

# Test 1: Basic Connectivity
echo -e "${BLUE}━━━ Test 1: Basic Connectivity ━━━${NC}"
echo -n "  Testing: Home page... "
increment_test_counter
http_code=$(curl -s -o /dev/null -w "%{http_code}" "$URL/home")
if [ "$http_code" = "200" ]; then
    record_pass "Home page" "(HTTP 200)"
else
    record_fail "Home page" "(HTTP $http_code)"
fi

echo -n "  Testing: Systemwide report... "
increment_test_counter
http_code=$(curl -s -o /dev/null -w "%{http_code}" "$URL/systemwide-report")
if [ "$http_code" = "200" ]; then
    record_pass "Systemwide report" "(HTTP 200)"
else
    record_fail "Systemwide report" "(HTTP $http_code)"
fi

echo ""

# Test 2: CSRF Protection (CRITICAL - Test Early!)
echo -e "${BLUE}━━━ Test 2: CSRF Protection (CRITICAL!) ━━━${NC}"

echo -n "  Checking CSRF token in page..."
increment_test_counter
page_content=$(curl -s -L "$URL/home" 2>&1)
if echo "$page_content" | grep -q 'name="csrf-token"'; then
    record_pass "CSRF meta tag" "(Token found)"
else
    record_fail "CSRF meta tag" "(Missing!)"
fi

echo -n "  Checking csrf-utils.js loaded..."
increment_test_counter
if echo "$page_content" | grep -q 'csrf-utils.js'; then
    record_pass "CSRF utilities" "(Loaded)"
else
    record_fail "CSRF utilities" "(Missing!)"
fi

echo -n "  Testing CSRF blocks unauthenticated POST..."
increment_test_counter
csrf_response=$(curl -s -w "\n%{http_code}" -X POST "$URL/php/api/instantiate" \
    -H "Content-Type: application/json" \
    -d '{"sessionKey":"TST","typeSlug":"word"}' 2>&1)
http_code=$(echo "$csrf_response" | tail -n1)
if [ "$http_code" = "403" ] || [ "$http_code" = "429" ]; then
    record_pass "CSRF protection" "($http_code - blocked correctly)"
else
    record_fail "CSRF protection" "(Expected 403/429, got $http_code)"
fi

echo ""

# Test 3: Rate Limiting (CRITICAL - Test Early!)
echo -e "${BLUE}━━━ Test 3: Rate Limiting (CRITICAL!) ━━━${NC}"

echo -n "  Checking rate limiter not exposed..."
increment_test_counter
rl_check=$(curl -s -I "$URL/php/includes/rate-limiter.php" 2>&1)
if echo "$rl_check" | grep -qE "403|404"; then
    record_pass "Rate limiter protected" "(PHP includes secured)"
else
    record_fail "Rate limiter protected" "(May be exposed!)"
fi

echo ""

# Test 4: API Endpoints
echo -e "${BLUE}━━━ Test 4: API Endpoints ━━━${NC}"

echo -n "  Testing: Health API... "
increment_test_counter
health_response=$(curl -s "$URL/php/api/health" 2>&1)
if echo "$health_response" | grep -q '"status"'; then
    record_pass "Health API" "(Responding)"
else
    record_fail "Health API" "(Not responding)"
fi

echo -n "  Testing: List API... "
increment_test_counter
list_response=$(curl -s "$URL/php/api/list" 2>&1)
if echo "$list_response" | grep -q '\['; then
    record_pass "List API" "(Responding)"
else
    record_fail "List API" "(Not responding)"
fi

echo ""

# Test 5: Security Headers
echo -e "${BLUE}━━━ Test 5: Security Headers ━━━${NC}"

headers=$(curl -s -I "$URL/home" 2>&1)

echo -n "  X-Frame-Options..."
increment_test_counter
if echo "$headers" | grep -qi "X-Frame-Options.*DENY"; then
    record_pass "X-Frame-Options" "(DENY)"
else
    record_fail "X-Frame-Options" "(Missing)"
fi

echo -n "  X-Content-Type-Options..."
increment_test_counter
if echo "$headers" | grep -qi "X-Content-Type-Options.*nosniff"; then
    record_pass "X-Content-Type-Options" "(nosniff)"
else
    record_fail "X-Content-Type-Options" "(Missing)"
fi

echo -n "  Content-Security-Policy..."
increment_test_counter
if echo "$headers" | grep -qi "Content-Security-Policy"; then
    record_pass "CSP" "(Enabled)"
else
    record_fail "CSP" "(Missing)"
fi

echo -n "  Strict-Transport-Security..."
increment_test_counter
if echo "$headers" | grep -qi "Strict-Transport-Security"; then
    record_pass "HSTS" "(Enabled)"
else
    record_fail "HSTS" "(Missing)"
fi

echo ""

# Test 6: Static Assets
echo -e "${BLUE}━━━ Test 6: Static Assets ━━━${NC}"

echo -n "  CSS files... "
increment_test_counter
http_code=$(curl -s -o /dev/null -w "%{http_code}" "$URL/css/base.css")
if [ "$http_code" = "200" ]; then
    record_pass "CSS" "(Loading)"
else
    record_fail "CSS" "(HTTP $http_code)"
fi

echo -n "  JavaScript files... "
increment_test_counter
http_code=$(curl -s -o /dev/null -w "%{http_code}" "$URL/js/main.js")
if [ "$http_code" = "200" ]; then
    record_pass "JavaScript" "(Loading)"
else
    record_fail "JavaScript" "(HTTP $http_code)"
fi

echo -n "  JSON templates... "
increment_test_counter
http_code=$(curl -s -o /dev/null -w "%{http_code}" "$URL/json/word.json")
if [ "$http_code" = "200" ]; then
    record_pass "JSON templates" "(Loading)"
else
    record_fail "JSON templates" "(HTTP $http_code)"
fi

echo ""

# Summary for Phase 1
echo -e "${CYAN}Phase 1 Summary:${NC} $PASSED_TESTS/$TOTAL_TESTS passed"
echo ""

# Export results for orchestrator
echo "PHASE1_TOTAL=$TOTAL_TESTS"
echo "PHASE1_PASSED=$PASSED_TESTS"
echo "PHASE1_FAILED=$FAILED_TESTS"

exit $FAILED_TESTS
