# AccessiList - Testing Infrastructure

**Document Type:** Backend Developer Code Audit Reference
**Last Updated:** October 21, 2025
**Purpose:** Complete testing documentation with emphasis on browser E2E and programmatic validation
**Branch:** security-updates

---

## 📋 Overview

AccessiList uses a comprehensive testing strategy with **70 total tests** across three main categories:
- **Browser E2E Tests** - 15 tests (Ground truth validation)
- **Programmatic Tests** - 53 tests (Automated validation)
- **Permissions Tests** - 2 tests (File system checks)

**Testing Philosophy:** Browser tests are ground truth. If browser passes but programmatic fails → Fix the test.

---

## 🎯 Testing Philosophy

### Browser Tests = Ground Truth

**Core Principle:** If a browser can do it, the app works. Tests are diagnostic tools.

**Decision Tree:**
```
Browser Test Result?
├─ ✅ PASS → App works, ship it
│   └─ Programmatic fails? → Fix the test
├─ ❌ FAIL → App broken
    └─ Programmatic passes? → False confidence, fix app
```

**Why:**
- Browsers are the real runtime environment
- Users experience what browsers render
- Programmatic tests can't catch visual/UX issues
- False positives in programmatic tests waste time

**Integration:**
- `test-production.sh` runs browser E2E in Phase 2
- `diagnose-test-failures.sh` prompts to run browser validation
- If browser passes → Diagnostic exits ("fix the test")

---

## 🌐 Phase 1: Programmatic Tests (53 Tests)

### Overview
**Command:** `./scripts/external/test-production.sh` (Phase 1 only)
**Environment:** Live production (webaim.org)
**Purpose:** Automated validation of APIs, routing, and content

### Test Categories

#### 1. API Endpoints (8 tests)
- Health check
- Generate key
- Instantiate
- Save
- Restore
- List
- List-detailed
- Delete

#### 2. Page Load Tests (5 tests)
- Home page (/)
- List page (/list?type=word)
- List report (/list-report?session=TEST)
- Systemwide report (/systemwide-report)
- AEIT page

#### 3. URL Routing (6 tests)
- Extensionless PHP files
- API extensionless
- Root-level clean URLs
- Parameter preservation
- Static asset access
- Root redirect

#### 4. Session Workflow (5 tests)
- Generate session key
- Create session
- Save checklist
- Restore checklist
- Delete session

#### 5. Content Verification (6 tests)
- Home page content
- List page content
- Report page content
- Security headers
- Meta tags
- Footer rendering

#### 6. Static Assets (5 tests)
- CSS loading
- JavaScript loading
- JSON templates loading
- Images loading
- SVG icons

#### 7. Error Handling (6 tests)
- 404 handling
- Invalid session handling
- Malformed requests
- Invalid type slug
- Missing parameters
- API errors

#### 8. Security Tests (5 tests)
- Security headers present
- Origin validation (entry point)
- Cache-Control headers
- Content-Type headers
- HTTPS enforcement

#### 9. Type Validation (5 tests)
- Valid types accepted (word, powerpoint, excel, etc.)
- Invalid types rejected
- Default type fallback
- Type configuration loading
- Type metadata validation

#### 10. Environment Configuration (2 tests)
- JS environment config injected
- Environment-specific paths correct

### Running Tests

```bash
# Programmatic only (Phase 1)
./scripts/external/test-production.sh --phase 1

# All phases (includes browser E2E)
./scripts/external/test-production.sh
```

### Test Output
```
═══════════════════════════════════════════
Phase 1: Programmatic Validation
═══════════════════════════════════════════
[1/53] ✓ Health check
[2/53] ✓ Generate key
...
[53/53] ✓ Environment paths

Phase 1: 53/53 tests passed (100%)
```

---

## 🌐 Phase 2: Browser E2E Tests (15 Tests) - GROUND TRUTH

### Overview
**Command:** `./scripts/external/browser-test-playwright.sh`
**Environment:** Live production (webaim.org)
**Purpose:** Real user interaction validation with Playwright
**Status:** Ground truth - if these pass, app works

### Test Categories

#### 1. Home Page & Navigation (3 tests)
- Home page loads and displays correctly
- Navigation to list page works
- Back button returns to home

#### 2. Checklist Creation (3 tests)
- Session generation
- Type selection (Word, PowerPoint, Excel)
- Checklist instantiation

#### 3. User Interactions (4 tests)
- Checkpoint status toggle (Ready → Active → Done)
- Textarea input and persistence
- Filter buttons (All, Done, Active, Ready)
- Side panel navigation

