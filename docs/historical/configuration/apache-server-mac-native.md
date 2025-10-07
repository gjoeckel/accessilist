# Apache Server Setup - macOS Native Testing Environment

**Created:** October 7, 2025
**Purpose:** Complete documentation of Apache server setup for local production testing
**Platform:** macOS (Darwin 25.0.0)
**Status:** ✅ **COMPLETE & OPERATIONAL**

---

## Executive Summary

This document records **EVERYTHING** done to configure macOS Apache for local production testing of AccessiList. The setup mirrors production AWS server configuration and enables AI agent automated testing.

**Key Achievement:** Local Apache server now runs production-identical configuration for testing clean URLs, .htaccess rules, and deployment validation before pushing to AWS.

---

## System Changes Made

### 1. ✅ macOS Security: Full Disk Access

**Problem:** macOS security prevents Apache (httpd) from accessing Desktop folder

**Solution:** Symlink from Apache-accessible location

**Changes Made:**
```bash
# Created symlink (root owns it)
sudo ln -sf /Users/a00288946/Desktop/accessilist /Library/WebServer/Documents/accessilist

# Verification:
ls -la /Library/WebServer/Documents/accessilist
# Output: lrwxr-xr-x@ 1 root wheel 36 Oct 7 11:03 accessilist -> /Users/a00288946/Desktop/accessilist
```

**Alternative Considered (NOT USED):**
- System Settings → Privacy & Security → Full Disk Access → Add `/usr/sbin/httpd`
- Decided against it to avoid broad system permissions

**Status:** ✅ Permanent (symlink persists across reboots)

---

### 2. ✅ Passwordless Sudo for Apache

**Problem:** AI agent cannot provide password interactively for `sudo apachectl` commands

**Solution:** Configure passwordless sudo ONLY for apachectl

**File Created:** `/etc/sudoers.d/apache-a00288946`
```bash
# Permissions: -r--r----- 1 root wheel 173 Oct 7 10:45
# Created by: ./scripts/setup-passwordless-apache.sh
```

**Configuration:**
```bash
# Passwordless Apache control for a00288946
# Allows AI agent autonomous execution
# Created: Mon Oct  7 10:45:00 MDT 2025
a00288946 ALL=(ALL) NOPASSWD: /usr/sbin/apachectl
```

**Commands Now Passwordless:**
- `sudo apachectl start`
- `sudo apachectl stop`
- `sudo apachectl restart`
- `sudo apachectl configtest`
- `sudo apachectl status`

**Security:** ALL other sudo commands still require password

**Status:** ✅ Permanent (survives reboots)

**Created By:** `scripts/setup-passwordless-apache.sh` (lines 44-68)

---

### 3. ✅ Apache Configuration Files

#### A. httpd.conf Backup

**File:** `/etc/apache2/httpd.conf.backup`
- **Permissions:** `-rw-r--r--@ 1 root wheel 21648 Oct 7 10:52`
- **Purpose:** Original Apache config before modifications
- **Created By:** `scripts/setup-local-apache.sh` (line 72)

#### B. httpd.conf Modifications

**File:** `/etc/apache2/httpd.conf` (system file)

**Changes Made:**
```bash
# 1. Enabled PHP module (line ~176)
LoadModule php_module libexec/apache2/libphp.so  # Uncommented

# 2. Enabled mod_rewrite (line ~169)
LoadModule rewrite_module libexec/apache2/mod_rewrite.so  # Uncommented

# 3. Set AllowOverride All (line ~252, DocumentRoot section)
<Directory "/Library/WebServer/Documents">
    AllowOverride All  # Changed from None
</Directory>
```

**Commands Used:**
```bash
sudo sed -i '' 's/^#LoadModule php/LoadModule php/' /etc/apache2/httpd.conf
sudo sed -i '' 's/^#LoadModule rewrite_module/LoadModule rewrite_module/' /etc/apache2/httpd.conf
sudo sed -i '' '/<Directory "\/Library\/WebServer\/Documents">/,/<\/Directory>/{s/AllowOverride None/AllowOverride All/g}' /etc/apache2/httpd.conf
```

#### C. VirtualHost Configuration

**File:** `/etc/apache2/other/accessilist.conf`
- **Permissions:** `-rw-r--r--@ 1 root wheel 1199 Oct 7 12:25`
- **Purpose:** AccessiList-specific VirtualHost config
- **Created By:** `scripts/setup-local-apache.sh` (lines 116-152)

