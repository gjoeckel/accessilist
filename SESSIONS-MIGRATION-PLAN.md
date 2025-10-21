# Sessions Directory Migration Plan
**Date:** October 21, 2025
**Branch:** security-updates
**Goal:** Move sessions directory outside web root for enhanced security

---

## 🎯 Security Objective

**Current State:** Sessions stored at `accessilist/sessions/` (INSIDE web root)
**Target State:** Sessions stored in `etc/sessions/` (OUTSIDE web root, same level as .env)

**Production Structure:**
```
/var/websites/webaim/htdocs/training/online/
├── etc/
│   ├── .env                    ← Configuration (already here)
│   └── sessions/               ← Move sessions HERE (sibling to .env)
├── accessilist/                ← Web root (PUBLIC)
│   └── sessions/ (DELETE)      ← Currently here (VULNERABLE)
└── accessilist2/               ← Test directory
```

**Security Benefit:**
- ✅ Session files completely outside web root
- ✅ Zero HTTP access - not dependent on `.htaccess`
- ✅ Logical grouping with configuration
- ✅ Same security level as `.env` file
- ✅ Fixes current `.htaccess` vulnerability (currently allows access!)

---

## 📊 Current Implementation Analysis

### Session Storage Locations

**Current Directory:** `accessilist/sessions/`
**Protection:** `.htaccess` with `Deny from all`
**Files:** ~60 JSON session files

**`.htaccess` Protection:**
```apache
# Prevent direct access to session files
Order deny,allow
Deny from all
```

### Code References Found

**Total Files Referencing "sessions":** 100+ files
**Critical PHP Files:** 10 files
**Deployment Scripts:** 3 files

---

## 🔍 Files Requiring Updates

### **Category 1: Core Path Functions (2 files) - CRITICAL**

#### 1. `php/includes/api-utils.php`
**Current Code:**
```php
function saves_path_for($sessionKey) {
  return __DIR__ . '/../../sessions/' . $sessionKey . '.json';
}
```

**Required Change:**
```php
function saves_path_for($sessionKey) {
  // Use environment-configured sessions path (defaults to etc/sessions in production)
  global $sessionsPath;
  return $sessionsPath . '/' . $sessionKey . '.json';
}
```

**Impact:** HIGH - Used by all API endpoints
**Effort:** 5 minutes

---

#### 2. `php/includes/session-utils.php`
**Current Code:**
```php
function getChecklistTypeFromSession($sessionKey, $defaultType = 'camtasia') {
    $sessionFile = "sessions/{$sessionKey}.json";

    if (!file_exists($sessionFile)) {
        return $defaultType;
    }
    // ...
}
```

**Required Change:**
```php
function getChecklistTypeFromSession($sessionKey, $defaultType = 'camtasia') {
    global $sessionsPath;
    $sessionFile = $sessionsPath . '/' . $sessionKey . '.json';

    if (!file_exists($sessionFile)) {
        return $defaultType;
    }
    // ...
}
```

**Impact:** HIGH - Used by index.php for URL routing
**Effort:** 5 minutes

---

### **Category 2: Configuration (1 file) - CRITICAL**

#### 3. `php/includes/config.php`
**Required Addition:**
```php
// Sessions directory path (in etc/ directory, sibling to .env in production)
if ($environment === 'production') {
    // Production: Store in etc/sessions (same directory as .env file)
    $sessionsPath = $_ENV['SESSIONS_PATH'] ?? '/var/websites/webaim/htdocs/training/online/etc/sessions';
} else {
    // Local development: keep in project for convenience
    $sessionsPath = __DIR__ . '/../../sessions';
}

// Export for use in API and utilities
$GLOBALS['sessionsPath'] = $sessionsPath;

// Add to envConfig for potential future JS use
$envConfig['sessionsPath'] = $sessionsPath; // Note: Never expose to client!
```

**Impact:** HIGH - Central configuration
**Effort:** 10 minutes

---

### **Category 3: API Endpoints (5 files) - MEDIUM**

#### 4. `php/api/save.php`
**Current Code:**
```php
// Verify sessions directory exists
$savesDir = __DIR__ . '/../../sessions';
if (!file_exists($savesDir)) {
    send_error('Saves directory not found', 500);
}

// ...
$filename = saves_path_for($sessionKey);
```

