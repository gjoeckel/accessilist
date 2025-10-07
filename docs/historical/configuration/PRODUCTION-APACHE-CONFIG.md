# Production Apache Configuration

**Server:** `ec2-3-20-59-76.us-east-2.compute.amazonaws.com`
**SSH User:** `george`
**SSH Key:** `/Users/a00288946/Developer/projects/GeorgeWebAIMServerKey.pem`
**Connection:** `.pem` key authentication
**Date Retrieved:** October 7, 2025

> 📘 **For complete connection & deployment info, see:** `AWS-SERVER-CONNECTION.md`

---

## 🔧 **Apache Configuration**

### **Version & Modules**
```
Apache Version: 2.4.52 (Ubuntu)
mod_rewrite: ✅ ENABLED (shared)
PHP Integration: PHP-FPM (not mod_php)
```

### **DocumentRoot**
```
DocumentRoot: /var/websites/webaim/htdocs
Application Path: /var/websites/webaim/htdocs/training/online/accessilist
```

### **VirtualHost - webaim.org (HTTPS - Port 443)**
```apache
ServerName webaim.org
ServerAlias webaim.net www.webaim.net webaim.org
DocumentRoot /var/websites/webaim/htdocs
DirectoryIndex index.php index.htm index.html
ErrorDocument 404 /404.php

# PHP-FPM Configuration
<FilesMatch \.php$>
    SetHandler "proxy:unix:/run/php/php8.1-fpm.sock|fcgi://localhost"
</FilesMatch>

# Caching
<FilesMatch "\.(ico|pdf|flv|jpe?g|png|gif|js|css|swf)$">
    ExpiresActive On
    ExpiresDefault "access plus 1 year"
</FilesMatch>

# RewriteEngine On (enabled)

# Remove .php extensions (except /blog/)
RewriteCond  %{REQUEST_URI}  !^/blog/ [NC]
RewriteCond %{THE_REQUEST} ^[A-Z]{3,}\s([^.]+)\.php [NC]
RewriteRule ^ %1 [R,L]

# Internally forward non .php files
RewriteCond %{REQUEST_FILENAME} !-d
RewriteCond %{DOCUMENT_ROOT}/$1\.php -f
RewriteRule ^(.+?)/?$ $1.php [L]

# Strip trailing slashes for non-directories
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule ^([^.]+\.[^/]*)/$ http://webaim.org/$1 [R=301,L]
```

### **Directory Permissions**
```apache
<Directory /var/websites/webaim/>
    Options +FollowSymLinks +Multiviews
    AllowOverride All
    Require all granted
</Directory>
```

```bash
# File System Permissions
Owner: www-data:www-data
Directories: 775 (drwxrwxr-x)
Files: 644 (-rw-r--r--)
Apache User: www-data (runs as root but serves as www-data)
```

---

## 🐘 **PHP Configuration**

### **Version & Setup**
```
PHP Version: 8.1.2-1ubuntu2.22 (cli)
Integration: PHP-FPM (not mod_php)
Socket: /run/php/php8.1-fpm.sock
```

### **Apache PHP Handler**
```apache
<FilesMatch \.php$>
    SetHandler "proxy:unix:/run/php/php8.1-fpm.sock|fcgi://localhost"
</FilesMatch>
```

---

## 📁 **AccessiList Application**

### **Full Path**
```
/var/websites/webaim/htdocs/training/online/accessilist
```

### **.htaccess Location**
```
/var/websites/webaim/htdocs/training/online/accessilist/.htaccess ✅
/var/websites/webaim/htdocs/training/online/accessilist/saves/.htaccess ✅
```

### **Directory Structure**
```
drwxrwxr-x  18 www-data www-data  4096 Oct  6 22:03 .
drwxrwxr-x+ 25 www-data www-data  4096 Oct  6 19:20 ..
-rw-r--r--   1 george   www-data  1477 Oct  6 22:03 .htaccess
-rw-r--r--   1 george   www-data  ...  Oct  6 22:03 index.php
[css/, js/, php/, images/, etc.]
```

---

## 🌐 **URL Structure**

### **Production URLs**
```
Base URL: https://webaim.org/training/online/accessilist
Clean URLs (via .htaccess):
  - /home → /training/online/accessilist/home
  - /admin → /training/online/accessilist/admin
  - /?=ABC → /training/online/accessilist/?=ABC

Full URLs:
  - https://webaim.org/training/online/accessilist/home
  - https://webaim.org/training/online/accessilist/admin
  - https://webaim.org/training/online/accessilist/?=ABC
```

### **SSL Configuration**
```
SSL Engine: ON
Certificate: /etc/letsencrypt/live/webaim.org/fullchain.pem
Private Key: /etc/letsencrypt/live/webaim.org/privkey.pem
```

---

## 🔄 **Rewrite Rules Analysis**

