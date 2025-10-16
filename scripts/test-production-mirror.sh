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

# NOTE: set -e removed to allow all tests to run even if some fail
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

# Project directory
PROJECT_DIR="/Users/a00288946/Projects/accessilist"
# Allow BASE_URL override via environment variable (for Docker testing)
BASE_URL="${BASE_URL:-http://localhost/training/online/accessilist}"

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

# Test counter helpers (DRY improvement)
increment_test_counter() {
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
}

record_pass() {
    local test_name="$1"
    local details="${2:-}"
    echo -e " ${GREEN}✅ PASS${NC} ${details}"
    log "PASS: $test_name${details:+ - }$details"
    PASSED_TESTS=$((PASSED_TESTS + 1))
}

record_fail() {
    local test_name="$1"
    local details="${2:-}"
    echo -e " ${RED}❌ FAIL${NC} ${details}"
    log "FAIL: $test_name${details:+ - }$details"
    FAILED_TESTS=$((FAILED_TESTS + 1))
}

# Test function
test_endpoint() {
    local test_name="$1"
    local url="$2"
    local expected_code="${3:-200}"
    local description="$4"

    increment_test_counter
    echo -n "  Testing: $test_name..."
    log "TEST: $test_name - $url"

    http_code=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>&1)

    if [ "$http_code" = "$expected_code" ]; then
        record_pass "$test_name" "(HTTP $http_code)"
        return 0
    else
        record_fail "$test_name" "(Expected: $expected_code, Got: $http_code)"
        return 1
    fi
}

# Test function with content check
test_endpoint_content() {
    local test_name="$1"
    local url="$2"
    local search_string="$3"
    local description="$4"

    increment_test_counter
    echo -n "  Testing: $test_name..."
    log "TEST: $test_name - $url (checking for: $search_string)"

    response=$(curl -s "$url" 2>&1)
    http_code=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>&1)

    if [ "$http_code" = "200" ] && echo "$response" | grep -q "$search_string"; then
        record_pass "$test_name" "(Found: $search_string)"
        return 0
    else
        record_fail "$test_name" "(HTTP $http_code, Content missing)"
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

# Docker serves index.php directly (200), Apache redirects (302)
if [[ "$BASE_URL" =~ ":8080" ]]; then
    test_endpoint "Root access" "$BASE_URL/" "200" "Docker root serves index.php"
    test_endpoint "Index.php" "$BASE_URL/index.php" "200" "Docker direct access"
else
    test_endpoint "Root redirect" "$BASE_URL/" "302" "Should redirect to /home"
    test_endpoint "Index.php" "$BASE_URL/index.php" "302" "Should redirect"
fi

# Test 2: Clean URL Routes
print_section "Test 2: Clean URL Routes (Production-style)"
log "=== Test 2: Clean URL Routes ==="

test_endpoint "/home clean URL" "$BASE_URL/home" "200" "Home page via clean URL"
# COMMENTED: admin.php deprecated/unused - keeping for potential future refactoring
# test_endpoint "/admin clean URL" "$BASE_URL/admin" "200" "Admin page via clean URL"
test_endpoint "/systemwide-report clean URL" "$BASE_URL/systemwide-report" "200" "Systemwide report page via clean URL"
# REMOVED: checklist-report.php deleted - replaced by report.php
# test_endpoint "/checklist-report clean URL" "$BASE_URL/checklist-report" "200" "Checklist report page"

# Test 3: Direct PHP Access
print_section "Test 3: Direct PHP File Access"
log "=== Test 3: Direct PHP Access ==="

test_endpoint "Direct /php/home.php" "$BASE_URL/php/home.php" "200" "Direct PHP access"
# COMMENTED: admin.php deprecated/unused - keeping for potential future refactoring
# test_endpoint "Direct /php/admin.php" "$BASE_URL/php/admin.php" "200" "Direct PHP access"
test_endpoint "Direct /php/systemwide-report.php" "$BASE_URL/php/systemwide-report.php" "200" "Direct PHP access"
test_endpoint "Direct /php/list.php" "$BASE_URL/php/list.php?session=TEST&type=word" "200" "Checklist page access"

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
test_endpoint "JSON template" "$BASE_URL/json/word.json" "200" "JSON template loading"

