# Scalability Issues for 100 Concurrent Users

**Current Status:** ❌ **NOT READY for 100 concurrent users**

---

## Critical Issues Identified

### 1. ❌ Session Key Collision Risk (HIGH)

**Problem:**
- 3-character keys (A-Z0-9) = 46,656 combinations
- Client-side Math.random() generation
- Birthday paradox collision probability:
  - 100 users: ~10.7% collision risk
  - 200 users: ~35% collision risk

**Impact:** Two users get same session key → overwrite each other's work

**Fix Required:**
```javascript
// In StateManager.js - Use crypto-secure random and longer keys
generateSessionId() {
    const array = new Uint8Array(8);
    crypto.getRandomValues(array);
    return Array.from(array, byte =>
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'[byte % 36]
    ).join('').substring(0, 8); // 8 chars = 2.8 trillion combinations
}
```

---

### 2. ❌ No File Locking (CRITICAL)

**Problem:**
```php
// php/api/save.php line 63
$result = file_put_contents($filename, $updatedRawData);
// NO LOCK_EX flag!
```

**Impact:** Race condition → corrupted files, data loss

**Fix Required:**
```php
// Add LOCK_EX flag for exclusive lock
$result = file_put_contents($filename, $updatedRawData, LOCK_EX);
```

**Also fix in:**
- `php/api/instantiate.php` line 63
- Any other file write operations

---

### 3. ❌ Non-Atomic Read-Modify-Write (HIGH)

**Problem:**
```php
// php/api/save.php lines 28-63
$existingContent = file_get_contents($filename);  // READ
// ... merge metadata ...
file_put_contents($filename, $updatedRawData);    // WRITE
```

**Race Condition:**
1. User A reads file
2. User B reads file (same content)
3. User A writes changes
4. User B writes changes (overwrites A's changes) ❌

**Fix Required:**
```php
// Use file locking for entire operation
$fp = fopen($filename, 'c+');
if ($fp && flock($fp, LOCK_EX)) {
    $existingContent = fread($fp, filesize($filename) ?: 1);
    // ... merge metadata ...
    ftruncate($fp, 0);
    rewind($fp);
    fwrite($fp, $updatedRawData);
    flock($fp, LOCK_UN);
    fclose($fp);
} else {
    send_error('Could not lock file for writing', 500);
}
```

---

### 4. ⚠️ Weak Random Generation (MEDIUM)

**Problem:**
```javascript
Math.random() // Not cryptographically secure
```

**Impact:** Predictable patterns, easier collisions

**Fix Required:**
```javascript
// Use Web Crypto API
crypto.getRandomValues()
```

---

## Recommended Architecture Changes

### Short-term Fixes (1-2 hours):
1. ✅ Increase session key length to 8 characters (2.8T combinations)
2. ✅ Use `crypto.getRandomValues()` for key generation
3. ✅ Add `LOCK_EX` to all `file_put_contents()` calls
4. ✅ Implement proper file locking for read-modify-write operations

### Medium-term Improvements (1-2 days):
1. 🔄 Add collision detection and retry logic
2. 🔄 Implement optimistic locking (version numbers)
3. 🔄 Add request queuing for same session key
4. 🔄 Monitor and log collision events

### Long-term Solutions (1-2 weeks):
1. 🚀 Move to database (SQLite or MySQL)
2. 🚀 Implement proper transaction support
3. 🚀 Add connection pooling
4. 🚀 Implement proper session management

---

## Risk Assessment

| Users | Current System | With Short-term Fixes |
|-------|----------------|----------------------|
| 10 users | ⚠️ Low risk | ✅ Safe |
| 50 users | ❌ Medium risk | ✅ Safe |
| 100 users | ❌ High risk | ✅ Safe |
| 500 users | ❌ Critical | ⚠️ Medium risk |

---

## Immediate Action Required

**Before supporting 100 concurrent users:**

1. **Implement file locking** (CRITICAL - 30 min)
2. **Extend session keys to 8 chars** (HIGH - 15 min)
3. **Use crypto.getRandomValues()** (HIGH - 10 min)
4. **Add collision detection** (MEDIUM - 1 hour)
5. **Test under load** (REQUIRED - 2 hours)

**Estimated total time:** ~4 hours to make production-ready for 100 users

