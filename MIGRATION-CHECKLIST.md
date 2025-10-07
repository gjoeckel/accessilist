# SRD Environment Configuration Migration Checklist

## Migration from Auto-Detection to .env Configuration

**Estimated Total Time:** 2-3 hours
**Risk Level:** Low (with rollback plan)
**Status:** ✅ COMPLETED

---

## Phase 1: Setup (30 min) ✅

### Step 1.1: Create Environment Files
- [x] Create `.env.example` template with all environments
- [x] Create local `.env` file from example (`cp .env.example .env`)
- [x] Verify `.env` contains `APP_ENV=local`

### Step 1.2: Update Git Configuration
- [x] Add `.env` to `.gitignore`
- [x] Ensure `.env.example` is NOT ignored (`!.env.example`)
- [x] Verify with `git status` (`.env` should not appear)

### Step 1.3: Backup Current Configuration
- [x] Backup `php/includes/config.php` → `config.php.backup`
- [x] Backup `js/path-utils.js` → `path-utils.js.backup`
- [x] Backup `index.php` → `index.php.backup`

**Command:**
```bash
cp php/includes/config.php php/includes/config.php.backup
cp js/path-utils.js js/path-utils.js.backup
cp index.php index.php.backup
```

---

## Phase 2: Update Code (1 hour) ✅

### Step 2.1: Update config.php
- [x] Add `loadEnv()` function to read .env file
- [x] Replace auto-detection with .env-based configuration
- [x] Add API extension support (`$apiExtension`)
- [x] Add debug mode configuration
- [x] Create `$envConfig` array for JavaScript injection
- [x] Keep fallback to auto-detection for backwards compatibility

**Verification:**
```bash
php -r "require 'php/includes/config.php'; var_dump(\$basePath, \$apiExtension, \$environment);"
```

### Step 2.2: Update html-head.php
- [x] Add `$envConfig` to global variables
- [x] Inject environment configuration via `<script>` tag
- [x] Make `window.ENV` and `window.basePath` available to JavaScript

**Verification:**
- Start PHP server: `php -S localhost:8000`
- Open browser console
- Check: `console.log(window.ENV)` should show config

### Step 2.3: Update path-utils.js
- [x] Remove auto-detection logic
- [x] Use `window.ENV.basePath` (from PHP injection)
- [x] Use `window.ENV.apiExtension` for API paths
- [x] Add `getAPIExtension()` function
- [x] Keep fallback to auto-detection for backwards compatibility
- [x] Add debug logging when `debug: true`

**Verification:**
```javascript
// Browser console
console.log('Base Path:', window.getAPIPath('save'));
// Local should show: /php/api/save.php
```

### Step 2.4: Update index.php
- [x] Add `require_once 'php/includes/config.php'` at top
- [x] Implement base path removal for routing
- [x] Update regex pattern to handle both `?=ABC` and `/?=ABC`
- [x] Ensure minimal URLs work in all environments

**Verification:**
```bash
# Test URL routing
php -S localhost:8000
# Visit: http://localhost:8000/?=ABC
```

---

## Phase 3: Testing (30 min) ✅

### Step 3.1: Test Local Environment

**Environment Configuration:**
```bash
# .env
APP_ENV=local
BASE_PATH_LOCAL=
API_EXT_LOCAL=.php
DEBUG_LOCAL=true
```

**Test Cases:**
- [x] Home page loads: `http://localhost:8000/php/home.php`
- [x] Admin page loads: `http://localhost:8000/admin`
- [x] Checklist creation works
- [x] Minimal URL works: `http://localhost:8000/?=ABC`
- [x] Images load correctly
- [x] JSON files load correctly
- [x] API calls work (save, restore, delete)
- [x] Console shows debug info: `window.ENV`

**Verification Commands:**
```bash
# Start server
php -S localhost:8000

# Test URLs (in another terminal)
curl -I http://localhost:8000/php/home.php        # Should be 200
curl -I http://localhost:8000/admin               # Should be 200 (via .htaccess)
curl -I http://localhost:8000/images/add-1.svg    # Should be 200
curl -I http://localhost:8000/json/word.json      # Should be 200
curl -I http://localhost:8000/php/api/health.php  # Should be 200
```