**Required Change:**
```php
// Verify sessions directory exists
global $sessionsPath;
if (!file_exists($sessionsPath)) {
    send_error('Sessions directory not found', 500);
}

// ...
$filename = saves_path_for($sessionKey); // No change needed - uses api-utils function
```

**Impact:** MEDIUM - One endpoint
**Effort:** 3 minutes

---

#### 5. `php/api/instantiate.php`
**Current Code:**
```php
// Ensure sessions directory exists
$savesDir = __DIR__ . '/../../sessions';
if (!file_exists($savesDir) && !mkdir($savesDir, 0755, true)) {
    send_error('Failed to create sessions directory', 500);
}

$filename = saves_path_for($sessionKey);
```

**Required Change:**
```php
// Ensure sessions directory exists
global $sessionsPath;
if (!file_exists($sessionsPath) && !mkdir($sessionsPath, 0755, true)) {
    send_error('Failed to create sessions directory', 500);
}

$filename = saves_path_for($sessionKey); // No change needed
```

**Impact:** MEDIUM
**Effort:** 3 minutes

---

#### 6. `php/api/list.php`
**Current Code:**
```php
// Get all JSON files from the sessions directory using the same path as other APIs
$savesDir = dirname(saves_path_for('dummy')) . '/';
$files = glob($savesDir . '*.json');
```

**Required Change:**
```php
// Get all JSON files from the sessions directory using the same path as other APIs
global $sessionsPath;
$files = glob($sessionsPath . '/*.json');
```

**Impact:** MEDIUM
**Effort:** 2 minutes

---

#### 7. `php/api/list-detailed.php`
**Current Code:**
```php
// Get all JSON files from the sessions directory
$savesDir = dirname(saves_path_for('dummy')) . '/';
$files = glob($savesDir . '*.json');
```

**Required Change:**
```php
// Get all JSON files from the sessions directory
global $sessionsPath;
$files = glob($sessionsPath . '/*.json');
```

**Impact:** MEDIUM
**Effort:** 2 minutes

---

#### 8. `php/api/generate-key.php`
**Current Code:**
```php
$savesDir = __DIR__ . '/../../sessions';

if (!file_exists($savesDir)) {
    send_error('Saves directory not found', 500);
}
// ...
$filename = "$savesDir/$key.json";
```

**Required Change:**
```php
global $sessionsPath;

if (!file_exists($sessionsPath)) {
    send_error('Sessions directory not found', 500);
}
// ...
$filename = saves_path_for($key); // Use standard function
```

**Impact:** MEDIUM
**Effort:** 3 minutes

---

### **Category 4: Page Files (1 file) - LOW**

#### 9. `php/list-report.php`
**Current Code:**
```php
$sessionFile = __DIR__ . '/../sessions/' . $sessionKey . '.json';
```

**Required Change:**
```php
$sessionFile = saves_path_for($sessionKey);
```

**Impact:** LOW - Uses existing function
**Effort:** 1 minute

---

### **Category 5: Deployment Scripts (2 files) - MEDIUM**

#### 10. `scripts/deployment/upload-production-files.sh`
**Current Code:**
```bash
ssh -i "$SSH_KEY" "${DEPLOY_TARGET}" "cd ${DEPLOY_PATH} && mkdir -p sessions && chmod 775 sessions"
```

**Required Change:**
```bash
# Create sessions directory in etc/ (sibling to .env)
ssh -i "$SSH_KEY" "${DEPLOY_TARGET}" "mkdir -p /var/websites/webaim/htdocs/training/online/etc/sessions && chmod 775 /var/websites/webaim/htdocs/training/online/etc/sessions"

# Optional: Create symlink in web root for verification (can be removed later)
ssh -i "$SSH_KEY" "${DEPLOY_TARGET}" "cd ${DEPLOY_PATH} && rm -rf sessions && ln -s ../etc/sessions sessions"
```

**Impact:** MEDIUM - Production deployment
**Effort:** 5 minutes

---

#### 11. `scripts/deployment/verify-deployment-manifest.sh`
**Current Code:**
```bash
# Check sessions directory
SESSIONS_EXISTS=0
if [ -d "sessions" ]; then
    echo -e "${GREEN}✅ sessions/ directory exists${NC}"
    SESSIONS_EXISTS=1
```