**Full Configuration:**
```apache
# AccessiList Local Development - Production Mirror
<VirtualHost *:80>
    ServerName localhost
    DocumentRoot "/Library/WebServer/Documents/accessilist"

    <FilesMatch \.php$>
        SetHandler application/x-httpd-php
    </FilesMatch>

    <Directory "/Library/WebServer/Documents/accessilist">
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

**DocumentRoot:** Uses symlink path (Full Disk Access workaround)

---

### 4. ✅ Project .htaccess Configuration

**File:** `/Users/a00288946/Desktop/accessilist/.htaccess`

**Purpose:** URL rewriting for clean URLs (production mirror)

**Key Rules:**
```apache
RewriteEngine On

# No RewriteBase - auto-determines from location

# Clean URL Routes
RewriteRule ^home/?$ php/home.php [L]
RewriteRule ^admin/?$ php/admin.php [L]

# API Routes: extensionless
RewriteRule ^php/api/([^/.]+)$ php/api/$1.php [L]

# General PHP Routes
RewriteRule ^php/([^/.]+)$ php/$1.php [L]
```

**Status:** ✅ Already existed, validated working

---

### 5. ✅ Local .env File

**File:** `/Users/a00288946/Desktop/accessilist/.env`

**Created By:** `scripts/setup-local-apache.sh` (lines 167-177)

**Content (for apache-local testing):**
```bash
APP_ENV=apache-local
BASE_PATH_LOCAL=
BASE_PATH_APACHE_LOCAL=/training/online/accessilist
BASE_PATH_PRODUCTION=/training/online/accessilist
API_EXT_LOCAL=.php
API_EXT_APACHE_LOCAL=
API_EXT_PRODUCTION=
DEBUG_LOCAL=true
DEBUG_APACHE_LOCAL=true
DEBUG_PRODUCTION=false
```

**Note:** Later moved to `.env.example` template (not in git)

---

## Scripts Created

### 1. `scripts/setup-local-apache.sh` (270 lines)
**Purpose:** One-time Apache configuration for production mirror
**Permissions:** `-rwxr-xr-x`
**Status:** ✅ Created and executed

**What It Does:**
- ✅ Backs up httpd.conf
- ✅ Enables PHP module
- ✅ Enables mod_rewrite
- ✅ Creates VirtualHost config
- ✅ Sets AllowOverride All
- ✅ Creates .env file
- ✅ Sets file permissions (755/644)
- ✅ Starts Apache
- ✅ Verifies configuration

### 2. `scripts/setup-passwordless-apache.sh` (113 lines)
**Purpose:** Configure passwordless sudo for apachectl
**Permissions:** `-rwxr-xr-x`
**Status:** ✅ Created and executed

**What It Does:**
- ✅ Creates `/etc/sudoers.d/apache-a00288946`
- ✅ Validates syntax with visudo
- ✅ Tests passwordless sudo works
- ✅ Sets proper permissions (440)

### 3. `scripts/apache-start.sh` (147 lines)
**Purpose:** Start Apache production simulation
**Permissions:** `-rwxr-xr-x`
**Status:** ✅ Created

**What It Does:**
- ✅ Stops existing Apache gracefully
- ✅ Tests configuration validity
- ✅ Starts Apache daemon
- ✅ Verifies modules (rewrite, PHP)
- ✅ Tests clean URLs
- ✅ Reports status

### 4. `scripts/local-apache-start.sh` (222 lines)
**Purpose:** Start BOTH PHP dev server + Apache
**Permissions:** `-rwxr-xr-x`
**Status:** ✅ Created

**What It Does:**
- ✅ Checks port availability (8000, 80)
- ✅ Kills conflicts if found
- ✅ Starts PHP server (port 8000, background)
- ✅ Starts Apache (port 80)
- ✅ Tests both servers
- ✅ Validates clean URLs

### 5. `scripts/local-start.sh` (82 lines)
**Purpose:** Start PHP dev server only
**Permissions:** `-rwxr-xr-x`
**Status:** ✅ Created

**What It Does:**
- ✅ Checks port 8000 availability
- ✅ Starts PHP server with router.php
- ✅ Tests server response

### 6. `scripts/diagnose-production-apache.sh` (189 lines)
**Purpose:** Diagnostic tool for Apache troubleshooting
**Permissions:** `-rwxr-xr-x`
**Status:** ✅ Created

**What It Does:**
- ✅ Checks Apache status
- ✅ Verifies configuration files
- ✅ Tests module loading
- ✅ Validates .htaccess
- ✅ Tests clean URLs
- ✅ Shows error logs

---

## NPM Scripts Added

**File:** `package.json`

**Scripts Added:**
```json
{
  "local-start": "bash scripts/local-start.sh",
  "apache-start": "bash scripts/apache-start.sh",
  "local-apache-start": "bash scripts/local-apache-start.sh"
}
```

**Usage:**
```bash
npm run local-start          # PHP only (no sudo)
npm run apache-start         # Apache only (requires sudo)
npm run local-apache-start   # Both servers (requires sudo)
```

---

## Complete Setup History (Chronological)

### Session 1: Initial Apache Setup (Oct 7, 10:00-11:00)

**1. Ran `scripts/setup-local-apache.sh`**
```bash
cd /Users/a00288946/Desktop/accessilist
./scripts/setup-local-apache.sh
```

**Actions Performed:**
- ✅ Backed up `/etc/apache2/httpd.conf` → `httpd.conf.backup`
- ✅ Enabled PHP module in httpd.conf
- ✅ Enabled mod_rewrite in httpd.conf
- ✅ Created VirtualHost: `/etc/apache2/other/accessilist.conf`
- ✅ Set AllowOverride All in httpd.conf
- ✅ Created `.env` file with `APP_ENV=local`
- ✅ Set file permissions (755 dirs, 644 files)
- ✅ Started Apache on port 80

**Result:** Apache running, but 403 Forbidden errors

---

### Session 2: Full Disk Access Fix (Oct 7, 11:00-11:30)

**2. Created symlink for Desktop access**
```bash
sudo ln -sf /Users/a00288946/Desktop/accessilist /Library/WebServer/Documents/accessilist
```

**3. Updated VirtualHost DocumentRoot**
```bash
sudo sed -i '' 's|DocumentRoot "/Users/a00288946/Desktop/accessilist"|DocumentRoot "/Library/WebServer/Documents/accessilist"|' /etc/apache2/other/accessilist.conf
```

**4. Restarted Apache**
```bash
sudo apachectl restart
```

**Result:** ✅ Apache now serving files successfully

---

### Session 3: Passwordless Sudo Setup (Oct 7, 10:45)

**5. Ran `scripts/setup-passwordless-apache.sh`**
```bash
./scripts/setup-passwordless-apache.sh
```

**Actions Performed:**
- ✅ Created `/etc/sudoers.d/apache-a00288946`
- ✅ Validated syntax with `visudo -c`
- ✅ Set permissions: `chmod 440`
- ✅ Set ownership: `chown root:wheel`
- ✅ Tested passwordless sudo works

**Result:** ✅ AI agent can now run `sudo apachectl` without password

---

## Verification & Testing

### URLs Tested & Working:

| URL | Method | Status | Notes |
|-----|--------|--------|-------|
| `http://localhost/` | GET | ✅ 200/302 | Root redirects to /home |
| `http://localhost/home` | GET | ✅ 200 | Clean URL working |
| `http://localhost/admin` | GET | ✅ 200 | Clean URL working |
| `http://localhost/php/home.php` | GET | ✅ 200 | Direct PHP access |
| `http://localhost/php/api/list` | GET | ✅ 200 | Extensionless API |

