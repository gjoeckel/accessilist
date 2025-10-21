# Rate Limiting Issue - Analysis & Solutions

## 🚨 Current Problem

**User experiencing HTTP 429 errors on accessilist2 (staging):**
```
Failed to load resource: the server responded with a status of 429 (Too Many Requests)
Failed to create session: {
  "success": false,
  "message": "Rate limit exceeded. Please try again later.",
  "retry_after": 178,  // ~3 minutes wait time!
  "timestamp": 1761062578
}
```

---

## 🔍 Root Cause Analysis

### **Current Rate Limits (From php/api/instantiate.php line 15):**
```php
enforce_rate_limit($_SERVER['REMOTE_ADDR'] . '_instantiate', 20, 3600);
```

**Translation:** Only **20 session creations per hour per IP address**

### **Why This is Too Restrictive for Staging:**

| Scenario | Requests | Time | Hits Limit? |
|----------|----------|------|-------------|
| Manual testing (create 5 instances) | 5 | 10 min | ✅ OK |
| Automated test suite | 3-5 | 2 min | ✅ OK |
| Development (create, test, delete, repeat) | 25+ | 1 hour | ❌ **BLOCKED** |
| Multiple developers testing | 30+ | 1 hour | ❌ **BLOCKED** |

### **The Problem:**
- **Production limits applied to staging** (no environment distinction)
- **Too aggressive for development** (20/hour is very low)
- **Blocks legitimate testing** (not just abuse)
- **Long retry times** (178 seconds = almost 3 minutes)

---

## ✅ Recommended Solutions

### **Solution 1: Environment-Based Rate Limits** (RECOMMENDED)

Modify `php/includes/rate-limiter.php` to check environment:

```php
/**
 * Get environment-appropriate rate limits
 *
 * @param string $endpoint API endpoint name
 * @return array [maxAttempts, windowSeconds]
 */
function get_rate_limit_for_environment($endpoint) {
    global $environment;

    // Development/Staging: Much higher limits
    if ($environment === 'local' || $environment === 'development') {
        $limits = [
            'instantiate' => [1000, 3600],  // 1000/hour (basically unlimited for dev)
            'save' => [1000, 3600],
            'delete' => [500, 3600],
            'list' => [1000, 3600],
            'restore' => [1000, 3600]
        ];
    }
    // Staging: Moderate limits (test security but allow testing)
    elseif ($environment === 'staging' || strpos($_SERVER['HTTP_HOST'], 'accessilist2') !== false) {
        $limits = [
            'instantiate' => [100, 3600],  // 100/hour (5x production)
            'save' => [500, 3600],
            'delete' => [250, 3600],
            'list' => [500, 3600],
            'restore' => [1000, 3600]
        ];
    }
    // Production: Strict limits
    else {
        $limits = [
            'instantiate' => [20, 3600],   // 20/hour (strict)
            'save' => [100, 3600],
            'delete' => [50, 3600],
            'list' => [100, 3600],
            'restore' => [200, 3600]
        ];
    }

    return $limits[$endpoint] ?? [100, 3600];  // Default fallback
}

/**
 * Enforce rate limit with environment awareness
 */
function enforce_rate_limit_smart($endpoint, $identifier = null) {
    // Use IP if no identifier provided
    $identifier = $identifier ?? $_SERVER['REMOTE_ADDR'];

    list($maxAttempts, $windowSeconds) = get_rate_limit_for_environment($endpoint);

    $limiter = new RateLimiter($maxAttempts, $windowSeconds);
    $limiter->checkLimit($identifier . '_' . $endpoint);
}
```

**Update API endpoints:**
```php
// php/api/instantiate.php line 15
// OLD:
enforce_rate_limit($_SERVER['REMOTE_ADDR'] . '_instantiate', 20, 3600);

// NEW:
enforce_rate_limit_smart('instantiate');
```

---

### **Solution 2: IP Whitelist for Development** (QUICK FIX)

Add to `rate-limiter.php` before rate limit check:

```php
public function checkLimit($identifier) {
    // Whitelist for development/testing IPs
    $whitelist_ips = [
        '127.0.0.1',           // localhost
        '::1',                 // localhost IPv6
        '192.168.1.0/24',      // Local network (adjust as needed)
        // Add specific dev team IPs here
    ];

    $client_ip = $_SERVER['REMOTE_ADDR'];

    // Skip rate limiting for whitelisted IPs
    foreach ($whitelist_ips as $whitelisted) {
        if (strpos($whitelisted, '/') !== false) {
            // CIDR notation check
            if (ip_in_range($client_ip, $whitelisted)) {
                return; // Skip rate limiting
            }
        } else {
            // Exact match
            if ($client_ip === $whitelisted) {
                return; // Skip rate limiting
            }
        }
    }

    // ... existing rate limit logic ...
}

// Helper function for CIDR range checking
function ip_in_range($ip, $range) {
    list($subnet, $bits) = explode('/', $range);
    $ip = ip2long($ip);
    $subnet = ip2long($subnet);
    $mask = -1 << (32 - $bits);
    $subnet &= $mask;
    return ($ip & $mask) == $subnet;
}
```

