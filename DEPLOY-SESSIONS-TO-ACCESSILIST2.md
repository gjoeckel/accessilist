# Deploy Sessions Migration to accessilist2 Testing
**Date:** October 21, 2025
**Branch:** security-updates
**Purpose:** Test sessions migration on production server before going live

---

## 📋 Pre-Deployment Checklist

### ✅ **Server Infrastructure Ready**
- [x] `etc/sessions/` directory exists
- [x] Permissions: 775 (george:www-data)
- [x] Contains 4 session files (1A8, 4Z8, 7MP, PRD)
- [x] No .htaccess (correct - outside web root)

### ✅ **Code Changes Complete**
- [x] 13 files updated on security-updates branch
- [x] All files use `global $sessionsPath`
- [x] 100/101 local tests passing (99%)
- [x] Committed to security-updates branch

### ⏹️ **Configuration Needed**
- [ ] Add `SESSIONS_PATH` to `.env.accessilist2`
- [ ] Verify etc/sessions accessible by Apache

---

## 🚀 Deployment Steps

### **Step 1: Update .env.accessilist2**
```bash
ssh -i ~/.ssh/GeorgeWebAIMServerKey.pem george@ec2-3-20-59-76.us-east-2.compute.amazonaws.com

# Edit .env.accessilist2
nano /var/websites/webaim/htdocs/training/online/etc/.env.accessilist2

# Add this line:
SESSIONS_PATH=/var/websites/webaim/htdocs/training/online/etc/sessions
```

**Expected .env.accessilist2:**
```bash
APP_ENV=production
BASE_PATH_PRODUCTION=/training/online/accessilist2
API_EXT_PRODUCTION=
DEBUG_PRODUCTION=false
SESSIONS_PATH=/var/websites/webaim/htdocs/training/online/etc/sessions
```

---

### **Step 2: Deploy Code to accessilist2**
```bash
# On local machine
./scripts/deployment/upload-to-test-directory.sh
```

**Or manually:**
```bash
rsync -avz --delete \
  -e "ssh -i ~/.ssh/GeorgeWebAIMServerKey.pem" \
  --exclude='.git' --exclude='node_modules' --exclude='tests' \
  ./ george@ec2-3-20-59-76.us-east-2.compute.amazonaws.com:/var/websites/webaim/htdocs/training/online/accessilist2/
```

---

### **Step 3: Test on accessilist2**

#### **3a: Test Pages Load**
- [ ] Home: https://webaim.org/training/online/accessilist2/home
- [ ] Systemwide Report: https://webaim.org/training/online/accessilist2/systemwide-report
- [ ] Existing session (1A8): https://webaim.org/training/online/accessilist2/?=1A8

#### **3b: Test API Endpoints**
```bash
# Create new session
curl -X POST https://webaim.org/training/online/accessilist2/php/api/instantiate \
  -H "Content-Type: application/json" \
  -H "X-CSRF-Token: [GET FROM PAGE]" \
  -d '{"sessionKey":"TST","typeSlug":"word"}'

# List sessions
curl https://webaim.org/training/online/accessilist2/php/api/list

# Restore session
curl https://webaim.org/training/online/accessilist2/php/api/restore?sessionKey=1A8
```

#### **3c: Verify File Locations**
```bash
ssh -i ~/.ssh/GeorgeWebAIMServerKey.pem george@ec2-3-20-59-76.us-east-2.compute.amazonaws.com

# Check that new sessions are created in etc/sessions
ls -la /var/websites/webaim/htdocs/training/online/etc/sessions/
# Should show TST.json or any new sessions created

# Check old location is not being used
ls -la /var/websites/webaim/htdocs/training/online/accessilist2/sessions/
# Should be empty or not exist
```

---

## ✅ Validation Checklist