**Required Change:**
```bash
# Check sessions directory (either local dir or symlink to external)
SESSIONS_EXISTS=0
if [ -d "sessions" ] || [ -L "sessions" ]; then
    echo -e "${GREEN}✅ sessions/ directory or symlink exists${NC}"
    SESSIONS_EXISTS=1
```

**Impact:** LOW - Verification script
**Effort:** 2 minutes

---

### **Category 6: Environment Configuration (2 files) - CRITICAL**

#### 12. `.env` (Production)
**Required Addition:**
```bash
# Sessions storage path (in etc/ directory, sibling to .env)
SESSIONS_PATH=/var/websites/webaim/htdocs/training/online/etc/sessions
```

**Location:** `/var/websites/webaim/htdocs/training/online/etc/.env`
**Impact:** CRITICAL - Must be configured
**Effort:** 1 minute

**Note:** This keeps sessions at the same level as the .env file - both in `etc/` directory outside the web root.

---

#### 13. Global `.env` (Local Development)
**Optional Addition:**
```bash
# Sessions storage (keep in project for local dev convenience)
SESSIONS_PATH=/Users/a00288946/Projects/accessilist/sessions
```

**Location:** `~/cursor-global/config/.env`
**Impact:** MEDIUM - Local development
**Effort:** 1 minute

---

### **Category 7: Documentation (1 file) - LOW**

#### 14. `DEPLOYMENT-SECURITY-MEASURES.md`
**Required Addition:**
Document the sessions directory location change and security benefits.

**Impact:** LOW - Documentation only
**Effort:** 5 minutes

---

## 📋 Summary Table

| File | Category | Lines Changed | Effort | Priority |
|------|----------|---------------|--------|----------|
| `php/includes/api-utils.php` | Core | 1-3 | 5 min | CRITICAL |
| `php/includes/session-utils.php` | Core | 2-3 | 5 min | CRITICAL |
| `php/includes/config.php` | Config | 10-15 | 10 min | CRITICAL |
| `php/api/save.php` | API | 2-3 | 3 min | MEDIUM |
| `php/api/instantiate.php` | API | 2-3 | 3 min | MEDIUM |
| `php/api/list.php` | API | 1-2 | 2 min | MEDIUM |
| `php/api/list-detailed.php` | API | 1-2 | 2 min | MEDIUM |
| `php/api/generate-key.php` | API | 2-4 | 3 min | MEDIUM |
| `php/list-report.php` | Pages | 1 | 1 min | LOW |
| `scripts/deployment/upload-production-files.sh` | Deploy | 2-3 | 5 min | MEDIUM |
| `scripts/deployment/verify-deployment-manifest.sh` | Deploy | 1-2 | 2 min | LOW |
| `.env` (production) | Config | 1-2 | 1 min | CRITICAL |
| `.env` (local) | Config | 1-2 | 1 min | MEDIUM |
| `DEPLOYMENT-SECURITY-MEASURES.md` | Docs | 10-20 | 5 min | LOW |

**Total Files:** 14
**Total Effort:** ~50 minutes
**Priority Breakdown:** 4 Critical, 7 Medium, 3 Low

---

## 🎯 Implementation Strategy

### **Approach: Backward-Compatible Migration**

**Key Decision:** Use global configuration variable instead of hardcoded paths

**Benefits:**
- ✅ Single change point (config.php)
- ✅ Environment-specific paths
- ✅ Easy to test locally
- ✅ Safe rollback if needed
- ✅ No breaking changes to API contracts

---

### **Phase 1: Local Development (Est. 30 min)**

1. **Update Core Functions** (10 min)
   - Modify `api-utils.php` to use global `$sessionsPath`
   - Modify `session-utils.php` to use global `$sessionsPath`
   - Add configuration to `config.php`

2. **Update API Endpoints** (15 min)
   - Update all 5 API files
   - Update `list-report.php`

3. **Test Locally** (5 min)
   - Run production mirror tests
   - Verify all endpoints work
   - Check session file creation/reading

---

### **Phase 2: Production Deployment (Est. 20 min)**

1. **Server Preparation** (5 min)
   ```bash
   # Create sessions directory in etc/ (sibling to .env)
   mkdir -p /var/websites/webaim/htdocs/training/online/etc/sessions
   chmod 775 /var/websites/webaim/htdocs/training/online/etc/sessions
   chown www-data:www-data /var/websites/webaim/htdocs/training/online/etc/sessions
   ```

