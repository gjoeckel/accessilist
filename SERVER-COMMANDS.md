# Server Commands Quick Reference

**Easy commands for local development and testing**

> 💡 **Both servers can run simultaneously!** PHP on port 8000, Apache on port 80 - no conflicts.

---

## 🚀 **Quick Start Commands**

### **Best Option: Both Servers** (Recommended)
```bash
# Using npm
npm run local-apache-start

# Or direct script
./scripts/local-apache-start.sh
```

**What it does:**
- ✅ Starts PHP server on port 8000 (quick dev)
- ✅ Starts Apache on port 80 (production testing)
- ✅ Tests both servers automatically
- ✅ Verifies clean URLs work
- ⚠️ Requires sudo for Apache

**Use when:**
- Complete development setup
- Need both quick testing and production validation
- Want to compare behavior side-by-side

---

### **For Manual Developer Testing** (PHP Built-in Server Only)
```bash
# Using npm
npm run local-start

# Or direct script
./scripts/local-start.sh
```

**What it does:**
- ✅ Checks port 8000 availability
- ✅ Starts PHP server on http://localhost:8000
- ✅ Can run alongside Apache (different ports)
- ⚠️ **Note:** .htaccess rules won't work (no mod_rewrite)

**Use when:**
- Quick development testing
- JavaScript/CSS changes
- PHP logic testing (non-URL dependent)

---

### **For AI Automated Testing** (Apache Production Simulation)
```bash
# Using npm
npm run apache-start

# Or direct script
./scripts/apache-start.sh
```

**What it does:**
- ✅ Checks for existing servers (info only)
- ✅ Restarts Apache if needed
- ✅ Verifies Apache configuration
- ✅ Starts Apache on http://localhost/
- ✅ Tests mod_rewrite and PHP modules
- ✅ Tests clean URLs (/home, /admin)
- ✅ Can run alongside PHP server (different ports)

**Use when:**
- Testing .htaccess rewrite rules
- Validating clean URLs work
- Production environment simulation
- Pre-deployment verification

---

## 🌐 **Deployment Commands**

### **Deploy to AWS Production**
```bash
# Using npm
npm run deploy:aws

# Or direct script
./scripts/deploy-to-aws.sh
```

**What it does:**
- ✅ Shows preview of changes (dry-run)
- ✅ Asks for confirmation
- ✅ Deploys to ec2-3-20-59-76.us-east-2.compute.amazonaws.com
- ✅ Tests production URLs
- ✅ Shows verification commands

---

## 📊 **Server Comparison**

| Feature | `local-start` (PHP) | `apache-start` (Apache) | **Can Run Together?** |
|---------|-------------------|----------------------|---------------------|
| **Port** | 8000 | 80 | ✅ Yes (different) |
| **URL** | http://localhost:8000 | http://localhost | ✅ Unique URLs |
| **mod_rewrite** | ❌ No | ✅ Yes | ✅ No conflict |
| **.htaccess** | ❌ Ignored | ✅ Processed | ✅ No conflict |
| **Clean URLs** | ❌ Won't work | ✅ Works | ✅ Test on Apache |
| **PHP** | ✅ Built-in | ✅ mod_php/FPM | ✅ Separate processes |
| **Use For** | Quick dev | Production testing | ✅ Both simultaneously |
| **Requires** | PHP only | Apache + PHP | - |
| **Sudo** | ❌ No | ✅ Yes (for Apache) | - |

---

## 🎯 **Running Both Servers Simultaneously**

### **Setup:**
```bash
# Terminal 1: Start PHP server (foreground)
npm run local-start
# Server running at http://localhost:8000

# Terminal 2: Start Apache (background)
npm run apache-start
# Server running at http://localhost
```

### **Testing Both:**
```bash
# Terminal 3: Test commands
# PHP server (no .htaccess processing):
curl http://localhost:8000/php/home.php    # ✅ Works
curl http://localhost:8000/home            # ❌ 404

# Apache server (with .htaccess processing):
curl http://localhost/php/home.php         # ✅ Works
curl http://localhost/home                 # ✅ Works (clean URL!)
```

### **Benefits:**
- ⚡ **Speed:** Quick refresh on :8000, production testing on :80
- 🔄 **Compare:** See .htaccess behavior difference instantly
- 🧪 **Flexible:** Switch URLs without restarting servers
- 💻 **Efficient:** Edit once, test in both environments

---

## 🔧 **Setup Requirements**

### **For `local-start` (PHP Server)**
**Already configured** - works out of the box ✅

### **For `apache-start` (Apache)**
**First-time setup required:**
```bash
./scripts/setup-local-apache.sh
```

This configures:
- ✅ Enables mod_rewrite
- ✅ Enables PHP module
- ✅ Sets AllowOverride All
- ✅ Creates VirtualHost
- ✅ Sets permissions

---

## 📋 **When to Use Which Server**

### **Use `local-start` when:**
- ✅ Testing PHP logic
- ✅ Developing JavaScript/CSS
- ✅ Making quick changes
- ✅ Not testing URL routing
- ✅ Want fastest startup