### Functionality Tests
- [ ] Can load existing sessions (1A8, 4Z8, 7MP, PRD)
- [ ] Can create new sessions (instantiate API)
- [ ] Can save session data (save API)
- [ ] Can restore session data (restore API)
- [ ] Can list all sessions (list API)
- [ ] Can delete sessions (delete API)
- [ ] Systemwide report shows all sessions
- [ ] List report loads for specific session

### Security Tests
- [ ] CSRF protection working (POST/DELETE blocked without token)
- [ ] Rate limiting active (429 after threshold)
- [ ] Security headers present
- [ ] Sessions NOT accessible via HTTP (try direct URL)

### Verification Commands
```bash
# Try to access session file via HTTP (should fail - 404 or 403)
curl -I https://webaim.org/training/online/accessilist2/sessions/1A8.json
# Expected: 404 Not Found (or 403 if directory listing blocked)

# Try via etc path (should fail - outside web root)
curl -I https://webaim.org/training/online/etc/sessions/1A8.json
# Expected: 404 Not Found (path not in web root)
```

---

## 🐛 Troubleshooting

### Issue: "Sessions directory not found"
```bash
# Check SESSIONS_PATH in .env
grep SESSIONS_PATH /var/websites/webaim/htdocs/training/online/etc/.env.accessilist2

# Verify directory exists
ls -la /var/websites/webaim/htdocs/training/online/etc/sessions/

# Check permissions
stat /var/websites/webaim/htdocs/training/online/etc/sessions/
```

### Issue: "Permission denied" when creating sessions
```bash
# Fix permissions
chmod 775 /var/websites/webaim/htdocs/training/online/etc/sessions
chown george:www-data /var/websites/webaim/htdocs/training/online/etc/sessions
```

### Issue: Can't find existing sessions
```bash
# Verify files are in etc/sessions
ls -la /var/websites/webaim/htdocs/training/online/etc/sessions/*.json

# Check config.php is loading correctly
curl https://webaim.org/training/online/accessilist2/php/api/health
# Should return: {"status":"ok",...}
```

---

## 📊 Expected Results

### **If Successful:**
- ✅ All pages load correctly
- ✅ All API endpoints functional
- ✅ Sessions created in `/var/.../etc/sessions/`
- ✅ Sessions NOT in `/var/.../accessilist2/sessions/`
- ✅ Security tests pass
- ✅ No errors in Apache logs

### **Success Metrics:**
- All functionality working: ✅
- Sessions in correct location: ✅
- No HTTP access to sessions: ✅
- Ready for live deployment: ✅

---

## 🎯 Next Steps After Validation

If accessilist2 testing is successful:

1. **Update main .env for production**
   ```bash
   echo "SESSIONS_PATH=/var/websites/webaim/htdocs/training/online/etc/sessions" >> \
     /var/websites/webaim/htdocs/training/online/etc/.env
   ```

2. **Merge to main**
   ```bash
   git checkout main
   git merge security-updates
   ```

3. **Deploy to production**
   ```bash
   ./scripts/run-workflow.sh proj-push-deploy-github
   ```

4. **Cleanup old sessions directory**
   ```bash
   # After confirming production works
   rm -rf /var/websites/webaim/htdocs/training/online/accessilist/sessions/
   ```

---

## 🔐 Security Verification

After deployment, verify enhanced security:

```bash
# 1. Try to access session via HTTP (should fail)
curl -I https://webaim.org/training/online/accessilist2/sessions/1A8.json
# Expected: 404

# 2. Try to access via etc path (should fail)
curl -I https://webaim.org/training/online/etc/sessions/1A8.json
# Expected: 404

# 3. Try directory listing (should fail)
curl -I https://webaim.org/training/online/accessilist2/sessions/
# Expected: 404 or 403

# 4. Verify application works
curl -s https://webaim.org/training/online/accessilist2/php/api/list | jq .
# Expected: {"success":true,"data":[...sessions...]}
```

---

**Ready to deploy to accessilist2!** 🚀