#### 4. Save & Restore (3 tests)
- Manual save via button click
- Session restoration from URL
- State persistence across page reloads

#### 5. Reports (2 tests)
- List report with session
- Systemwide report dashboard

### Running Tests

```bash
# Browser E2E only (Phase 2)
./scripts/external/browser-test-playwright.sh

# As part of full test suite
./scripts/external/test-production.sh  # Includes Phase 2
```

### Test Output
```
═══════════════════════════════════════════
Phase 2: Browser E2E Tests (Playwright)
═══════════════════════════════════════════
✓ Home page loads
✓ Navigate to checklist
✓ Create new session
✓ Toggle checkpoint status
✓ Input textarea notes
✓ Apply filters
✓ Save checklist
✓ Restore from session
✓ Navigate side panel
✓ View list report
✓ View systemwide report
✓ Back to home
✓ Select different type
✓ Multi-checkpoint workflow
✓ Session persistence

Phase 2: 15/15 tests passed (100%)
```

### Playwright Configuration

**Browser:** Chromium (headless)
**Viewport:** 1280x720
**Timeout:** 30 seconds per test
**Screenshots:** On failure only

---

## 🔒 Phase 3: Permissions Tests (2 Tests)

### Overview
**Command:** Part of `./scripts/external/test-production.sh`
**Purpose:** Verify file system permissions for session storage

### Tests

#### 1. Sessions Directory Writable
- Verify `/var/websites/.../etc/sessions/` exists
- Test write permission
- Test file creation
- Cleanup test files

#### 2. Sessions Directory HTTP Blocked
- Verify HTTP access returns 403 Forbidden
- Confirm sessions not web-accessible

### Test Output
```
═══════════════════════════════════════════
Phase 3: Permissions Validation
═══════════════════════════════════════════
✓ Sessions directory writable
✓ Sessions directory HTTP blocked (403)

Phase 3: 2/2 tests passed (100%)
```

---

## 🧪 Apache Testing Methods (Legacy)

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

## 📊 Test Execution Summary

### Current Test Status

**Date:** October 21, 2025
**Environment:** Live production (webaim.org)
**Total Tests:** 70
**Passed:** 70
**Failed:** 0
**Success Rate:** 100%

### Coverage Summary

| Test Phase | Tests | Status | Purpose |
|------------|-------|--------|---------|
| Programmatic | 53 | ✅ 100% | Automated validation |
| Browser E2E | 15 | ✅ 100% | Ground truth |
| Permissions | 2 | ✅ 100% | File system |

### Component Coverage

| Component | Tests | Status |
|-----------|-------|--------|
| API Endpoints | 8 | ✅ 100% |
| Page Load | 5 | ✅ 100% |
| URL Routing | 6 | ✅ 100% |
| Session Workflow | 5 | ✅ 100% |
| Content Verification | 6 | ✅ 100% |
| Static Assets | 5 | ✅ 100% |
| Error Handling | 6 | ✅ 100% |
| Security | 5 | ✅ 100% |
| Type Validation | 5 | ✅ 100% |
| Environment | 2 | ✅ 100% |
| Browser E2E | 15 | ✅ 100% |
| Permissions | 2 | ✅ 100% |

### Test Duration
- **Programmatic:** ~2 minutes
- **Browser E2E:** ~3 minutes
- **Permissions:** ~10 seconds
- **Total:** ~5 minutes for full suite

---

## 🎯 Testing Strategy

### Continuous Testing Workflow

```
Code Change
  ↓
Deploy to production
  ↓
Run test-production.sh (all 3 phases)
  ↓
Phase 1: Programmatic (53 tests) → Pass?
  ↓
Phase 2: Browser E2E (15 tests) → Pass?
  ↓
Phase 3: Permissions (2 tests) → Pass?
  ↓
All pass? → Deployment verified ✅
```

### Pre-Deployment Checklist
1. ✅ Review linter errors
2. ✅ Manual smoke test
3. ✅ Check changelog updated
4. ✅ Deploy to production
5. ✅ Run full test suite

### Post-Deployment Verification
1. Run `./scripts/external/test-production.sh` (all phases)
2. Verify browser E2E tests pass (ground truth)
3. Monitor for errors
4. Spot-check key workflows
5. Verify session save/restore works

### Diagnostic Workflow (When Tests Fail)
1. Run `./scripts/external/diagnose-test-failures.sh`
2. Diagnostic prompts: "Run browser validation?"
3. If browser passes → Fix the test
4. If browser fails → Fix the app

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
