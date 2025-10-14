# Apache Setup - Quick Guide

**Two options: Manual one-time setup OR enhanced passwordless sudo**

---

## 🎯 **Quick Solution: Manual Setup (Recommended for One-Time)**

Since Apache setup is **ONE-TIME ONLY**, the easiest approach is:

### **Run this in Terminal.app (outside Cursor):**

```bash
cd /Users/a00288946/Desktop/accessilist
./scripts/setup-local-apache.sh
```

**You'll be prompted for password a few times for:**
- Backing up httpd.conf
- Enabling PHP module
- Enabling mod_rewrite
- Creating VirtualHost
- Setting AllowOverride
- Starting Apache

**After this completes ONCE:**
- ✅ Apache is configured forever
- ✅ AI can start/stop Apache autonomously (you already set this up)
- ✅ Never need to run setup again

---

## ⚡ **Alternative: Enhanced Passwordless Sudo**

If you want AI to run setup autonomously too, expand passwordless sudo:

### **Commands needed for full autonomy:**
```bash
# Edit sudoers (run in Terminal.app):
sudo visudo -f /etc/sudoers.d/apache-a00288946
```

**Add these lines:**
```bash
# Enhanced Apache setup - allows all Apache-related commands
a00288946 ALL=(ALL) NOPASSWD: /usr/sbin/apachectl
a00288946 ALL=(ALL) NOPASSWD: /usr/bin/tee /etc/apache2/other/accessilist.conf
a00288946 ALL=(ALL) NOPASSWD: /usr/bin/sed -i * /etc/apache2/httpd.conf
a00288946 ALL=(ALL) NOPASSWD: /bin/cp /etc/apache2/httpd.conf /etc/apache2/httpd.conf.backup
```

**But this is more complex and only needed once, so:**

---

## 💡 **My Recommendation**

**Just run the setup manually this ONE time:**

```bash
# In Terminal.app:
cd /Users/a00288946/Desktop/accessilist
./scripts/setup-local-apache.sh
# Enter password when prompted (a few times)
```

**Takes:** ~2 minutes
**Frequency:** Once per machine
**After this:** AI can do everything else autonomously

---

## ✅ **What to Tell Me After Setup**

Just say: **"apache setup complete"**

Then I'll:
1. ✅ Start both servers (no password needed)
2. ✅ Test clean URLs
3. ✅ Validate .htaccess rules
4. ✅ Report complete results

---

**Ready to run `./scripts/setup-local-apache.sh` in Terminal.app?**

