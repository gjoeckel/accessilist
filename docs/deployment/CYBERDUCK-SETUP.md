# Cyberduck Setup Complete! 🎉

**Date:** 2025-10-20
**Application:** Cyberduck 9.2.4
**Status:** ✅ Installed and Configured

---

## ✅ What I've Done

1. ✅ Installed Cyberduck via Homebrew
2. ✅ Verified SSH key exists: `~/.ssh/GeorgeWebAIMServerKey.pem`
3. ✅ Created bookmark file: `AccessiList-Production.duck`
4. ✅ Launched Cyberduck and imported bookmark

---

## 🚀 Next Steps (In Cyberduck)

### Step 1: Accept the Bookmark Import
You should see a dialog asking to import the bookmark. Click **"Add"** or **"Allow"**.

### Step 2: Connect to Server
1. Look for the bookmark: **"AccessiList Production Server"** in the Bookmarks window
2. **Double-click** the bookmark to connect
3. You'll see a security warning about an unknown fingerprint
4. Click **"Allow"** (this is normal for first connection)

### Step 3: You're In!
After connecting, you should see the production AccessiList directory:
```
/var/websites/webaim/htdocs/training/online/accessilist/
├── php/
├── js/
├── css/
├── json/
├── images/
├── sessions/
├── index.php
└── .htaccess
```

---

## 📖 How to Use Cyberduck

### Opening the Bookmark
- **From Bookmarks**: `Cmd + B` to show bookmarks, then double-click
- **Quick Connect**: If bookmarks window closes, just launch Cyberduck and it should auto-connect

### Browsing Files
- **Navigate**: Double-click folders to open
- **Go Up**: Click the up arrow ⬆️ in toolbar
- **Refresh**: `Cmd + R`
- **Search**: `Cmd + F`

### Viewing Files
- **Quick Look**: Select file, press `Space` (like Finder)
- **Edit**: Right-click → "Edit With" → Choose your editor (Cursor, VS Code, TextEdit)
- **Download**: Drag file to Desktop/Finder

### Going to Specific Path
1. `Cmd + G` (Go to folder)
2. Type path, e.g., `/var/websites/webaim/htdocs/training/online/etc`
3. Press Enter

---

## 🔍 Common Tasks

### 1. View Production .env File
```
Path: /var/websites/webaim/htdocs/training/online/etc/.env
```
1. Press `Cmd + G`
2. Type: `/var/websites/webaim/htdocs/training/online/etc`
3. Find `.env` file
4. Press `Space` to Quick Look

### 2. Check Deployed Files
Navigate to:
```
/var/websites/webaim/htdocs/training/online/accessilist/
```
Verify these exist:
- ✅ `index.php`
- ✅ `.htaccess`
- ✅ `php/` directory (18 files)
- ✅ `js/` directory (19 files)
- ✅ `css/` directory (16 files)
- ✅ `sessions/` directory

### 3. Compare Local vs Production
**Local:** `/Users/a00288946/Projects/accessilist/`
**Production:** `/var/websites/webaim/htdocs/training/online/accessilist/`

1. Open two Cyberduck windows:
   - Window 1: Production server
   - Window 2: Local files (`File → Open → Local Disk`)
2. Compare file timestamps and sizes

### 4. Download Production File for Inspection
1. Right-click file
2. Choose "Download To..."
3. Select download location
4. File is copied locally (production unchanged)

---

## 🔒 Safety Tips

### Read-Only Browsing (Recommended)
1. **Just browse** - don't upload/edit yet
2. Use **Quick Look** (`Space`) to view files
3. **Download** files to inspect locally

### Before Making Changes
1. ✅ Always test changes locally first
2. ✅ Use deployment scripts (`proj-push-deploy-github`)
3. ✅ Never upload `config.json` or `.env` from local machine
4. ✅ Make backups before editing production files

### Emergency Edit on Production
If you MUST edit a file directly on production:
1. Right-click file → "Download"
2. Save backup locally
3. Edit on server: Right-click → "Edit With" → Your editor
4. Save changes
5. Test immediately in browser

---

## ⚙️ Cyberduck Preferences

### Recommended Settings
1. **Cyberduck → Preferences** (`Cmd + ,`)

2. **General Tab:**
   - ✅ "Use Keychain" (saves SSH key passphrase)
   - ✅ "Confirm disconnect" (prevents accidental disconnects)

3. **Transfers Tab:**
   - ✅ "Open multiple connections" (faster transfers)
   - Set "Transfers" dropdown to "Use browser connection"

