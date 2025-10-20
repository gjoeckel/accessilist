# AccessiList - Testing Infrastructure

**Document Type:** Backend Developer Code Audit Reference
**Last Updated:** October 20, 2025
**Purpose:** Complete testing documentation with emphasis on proj-test-mirror and external-test-production
**Branch:** cleanup-and-scope-server-files

---

## 📋 Overview

AccessiList uses a comprehensive testing strategy with **143 total tests** across two main suites:
- **proj-test-mirror** - 101 tests (Local Docker Apache - 100% pass rate)
- **external-test-production** - 42 tests (Live production server)

Both test suites are available as workflows for easy execution.

---

## 🐳 Production Mirror Testing (101 Tests)

### Overview
**Workflow:** `proj-test-mirror`
**Command:** `./scripts/test-production-mirror.sh`
**Environment:** Docker Apache (port 8080)
**Pass Rate:** 101/101 (100%)

### Test Categories

#### 1. Prerequisites Check (4 tests)
- PHP module detection
- mod_rewrite enabled
- .env configuration (local)
- .htaccess presence

#### 2. Basic Connectivity (2 tests)
- Root redirect (HTTP 302)
- Index.php redirect (HTTP 302)

#### 3. Clean URL Routes (2 tests)
- `/home` clean URL (HTTP 200)
- `/systemwide-report` clean URL (HTTP 200)

#### 4. Direct PHP Access (3 tests)
- `/php/home.php` (HTTP 200)
- `/php/systemwide-report.php` (HTTP 200)
- `/php/list.php` (HTTP 200)

#### 5. API Endpoints Extensionless (2 tests)
- `/php/api/health` (HTTP 200)
- `/php/api/list` (HTTP 200)

#### 6. API Endpoints with .php (2 tests)
- `/php/api/health.php` (HTTP 200)
- `/php/api/list.php` (HTTP 200)

#### 7. Static Assets (3 tests)
- CSS file (HTTP 200)
- JavaScript file (HTTP 200)
- JSON template (HTTP 200)

#### 8. Content Verification (2 tests)
- Home page contains "Accessibility Checklists"
- Systemwide report contains "Systemwide Report"

#### 9. Save/Restore API Workflow (4 tests)
- Instantiate API (session creation)
- Save API (state persistence)
- Session file created
- Restore API (state retrieval)

#### 10. Minimal URL Parameter Tracking (1 test)
- Minimal URL format `/?=MIN` (HTTP 200)

#### 11. Error Handling (2 tests)
- 404 for missing page
- 404 for missing file

#### 12. Security & Headers (2 tests)
- Cache-Control header present
- Content-Type header present

#### 13. Environment Configuration (2 tests)
- JS environment config injected
- Environment-specific paths correct

#### 14-28. Systemwide Reports Dashboard (16 tests)
- Page load verification
- List-detailed API endpoint
- JavaScript module loading
- Filter buttons (Done, Active, Not Started)
- Reports table structure
- Status/Progress columns
- Refresh and Home buttons
- CSS file loading
- Caption and section elements

#### 29-41. List Report Page (13 tests)
- Valid session handling
- Heading and JS module
- CSS file loading
- Filter functionality
- Table structure
- Back and Refresh buttons
- Invalid session handling
- Missing/malformed parameters
- Filter labels

#### 42. Scroll Buffer Configuration (4 tests)
- List scroll buffer (restoration disabled, scroll.js loaded)
- List-report scroll buffer (120px buffer, 130px scroll, dynamic function)
- Systemwide-report scroll buffer (120px buffer, 130px scroll)
- Report buffer target position (400px from top)

#### 43. Side Panel All Button (2 tests)
- All button clickability (CSS min dimensions, pointer-events)
- Pointer-events pass-through (container: none, children: auto)

#### 44-52. Read-Only Scrollable Textareas (9 tests)
- readOnly attribute (not disabled)
- Tab order exclusion (tabindex="-1")
- Scrollbar styling
- Pointer-events for scrolling (auto)
- Hover effects removed
- Focus.css readonly exclusion
- Table.css readonly exclusion
- Checkpoint click buffer recalc
- Sequential scroll execution (requestAnimationFrame)

