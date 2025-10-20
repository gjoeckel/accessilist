# Deploy to accessilist2 (Test Directory)

**Purpose:** Test deployment in production environment without affecting live site
**Test Directory:** `/var/websites/webaim/htdocs/training/online/accessilist2/`
**Test URL:** `https://webaim.org/training/online/accessilist2/home`

---

## 🎯 Why Use accessilist2?

✅ Test on real production server
✅ Same Apache configuration
✅ Same PHP environment
✅ Test with real URLs and routing
✅ No risk to live site

---

## 📋 Setup Steps

### **Step 1: Deploy Code to accessilist2**

```bash
# Deploy all 89 production files to test directory
./scripts/deployment/upload-to-test-directory.sh
```

### **Step 2: Create Test Environment File**

SSH to server and create test `.env`:

```bash
# SSH to server
ssh -i ~/.ssh/GeorgeWebAIMServerKey.pem george@ec2-3-20-59-76.us-east-2.compute.amazonaws.com

# Create test .env file
cat > /var/websites/webaim/htdocs/training/online/etc/.env.accessilist2 << 'EOF'
APP_ENV=production

# Test directory paths (accessilist2)
BASE_PATH_PRODUCTION=/training/online/accessilist2
API_EXT_PRODUCTION=
DEBUG_PRODUCTION=false

# Local development paths (for reference)
BASE_PATH_LOCAL=
API_EXT_LOCAL=.php
DEBUG_LOCAL=true

# Apache-local testing paths (for reference)
BASE_PATH_APACHE_LOCAL=/training/online/accessilist
API_EXT_APACHE_LOCAL=
DEBUG_APACHE_LOCAL=true
EOF
```

### **Step 3: Update config.php to Check Test .env**

Edit `config.php` on server to check for test `.env`:

```bash
# Navigate to accessilist2
cd /var/websites/webaim/htdocs/training/online/accessilist2/php/includes

# Edit config.php (add BEFORE the existing .env checks)
```

Add this code around line 53 (before the global env check):

```php
// Test directory .env (accessilist2 only)
$testEnvPath = '/var/websites/webaim/htdocs/training/online/etc/.env.accessilist2';
if (file_exists($testEnvPath)) {
    $envLoaded = loadEnv($testEnvPath);
}

// If not loaded, try other locations...
if (!$envLoaded) {
    // Try global config first (preferred for local development)
    if (file_exists($globalEnvPath)) {
        $envLoaded = loadEnv($globalEnvPath);
    }
    // ... rest of existing code
}
```

**OR** for simpler approach, just check if the directory name contains "accessilist2":

```php
// Auto-detect test directory
$currentPath = __DIR__;
if (strpos($currentPath, 'accessilist2') !== false) {
    $testEnvPath = '/var/websites/webaim/htdocs/training/online/etc/.env.accessilist2';
    if (file_exists($testEnvPath)) {
        $envLoaded = loadEnv($testEnvPath);
    }
}
```

### **Step 4: Create sessions Directory**

```bash
# Still on server
cd /var/websites/webaim/htdocs/training/online/accessilist2
mkdir -p sessions
chmod 755 sessions
```

### **Step 5: Verify Permissions**

```bash
# Check file ownership
ls -la /var/websites/webaim/htdocs/training/online/accessilist2/

# Should be owned by apache or your user
# sessions/ must be writable by Apache
```

---

## 🧪 Testing

### **Test URL Structure:**

```
Home Page:
https://webaim.org/training/online/accessilist2/home

API Health Check:
https://webaim.org/training/online/accessilist2/php/api/health

Systemwide Report:
https://webaim.org/training/online/accessilist2/systemwide-report

Create Test Checklist:
https://webaim.org/training/online/accessilist2/home
(Click any checklist button - should work with ?=ABC format)
```

### **Expected Behavior:**

1. ✅ Home page loads
2. ✅ Can create new checklist
3. ✅ Save/restore works (tests sessions/ directory)
4. ✅ All assets load (CSS, JS, JSON)
5. ✅ Clean URLs work
6. ✅ API endpoints respond

---

## 🔍 Troubleshooting

