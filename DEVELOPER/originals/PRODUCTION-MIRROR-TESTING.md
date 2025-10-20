# Production-Mirror Testing Guide

**Date**: October 8, 2025
**Purpose**: Comprehensive testing on local Apache configured to mirror production server

---

## Production Server Specifications

The production server runs:
- **Apache**: 2.4.52
- **PHP**: 8.1 via PHP-FPM
- **mod_rewrite**: Enabled
- **Base Path**: `/training/online/accessilist`
- **Clean URLs**: Enabled (extensionless routes)
- **AllowOverride**: All (`.htaccess` processed)

---

## Setup Instructions

### 1. Configure Environment

The `.env` file is configured for `apache-local` mode:

```bash
APP_ENV=apache-local
BASE_PATH_APACHE_LOCAL=/training/online/accessilist
API_EXT_APACHE_LOCAL=
DEBUG_APACHE_LOCAL=true
```

✅ **Already configured**

### 2. Setup Production Path Structure

Run this command to create the production path mirror:

```bash
sudo ./scripts/setup-production-path.sh
```

This creates:
- Directory: `/Library/WebServer/Documents/training/online/`
- Symlink: `/Library/WebServer/Documents/training/online/accessilist` → Project directory
- Production URL: `http://localhost/training/online/accessilist`

### 3. Setup/Verify Apache Configuration

If Apache isn't configured yet, run:

```bash
./scripts/setup-local-apache.sh
```

This configures:
- ✅ Enables mod_rewrite
- ✅ Enables PHP module
- ✅ Sets AllowOverride All
- ✅ Creates VirtualHost configuration
- ✅ Sets proper permissions

### 4. Start Apache

```bash
npm run apache-start
# or
./scripts/apache-start.sh
```

---

## Running Comprehensive Tests

### Full Production-Mirror Test Suite

```bash
./scripts/test-production-mirror.sh
```

**Tests included:**
1. ✅ Prerequisites check (Apache, PHP, mod_rewrite, .env, .htaccess)
2. ✅ Basic connectivity
3. ✅ Clean URL routes (`/home`, `/admin`, `/reports`)
4. ✅ Direct PHP file access
5. ✅ API endpoints (extensionless, production-style)
6. ✅ API endpoints (with .php extension)
7. ✅ Static assets (CSS, JS, images, JSON)
8. ✅ Content verification
9. ✅ Save/Restore API workflow (complete cycle)
10. ✅ Minimal URL parameter tracking
11. ✅ Error handling (404s)
12. ✅ Security headers
13. ✅ Production base path configuration

**Output**: Detailed test results with pass/fail for each test, log file saved to `logs/`

---

## Test Categories

### Category 1: URL Routing (Production Mirror)

Tests that Apache + `.htaccess` handle URLs exactly like production:

| URL | Expected | Description |
|-----|----------|-------------|
| `/training/online/accessilist/` | 302 → `/home` | Root redirect |
| `/training/online/accessilist/home` | 200 | Clean URL |
| `/training/online/accessilist/admin` | 200 | Clean URL |
| `/training/online/accessilist/reports` | 200 | Clean URL |
| `/training/online/accessilist/php/home.php` | 200 | Direct access |
| `/training/online/accessilist/php/api/list` | 200 | Extensionless API |

### Category 2: API Functionality

Tests all API endpoints work in production configuration:

- **Instantiate API**: Create new session
- **Save API**: Save checklist state
- **Restore API**: Retrieve checklist state
- **List API**: Get all sessions
- **Health API**: Server health check

### Category 3: Static Assets

Verify all assets load with correct MIME types:

- CSS files (`/css/*.css`)
- JavaScript files (`/js/*.js`)
- Images (`/images/*.svg`)
- JSON templates (`/json/*.json`)

### Category 4: Content Verification

Ensure pages render correctly with production paths:

- Base path in HTML (`/training/online/accessilist`)
- JavaScript ENV injection (`window.ENV`)
- Path configuration in all assets
- Proper ARIA attributes and accessibility

---

## Manual Testing Checklist

After automated tests pass, manually verify:

### 1. Navigation
- [ ] Home page loads at `http://localhost/training/online/accessilist/home`
- [ ] Admin page loads and shows sessions
- [ ] Reports page loads (if available)
- [ ] All navigation buttons work

### 2. Checklist Functionality
- [ ] Can select checklist type
- [ ] Can create new checklist session
- [ ] Can enter notes in textareas
- [ ] Can change status buttons (pending → in-progress → completed)
- [ ] Side panel navigation works
- [ ] Scroll to section works

### 3. Save/Restore
- [ ] Auto-save triggers after 3 seconds
- [ ] Manual save button works
- [ ] Page reload restores state
- [ ] Session key in URL works (`/?=ABC`)

### 4. Admin Functions
- [ ] Admin page lists all sessions
- [ ] Can filter by type
- [ ] Can filter by status
- [ ] Can delete sessions
- [ ] Timestamps display correctly

### 5. Production Path Verification
- [ ] View page source → all paths include `/training/online/accessilist`
- [ ] Browser console → check `window.ENV.basePath`
- [ ] Network tab → all requests use production base path
- [ ] No 404 errors for any assets

---

## Troubleshooting

### Apache not responding

```bash
# Check Apache status
sudo apachectl status

# Check error log
tail -f /var/log/apache2/accessilist_error.log

# Restart Apache
sudo apachectl restart
```

### Clean URLs not working (404 errors)

```bash
# Verify mod_rewrite is enabled
apachectl -M | grep rewrite

# Test Apache configuration
sudo apachectl configtest

# Check .htaccess exists
ls -la .htaccess
```

### Wrong base path in HTML

```bash
# Check .env configuration
cat .env | grep APP_ENV
cat .env | grep BASE_PATH

# Should show:
# APP_ENV=apache-local
# BASE_PATH_APACHE_LOCAL=/training/online/accessilist
```

### Assets returning 404

```bash
# Check symlink exists
ls -la /Library/WebServer/Documents/training/online/

# Should show:
# accessilist -> /Users/a00288946/Projects/accessilist
```

### PHP not executing

```bash
# Check PHP module
apachectl -M | grep php

# Check PHP version
php -v

# If missing, run setup again
./scripts/setup-local-apache.sh
```

---

## Success Criteria

All tests should pass with these results:

- ✅ **Prerequisites**: All checks green
- ✅ **Clean URLs**: All routes return 200
- ✅ **API Endpoints**: All endpoints return 200
- ✅ **Static Assets**: All assets load successfully
- ✅ **Save/Restore**: Complete cycle works
- ✅ **Production Paths**: Base path correctly injected in all HTML/JS

**Expected**: 100% pass rate on all automated tests

---

## After Testing

### Stop Apache

```bash
sudo apachectl stop
```

### Switch Back to Local Development

Edit `.env`:
```bash
APP_ENV=local
```

Then use PHP dev server:
```bash
npm run local-start
```

---

## Files Created/Updated

| File | Purpose |
|------|---------|
| `.env` | Environment configuration (apache-local) |
| `scripts/test-production-mirror.sh` | Comprehensive test suite |
| `scripts/setup-production-path.sh` | Production path structure setup |
| `PRODUCTION-MIRROR-TESTING.md` | This documentation |

---

## Quick Reference

```bash
# Full test sequence
sudo ./scripts/setup-production-path.sh   # One-time setup
npm run apache-start                       # Start Apache
./scripts/test-production-mirror.sh        # Run all tests
sudo apachectl stop                        # Stop when done
```

---

**Created**: October 8, 2025
**YOLO Mode**: ✅ Enabled
**MCP Tools**: 39 tools operational

