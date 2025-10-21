# Security Implementation Guide
**Last Updated:** October 21, 2025
**Security Score:** 8.5/10

---

## 🔒 Active Security Protections

### 1. CSRF Protection ✅
**What:** Prevents cross-site request forgery attacks
**Where:** All POST/PUT/DELETE endpoints

**Implementation:**
```php
// Server-side (automatic in all API endpoints)
require_once __DIR__ . '/includes/csrf.php';
validate_csrf_from_header();
```

```javascript
// Client-side (automatic with fetchWithCsrf)
fetchWithCsrf('/php/api/save', {
    method: 'POST',
    body: JSON.stringify(data)
});
```

**Token:** 64-char session-based token in `<meta name="csrf-token">`

---

### 2. Rate Limiting ✅
**What:** Prevents API abuse and DoS attacks
**Where:** All API endpoints

**Current Limits:**
```
/api/save         → 100 requests/hour per IP
/api/instantiate  → 20 requests/hour per IP
/api/delete       → 50 requests/hour per IP
/api/restore      → 200 requests/hour per IP
/api/list         → 100 requests/hour per IP
```

**Implementation:**
```php
require_once __DIR__ . '/includes/rate-limiter.php';
enforce_rate_limit($_SERVER['REMOTE_ADDR'] . '_save', 100, 3600);
```

**Response:** HTTP 429 with `Retry-After` header when limit exceeded

---

### 3. Security Headers ✅
**What:** HTTP headers that prevent common attacks
**Where:** All HTML responses

**Headers Set:**
```
X-Frame-Options: DENY                    // Clickjacking protection
X-Content-Type-Options: nosniff          // MIME sniffing prevention
X-XSS-Protection: 1; mode=block          // Legacy XSS protection
Content-Security-Policy: ...             // Modern XSS protection
Referrer-Policy: strict-origin-...       // Referrer control
Permissions-Policy: ...                  // Feature restrictions
Strict-Transport-Security: ...           // HTTPS enforcement (production)
```

**Implementation:**
```php
require_once __DIR__ . '/includes/security-headers.php';
set_security_headers();
```

---

### 4. Input Validation ✅
**What:** Validates all user input before processing
**Where:** All API endpoints

**Session Keys:**
```php
// 3-20 characters, alphanumeric + hyphens
preg_match('/^[a-zA-Z0-9\-]{3,20}$/', $sessionKey)
```

**Output Escaping:**
```php
// Always escape HTML output
htmlspecialchars($data, ENT_QUOTES, 'UTF-8')
```

**Type Validation:**
```php
// TypeManager validates all checklist types
$validated = TypeManager::validateType($typeSlug);
```

---

## 🛡️ Attack Prevention Matrix

| Attack Type | Protection | Status |
|-------------|-----------|--------|
| CSRF | Session tokens | ✅ Active |
| XSS | CSP + escaping | ✅ Active |
| Clickjacking | X-Frame-Options | ✅ Active |
| MIME Sniffing | X-Content-Type-Options | ✅ Active |
| DoS/API Abuse | Rate limiting | ✅ Active |
| SQL Injection | No SQL (file-based) | ✅ N/A |
| Command Injection | No shell execution | ✅ N/A |

---

## 📝 Developer Guidelines

### When Adding New API Endpoints

1. **Add CSRF Protection** (for POST/PUT/DELETE):
```php
require_once __DIR__ . '/../includes/csrf.php';
validate_csrf_from_header();
```

2. **Add Rate Limiting**:
```php
require_once __DIR__ . '/../includes/rate-limiter.php';
enforce_rate_limit($_SERVER['REMOTE_ADDR'] . '_endpoint', 100, 3600);
```

3. **Validate All Input**:
```php
require_once __DIR__ . '/../includes/api-utils.php';
validate_session_key($sessionKey);
```

4. **Use Proper HTTP Methods**:
- GET = Read only (no CSRF needed)
- POST = Create
- PUT = Update
- DELETE = Delete (requires CSRF)

### When Adding Frontend API Calls

**Always use `fetchWithCsrf()` for state-changing requests:**
```javascript
// ✅ CORRECT
fetchWithCsrf('/php/api/save', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(data)
});

// ❌ WRONG - CSRF token not included
fetch('/php/api/save', {
    method: 'POST',
    body: JSON.stringify(data)
});
```

