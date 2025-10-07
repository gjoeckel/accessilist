# Single .env Deployment Workflow

**Date:** October 7, 2025
**Status:** ✅ IMPLEMENTED

## Overview

Simplified deployment using a single `.env` file (version controlled) with environment switching. No `.env.example`, no exclusions, ONE source of truth.

---

## Environment Configuration

### Single `.env` File Structure

```bash
# Environment Configuration
# Change APP_ENV to switch environments

APP_ENV=local              # Current environment

# Base paths for each environment
BASE_PATH_LOCAL=
BASE_PATH_APACHE_LOCAL=/training/online/accessilist
BASE_PATH_PRODUCTION=/training/online/accessilist

# API extensions for each environment
API_EXT_LOCAL=.php
API_EXT_APACHE_LOCAL=
API_EXT_PRODUCTION=

# Debug mode for each environment
DEBUG_LOCAL=true
DEBUG_APACHE_LOCAL=true
DEBUG_PRODUCTION=false
```

### Environment Values

| Environment | Usage | Base Path | API Ext | Debug |
|------------|-------|-----------|---------|-------|
| `local` | PHP dev server | ` ` | `.php` | ✅ |
| `apache-local` | Local Apache testing | `/training/online/accessilist` | ` ` | ✅ |
| `production` | AWS production | `/training/online/accessilist` | ` ` | ❌ |

---

## Development Workflow

### Local Development (PHP Dev Server)

```bash
# 1. Ensure APP_ENV=local in .env
grep "^APP_ENV=" .env  # Should show: APP_ENV=local

# 2. Start PHP dev server
php -S localhost:8000 router.php

# 3. Test
open http://localhost:8000/home
```

### Local Apache Production Testing

```bash
# 1. Switch to apache-local
sed -i '' 's/^APP_ENV=.*/APP_ENV=apache-local/' .env

# 2. Start local Apache (if configured)
sudo apachectl start

# 3. Test production paths locally
open http://localhost/training/online/accessilist/home

# 4. Restore to local
sed -i '' 's/^APP_ENV=.*/APP_ENV=apache-local/' .env
```

---

## Deployment Workflow

### Automatic Deployment via GitHub Push

**IMPORTANT:** Deployment ONLY happens through `push to github` process.

#### Process Flow

1. **Developer makes changes** (in `local` environment)
2. **Commits changes** to git
3. **Triggers deployment** using GitHub push gate
4. **Automatic workflow:**
   - Current env saved (e.g., `local`)
   - `.env` set to `APP_ENV=production`
   - Commit: "Deploy: Set environment to production"
   - Push to GitHub
   - Deploy files to AWS via rsync
   - Update `.env` on server to production
   - Verify production site responds
   - Restore local env to original value
   - Commit: "Restore: Set environment to local"
   - Push restoration commit

#### Commands

```bash
# Stage and commit your changes
git add .
git commit -m "Your changes"

# Deploy to production (ONLY method)
git push-secure 'push to github'

# Or manually:
./github-push-gate.sh secure-push 'push to github'
```

#### What Happens

```
📋 Preparing for production deployment...
Current environment: local

🔧 Setting APP_ENV=production...
✅ .env configured for production
✅ Committed: "Deploy: Set environment to production"

🚀 Pushing to GitHub repository...
✅ Push successful

🚀 Deploying to AWS production...
✅ Files synced to ec2-3-20-59-76.us-east-2.compute.amazonaws.com
✅ Production environment configured on server

🔍 Verifying deployment...
✅ Production site is responding

🔧 Restoring local environment to local...
✅ .env restored
✅ Committed: "Restore: Set environment to local"
✅ Pushed restoration

✅ GitHub push and deployment complete!
```

---

## Files Changed

### Created
- `.env` - Single environment configuration (NOW IN GIT)

### Modified
- `.gitignore` - Removed `.env` exclusion, only exclude `.env.local`
- `php/includes/config.php` - Support hyphen-to-underscore conversion
- `github-push-gate.sh` - Integrated deployment workflow

### Deleted
- `.env.example` - No longer needed (single source of truth)
- `scripts/deploy-to-aws.sh` - Replaced by GitHub push gate

---

## Key Benefits

### ✅ Simplicity
- **ONE file** controls environment
- **ONE command** to deploy
- **ONE workflow** to remember

### ✅ Reliability
- Environment explicitly set (no guessing)
- Automatic rollback on failures
- Production verification after deploy

### ✅ Safety
- Can't accidentally deploy wrong environment
- Local environment auto-restored
- GitHub push gate enforces correct token

### ✅ Visibility
- `.env` in git shows current config
- Deployment commits show environment changes
- Easy to audit what's deployed

---

## Validation Results

### ✅ Local Environment
```
Env: local
Path: []
API: [.php]
Debug: true
```

### ✅ Apache-Local Environment
```
Env: apache-local
Path: [/training/online/accessilist]
API: []
Debug: true
```

### ✅ Production Environment
```
URL: https://webaim.org/training/online/accessilist/home
Status: 200 OK (after deployment)
```

---

## Important Notes

1. **NEVER deploy without GitHub push gate**
   - Standalone deploy scripts removed
   - Use: `git push-secure 'push to github'`

2. **No sensitive data in .env**
   - Only path configuration
   - Safe to version control

3. **Environment changes tracked in git**
   - Deploy commits show production switch
   - Restore commits show local switch

4. **Hyphen normalization**
   - `apache-local` → looks up `BASE_PATH_APACHE_LOCAL`
   - Automatic in `php/includes/config.php`

---

## Troubleshooting

### Production returns 500 error
```bash
# Check .env on production server
ssh -i /path/to/key.pem george@ec2-3-20-59-76.us-east-2.compute.amazonaws.com
cat /var/websites/webaim/htdocs/training/online/accessilist/.env
# Should show: APP_ENV=production
```

### Local shows wrong paths
```bash
# Verify local environment
grep "^APP_ENV=" .env
# Should show: APP_ENV=local

# Test config loads correctly
php -r "require 'php/includes/config.php'; echo \$environment . PHP_EOL;"
```

### Push gate blocks deployment
```bash
# Check status
./github-push-gate.sh status

# Verify token exactly matches
./github-push-gate.sh validate 'push to github'
```

---

## Migration Complete

**Previous approach:**
- `.env.example` template
- Excluded `.env` from git
- Manual .env creation on each environment
- Standalone deploy scripts

**New approach:**
- Single `.env` in git
- Automatic environment switching
- Integrated GitHub push deployment
- ONE source of truth

**Result:** Simpler, more reliable, fully automated! ✅

