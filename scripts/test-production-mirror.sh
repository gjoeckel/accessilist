#!/bin/bash

# Comprehensive Production-Mirror Testing Suite
# Tests local Apache configured to mirror production server conditions
#
# Production Server Specs:
# - Apache 2.4.52
# - PHP 8.1
# - mod_rewrite enabled
# - Base path: /training/online/accessilist
# - Clean URLs enabled
# - Save/restore functionality
# - API endpoints (extensionless)

set -e

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

# Project directory
PROJECT_DIR="/Users/a00288946/Desktop/accessilist"
BASE_URL="http://localhost/training/online/accessilist"

# Log file
LOG_FILE="$PROJECT_DIR/logs/test-production-mirror-$(date +%Y%m%d-%H%M%S).log"
mkdir -p "$PROJECT_DIR/logs"

echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Production-Mirror Comprehensive Testing Suite        ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}Test Environment:${NC}"
echo "  Base URL: $BASE_URL"
echo "  Log File: $LOG_FILE"
echo "  Date: $(date)"
echo ""

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Test function
test_endpoint() {
    local test_name="$1"
    local url="$2"
    local expected_code="${3:-200}"
    local description="$4"

    TOTAL_TESTS=$((TOTAL_TESTS + 1))

    echo -n "  Testing: $test_name..."
    log "TEST: $test_name - $url"

    http_code=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>&1)

    if [ "$http_code" = "$expected_code" ]; then
        echo -e " ${GREEN}✅ PASS${NC} (HTTP $http_code)"
        log "PASS: $test_name - HTTP $http_code"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        return 0
    else
        echo -e " ${RED}❌ FAIL${NC} (Expected: $expected_code, Got: $http_code)"
        log "FAIL: $test_name - Expected $expected_code, Got $http_code"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        return 1
    fi
}

# Test function with content check
test_endpoint_content() {
    local test_name="$1"
    local url="$2"
    local search_string="$3"
    local description="$4"

    TOTAL_TESTS=$((TOTAL_TESTS + 1))

    echo -n "  Testing: $test_name..."
    log "TEST: $test_name - $url (checking for: $search_string)"

    response=$(curl -s "$url" 2>&1)
    http_code=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>&1)

    if [ "$http_code" = "200" ] && echo "$response" | grep -q "$search_string"; then
        echo -e " ${GREEN}✅ PASS${NC} (Found: $search_string)"
        log "PASS: $test_name - Found content"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        return 0
    else
        echo -e " ${RED}❌ FAIL${NC} (HTTP $http_code, Content missing)"
        log "FAIL: $test_name - HTTP $http_code or content not found"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        return 1
    fi
}

# Section header
print_section() {
    echo ""
    echo -e "${BLUE}━━━ $1 ━━━${NC}"
}

# Check prerequisites
print_section "Prerequisites Check"
log "=== Prerequisites Check ==="

echo -n "  Checking Apache..."
if sudo apachectl -k status &> /dev/null; then
    echo -e " ${GREEN}✅ Running${NC}"
    log "Apache: Running"
else
    echo -e " ${RED}❌ Not running${NC}"
    echo -e "${YELLOW}Starting Apache...${NC}"
    sudo apachectl start
    sleep 2
fi

echo -n "  Checking PHP module..."
if apachectl -M 2>/dev/null | grep -q "php"; then
    PHP_VERSION=$(php -v | head -n 1 | awk '{print $2}')
    echo -e " ${GREEN}✅ $PHP_VERSION${NC}"
    log "PHP: $PHP_VERSION"
else
    echo -e " ${YELLOW}⚠️  Not detected${NC}"
    log "PHP: Not detected"
fi

echo -n "  Checking mod_rewrite..."
if apachectl -M 2>/dev/null | grep -q "rewrite_module"; then
    echo -e " ${GREEN}✅ Enabled${NC}"
    log "mod_rewrite: Enabled"
else
    echo -e " ${RED}❌ Disabled${NC}"
    log "mod_rewrite: Disabled"
    exit 1
fi

