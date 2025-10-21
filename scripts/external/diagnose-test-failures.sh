#!/bin/bash

################################################################################
# TEST FAILURE DIAGNOSTIC TOOL
################################################################################
#
# PURPOSE: Analyze test failures and provide actionable recommendations
#
# USAGE:
#   Called automatically by test scripts on failure:
#     ./diagnose-test-failures.sh <log-file> <environment> <last-failure-test> <last-failure-details>
#
#   Or run manually for investigation:
#     ./diagnose-test-failures.sh logs/external-test-staging-20251021.log staging
#
################################################################################
# FOR AI AGENTS:
################################################################################
#
# This script embodies the diagnostic process you should follow when tests fail.
# It's NOT just error reporting - it's INTELLIGENT ANALYSIS with ACTIONABLE FIXES.
#
# Key principles:
# 1. Identify MULTIPLE potential issues (not just one)
# 2. Provide SPECIFIC fixes (not vague suggestions)
# 3. Request ADDITIONAL INFO when diagnosis is uncertain
# 4. WAIT for human decision (don't auto-apply fixes)
# 5. Prioritize by LIKELIHOOD (most probable issue first)
#
# Remember: Your job is to HELP HUMANS DEBUG, not to blindly retry tests.
#
################################################################################

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

# Arguments
LOG_FILE=${1:-""}
ENVIRONMENT=${2:-"unknown"}
LAST_FAILURE_TEST=${3:-""}
LAST_FAILURE_DETAILS=${4:-""}

# Banner
echo ""
echo -e "${RED}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${RED}║  🔍 AUTOMATIC FAILURE DIAGNOSIS                        ║${NC}"
echo -e "${RED}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# If called manually without parameters, show usage
if [ -z "$LOG_FILE" ]; then
    echo -e "${YELLOW}Usage:${NC}"
    echo "  $0 <log-file> <environment> [last-failure-test] [last-failure-details]"
    echo ""
    echo -e "${CYAN}Example:${NC}"
    echo "  $0 logs/external-test-staging-20251021.log staging"
    echo ""
    exit 1
fi

# Analyze failure patterns from log file if available
echo -e "${YELLOW}📋 Analyzing Failures...${NC}"
echo ""

if [ -f "$LOG_FILE" ]; then
    echo -e "${CYAN}Log file:${NC} $LOG_FILE"
    echo -e "${CYAN}Environment:${NC} $ENVIRONMENT"
    echo ""

    # Extract failure patterns
    FAIL_COUNT=$(grep -c "^.*FAIL:" "$LOG_FILE" 2>/dev/null || echo "0")
    echo -e "${YELLOW}Total failures detected:${NC} $FAIL_COUNT"
    echo ""
fi

# POTENTIAL ISSUES
echo -e "${BLUE}🔍 POTENTIAL ISSUES IDENTIFIED:${NC}"
echo ""

issue_count=0

# Issue 1: Rate Limiting (HTTP 429)
if echo "$LAST_FAILURE_DETAILS" | grep -q "429" || grep -q "429" "$LOG_FILE" 2>/dev/null; then
    issue_count=$((issue_count + 1))
    echo -e "${YELLOW}Issue $issue_count: Rate Limiting Active (HTTP 429)${NC}"
    echo "  - API is blocking rapid requests with HTTP 429"
    echo "  - This prevents automated testing but protects production"
    echo "  - This is EXPECTED and actually proves security works!"
    echo ""
    echo -e "  ${GREEN}Fixes/Alternatives:${NC}"
    echo "    1. Add delays (sleep 2-5s) between API requests in test script"
    echo "    2. Whitelist test IP in php/includes/rate-limiter.php"
    echo "    3. Run tests from authenticated admin session with higher limits"
    echo ""
fi

# Issue 2: CSRF Token Issues (HTTP 403)
if echo "$LAST_FAILURE_DETAILS" | grep -q "403" || grep -q "CSRF.*403" "$LOG_FILE" 2>/dev/null; then
    issue_count=$((issue_count + 1))
    echo -e "${YELLOW}Issue $issue_count: CSRF Protection Blocking Request (HTTP 403)${NC}"
    echo "  - Request was blocked due to missing/invalid CSRF token"
    echo "  - Session cookie may not be persisting correctly"
    echo "  - Token/cookie mismatch between frontend and backend"
    echo ""
    echo -e "  ${GREEN}Fixes/Alternatives:${NC}"
    echo "    1. Verify CSRF token in page: curl -s \$URL | grep 'csrf-token'"
    echo "    2. Check session cookie path in config.php (should be '/' for all)"
    echo "    3. Verify session_start() happens BEFORE any headers sent"
    echo ""
