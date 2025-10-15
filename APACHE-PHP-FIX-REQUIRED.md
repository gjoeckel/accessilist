# Apache PHP Configuration Fix

**Date**: 2025-10-15
**Status**: ⚠️ Action Required
**Priority**: Medium (Automated tests affected, manual testing works)

---

## Problem Identified

Apache is configured to use PHP-FPM (FastCGI) but PHP-FPM is not installed/running on this machine:

```
[proxy_fcgi:error] AH01079: failed to make connection to backend: 127.0.0.1:9000
```

**Current Config** (`/etc/apache2/other/accessilist.conf`):
```apache
<FilesMatch \.php$>
    SetHandler "proxy:fcgi://127.0.0.1:9000"
</FilesMatch>
```

**Result**: HTTP 503 errors for all PHP pages

---

## System Status

✅ **PHP CLI**: Installed (PHP 8.4.13)
❌ **PHP-FPM**: Not installed
❌ **mod_php**: Not loaded in Apache
✅ **Apache**: Running (PID 35866)
✅ **Global .env**: Configured (`/Users/a00288946/cursor-global/config/.env`)

---

## Solution Options

### Option 1: Use Built-in PHP Handler (RECOMMENDED - No Dependencies)

**Replace PHP-FPM config with built-in handler:**

```bash
# 1. Backup current config
sudo cp /etc/apache2/other/accessilist.conf /etc/apache2/other/accessilist.conf.backup

# 2. Apply updated config (see fixed-accessilist.conf below)
sudo cp /Users/a00288946/Projects/accessilist/config/apache/fixed-accessilist.conf /etc/apache2/other/accessilist.conf

# 3. Restart Apache
sudo apachectl restart
```

### Option 2: Install PHP-FPM (More Complex)

```bash
# Install PHP-FPM via Homebrew
brew install php-fpm

# Start PHP-FPM on port 9000
brew services start php-fpm

# Verify
lsof -i :9000  # Should show php-fpm
```

---

## Fixed Apache Configuration

**File**: `config/apache/fixed-accessilist.conf`

```apache
# AccessiList Local Development - Production Mirror
<VirtualHost *:80>
    ServerName localhost
    DocumentRoot "/Library/WebServer/Documents"

    # Use Apache built-in PHP handler instead of PHP-FPM
    # This works with PHP CLI and doesn't require PHP-FPM
    <FilesMatch \.php$>
        SetHandler application/x-httpd-php
    </FilesMatch>

    # Allow access to main directory
    <Directory "/Library/WebServer/Documents">
        Options +FollowSymLinks +Multiviews +Indexes
        AllowOverride All
        Require all granted
    </Directory>

    # Specific directory for accessilist (local root access)
    <Directory "/Library/WebServer/Documents/accessilist">
        Options +FollowSymLinks +Multiviews +Indexes
        AllowOverride All
        Require all granted
    </Directory>

    # Production path directory
    <Directory "/Library/WebServer/Documents/training">
        Options +FollowSymLinks +Multiviews +Indexes
        AllowOverride All
        Require all granted
    </Directory>

    DirectoryIndex index.php index.htm index.html
    RewriteEngine On

    ErrorLog "/private/var/log/apache2/accessilist_error.log"
    CustomLog "/private/var/log/apache2/accessilist_access.log" combined
</VirtualHost>
```

**Key Change**:
- ❌ `SetHandler "proxy:fcgi://127.0.0.1:9000"` (requires PHP-FPM)
- ✅ `SetHandler application/x-httpd-php"` (built-in, no dependencies)

---

## Enable mod_php (if needed)

```bash
# Check if mod_php module exists
ls -la /usr/libexec/apache2/libphp*.so

# If exists, enable in httpd.conf
sudo nano /etc/apache2/httpd.conf
# Uncomment: LoadModule php_module libexec/apache2/libphp.so

# Restart Apache
sudo apachectl restart
```

---

## Workaround (Current State)

**For now**, the test scripts can fallback to PHP built-in server:

```bash
# Manual testing (works now with global .env)
php -S localhost:8000 router.php

# Automated testing (update test-production-mirror.sh to use PHP server as fallback)
# if Apache not working, use: BASE_URL=http://localhost:8000
```

---

## Verification After Fix

```bash
# 1. Check Apache status
sudo apachectl status

# 2. Test PHP processing
curl http://localhost/training/online/accessilist/home

# 3. Check error logs
tail -f /var/log/apache2/accessilist_error.log
```

**Expected**: HTTP 200, proper HTML rendering, no FCGI errors

---

## Related Files

- Global .env: `/Users/a00288946/cursor-global/config/.env`
- Apache config: `/etc/apache2/other/accessilist.conf`
- Error log: `/var/log/apache2/accessilist_error.log`
- Test script: `scripts/test-production-mirror.sh`

---

## Implementation Status

✅ **Completed:**
- Global .env created in cursor-global
- config.php updated to use global .env
- Environment switcher script created
- Problem diagnosed

⚠️ **Requires Manual Action:**
- Apply fixed Apache configuration (requires sudo)
- OR install/start PHP-FPM
- Restart Apache

💡 **Temporary Workaround:**
- Tests can use PHP built-in server (localhost:8000)
- All functionality works, just different URL structure
