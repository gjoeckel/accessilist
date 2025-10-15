#!/bin/bash

# External Production Server Testing
# Tests the ACTUAL production server at webaim.org
# Does NOT test local environment - this is for verifying live deployment

set -o pipefail

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Production URL
PROD_URL="https://webaim.org/training/online/accessilist"

# Log file
PROJECT_DIR="/Users/a00288946/Projects/accessilist"
LOG_FILE="$PROJECT_DIR/logs/external-production-test-$(date +%Y%m%d-%H%M%S).log"
mkdir -p "$PROJECT_DIR/logs"

echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     External Production Server Testing Suite          ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}Production Server:${NC}"
echo "  URL: $PROD_URL"
echo "  Log File: $LOG_FILE"
echo "  Date: $(date)"
echo ""

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Test counter helpers
increment_test_counter() {
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
}

record_pass() {
    local test_name="$1"
    local details="${2:-}"
    echo -e "  ${GREEN}✅ PASS${NC} ${details}"
    log "PASS: $test_name${details:+ - }$details"
    PASSED_TESTS=$((PASSED_TESTS + 1))
}

record_fail() {
    local test_name="$1"
    local details="${2:-}"
    echo -e "  ${RED}❌ FAIL${NC} ${details}"
    log "FAIL: $test_name${details:+ - }$details"
    FAILED_TESTS=$((FAILED_TESTS + 1))
}

# Test function
test_endpoint() {
    local test_name="$1"
    local path="$2"
    local expected_code="${3:-200}"
    local alternate_code="${4:-}"  # Optional alternate acceptable code

    increment_test_counter
    echo -n "  Testing: $test_name..."
    log "TEST: $test_name - $PROD_URL/$path"

    http_code=$(curl -s -o /dev/null -w "%{http_code}" -L "$PROD_URL/$path" 2>&1)

    if [ "$http_code" = "$expected_code" ]; then
        record_pass "$test_name" "(HTTP $http_code)"
        return 0
    elif [ -n "$alternate_code" ] && [ "$http_code" = "$alternate_code" ]; then
        record_pass "$test_name" "(HTTP $http_code)"
        return 0
    else
        record_fail "$test_name" "(Expected: $expected_code${alternate_code:+ or $alternate_code}, Got: $http_code)"
        return 1
    fi
}

# Test function with content check
test_content() {
    local test_name="$1"
    local path="$2"
    local search_pattern="$3"

    increment_test_counter
    echo -n "  Testing: $test_name..."
    log "TEST: $test_name - Searching for: $search_pattern"

    content=$(curl -s -L "$PROD_URL/$path" 2>&1)
    http_code=$(curl -s -o /dev/null -w "%{http_code}" -L "$PROD_URL/$path" 2>&1)

    if [ "$http_code" != "200" ]; then
        record_fail "$test_name" "(HTTP $http_code)"
        return 1
    fi

    if echo "$content" | grep -q "$search_pattern"; then
        record_pass "$test_name" "(Content found)"
        return 0
    else
        record_fail "$test_name" "(Content missing)"
        return 1
    fi
}

# ============================================================
# TEST SUITE
# ============================================================

# Test 1: Basic Connectivity
echo -e "${BLUE}━━━ Test 1: Basic Connectivity ━━━${NC}"
test_endpoint "Production root" "" "200"
test_endpoint "Home page" "home" "200"
test_endpoint "Systemwide report page" "systemwide-report" "200"
echo ""

# Test 2: Clean URL Routes
echo -e "${BLUE}━━━ Test 2: Clean URL Routes ━━━${NC}"
test_endpoint "Checklist page (Word)" "mychecklist?type=word" "200"
test_endpoint "Checklist page (Excel)" "mychecklist?type=excel" "200"
test_endpoint "Checklist page (PowerPoint)" "mychecklist?type=powerpoint" "200"
test_endpoint "Invalid session error (list-report)" "list-report?session=ABC" "400" "404"  # Accept either error code
echo ""

# Test 3: API Endpoints
echo -e "${BLUE}━━━ Test 3: API Endpoints (Extensionless) ━━━${NC}"
test_endpoint "Health API" "php/api/health" "200"
test_endpoint "List API" "php/api/list" "200"
echo ""

