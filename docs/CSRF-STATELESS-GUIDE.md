# Stateless CSRF Protection (Cookie-Free!)

## Why Stateless?

**Problems with Session-Based CSRF:**
- ❌ Requires cookies (blocked by privacy settings)
- ❌ Requires server-side sessions (state management)
- ❌ Doesn't scale horizontally (session storage)
- ❌ Fails in private/incognito mode
- ❌ Blocked by browser extensions

**Benefits of Stateless CSRF:**
- ✅ No cookies required
- ✅ No server-side state
- ✅ Works with cookie blockers
- ✅ Privacy-friendly
- ✅ Scales infinitely
- ✅ Works in incognito mode

## How It Works

### Token Generation
```
Token = Base64(ClientID | Expiry | HMAC(ClientID + Expiry, Secret))
```

Where:
- **ClientID** = IP + User-Agent (ties token to client)
- **Expiry** = Timestamp + TTL (prevents replay attacks)
- **HMAC** = Cryptographic signature (prevents tampering)
- **Secret** = Server-side key (never sent to client)

### Validation Flow
```
Client Request
    ↓
Extract Token from Header
    ↓
Decode Base64
    ↓
Split into: ClientID | Expiry | Signature
    ↓
Check Expiry (not expired?)
    ↓
Verify ClientID (same IP/UA?)
    ↓
Recompute HMAC
    ↓
Compare Signatures (match?)
    ↓
✅ Valid / ❌ Invalid
```

## Migration Guide

### Step 1: Update home.php

```php
<?php
// OLD: Session-based CSRF
// require_once __DIR__ . '/includes/csrf.php';
// $GLOBALS['csrfToken'] = generate_csrf_token();

// NEW: Stateless CSRF
require_once __DIR__ . '/includes/csrf-stateless.php';
$GLOBALS['csrfToken'] = generate_stateless_csrf_token();
?>
```

### Step 2: Update API Endpoints

```php
<?php
// In instantiate.php, save.php, delete.php, etc.

// OLD: Session-based validation
// require_once __DIR__ . '/../includes/csrf.php';
// validate_csrf_from_header();

// NEW: Stateless validation
require_once __DIR__ . '/../includes/csrf-stateless.php';
validate_stateless_csrf_from_header();
?>
```

### Step 3: Configure Secret Key

**Option A: Environment Variable (Recommended)**
```bash
# In .env file
CSRF_SECRET=your-256-bit-hex-key-here
```

**Option B: Auto-Generate (Development)**
The library will auto-generate and store in `.csrf-secret` file.

**Option C: Hardcode (NOT RECOMMENDED)**
Only for testing! Never in production.

## JavaScript (No Changes Needed!)

Your existing `fetchWithCsrf()` works unchanged:
```javascript
// Same code, works with both session-based and stateless!
const response = await fetchWithCsrf('/api/instantiate', {
  method: 'POST',
  body: JSON.stringify({...})
});
```

## Security Considerations

### Token Lifetime
```php
// 1 hour (default)
$token = generate_stateless_csrf_token(3600);

// 24 hours (for long forms)
$token = generate_stateless_csrf_token(86400);

// 5 minutes (for sensitive operations)
$token = generate_stateless_csrf_token(300);
```

### Client Identifier Strictness

**Strict Mode** (current): IP + User-Agent must match
- ✅ More secure
- ❌ Fails if user switches networks/browsers
- ❌ Fails with VPNs/proxies

**Relaxed Mode**: Don't validate client ID
```php
// In validate_stateless_csrf_token()
// Comment out this check:
// if ($tokenClientId !== $currentClientId) {
//     return false;
// }
```

### Secret Key Security

**Critical:** Keep secret key secure!
- ✅ Store in environment variable
- ✅ Use different keys per environment
- ✅ Rotate periodically
- ❌ Never commit to git
- ❌ Never log or expose

## Comparison

| Feature | Session-Based | Stateless |
|---------|--------------|-----------|
| **Requires Cookies** | ✅ Yes | ❌ No |
| **Server State** | ✅ Sessions | ❌ None |
| **Privacy Friendly** | ❌ No | ✅ Yes |
| **Horizontal Scaling** | ❌ Complex | ✅ Easy |
| **Token Size** | Small (64 bytes) | Larger (~200 bytes) |
| **Validation Speed** | Fast (memory lookup) | Fast (HMAC compute) |
| **Works in Incognito** | ❌ No | ✅ Yes |
| **Browser Extensions** | ❌ Blocked | ✅ Works |

## Alternative: Origin-Based CSRF (Simplest!)

If you only care about same-origin requests:

```php
function validate_origin() {
    $origin = $_SERVER['HTTP_ORIGIN'] ?? '';
    $allowedOrigins = [
        'https://webaim.org',
        'https://www.webaim.org'
    ];

    if (!in_array($origin, $allowedOrigins)) {
        http_response_code(403);
        die('Invalid origin');
    }
}
```

**Pros:**
- ✅ No tokens needed
- ✅ No cookies needed
- ✅ Simple to implement

**Cons:**
- ❌ Only protects against cross-origin attacks
- ❌ Doesn't protect against same-origin XSS
- ❌ Origin header can be missing (some browsers/proxies)

## Recommended Hybrid Approach

Combine multiple protections:

```php
// 1. Check origin first (fast, catches most attacks)
validate_origin();

// 2. Check CSRF token (comprehensive protection)
validate_stateless_csrf_from_header();

// 3. Rate limiting (prevent brute force)
// enforce_rate_limit_smart('instantiate');
```

## Testing

```bash
# Generate token
curl https://webaim.org/training/online/accessilist2/home \
  | grep 'csrf-token' \
  | sed 's/.*content="\([^"]*\)".*/\1/'

# Use token in request
TOKEN="..."
curl -X POST https://webaim.org/training/online/accessilist2/php/api/instantiate \
  -H "Content-Type: application/json" \
  -H "X-CSRF-Token: $TOKEN" \
  -d '{"sessionKey":"TEST","typeSlug":"word"}'
```

## Migration Checklist

- [ ] Add `csrf-stateless.php` to project
- [ ] Update `home.php` to use stateless token generation
- [ ] Update API endpoints to use stateless validation
- [ ] Add CSRF_SECRET to `.env` file
- [ ] Add `.csrf-secret` to `.gitignore`
- [ ] Test with cookies disabled
- [ ] Test in incognito mode
- [ ] Test with privacy extensions
- [ ] Deploy to accessilist2
- [ ] Monitor error logs
- [ ] Deploy to live production

## Performance Impact

**Token Generation:** ~0.1ms (HMAC computation)
**Token Validation:** ~0.1ms (HMAC verification)

Negligible performance impact - suitable for high-traffic applications.
