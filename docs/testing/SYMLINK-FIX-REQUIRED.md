# Production Mirror Symlink Fix Required

**Status:** ⚠️ **ACTION REQUIRED** (Requires sudo privileges)

## Issue

The production mirror symlink currently points to an outdated project location that no longer exists.

**Current symlink:**
```bash
/Library/WebServer/Documents/training/online/accessilist
→ /Users/a00288946/Desktop/accessilist  # ❌ OLD PATH (doesn't exist)
```

**Should point to:**
```bash
/Library/WebServer/Documents/training/online/accessilist
→ /Users/a00288946/Projects/accessilist  # ✅ CURRENT PROJECT
```

## Impact

- ❌ Production mirror tests will fail
- ❌ Apache won't be able to serve the application from production path
- ❌ Cannot validate production deployment before going live

## Solution

Run these commands to fix the symlink:

```bash
# Remove old symlink (requires sudo)
sudo rm /Library/WebServer/Documents/training/online/accessilist

# Create new symlink to current project location (requires sudo)
sudo ln -s /Users/a00288946/Projects/accessilist /Library/WebServer/Documents/training/online/accessilist

# Verify the fix
ls -la /Library/WebServer/Documents/training/online/accessilist
# Should show: accessilist -> /Users/a00288946/Projects/accessilist
```

## Verification

After fixing the symlink, verify production mirror works:

```bash
# 1. Switch to apache-local mode
# Edit .env: APP_ENV=apache_local

# 2. Setup/verify Apache configuration
./scripts/setup-local-apache.sh

# 3. Start Apache
npm run apache-start

# 4. Run production mirror tests
./scripts/test-production-mirror.sh

# 5. When done, stop Apache
sudo apachectl stop

# 6. Switch back to local mode
# Edit .env: APP_ENV=local
```

## Related Documentation

- See `docs/testing/PRODUCTION-MIRROR-TESTING.md` for complete testing guide
- See `archive/setup-guides/APACHE-SETUP-GUIDE.md` for Apache setup details

---

**Created:** 2025-10-14
**Priority:** Medium (required before production mirror testing)
**Requires:** Sudo privileges