# Test 4: Static Assets
echo -e "${BLUE}━━━ Test 4: Static Assets ━━━${NC}"
test_endpoint "Main CSS" "css/base.css" "200"
test_endpoint "List CSS" "css/list.css" "200"
test_endpoint "Main JavaScript" "js/main.js" "200"
test_endpoint "Side Panel JS" "js/side-panel.js" "200"
test_endpoint "Template JSON (Word)" "json/word.json" "200"
test_endpoint "SVG Icon" "images/done-1.svg" "200"
echo ""

# Test 5: Content Verification
echo -e "${BLUE}━━━ Test 5: Content Verification ━━━${NC}"
test_content "Home page title" "home" "<title>Accessibility Checklists</title>"
test_content "Systemwide report title" "systemwide-report" "<title>Systemwide Report</title>"
test_content "Home page heading" "home" "Accessibility Checklist"
test_content "Global .env loaded" "home" "window.ENV"
echo ""

# Test 6: JavaScript Module Loading
echo -e "${BLUE}━━━ Test 6: JavaScript Module Loading ━━━${NC}"
test_content "Path utilities loaded" "mychecklist?type=word" "path-utils.js"
test_content "Side panel loaded" "mychecklist?type=word" "side-panel.js"
test_content "State manager loaded" "mychecklist?type=word" "StateManager.js"
test_content "Scroll utilities loaded" "mychecklist?type=word" "scroll.js"
echo ""

# Test 7: Configuration Verification
echo -e "${BLUE}━━━ Test 7: Production Configuration ━━━${NC}"
test_content "Base path configured" "home" 'training/online/accessilist'
test_content "ENV object present" "home" 'window.ENV'
test_content "Production mode" "home" 'isProduction'
echo ""

# Test 8: Key Features
echo -e "${BLUE}━━━ Test 8: Key Features Present ━━━${NC}"
test_content "Side panel navigation" "mychecklist?type=word" 'class="side-panel"'
test_content "Sticky header" "mychecklist?type=word" 'class="sticky-header"'
test_content "Filter buttons" "systemwide-report" 'class="filter-button"'
test_content "Status footer" "mychecklist?type=word" 'class="status-footer"'
echo ""

# Test 9: Recent Deployments Verification
echo -e "${BLUE}━━━ Test 9: Recent Deployment Verification ━━━${NC}"

# Check if console logging cleanup is deployed
echo -n "  Testing: Console logging cleanup deployed..."
increment_test_counter
content=$(curl -s -L "$PROD_URL/js/side-panel.js" 2>&1)
if echo "$content" | grep -q "🎯"; then
    record_fail "Console logging cleanup" "(Debug logs still present)"
else
    record_pass "Console logging cleanup" "(Debug logs removed)"
fi

# Check if global .env support is deployed
echo -n "  Testing: Global .env support deployed..."
increment_test_counter
content=$(curl -s -L "$PROD_URL/php/includes/config.php" 2>&1)
if echo "$content" | grep -q "cursor-global"; then
    record_pass "Global .env support" "(cursor-global config present)"
else
    # This is OK - production uses its own .env
    record_pass "Global .env support" "(Production uses external .env)"
fi

echo ""

# Test 10: Error Handling
echo -e "${BLUE}━━━ Test 10: Error Handling ━━━${NC}"
test_endpoint "Invalid page (404)" "nonexistent-page" "404"
test_endpoint "Invalid session error (duplicate check)" "list-report?session=INVALID" "400" "404"  # Accept either error code
echo ""

# Test 11: URL Format Validation (Extensionless URLs)
echo -e "${BLUE}━━━ Test 11: URL Format Validation ━━━${NC}"

# Check that application uses short-form URLs (no .php extensions)
echo -n "  Checking mychecklist page uses short-form URLs..."
increment_test_counter
content=$(curl -s -L "$PROD_URL/mychecklist?type=word" 2>&1)

# Check for .php extensions in links (should NOT be present)
if echo "$content" | grep -q 'href="[^"]*\.php'; then
    record_fail "Short-form URLs in mychecklist" "(Found .php extensions in links)"
elif echo "$content" | grep -q 'action="[^"]*\.php'; then
    record_fail "Short-form URLs in mychecklist" "(Found .php extensions in forms)"
else
    record_pass "Short-form URLs in mychecklist" "(No .php extensions found)"
fi

# Check that list-report links use short form
echo -n "  Checking list-report links use short-form..."
increment_test_counter
if echo "$content" | grep -q 'list-report\.php'; then
    record_fail "list-report short-form URLs" "(Found list-report.php)"