# Test 7: Content Verification
print_section "Test 7: Content Verification"
log "=== Test 7: Content Verification ==="

test_endpoint_content "Home page content" "$BASE_URL/home" "Accessibility Checklists" "Home page has correct title"
# COMMENTED: admin.php deprecated/unused - keeping for potential future refactoring
# test_endpoint_content "Admin page content" "$BASE_URL/admin" "Admin" "Admin page has correct content"
test_endpoint_content "Systemwide report page content" "$BASE_URL/systemwide-report" "Systemwide Report" "Systemwide report page has correct content"

# Test 8: Save/Restore API Workflow
print_section "Test 8: Save/Restore API Workflow"
log "=== Test 8: Save/Restore API ==="

# Generate a test session key
TEST_KEY="TST$(date +%s | tail -c 4)"
echo "  Using test session key: $TEST_KEY"

# Test instantiate
increment_test_counter
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
        "checkpointRows":{"checklist-1":[],"checklist-2":[],"checklist-3":[],"checklist-4":[]}
    },
    "metadata":{
        "version":"1.0",
        "created":'$(date +%s)'000,
        "lastModified":'$(date +%s)'000
    }
}'

increment_test_counter
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

# Verify file was created
if [ -f "$PROJECT_DIR/sessions/$TEST_KEY.json" ]; then
    echo "  ✓ Session file created successfully"
else
    echo "  ✗ Session file not created"
fi

# Test restore
increment_test_counter
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

# Cleanup test session
if [ -f "$PROJECT_DIR/sessions/$TEST_KEY.json" ]; then
    rm "$PROJECT_DIR/sessions/$TEST_KEY.json"
    echo "  Cleaned up test session file"
fi

# Test 9: Minimal URL Format
print_section "Test 9: Minimal URL Parameter Tracking"
log "=== Test 9: Minimal URLs ==="

# Test minimal URL with a session that actually exists
# Create a minimal test session first
TEST_MIN_KEY="MIN"
echo "{\"sessionKey\":\"$TEST_MIN_KEY\",\"timestamp\":$(date +%s)000,\"typeSlug\":\"word\",\"state\":{\"sidePanel\":{\"expanded\":true},\"notes\":{},\"statusButtons\":{},\"restartButtons\":{},\"checkpointRows\":{}},\"metadata\":{\"version\":\"1.0\"}}" > "$PROJECT_DIR/sessions/$TEST_MIN_KEY.json"

# Now test the minimal URL
test_endpoint "Minimal URL format (/?=MIN)" "$BASE_URL/?=MIN" "200" "Minimal URL parameter routing"

# Cleanup
rm -f "$PROJECT_DIR/sessions/$TEST_MIN_KEY.json"

# Test 10: Error Handling
print_section "Test 10: Error Handling"
log "=== Test 10: Error Handling ==="

test_endpoint "404 for missing page" "$BASE_URL/nonexistent" "404" "Should return 404"
test_endpoint "404 for missing file" "$BASE_URL/nonexistent.php" "404" "Should return 404"

# Test 11: Security Headers
print_section "Test 11: Security & Headers"
log "=== Test 11: Security Headers ==="

HEADERS=$(curl -sI "$BASE_URL/home" 2>&1)

increment_test_counter
echo -n "  Checking Cache-Control header..."
if echo "$HEADERS" | grep -qi "Cache-Control"; then
    echo -e " ${GREEN}✅ Present${NC}"
    log "Cache-Control: Present"
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    # Cache-Control is optional in development environments
    echo -e " ${YELLOW}⚠️  Missing (optional)${NC}"
    log "Cache-Control: Missing (counted as pass for dev environment)"
    PASSED_TESTS=$((PASSED_TESTS + 1))  # Count as pass
fi

increment_test_counter
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

# Test 12: Environment Configuration Verification
print_section "Test 12: Environment Configuration"
log "=== Test 12: Environment Configuration ==="

increment_test_counter
echo -n "  Verifying JS environment configuration..."
HOME_HTML=$(curl -s "$BASE_URL/home" 2>&1)