### Apache Modules Verified:

```bash
apachectl -M | grep -E "rewrite|php"
```

**Output:**
- ✅ `rewrite_module` (shared) - ENABLED
- ✅ PHP module - ENABLED (mod_php)

### Apache Version:

```bash
apachectl -v
```

**Output:**
```
Server version: Apache/2.4.62 (Unix)
Server built:   Aug  2 2025 22:05:07
```

---

## Configuration Files Summary

### System-Level Changes (Requires Rollback)

| File | Type | Original | Modified | Backed Up |
|------|------|----------|----------|-----------|
| `/etc/apache2/httpd.conf` | Modified | ✅ | ✅ | ✅ Yes (httpd.conf.backup) |
| `/etc/apache2/other/accessilist.conf` | Created | ❌ | ✅ | N/A |
| `/etc/sudoers.d/apache-a00288946` | Created | ❌ | ✅ | N/A |
| `/Library/WebServer/Documents/accessilist` | Symlink | ❌ | ✅ | N/A |

### Project-Level Changes (In Git)

| File | Status | Purpose |
|------|--------|---------|
| `scripts/setup-local-apache.sh` | Created | One-time Apache setup |
| `scripts/setup-passwordless-apache.sh` | Created | Passwordless sudo config |
| `scripts/apache-start.sh` | Created | Start Apache only |
| `scripts/local-apache-start.sh` | Created | Start both servers |
| `scripts/local-start.sh` | Created | Start PHP only |
| `scripts/diagnose-production-apache.sh` | Created | Troubleshooting tool |
| `.htaccess` | Validated | URL rewriting rules |