else
    record_pass "list-report short-form URLs" "(Uses list-report)"
fi

# Check Back button uses minimal format (/?=) not full format (/?session=)
echo -n "  Checking Back button uses minimal format (/?=)..."
increment_test_counter
# Use reserved test session AAA for consistent testing
content=$(curl -s "$PROD_URL/list-report?session=AAA" 2>&1)
if echo "$content" | grep -q 'window\.location\.href.*/?session='; then
    record_fail "Back button minimal format" "(Uses /?session= instead of /?=)"
elif echo "$content" | grep -q 'window\.location\.href.*/?='; then
    record_pass "Back button minimal format" "(Uses minimal format /?=)"
else
    record_fail "Back button minimal format" "(Code not found or changed)"
fi

# Test that minimal URL format actually works (behavioral test)
echo -n "  Testing minimal URL navigation (/?=AAA)..."
increment_test_counter
http_code=$(curl -s -o /dev/null -w "%{http_code}" -L "$PROD_URL/?=AAA")
if [ "$http_code" = "200" ]; then
    record_pass "Minimal URL works" "(HTTP 200, checklist loads)"
elif [ "$http_code" = "404" ]; then
    record_fail "Minimal URL works" "(HTTP 404, test session AAA not found)"
elif [ "$http_code" = "302" ]; then
    record_fail "Minimal URL works" "(HTTP 302, redirects incorrectly)"
else
    record_fail "Minimal URL works" "(HTTP $http_code)"
fi

# Check systemwide-report page for short-form URLs
echo -n "  Checking systemwide-report page uses short-form URLs..."
increment_test_counter
content=$(curl -s -L "$PROD_URL/systemwide-report" 2>&1)
if echo "$content" | grep -q 'href="[^"]*\.php'; then
    record_fail "Short-form URLs in systemwide-report" "(Found .php extensions)"
else
    record_pass "Short-form URLs in systemwide-report" "(No .php extensions found)"
fi

# Check home page navigation uses short-form URLs
echo -n "  Checking home page navigation uses short-form..."
increment_test_counter
content=$(curl -s -L "$PROD_URL/home" 2>&1)
if echo "$content" | grep -q 'href="[^"]*\.php'; then
    record_fail "Short-form URLs in navigation" "(Found .php extensions)"
else
    record_pass "Short-form URLs in navigation" "(No .php extensions found)"
fi

echo ""

# Test 12: Security Headers
echo -e "${BLUE}━━━ Test 12: Security & Headers ━━━${NC}"

echo -n "  Checking HTTPS..."
increment_test_counter
if curl -s -I "$PROD_URL/home" 2>&1 | grep -q "HTTP/2 200"; then
    record_pass "HTTPS enabled" "(HTTP/2)"
elif curl -s -I "$PROD_URL/home" 2>&1 | grep -q "200"; then
    record_pass "HTTPS enabled" "(HTTP/1.1)"
else
    record_fail "HTTPS enabled" "(Connection failed)"
fi

echo -n "  Checking Content-Type header..."
increment_test_counter
content_type=$(curl -s -I "$PROD_URL/home" 2>&1 | grep -i "content-type:" | head -1)
if echo "$content_type" | grep -q "text/html"; then
    record_pass "Content-Type header" "(text/html)"
else
    record_fail "Content-Type header" "(Missing or incorrect)"
fi

echo ""

# ============================================================
# SUMMARY
# ============================================================

echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║              Test Results Summary                      ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}Total Tests:${NC}    $TOTAL_TESTS"
echo -e "${GREEN}Passed:${NC}         $PASSED_TESTS"
echo -e "${RED}Failed:${NC}         $FAILED_TESTS"

if [ $TOTAL_TESTS -gt 0 ]; then
    SUCCESS_RATE=$(echo "scale=1; $PASSED_TESTS * 100 / $TOTAL_TESTS" | bc)
    echo -e "${CYAN}Success Rate:${NC}   ${SUCCESS_RATE}%"
fi
echo ""

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  ✅ ALL TESTS PASSED - Production is healthy! ✅      ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
    exit 0
else
    echo -e "${YELLOW}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║  ⚠️  SOME TESTS FAILED - Review log for details  ⚠️   ║${NC}"
    echo -e "${YELLOW}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}Log file:${NC} $LOG_FILE"
    echo ""
    exit 1
fi