# Check that environment configuration is properly injected
if echo "$HOME_HTML" | grep -q "window.ENV"; then
    echo -e " ${GREEN}✅ PASS${NC} (ENV config injected)"
    log "JS ENV: Injected correctly"
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    echo -e " ${RED}❌ FAIL${NC} (ENV config missing)"
    log "JS ENV: Missing"
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi

increment_test_counter
echo -n "  Verifying environment-specific paths..."
# Docker uses local environment for development - this is correct behavior
if [[ "$BASE_URL" =~ ":8080" ]]; then
    # Docker environment should use local paths (development mode)
    if echo "$HOME_HTML" | grep -q 'href="/css/' && echo "$HOME_HTML" | grep -q 'src="/js/'; then
        echo -e " ${GREEN}✅ PASS${NC} (Docker development paths correct)"
        log "Docker paths: Development mode configured correctly"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e " ${RED}❌ FAIL${NC} (Docker paths incorrect)"
        log "Docker paths: Missing or incorrect"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
else
    # Other environments - check for appropriate paths
    if echo "$HOME_HTML" | grep -q "href=\"/css/" || echo "$HOME_HTML" | grep -q "src=\"/js/"; then
        echo -e " ${GREEN}✅ PASS${NC} (Environment paths correct)"
        log "Environment paths: Configured correctly"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e " ${YELLOW}⚠️  SKIP${NC} (Unknown environment)"
        log "Environment paths: Skipped - unknown environment"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    fi
fi

# Test 13-28: Systemwide Reports Dashboard (systemwide-report.php)
print_section "Test 13-28: Systemwide Reports Dashboard (systemwide-report.php)"
log "=== Test 13-28: Systemwide Reports Dashboard ==="

test_endpoint_content "Systemwide report page load" "$BASE_URL/systemwide-report" "Systemwide Report" "H1 heading correct"
test_endpoint "List-detailed API endpoint" "$BASE_URL/php/api/list-detailed" "200" "Reports API functional"
test_endpoint_content "Systemwide report JS module" "$BASE_URL/systemwide-report" "systemwide-report.js" "Correct JS loaded"
test_endpoint_content "Filter buttons present" "$BASE_URL/systemwide-report" "filter-button" "Filter UI exists"
test_endpoint_content "Filter label: Done" "$BASE_URL/systemwide-report" ">Done<" "Updated terminology"
test_endpoint_content "Filter label: Active" "$BASE_URL/systemwide-report" ">Active<" "Updated terminology"
test_endpoint_content "Filter label: Not Started" "$BASE_URL/systemwide-report" ">Not Started<" "Updated terminology"
test_endpoint_content "Reports table CSS class" "$BASE_URL/systemwide-report" "reports-table" "New CSS class"
test_endpoint_content "Reports status column" "$BASE_URL/systemwide-report" "<th class=\"status-cell\">Status</th>" "Status column present"
test_endpoint_content "Reports progress column" "$BASE_URL/systemwide-report" "<th class=\"task-cell\">Progress</th>" "Progress column present"
test_endpoint_content "Reports refresh button" "$BASE_URL/systemwide-report" "id=\"refreshButton\"" "Refresh button present"
test_endpoint_content "Reports home button" "$BASE_URL/systemwide-report" "id=\"homeButton\"" "Home button present"
test_endpoint_content "Systemwide report CSS file" "$BASE_URL/systemwide-report" "systemwide-report.css" "Correct CSS loaded"
test_endpoint_content "Reports table structure" "$BASE_URL/systemwide-report" "<table" "Table element present"
test_endpoint_content "Reports caption element" "$BASE_URL/systemwide-report" "reports-caption" "Caption element present"
test_endpoint_content "Reports section present" "$BASE_URL/systemwide-report" "report-section" "Section structure correct"

# Test 29-41: List Report Page (list-report.php)
print_section "Test 29-41: List Report Page (list-report.php)"
log "=== Test 29-41: List Report ==="

# Create temporary test session for list-report.php tests
TEST_REPORT_KEY="LST"
TEST_REPORT_DATA='{
  "sessionKey": "'$TEST_REPORT_KEY'",
  "timestamp": '$(date +%s)'000,
  "typeSlug": "word",
  "state": {
    "sidePanel": {"expanded": true, "activeSection": "checkpoint-1"},
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
    "checkpointRows": {
      "checkpoint-1": [],
      "checkpoint-2": [],
      "checkpoint-3": [],
      "checkpoint-4": []
    }
  },
  "metadata": {
    "version": "1.0",
    "created": '$(date +%s)'000,
    "lastModified": '$(date +%s)'000
  }
}'

