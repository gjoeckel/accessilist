# Apache 403 Forbidden - Quick Fix

**Issue:** macOS security prevents Apache from accessing Desktop folder
**Solution:** Create symlink from accessible location

---

## 🔧 **Quick Fix (2 commands)**

**Run these in Terminal.app:**

```bash
# 1. Create symlink from Apache-accessible location
sudo ln -sf /Users/a00288946/Desktop/accessilist /Library/WebServer/Documents/accessilist

# 2. Update VirtualHost DocumentRoot
sudo sed -i '' 's|DocumentRoot "/Users/a00288946/Desktop/accessilist"|DocumentRoot "/Library/WebServer/Documents/accessilist"|' /etc/apache2/other/accessilist.conf

# 3. Restart Apache
sudo apachectl restart
```

**Then test:**
```bash
curl -I http://localhost/
# Should now work!
```

---

## 🎯 **Alternative: Full Disk Access for Apache**

**If you prefer not to use symlink:**

1. **System Settings** → **Privacy & Security** → **Full Disk Access**
2. Click **+** button
3. Add: `/usr/sbin/httpd`
4. Restart Apache: `sudo apachectl restart`

---

## 🚀 **After Fix:**

Tell me: **"403 fixed"**

Then I'll:
- ✅ Test all clean URLs
- ✅ Validate .htaccess rules
- ✅ Report complete results

---

**Run the 3 commands above in Terminal.app**