#### 53-57. Dynamic Checkpoint Validation (5 tests)
- Camtasia: 3 checkpoints
- Word: 4 checkpoints
- PowerPoint: 4 checkpoints
- Excel: 4 checkpoints
- Slides: 4 checkpoints

#### 58-64. AEIT Link Visibility (7 tests)
- AEIT link element in footer template
- PowerPoint config has aeitLink true
- Dojo config has aeitLink false
- AEIT link in footer template
- setAEITLinkHref function exists
- AEIT link uses TypeManager
- Footer separator in template

#### 65-71. AEIT Page Functionality (7 tests)
- AEIT page with session (HTTP 200)
- AEIT page without session (HTTP 200)
- Content verification (Eric J Moore)
- Back button with session (present)
- Back button without session (not rendered)
- CSS loaded (aeit.css)
- Skip link present

#### 72-76. Scroll Buffer Behavior Path A/B (5 tests)
- scroll.js file exists
- updateChecklistBuffer function defined
- Path A/B logic (no-scroll class toggle)
- CSS no-scroll class (overflow:hidden)
- Path B bottom buffer (100px)

#### 77-79. ScrollManager Global API (3 tests)
- ScrollManager export
- updateReportBuffer function
- scheduleReportBufferUpdate function

#### 80-81. Additional Clean URL Routes (2 tests)
- AEIT clean URL (HTTP 200)
- List clean URL with parameters (HTTP 200)

#### 82-83. Footer Rendering Variations (2 tests)
- list.php uses status footer
- AEIT page uses standard footer

### Running Tests

```bash
# Using workflow
proj-test-mirror

# Manual execution
docker compose up -d
./scripts/test-production-mirror.sh
```

### Test Output
```
╔════════════════════════════════════════════════════════╗
║  ✅ ALL TESTS PASSED! Production mirror verified! ✅  ║
╚════════════════════════════════════════════════════════╝

Total Tests:    101
Passed:         101
Failed:         0
Success Rate:   100%
```

---

## 🌐 External Production Testing (42 Tests)

### Overview
**Workflow:** `external-test-production`
**Command:** `./scripts/external/test-production.sh`
**Environment:** Live production (webaim.org)
**Purpose:** Post-deployment verification

### Test Categories

#### 1. Basic Connectivity (3 tests)
- Home page loads
- Clean URL routing
- Root redirect

#### 2. Page Load Tests (4 tests)
- Home page (/)
- List page (/list?type=word)
- List report (/list-report?session=TEST)
- Systemwide report (/systemwide-report)

#### 3. API Endpoints (8 tests)
- Health check
- Generate key
- Instantiate
- Save
- Restore
- List
- List-detailed
- Delete

#### 4. URL Routing (5 tests)
- Extensionless PHP files
- API extensionless
- Root-level clean URLs
- Parameter preservation
- Static asset access

#### 5. Session Workflow (4 tests)
- Generate session key
- Create session
- Save checklist
- Restore checklist

#### 6. Type Validation (4 tests)
- Valid types accepted
- Invalid types rejected
- Default type fallback
- Type configuration loading

#### 7. Content Verification (3 tests)
- Home page content
- List page content
- Report page content

#### 8. Static Assets (3 tests)
- CSS loading
- JavaScript loading
- JSON templates loading

#### 9. Error Handling (3 tests)
- 404 handling
- Invalid session handling
- Malformed requests

#### 10. Production Environment (5 tests)
- Apache version
- PHP version
- mod_rewrite enabled
- SSL/HTTPS
- Proper headers

### Running Tests

```bash
# Using workflow
external-test-production

# Manual execution
./scripts/external/test-production.sh
```

### Test Output
```
Testing Production: https://webaim.org/training/online/accessilist

[1/42] ✓ Home page loads
[2/42] ✓ Clean URL routing works
...
[42/42] ✓ Proper security headers

Summary: 42/42 tests passed (100%)
```

---

## 🧪 Apache Testing Methods

### Three Approaches Researched

#### 1. Docker Apache (CHOSEN)
**Pros:**
- Exact production parity (Apache 2.4 + PHP 8.1)
- No system-level changes
- Isolated environment
- CI/CD ready

**Cons:**
- Requires Docker installation
- Slightly slower than native