4. **Editor Tab:**
   - Set default editor to your preferred editor:
     - Cursor: `/Applications/Cursor.app`
     - VS Code: `/Applications/Visual Studio Code.app`
     - TextEdit: `/System/Applications/TextEdit.app`

5. **Browser Tab:**
   - ✅ "Show hidden files" (to see .htaccess, .env)

---

## 🛠️ Troubleshooting

### Connection Fails
```bash
# Test SSH connection manually
ssh -i ~/.ssh/GeorgeWebAIMServerKey.pem george@ec2-3-20-59-76.us-east-2.compute.amazonaws.com

# If this works, Cyberduck should work too
```

### "Permission Denied" Error
- Check SSH key permissions:
  ```bash
  ls -l ~/.ssh/GeorgeWebAIMServerKey.pem
  # Should show: -r-------- (read-only for owner)
  ```

### Can't See Hidden Files
1. Cyberduck → Preferences → Browser
2. Check ✅ "Show hidden files"
3. Refresh (`Cmd + R`)

### Bookmark Not Showing
1. `Cmd + B` to show bookmarks
2. If empty, re-import: `File → Open` → Select `AccessiList-Production.duck`

---

## 📂 Important Paths

### Production Files
```
/var/websites/webaim/htdocs/training/online/accessilist/
```

### Production .env (External Config)
```
/var/websites/webaim/htdocs/training/online/etc/.env
```

### Apache Config
```
/var/websites/webaim/htdocs/training/online/accessilist/.htaccess
```

### Session Data
```
/var/websites/webaim/htdocs/training/online/accessilist/sessions/
```

---

## 🎯 Quick Reference

| Action | Shortcut |
|--------|----------|
| Show Bookmarks | `Cmd + B` |
| Connect to Bookmark | `Cmd + B`, then double-click |
| Go to Path | `Cmd + G` |
| Refresh Directory | `Cmd + R` |
| Quick Look File | `Space` |
| Search Files | `Cmd + F` |
| Download File | Drag to Desktop |
| Edit File | Right-click → Edit With |
| New Browser Window | `Cmd + N` |
| Preferences | `Cmd + ,` |
| Disconnect | `Cmd + W` |

---

## 📊 Verify Deployment

After next deployment, check these in Cyberduck:

### Files Should Exist (89 total)
- [ ] `index.php` (root entry point)
- [ ] `.htaccess` (Apache routing)
- [ ] `config/checklist-types.json`
- [ ] `php/` directory (18 files)
- [ ] `js/` directory (19 files)
- [ ] `css/` directory (16 files)
- [ ] `images/` directory (15 SVG files)
- [ ] `json/` directory (11 files)
- [ ] `sessions/` directory
- [ ] `sessions/.htaccess`

### Files Should NOT Exist
- [ ] ❌ `config.json` (contains credentials!)
- [ ] ❌ `node_modules/`
- [ ] ❌ `tests/`
- [ ] ❌ `scripts/`
- [ ] ❌ `.git/`
- [ ] ❌ Any `.md` files

---

## 🔗 Related Documentation

- **DEVELOPER/CORE2.md** - Production file manifest (89 items)
- **scripts/deployment/README-DEPLOYMENT-METHODS.md** - Deployment methods
- **IMPLEMENTATION-DEPLOYMENT-EXCLUSIONS.md** - What gets deployed

---

## 💡 Pro Tips

1. **Bookmark Multiple Paths**:
   - Create separate bookmarks for:
     - AccessiList root
     - .env config directory
     - Apache logs

2. **Use Multiple Windows**:
   - `Cmd + N` for new window
   - Compare local vs production side-by-side

3. **Quick Access**:
   - Pin Cyberduck to Dock for easy access
   - Add to Finder sidebar: Right-click bookmark → "Make Alias"

4. **Sync Check**:
   - After deployment, compare file timestamps
   - Should match your local deployment time

---

## 🎉 You're All Set!

**Cyberduck is installed and configured!**

**To connect:**
1. Launch Cyberduck (if not already open)
2. Press `Cmd + B` for bookmarks
3. Double-click "AccessiList Production Server"
4. Click "Allow" on security prompt
5. Browse your production files!

---

**Questions?** The bookmark configuration is in:
`/Users/a00288946/Projects/accessilist/AccessiList-Production.duck`

**To reconnect later:** Just launch Cyberduck and it should auto-connect to your last session.

**Happy browsing! 🚀**
