# 403 CSRF Error - E2E Diagnostic Analysis

## Test Results
- **Page loads**: ✅ Successfully
- **CSRF token in meta tag**: ✅ Present (64 chars)
- **Button click**: ❌ Does NOT redirect (stays on home page)
- **Expected behavior**: Should redirect to `/?=ABC` after creating session
- **Actual behavior**: Stays on home page (likely 403 from API)

## Identified Potential Issues

### Issue 1: Session Cookie Domain/Path Mismatch 🔴 HIGH PRIORITY
**Location**: `php/includes/config.php` lines 122-129

```php
session_set_cookie_params([
    'lifetime' => 0,
    'path' => '/',           // ← Set to '/'
    'domain' => '',          // ← Empty domain
    'secure' => true,
    'httponly' => true,
    'samesite' => 'Lax'
]);
```

**Problem**:
- Home page is at: `/training/online/accessilist2/home`
- Cookie path is: `/`
- API path is: `/training/online/accessilist2/php/api/instantiate`
- **Session cookie may not be sent with API requests** because of path mismatch

**Why this causes 403**:
1. Home page loads → `session_start()` creates cookie at path `/`
2. CSRF token saved in `$_SESSION['csrf_token']` with session ID `SESS123`
3. Browser sends cookie `PHPSESSID=SESS123` to home page (path `/`)
4. User clicks button → JavaScript sends POST to `/training/online/accessilist2/php/api/instantiate`
5. **Browser MAY NOT send cookie** to this subpath
6. API calls `session_start()` → gets NEW session ID `SESS456`
7. API looks for `$_SESSION['csrf_token']` in NEW session → **NOT FOUND**
8. API returns 403: "Invalid CSRF token"

**Fix**: Set cookie path to application base path:
```php
'path' => '/training/online/accessilist2/',
```

### Issue 2: Multiple session_start() Calls Creating New Sessions 🔴 HIGH PRIORITY
**Locations**:
- `php/home.php` line 12: `generate_csrf_token()` → `session_start()`
- `php/api/instantiate.php` line 21: `validate_csrf_from_header()` → `validate_csrf_token()` → `session_start()`

**Problem**:
Each file calls `session_start()` independently. If cookies aren't persisting correctly, each call creates a NEW session.

**Evidence**:
```php
// csrf.php line 44-46
if (session_status() === PHP_SESSION_NONE) {
    session_start();  // Creates NEW session if cookie not received
}
```

**Why this causes 403**:
- Session cookie not sent → New session created → CSRF token not found

### Issue 3: SameSite=Lax Blocking POST Requests ⚠️ MEDIUM PRIORITY
**Location**: `php/includes/config.php` line 128

```php
'samesite' => 'Lax'
```

**Problem**:
- `SameSite=Lax` blocks cookies on cross-site POST requests
- If browser treats API subdirectory as "different site", cookie may not be sent

**Scenarios where this fails**:
- User on `example.com/training/online/accessilist2/home`
- Sends POST to `example.com/training/online/accessilist2/php/api/...`
- Some browsers treat path changes as cross-site

**Fix**: Use `SameSite=None` for production (requires `secure=true` which is already set)

### Issue 4: Session Cookie Not Being Set Due to Headers Already Sent 🔴 CRITICAL
**Risk**: Output before session_start() prevents cookie from being set

**Locations to check**:
- Any `echo`, `print`, whitespace, or BOM before `session_start()`
- Files that are `require_once`'d before session starts

**Evidence needed**: Check PHP error logs for "headers already sent" warnings

## Diagnostic Logging Plan

### Phase 1: Add Session/Cookie Logging to debug-utils.js
Log when page loads:
- Session cookie presence/absence
- CSRF token from meta tag
- Session ID if available

### Phase 2: Add Server-Side Logging to CSRF validation
Log in `php/includes/csrf.php`:
- Session ID on token generation
- Session ID on token validation
- Token sent vs. token in session
- Cookie headers received

### Phase 3: Add API Logging to instantiate.php
Log:
- All request headers
- Cookie headers specifically
- Session ID when API receives request
- CSRF token validation result

## Recommended Immediate Fixes

1. **Change cookie path** to match application path
2. **Add comprehensive logging** to track session IDs
3. **Test with SameSite=None** to rule out cross-site issues
4. **Verify no headers sent before session_start()**

## Testing Plan
1. Fix Issue #1 (cookie path)
2. Deploy to accessilist2
3. Use Playwright to test button click with network logging
4. Review server logs for session ID mismatches
5. If still failing, apply fixes #2, #3, #4 sequentially
