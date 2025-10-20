# Production Deployment Methods

**Reference:** `DEVELOPER/CORE2.md` - Production Deployment Manifest
**Last Updated:** 2025-10-20

---

## 📋 Overview

This project implements **two complementary methods** for ensuring only production-required files are deployed to the server:

1. **Method 1:** `.deployignore` - Exclusion list (what NOT to upload)
2. **Method 2:** `upload-production-files.sh` - Explicit include list (what TO upload)

**Recommended Approach:** Use **Method 2** for actual deployments (safest), with Method 1 as backup protection.

---

## 🎯 Method 1: `.deployignore` (Exclusion List)

### Purpose
Defines patterns for files/directories to **EXCLUDE** from deployment.

### Location
```
/Users/a00288946/Projects/accessilist/.deployignore
```

### File Format
```bash
# Development tools
node_modules/
package.json
router.php
docker-compose.yml

# Testing
tests/
logs/

# Documentation
*.md
docs/
DEVELOPER/
```

### Usage with rsync
```bash
# Deploy with exclusions
rsync -avz \
  --exclude-from='.deployignore' \
  -e "ssh -i ~/.ssh/key.pem" \
  ./ user@server:/path/
```

### Advantages
✅ Simple pattern matching
✅ Works with standard rsync
✅ Easy to maintain
✅ Good for testing deployments

### Disadvantages
⚠️ Risk of including unintended files
⚠️ Pattern matching can be tricky
⚠️ Doesn't guarantee minimal deployment

---

## 🎯 Method 2: Explicit Include List (RECOMMENDED)

### Purpose
Uploads **ONLY** the 89 required production files - nothing more, nothing less.

### Location
```
/Users/a00288946/Projects/accessilist/scripts/deployment/upload-production-files.sh
```

### How It Works
1. Maintains explicit list of all 89 production files
2. Verifies each file exists locally before upload
3. Uses rsync with `--files-from` to upload only listed files
4. Provides detailed deployment summary

### File Categories (89 Total)
```
Root:         2 files  (index.php, .htaccess)
Config:       1 file   (checklist-types.json)
PHP Backend: 18 files  (pages, APIs, includes)
JavaScript:  19 files  (ES6 modules)
CSS:         16 files  (stylesheets)
Images:      15 files  (SVG icons)
JSON:        11 files  (checklist definitions)
Sessions:     2 items  (directory + .htaccess)
```

### Usage
```bash
# Basic usage (uses environment defaults)
./scripts/deployment/upload-production-files.sh

# With custom configuration
DEPLOY_USER=george \
DEPLOY_HOST=ec2-3-20-59-76.us-east-2.compute.amazonaws.com \
DEPLOY_PATH=/var/websites/webaim/htdocs/training/online/accessilist/ \
./scripts/deployment/upload-production-files.sh
```

### Configuration Variables
```bash
DEPLOY_USER    # SSH username (default: george)
DEPLOY_HOST    # Server hostname (default: ec2-3-20-59-76.us-east-2.compute.amazonaws.com)
DEPLOY_PATH    # Target directory on server
SSH_KEY        # Path to SSH private key (default: ~/.ssh/GeorgeWebAIMServerKey.pem)
```

### Advantages
✅ **Safest method** - only uploads exactly what's needed
✅ No risk of uploading dev files or secrets
✅ Pre-flight checks verify all files exist
✅ Detailed logging and progress reporting
✅ Acts as executable documentation
✅ Easy to audit (all 89 files listed in script)

### Disadvantages
⚠️ Requires manual updates when files are added/removed
⚠️ Slightly more verbose than exclusion patterns

---

## 🚀 Workflow Integration

### Using Cursor Workflows

#### Option 1: Full Deployment (Recommended)
```bash
# Use the workflow name
proj-push-deploy-github
```

**What it does:**
1. Verifies `.deployignore` and `upload-production-files.sh` exist
2. Uploads 89 production files using Method 2
3. Pushes to GitHub
4. Runs post-deployment verification

#### Option 2: Upload Only (No GitHub Push)
```bash
# Direct script execution
./scripts/deployment/upload-production-files.sh
```

---

## 📊 Production File Manifest (89 Files)

### Breakdown by Category

