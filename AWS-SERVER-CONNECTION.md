# AWS Server Connection Guide

**Complete connection information for AccessiList production server**

---

## 🔑 **Connection Credentials**

### **Server Details**
```
Hostname: ec2-3-20-59-76.us-east-2.compute.amazonaws.com
Region: us-east-2 (Ohio)
SSH User: george
Authentication: SSH key (.pem file)
```

### **SSH Key File**
```
Location: /Users/a00288946/Developer/projects/GeorgeWebAIMServerKey.pem
Permissions: 600 (already set correctly)
Name Pattern: GeorgeWebAIMServerKey
```

### **User Permissions**
```
SSH User: george
Can read: ✅ Apache configs, application files
Can write: ✅ Application files (/var/websites/webaim/htdocs/training/online/accessilist)
Sudo access: ⚠️ Requires password (may be limited)
Apache user: www-data (files owned by www-data:www-data)
```

---

## 🌐 **Quick Connection Commands**

### **Basic SSH Connection**
```bash
# Standard connection
ssh -i /Users/a00288946/Developer/projects/GeorgeWebAIMServerKey.pem \
    george@ec2-3-20-59-76.us-east-2.compute.amazonaws.com

# With port forwarding (if needed)
ssh -i /Users/a00288946/Developer/projects/GeorgeWebAIMServerKey.pem \
    -L 8080:localhost:80 \
    george@ec2-3-20-59-76.us-east-2.compute.amazonaws.com

# With X11 forwarding (if needed)
ssh -i /Users/a00288946/Developer/projects/GeorgeWebAIMServerKey.pem \
    -X \
    george@ec2-3-20-59-76.us-east-2.compute.amazonaws.com
```

### **Quick Diagnostic**
```bash
# Run diagnostic script on server
ssh -i /Users/a00288946/Developer/projects/GeorgeWebAIMServerKey.pem \
    george@ec2-3-20-59-76.us-east-2.compute.amazonaws.com \
    'bash -s' < ./scripts/diagnose-production-apache.sh
```

### **One-liner Commands**
```bash
# Check Apache status
ssh -i /Users/a00288946/Developer/projects/GeorgeWebAIMServerKey.pem \
    george@ec2-3-20-59-76.us-east-2.compute.amazonaws.com \
    "apache2ctl -M | grep rewrite"

# Check PHP version
ssh -i /Users/a00288946/Developer/projects/GeorgeWebAIMServerKey.pem \
    george@ec2-3-20-59-76.us-east-2.compute.amazonaws.com \
    "php -v"

# Check application files
ssh -i /Users/a00288946/Developer/projects/GeorgeWebAIMServerKey.pem \
    george@ec2-3-20-59-76.us-east-2.compute.amazonaws.com \
    "ls -la /var/websites/webaim/htdocs/training/online/accessilist/"
```

---

## 📁 **Server File Structure**

### **Application Paths**
```
Application Root: /var/websites/webaim/htdocs/training/online/accessilist
Apache DocumentRoot: /var/websites/webaim/htdocs
Apache Logs: /var/websites/webaim/logs/
  - error.log
  - access.log
Apache Config: /etc/apache2/sites-available/webaim.org.conf
```

### **Key Directories**
```
/var/websites/webaim/htdocs/
├── training/
│   └── online/
│       └── accessilist/          # ← Application root
│           ├── .htaccess          # ← Rewrite rules
│           ├── index.php
│           ├── .env               # ← Environment config (if exists)
│           ├── css/
│           ├── js/
│           ├── php/
│           │   ├── api/
│           │   └── saves/         # ← Writable directory
│           ├── saves/             # ← Alternative writable directory
│           └── images/
```

---

## 🚀 **Deployment Commands**

### **File Transfer - rsync (Recommended)**
```bash
# Dry run (preview changes)
rsync -avz --dry-run \
  --exclude .git/ \
  --exclude .cursor/ \
  --exclude node_modules/ \
  --exclude .DS_Store \
  -e "ssh -i /Users/a00288946/Developer/projects/GeorgeWebAIMServerKey.pem" \
  /Users/a00288946/Desktop/accessilist/ \
  george@ec2-3-20-59-76.us-east-2.compute.amazonaws.com:/var/websites/webaim/htdocs/training/online/accessilist/

# Actual deployment
rsync -avz \
  --exclude .git/ \
  --exclude .cursor/ \
  --exclude node_modules/ \
  --exclude .DS_Store \
  -e "ssh -i /Users/a00288946/Developer/projects/GeorgeWebAIMServerKey.pem" \
  /Users/a00288946/Desktop/accessilist/ \
  george@ec2-3-20-59-76.us-east-2.compute.amazonaws.com:/var/websites/webaim/htdocs/training/online/accessilist/

# Deploy only specific files
rsync -avz \
  -e "ssh -i /Users/a00288946/Developer/projects/GeorgeWebAIMServerKey.pem" \
  /Users/a00288946/Desktop/accessilist/.htaccess \
  /Users/a00288946/Desktop/accessilist/index.php \
  /Users/a00288946/Desktop/accessilist/js/path-utils.js \
  george@ec2-3-20-59-76.us-east-2.compute.amazonaws.com:/var/websites/webaim/htdocs/training/online/accessilist/
```