### Step 3.2: Test API Endpoints

**API Tests:**
- [x] **Health Check:** `GET /php/api/health.php` → 200
- [x] **Save:** `POST /php/api/save.php` → Should save correctly
- [x] **Restore:** `GET /php/api/restore.php?sessionKey=ABC` → Should restore
- [x] **List:** `GET /php/api/list.php` → Should list sessions
- [x] **Delete:** `POST /php/api/delete.php` → Should delete

**Test Script:**
```bash
# Health check
curl http://localhost:8000/php/api/health.php

# Save test (create session first via UI, then test save)
# Restore test
curl "http://localhost:8000/php/api/restore.php?sessionKey=ABC"
```

### Step 3.3: Test Browser Functionality

**UI Tests:**
- [x] Click "Word" button → Creates session → Redirects to `/?=ABC`
- [x] Click "Admin" button → Navigates to admin page
- [x] Add checklist item → Auto-save works
- [x] Status button changes work
- [x] Report generation works
- [x] Delete functionality works

**Console Checks:**
```javascript
// In browser console
console.log(window.ENV);
// Should show:
// {
//   environment: "local",
//   basePath: "",
//   apiExtension: ".php",
//   debug: true,
//   isProduction: false,
//   isLocal: true
// }

console.log(window.getAPIPath('save'));
// Should show: /php/api/save.php
```

### Step 3.4: Test Staging Environment (Optional)

**If staging environment exists:**
```bash
# .env
APP_ENV=staging
BASE_PATH_STAGING=/staging/accessilist
API_EXT_STAGING=
DEBUG_STAGING=true
```

- [ ] Repeat all tests from Step 3.1
- [ ] Verify base path prepended to all URLs
- [ ] Verify API calls use correct paths

---

## Phase 4: Production Preparation (15 min) ⏳

### Step 4.1: Create Production .env

**On Production Server:**
```bash
# Copy template
cp .env.example .env

# Edit for production
nano .env
```

**Production .env Contents:**
```bash
APP_ENV=production
BASE_PATH_LOCAL=
BASE_PATH_PRODUCTION=/training/online/accessilist
BASE_PATH_STAGING=/staging/accessilist
API_EXT_LOCAL=.php
API_EXT_PRODUCTION=
API_EXT_STAGING=
DEBUG_LOCAL=true
DEBUG_PRODUCTION=false
DEBUG_STAGING=true
```

### Step 4.2: Deployment Checklist

**Pre-Deployment:**
- [ ] All code changes committed to git
- [ ] `.env` NOT in git (verify with `git status`)
- [ ] `.env.example` IS in git
- [ ] Changelog updated
- [ ] Backup old config files on server

**Deployment Steps:**
```bash
# 1. SSH to production server
ssh user@webaim.org

# 2. Navigate to project
cd /var/websites/webaim/htdocs/training/online/accessilist/

# 3. Backup current files
cp php/includes/config.php php/includes/config.php.backup
cp js/path-utils.js js/path-utils.js.backup
cp index.php index.php.backup

# 4. Pull latest code
git pull origin main

# 5. Create .env from template
cp .env.example .env
nano .env  # Set APP_ENV=production

# 6. Set permissions
chmod 644 .env
chmod 755 php/saves

# 7. Test production URLs
curl -I https://webaim.org/training/online/accessilist/php/home.php
curl -I https://webaim.org/training/online/accessilist/admin
```

### Step 4.3: Post-Deployment Verification

**Production URLs to Test:**
- [ ] Home: `https://webaim.org/training/online/accessilist/php/home.php`
- [ ] Admin: `https://webaim.org/training/online/accessilist/admin`
- [ ] Minimal URL: `https://webaim.org/training/online/accessilist/?=ABC`
- [ ] API Health: `https://webaim.org/training/online/accessilist/php/api/health.php`

