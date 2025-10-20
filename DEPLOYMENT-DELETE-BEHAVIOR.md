# Deployment Delete Behavior

**Question:** When deploying to production, are old files automatically deleted?
**Answer:** **NO - by default, old files remain on the server**

---

## 🔍 Current Behavior

### **What Happens Now:**

**Deployment command:**
```bash
rsync -avz \
    --files-from="file-list.txt" \
    ./ server:/path/
```

**Behavior:**
- ✅ Uploads 90 whitelisted files
- ✅ Overwrites existing files
- ❌ **Does NOT delete** old files on server

---

## ⚠️ Example Scenario

### **Server Before Deployment:**
```
/var/websites/webaim/htdocs/training/online/accessilist/
├── index.php                    ✅ Will be updated
├── old-admin.php                ❌ Will REMAIN
├── config.json                  ❌ Will REMAIN (security risk!)
├── test-script.sh               ❌ Will REMAIN
├── debug/                       ❌ Will REMAIN
│   └── test-data.json
├── php/
│   ├── home.php                 ✅ Will be updated
│   └── legacy-page.php          ❌ Will REMAIN
└── sessions/
    └── old-session.json         ✅ SAFE (in .gitignore, rsync preserves)
```

### **Server After Deployment:**
```
/var/websites/webaim/htdocs/training/online/accessilist/
├── index.php                    ✅ Updated
├── old-admin.php                ❌ STILL THERE
├── config.json                  ❌ STILL THERE (SECURITY RISK!)
├── test-script.sh               ❌ STILL THERE
├── debug/                       ❌ STILL THERE
│   └── test-data.json
├── php/
│   ├── home.php                 ✅ Updated
│   └── legacy-page.php          ❌ STILL THERE
└── sessions/
    └── old-session.json         ✅ SAFE (preserved)
```

---

## 🚨 Security Implications

**Files that might exist on server but shouldn't:**
- ❌ `config.json` - Contains SSH credentials!
- ❌ `tests/` - Exposes application internals
- ❌ `scripts/` - Deployment automation
- ❌ `.git/` - Repository history
- ❌ Old PHP files - Could have vulnerabilities
- ❌ Debug files - Exposes system information

---

## ✅ Solution Options

### **Option 1: Add `--delete` Flag (Clean but Risky)**

**Pros:**
- ✅ Deletes all files not in the whitelist
- ✅ Clean server (only required files)
- ✅ Removes old/forgotten files

**Cons:**
- ⚠️ **DANGEROUS** - Will delete EVERYTHING not whitelisted
- ⚠️ Will delete `sessions/` data (user sessions lost!)
- ⚠️ No undo - permanent deletion
- ⚠️ One mistake = data loss

**Command:**
```bash
rsync -avz \
    --delete \                    # DELETE FILES NOT IN LIST!
    --files-from="file-list.txt" \
    ./ server:/path/
```

---

### **Option 2: Protected Delete (Recommended)**

**Protect important directories from deletion:**

```bash
rsync -avz \
    --delete \
    --exclude='sessions/*' \       # Keep user session data
    --exclude='.env' \             # Keep production config
    --files-from="file-list.txt" \
    ./ server:/path/
```

**What this does:**
- ✅ Deletes old files NOT in whitelist
- ✅ **Protects** `sessions/` directory (user data safe)
- ✅ **Protects** `.env` file (config safe)
- ✅ Clean deployment

---

### **Option 3: Manual Cleanup (Safest)**

**Before first deployment with --delete:**

```bash
# SSH to server
ssh george@ec2-3-20-59-76.us-east-2.compute.amazonaws.com

# Navigate to production
cd /var/websites/webaim/htdocs/training/online/accessilist

# Manual cleanup - review and delete old files
ls -la
# Manually remove:
rm config.json        # If it exists
rm -rf tests/         # If it exists
rm -rf scripts/       # If it exists
rm -rf old-files/     # Any old directories

# Then deploy normally (no --delete needed)
```

---

### **Option 4: Dry Run First (Test Before Deleting)**

**Test what WOULD be deleted:**

```bash
rsync -avz \
    --delete \
    --dry-run \                    # PREVIEW ONLY - NO CHANGES
    --exclude='sessions/*' \
    --files-from="file-list.txt" \
    ./ server:/path/
```

**Review the output, then run for real without `--dry-run`**

---

## 🎯 My Recommendation

### **Step 1: Check What's Currently on Server**

Use Cyberduck to browse:
```
/var/websites/webaim/htdocs/training/online/accessilist/
```

**Look for:**
- Old PHP files
- Test directories
- Config files
- Scripts
- Debug files

### **Step 2: If Clean - Deploy As-Is**

If server only has production files already:
- ✅ No changes needed
- ✅ Current deployment is safe
- ✅ Just deploys/updates whitelisted files

### **Step 3: If Dirty - Use Protected Delete**

If server has old/extra files:
- ✅ Update deployment script to use `--delete`
- ✅ Protect `sessions/` directory
- ✅ Do dry-run first to preview deletions
- ✅ Then deploy for real

---

## 💡 Recommended Implementation

**Update `upload-production-files.sh` around line 267:**

**Current:**
```bash
rsync -avz \
    --files-from="$CLEAN_FILE_LIST" \
    -e "ssh -i $SSH_KEY -o StrictHostKeyChecking=no" \
    --progress \
    --itemize-changes \
    ./ "${DEPLOY_TARGET}:${DEPLOY_PATH}"
```

**Recommended (with protected delete):**
```bash
rsync -avz \
    --delete \
    --exclude='sessions/*.json' \
    --files-from="$CLEAN_FILE_LIST" \
    -e "ssh -i $SSH_KEY -o StrictHostKeyChecking=no" \
    --progress \
    --itemize-changes \
    ./ "${DEPLOY_TARGET}:${DEPLOY_PATH}"
```

---

## 🧪 Test With accessilist2 First

**Safe testing approach:**

1. **Test on accessilist2 with --delete:**
   ```bash
   # Modify upload-to-test-directory.sh to add --delete
   # Deploy to accessilist2
   # Verify nothing important was deleted
   ```

2. **If successful, use same approach for live**

---

## 🚨 Important Warnings

### **DO NOT use --delete without:**
1. ❌ Testing on accessilist2 first
2. ❌ Protecting sessions/ directory
3. ❌ Running dry-run first
4. ❌ Having a backup plan

### **WILL DELETE if not protected:**
- User session data in `sessions/*.json`
- Any `.env` files
- Uploaded files by users
- Any data not in git

---

## 🤔 Your Next Decision

**Choose:**

**A. Keep Current Behavior (Safe, Manual Cleanup)**
- No --delete flag
- Old files remain (you clean manually when needed)
- Safest option

**B. Add Protected Delete (Recommended)**
- Add --delete with exclusions
- Test on accessilist2 first
- Clean deployment

**C. Do Nothing Different**
- Server is probably clean already
- First deployment will just upload files
- Can add --delete later if needed

---

**My recommendation:** Check server first with Cyberduck, then decide!

Would you like me to:
1. Show you how to check what's on the server with Cyberduck?
2. Implement the protected --delete option?
3. Leave as-is for now?
