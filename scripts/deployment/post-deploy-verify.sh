#!/bin/bash

# Post-Deployment Verification Script
# Validates production site after deployment
# Tests critical paths to ensure deployment success

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

PRODUCTION_URL="https://webaim.org/training/online/accessilist"
PROJECT_DIR="/Users/a00288946/Desktop/accessilist"

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║          Post-Deployment Verification                 ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}Production URL:${NC} $PRODUCTION_URL"
echo -e "${CYAN}Test Time:${NC} $(date)"
echo ""
echo -e "${YELLOW}Note: Waiting 10 seconds for GitHub Actions deployment to complete...${NC}"
sleep 10
echo -e "${GREEN}✅ Starting production verification${NC}"
echo ""

# Test function
test_production_endpoint() {
    local test_name="$1"
    local url="$2"
    local expected_code="${3:-200}"

    TOTAL_TESTS=$((TOTAL_TESTS + 1))

    echo -n "  Testing: $test_name..."

    http_code=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>&1)

    if [ "$http_code" = "$expected_code" ]; then
        echo -e " ${GREEN}✅ PASS${NC} (HTTP $http_code)"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        return 0
    else
        echo -e " ${RED}❌ FAIL${NC} (Expected: $expected_code, Got: $http_code)"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        return 1
    fi
}

# Test function with content check
test_production_content() {
    local test_name="$1"
    local url="$2"
    local search_string="$3"

    TOTAL_TESTS=$((TOTAL_TESTS + 1))

    echo -n "  Testing: $test_name..."

    response=$(curl -s "$url" 2>&1)
    http_code=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>&1)

    if [ "$http_code" = "200" ] && echo "$response" | grep -q "$search_string"; then
        echo -e " ${GREEN}✅ PASS${NC}"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        return 0
    else
        echo -e " ${RED}❌ FAIL${NC} (HTTP $http_code or content missing)"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        return 1
    fi
}

# Critical Production Tests (6 tests)
echo -e "${BLUE}━━━ Critical Production Tests ━━━${NC}"

test_production_endpoint "Home page" "$PRODUCTION_URL/home" "200"
test_production_endpoint "Reports dashboard" "$PRODUCTION_URL/reports" "200"
test_production_endpoint "API Health" "$PRODUCTION_URL/php/api/health" "200"
test_production_endpoint "API List" "$PRODUCTION_URL/php/api/list" "200"
test_production_content "Base path in HTML" "$PRODUCTION_URL/home" "/training/online/accessilist"
test_production_content "ENV config injected" "$PRODUCTION_URL/home" "window.ENV"

echo ""

# Results Summary
echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║          Verification Results                          ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

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
    echo -e "${GREEN}║  ✅ PRODUCTION DEPLOYMENT VERIFIED SUCCESSFULLY! ✅    ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}Production Site:${NC} $PRODUCTION_URL/home"
    echo ""
    exit 0
else
    echo -e "${RED}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║  ❌ PRODUCTION VERIFICATION FAILED - INVESTIGATE! ❌   ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Failed tests indicate deployment issues${NC}"
    echo -e "${YELLOW}Check production site and logs${NC}"
    echo ""
    exit 1
fi

