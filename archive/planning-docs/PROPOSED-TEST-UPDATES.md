# Proposed Test Updates - Reports and User Report Pages

**Date**: October 8, 2025
**Purpose**: Add comprehensive tests for reports.php and report.php; disable admin.php tests

---

## Overview

Based on analysis of the codebase using MCP tools, I propose adding 15 new tests and commenting out 3 admin.php tests.

---

## Understanding of Functionality

### `reports.php` - Systemwide Reports Dashboard
**Purpose**: Shows all saved checklists across all users/types with filtering

**Key Features:**
- Displays table with columns: Type, Updated, Key, Status, Progress, Delete
- Filter buttons: Completed, In Progress, All Pending, All (with counts)
- Status calculated from `statusButtons` in saved state
- Progress bar showing completed/total tasks
- Delete functionality with modal confirmation
- Refresh button to reload data
- Uses `/php/api/list-detailed` endpoint

**JavaScript**: `ReportsManager` class handles:
- Loading all checklists via API
- Calculating status (pending/in-progress/completed) from statusButtons
- Filtering by status
- Progress calculation (completed tasks / total tasks)
- Delete workflow with focus management

### `report.php` - User-Specific Checklist Report
**Purpose**: Shows single checklist in read-only report view

**Key Features:**
- Requires `?session=KEY` parameter (validates session key)
- Shows 404 if session doesn't exist
- Displays all tasks grouped by checkpoint/principle
- Table columns: Checkpoint Icon, Tasks, Notes, Status
- Filter buttons: Completed, In Progress, Pending, All (with counts)
- Read-only textareas (disabled, no borders)
- Status icons (non-interactive images, not buttons)
- Back button returns to checklist (/?=KEY)
- Refresh button reloads data
- Uses `/php/api/restore?sessionKey=KEY` endpoint

**JavaScript**: `UserReportManager` class handles:
- Loading single checklist via restore API
- Loading principle structure from type JSON
- Grouping tasks by principle/checkpoint
- Filtering tasks by status
- Rendering read-only view

### `admin.php` - **DEPRECATED/UNUSED**
**Current Status**: Page exists but is no longer used in workflow
**Action**: Comment out all admin.php tests for potential future refactoring

---

## Proposed New Tests

### Category A: reports.php Tests (8 new tests)

#### Test A1: Reports Page Structure
```bash
Test: Reports page loads correctly
URL: /reports
Expected: HTTP 200
Verify: Page contains "Systemwide Reports" heading
```

#### Test A2: Reports API Endpoint
```bash
Test: List-detailed API endpoint
URL: /php/api/list-detailed
Expected: HTTP 200
Verify: Returns JSON with data array
```

#### Test A3: Reports Filter Buttons
```bash
Test: Filter buttons present and structured
URL: /reports
Expected: HTTP 200
Verify: Page contains filter buttons (Completed, In Progress, All Pending, All)
Verify: Each button has data-filter attribute
Verify: Each button has filter-count span
```

#### Test A4: Reports Table Structure
```bash
Test: Reports table has correct columns
URL: /reports
Expected: HTTP 200
Verify: Table headers: Type, Updated, Key, Status, Progress, Delete
```

#### Test A5: Reports with Existing Data
```bash
Test: Reports page shows existing checklists
Setup: Use existing session files in saves/
URL: /reports
Expected: HTTP 200
Verify: Table tbody contains at least 1 row (if saves exist)
Verify: Progress bar elements present
Verify: Status icons present
```

#### Test A6: Reports Refresh Button
```bash
Test: Refresh button present
URL: /reports
Expected: HTTP 200
Verify: Button with id="refreshButton" exists
Verify: Button has aria-label
```

#### Test A7: Reports Home Button
```bash
Test: Home button present
URL: /reports
Expected: HTTP 200
Verify: Button with id="homeButton" exists
Verify: Button has aria-label
```

#### Test A8: Reports JavaScript Loaded
```bash
Test: ReportsManager JavaScript loaded
URL: /reports
Expected: HTTP 200
Verify: Page includes reports.js module
Verify: date-utils.js loaded
```

---

### Category B: report.php Tests (7 new tests)

#### Test B1: Report Page with Valid Session
```bash
Test: User report page loads with valid session
Setup: Create test session (MIN.json)
URL: /report?session=MIN
Expected: HTTP 200
Verify: Page contains "Report" heading
Verify: Back button present
```