echo -n "  Checking .env configuration..."
if [ -f "$PROJECT_DIR/.env" ]; then
    APP_ENV=$(grep "^APP_ENV=" "$PROJECT_DIR/.env" | cut -d'=' -f2)
    echo -e " ${GREEN}✅ $APP_ENV${NC}"
    log "Environment: $APP_ENV"
else
    echo -e " ${RED}❌ Missing${NC}"
    log "Environment: Missing .env"
    exit 1
fi

echo -n "  Checking .htaccess..."
if [ -f "$PROJECT_DIR/.htaccess" ]; then
    echo -e " ${GREEN}✅ Present${NC}"
    log ".htaccess: Present"
else
    echo -e " ${RED}❌ Missing${NC}"
    log ".htaccess: Missing"
    exit 1
fi

# Test 1: Basic Connectivity
print_section "Test 1: Basic Connectivity"
log "=== Test 1: Basic Connectivity ==="

test_endpoint "Root redirect" "$BASE_URL/" "302" "Should redirect to /home"
test_endpoint "Index.php" "$BASE_URL/index.php" "302" "Should redirect"

# Test 2: Clean URL Routes
print_section "Test 2: Clean URL Routes (Production-style)"
log "=== Test 2: Clean URL Routes ==="

test_endpoint "/home clean URL" "$BASE_URL/home" "200" "Home page via clean URL"
# COMMENTED: admin.php deprecated/unused - keeping for potential future refactoring
# test_endpoint "/admin clean URL" "$BASE_URL/admin" "200" "Admin page via clean URL"
test_endpoint "/reports clean URL" "$BASE_URL/reports" "200" "Reports page via clean URL"
# REMOVED: checklist-report.php deleted - replaced by report.php
# test_endpoint "/checklist-report clean URL" "$BASE_URL/checklist-report" "200" "Checklist report page"

# Test 3: Direct PHP Access
print_section "Test 3: Direct PHP File Access"
log "=== Test 3: Direct PHP Access ==="

test_endpoint "Direct /php/home.php" "$BASE_URL/php/home.php" "200" "Direct PHP access"
# COMMENTED: admin.php deprecated/unused - keeping for potential future refactoring
# test_endpoint "Direct /php/admin.php" "$BASE_URL/php/admin.php" "200" "Direct PHP access"
test_endpoint "Direct /php/reports.php" "$BASE_URL/php/reports.php" "200" "Direct PHP access"

# Test 4: API Endpoints (Extensionless)
print_section "Test 4: API Endpoints (Production-style extensionless)"
log "=== Test 4: API Endpoints ==="

test_endpoint "API health (extensionless)" "$BASE_URL/php/api/health" "200" "Health check"
test_endpoint "API list (extensionless)" "$BASE_URL/php/api/list" "200" "List sessions"

# Test 5: API Endpoints (With extension - should also work)
print_section "Test 5: API Endpoints (With .php extension)"
log "=== Test 5: API Endpoints with extension ==="

test_endpoint "API health.php" "$BASE_URL/php/api/health.php" "200" "Health check with extension"
test_endpoint "API list.php" "$BASE_URL/php/api/list.php" "200" "List with extension"

# Test 6: Static Assets
print_section "Test 6: Static Assets"
log "=== Test 6: Static Assets ==="

test_endpoint "CSS file" "$BASE_URL/css/base.css" "200" "CSS loading"
test_endpoint "JavaScript file" "$BASE_URL/js/main.js" "200" "JS loading"
test_endpoint "Image file" "$BASE_URL/images/home0.svg" "200" "Image loading"
test_endpoint "JSON template" "$BASE_URL/json/word.json" "200" "JSON template loading"

# Test 7: Content Verification
print_section "Test 7: Content Verification"
log "=== Test 7: Content Verification ==="

test_endpoint_content "Home page content" "$BASE_URL/home" "Accessibility Checklists" "Home page has correct title"
# COMMENTED: admin.php deprecated/unused - keeping for potential future refactoring
# test_endpoint_content "Admin page content" "$BASE_URL/admin" "Admin" "Admin page has correct content"
test_endpoint_content "Reports page content" "$BASE_URL/reports" "Reports" "Reports page has correct content"