| Category | Count | Examples |
|----------|-------|----------|
| Root | 2 | `index.php`, `.htaccess` |
| Config | 1 | `config/checklist-types.json` |
| PHP Pages | 6 | `php/home.php`, `php/list.php` |
| PHP APIs | 8 | `php/api/save.php`, `php/api/restore.php` |
| PHP Includes | 9 | `php/includes/config.php`, `php/includes/api-utils.php` |
| JavaScript | 19 | `js/main.js`, `js/StateManager.js` |
| CSS | 16 | `css/base.css`, `css/list.css` |
| Images | 15 | `images/active-1.svg`, `images/done.svg` |
| JSON | 11 | `json/demo.json`, `json/word.json` |
| Sessions | 2 | `sessions/` directory, `sessions/.htaccess` |

### Complete List
See `DEVELOPER/CORE2.md` for the complete annotated list of all 89 files with descriptions.

---

## 🚫 Files EXCLUDED from Production

### Development Tools
- `node_modules/` - NPM dependencies (Puppeteer, Playwright)
- `package.json`, `package-lock.json` - NPM configuration
- `router.php` - PHP built-in server routing (dev only)
- `docker-compose.yml`, `Dockerfile` - Docker testing environment
- `config.json` - Contains SSH credentials (NEVER upload)

### Testing & Scripts
- `tests/` - Complete test suite (76 automated tests)
- `scripts/` - 99 shell scripts for deployment, testing, automation
- `logs/` - Test execution logs

### Documentation
- All `.md` files (README, DEVELOPER/, docs/, etc.)
- `archive/` - Historical files and planning docs
- `IMPLEMENTATION-STATUS.md` - Development tracking

### Configuration
- `.env` - Local environment configuration (use external .env on server)
- `.git/` - Git repository data
- `.cursor/` - Cursor IDE configuration

---

## 🔒 Security Considerations

### Files That Must NEVER Be Uploaded

1. **`config.json`** - Contains SSH private key path and credentials
2. **`.env`** (local copy) - May contain sensitive configuration
3. **`.git/`** - Contains entire repository history
4. **`node_modules/`** - May contain vulnerable dependencies
5. **`tests/`** - May expose application internals
6. **`scripts/`** - May contain deployment credentials

### External Configuration Required

**Production `.env` location:**
```
/var/websites/webaim/htdocs/training/online/etc/.env
```

**NOT** in the deployment directory - stored securely outside web root.

---

## 🧪 Testing Deployment

### Pre-Deployment Checks
```bash
# Run comprehensive pre-deployment validation
./scripts/deployment/pre-deploy-check.sh
```

**Validates:**
- All 76 production mirror tests pass
- Required files exist
- No syntax errors
- Deployment configuration valid

### Post-Deployment Verification
```bash
# Test production server after deployment
./scripts/deployment/post-deploy-verify.sh
```

**Tests:**
- Application loads correctly
- API endpoints respond
- Clean URLs work
- Session save/restore works
- All checklist types accessible

---

## 📖 Complete Documentation

- **`DEVELOPER/CORE2.md`** - Complete production file manifest with descriptions
- **`DEVELOPER/DEPLOYMENT.md`** - Full deployment procedures
- **`DEVELOPER/ROLLBACK_PLAN.md`** - Emergency rollback procedures
- **`DEVELOPER/SSH-SETUP.md`** - SSH configuration for deployment

---

## 🔄 Maintaining the Deployment Files

### When Adding New Production Files

1. **Add to explicit list** in `upload-production-files.sh`:
   ```bash
   # In the file list section
   path/to/new-file.php
   ```

2. **Update CORE2.md** with file description

3. **Test deployment locally:**
   ```bash
   # Verify file is in list
   grep "new-file.php" scripts/deployment/upload-production-files.sh

   # Test deployment
   ./scripts/deployment/upload-production-files.sh
   ```

### When Adding New Development Files

1. **Add to `.deployignore`** if it matches a pattern
2. **No changes needed** to explicit list (it won't be uploaded)

---

## ✅ Deployment Checklist

Before running deployment:
- [ ] All tests passing locally (76/76)
- [ ] `.deployignore` file exists and is up-to-date
- [ ] `upload-production-files.sh` has all 89 files listed
- [ ] SSH key accessible at `~/.ssh/GeorgeWebAIMServerKey.pem`
- [ ] Pre-deployment checks pass
- [ ] Changes committed to Git
- [ ] Changelog updated

After deployment:
- [ ] Production `.env` file exists at external location
- [ ] `sessions/` directory writable by Apache
- [ ] Test production URL: https://webaim.org/training/online/accessilist/home
- [ ] Post-deployment verification passes
- [ ] All checklist types load correctly

---

**Version:** 1.0.0
**Last Updated:** 2025-10-20
**Maintained By:** AccessiList Development Team