### **From VirtualHost (webaim.org)**
```apache
# These affect the entire site:
1. Remove .php extensions (except /blog/)
2. Internal forwarding to .php files
3. Strip trailing slashes
```

### **From Application .htaccess**
```apache
# AccessiList-specific rewrites:
RewriteEngine On
RewriteBase /

# Specific routes BEFORE general patterns:
RewriteRule ^home/?$ php/home.php [L]
RewriteRule ^admin/?$ php/admin.php [L]

# API routes:
RewriteRule ^php/api/([^/.]+)$ php/api/$1.php [L]

# General PHP routes (LAST):
RewriteRule ^php/([^/.]+)$ php/$1.php [L]
```

---

## 🔍 **Key Findings for Local Setup**

### **Critical Configuration Elements**
1. ✅ **mod_rewrite**: MUST be enabled
2. ✅ **AllowOverride All**: MUST be set for .htaccess to work
3. ✅ **.htaccess**: Located in app root
4. ✅ **PHP**: Via FPM on production, can use mod_php locally
5. ✅ **Permissions**: 775 for directories, 644 for files

### **URL Mapping**
```
Production: /training/online/accessilist/home
Local:      /home (when served from project root)

Production uses BASE_PATH_PRODUCTION=/training/online/accessilist
Local uses BASE_PATH_LOCAL= (empty)
```

### **What Local Setup Must Match**
1. ✅ mod_rewrite enabled
2. ✅ AllowOverride All
3. ✅ .htaccess in DocumentRoot
4. ✅ PHP enabled (any method)
5. ✅ RewriteEngine On
6. ✅ Same .htaccess rules

### **What Can Differ**
- ❌ PHP integration method (FPM vs mod_php)
- ❌ Base path (production has /training/online/accessilist)
- ❌ User/group ownership
- ❌ SSL (not needed locally)

---

## 🚀 **Local Setup Instructions**

### **Automated Setup**
```bash
# Run the automated setup script
./scripts/setup-local-apache.sh
```

### **Manual Verification**
```bash
# 1. Check Apache version
apachectl -v

# 2. Enable mod_rewrite
sudo nano /etc/apache2/httpd.conf
# Uncomment: LoadModule rewrite_module libexec/apache2/mod_rewrite.so

# 3. Enable PHP
# Uncomment: LoadModule php_module libexec/apache2/libphp.so

# 4. Set AllowOverride All
# Find <Directory "/Library/WebServer/Documents">
# Change: AllowOverride None → AllowOverride All

# 5. Start Apache
sudo apachectl start
```

### **Testing**
```bash
# Test URLs:
curl -I http://localhost/
curl -I http://localhost/home
curl -I http://localhost/admin
curl -I http://localhost/php/home.php
```

---

## 📊 **Comparison Matrix**

| Feature | Production | Local macOS |
|---------|-----------|-------------|
| **Apache Version** | 2.4.52 (Ubuntu) | 2.4.x (varies) |
| **DocumentRoot** | `/var/websites/webaim/htdocs` | Project directory |
| **App Path** | `/var/websites/.../accessilist` | Project root |
| **mod_rewrite** | ✅ Enabled | ✅ Must enable |
| **AllowOverride** | All | ✅ Must set to All |
| **PHP** | 8.1 via FPM | 8.x via mod_php |
| **Base Path** | `/training/online/accessilist` | `` (empty) |
| **.htaccess** | Active | ✅ Active |
| **Clean URLs** | ✅ Works | ✅ Will work |
| **SSL** | Let's Encrypt | ❌ Not needed |

---

## ✅ **Setup Complete Checklist**

- [x] Production server accessed via SSH
- [x] Apache configuration documented
- [x] PHP setup documented
- [x] .htaccess rules confirmed
- [x] Directory permissions documented
- [x] URL structure analyzed
- [x] Automated setup script created
- [ ] Local Apache configured
- [ ] Clean URLs tested locally
- [ ] Production deployment ready

---

## 🔗 **SSH Connection Command**

```bash
# Connect to production server
ssh -i /Users/a00288946/Developer/projects/GeorgeWebAIMServerKey.pem \
    george@ec2-3-20-59-76.us-east-2.compute.amazonaws.com

# Run diagnostic
ssh -i /Users/a00288946/Developer/projects/GeorgeWebAIMServerKey.pem \
    george@ec2-3-20-59-76.us-east-2.compute.amazonaws.com \
    'bash -s' < ./scripts/diagnose-production-apache.sh
```

---

## 📝 **Notes**

1. **mod_rewrite** is critical - clean URLs won't work without it
2. **AllowOverride All** is required for .htaccess to be processed
3. **Base path** differs between local (empty) and production (`/training/online/accessilist`)
4. **.env file** handles environment-specific configuration
5. **Save/restore** is URL-independent (uses session keys)

---

**Configuration Retrieved:** October 7, 2025
**Next Step:** Run `./scripts/setup-local-apache.sh` to configure local environment