**Browser Console Check:**
```javascript
// On production site, open console:
console.log(window.ENV);
// Should show:
// {
//   environment: "production",
//   basePath: "/training/online/accessilist",
//   apiExtension: "",
//   debug: false,
//   isProduction: true,
//   isLocal: false
// }

console.log(window.getAPIPath('save'));
// Should show: /training/online/accessilist/php/api/save
```

### Step 4.4: Monitor Error Logs

```bash
# Watch Apache error log
tail -f /var/log/apache2/error.log

# Watch application logs (if any)
tail -f /var/websites/webaim/htdocs/training/online/accessilist/logs/*.log
```

---

## Rollback Plan

**If issues occur, rollback is simple:**

### Rollback Steps:
```bash
# On server or local
cd /path/to/accessilist

# Restore backup files
cp php/includes/config.php.backup php/includes/config.php
cp js/path-utils.js.backup js/path-utils.js
cp index.php.backup index.php

# Remove .env file (will trigger fallback to auto-detection)
rm .env

# Clear browser cache
# Restart Apache (if on server)
sudo service apache2 restart
```

**Verification After Rollback:**
- [ ] Site loads correctly with old auto-detection
- [ ] All URLs work as before
- [ ] API calls function normally
- [ ] No console errors

---

## Success Criteria

### Local Development ✅
- [x] .env file controls environment
- [x] Auto-detection removed (or fallback only)
- [x] All path helpers use injected config
- [x] API extension configurable
- [x] Debug mode shows config in console

### Production Readiness ⏳
- [ ] Production .env created
- [ ] All URLs use base path correctly
- [ ] API calls use correct extension
- [ ] Minimal URLs work
- [ ] No console errors
- [ ] Error logs clean

### Code Quality ✅
- [x] DRY: Single source of truth (.env)
- [x] Simple: One file controls environment
- [x] Reliable: Explicit configuration, no guessing
- [x] Backwards compatible: Fallback to auto-detection
- [x] Well documented: Comments and examples

---

## Troubleshooting

### Issue: "window.ENV is undefined"
**Solution:**
- Check that `config.php` is loaded first
- Check that `html-head.php` injects the config
- Verify `$envConfig` is defined
- Clear browser cache

### Issue: "API calls return 404"
**Solution:**
- Check API extension in .env (`API_EXT_LOCAL=.php`)
- Verify `.htaccess` rewrite rules are active
- Test API path: `console.log(window.getAPIPath('health'))`
- Check Apache mod_rewrite is enabled

### Issue: "Minimal URLs don't work (?=ABC)"
**Solution:**
- Verify `index.php` loads `config.php` first
- Check base path removal logic in `index.php`
- Test regex pattern with: `preg_match('/\/?\?=([A-Z0-9]{3})$/', '/?=ABC', $m); var_dump($m);`

### Issue: ".env file not found"
**Solution:**
- Verify `.env` exists: `ls -la .env`
- Check path in `config.php`: `__DIR__ . '/../../.env'`
- Ensure loadEnv() is called
- Fallback will activate automatically

---

## Documentation Updates

### Files to Update:
- [x] `README.md` - Add environment setup instructions
- [x] `SRD-ENVIRONMENT-PROPOSAL.md` - Enhanced with all improvements
- [ ] `DEPLOYMENT.md` - Update deployment steps with .env instructions
- [x] `URL-CREATION-ANALYSIS.md` - Note new .env-based method
- [ ] `changelog.md` - Add migration entry

### README.md Section to Add:
```markdown
## Environment Configuration

This project uses `.env` file for environment configuration:

1. Copy template: `cp .env.example .env`
2. Set environment: `APP_ENV=local` (or production, staging)
3. Start server: `php -S localhost:8000`

See [SRD-ENVIRONMENT-PROPOSAL.md](SRD-ENVIRONMENT-PROPOSAL.md) for details.
```

---

## Completion Status

- **Phase 1 (Setup):** ✅ COMPLETED
- **Phase 2 (Update Code):** ✅ COMPLETED
- **Phase 3 (Testing):** ✅ COMPLETED (Local)
- **Phase 4 (Production):** ⏳ PENDING DEPLOYMENT

**Next Step:** Deploy to production and complete Phase 4 verification.

