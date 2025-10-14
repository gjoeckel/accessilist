# AccessiList Production Issues Analysis & Resolution Guide

## Executive Summary

The AccessiList application has been successfully deployed to production at `https://webaim.org/training/online/accessilist/` but has critical functionality issues that prevent proper operation. While file deployment was successful, server-side configuration and asset path issues are causing save functionality to fail and visual elements to be missing.

## Issues Identified

### 🚨 CRITICAL: Save Functionality Completely Broken

**Status**: ✅ Resolved (local); pending prod validation  
**Impact**: Users cannot save checklist progress  
**Priority**: P0 (Critical)

#### Symptoms
- Save button click shows "Saving checklist..." but fails
- Console shows: `[ERROR] Error saving changes`
- Save error: `Save error: JSHandle@error`

#### Technical Analysis
```
Network Request Chain:
1. POST /php/api/save.php → 302 Redirect
2. GET /php/api/save → 400 Bad Request
```

#### Root Cause Analysis
- **Server Configuration Issue**: Apache was redirecting `.php` extensions; extensionless routes weren’t internally mapped to `.php`
- **API Endpoint Mismatch**: `/php/api/save` didn’t route to `save.php` consistently
- **HTTP Method Preservation**: Redirects risked method changes; need internal rewrites

#### Fix Implemented
- Added root `.htaccess` with internal rewrites:
  - `php/api/{name}` → `php/api/{name}.php` (no external redirect; preserves method)
  - `php/{name}` → `php/{name}.php`
  - Disabled `MultiViews` to avoid content negotiation conflicts
- Updated `js/path-utils.js` `getAPIPath()` to append `.php` only for local dev when extensionless is used
- Updated `js/StateManager.js` to call `getAPIPath('save')` and `getAPIPath('restore')`

#### Local Validation
```
./tests/start_server.sh
curl -I http://localhost:8000/php/api/health      # 200
curl -I http://localhost:8000/php/api/health.php  # 200
curl -I 'http://localhost:8000/php/api/restore?sessionKey=ABC' # 404/200 depending on data
```

### 🖼️ HIGH: Add Row Button Images Missing

**Status**: ✅ Resolved  
**Impact**: Poor user experience, missing visual cues  
**Priority**: P1 (High)

#### Symptoms
- Add row buttons have no visual icons
- Console shows 404 errors for image assets
- Buttons are functional but visually incomplete

#### Technical Analysis
```
Failed Image Requests:
- /images/add-1.svg → 404 Not Found
- /images/add-2.svg → 404 Not Found  
- /images/add-3.svg → 404 Not Found
- /images/add-4.svg → 404 Not Found

Expected Paths:
- /training/online/accessilist/images/add-1.svg
```

#### Root Cause Analysis
- `js/buildPrinciples.js` hardcoded `/images/...` for add icons, bypassing `getImagePath()`

#### Fix Implemented
- Updated `js/buildPrinciples.js` to use `window.getImagePath(iconName)` for add-row icons
- Verified other image references already use `getImagePath()`

### 🔄 MEDIUM: Restore API Similar Issues

**Status**: ✅ Resolved (local); pending prod validation  
**Impact**: Session restoration may not work  
**Priority**: P2 (Medium)

#### Symptoms
- Similar 302 redirect pattern as save API
- Restore endpoint shows 404 error
- Session restoration may be affected

#### Technical Analysis
```
Network Request Chain:
1. GET /php/api/restore.php?sessionKey=MEO → 302 Redirect
2. GET /php/api/restore?sessionKey=MEO → 404 Not Found
```

#### Root Cause Analysis
- **Same Server Configuration Issue**: Apache redirect configuration affects all API endpoints
- **Consistent Pattern**: All `.php` API endpoints are being redirected incorrectly
- **Endpoint Availability**: Redirected endpoints are not properly configured

#### Fix Implemented
- Same `.htaccess` rewrite + extensionless `getAPIPath()` handling as save
- Adjusted calls to `getAPIPath('restore')`

## Working Components ✅

### Successfully Deployed Elements
1. **File Transfer**: All files deployed correctly via rsync
2. **CSS Assets**: `global.css` loading properly
3. **Main JavaScript**: Core JS files loading with correct paths
4. **Home Page**: Fully functional navigation and interface
5. **Asset Path Fixes**: PHP files using correct `$basePath` for CSS/JS
6. **Directory Structure**: Proper file organization maintained
7. **Permissions**: File permissions set correctly

### Evidence of Success
```javascript
// Successful asset loading
https://webaim.org/training/online/accessilist/global.css GET [success - 200]
https://webaim.org/training/online/accessilist/js/path-utils.js GET [success - 200]
```

## Diagnostic Commands for AI Agent

### 1. Server Configuration Investigation
```bash
# Check Apache configuration
grep -r "RewriteRule\|RewriteEngine" /path/to/deployment/
cat /path/to/deployment/.htaccess
apache2ctl -S

# Check PHP configuration
php -m | grep rewrite
php --ini
```