---

## Documentation Created

| Document | Purpose | Lines |
|----------|---------|-------|
| `APACHE-SETUP-GUIDE.md` | Quick setup guide | 272 |
| `APACHE-403-FIX.md` | Full Disk Access fix | 55 |
| `APACHE-TESTING-REPORT.md` | Testing results | ~200 |
| `SUDO-AUTHORIZATION-OPTIONS.md` | Sudo configuration options | 272 |
| `SERVER-SETUP-COMPLETE.md` | Implementation summary | 307 |
| `SERVER-COMMANDS.md` | Command reference | 383 |
| `PRODUCTION-APACHE-CONFIG.md` | Production config details | 312 |
| `AUTONOMOUS-SERVER-EXECUTION.md` | AI agent capabilities | ~150 |

---

## Git History

### Commits Related to Apache Setup:

```bash
git log --all --grep="Apache\|apache\|sudo" --oneline
```

**Key Commits:**
1. `4ce0e58` - feat: implement strict mode environment configuration and production testing
2. `2ea5c1f` - Implement single .env deployment workflow
3. `4b17d89` - Refactor: Remove .env from version control
4. `d0836d0` - feat: Scalability & Admin Type Column fixes (current)

---

## ROLLBACK PROCEDURES

### Complete Rollback Script

**File:** `rollback-apache-setup.sh`

```bash
#!/bin/bash

# Rollback Apache Setup to Pre-Configuration State
# This removes ALL changes made during Apache setup

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${RED}⚠️  Apache Setup Rollback${NC}"
echo "=============================================="
echo ""
echo -e "${YELLOW}This will UNDO all Apache configuration changes${NC}"
echo -e "${YELLOW}Press Ctrl+C within 5 seconds to cancel...${NC}"
sleep 5
echo ""

# Step 1: Stop Apache
echo -e "${BLUE}📋 Step 1: Stopping Apache${NC}"
if sudo apachectl -k status &> /dev/null; then
    sudo apachectl -k stop
    echo -e "${GREEN}✅ Apache stopped${NC}"
else
    echo -e "${GREEN}✅ Apache already stopped${NC}"
fi
echo ""

# Step 2: Remove VirtualHost config
echo -e "${BLUE}📋 Step 2: Removing VirtualHost${NC}"
if [ -f /etc/apache2/other/accessilist.conf ]; then
    sudo rm /etc/apache2/other/accessilist.conf
    echo -e "${GREEN}✅ VirtualHost removed${NC}"
else
    echo -e "${YELLOW}⚠️  VirtualHost already removed${NC}"
fi
echo ""

# Step 3: Restore original httpd.conf
echo -e "${BLUE}📋 Step 3: Restoring Original Apache Config${NC}"
if [ -f /etc/apache2/httpd.conf.backup ]; then
    sudo cp /etc/apache2/httpd.conf.backup /etc/apache2/httpd.conf
    echo -e "${GREEN}✅ httpd.conf restored${NC}"
else
    echo -e "${RED}❌ Backup not found - httpd.conf NOT restored${NC}"
fi
echo ""

# Step 4: Remove symlink
echo -e "${BLUE}📋 Step 4: Removing Symlink${NC}"
if [ -L /Library/WebServer/Documents/accessilist ]; then
    sudo rm /Library/WebServer/Documents/accessilist
    echo -e "${GREEN}✅ Symlink removed${NC}"
else
    echo -e "${YELLOW}⚠️  Symlink already removed${NC}"
fi
echo ""

# Step 5: Remove passwordless sudo (OPTIONAL)
echo -e "${BLUE}📋 Step 5: Remove Passwordless Sudo (Optional)${NC}"
if [ -f /etc/sudoers.d/apache-a00288946 ]; then
    echo -e "${YELLOW}Passwordless sudo configuration exists${NC}"
    echo -e "${YELLOW}Remove it? (y/n)${NC}"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        sudo rm /etc/sudoers.d/apache-a00288946
        echo -e "${GREEN}✅ Passwordless sudo removed${NC}"
    else
        echo -e "${BLUE}ℹ️  Keeping passwordless sudo${NC}"
    fi
else
    echo -e "${GREEN}✅ No passwordless sudo config${NC}"
fi
echo ""

# Step 6: Clean up log files
echo -e "${BLUE}📋 Step 6: Cleaning Up Logs${NC}"
sudo rm -f /private/var/log/apache2/accessilist_error.log
sudo rm -f /private/var/log/apache2/accessilist_access.log
echo -e "${GREEN}✅ Logs removed${NC}"
echo ""

# Summary
echo -e "${GREEN}✅ Rollback Complete${NC}"
echo "=============================================="
echo ""
echo -e "${BLUE}System State:${NC}"
echo "  ✅ VirtualHost removed"
echo "  ✅ httpd.conf restored to original"
echo "  ✅ Symlink removed"
echo "  ✅ Logs cleaned"
if [ -f /etc/sudoers.d/apache-a00288946 ]; then
    echo "  ⚠️  Passwordless sudo still configured"
else
    echo "  ✅ Passwordless sudo removed"
fi
echo ""
echo -e "${YELLOW}💡 Apache is back to default macOS state${NC}"
echo ""
```