fi

# Issue 3: Missing Files/Resources (HTTP 404)
if echo "$LAST_FAILURE_DETAILS" | grep -q "404" || grep -q "404" "$LOG_FILE" 2>/dev/null; then
    issue_count=$((issue_count + 1))
    echo -e "${YELLOW}Issue $issue_count: Resource Not Found (HTTP 404)${NC}"
    echo "  - File or endpoint does not exist on server"
    echo "  - May indicate incomplete deployment or wrong URL"
    echo "  - Check if file exists in codebase but wasn't deployed"
    echo ""
    echo -e "  ${GREEN}Fixes/Alternatives:${NC}"
    echo "    1. Verify deployment: ./scripts/deployment/verify-deployment-manifest.sh"
    echo "    2. Check file on server: ssh ... 'ls -la /path/to/file'"
    echo "    3. Review .deployignore - file may be excluded"
    echo ""
fi

# Issue 4: Permission/Access Issues
if echo "$LAST_FAILURE_DETAILS" | grep -qi "permission\|writable\|accessible\|not exposed" || grep -qi "permission" "$LOG_FILE" 2>/dev/null; then
    issue_count=$((issue_count + 1))
    echo -e "${YELLOW}Issue $issue_count: Permission/Access Problem${NC}"
    echo "  - Directory or file permissions may be incorrect"
    echo "  - Web server (www-data) may lack necessary access"
    echo "  - Or: PHP includes are correctly protected (403 = good!)"
    echo ""
    echo -e "  ${GREEN}Fixes/Alternatives:${NC}"
    echo "    1. Check if 403/404 on includes is EXPECTED (security working)"
    echo "    2. For session dirs: ssh ... 'ls -la /var/websites/.../etc/sessions'"
    echo "    3. Fix permissions: sudo chown -R www-data:www-data /path/ && chmod 755"
    echo ""
fi

# If no specific issues identified
if [ $issue_count -eq 0 ]; then
    echo -e "${YELLOW}Issue 1: Unknown Failure Pattern${NC}"
    echo "  - Test failed but doesn't match known patterns"
    if [ -n "$LAST_FAILURE_TEST" ]; then
        echo "  - Last failure: $LAST_FAILURE_TEST"
        echo "  - Details: $LAST_FAILURE_DETAILS"
    fi
    echo ""
    echo -e "  ${GREEN}Fixes/Alternatives:${NC}"
    echo "    1. Review full log file: $LOG_FILE"
    echo "    2. Run test manually with -v flag for verbose output"
    echo "    3. Check server error logs: ssh ... 'tail -50 /var/log/apache2/error.log'"
    echo ""
fi

# ADDITIONAL INFO NEEDED
echo -e "${BLUE}📊 ADDITIONAL INFORMATION NEEDED:${NC}"
echo ""
echo "To better diagnose this issue, please provide:"
echo ""
echo "  1. Full error output from failed test:"
echo "     → Review: $LOG_FILE"
echo ""
echo "  2. Server-side logs (if accessible):"
echo "     → Apache error log: /var/log/apache2/error.log"
echo "     → PHP error log: /var/log/php/error.log"
echo ""
echo "  3. Network response details:"
echo "     → Run: curl -v <failed-endpoint-url>"
echo ""
echo "  4. Recent deployment changes:"
echo "     → Run: git log --oneline -10"
echo ""
echo "  5. Browser console (if UI test failed):"
echo "     → Open browser dev tools and check for JS errors"
echo ""

# NEXT STEPS
echo -e "${BLUE}🔧 RECOMMENDED NEXT STEPS:${NC}"
echo ""
echo "  1. Review diagnostic output above"
echo "  2. Gather additional information if needed"
echo "  3. Choose most likely fix from alternatives"
echo "  4. Test fix on staging (accessilist2) first"
echo "  5. Re-run test script to verify fix works"
echo ""

echo -e "${YELLOW}⏸️  WAITING FOR YOUR DECISION...${NC}"
echo ""
echo "What would you like to do next?"
echo "  → Investigate a specific issue from the list above"
echo "  → Apply one of the suggested fixes"
echo "  → Request more detailed analysis of a specific failure"
echo "  → Continue despite failures (if failures are acceptable)"
echo "  → Review the full log file for more context"
echo ""
