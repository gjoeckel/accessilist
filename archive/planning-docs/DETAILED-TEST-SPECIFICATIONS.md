# Detailed Test Specifications for Reports Pages

**Date**: October 8, 2025

---

## Page Analysis Summary

### `reports.php` - Systemwide Reports Dashboard
- **Route**: `/reports` (clean URL)
- **Direct Access**: `/php/reports.php`
- **API Used**: `/php/api/list-detailed` (returns all sessions with full state)
- **JavaScript**: `ReportsManager` class from `js/reports.js`
- **Features**:
  - Table with 6 columns (Type, Updated, Key, Status, Progress, Delete)
  - 4 filter buttons with count badges
  - Status calculation from statusButtons
  - Progress bar (completed/total tasks)
  - Delete confirmation modal
  - Refresh functionality
  - Home button navigation

### `report.php` - User Checklist Report
- **Route**: `/report?session=KEY`
- **API Used**: `/php/api/restore?sessionKey=KEY` (single session data)
- **JavaScript**: `UserReportManager` class from `js/report.js`
- **Features**:
  - Requires session parameter (validates format)
  - 404 if session doesn't exist
  - 400 if session parameter missing/invalid
  - Table with 4 columns (Checkpoint Icon, Tasks, Notes, Status)
  - 4 filter buttons with count badges
  - Read-only textareas (disabled)
  - Non-interactive status icons
  - Back button (returns to /?=KEY)
  - Refresh functionality
  - Checkpoint grouping

---

## Proposed Test Additions

### Reports Dashboard Tests (8 tests)

#### Test 13: Reports Page Load
```bash
Description: Verify reports page loads with correct heading
Method: GET
URL: http://localhost/training/online/accessilist/reports
Expected HTTP: 200
Content Check: "Systemwide Reports"
Validation: Page renders without errors
```

#### Test 14: List-Detailed API Endpoint
```bash
Description: Verify list-detailed API returns session data
Method: GET
URL: http://localhost/training/online/accessilist/php/api/list-detailed
Expected HTTP: 200
Content Check: JSON response with "success":true
Content Check: "data" array present
Validation: API endpoint accessible and returns valid JSON
```

#### Test 15: Reports Filter Buttons Present
```bash
Description: Verify all 4 filter buttons exist
Method: GET
URL: http://localhost/training/online/accessilist/reports
Expected HTTP: 200
Content Check: id="filter-completed"
Content Check: id="filter-in-progress"
Content Check: id="filter-pending"
Content Check: id="filter-all"
Validation: All filter buttons rendered in HTML
```

#### Test 16: Reports Table Headers
```bash
Description: Verify table has correct 6 column headers
Method: GET
URL: http://localhost/training/online/accessilist/reports
Expected HTTP: 200
Content Check: <th class="admin-type-cell">Type</th>
Content Check: <th class="admin-date-cell">Updated</th>
Content Check: <th class="admin-instance-cell">Key</th>
Content Check: <th class="reports-status-cell">Status</th>
Content Check: <th class="reports-progress-cell">Progress</th>
Content Check: <th class="reports-delete-cell">Delete</th>
Validation: Table structure matches specification
```

#### Test 17: Reports Shows Existing Sessions
```bash
Description: Verify reports displays existing save files
Method: GET
URL: http://localhost/training/online/accessilist/reports
Expected HTTP: 200
Content Check: <tbody> contains <tr> elements (if saves exist)
Note: Test passes even with 0 sessions (empty state)
Validation: Table renders correctly with or without data
```

#### Test 18: Reports Refresh Button
```bash
Description: Verify refresh button present and accessible
Method: GET
URL: http://localhost/training/online/accessilist/reports
Expected HTTP: 200
Content Check: id="refreshButton"
Content Check: aria-label="Refresh reports data"
Validation: Refresh functionality available
```

#### Test 19: Reports Home Button
```bash
Description: Verify home button present and accessible
Method: GET
URL: http://localhost/training/online/accessilist/reports
Expected HTTP: 200
Content Check: id="homeButton"
Content Check: aria-label="Go to home page"
Validation: Navigation back to home available
```

#### Test 20: Reports JavaScript Module
```bash
Description: Verify ReportsManager JavaScript loaded
Method: GET
URL: http://localhost/training/online/accessilist/reports
Expected HTTP: 200
Content Check: js/reports.js
Content Check: js/date-utils.js
Content Check: ReportsManager
Validation: All required JavaScript modules present
```

---

### User Report Tests (7 tests)