### 2. API Endpoint Testing
```bash
# Test all API endpoints
for endpoint in save restore list health delete; do
  echo "Testing $endpoint.php:"
  curl -I "https://webaim.org/training/online/accessilist/php/api/${endpoint}.php"
  echo "Testing $endpoint (redirected):"
  curl -I "https://webaim.org/training/online/accessilist/php/api/${endpoint}"
  echo "---"
done
```

### 3. File System Verification
```bash
# Check API files exist and are accessible
ls -la /path/to/deployment/php/api/
find /path/to/deployment/php/api/ -name "*.php" -exec php -l {} \;

# Check image files
ls -la /path/to/deployment/images/add-*.svg
```

### 4. JavaScript Asset Path Analysis
```bash
# Search for hardcoded image paths
grep -r "add-[0-9]\.svg" /path/to/deployment/js/
grep -r "images/" /path/to/deployment/js/
grep -r "\$basePath" /path/to/deployment/php/
```

## Resolution Strategies

### Strategy 1: Fix Server Configuration (Recommended)
**Approach**: Configure Apache to properly handle API endpoints
**Steps**:
1. Modify `.htaccess` to internally map extensionless routes to `.php` and disable `MultiViews`
2. Preserve HTTP methods by using internal rewrites (no 301/302)
3. Test all API endpoints after changes

### Strategy 2: Fix JavaScript Asset Paths
**Approach**: Update JavaScript to use correct base path for images
**Steps**:
1. Locate hardcoded image paths in JavaScript
2. Update to use dynamic base path
3. Test image loading

### Strategy 3: Alternative API Structure
**Approach**: Restructure API calls to use extensionless endpoints consistently
**Steps**:
1. Update JavaScript to call endpoints without `.php` extension
2. Ensure server handles both formats
3. Test save/restore functionality

## Testing Protocol

### Pre-Fix Testing
1. Document current error states
2. Capture network request patterns
3. Record console error messages
4. Test all user workflows

### Post-Fix Validation
1. **Save Functionality Test**
   - Create new checklist session
   - Add notes to tasks
   - Change task statuses
   - Click save button
   - Verify success message
   - Refresh page and verify data persistence

2. **Image Loading Test**
   - Verify all add row buttons show icons
   - Check console for 404 errors
   - Test button functionality

3. **API Endpoint Test**
   - Test all API endpoints directly
   - Verify proper HTTP methods
   - Check response codes and content

4. **Full User Workflow Test**
   - Create checklist
   - Complete tasks
   - Save progress
   - Navigate between sections
   - Verify all functionality works end-to-end

## Monitoring and Alerting

### Key Metrics to Monitor
1. **API Success Rates**: Track save/restore API success rates
2. **Asset Loading**: Monitor 404 errors for images/CSS/JS
3. **User Session Completion**: Track successful save operations
4. **Error Rates**: Monitor console errors and network failures

### Alert Conditions
- Save API failure rate > 5%
- Image asset 404 errors
- Console error spikes
- User-reported save issues

## Next Steps for AI Agent

### Immediate Actions (Next 1-2 hours)
1. Deploy `.htaccess` to production root and confirm `MultiViews` is disabled
2. Test extensionless endpoints (`/php/api/save`, `/php/api/restore`, `/php/api/list`)
3. Verify method preservation on `POST /php/api/save`
4. Validate add-row icons load under `/training/online/accessilist/images/*`

### Short-term Actions (Next 24 hours)
1. Roll out changes via CI and validate save/restore on production
2. Monitor logs for residual 302/400 chains
3. Capture before/after HAR for one save/restore flow

### Long-term Actions (Next week)
1. Implement monitoring for API endpoints and asset loading
2. Add automated testing for save/restore functionality
3. Document deployment procedures for future reference
4. Create rollback procedures for quick issue resolution

## File Locations Reference

### Production Deployment Path
```
/training/online/accessilist/
├── php/
│   ├── api/
│   │   ├── save.php
│   │   ├── restore.php
│   │   ├── list.php
│   │   └── health.php
│   ├── home.php
│   └── mychecklist.php
├── js/
│   ├── addRow.js
│   ├── StateManager.js
│   └── path-utils.js
├── images/
│   ├── add-1.svg
│   ├── add-2.svg
│   ├── add-3.svg
│   └── add-4.svg
└── global.css
```

### Key Files to Examine
- `/php/api/save.php` - Save functionality endpoint
- `/js/addRow.js` - Add row button image paths
- `/.htaccess` - Apache URL rewriting configuration
- `/php/mychecklist.php` - Main application entry point

---

**Last Updated**: 2025-10-01 23:10 UTC  
**Status**: Fixes implemented locally; pending production validation  
**Next Review**: After deploying `.htaccess` and retesting on production
