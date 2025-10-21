# CSRF Debug Analysis
**Date:** October 21, 2025
**Issue:** Persistent "Invalid CSRF token" 403 errors on accessilist2
**Status:** ROOT CAUSE IDENTIFIED

---

## 🔴 **ROOT CAUSE IDENTIFIED**

### **Issue #1: CRITICAL - Headers Sent Too Early**

**Problem:** `api-utils.php` sends headers immediately on load (line 2)

**Code Flow:**
```php
// php/api/instantiate.php
require_once __DIR__ . '/../includes/config.php';     // Step 1: Sets session params
require_once __DIR__ . '/../includes/api-utils.php';  // Step 2: SENDS HEADERS! (line 2)
require_once __DIR__ . '/../includes/csrf.php';       // Step 3: Tries to start session
validate_csrf_from_header();                          // Step 4: Session fails - headers already sent
```

**The Problem in api-utils.php:**
```php
<?php
header('Content-Type: application/json');  // ← LINE 2: IMMEDIATE HEADER!
// This happens BEFORE csrf.php can call session_start()
```

**Impact:**
- Session cannot start after headers are sent
- New session created on each request
- CSRF tokens don't match (different sessions)
- Result: "Invalid CSRF token" error

**Evidence:**
```
PHP Warning: session_start(): Session cannot be started after headers have already been sent
```

---

## ⚠️ **POTENTIAL ISSUE #2: Session Cookie Mismatch**

**Problem:** Page load vs API call might create different sessions