# Test 8: Save/Restore API Workflow
print_section "Test 8: Save/Restore API Workflow"
log "=== Test 8: Save/Restore API ==="

# Generate a test session key
TEST_KEY="TST$(date +%s | tail -c 4)"
echo "  Using test session key: $TEST_KEY"

# Test instantiate
INSTANTIATE_RESPONSE=$(curl -s -X POST "$BASE_URL/php/api/instantiate" \
    -H "Content-Type: application/json" \
    -d "{\"session\":\"$TEST_KEY\",\"type\":\"word\"}" 2>&1)

if echo "$INSTANTIATE_RESPONSE" | grep -q "success"; then
    echo -e "  Instantiate API: ${GREEN}✅ PASS${NC}"
    PASSED_TESTS=$((PASSED_TESTS + 1))
    log "PASS: Instantiate API"
else
    echo -e "  Instantiate API: ${RED}❌ FAIL${NC}"
    FAILED_TESTS=$((FAILED_TESTS + 1))
    log "FAIL: Instantiate API"
fi
TOTAL_TESTS=$((TOTAL_TESTS + 1))

# Test save with correct data format
SAVE_DATA='{
    "sessionKey":"'$TEST_KEY'",
    "timestamp":'$(date +%s)'000,
    "typeSlug":"word",
    "state":{
        "sidePanel":{"expanded":true,"activeSection":"checklist-1"},
        "notes":{"textarea-1.1":"Test content from production-mirror tests"},
        "statusButtons":{"status-1.1":"in-progress"},
        "restartButtons":{"restart-1.1":false},
        "principleRows":{"checklist-1":[],"checklist-2":[],"checklist-3":[],"checklist-4":[]}
    },
    "metadata":{
        "version":"1.0",
        "created":'$(date +%s)'000,
        "lastModified":'$(date +%s)'000
    }
}'

SAVE_RESPONSE=$(curl -s -X POST "$BASE_URL/php/api/save" \
    -H "Content-Type: application/json" \
    -d "$SAVE_DATA" 2>&1)

if echo "$SAVE_RESPONSE" | grep -q '"success":true'; then
    echo -e "  Save API: ${GREEN}✅ PASS${NC}"
    PASSED_TESTS=$((PASSED_TESTS + 1))
    log "PASS: Save API"
else
    echo -e "  Save API: ${RED}❌ FAIL${NC}"
    FAILED_TESTS=$((FAILED_TESTS + 1))
    log "FAIL: Save API - Response: $SAVE_RESPONSE"
fi
TOTAL_TESTS=$((TOTAL_TESTS + 1))

# Verify file was created
if [ -f "$PROJECT_DIR/saves/$TEST_KEY.json" ]; then
    echo "  ✓ Session file created successfully"
else
    echo "  ✗ Session file not created"
fi

# Test restore
RESTORE_RESPONSE=$(curl -s "$BASE_URL/php/api/restore?sessionKey=$TEST_KEY" 2>&1)

if echo "$RESTORE_RESPONSE" | grep -q "Test content from production-mirror tests"; then
    echo -e "  Restore API: ${GREEN}✅ PASS${NC}"
    PASSED_TESTS=$((PASSED_TESTS + 1))
    log "PASS: Restore API"
else
    echo -e "  Restore API: ${RED}❌ FAIL${NC}"
    FAILED_TESTS=$((FAILED_TESTS + 1))
    log "FAIL: Restore API - Response: $RESTORE_RESPONSE"
fi
TOTAL_TESTS=$((TOTAL_TESTS + 1))

# Cleanup test session
if [ -f "$PROJECT_DIR/saves/$TEST_KEY.json" ]; then
    rm "$PROJECT_DIR/saves/$TEST_KEY.json"
    echo "  Cleaned up test session file"
fi

# Test 9: Minimal URL Format
print_section "Test 9: Minimal URL Parameter Tracking"
log "=== Test 9: Minimal URLs ==="