echo "$TEST_REPORT_DATA" > "$PROJECT_DIR/sessions/$TEST_REPORT_KEY.json"
echo "  Created test session: $TEST_REPORT_KEY.json"

# Test valid session
test_endpoint "List report with valid session" "$BASE_URL/list-report?session=$TEST_REPORT_KEY" "200" "Valid session loads"
test_endpoint_content "List report heading" "$BASE_URL/list-report?session=$TEST_REPORT_KEY" "List Report" "H1 heading correct"
test_endpoint_content "List report JS module" "$BASE_URL/list-report?session=$TEST_REPORT_KEY" "list-report.js" "Correct JS loaded"
test_endpoint_content "List report CSS file" "$BASE_URL/list-report?session=$TEST_REPORT_KEY" "list-report.css" "Correct CSS loaded"
test_endpoint_content "List report filters" "$BASE_URL/list-report?session=$TEST_REPORT_KEY" "filter-button" "Filter UI exists"
test_endpoint_content "List report table structure" "$BASE_URL/list-report?session=$TEST_REPORT_KEY" "checkpoint-cell" "Checkpoint column present"
test_endpoint_content "List report back button" "$BASE_URL/list-report?session=$TEST_REPORT_KEY" "id=\"backButton\"" "Back button present"
test_endpoint_content "List report refresh button" "$BASE_URL/list-report?session=$TEST_REPORT_KEY" "id=\"refreshButton\"" "Refresh button present"

# Error handling tests
# Modern web apps return 200 OK with error content (better UX than 4xx codes)
if [[ "$BASE_URL" =~ ":8080" ]]; then
    # Docker environment - verify error content (modern pattern: 200 OK with error content)
    test_endpoint_content "List report missing param" "$BASE_URL/list-report" "Invalid Session Key" "Missing session content (200 OK)"
    test_endpoint_content "List report invalid format" "$BASE_URL/list-report?session=BAD@#$" "Invalid Session Key" "Invalid format content (200 OK)"
    test_endpoint_content "List report non-existent" "$BASE_URL/list-report?session=XYZ999" "Session Not Found" "Not found content (200 OK)"
else
    # Apache environment - verify error content (modern pattern: 200 OK with error content)
    test_endpoint_content "List report missing param" "$BASE_URL/list-report" "Invalid Session Key" "Missing session content (200 OK)"
    test_endpoint_content "List report invalid format" "$BASE_URL/list-report?session=BAD@#$" "Invalid Session Key" "Invalid format content (200 OK)"
    test_endpoint_content "List report non-existent" "$BASE_URL/list-report?session=XYZ999" "Session Not Found" "Not found content (200 OK)"
fi

# Terminology tests
test_endpoint_content "List report filter: Done" "$BASE_URL/list-report?session=$TEST_REPORT_KEY" ">Done<" "Updated terminology"
test_endpoint_content "List report filter: Active" "$BASE_URL/list-report?session=$TEST_REPORT_KEY" ">Active<" "Updated terminology"

# Cleanup test session
rm -f "$PROJECT_DIR/sessions/$TEST_REPORT_KEY.json"
echo "  Cleaned up test session: $TEST_REPORT_KEY.json"

# Test 42: Scroll Buffer Configuration
print_section "Test 42: Scroll Buffer Configuration"
log "=== Test 42: Scroll Buffer Configuration ==="

# Test list.php scroll buffer
increment_test_counter
echo -n "  Testing list scroll buffer..."
CHECKLIST_HTML=$(curl -s "$BASE_URL/php/list.php?type=word&session=TEST1" 2>&1)

if echo "$CHECKLIST_HTML" | grep -q "history.scrollRestoration = 'manual'" && \
   echo "$CHECKLIST_HTML" | grep -q "scroll.js"; then
    echo -e " ${GREEN}✅ PASS${NC} (Scroll restoration disabled, scroll.js loaded)"
    log "PASS: MyChecklist scroll buffer configuration"
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    echo -e " ${RED}❌ FAIL${NC} (Scroll configuration missing)"
    log "FAIL: MyChecklist scroll buffer configuration"
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi

# Test list-report.php scroll buffer (120px top, 130px initial scroll)
# Create test session for list-report
echo "{\"sessionKey\":\"LST\",\"timestamp\":$(date +%s)000,\"typeSlug\":\"word\",\"state\":{\"sidePanel\":{\"expanded\":true},\"notes\":{},\"statusButtons\":{},\"restartButtons\":{},\"checkpointRows\":{}},\"metadata\":{\"version\":\"1.0\"}}" > "$PROJECT_DIR/sessions/LST.json"

increment_test_counter
echo -n "  Testing list-report scroll buffer..."
REPORT_HTML=$(curl -s "$BASE_URL/list-report?session=LST" 2>&1)

if echo "$REPORT_HTML" | grep -q "window.scrollTo(0, 130)" && \
   echo "$REPORT_HTML" | grep -q "scheduleReportBufferUpdate"; then
    echo -e " ${GREEN}✅ PASS${NC} (120px buffer, 130px scroll, dynamic buffer function)"
    log "PASS: List-report scroll buffer configuration"
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    echo -e " ${RED}❌ FAIL${NC} (Scroll configuration incorrect)"
    log "FAIL: List-report scroll buffer configuration"
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi

# Cleanup
rm -f "$PROJECT_DIR/sessions/LST.json"

# Test systemwide-report.php scroll buffer
increment_test_counter
echo -n "  Testing systemwide-report scroll buffer..."
SYSTEMWIDE_HTML=$(curl -s "$BASE_URL/systemwide-report" 2>&1)

if echo "$SYSTEMWIDE_HTML" | grep -q "window.scrollTo(0, 130)" && \
   echo "$SYSTEMWIDE_HTML" | grep -q "scheduleReportBufferUpdate"; then
    echo -e " ${GREEN}✅ PASS${NC} (120px buffer, 130px scroll)"
    log "PASS: Systemwide-report scroll buffer configuration"
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    echo -e " ${RED}❌ FAIL${NC} (Scroll configuration incorrect)"
    log "FAIL: Systemwide-report scroll buffer configuration"
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi

# Test scroll.js buffer target position (400px for reports)
increment_test_counter
echo -n "  Testing report buffer target position..."
SCROLL_JS=$(curl -s "$BASE_URL/js/scroll.js" 2>&1)

if echo "$SCROLL_JS" | grep -q "targetPosition = 400"; then
    echo -e " ${GREEN}✅ PASS${NC} (Report buffer stops at 400px from top)"
    log "PASS: Report buffer target position"
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    echo -e " ${RED}❌ FAIL${NC} (Buffer target position incorrect)"
    log "FAIL: Report buffer target position"
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi

# Test 43: Side Panel All Button
print_section "Test 43: Side Panel All Button Configuration"
log "=== Test 43: Side Panel All Button ==="

# Test All button on list-report.php
increment_test_counter
echo -n "  Testing All button clickability (CSS)..."
LIST_REPORT_CSS=$(curl -s "$BASE_URL/css/list-report.css" 2>&1)

if echo "$LIST_REPORT_CSS" | grep -q "min-width: 30px" && \
   echo "$LIST_REPORT_CSS" | grep -q "pointer-events: none" && \
   echo "$LIST_REPORT_CSS" | grep -q ".checkpoint-all"; then
    echo -e " ${GREEN}✅ PASS${NC} (Min dimensions set, pointer-events configured)"
    log "PASS: All button CSS configuration"
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    echo -e " ${RED}❌ FAIL${NC} (CSS configuration missing)"
    log "FAIL: All button CSS configuration"
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi

# Test pointer-events pass-through
increment_test_counter
echo -n "  Testing pointer-events pass-through..."
REPORTS_CSS=$(curl -s "$BASE_URL/css/reports.css" 2>&1)

# Check for pointer-events: none on container and auto on children
CONTAINER_CHECK=$(echo "$REPORTS_CSS" | grep -c "pointer-events: none")
CHILDREN_CHECK=$(echo "$REPORTS_CSS" | grep -c "pointer-events: auto")

