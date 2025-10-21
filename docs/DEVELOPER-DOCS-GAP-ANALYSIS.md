# DEVELOPER Documentation Gap Analysis
**Date:** 2025-10-21
**Analysis Method:** E2E code review vs. documentation
**Files Reviewed:** 12 DEVELOPER/*.md files

---

## 📊 Summary

| Document | Status | Gaps Found | Severity | Action Required |
|----------|--------|------------|----------|-----------------|
| CORE2.md | 🟢 Current | 0 | None | ✅ Updated today |
| SECURITY.md | 🔴 Outdated | 5 major | Critical | ⚠️ Update immediately |
| TESTING.md | 🔴 Outdated | 4 major | High | ⚠️ Update immediately |
| DEPLOYMENT.md | 🟡 Outdated | 3 medium | Medium | Update soon |
| SAVE-AND-RESTORE.md | 🟢 Mostly Current | 1 minor | Low | Minor update |
| GENERAL-ARCHITECTURE.md | 🟢 Current | 0 | None | ✅ Accurate |
| LIST-REPORT.md | 🟢 Current | 0 | None | ✅ Accurate |
| LIST-USER-INTERFACE.md | 🟢 Current | 0 | None | ✅ Accurate |
| SYSTEMWIDE-REPORT.md | 🟢 Current | 0 | None | ✅ Accurate |
| CONSOLE-LOGGING-ANALYSIS.md | 🟢 Current | 0 | None | ✅ Implemented |
| ROLLBACK_PLAN.md | 🟢 Current | 0 | None | ✅ Still relevant |
| SSH-SETUP.md | 🟡 Outdated | 1 minor | Low | Update key name |

**Total Gaps:** 14 (5 critical, 4 high, 3 medium, 2 low)

---

## 🔴 CRITICAL GAPS (Update Immediately)

### 1. SECURITY.md - CSRF Implementation **COMPLETELY CHANGED**

#### **What Doc Says:**
```markdown
### 1. CSRF Protection ✅
**Implementation:**
- Session-based token in meta tag
- validate_csrf_from_header() in all POST endpoints
- 64-char session-based token
- Requires cookies
```

#### **Current Reality:**
```php
// NEW: Origin-based validation (NO cookies!)
require_once __DIR__ . '/../includes/origin-check.php';
validate_origin();  // Simple, no sessions, no cookies
```

**Gaps:**
- ❌ Doc says session-based CSRF - **WRONG**, now origin-based
- ❌ Doc says all POST endpoints have validate_csrf_from_header() - **WRONG**, removed
- ❌ Doc says requires cookies - **WRONG**, cookie-free now
- ❌ Missing: origin-check.php documentation
- ❌ Missing: csrf-stateless.php option (alternative implementation)

**Impact:** Developers would implement the WRONG security model

**Fix Required:**
```markdown
### 1. CSRF Protection ✅ (Origin-Based)
**What:** Prevents cross-site request forgery attacks
**Method:** Origin header validation (cookie-free)
**Where:** Entry point only (instantiate.php)

**Implementation:**
```php
// Server-side (entry point validation)
require_once __DIR__ . '/../includes/origin-check.php';
validate_origin();  // Validates HTTP Origin header
```

**Allowed Origins:**
- https://webaim.org
- https://www.webaim.org
- http://localhost:8000 (development)

**Benefits:**
- ✅ No cookies required
- ✅ Works with privacy settings
- ✅ Simple (20 lines vs 300)
- ✅ No session state needed

**Alternative:** Stateless CSRF (php/includes/csrf-stateless.php) for enhanced security
```

---

### 2. SECURITY.md - Rate Limiting Status **WRONG**

#### **What Doc Says:**
```markdown
### 2. Rate Limiting ✅
**Where:** All API endpoints
**Current Limits:**
/api/save         → 100 requests/hour per IP
/api/instantiate  → 20 requests/hour per IP
...
```

#### **Current Reality:**
```php
// TEMPORARILY DISABLED: Rate limiting causing test failures
// TODO: Re-enable after testing is stable with more lenient limits
// enforce_rate_limit_smart('instantiate');
```

**Gaps:**
- ❌ Doc says rate limiting active - **WRONG**, currently disabled
- ❌ Doc lists specific limits - **IRRELEVANT**, all commented out
- ❌ Missing: Reason for disabling (blocked testing)
- ❌ Missing: Plan for re-enabling with lenient limits
- ❌ Missing: TODO markers location

**Impact:** Developers think rate limiting is active when it's not

**Fix Required:**
```markdown
### 2. Rate Limiting ⏸️ (Currently Disabled)
**Status:** TEMPORARILY DISABLED (2025-10-21)
**Reason:** Aggressive limits (20/hour) blocked all automated testing
**Plan:** Re-enable with more lenient limits after testing stabilizes

**Previous Limits (Too Strict):**
- /api/instantiate: 20/hour → Blocked test suites
- /api/save: 100/hour → Blocked rapid saves
- /api/delete: 50/hour
- /api/restore: 200/hour
- /api/list: 100/hour

**Proposed New Limits:**
- /api/instantiate: 200/hour (10x more lenient)
- /api/save: 1000/hour (10x more lenient)
- Others: Similar increases

**Code Location:**
All 5 API files have TODO comments:
```php
// TEMPORARILY DISABLED: Rate limiting causing test failures
// TODO: Re-enable after testing is stable with more lenient limits
```

**To Re-enable:**
1. Uncomment enforce_rate_limit_smart() in all 5 files
2. Adjust limits in rate-limiter.php
3. Test with automated suite
4. Deploy incrementally
```

---

### 3. SECURITY.md - Session Storage Location **OUTDATED**

#### **What Doc Says:**
```markdown
(Not mentioned in SECURITY.md - gap!)
```

#### **Current Reality:**
```
/var/websites/webaim/htdocs/training/online/
├── accessilist/       (web root)
├── accessilist2/      (web root)
└── etc/sessions/      (OUTSIDE web root - secure)
```

**Gaps:**
- ❌ No documentation of etc/sessions location
- ❌ No documentation of security benefits
- ❌ No documentation of shared storage between environments
- ❌ No documentation of HTTP blocking (403)

**Fix Required:**
Add new section:
```markdown
### 6. Secure Session Storage ✅
**What:** Sessions stored outside web root to prevent HTTP access
**Where:** `/var/websites/webaim/htdocs/training/online/etc/sessions/`

**Security Features:**
- ✅ Outside both web roots (accessilist and accessilist2)
- ✅ HTTP access returns 403 Forbidden
- ✅ Proper permissions (775 dir, 664 files)
- ✅ Owned by www-data
- ✅ Shared storage (both environments use same secure location)

**Verification:**
```bash
# Should return 403 Forbidden:
curl -I https://webaim.org/training/online/etc/sessions/ABC.json
```
```

---

### 4. SECURITY.md - Missing Header Ordering Critical Issue

**Gap:** No mention of header ordering requirement

**Current Critical Requirement:**
```php
// CRITICAL: session_start() MUST come before set_security_headers()
$GLOBALS['csrfToken'] = generate_csrf_token();  // Starts session, sets cookie
set_security_headers();  // Then send other headers
```

**If wrong order:**
- Headers already sent
- session_start() can't set cookies
- Silent failure
- Users completely blocked

**Fix Required:**
```markdown
### 7. Header Ordering ⚠️ CRITICAL
**Issue:** Headers must be sent in correct order or cookies fail silently

**CORRECT Order:**
```php
// 1. FIRST: Start session (sets cookie header)
$GLOBALS['csrfToken'] = generate_csrf_token();

// 2. THEN: Send other headers
set_security_headers();

// 3. FINALLY: Output HTML
renderHTMLHead();
```

**WRONG Order (breaks cookies):**
```php
set_security_headers();  // ← Headers sent
generate_csrf_token();    // ← Cookie fails (too late)
```

**Files That Must Follow This:**
- php/home.php ✅ Fixed
- php/list.php ✅ Fixed
- Any new pages that use sessions

**Detection:**
- Console shows "NO COOKIES"
- Sessions don't persist
- CSRF always fails
```

---

### 5. TESTING.md - Test Count **COMPLETELY WRONG**

#### **What Doc Says:**
```markdown
AccessiList uses a comprehensive testing strategy with **143 total tests**:
- proj-test-mirror - 101 tests (Local Docker Apache)
- external-test-production - 42 tests (Live production)
```

#### **Current Reality:**
```
Total Tests: 70 (not 143)
- Browser E2E: 15 tests
- Programmatic: 53 tests
- Permissions: 2 tests
```

**Gaps:**
- ❌ Doc says 143 tests - **WRONG**, actually 70
- ❌ Doc says 101 Docker tests - **OUTDATED**
- ❌ Doc says 42 production tests - **OUTDATED**
- ❌ Missing: Browser E2E test integration (NEW)
- ❌ Missing: Testing philosophy (browser = ground truth)

**Fix Required:**
Complete rewrite of TESTING.md to reflect new architecture

---

## 🟡 HIGH PRIORITY GAPS

### 6. TESTING.md - Testing Philosophy **MISSING**

**Gap:** No mention of "browser tests are ground truth" principle

**Current Critical Principle:**
```
Browser Test = Ground Truth
Programmatic Test = Diagnostic Only

If browser passes but programmatic fails → Fix the test
If both fail → Fix the app
```

**Fix Required:**
Add section from `docs/TESTING-PHILOSOPHY.md`

---

### 7. TESTING.md - Test Integration **NOT DOCUMENTED**

**Gap:** Doesn't mention browser validation in diagnostic workflow

**Current Implementation:**
- `diagnose-test-failures.sh` prompts to run browser test
- `test-production.sh` runs browser E2E automatically in Phase 2
- If browser passes → Diagnostic exits ("fix the test")

**Fix Required:**
Document the integrated workflow

---

### 8. DEPLOYMENT.md - Sessions Directory **WRONG**

#### **What Doc Says:**
```markdown
## 5) Writable paths and permissions
This app writes user progress JSON files to `php/saves/`

```bash
mkdir -p "$DEPLOY_PATH/php/saves" "$DEPLOY_PATH/saves"
chmod -R 775 "$DEPLOY_PATH/php/saves" "$DEPLOY_PATH/saves"
```

#### **Current Reality:**
```bash
# Sessions stored OUTSIDE application:
/var/websites/webaim/htdocs/training/online/etc/sessions/

# NOT in php/saves/ or saves/
```

**Gaps:**
- ❌ Doc says sessions in php/saves/ - **WRONG**, in etc/sessions/
- ❌ Doc shows wrong permissions setup
- ❌ Missing: etc/sessions/ directory creation
- ❌ Missing: Security benefits explanation

**Fix Required:**
```markdown
## 5) Session Storage Setup (Secure)

**Critical:** Sessions are stored OUTSIDE the application directory for security.

```bash
# Create sessions directory (outside web root)
sudo mkdir -p /var/websites/webaim/htdocs/training/online/etc/sessions
sudo chown www-data:www-data /var/websites/webaim/htdocs/training/online/etc/sessions
sudo chmod 775 /var/websites/webaim/htdocs/training/online/etc/sessions

# Verify HTTP access is blocked
curl -I https://webaim.org/training/online/etc/sessions/
# Should return: 403 Forbidden ✅
```

**Directory Structure:**
```
/var/websites/webaim/htdocs/training/online/
├── accessilist/       (web root)
├── accessilist2/      (web root)
└── etc/               (OUTSIDE web roots)
    ├── .env           (shared config)
    ├── .env.accessilist2 (test config)
    └── sessions/      (shared session storage - SECURE)
```

**Security Benefits:**
- ✅ Sessions not web-accessible (403)
- ✅ Shared between environments
- ✅ Outside both web roots
- ✅ Proper Apache blocking
```

---

### 9. DEPLOYMENT.md - Paths Reference Deprecated Structure

**What Doc Says:**
```markdown
Alias /training/online/accessilist \
      /var/websites/webaim/htdocs/training/online/accessilist
```

**Gap:** Mentions accessilist folder but not accessilist2 (test environment)

**Current Structure:**
- `/accessilist/` - Live production
- `/accessilist2/` - Test/staging environment
- Both use same etc/sessions/

**Fix Required:**
Document both environments

---

## 🟡 MEDIUM PRIORITY GAPS

### 10. SAVE-AND-RESTORE.md - Missing config.php Bug

**Gap:** Doesn't mention the critical requirement that all API files must load config.php

**Current Bug (Found Today):**
- 3 API files were missing `require_once config.php`
- Result: $sessionsPath = null
- APIs couldn't find session files

**Fix Required:**
```markdown
### ⚠️ CRITICAL: All API Files Must Load config.php First

**Requirement:**
```php
<?php
require_once __DIR__ . '/../includes/config.php'; // MUST BE FIRST!
require_once __DIR__ . '/../includes/api-utils.php';
```

**Why:**
- config.php sets global $sessionsPath
- config.php loads .env configuration
- Without it: $sessionsPath = null → APIs fail

**Files That MUST Have This:**
- ✅ php/api/instantiate.php
- ✅ php/api/save.php
- ✅ php/api/restore.php
- ✅ php/api/delete.php
- ✅ php/api/list.php
- ✅ php/api/list-detailed.php
- ⚠️ php/api/generate-key.php (needs sessions)
- ❌ php/api/health.php (doesn't need sessions)
```

---

### 11. TESTING.md - Browser Test Suite Not Documented

**Gap:** Browser E2E tests exist but aren't documented

**Current Implementation:**
- 15 comprehensive browser tests
- Playwright automation
- Integrated into test-production.sh
- 100% passing

**Fix Required:**
Add complete browser test documentation

---

### 12. CORE2.md - New Files Not in Manifest

**Already Fixed Today** ✅ but worth noting what was added:

**Added:**
- php/includes/csrf.php
- php/includes/csrf-stateless.php
- php/includes/security-headers.php
- php/includes/rate-limiter.php
- php/includes/origin-check.php
- php/api/test-stateless-csrf.php
- php/home-stateless-test.php

---

## 🟢 LOW PRIORITY GAPS

### 13. SSH-SETUP.md - Key Name Changed

**What Doc Says:**
- Key: `~/.ssh/accessilist_deploy`

**Current Reality:**
- Key: `~/.ssh/GeorgeWebAIMServerKey.pem`

**Fix:** Update references

---

### 14. DEPLOYMENT.md - .env Configuration Not Documented

**Gap:** No mention of .env file setup

**Current Requirement:**
- `.env` file must exist at `/var/websites/.../online/etc/.env`
- `.env.accessilist2` for test environment
- Contains BASE_PATH, API_EXT, DEBUG, SESSIONS_PATH

**Fix Required:**
Document .env setup process

---

## 📋 DETAILED FILE-BY-FILE ANALYSIS

### 1. SECURITY.md (7.7K) 🔴 **CRITICAL UPDATES NEEDED**

**Last Updated:** October 21, 2025 (but content is outdated)

**Misalignments:**

| Section | Doc Says | Current Reality | Gap Severity |
|---------|----------|----------------|--------------|
| **CSRF Protection** | Session-based, cookies required | Origin validation, cookie-free | 🔴 Critical |
| **Rate Limiting** | Active with specific limits | Disabled temporarily | 🔴 Critical |
| **Session Storage** | Not mentioned | etc/sessions outside web root | 🔴 Critical |
| **Header Ordering** | Not mentioned | CRITICAL requirement | 🔴 Critical |
| **File List** | Missing 5 security files | origin-check, csrf-stateless, etc. | 🟡 Medium |

**Action Required:**
1. Update CSRF section (session → origin)
2. Update rate limiting section (active → disabled with plan)
3. Add session storage security section
4. Add header ordering warning
5. Document all security include files

**Estimated Time:** 30 minutes

---

### 2. TESTING.md (11K) 🔴 **MAJOR REWRITE NEEDED**

**Last Updated:** October 20, 2025

**Misalignments:**

| Section | Doc Says | Current Reality | Gap Severity |
|---------|----------|----------------|--------------|
| **Total Tests** | 143 tests | 70 tests | 🔴 Critical |
| **Test Suites** | proj-test-mirror (101) + external (42) | Browser E2E (15) + Programmatic (53) + Perms (2) | 🔴 Critical |
| **Testing Philosophy** | Not mentioned | Browser = ground truth | 🔴 Critical |
| **Browser Integration** | Not mentioned | Automatic in Phase 2 | 🟡 High |
| **Diagnostic Workflow** | Not mentioned | Browser validation integrated | 🟡 High |

**Action Required:**
1. Update test counts and categories
2. Add testing philosophy section
3. Document browser E2E suite (15 tests)
4. Document diagnostic integration
5. Remove outdated proj-test-mirror references

**Estimated Time:** 45 minutes

**Suggested Structure:**
```markdown
## Testing Architecture (70 Total Tests)

### Phase 1: Programmatic Tests (53 tests)
- API endpoints
- Security headers
- Static assets
- Content verification
...

### Phase 2: Browser E2E Tests (15 tests) - GROUND TRUTH
- User workflow validation
- Click interactions
- Form submission
- Navigation
- Save/restore
...

### Phase 3: Permissions (2 tests)
- Sessions directory writable
- File access validation
```

---

### 3. DEPLOYMENT.md (4.9K) 🟡 **MODERATE UPDATES NEEDED**

**Misalignments:**

| Section | Doc Says | Current Reality | Gap Severity |
|---------|----------|----------------|--------------|
| **Session Storage** | php/saves/ and saves/ | etc/sessions/ | 🟡 Medium |
| **Permissions Setup** | chmod php/saves/ | Setup etc/sessions/ | 🟡 Medium |
| **Environment Config** | Not mentioned | .env file required | 🟡 Medium |
| **Test Environment** | Mentions accessilist2 briefly | Full dual-environment setup | 🟢 Minor |

**Action Required:**
1. Update session storage location
2. Update permissions commands
3. Add .env configuration section
4. Clarify accessilist vs accessilist2 usage

**Estimated Time:** 20 minutes

---

### 4. CORE2.md (20K) 🟢 **CURRENT** ✅

**Last Updated:** Today (2025-10-21)

**Status:** Already updated with:
- ✅ Correct file counts (29 PHP files, 13 includes)
- ✅ All new security files listed
- ✅ Test files listed
- ✅ Accurate manifest

**Gaps:** None found ✅

---

### 5. SAVE-AND-RESTORE.md (10K) 🟢 **MOSTLY CURRENT**

**Minor Gap:**
- Doesn't mention critical config.php requirement
- Doesn't mention sessions path resolution

**Fix Required:**
Add note about config.php requirement (see Gap #10 above)

---

### 6. GENERAL-ARCHITECTURE.md (22K) 🟢 **CURRENT** ✅

**Status:** Accurate description of:
- Directory structure
- Technology stack
- URL routing
- TypeManager system
- Docker environment

**Gaps:** None significant

---

### 7. LIST-REPORT.md (17K) 🟢 **CURRENT** ✅
### 8. LIST-USER-INTERFACE.md (10K) 🟢 **CURRENT** ✅
### 9. SYSTEMWIDE-REPORT.md (13K) 🟢 **CURRENT** ✅

**Status:** All accurate and current

---

### 10. CONSOLE-LOGGING-ANALYSIS.md (10K) 🟢 **IMPLEMENTED** ✅

**Status:** Recommendation implemented via debug-utils.js
- ✅ Debug mode toggle exists
- ✅ Respects ENV.debug setting
- ✅ Errors/warnings always shown
- ✅ Debug logs hidden in production

**Gaps:** None, successfully implemented

---

### 11. ROLLBACK_PLAN.md (3.5K) 🟢 **STILL RELEVANT** ✅

**Status:** Generic rollback procedures, still applicable

---

### 12. SSH-SETUP.md (3.0K) 🟢 **MINOR UPDATE**

**Gap:** Key name changed
- Doc: `~/.ssh/accessilist_deploy`
- Reality: `~/.ssh/GeorgeWebAIMServerKey.pem`

---

## 🎯 PRIORITY ACTION ITEMS

### Immediate (Before Next Deployment):
1. ⚠️ **Update SECURITY.md** - CSRF and rate limiting sections (Critical)
2. ⚠️ **Update TESTING.md** - Test counts and philosophy (Critical)
3. ⚠️ **Update DEPLOYMENT.md** - Session storage location (High)

### Soon:
4. ✅ Add header ordering warning to SECURITY.md
5. ✅ Add config.php requirement to SAVE-AND-RESTORE.md
6. ✅ Update SSH key references

### Nice to Have:
7. ✅ Document browser test suite details
8. ✅ Document diagnostic workflow integration

---

## 📊 Gap Summary by Severity

**🔴 Critical (5 gaps):**
- SECURITY.md: CSRF implementation completely changed
- SECURITY.md: Rate limiting status wrong
- SECURITY.md: Session storage not documented
- SECURITY.md: Header ordering not mentioned
- TESTING.md: Test counts completely wrong

**🟡 High (4 gaps):**
- TESTING.md: Testing philosophy missing
- TESTING.md: Browser integration not documented
- DEPLOYMENT.md: Wrong session storage location
- DEPLOYMENT.md: .env configuration missing

**🟢 Medium (3 gaps):**
- DEPLOYMENT.md: Permission commands outdated
- SAVE-AND-RESTORE.md: config.php requirement missing
- CORE2.md: New files (already fixed)

**🟢 Low (2 gaps):**
- SSH-SETUP.md: Key name changed
- DEPLOYMENT.md: Dual environment not clarified

---

## 🔧 Recommended Documentation Updates

### Priority 1 (Critical):
```bash
# Update these 3 files immediately:
nano DEVELOPER/SECURITY.md      # Update CSRF, rate limiting, add session storage
nano DEVELOPER/TESTING.md        # Update test counts, add philosophy
nano DEVELOPER/DEPLOYMENT.md     # Update session storage location
```

### Priority 2 (High):
- Copy `docs/TESTING-PHILOSOPHY.md` content into TESTING.md
- Document browser validation workflow
- Add .env configuration guide

### Priority 3 (Cleanup):
- Update SSH key references
- Add config.php warnings
- Clean up outdated test references

---

## ✅ CONCLUSION

**7 out of 12 DEVELOPER docs are current and accurate** (58%)

**5 docs need updates:**
1. **SECURITY.md** - 5 critical gaps
2. **TESTING.md** - 4 high-priority gaps
3. **DEPLOYMENT.md** - 3 medium gaps
4. **SAVE-AND-RESTORE.md** - 1 minor gap
5. **SSH-SETUP.md** - 1 minor gap

**Estimated update time:** 2 hours total

**Most critical:** SECURITY.md (30 min) and TESTING.md (45 min)