### When Rendering User Content

**Always escape HTML:**
```javascript
// ✅ CORRECT - Use textContent for text
element.textContent = userInput;

// ⚠️ CAUTION - Only if HTML is needed
element.innerHTML = escapeHtml(userInput);

// ❌ WRONG - XSS vulnerability
element.innerHTML = userInput;
```

---

## 🧪 Testing Security

### Manual Testing

**Test CSRF Protection:**
```bash
# Should return 403 Forbidden
curl -X POST http://localhost:8000/php/api/save \
  -H "Content-Type: application/json" \
  -d '{"sessionKey":"ABC","typeSlug":"word"}'
```

**Test Rate Limiting:**
```bash
# Send 101 requests rapidly - last should return 429
for i in {1..101}; do
  curl http://localhost:8000/php/api/list
done
```

**Test Security Headers:**
```bash
curl -I http://localhost:8000/home | grep -E "X-Frame|X-Content|CSP"
```

### Automated Testing

```bash
# Run full test suite (includes security tests)
npm run test:production-mirror

# Test 8 specifically verifies CSRF protection
```

---

## 🚨 Security Incidents

### If You Discover a Vulnerability

1. **DO NOT** commit the fix immediately
2. Document the issue privately
3. Assess the impact and exploitability
4. Create a fix on a private branch
5. Test the fix thoroughly
6. Deploy to production ASAP
7. Review logs for exploitation attempts

### Reporting Security Issues

- Internal: Document in `docs/security/`
- External: Contact project maintainer

---

## 📚 Security Resources

**Implementation Files:**
```
php/includes/security-headers.php  - HTTP security headers
php/includes/csrf.php              - CSRF token management
php/includes/rate-limiter.php      - API rate limiting
js/csrf-utils.js                   - Client-side CSRF handling
```

**Documentation:**
```
SECURITY-AUDIT-REPORT.md                 - Full security audit
SECURITY-IMPLEMENTATION-SUMMARY.md        - Implementation details
docs/security/INNERHTML-USAGE-AUDIT.md   - XSS risk assessment
```

**External Resources:**
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [OWASP Cheat Sheets](https://cheatsheetseries.owasp.org/)
- [Content Security Policy](https://content-security-policy.com/)

---

## ⚙️ Configuration

### Adjusting Rate Limits

Edit the API file directly:
```php
// php/api/save.php
enforce_rate_limit($_SERVER['REMOTE_ADDR'] . '_save', 200, 3600);
//                                                     ^^^  ^^^^
//                                                     max  seconds
```

### Modifying Security Headers

Edit `php/includes/security-headers.php`:
```php
function set_security_headers() {
    header('X-Frame-Options: DENY');
    header("Content-Security-Policy: ...");
    // Adjust as needed
}
```

### Changing Session Key Requirements

Edit `php/includes/api-utils.php`:
```php
function validate_session_key($sessionKey) {
    // Currently: 3-20 characters
    if (!preg_match('/^[a-zA-Z0-9\-]{3,20}$/', $sessionKey)) {
        send_error('Invalid session key', 400);
    }
}
```

---

## ✅ Quick Checklist

Before deploying new features, verify:

- [ ] CSRF protection on POST/PUT/DELETE endpoints
- [ ] Rate limiting on all API endpoints
- [ ] Input validation for all user data
- [ ] Output escaping for all HTML rendering
- [ ] Security headers on all HTML responses
- [ ] `fetchWithCsrf()` used for API calls
- [ ] Tests pass (including security tests)
- [ ] No sensitive data in logs
- [ ] No credentials in code

---

## 🎯 Security Score Breakdown

| Category | Score | Notes |
|----------|-------|-------|
| Input Validation | 9/10 | Strong regex & type validation |
| API Security | 9/10 | CSRF + rate limiting active |
| Security Headers | 9/10 | Comprehensive headers set |
| Data Protection | 8/10 | File-based, proper escaping |
| Authentication | 5/10 | Session keys only (by design) |
| Authorization | 6/10 | Key-based access (by design) |
| Dependencies | 10/10 | Zero vulnerabilities |

**Overall: 8.5/10** ⭐

---

**Last Security Audit:** October 20, 2025
**Next Audit Due:** January 20, 2026