### **File Transfer - scp (Alternative)**
```bash
# Upload single file
scp -i /Users/a00288946/Developer/projects/GeorgeWebAIMServerKey.pem \
  /Users/a00288946/Desktop/accessilist/.htaccess \
  george@ec2-3-20-59-76.us-east-2.compute.amazonaws.com:/var/websites/webaim/htdocs/training/online/accessilist/

# Upload directory
scp -r -i /Users/a00288946/Developer/projects/GeorgeWebAIMServerKey.pem \
  /Users/a00288946/Desktop/accessilist/js/ \
  george@ec2-3-20-59-76.us-east-2.compute.amazonaws.com:/var/websites/webaim/htdocs/training/online/accessilist/

# Download file from server
scp -i /Users/a00288946/Developer/projects/GeorgeWebAIMServerKey.pem \
  george@ec2-3-20-59-76.us-east-2.compute.amazonaws.com:/var/websites/webaim/htdocs/training/online/accessilist/.htaccess \
  /Users/a00288946/Desktop/accessilist/.htaccess.backup
```

---

## 🔧 **Common Server Tasks**

### **Check Application Status**
```bash
# View error log
ssh -i /Users/a00288946/Developer/projects/GeorgeWebAIMServerKey.pem \
    george@ec2-3-20-59-76.us-east-2.compute.amazonaws.com \
    "tail -n 50 /var/websites/webaim/logs/error.log"

# View access log
ssh -i /Users/a00288946/Developer/projects/GeorgeWebAIMServerKey.pem \
    george@ec2-3-20-59-76.us-east-2.compute.amazonaws.com \
    "tail -n 50 /var/websites/webaim/logs/access.log"

# Check disk space
ssh -i /Users/a00288946/Developer/projects/GeorgeWebAIMServerKey.pem \
    george@ec2-3-20-59-76.us-east-2.compute.amazonaws.com \
    "df -h /var/websites/"
```

### **Backup Commands**
```bash
# Backup application files
ssh -i /Users/a00288946/Developer/projects/GeorgeWebAIMServerKey.pem \
    george@ec2-3-20-59-76.us-east-2.compute.amazonaws.com \
    "cd /var/websites/webaim/htdocs/training/online && tar -czf accessilist-backup-$(date +%Y%m%d).tar.gz accessilist/"

# Download backup
scp -i /Users/a00288946/Developer/projects/GeorgeWebAIMServerKey.pem \
    george@ec2-3-20-59-76.us-east-2.compute.amazonaws.com:/var/websites/webaim/htdocs/training/online/accessilist-backup-*.tar.gz \
    ~/Desktop/
```

### **Permission Fixes**
```bash
# Set correct permissions (if files uploaded with wrong permissions)
ssh -i /Users/a00288946/Developer/projects/GeorgeWebAIMServerKey.pem \
    george@ec2-3-20-59-76.us-east-2.compute.amazonaws.com \
    "find /var/websites/webaim/htdocs/training/online/accessilist -type d -exec chmod 775 {} \; && \
     find /var/websites/webaim/htdocs/training/online/accessilist -type f -exec chmod 644 {} \;"
```

---

## 🔍 **Verification & Testing**

### **After Deployment - Test URLs**
```bash
# Test main page
curl -I https://webaim.org/training/online/accessilist/

# Test home clean URL
curl -I https://webaim.org/training/online/accessilist/home

# Test admin clean URL
curl -I https://webaim.org/training/online/accessilist/admin

# Test API endpoint
curl -I https://webaim.org/training/online/accessilist/php/api/health
```

### **Check .htaccess is Working**
```bash
# View .htaccess on server
ssh -i /Users/a00288946/Developer/projects/GeorgeWebAIMServerKey.pem \
    george@ec2-3-20-59-76.us-east-2.compute.amazonaws.com \
    "cat /var/websites/webaim/htdocs/training/online/accessilist/.htaccess"

# Check if mod_rewrite is processing it
ssh -i /Users/a00288946/Developer/projects/GeorgeWebAIMServerKey.pem \
    george@ec2-3-20-59-76.us-east-2.compute.amazonaws.com \
    "apache2ctl -M | grep rewrite"
```

---

## 🛠️ **Troubleshooting**

### **Permission Denied Issues**
```bash
# If you can't write to the directory
# Check current permissions
ssh -i /Users/a00288946/Developer/projects/GeorgeWebAIMServerKey.pem \
    george@ec2-3-20-59-76.us-east-2.compute.amazonaws.com \
    "ls -la /var/websites/webaim/htdocs/training/online/accessilist/"

# Files should be owned by: www-data:www-data or george:www-data
# User 'george' should be in 'www-data' group
```