### **Use `apache-start` when:**
- ✅ Testing .htaccess rules
- ✅ Validating clean URLs (/home, /admin)
- ✅ Pre-deployment testing
- ✅ Simulating production
- ✅ AI automated testing
- ✅ Need exact production match

### **Run both simultaneously when:**
- ✅ Quick dev testing + production validation
- ✅ Compare behavior side-by-side
- ✅ Switch between environments without restart
- 🌐 Access via: http://localhost:8000 (PHP) & http://localhost (Apache)

---

## 🛑 **Stop Commands**

### **Stop PHP Dev Server**
```bash
# If running in foreground terminal:
Ctrl+C

# If running in background:
ps aux | grep "php -S" | grep -v grep | awk '{print $2}' | xargs kill

# Stop specific port only:
lsof -ti:8000 | xargs kill
```

### **Stop Apache**
```bash
sudo apachectl stop

# Apache runs as daemon, so Ctrl+C won't stop it
# Must use apachectl command
```

### **Stop Both**
```bash
# Stop PHP
lsof -ti:8000 | xargs kill 2>/dev/null || true

# Stop Apache
sudo apachectl stop

# Verify both stopped
lsof -ti:8000,80 || echo "All servers stopped"
```

### **Check What's Running**
```bash
# Check PHP servers
ps aux | grep "php -S" | grep -v grep

# Check Apache
sudo apachectl status

# Check port 8000
lsof -ti:8000

# Check port 80
lsof -ti:80
```

---

## 🧪 **Testing Clean URLs**

### **After `local-start` (PHP Server)**
```bash
# These will work:
curl -I http://localhost:8000/
curl -I http://localhost:8000/php/home.php
curl -I http://localhost:8000/php/admin.php

# These will 404 (no .htaccess):
curl -I http://localhost:8000/home     # ❌ 404
curl -I http://localhost:8000/admin    # ❌ 404
```

### **After `apache-start` (Apache)**
```bash
# ALL of these should work:
curl -I http://localhost/
curl -I http://localhost/home          # ✅ Clean URL
curl -I http://localhost/admin         # ✅ Clean URL
curl -I http://localhost/php/home.php  # ✅ Direct access
```

---

## 📝 **Additional Commands**

### **View Apache Logs**
```bash
# Error log
tail -f /var/log/apache2/accessilist_error.log

# Or general error log
tail -f /var/log/apache2/error_log

# Access log
tail -f /var/log/apache2/accessilist_access.log
```

### **Apache Management**
```bash
# Restart Apache
sudo apachectl restart

# Test configuration
sudo apachectl configtest

# Check modules
apachectl -M | grep rewrite
apachectl -M | grep php
```

### **Check Server Environment**
```bash
# Check .env file
cat .env

# Check which environment
php -r 'require "php/includes/config.php"; echo "Env: " . $environment . "\n"; echo "Base: " . $basePath . "\n";'
```

---

## 🔄 **Typical Workflow**

### **Development Workflow (Run Both Simultaneously)**
```bash
# Terminal 1: Start PHP server for quick dev
npm run local-start
# Leaves running at http://localhost:8000

# Terminal 2: Start Apache for production testing
npm run apache-start
# Runs at http://localhost

# Now you have both:
# - Quick dev: http://localhost:8000 (no .htaccess)
# - Production: http://localhost (with .htaccess)

# Make changes, test on both, then deploy
npm run deploy:aws
```

### **AI Agent Workflow**
```bash
# 1. Make code changes
# 2. Start Apache for production simulation
npm run apache-start

# 3. Run automated tests
curl -I http://localhost/home
curl -I http://localhost/admin

# 4. Deploy if tests pass
npm run deploy:aws
```

### **Quick Switch Workflow (One at a Time)**
```bash
# Option 1: Just PHP (fastest)
npm run local-start
# Ctrl+C to stop

# Option 2: Just Apache (production-like)
npm run apache-start
sudo apachectl stop  # when done
```

---

## 📚 **Related Documentation**

- **AWS Connection:** `AWS-SERVER-CONNECTION.md`
- **Apache Config:** `PRODUCTION-APACHE-CONFIG.md`
- **Setup Guide:** `scripts/setup-local-apache.sh`
- **Deployment:** `scripts/deploy-to-aws.sh`

---

## ⚡ **Quick Command Reference**

| Command | Purpose | Server Type | Sudo? |
|---------|---------|-------------|-------|
| `npm run local-apache-start` | **Start both servers** | Both | ✅ Yes |
| `npm run local-start` | Start PHP dev server | PHP (port 8000) | ❌ No |
| `npm run apache-start` | Start Apache production sim | Apache (port 80) | ✅ Yes |
| `npm run deploy:aws` | Deploy to AWS production | N/A (rsync) | ❌ No |
| `sudo apachectl stop` | Stop Apache | Apache | ✅ Yes |
| `Ctrl+C` | Stop PHP server | PHP | ❌ No |
| `./scripts/setup-local-apache.sh` | Initial Apache setup | Apache | ✅ Yes |

---

**Created:** October 7, 2025
**Quick Access:** Run `npm run` to see all available commands