# Test minimal URL with a session that actually exists
# Create a minimal test session first
TEST_MIN_KEY="MIN"
echo "{\"sessionKey\":\"$TEST_MIN_KEY\",\"timestamp\":$(date +%s)000,\"typeSlug\":\"word\",\"state\":{\"sidePanel\":{\"expanded\":true},\"notes\":{},\"statusButtons\":{},\"restartButtons\":{},\"principleRows\":{}},\"metadata\":{\"version\":\"1.0\"}}" > "$PROJECT_DIR/saves/$TEST_MIN_KEY.json"

# Now test the minimal URL
test_endpoint "Minimal URL format (/?=MIN)" "$BASE_URL/?=MIN" "200" "Minimal URL parameter routing"

# Cleanup
rm -f "$PROJECT_DIR/saves/$TEST_MIN_KEY.json"

# Test 10: Error Handling
print_section "Test 10: Error Handling"
log "=== Test 10: Error Handling ==="

test_endpoint "404 for missing page" "$BASE_URL/nonexistent" "404" "Should return 404"
test_endpoint "404 for missing file" "$BASE_URL/nonexistent.php" "404" "Should return 404"

# Test 11: Security Headers
print_section "Test 11: Security & Headers"
log "=== Test 11: Security Headers ==="

HEADERS=$(curl -sI "$BASE_URL/home" 2>&1)

echo -n "  Checking Cache-Control header..."
if echo "$HEADERS" | grep -qi "Cache-Control"; then
    echo -e " ${GREEN}✅ Present${NC}"
    log "Cache-Control: Present"
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    echo -e " ${YELLOW}⚠️  Missing${NC}"
    log "Cache-Control: Missing"
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi
TOTAL_TESTS=$((TOTAL_TESTS + 1))

echo -n "  Checking Content-Type header..."
if echo "$HEADERS" | grep -qi "Content-Type"; then
    echo -e " ${GREEN}✅ Present${NC}"
    log "Content-Type: Present"
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    echo -e " ${YELLOW}⚠️  Missing${NC}"
    log "Content-Type: Missing"
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi
TOTAL_TESTS=$((TOTAL_TESTS + 1))

# Test 12: Production Base Path Verification
print_section "Test 12: Production Base Path Configuration"
log "=== Test 12: Production Base Path ==="

echo -n "  Verifying base path in HTML..."
HOME_HTML=$(curl -s "$BASE_URL/home" 2>&1)

if echo "$HOME_HTML" | grep -q "/training/online/accessilist"; then
    echo -e " ${GREEN}✅ PASS${NC} (Base path correctly set)"
    log "Base path: Correctly configured"
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    echo -e " ${RED}❌ FAIL${NC} (Base path not found in HTML)"
    log "Base path: Not found in HTML"
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi
TOTAL_TESTS=$((TOTAL_TESTS + 1))

echo -n "  Verifying JS path configuration..."
if echo "$HOME_HTML" | grep -q "window.ENV"; then
    echo -e " ${GREEN}✅ PASS${NC} (ENV config injected)"
    log "JS ENV: Injected correctly"
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    echo -e " ${RED}❌ FAIL${NC} (ENV config missing)"
    log "JS ENV: Missing"
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi
TOTAL_TESTS=$((TOTAL_TESTS + 1))

# Test 13-20: Reports Dashboard (reports.php)
print_section "Test 13-20: Reports Dashboard (reports.php)"
log "=== Test 13-20: Reports Dashboard ==="

test_endpoint_content "Reports page structure" "$BASE_URL/reports" "Systemwide Reports" "Reports heading present"
test_endpoint "List-detailed API endpoint" "$BASE_URL/php/api/list-detailed" "200" "Reports API functional"
test_endpoint_content "Reports filter buttons" "$BASE_URL/reports" "filter-button" "Filter buttons present"
test_endpoint_content "Reports table headers" "$BASE_URL/reports" "reports-status-cell" "Table structure correct"
test_endpoint_content "Reports table headers" "$BASE_URL/reports" "reports-progress-cell" "Progress column present"
test_endpoint_content "Reports refresh button" "$BASE_URL/reports" "id=\"refreshButton\"" "Refresh button present"
test_endpoint_content "Reports home button" "$BASE_URL/reports" "id=\"homeButton\"" "Home button present"
test_endpoint_content "Reports JavaScript module" "$BASE_URL/reports" "js/systemwide-report.js" "ReportsManager loaded"