### **Connection Issues**
```bash
# Test basic connectivity
ping ec2-3-20-59-76.us-east-2.compute.amazonaws.com

# Test SSH port
nc -zv ec2-3-20-59-76.us-east-2.compute.amazonaws.com 22

# Verbose SSH connection (for debugging)
ssh -vvv -i /Users/a00288946/Developer/projects/GeorgeWebAIMServerKey.pem \
    george@ec2-3-20-59-76.us-east-2.compute.amazonaws.com
```

### **File Transfer Issues**
```bash
# Test with verbose mode
rsync -avz --progress -e "ssh -vvv -i /Users/a00288946/Developer/projects/GeorgeWebAIMServerKey.pem" \
  /Users/a00288946/Desktop/accessilist/.htaccess \
  george@ec2-3-20-59-76.us-east-2.compute.amazonaws.com:/var/websites/webaim/htdocs/training/online/accessilist/
```

---

## 📝 **SSH Config Shortcut (Optional)**

Add to `~/.ssh/config` for easier connection:

```bash
# Add this to ~/.ssh/config
Host webaim-prod
    HostName ec2-3-20-59-76.us-east-2.compute.amazonaws.com
    User george
    IdentityFile /Users/a00288946/Developer/projects/GeorgeWebAIMServerKey.pem
    ServerAliveInterval 60
    ServerAliveCountMax 3

# Then connect with just:
ssh webaim-prod

# Or deploy with:
rsync -avz --exclude .git/ /Users/a00288946/Desktop/accessilist/ \
  webaim-prod:/var/websites/webaim/htdocs/training/online/accessilist/
```

---

## ⚡ **Quick Deployment Script**

Save this as `scripts/deploy-to-aws.sh`:

```bash
#!/bin/bash

# Quick deploy to AWS production
PEM_FILE="/Users/a00288946/Developer/projects/GeorgeWebAIMServerKey.pem"
SERVER="george@ec2-3-20-59-76.us-east-2.compute.amazonaws.com"
REMOTE_PATH="/var/websites/webaim/htdocs/training/online/accessilist"
LOCAL_PATH="/Users/a00288946/Desktop/accessilist"

echo "🚀 Deploying to AWS production..."

# Dry run first
echo "📋 Preview changes:"
rsync -avz --dry-run \
  --exclude .git/ \
  --exclude .cursor/ \
  --exclude node_modules/ \
  --exclude .DS_Store \
  -e "ssh -i $PEM_FILE" \
  "$LOCAL_PATH/" \
  "$SERVER:$REMOTE_PATH/"

# Ask for confirmation
read -p "Deploy these changes? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "📤 Deploying..."
    rsync -avz \
      --exclude .git/ \
      --exclude .cursor/ \
      --exclude node_modules/ \
      --exclude .DS_Store \
      -e "ssh -i $PEM_FILE" \
      "$LOCAL_PATH/" \
      "$SERVER:$REMOTE_PATH/"

    echo "✅ Deployment complete!"
    echo "🌐 Test at: https://webaim.org/training/online/accessilist/"
else
    echo "❌ Deployment cancelled"
fi
```

---

## 📊 **Additional Information Captured**

### **From Dreamweaver Sync File**
- Original discovery location: `images/_notes/dwsync.xml`
- Contains file sync history
- Confirms server path structure
- Shows www-data:www-data ownership pattern

### **Server Configuration Details**
- **Apache Version:** 2.4.52 (Ubuntu)
- **PHP Version:** 8.1.2-1ubuntu2.22
- **PHP Integration:** PHP-FPM (socket: /run/php/php8.1-fpm.sock)
- **mod_rewrite:** ✅ Enabled
- **AllowOverride:** All (for /var/websites/webaim/)
- **SSL:** Let's Encrypt (webaim.org)

### **Directory Permissions**
```
Owner: www-data:www-data
Group permissions: rwx (read, write, execute)
Others: r-x (read, execute)
Directories: 775 (drwxrwxr-x)
Files: 644 (-rw-r--r--)
```

---

## ✅ **Deployment Checklist**

- [ ] Changes tested locally with Apache (not PHP built-in server)
- [ ] `.env` file configured (if needed)
- [ ] `.htaccess` rules verified
- [ ] Clean URLs working locally
- [ ] Backup created before deployment
- [ ] Dry-run rsync completed
- [ ] Actual deployment completed
- [ ] Production URLs tested
- [ ] Error logs checked
- [ ] Rollback plan ready (if needed)

---

## 🔐 **Security Notes**

1. **Never commit .pem file to git** - Already in `.gitignore` ✅
2. **Keep .pem file permissions at 600** - Already set correctly ✅
3. **Don't share .pem file** - Store securely
4. **SSH key authentication only** - No password authentication
5. **Server has sudo access restrictions** - george user may have limited sudo

---

## 📚 **Related Documentation**

- **Production Configuration:** See `PRODUCTION-APACHE-CONFIG.md`
- **Clean URL Changes:** See `CLEAN-URL-CHANGES-REQUIRED.md`
- **Deployment Guide:** See `DEPLOYMENT.md`
- **Local Apache Setup:** See `scripts/setup-local-apache.sh`

---

**Last Updated:** October 7, 2025
**Verified Connection:** ✅ Working
**Server Status:** ✅ Active