2. **Configure Environment** (2 min)
   ```bash
   # Add to /var/websites/webaim/htdocs/training/online/etc/.env
   echo "SESSIONS_PATH=/var/websites/webaim/htdocs/training/online/etc/sessions" >> .env
   ```

3. **Migrate Existing Sessions** (5 min)
   ```bash
   # Move existing session files
   mv /var/websites/webaim/htdocs/training/online/accessilist/sessions/*.json \
      /var/websites/webaim/htdocs/training/online/etc/sessions/

   # Optional: Create symlink for debugging/verification
   cd /var/websites/webaim/htdocs/training/online/accessilist
   rm -rf sessions
   ln -s ../etc/sessions sessions
   ```

4. **Deploy Code** (3 min)
   - Deploy updated PHP files
   - Deploy updated scripts

5. **Verify** (5 min)
   - Test creating new session
   - Test reading existing session
   - Test all API endpoints
   - Verify no HTTP access to session files

---

## ⚠️ Risks & Mitigation

### **Risk 1: Path Configuration Error**
**Impact:** Sessions not found, API errors
**Mitigation:**
- Add validation in config.php to check if directory exists
- Log warning if sessions path is not configured
- Provide clear error messages

### **Risk 2: File Permissions**
**Impact:** Apache cannot write to new location
**Mitigation:**
- Verify permissions during deployment (775)
- Ensure Apache user (www-data) owns directory
- Test write access before going live

### **Risk 3: Existing Sessions Lost**
**Impact:** Users lose in-progress work
**Mitigation:**
- Migrate existing files BEFORE deploying code
- Keep backup of old sessions directory
- Verify file count before/after migration

### **Risk 4: Local Development Broken**
**Impact:** Developers can't test locally
**Mitigation:**
- Default to project sessions directory for local env
- Update local .env with clear instructions
- Document the change in README

---

## ✅ Rollback Plan

If issues occur in production:

1. **Immediate Rollback:**
   ```bash
   # Restore .env to remove SESSIONS_PATH
   # Sessions will default to old location via fallback
   ```

2. **Restore Sessions:**
   ```bash
   # Copy files back to web root
   cp /var/websites/webaim/htdocs/training/online/etc/sessions/*.json \
      /var/websites/webaim/htdocs/training/online/accessilist/sessions/
   ```

3. **Revert Code:**
   - Git revert the security-updates branch
   - Redeploy previous version

**Rollback Time:** < 5 minutes

---

## 📝 Testing Checklist

### Local Testing
- [ ] Create new session (instantiate API)
- [ ] Save session data (save API)
- [ ] Restore session data (restore API)
- [ ] List all sessions (list API)
- [ ] Delete session (delete API)
- [ ] Load page by session key (index.php routing)
- [ ] All production mirror tests pass (101/101)

### Production Testing
- [ ] Sessions directory created with correct permissions
- [ ] Environment variable configured
- [ ] Old sessions migrated successfully
- [ ] New sessions created in new location
- [ ] HTTP access blocked (try accessing session JSON via browser)
- [ ] All API endpoints functional
- [ ] No errors in server logs

---

## 💡 Additional Security Enhancements (Future)

1. **Encrypted Session Storage**
   - Encrypt session JSON files at rest
   - Decrypt on read, encrypt on write

2. **Session Expiration**
   - Add timestamp checking
   - Auto-delete sessions older than X days
   - Cleanup script in cron

3. **Session Integrity**
   - Add HMAC to prevent tampering
   - Validate signature on load

4. **Audit Logging**
   - Log all session access
   - Track creation/modification/deletion
   - Alert on suspicious patterns

---

## 🎯 Final Recommendation

**Effort Level:** LOW ⭐ (50 minutes total)
**Risk Level:** LOW ⭐ (Good backward compatibility)
**Security Benefit:** HIGH ⭐⭐⭐ (Defense-in-depth)

**Recommendation:** ✅ **PROCEED**

This is a **worthwhile security improvement** with:
- Minimal code changes (14 files)
- Low implementation risk
- Significant security benefit
- Clean rollback path

The use of environment configuration makes this flexible and maintainable.

---

**Ready to implement?** The changes are straightforward and well-contained.