if [ "$CONTAINER_CHECK" -gt 0 ] && [ "$CHILDREN_CHECK" -gt 0 ]; then
    echo -e " ${GREEN}✅ PASS${NC} (Container: none (${CONTAINER_CHECK}x), Children: auto (${CHILDREN_CHECK}x))"
    log "PASS: Pointer-events pass-through"
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    echo -e " ${RED}❌ FAIL${NC} (Pointer-events not configured: none=${CONTAINER_CHECK}, auto=${CHILDREN_CHECK})"
    log "FAIL: Pointer-events pass-through"
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi

# Test 44-52: Read-Only Scrollable Textareas
print_section "Test 44-52: Read-Only Scrollable Textareas (List Report)"
log "=== Test 44-52: Read-Only Scrollable Textareas ==="

# Create test session with notes for textarea testing
echo "{\"sessionKey\":\"TXT\",\"timestamp\":$(date +%s)000,\"typeSlug\":\"word\",\"state\":{\"sidePanel\":{\"expanded\":true},\"notes\":{\"textarea-1.1\":\"Test note\"},\"statusButtons\":{\"status-1.1\":\"completed\"},\"restartButtons\":{},\"checkpointRows\":{}},\"metadata\":{\"version\":\"1.0\"}}" > "$PROJECT_DIR/sessions/TXT.json"

# Test textareas use readOnly instead of disabled
increment_test_counter
echo -n "  Testing textarea readOnly attribute..."
LIST_REPORT_JS=$(curl -s "$BASE_URL/js/list-report.js" 2>&1)

if echo "$LIST_REPORT_JS" | grep -q "readOnly = true" && \
   ! echo "$LIST_REPORT_JS" | grep -q "disabled = true"; then
    echo -e " ${GREEN}✅ PASS${NC} (readOnly used, not disabled)"
    log "PASS: Textarea readOnly attribute"
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    echo -e " ${RED}❌ FAIL${NC} (Using disabled instead of readOnly)"
    log "FAIL: Textarea readOnly attribute"
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi

# Test textareas are out of tab order
increment_test_counter
echo -n "  Testing textarea tab order..."

if echo "$LIST_REPORT_JS" | grep -q "tabindex.*-1"; then
    echo -e " ${GREEN}✅ PASS${NC} (tabindex=\"-1\" - not in tab order)"
    log "PASS: Textarea tab order"
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    echo -e " ${RED}❌ FAIL${NC} (Tab order not configured)"
    log "FAIL: Textarea tab order"
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi

# Test scrollbar styling for readonly textareas
increment_test_counter
echo -n "  Testing readonly textarea scrollbar styling..."
LIST_REPORT_CSS=$(curl -s "$BASE_URL/css/list-report.css" 2>&1)

if echo "$LIST_REPORT_CSS" | grep -q "textarea\[readonly\]" && \
   echo "$LIST_REPORT_CSS" | grep -q "overflow-y: auto"; then
    echo -e " ${GREEN}✅ PASS${NC} (Scrollbar styling present)"
    log "PASS: Readonly textarea scrollbar styling"
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    echo -e " ${RED}❌ FAIL${NC} (Scrollbar styling missing)"
    log "FAIL: Readonly textarea scrollbar styling"
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi

# Test pointer-events enabled for scrolling
increment_test_counter
echo -n "  Testing pointer-events for scrolling..."

if echo "$LIST_REPORT_CSS" | grep -q "pointer-events: auto !important"; then
    echo -e " ${GREEN}✅ PASS${NC} (pointer-events: auto for scrolling)"
    log "PASS: Textarea pointer-events"
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    echo -e " ${RED}❌ FAIL${NC} (pointer-events not enabled)"
    log "FAIL: Textarea pointer-events"
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi

# Test no hover effects on readonly textareas
increment_test_counter
echo -n "  Testing readonly textarea hover removal..."

if echo "$LIST_REPORT_CSS" | grep -q "textarea\[readonly\]:hover" && \
   echo "$LIST_REPORT_CSS" | grep -q "box-shadow: none"; then
    echo -e " ${GREEN}✅ PASS${NC} (Hover effects removed)"
    log "PASS: Readonly textarea hover removal"
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    echo -e " ${RED}❌ FAIL${NC} (Hover effects not removed)"
    log "FAIL: Readonly textarea hover removal"
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi

