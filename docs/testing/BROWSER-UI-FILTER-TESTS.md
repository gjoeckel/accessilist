# Browser UI Filter Tests Integration

## Overview

Added comprehensive browser UI tests for systemwide-report filter functionality using Playwright. These tests validate the new filter features including color changes, status icons, progress bars, and ARIA accessibility.

## Test Suite Summary

**Total Browser Tests:** 24 (15 existing + 9 new)
**New Filter Tests:** Tests 16-24
**Test Framework:** Playwright (supports Chromium, Firefox, WebKit)
**Integration Point:** Phase 3 of test workflows

## New Tests Added (16-24)

### Test 16: Filter Button Color Changes
- **Purpose:** Verify filter buttons display correct colors when activated
- **Colors Tested:**
  - Ready filter → Blue (#1a76bb)
  - Active filter → Yellow (#fec111)
  - Done filter → Green (#00834b)
- **Method:** Click each filter, extract computed background color
- **Pass Criteria:** All three colors match expected values

### Test 17: Color Persistence After Refresh
- **Purpose:** Ensure active filter retains color after clicking Refresh button
- **Method:** Activate Ready filter, click Refresh, verify blue color persists
- **Pass Criteria:** Active class present + blue background color maintained
- **Validates:** CSS specificity and state management

### Test 18: Status Column Icon Changes
- **Purpose:** Verify Status column icon matches the active filter
- **Method:** Switch between Ready/Active filters, check icon src attributes
- **Pass Criteria:** Ready filter shows `ready-1.svg`, Active shows `active-1.svg`
- **Validates:** Filter-specific icon display logic

### Test 19: Progress Text Changes by Filter
- **Purpose:** Verify progress text adapts to filter type
- **Expected Formats:**
  - All filter: "V Done | Z Active | Y Ready | X Tasks"
  - Ready filter: "N/X Tasks Started"
  - Active filter: "N/X Open Tasks Active"
- **Pass Criteria:** Text includes filter-specific keywords
- **Validates:** Dynamic progress calculation

### Test 20: Filter Badge Counts Display
- **Purpose:** Verify badge counts show correct numbers
- **Method:** Extract text from all badge elements (#count-ready, #count-active, etc.)
- **Pass Criteria:** All counts exist and are numeric
- **Validates:** "At least one task" counting logic

### Test 21: Status Placeholder in All/Demos
- **Purpose:** Verify Status column shows "-" placeholder for All/Demos filters
- **Method:** Activate All filter, count placeholders vs status icons
- **Pass Criteria:** Placeholder present, no status icons
- **Validates:** Conditional status display

### Test 22: Progress Bar Presence/Absence
- **Purpose:** Verify progress bars only appear in status-based filters
- **Method:** Count progress bars in All filter (expect 0) vs Ready filter (expect >0)
- **Pass Criteria:** All=0 progress bars, Ready>0 progress bars
- **Validates:** Filter-dependent UI rendering

### Test 23: ARIA Attributes for Accessibility
- **Purpose:** Verify aria-pressed attributes update correctly
- **Method:** Click Ready filter, check aria-pressed on Ready (true) and Active (false)
- **Pass Criteria:** Correct boolean values for both attributes
- **Validates:** Screen reader compatibility

### Test 24: Filter Button Labels
- **Purpose:** Verify correct label text ("Ready" not "Not Started")
- **Method:** Extract text from all filter labels
- **Pass Criteria:**
  - "Ready" present
  - "Active" present
  - "Done" present
  - "Not Started" absent
- **Validates:** Label terminology update

## Integration Points

### Local Docker Environment
- **Workflow:** `proj-mirror-production`
- **Command:** `bash scripts/external/browser-test-playwright.sh http://127.0.0.1:8080`
- **Phase:** Phase 3 (Browser UI Testing)

### Staging Server
- **Workflow:** `external-test`
- **Command:** `bash scripts/external/test-production.sh [staging-url]`
- **Phase:** Phase 3 (Browser UI Testing)

### Production Server
- **Workflow:** `external-live-production`
- **Command:** `bash scripts/external/test-production.sh https://webaim.org/training/online/accessilist2`
- **Phase:** Phase 3 (Browser UI Testing)

## Test Resilience

### Graceful Failure Handling
- Tests 1-3: Home page and button verification
- Tests 4-12: Session creation and interaction (may fail due to origin validation)
- **Tests 13-24: Filter tests run regardless of session creation success**

### Fallback Logic
If session creation fails (Test 3), the script:
1. Skips Tests 4-12 (session-dependent)
2. Navigates directly to systemwide-report
3. Runs Tests 13-24 using existing session data

This ensures filter tests always run, even when creating new sessions is blocked by CSRF protection.

## Running the Tests

### Local Development
```bash
# Run all browser tests (including filter tests)
bash scripts/external/browser-test-playwright.sh http://127.0.0.1:8080 chromium

# Run via workflow
# In Cursor: Cmd+Shift+P → "proj-mirror-production"
```

### Staging/Production
```bash
# Staging
bash scripts/external/test-production.sh [staging-url]

# Production
bash scripts/external/test-production.sh https://webaim.org/training/online/accessilist2

# Run via workflows
# In Cursor: Cmd+Shift+P → "external-test" or "external-live-production"
```

## Test Data Requirements

### Minimum Requirements
- At least 1 saved session with mixed task statuses (for filter visibility tests)
- Sessions with Ready, Active, and Done tasks (for badge count tests)

### Current Test Data (Docker)
- 2 saved sessions available
- Includes session 4E6 with mixed statuses (22 Ready, 4 Active, 0 Done)

## Success Criteria

### Full Suite (Tests 1-24)
- **Ideal:** 24/24 tests pass (requires successful session creation)
- **Acceptable:** 14/24 tests pass (Tests 1-3, 13-24 with session creation skipped)

### Filter Tests Only (Tests 13-24)
- **Required:** 12/12 tests pass (all filter-related tests)
- **Current Status:** ✅ 100% pass rate

## Browser Compatibility

### Tested Browsers
- ✅ Chromium (default)
- Firefox (supported via `--browser firefox`)
- WebKit (supported via `--browser webkit`)

### Multi-Browser Testing
```bash
# Test across all browsers
for browser in chromium firefox webkit; do
  bash scripts/external/browser-test-playwright.sh http://127.0.0.1:8080 $browser
done
```

## Related Documentation

- [TESTING.md](/DEVELOPER/TESTING.md) - Overall testing philosophy
- [TESTING-PHILOSOPHY.md](/docs/TESTING-PHILOSOPHY.md) - "Browser tests = ground truth"
- [test-production.sh](/scripts/external/test-production.sh) - Main test orchestrator
- [browser-test-playwright.sh](/scripts/external/browser-test-playwright.sh) - Playwright test implementation

## Failure Handling

### Session Creation Failures
If Test 3 (session creation) fails, the browser test script:

1. **Continues with filter tests** (Tests 13-24) using existing session data
2. **Invokes diagnostic script** automatically in non-interactive mode
3. **Provides clear summary** of what was tested and what failed
4. **Exits with code 2** to indicate session creation failure

### Diagnostic Integration
- **Auto-diagnostic:** Runs `diagnose-test-failures.sh` when session creation fails
- **Non-interactive mode:** Diagnostic script runs without user prompts (stdin redirected to /dev/null)
- **Log file created:** Failure details saved to `logs/browser-test-session-failure-<timestamp>.log`
- **Clear messaging:** User receives actionable next steps and impact assessment

### Exit Codes
- **0:** All tests passed (session creation + filter tests)
- **1:** Some tests failed (but not session creation)
- **2:** Session creation failed (diagnostic invoked, partial testing completed)

## Changelog

### 2025-10-21: Filter Tests + Diagnostic Integration
- Added Tests 16-24 (9 new filter tests)
- Validates filter colors, icons, progress bars, ARIA attributes
- Integrated automatic diagnostic invocation on session creation failure
- Fixed `set -e` issue preventing diagnostic script from running
- Added comprehensive failure reporting and user guidance
- 100% pass rate on local Docker environment (filter tests)

---

**Note:** These tests validate user-visible behavior in real browsers, serving as the "ground truth" for UI/UX functionality per the project's testing philosophy. When session creation fails, diagnostics run automatically to help identify the root cause.