#### Test B2: Report Page Missing Session Parameter
```bash
Test: Report page handles missing session parameter
URL: /report
Expected: HTTP 400
Verify: Error page with "Invalid Session Key" message
Verify: Link to return home
```

#### Test B3: Report Page Invalid Session Key
```bash
Test: Report page handles invalid session format
URL: /report?session=INVALID@KEY
Expected: HTTP 400
Verify: Error page with validation message
```

#### Test B4: Report Page Non-Existent Session
```bash
Test: Report page handles non-existent session
URL: /report?session=XYZ
Expected: HTTP 404
Verify: Error page with "Session Not Found" message
Verify: Shows session key in error message
```

#### Test B5: Report Table Structure
```bash
Test: Report table has correct columns
Setup: Use existing session (MIN.json)
URL: /report?session=MIN
Expected: HTTP 200
Verify: Table headers: Chkpt, Tasks, Notes, Status
Verify: Table has aria-labelledby attribute
```

#### Test B6: Report Filter Buttons
```bash
Test: Report filter buttons present
Setup: Use existing session (MIN.json)
URL: /report?session=MIN
Expected: HTTP 200
Verify: Filter buttons: Completed, In Progress, Pending, All
Verify: Each button has data-filter and count span
```

#### Test B7: Report Back Button Functionality
```bash
Test: Back button links to checklist
Setup: Use existing session (MIN.json)
URL: /report?session=MIN
Expected: HTTP 200
Verify: Button with id="backButton" exists
Verify: JavaScript includes back navigation logic
```

---

### Category C: admin.php Tests (3 tests to COMMENT OUT)

#### Test C1: Admin page loads ~~ACTIVE~~ COMMENTED
```bash
# Test: Admin clean URL
# URL: /admin
# Expected: HTTP 200
# Status: COMMENTED - admin.php no longer used
```

#### Test C2: Direct admin.php access ~~ACTIVE~~ COMMENTED
```bash
# Test: Direct /php/admin.php
# URL: /php/admin.php
# Expected: HTTP 200
# Status: COMMENTED - admin.php no longer used
```

#### Test C3: Admin page content ~~ACTIVE~~ COMMENTED
```bash
# Test: Admin page content
# URL: /admin
# Expected: Contains "Admin"
# Status: COMMENTED - admin.php no longer used
```

---

## Implementation Plan

### Step 1: Comment Out Admin Tests
In `scripts/test-production-mirror.sh`:
- Comment out Test 2: `/admin clean URL` test
- Comment out Test 3: `Direct /php/admin.php` test
- Comment out Test 7: `Admin page content` test
- Add comment explaining admin.php is deprecated

### Step 2: Add Reports Tests (Category A - 8 tests)
Add new test section after Test 7:
- **Test 13**: Reports page structure
- **Test 14**: Reports API (list-detailed)
- **Test 15**: Reports filter buttons
- **Test 16**: Reports table structure
- **Test 17**: Reports with existing data
- **Test 18**: Reports refresh button
- **Test 19**: Reports home button
- **Test 20**: Reports JavaScript loaded

### Step 3: Add User Report Tests (Category B - 7 tests)
Add new test section after reports tests:
- **Test 21**: Report page with valid session
- **Test 22**: Report missing session parameter (400)
- **Test 23**: Report invalid session format (400)
- **Test 24**: Report non-existent session (404)
- **Test 25**: Report table structure
- **Test 26**: Report filter buttons
- **Test 27**: Report back button

### Step 4: Update Test Counters
- Total tests: 30 → 34 tests
- Commented: 3 tests (admin.php)
- Active: 31 tests (27 existing + 4 report tests after admin removal, + 15 new = 34)
- Net change: +4 active tests

---

## Expected Results After Implementation

### Before Changes
```
Total Tests:    30
Active Tests:   30
Commented:      0
```

### After Changes
```
Total Tests:    34
Active Tests:   34
Commented:      3 (admin.php - deprecated)
Success Rate:   100% (expected)
```

---

## Test Data Requirements

### For Reports Tests
- **Requirement**: At least 1 existing session in `saves/` directory
- **Current State**: Multiple sessions exist (0EX, 0YI, 45X, etc.)
- **Status**: ✅ Ready