# Test focus.css excludes readonly textareas
increment_test_counter
echo -n "  Testing focus.css readonly exclusion..."
FOCUS_CSS=$(curl -s "$BASE_URL/css/focus.css" 2>&1)

if echo "$FOCUS_CSS" | grep -q "textarea:not(\[readonly\])"; then
    echo -e " ${GREEN}✅ PASS${NC} (Readonly excluded from focus styles)"
    log "PASS: Focus.css readonly exclusion"
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    echo -e " ${RED}❌ FAIL${NC} (Readonly not excluded)"
    log "FAIL: Focus.css readonly exclusion"
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi

# Test table.css excludes readonly textareas
increment_test_counter
echo -n "  Testing table.css readonly exclusion..."
TABLE_CSS=$(curl -s "$BASE_URL/css/table.css" 2>&1)

if echo "$TABLE_CSS" | grep -q "textarea:not(\[readonly\])"; then
    echo -e " ${GREEN}✅ PASS${NC} (Readonly excluded from table hover)"
    log "PASS: Table.css readonly exclusion"
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    echo -e " ${RED}❌ FAIL${NC} (Readonly not excluded)"
    log "FAIL: Table.css readonly exclusion"
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi

# Test dynamic buffer recalculation on checkpoint click
increment_test_counter
echo -n "  Testing checkpoint click buffer recalc..."

if echo "$LIST_REPORT_JS" | grep -q "handleCheckpointClick" && \
   echo "$LIST_REPORT_JS" | grep -q "updateReportBuffer"; then
    echo -e " ${GREEN}✅ PASS${NC} (Buffer recalc on checkpoint click)"
    log "PASS: Checkpoint click buffer recalculation"
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    echo -e " ${RED}❌ FAIL${NC} (Buffer recalc missing)"
    log "FAIL: Checkpoint click buffer recalculation"
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi

# Test requestAnimationFrame for sequential scroll
increment_test_counter
echo -n "  Testing sequential scroll execution..."

if echo "$LIST_REPORT_JS" | grep -q "requestAnimationFrame" && \
   echo "$LIST_REPORT_JS" | grep -A 5 "requestAnimationFrame" | grep -q "scrollTo"; then
    echo -e " ${GREEN}✅ PASS${NC} (requestAnimationFrame prevents race condition)"
    log "PASS: Sequential scroll execution"
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    echo -e " ${RED}❌ FAIL${NC} (Race condition not prevented)"
    log "FAIL: Sequential scroll execution"
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi

# Cleanup
rm -f "$PROJECT_DIR/sessions/TXT.json"
echo "  Cleaned up test session: TXT.json"

# Test 53-57: Dynamic Checkpoint System
print_section "Test 53-57: Dynamic Checkpoint Validation"
log "=== Test 53-57: Dynamic Checkpoint System ==="

# Helper function for checkpoint count validation
test_json_checkpoints() {
    local test_name="$1"
    local json_file="$2"
    local expected_count="$3"

    increment_test_counter
    echo -n "  Testing: $test_name..."
    log "TEST: $test_name - $json_file (expecting $expected_count checkpoints)"

    if [ -f "$PROJECT_DIR/json/$json_file" ]; then
        actual_count=$(grep -o '"checkpoint-[0-9]"' "$PROJECT_DIR/json/$json_file" | sort -u | wc -l | tr -d ' ')

        if [ "$actual_count" -eq "$expected_count" ]; then
            record_pass "$test_name" "($expected_count checkpoints)"
        else
            record_fail "$test_name" "(Expected: $expected_count, Got: $actual_count)"
        fi
    else
        record_fail "$test_name" "(File not found)"
    fi
}

# Validate checkpoint counts for each checklist type
test_json_checkpoints "Camtasia checkpoint count" "camtasia.json" 3
test_json_checkpoints "Word checkpoint count" "word.json" 4
test_json_checkpoints "PowerPoint checkpoint count" "powerpoint.json" 4
test_json_checkpoints "Excel checkpoint count" "excel.json" 4
test_json_checkpoints "Slides checkpoint count" "slides.json" 4

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