#### Test 21: Report with Valid Session
```bash
Description: Verify report page loads with valid session
Method: GET
Setup: Create saves/MIN.json with test data
URL: http://localhost/training/online/accessilist/report?session=MIN
Expected HTTP: 200
Content Check: <h1>Report</h1>
Content Check: id="backButton"
Content Check: class="report-table"
Validation: Page loads successfully with session data
```

#### Test 22: Report Missing Session Parameter
```bash
Description: Verify error handling for missing session parameter
Method: GET
URL: http://localhost/training/online/accessilist/report
Expected HTTP: 400
Content Check: "Invalid Session Key"
Content Check: "invalid or missing"
Content Check: href to /home
Validation: Proper error page with navigation
```

#### Test 23: Report Invalid Session Format
```bash
Description: Verify validation rejects invalid session format
Method: GET
URL: http://localhost/training/online/accessilist/report?session=INVALID@#$
Expected HTTP: 400
Content Check: "Invalid Session Key"
Validation: Regex validation working (/^[A-Z0-9\-]{3,20}$/)
```

#### Test 24: Report Non-Existent Session
```bash
Description: Verify 404 for session that doesn't exist
Method: GET
URL: http://localhost/training/online/accessilist/report?session=XYZ
Expected HTTP: 404
Content Check: "Session Not Found"
Content Check: Session key "XYZ" in message
Content Check: href to /home
Validation: File existence check working, proper 404
```

#### Test 25: Report Table Structure
```bash
Description: Verify report table has correct 4 columns
Method: GET
Setup: Create saves/MIN.json
URL: http://localhost/training/online/accessilist/report?session=MIN
Expected HTTP: 200
Content Check: <th class="checkpoint-cell">Chkpt</th>
Content Check: <th class="task-cell">Tasks</th>
Content Check: <th class="notes-cell">Notes</th>
Content Check: <th class="status-cell">Status</th>
Validation: Table structure correct
```

#### Test 26: Report Filter Buttons
```bash
Description: Verify filter buttons with count badges
Method: GET
Setup: Create saves/MIN.json
URL: http://localhost/training/online/accessilist/report?session=MIN
Expected HTTP: 200
Content Check: id="filter-completed" with span id="count-completed"
Content Check: id="filter-in-progress" with span id="count-in-progress"
Content Check: id="filter-pending" with span id="count-pending"
Content Check: id="filter-all" with span id="count-all"
Validation: All 4 filters with count badges present
```

#### Test 27: Report Back Button
```bash
Description: Verify back button present and functional
Method: GET
Setup: Create saves/MIN.json
URL: http://localhost/training/online/accessilist/report?session=MIN
Expected HTTP: 200
Content Check: id="backButton"
Content Check: aria-label="Back to checklist"
Validation: Navigation to checklist available
```

---

## Test Session Data

### MIN.json Test Data
```json
{
  "sessionKey": "MIN",
  "timestamp": 1759965000000,
  "typeSlug": "word",
  "state": {
    "sidePanel": {"expanded": true, "activeSection": "checklist-1"},
    "notes": {
      "textarea-1.1": "Test note for task 1.1",
      "textarea-1.2": "Test note for task 1.2"
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
    "created": 1759965000000,
    "lastModified": 1759965000000
  }
}
```

**Purpose**: Provides realistic test data for report.php tests with mixed statuses

---

## Success Criteria

After implementation, all tests should:

1. ✅ **Reports Dashboard**: All 8 tests pass
2. ✅ **User Report**: All 7 tests pass (including error conditions)
3. ✅ **Admin Tests**: Properly commented with explanation
4. ✅ **Overall**: 34/34 tests pass (100% success rate)
5. ✅ **Documentation**: Updated to reflect new test coverage

---

## Implementation Timeline

1. **Update test script** - Comment admin, add 15 new tests (~15 minutes)
2. **Run tests** - Execute full suite (~30 seconds)
3. **Debug any failures** - Fix issues if needed (~5-10 minutes)
4. **Update documentation** - Update all docs with new results (~5 minutes)
5. **Update changelog** - Document the changes (~5 minutes)

**Total Estimated Time**: 25-35 minutes

---

## Approval Checklist

Please confirm:

- [ ] Comment out admin.php tests (3 tests) ✓
- [ ] Add reports.php tests (8 tests) ✓
- [ ] Add report.php tests (7 tests) ✓
- [ ] Create temporary MIN.json for testing ✓
- [ ] Update test counters and documentation ✓
- [ ] Run full test suite after changes ✓

**Awaiting your approval to proceed with implementation.**