### Manual Rollback Steps

If script fails, manually execute:

```bash
# 1. Stop Apache
sudo apachectl stop

# 2. Remove VirtualHost
sudo rm /etc/apache2/other/accessilist.conf

# 3. Restore httpd.conf
sudo cp /etc/apache2/httpd.conf.backup /etc/apache2/httpd.conf

# 4. Remove symlink
sudo rm /Library/WebServer/Documents/accessilist

# 5. Remove passwordless sudo (optional)
sudo rm /etc/sudoers.d/apache-a00288946

# 6. Clean logs
sudo rm -f /private/var/log/apache2/accessilist_*

# 7. Verify
sudo apachectl configtest
```

---

## Current State Snapshot (Oct 7, 2025)

### Apache Status:
```bash
sudo apachectl status
# Result: Running/Stopped (varies)
```

### Files Modified:
- ✅ 4 system files modified/created
- ✅ 6 project scripts created
- ✅ 8 documentation files created
- ✅ 1 symlink created

### Git Branch:
- **Branch:** `apache-server-eval`
- **Based on:** `main` (commit d0836d0)
- **Status:** Clean working directory

### Sudo Configuration:
- ✅ Passwordless: `/usr/sbin/apachectl` only
- ✅ Protected: All other sudo commands

### Apache Configuration:
- ✅ VirtualHost: Configured for localhost
- ✅ DocumentRoot: `/Library/WebServer/Documents/accessilist` (symlink)
- ✅ mod_rewrite: Enabled
- ✅ PHP module: Enabled
- ✅ AllowOverride: All

---

## Testing Capabilities Enabled

### Manual User Testing:
- ✅ PHP dev server: `npm run local-start`
- ✅ Apache server: `npm run apache-start`
- ✅ Both servers: `npm run local-apache-start`

### AI Agent Automated Testing:
- ✅ Can start PHP server autonomously (no sudo)
- ✅ Can start Apache autonomously (passwordless sudo configured)
- ✅ Can test clean URLs
- ✅ Can validate .htaccess rules
- ✅ Can compare PHP vs Apache behavior

---

## Maintenance & Troubleshooting

### View Apache Error Log:
```bash
tail -f /var/log/apache2/accessilist_error.log
```

### View Apache Access Log:
```bash
tail -f /var/log/apache2/accessilist_access.log
```

### Test Apache Config:
```bash
sudo apachectl configtest
```

### View Loaded Modules:
```bash
apachectl -M | grep -E "rewrite|php"
```

### Check What's Using Port 80:
```bash
sudo lsof -i:80
```

---

## Summary

### What Was Done:
1. ✅ Configured macOS Apache to mirror AWS production
2. ✅ Enabled PHP module (mod_php)
3. ✅ Enabled mod_rewrite for clean URLs
4. ✅ Created VirtualHost for AccessiList
5. ✅ Solved Full Disk Access with symlink
6. ✅ Configured passwordless sudo for AI autonomy
7. ✅ Created 6 management scripts
8. ✅ Validated clean URL functionality
9. ✅ Documented complete setup process
10. ✅ Created rollback procedures

### Result:
🎉 **Local Apache environment ready for production simulation testing**

### Rollback Available:
✅ Complete rollback script provided above
✅ Backup of original httpd.conf exists
✅ All changes documented for manual rollback

---

**Document Complete - Ready for Apache Server Evaluation**