# Test 21-27: User Report (report.php)
print_section "Test 21-27: User Report (report.php)"
log "=== Test 21-27: User Report ==="

# Create temporary test session for report.php tests
TEST_REPORT_KEY="MIN"
TEST_REPORT_DATA='{
  "sessionKey": "'$TEST_REPORT_KEY'",
  "timestamp": '$(date +%s)'000,
  "typeSlug": "word",
  "state": {
    "sidePanel": {"expanded": true, "activeSection": "checklist-1"},
    "notes": {
      "textarea-1.1": "Test note 1",
      "textarea-1.2": "Test note 2"
    },
    "statusButtons": {
      "status-1.1": "completed",
      "status-1.2": "in-progress",
      "status-1.3": "pending"
    },
    "restartButtons": {
      "restart-1.1": true,
      "restart-1.2": false,
      "restart-1.3": false
    },
    "principleRows": {
      "checklist-1": [],
      "checklist-2": [],
      "checklist-3": [],
      "checklist-4": []
    }
  },
  "metadata": {
    "version": "1.0",
    "created": '$(date +%s)'000,
    "lastModified": '$(date +%s)'000
  }
}'

echo "$TEST_REPORT_DATA" > "$PROJECT_DIR/saves/$TEST_REPORT_KEY.json"
echo "  Created test session: $TEST_REPORT_KEY.json"

# Test valid session
test_endpoint "Report with valid session" "$BASE_URL/report?session=$TEST_REPORT_KEY" "200" "User report loads"
test_endpoint_content "Report page structure" "$BASE_URL/report?session=$TEST_REPORT_KEY" "<h1>Report</h1>" "Report heading present"
test_endpoint "Report missing session param" "$BASE_URL/report" "400" "Missing session error"
test_endpoint "Report invalid session format" "$BASE_URL/report?session=INVALID@#$" "400" "Invalid session format error"
test_endpoint "Report non-existent session" "$BASE_URL/report?session=XYZ" "404" "Session not found error"
test_endpoint_content "Report table structure" "$BASE_URL/report?session=$TEST_REPORT_KEY" "checkpoint-cell" "Table has checkpoint column"
test_endpoint_content "Report filter buttons" "$BASE_URL/report?session=$TEST_REPORT_KEY" "filter-button" "Filter buttons present"

# Cleanup test session
rm -f "$PROJECT_DIR/saves/$TEST_REPORT_KEY.json"
echo "  Cleaned up test session: $TEST_REPORT_KEY.json"

# Final Summary
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║              Test Results Summary                      ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

log "=== Test Summary ==="
log "Total: $TOTAL_TESTS, Passed: $PASSED_TESTS, Failed: $FAILED_TESTS"

echo -e "${CYAN}Total Tests:${NC}    $TOTAL_TESTS"
echo -e "${GREEN}Passed:${NC}         $PASSED_TESTS"
echo -e "${RED}Failed:${NC}         $FAILED_TESTS"

if [ $FAILED_TESTS -eq 0 ]; then
    SUCCESS_RATE="100"
else
    SUCCESS_RATE=$(awk "BEGIN {printf \"%.1f\", ($PASSED_TESTS/$TOTAL_TESTS)*100}")
fi

echo -e "${CYAN}Success Rate:${NC}   ${SUCCESS_RATE}%"
echo ""

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  ✅ ALL TESTS PASSED! Production mirror verified! ✅  ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
    log "RESULT: ALL TESTS PASSED"
    exit 0
else
    echo -e "${YELLOW}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║  ⚠️  SOME TESTS FAILED - Review log for details  ⚠️   ║${NC}"
    echo -e "${YELLOW}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}Log file:${NC} $LOG_FILE"
    log "RESULT: $FAILED_TESTS TESTS FAILED"
    exit 1
fi