### **Issue: 404 Errors**

**Cause:** Apache not configured for accessilist2
**Solution:** Check if `.htaccess` was deployed and has correct permissions

```bash
# On server
cd /var/websites/webaim/htdocs/training/online/accessilist2
ls -la .htaccess
# Should show the file exists

# Check Apache can read it
cat .htaccess | head -20
```

### **Issue: "Configuration Error: .env file not found"**

**Cause:** `.env.accessilist2` not found or config.php not checking it
**Solution:**
1. Verify `.env.accessilist2` exists
2. Check config.php is looking for it
3. Or temporarily copy from accessilist:

```bash
cp /var/websites/webaim/htdocs/training/online/etc/.env \
   /var/websites/webaim/htdocs/training/online/etc/.env.accessilist2

# Edit the BASE_PATH
sed -i 's|/accessilist|/accessilist2|g' \
  /var/websites/webaim/htdocs/training/online/etc/.env.accessilist2
```

### **Issue: Assets Not Loading**

**Cause:** BASE_PATH not set correctly
**Solution:** Check browser console for 404s, verify BASE_PATH in .env

### **Issue: "Permission Denied" on Save**

**Cause:** sessions/ not writable
**Solution:**
```bash
chmod 755 /var/websites/webaim/htdocs/training/online/accessilist2/sessions
```

---

## ✅ Verification Checklist

After deployment, verify these work:

- [ ] Home page loads: `/training/online/accessilist2/home`
- [ ] Can click checklist button (e.g., "Demo")
- [ ] Checklist page loads with `?=ABC` format
- [ ] Can fill out checklist items
- [ ] Save button works (check sessions/ directory)
- [ ] Refresh page - data persists
- [ ] Report page loads
- [ ] Systemwide report loads
- [ ] API health check responds: `/php/api/health`

---

## 📊 Compare Test vs Live

| Aspect | accessilist (Live) | accessilist2 (Test) |
|--------|-------------------|---------------------|
| **URL** | `/training/online/accessilist` | `/training/online/accessilist2` |
| **ENV File** | `.env` | `.env.accessilist2` |
| **BASE_PATH** | `/training/online/accessilist` | `/training/online/accessilist2` |
| **Sessions** | `accessilist/sessions/` | `accessilist2/sessions/` |
| **Purpose** | Production | Testing |

---

## 🚀 After Testing Successfully

### **Option 1: Deploy to Live (Recommended)**

```bash
# Deploy to actual production
./scripts/deployment/upload-production-files.sh
```

### **Option 2: Promote accessilist2 to Live**

```bash
# On server - backup current, then replace
cd /var/websites/webaim/htdocs/training/online
mv accessilist accessilist.backup
mv accessilist2 accessilist

# Update .env back to accessilist paths
mv /var/websites/webaim/htdocs/training/online/etc/.env.accessilist2 \
   /var/websites/webaim/htdocs/training/online/etc/.env

# Edit .env to use /training/online/accessilist (not accessilist2)
```

---

## 🧹 Cleanup After Testing

```bash
# Keep accessilist2 for future testing, OR remove it:
ssh -i ~/.ssh/GeorgeWebAIMServerKey.pem george@ec2-3-20-59-76.us-east-2.compute.amazonaws.com

# Remove test directory
rm -rf /var/websites/webaim/htdocs/training/online/accessilist2

# Remove test .env
rm /var/websites/webaim/htdocs/training/online/etc/.env.accessilist2
```

---

## 💡 Pro Tips

1. **Keep accessilist2 as permanent test environment:**
   - Always test new features there first
   - Keep test `.env` configured
   - Create test sessions separately

2. **Use Cyberduck to compare:**
   - Browse both directories side-by-side
   - Compare file timestamps
   - Verify all files deployed

3. **Test with real checklists:**
   - Create a checklist
   - Fill it out
   - Save it
   - Refresh browser
   - Verify data persists

---

**Quick Deploy to Test:**
```bash
./scripts/deployment/upload-to-test-directory.sh
```

**Test URL:**
```
https://webaim.org/training/online/accessilist2/home
```
