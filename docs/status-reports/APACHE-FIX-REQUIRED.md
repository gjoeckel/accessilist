# 🔧 Apache Symlink Fix Required

**Issue:** Apache symlink points to old location
**Status:** ⚠️ **MANUAL FIX NEEDED** (requires sudo password)

---

## 🎯 **Problem Diagnosed**

### **Apache Status:**
- ✅ Apache IS running (3 httpd processes detected)
- ✅ Port 80 available
- ✅ Configuration valid (Syntax OK)
- ❌ **Symlink pointing to wrong directory**

### **The Issue:**

```bash
Current symlink:
/Library/WebServer/Documents/accessilist → /Users/a00288946/Desktop/accessilist ❌

Should be:
/Library/WebServer/Documents/accessilist → /Users/a00288946/Projects/accessilist ✅
```

**Result:** Apache returns 503 because it can't find project files at the old `/Desktop/` location.

---

## ✅ **Quick Fix (1 Command)**

**Run this command:**
```bash
sudo bash scripts/fix-apache-symlink.sh
```

**What it does:**
1. Removes old symlink
2. Creates new symlink → `/Projects/accessilist`
3. Verifies project files accessible
4. Restarts Apache
5. Tests endpoint
6. Reports success/failure

**Time:** ~10 seconds

**Expected output:**
```
✅ Old symlink removed
✅ New symlink created
✅ Project files accessible
✅ Apache restarted
✅ APACHE SYMLINK FIX COMPLETE!

You can now run: proj-test-mirror
```

---

## 🔧 **Manual Fix (Alternative)**

If you prefer to do it manually:

```bash
# 1. Remove old symlink
sudo rm /Library/WebServer/Documents/accessilist

# 2. Create new symlink
sudo ln -sf /Users/a00288946/Projects/accessilist /Library/WebServer/Documents/accessilist

# 3. Verify
ls -la /Library/WebServer/Documents/accessilist

# 4. Restart Apache
sudo apachectl restart

# 5. Test
curl -I http://localhost/training/online/accessilist/home
```

---

## 🧪 **Verification After Fix**

```bash
# Test Apache endpoint
curl http://localhost/training/online/accessilist/home

# Expected: HTML page content (not 503 error)

# Run full test suite
proj-test-mirror

# Expected: Much higher success rate (70%+ tests passing)
```

---

## 📊 **Current Test Results**

**Before Fix:**
- ✅ Static assets: 4/4 passing (CSS, JS, images, JSON)
- ❌ PHP pages: 0/X passing (all 503 errors)
- ❌ API endpoints: 0/X passing (all 503 errors)
- **Success rate:** 31.6% (24/76 tests)

**After Fix (Expected):**
- ✅ Static assets: 4/4 passing
- ✅ PHP pages: ~15/15 passing (200/302 responses)
- ✅ API endpoints: ~10/10 passing
- **Success rate:** ~85-95% (65-72/76 tests)

---

## 🎯 **Root Cause**

When we updated all paths from `/Desktop/accessilist` to `/Projects/accessilist`, we **updated the project files** but **forgot to update the Apache symlink**.

**Files updated:** ✅ 30+ scripts and config files
**Apache symlink:** ❌ Still pointing to `/Desktop/`

---

## ⚡ **Quick Action Required**

**Run this ONE command:**
```bash
sudo bash scripts/fix-apache-symlink.sh
```

**Then test:**
```bash
proj-test-mirror
```

**Expected:** 🎉 Much better test results!

---

## 📋 **Troubleshooting**

### **If symlink fix doesn't resolve 503:**

1. **Check Apache error log:**
```bash
sudo tail -50 /private/var/log/apache2/error_log
```

2. **Check Apache configuration:**
```bash
cat /etc/apache2/other/accessilist.conf
```

3. **Verify PHP module loaded:**
```bash
apachectl -M | grep php
```

4. **Check file permissions:**
```bash
ls -la /Users/a00288946/Projects/accessilist/index.php
```

---

**Ready to fix! Run the script and Apache testing will work!** ✅
