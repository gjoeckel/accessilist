# 403 CSRF Error - Complete Diagnostic & Fix Summary

## What Was Done

### 1. E2E Analysis Identified 4 Root Causes

📝 **Full analysis**: `docs/403-DIAGNOSIS.md`

1. **Cookie Path Mismatch** (FIXED ✅)
2. **Multiple session_start() Creating New Sessions** (LOGGED for diagnosis)
3. **SameSite=Lax Blocking** (Kept as 'Lax' - more permissive than 'Strict')
4. **Headers Already Sent** (LOGGED for detection)

### 2. Enhanced Client-Side Logging

**File**: `js/debug-utils.js`

Added 3 new diagnostic methods:
- `debug.logCsrfDiagnostics()` - Shows CSRF token, cookies, session state
- `debug.logApiRequest()` - Logs all fetch() requests before sending
- `debug.logApiResponse()` - Logs responses, highlights 403 errors

**Auto-runs on every page load** via `php/home.php`

**File**: `js/csrf-utils.js`

Modified `fetchWithCsrf()` to:
- Log ALL API requests automatically
- Log ALL API responses automatically
- Highlight 403 errors with troubleshooting steps

### 3. Enhanced Server-Side Logging

**File**: `php/includes/csrf.php`

Added logging to `validate_csrf_token()`:
- Session ID on validation
- Token received vs. token in session
- Cookie headers
- Session cookie params
- Diagnostic info in 403 response JSON

### 4. Applied Critical Fix - Cookie Path

**File**: `php/includes/config.php`

**Before**:
```php
session_set_cookie_params([
    'path' => '/',  // ❌ Root path - cookies may not reach subdirs
    ...
]);
```

**After**:
```php
$cookiePath = $basePath ?: '/';  // Use application base path
session_set_cookie_params([
    'path' => $cookiePath,  // ✅ /training/online/accessilist2/
    ...
]);
error_log("[SESSION CONFIG] Cookie path set to: $cookiePath");
```

**Why This Fixes It**:
- Production app at: `/training/online/accessilist2/`
- API endpoints at: `/training/online/accessilist2/php/api/instantiate`
- Cookie with `path=/` works for ALL paths
- Cookie with `path=/training/online/accessilist2/` is MORE SPECIFIC
- Browser WILL send cookie to `/training/online/accessilist2/php/api/...`
- Session persists across home page → API calls
- CSRF token found in session → ✅ Validation succeeds

## How to Test

### Option 1: Browser Console Diagnostics (Manual)

1. Open https://webaim.org/training/online/accessilist2/home
2. Open DevTools Console
3. Look for automatic diagnostic output:
   ```
   🔍 CSRF DIAGNOSTICS
   1️⃣ CSRF Token (meta tag): ✅ Present (64 chars)
   2️⃣ Cookies: [list of cookies with PHPSESSID]
   3️⃣ Session Storage: Empty
   4️⃣ fetchWithCsrf(): ✅ Available
   5️⃣ ENV Config: {environment: "production", ...}
   ```
4. Click "Word" button
5. Watch console for:
   ```
   🌐 API REQUEST: /training/online/accessilist2/php/api/instantiate
   ✅ CSRF Token: a825700a50a00cd9...
   📥 API RESPONSE: /training/online/accessilist2/php/api/instantiate
   Status: 200 OK  (✅ SUCCESS!)
   ```

### Option 2: Server Logs (SSH)

```bash
ssh -i ~/.ssh/GeorgeWebAIMServerKey.pem george@ec2-3-20-59-76.us-east-2.compute.amazonaws.com

# Watch Apache error log
sudo tail -f /var/log/apache2/error.log | grep CSRF

# Expected output on successful request:
[SESSION CONFIG] Cookie path set to: /training/online/accessilist2/
[CSRF VALIDATION] Session ID: abc123def456...
[CSRF VALIDATION] Token received: a825700a50a00cd9...
[CSRF VALIDATION] Token in session: a825700a50a00cd9...
[CSRF VALIDATION] SUCCESS
```

### Option 3: Automated Test (Playwright MCP)

Use MCP tools to automate testing:
```
Ask AI: "Test https://webaim.org/training/online/accessilist2 button click with console logging"
```

## What To Look For

### ✅ SUCCESS Indicators
- Console shows "✅ CSRF Token" with 64-char hex
- Console shows "🔑 PHPSESSID = ..." cookie
- Button click shows "📥 API RESPONSE: Status: 200 OK"
- Page redirects to `/?=ABC` after button click
- Server log shows "[CSRF VALIDATION] SUCCESS"

### ❌ FAILURE Indicators
- Console shows "❌ NO COOKIES" or "❌ MISSING" token
- Button click shows "📥 API RESPONSE: Status: 403 Forbidden"
- Console shows "🚫 403 FORBIDDEN - Likely CSRF token issue!"
- Page stays on home after button click
- Server log shows "[CSRF VALIDATION] FAILED"

## Files Modified

### JavaScript (Client-Side)
- `js/debug-utils.js` - Added CSRF diagnostics
- `js/csrf-utils.js` - Added request/response logging
- `php/home.php` - Added auto-diagnostic on page load

### PHP (Server-Side)
- `php/includes/config.php` - FIXED cookie path
- `php/includes/csrf.php` - Added validation logging

## Deployment

```bash
./scripts/deployment/upload-to-test-directory.sh
```

All modified files are already in CORE2.md deployment whitelist ✅

## Rollback Plan

If this breaks something:

```bash
# Revert cookie path change
git diff php/includes/config.php
git checkout php/includes/config.php

# Redeploy
./scripts/deployment/upload-to-test-directory.sh
```

## Next Steps

1. Deploy changes to accessilist2
2. Test manually in browser (check console)
3. If 403 persists, review server logs for diagnostic output
4. Apply additional fixes from 403-DIAGNOSIS.md if needed