---

### **Solution 3: Environment Variable Configuration** (CLEANEST)

In `.env.accessilist2` (staging):
```bash
RATE_LIMIT_INSTANTIATE=100
RATE_LIMIT_SAVE=500
RATE_LIMIT_DELETE=250
RATE_LIMIT_LIST=500
RATE_LIMIT_RESTORE=1000
RATE_LIMIT_WINDOW=3600
```

In `rate-limiter.php`:
```php
function get_rate_limit($endpoint) {
    $envKey = 'RATE_LIMIT_' . strtoupper($endpoint);
    $limit = getenv($envKey) ?: 20;  // Default to 20 if not set
    $window = getenv('RATE_LIMIT_WINDOW') ?: 3600;
    return [$limit, $window];
}
```

---

### **Solution 4: Session-Based + IP-Based** (MOST SOPHISTICATED)

Instead of IP-only, use session + IP:

```php
// Authenticated users get higher limits
if (isset($_SESSION['user_id'])) {
    $identifier = 'user_' . $_SESSION['user_id'];
    $maxAttempts = 500;  // Authenticated users: 500/hour
} else {
    $identifier = 'ip_' . $_SERVER['REMOTE_ADDR'];
    $maxAttempts = 20;   // Anonymous users: 20/hour
}
```

---

## 📊 Comparison of Solutions

| Solution | Pros | Cons | Effort | Security Impact |
|----------|------|------|--------|-----------------|
| **Environment-Based** | Clean, maintains security per env | Requires code changes | Medium | ✅ No impact |
| **IP Whitelist** | Quick, no API changes | Hardcoded IPs | Low | ⚠️ Minor (whitelisted IPs bypass) |
| **ENV Variables** | Most flexible, no code for changes | Requires .env updates | Medium | ✅ No impact |
| **Session-Based** | Better UX, rewards auth | Complex logic | High | ✅ Actually improves security |

---

## 🎯 Immediate Recommendation

**Implement Solution 1 (Environment-Based) + Solution 2 (IP Whitelist)**

### **Step 1: Add Environment Detection to rate-limiter.php**
```php
// Detect accessilist2 (staging) vs accessilist (production)
$is_staging = strpos($_SERVER['HTTP_HOST'] ?? '', 'accessilist2') !== false ||
              strpos($_SERVER['REQUEST_URI'] ?? '', 'accessilist2') !== false ||
              ($environment ?? '') === 'development';

// Adjust limits based on environment
if ($is_staging) {
    $multiplier = 5;  // 5x limits for staging
} else {
    $multiplier = 1;  // Normal limits for production
}
```

### **Step 2: Update API Endpoints**
```php
// php/api/instantiate.php
$base_limit = 20;
$adjusted_limit = $base_limit * $multiplier;  // 20 for prod, 100 for staging
enforce_rate_limit($_SERVER['REMOTE_ADDR'] . '_instantiate', $adjusted_limit, 3600);
```

### **Step 3: Add Whitelist for Known Dev IPs**
```php
// At top of RateLimiter::checkLimit()
$dev_ips = ['127.0.0.1', '::1'];  // Add your IP here
if (in_array($_SERVER['REMOTE_ADDR'], $dev_ips)) {
    return;  // Skip rate limiting for dev IPs
}
```

---

## 🔧 Quick Fix (5 Minutes)

**For immediate relief on accessilist2:**

1. SSH to server
2. Edit `/var/websites/webaim/htdocs/training/online/accessilist2/php/api/instantiate.php`
3. Change line 15:
   ```php
   // FROM:
   enforce_rate_limit($_SERVER['REMOTE_ADDR'] . '_instantiate', 20, 3600);

   // TO:
   enforce_rate_limit($_SERVER['REMOTE_ADDR'] . '_instantiate', 100, 3600);
   ```
4. Save and test

**Result:** 100 requests/hour instead of 20 (5x more permissive for staging)

---

## 📈 Long-Term Strategy

1. **Immediate:** Increase staging limits via SSH (5 min)
2. **Short-term:** Add IP whitelist for dev team (30 min)
3. **Long-term:** Implement environment-based config (2 hours)
4. **Future:** Session-based rate limiting for better UX (1 day)

---

## ⚠️ Important Notes

### **Don't Disable Rate Limiting Entirely**
Even on staging, keep rate limiting active to:
- Test that the security measure works
- Prevent accidental DoS during load testing
- Maintain production-like environment

### **Document the Configuration**
Add to `.env.accessilist2`:
```bash
# Staging has 5x higher rate limits than production
# This allows testing while still preventing abuse
RATE_LIMIT_MULTIPLIER=5
```

---

## 🎯 My Recommendation

**Implement Solution 1 (Environment-Based) NOW:**

This gives you:
- ✅ Production security maintained (20/hour)
- ✅ Staging usability improved (100/hour)
- ✅ No whitelist management overhead
- ✅ Automatic environment detection
- ✅ Easy to adjust per environment

**Would you like me to implement this solution?**