#### 2. macOS Native Apache
**Pros:**
- Fast local testing
- No containers needed

**Cons:**
- Requires sudo configuration
- System-level changes
- macOS-specific issues

#### 3. PHP Built-in Server
**Pros:**
- Simple to start
- No configuration

**Cons:**
- Doesn't test mod_rewrite
- Not production-like
- Development only

**Decision:** Docker chosen for production parity and CI/CD integration.

---

## 📊 Local Test Report

### Test Execution Results

**Date:** October 20, 2025
**Environment:** Docker Apache (accessilist-apache container)
**Total Tests:** 101
**Passed:** 101
**Failed:** 0
**Success Rate:** 100%

### Coverage Summary

| Component | Tests | Status |
|-----------|-------|--------|
| URL Routing | 11 | ✅ 100% |
| API Endpoints | 10 | ✅ 100% |
| Page Rendering | 8 | ✅ 100% |
| Save/Restore | 7 | ✅ 100% |
| Scroll System | 14 | ✅ 100% |
| Side Panel | 10 | ✅ 100% |
| AEIT Feature | 10 | ✅ 100% |
| Static Assets | 6 | ✅ 100% |
| Error Handling | 5 | ✅ 100% |
| Security | 4 | ✅ 100% |
| Environment | 4 | ✅ 100% |
| Checkpoints | 5 | ✅ 100% |
| Textareas | 9 | ✅ 100% |

### Test Duration
- **Average:** 2.5 seconds per test
- **Total:** ~4 minutes for full suite

---

## 🎯 Testing Strategy

### Continuous Testing Workflow

```
Code Change
  ↓
Run proj-test-mirror (101 tests)
  ↓
All pass? → Commit
  ↓
Deploy to production
  ↓
Run external-test-production (42 tests)
  ↓
All pass? → Deployment verified
```

### Pre-Deployment Checklist
1. ✅ Run `proj-test-mirror` - must be 100%
2. ✅ Review linter errors
3. ✅ Manual smoke test
4. ✅ Check changelog updated
5. ✅ Deploy to production
6. ✅ Run `external-test-production`

### Post-Deployment Verification
1. Run `external-test-production`
2. Manual check of key features
3. Monitor for errors
4. Verify session save/restore
5. Check all checklist types load

---

## 🔧 Test Session Guide

### Creating Test Sessions

```bash
# Generate session key
curl http://localhost:8080/php/api/generate-key

# Create session
curl -X POST http://localhost:8080/php/api/instantiate \
  -H "Content-Type: application/json" \
  -d '{"sessionKey":"TST","typeSlug":"word"}'

# Save state
curl -X POST http://localhost:8080/php/api/save \
  -H "Content-Type: application/json" \
  -d '{
    "sessionKey":"TST",
    "typeSlug":"word",
    "state":{"statusButtons":{"0":"done"},"textareas":{"0":"Test notes"}}
  }'

# Restore state
curl "http://localhost:8080/php/api/restore?sessionKey=TST"
```

### Test Session Keys
- **Production:** 3-char alphanumeric (ABC, 5K2)
- **Test:** Longer format allowed (TEST-PROGRESS-50)
- **Reserved:** WRD, PPT, XLS, DOC, SLD, CAM, DJO (demos)

---

## 📚 Related Documentation

- **[GENERAL-ARCHITECTURE.md](GENERAL-ARCHITECTURE.md)** - Docker environment, server config
- **[SAVE-AND-RESTORE.md](SAVE-AND-RESTORE.md)** - API endpoints tested
- **[LIST-USER-INTERFACE.md](LIST-USER-INTERFACE.md)** - UI components tested
- **[SYSTEMWIDE-REPORT.md](SYSTEMWIDE-REPORT.md)** - Report page tests
- **[LIST-REPORT.md](LIST-REPORT.md)** - List report tests

---

*Document Created: October 20, 2025*
*Synthesized from: TESTING.md, PRODUCTION-MIRROR-TESTING.md, EXTERNAL-PRODUCTION-TESTING.md, APACHE-TESTING-METHODS-RESEARCH.md, LOCAL-TEST-REPORT.md, TEST-SESSION-GUIDE.md*
*Status: Complete testing infrastructure documentation*