**Scenario:**
1. User loads `/home` → Session A created, CSRF token `ABC123` generated
2. User clicks button → API call `/php/api/instantiate`
3. API loads files → Headers sent by api-utils.php line 2
4. Session B created (can't use Session A - headers already sent)
5. CSRF validation fails (token from Session A, validating against Session B)

**Current Behavior:**
```
Page Load:   PHPSESSID=xyz123, csrf_token=ABC123
API Call:    PHPSESSID=xyz456, csrf_token=DEF456  ← DIFFERENT SESSION!
Validation:  Token ABC123 ≠ Token DEF456  →  403 FORBIDDEN
```

---

## ⚠️ **POTENTIAL ISSUE #3: Config.php Not Loaded in api-utils.php**

**Problem:** `api-utils.php` is loaded by all APIs but doesn't load config.php itself

**Current Dependency:**
```
instantiate.php loads:
  ├── config.php (session params set)
  ├── api-utils.php (sends headers - line 2)
  ├── csrf.php (tries session_start - FAILS)
  └── rate-limiter.php
```

**If api-utils.php is loaded first anywhere:**
- Headers sent immediately
- Session params not set
- Sessions fail

---

## 🔍 **ADDITIONAL FINDINGS**

### Finding #1: fetchWithCsrf IS Deployed ✅
```bash
# Verified on server:
grep fetchWithCsrf /var/.../accessilist2/php/home.php
# Result: Line 112 uses fetchWithCsrf ✅
```

### Finding #2: CSRF Token EXISTS in Page ✅
```html
<meta name="csrf-token" content="1b4927d11ca183183912cdd6a21450ce...">
```

### Finding #3: csrf-utils.js IS Loaded ✅
```html
<script src="/training/online/accessilist2/js/csrf-utils.js?v=1761060387"></script>
```

### Finding #4: Session Cookie IS Set ✅
```
Set-Cookie: PHPSESSID=ac4ln97s3ake4u69letcjlr2fg; path=/; secure; HttpOnly; SameSite=Lax
```

**BUT:** Session can't persist because headers are sent too early!

---

## 🎯 **THREE POTENTIAL ISSUES**

### **1. Headers Sent Before Session Can Start** ⭐ ROOT CAUSE
- **Severity:** CRITICAL
- **Location:** `php/includes/api-utils.php` line 2
- **Impact:** Session fails, CSRF validation impossible
- **Confidence:** 99% - This is the smoking gun

### **2. Load Order Dependency**
- **Severity:** HIGH
- **Location:** File inclusion order in API endpoints
- **Impact:** If api-utils.php loads before config.php anywhere, breaks
- **Confidence:** 80% - Likely contributing factor

### **3. Session Isolation Between Requests**
- **Severity:** MEDIUM
- **Location:** Session handling across page load → API call
- **Impact:** Different sessions can't share CSRF tokens
- **Confidence:** 70% - Consequence of Issue #1

---

## 💡 **THREE PROPOSED FIXES**

### **FIX #1: Move header() Call to Functions** ⭐ RECOMMENDED
**Approach:** Don't send headers at file load time

**Change api-utils.php:**
```php
<?php
// DON'T send headers immediately
// header('Content-Type: application/json');  ← REMOVE THIS

function send_json($arr) {
  // Send header here instead
  if (!headers_sent()) {
    header('Content-Type: application/json');
  }
  echo json_encode($arr);
  exit;
}
```

**Benefits:**
- ✅ Session can start before any headers
- ✅ Minimal code changes
- ✅ Preserves all functionality
- ✅ Clean solution

**Effort:** 2 minutes
**Risk:** LOW

---

### **FIX #2: Alternative - Require config.php in api-utils.php**
**Approach:** Load config.php before sending headers

**Change api-utils.php:**
```php
<?php
// Load config first to set session params
require_once __DIR__ . '/config.php';

// Now safe to send headers
header('Content-Type: application/json');
```

**Benefits:**
- ✅ Ensures config always loaded
- ✅ Session params set before headers
- ✅ Works everywhere

**Drawbacks:**
- ⚠️ Circular dependency risk
- ⚠️ Config loaded multiple times
- ⚠️ Less clean architecture

**Effort:** 1 minute
**Risk:** MEDIUM (circular dependencies)

---

### **FIX #3: Alternative - Use output buffering**
**Approach:** Buffer output to delay headers

**Change api-utils.php:**
```php
<?php
// Start output buffering to delay headers
if (!headers_sent()) {
    ob_start();
}

header('Content-Type: application/json');

// Rest of file...

// At end, flush buffer
register_shutdown_function(function() {
    if (ob_get_level() > 0) {
        ob_end_flush();
    }
});
```

**Benefits:**
- ✅ Delays header sending
- ✅ Allows session_start() later
- ✅ No structural changes

**Drawbacks:**
- ⚠️ Adds complexity
- ⚠️ Output buffering can mask errors
- ⚠️ Harder to debug

**Effort:** 5 minutes
**Risk:** MEDIUM

---

## 🏆 **RECOMMENDED SOLUTION**

**Use FIX #1: Move header() into send_json() function**

**Why:**
1. ✅ Cleanest solution
2. ✅ Headers only sent when actually needed
3. ✅ No circular dependencies
4. ✅ Lowest risk
5. ✅ Best practice (headers should be in response functions)

**Implementation:**
1. Remove `header('Content-Type: application/json');` from line 2 of api-utils.php
2. Add header check in send_json() function
3. Test locally
4. Deploy to accessilist2
5. Validate CSRF works

**Expected Result:**
- Session starts successfully
- CSRF tokens persist across requests
- Validation succeeds
- 403 errors resolved

---

## 🧪 **HOW TO VERIFY THE FIX**

### Before Fix:
```bash
# Test session creation
ssh ... "cd accessilist2/php/api && php -r '...' 2>&1 | grep 'headers already sent'"
# Output: Warning about headers sent
```

### After Fix:
```bash
# Same test - no warning
# Session starts successfully
```

### Browser Test:
1. Open DevTools → Application → Cookies
2. Load page → Note PHPSESSID value
3. Create checklist → Check if same PHPSESSID used
4. Should be same session = CSRF works ✅

---

## 📊 **CONFIDENCE LEVELS**

| Issue | Confidence | Evidence |
|-------|------------|----------|
| Headers sent too early | 99% | PHP warning, code inspection |
| Load order dependency | 80% | Code structure analysis |
| Session isolation | 70% | Consequence of #1 |

| Fix | Success Probability | Risk |
|-----|---------------------|------|
| Move header to function | 95% | LOW |
| Require config in api-utils | 75% | MEDIUM |
| Output buffering | 60% | MEDIUM |

---

## ⏸️ **WAITING FOR APPROVAL**

**Next Step:** Implement FIX #1 (move header to send_json function)?

This is the cleanest solution with highest success probability and lowest risk.