### For User Report Tests
- **Requirement**: Create test session `MIN.json` with valid data
- **Setup**: Script will create temporary MIN.json for testing
- **Cleanup**: Script will delete MIN.json after tests
- **Status**: ✅ Will be automated

---

## Code Changes Preview

### Change 1: Comment Admin Tests
```bash
# Test 2: Clean URL Routes (Production-style)
# COMMENTED: admin.php deprecated - keeping for potential future refactoring
# test_endpoint "/admin clean URL" "$BASE_URL/admin" "200" "Admin page via clean URL"

# Test 3: Direct PHP File Access
# COMMENTED: admin.php deprecated
# test_endpoint "Direct /php/admin.php" "$BASE_URL/php/admin.php" "200" "Direct PHP access"

# Test 7: Content Verification
# COMMENTED: admin.php deprecated
# test_endpoint_content "Admin page content" "$BASE_URL/admin" "Admin" "Admin page has correct content"
```

### Change 2: Add Reports Tests
```bash
# Test 13-20: Reports Dashboard Functionality
print_section "Test 13-20: Reports Dashboard (reports.php)"
log "=== Reports Dashboard Tests ==="

test_endpoint_content "Reports page structure" "$BASE_URL/reports" "Systemwide Reports" "Reports heading"
test_endpoint "List-detailed API" "$BASE_URL/php/api/list-detailed" "200" "Reports API"
test_endpoint_content "Reports filter buttons" "$BASE_URL/reports" "filter-button" "Filter buttons present"
# ... (8 tests total)
```

### Change 3: Add User Report Tests
```bash
# Test 21-27: User Report Functionality
print_section "Test 21-27: User Report (report.php)"
log "=== User Report Tests ==="

# Create test session
MIN_DATA='{"sessionKey":"MIN","timestamp":'$(date +%s)'000,"typeSlug":"word",...}'
echo "$MIN_DATA" > "$PROJECT_DIR/saves/MIN.json"

test_endpoint "Report with valid session" "$BASE_URL/report?session=MIN" "200" "User report loads"
test_endpoint "Report missing parameter" "$BASE_URL/report" "400" "Missing session error"
# ... (7 tests total)

# Cleanup
rm -f "$PROJECT_DIR/saves/MIN.json"
```

---

## Benefits

### Coverage
- ✅ Comprehensive reports dashboard testing
- ✅ User report page validation
- ✅ Error handling for report page (400, 404)
- ✅ API endpoint validation (list-detailed)
- ✅ Filter functionality verification

### Maintainability
- ✅ Admin tests preserved (commented) for future refactoring
- ✅ Clear separation of deprecated vs active tests
- ✅ Automated test data setup/cleanup

### Production Readiness
- ✅ Validates both report pages work in production-mirror environment
- ✅ Tests error conditions (missing/invalid sessions)
- ✅ Verifies JavaScript modules load correctly
- ✅ Confirms filter buttons and navigation work

---

## Questions/Clarifications Needed

### 1. Admin Page Status
**Confirmed**: admin.php is deprecated/unused, tests should be commented out ✅

### 2. Test Session Data
**Question**: Should test use existing sessions or create temporary ones?
**Recommendation**: Create temporary MIN.json for clean, predictable testing ✅

### 3. List-Detailed API
**Question**: Is `/php/api/list-detailed` different from `/php/api/list`?
**Assumption**: Yes - list-detailed includes full state data for progress calculation
**Action**: Will test both endpoints

---

## Risk Assessment

### Low Risk
- Adding new tests doesn't modify application code
- Commenting out tests is easily reversible
- Test data is temporary and cleaned up

### No Risk
- Admin.php tests are preserved (commented)
- Existing tests remain unchanged
- All changes in test script only

---

## Approval Request

Please review and approve:

1. ✅ **Comment out 3 admin.php tests** (page deprecated)
2. ✅ **Add 8 reports.php tests** (systemwide reports dashboard)
3. ✅ **Add 7 report.php tests** (user-specific report page)
4. ✅ **Update test counter** (30 → 34 total tests, 34 active)
5. ✅ **Create temporary MIN.json** for report.php tests

**Expected Outcome**: 34/34 tests passing (100% success rate)

---

## Ready to Implement?

Once approved, I will:
1. Update `scripts/test-production-mirror.sh` with all proposed changes
2. Run the updated test suite
3. Verify 100% pass rate
4. Update all documentation
5. Update changelog

**Please confirm approval to proceed with implementation.**

