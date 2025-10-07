# Complete URL Creation Process Analysis
## Local vs Production Server URL Generation

> **⚠️ UPDATE:** This document describes the legacy auto-detection system. The project has been migrated to use `.env` file configuration for a Simple, Reliable, DRY (SRD) approach.
> 
> **New Method:** See [SRD-ENVIRONMENT-PROPOSAL.md](SRD-ENVIRONMENT-PROPOSAL.md) and [MIGRATION-CHECKLIST.md](MIGRATION-CHECKLIST.md)
> 
> **Key Changes:**
> - ✅ Single `.env` file controls all environment settings
> - ✅ No more auto-detection (hostname/port checks)
> - ✅ Explicit `APP_ENV` configuration (local, production, staging)
> - ✅ API extension configurable per environment
> - ✅ Backwards compatible with fallback to auto-detection

---

## A. CREATING URLs ON LOCAL SERVER

### 1. **PHP Server-Side Configuration** (`php/includes/config.php`)

```php
<?php
// Determine if running on local development environment
$isLocal = $_SERVER['HTTP_HOST'] === 'localhost' ||
           $_SERVER['HTTP_HOST'] === '127.0.0.1' ||
           strpos($_SERVER['HTTP_HOST'], 'local') !== false;

// Set base path for all assets (CSS, JS, images, PHP files)
// Local: '' (root)
// Production: '/training/online/accessilist'
$basePath = $isLocal ? '' : '/training/online/accessilist';
```

**Local Detection Logic:**
- Checks if hostname is `localhost` or `127.0.0.1`
- Checks if hostname contains the word "local"
- **Local Result:** `$basePath = ''` (empty string, no prefix)
- **Usage:** Used in ALL PHP templates via `<?php echo $basePath; ?>`

---

### 2. **JavaScript Client-Side Configuration** (`js/path-utils.js`)

```javascript
function getBasePath() {
    try {
        if (window.pathConfig && typeof window.pathConfig.basePath === 'string') {
            return window.pathConfig.basePath;
        }
    } catch (e) {}

    // Detect local environment
    const isLocal = window.location.hostname === 'localhost' ||
                   window.location.hostname === '127.0.0.1' ||
                   window.location.hostname.includes('local') ||
                   window.location.port === '8000';

    return isLocal ? '' : '/training/online/accessilist';
}
```

**Local Detection Logic:**
- Checks hostname for `localhost`, `127.0.0.1`, or contains "local"
- **NEW:** Also checks if port is `8000` (common PHP dev server)
- **Local Result:** Returns `''` (empty string)

**Path Helper Functions (Local Examples):**
```javascript
// Images
window.getImagePath('add-1.svg')
// Local: '/images/add-1.svg'
// Production: '/training/online/accessilist/images/add-1.svg'

// JSON files
window.getJSONPath('word.json')
// Local: '/json/word.json'
// Production: '/training/online/accessilist/json/word.json'

// PHP pages
window.getPHPPath('mychecklist.php')
// Local: '/php/mychecklist.php'
// Production: '/training/online/accessilist/php/mychecklist.php'

// API endpoints
window.getAPIPath('save')
// Local: '/php/api/save.php' (adds .php extension)
// Production: '/training/online/accessilist/php/api/save'

// CSS files
window.getCSSPath('status.css')
// Local: '/status.css'
// Production: '/training/online/accessilist/status.css'
```

---

### 3. **Navigation URL Creation (Local)**

#### A. **Home Page Checklist Buttons** (`php/home.php`)
```javascript
// Checklist button click
const sessionId = generateAlphanumericSessionId(); // e.g., "ABC"

// Step 1: Call instantiate API
fetch('<?php echo $basePath; ?>/php/api/instantiate.php', {
  method: 'POST',
  body: JSON.stringify({
    sessionKey: sessionId,
    typeSlug: checklistType
  })
});

// Step 2: Redirect to minimal URL
window.location.href = `/?=${sessionId}`;
// Local Result: http://localhost:8000/?=ABC
```

#### B. **Admin Button** (`php/home.php`)
```javascript
window.location.href = '<?php echo $basePath; ?>/admin';
// Local Result: http://localhost:8000/admin
// (handled by .htaccess rewrite rule)
```

#### C. **Admin Page Instance Links** (`php/admin.php`)
```javascript
function createInstanceLink(instanceId, typeSlug) {
    const link = document.createElement('a');
    link.href = `/?=${instanceId}`;
    // Local Result: http://localhost:8000/?=ABC
    link.target = '_blank';
    return link;
}
```

---

### 4. **API URL Creation (Local)**

#### A. **Save/Restore Operations** (`js/StateManager.js`)
```javascript
// Save operation
const apiPath = window.getAPIPath ?
    window.getAPIPath('save') :
    '/php/api/save.php';
// Local Result: '/php/api/save.php'

fetch(apiPath, {
  method: 'POST',
  body: JSON.stringify(stateData)
});
```

#### B. **Instantiate API** (`js/StateManager.js`)
```javascript
const apiPath = window.getAPIPath ?
    window.getAPIPath('instantiate') :
    '/php/api/instantiate.php';
// Local Result: '/php/api/instantiate.php'
```

---

### 5. **URL Routing (Local)** (`.htaccess`)

```apache
Options -MultiViews
RewriteEngine On
RewriteBase /

# Allow direct access to existing files
RewriteCond %{REQUEST_FILENAME} -f [OR]
RewriteCond %{REQUEST_FILENAME} -d
RewriteRule ^ - [L]

# Admin routing
RewriteRule ^admin/?$ php/admin.php [L]

# API: extensionless to .php
RewriteRule ^php/api/([^/.]+)$ php/api/$1.php [L]

# General PHP: extensionless to .php
RewriteRule ^php/([^/.]+)$ php/$1.php [L]
```

**Local URL Mappings:**
- `/admin` → `php/admin.php`
- `/php/api/save` → `php/api/save.php`
- `/php/api/restore` → `php/api/restore.php`
- `/php/mychecklist` → `php/mychecklist.php`

---

### 6. **Minimal URL Routing (Local)** (`index.php`)

```php
<?php
// Handle minimal URL parameter format: ?=EDF
$requestUri = $_SERVER['REQUEST_URI'] ?? '';

// Check for minimal URL format: ?=ABC (3-character session key)
if (preg_match('/\?=([A-Z0-9]{3})$/', $requestUri, $matches)) {
    $sessionKey = $matches[1];

    // Get the checklist type from session file
    $checklistType = getChecklistTypeFromSession($sessionKey, '');

    if ($checklistType === null || $checklistType === '') {
        // Show 404 error page
        http_response_code(404);
        echo '<!DOCTYPE html>...Checklist Not Found...';
        exit;
    }

    // Include checklist page directly (keeps URL clean)
    $_GET['session'] = $sessionKey;
    $_GET['type'] = $checklistType;
    include 'php/mychecklist.php';
    exit;
}

// Default: redirect to home
header('Location: php/home.php');
```

**Local Minimal URL Flow:**
1. User visits: `http://localhost:8000/?=ABC`
2. `index.php` captures `ABC` session key
3. Looks up type from session file
4. Includes `mychecklist.php` with `$_GET` params
5. **URL stays**: `http://localhost:8000/?=ABC` (no redirect)

---

## B. CREATING URLs ON PRODUCTION SERVER

### 1. **PHP Server-Side Configuration** (`php/includes/config.php`)

```php
<?php
// Determine if running on production
$isLocal = $_SERVER['HTTP_HOST'] === 'localhost' ||
           $_SERVER['HTTP_HOST'] === '127.0.0.1' ||
           strpos($_SERVER['HTTP_HOST'], 'local') !== false;

// Set base path for production
$basePath = $isLocal ? '' : '/training/online/accessilist';
```

**Production Detection Logic:**
- Hostname: `webaim.org` (does NOT match local conditions)
- **Production Result:** `$basePath = '/training/online/accessilist'`
- **Usage:** All PHP templates prepend this path

---

### 2. **JavaScript Client-Side Configuration** (`js/path-utils.js`)

```javascript
function getBasePath() {
    // Detect production environment
    const isLocal = window.location.hostname === 'localhost' ||
                   window.location.hostname === '127.0.0.1' ||
                   window.location.hostname.includes('local') ||
                   window.location.port === '8000';

    return isLocal ? '' : '/training/online/accessilist';
}
```

**Production Detection Logic:**
- Hostname: `webaim.org` (NOT localhost, NOT local)
- Port: NOT `8000`
- **Production Result:** Returns `/training/online/accessilist`

**Path Helper Functions (Production Examples):**
```javascript
// Images
window.getImagePath('add-1.svg')
// Production: '/training/online/accessilist/images/add-1.svg'

// JSON files
window.getJSONPath('word.json')
// Production: '/training/online/accessilist/json/word.json'

// PHP pages
window.getPHPPath('mychecklist.php')
// Production: '/training/online/accessilist/php/mychecklist.php'

// API endpoints
window.getAPIPath('save')
// Production: '/training/online/accessilist/php/api/save'
// (NO .php extension for production)

// CSS files
window.getCSSPath('status.css')
// Production: '/training/online/accessilist/status.css'
```

---

### 3. **Navigation URL Creation (Production)**

#### A. **Home Page Checklist Buttons** (`php/home.php`)
```javascript
// Checklist button click
const sessionId = generateAlphanumericSessionId(); // e.g., "XYZ"

// Step 1: Call instantiate API
fetch('<?php echo $basePath; ?>/php/api/instantiate.php', {
  method: 'POST',
  body: JSON.stringify({
    sessionKey: sessionId,
    typeSlug: checklistType
  })
});
// Production URL: https://webaim.org/training/online/accessilist/php/api/instantiate.php

// Step 2: Redirect to minimal URL
window.location.href = `/?=${sessionId}`;
// Production Result: https://webaim.org/training/online/accessilist/?=XYZ
```

#### B. **Admin Button** (`php/home.php`)
```javascript
window.location.href = '<?php echo $basePath; ?>/admin';
// Production Result: https://webaim.org/training/online/accessilist/admin
// (handled by .htaccess rewrite rule)
```

#### C. **Admin Page Instance Links** (`php/admin.php`)
```javascript
function createInstanceLink(instanceId, typeSlug) {
    const link = document.createElement('a');
    link.href = `/?=${instanceId}`;
    // Production Result: https://webaim.org/training/online/accessilist/?=XYZ
    link.target = '_blank';
    return link;
}
```

---

### 4. **API URL Creation (Production)**

#### A. **Save/Restore Operations** (`js/StateManager.js`)
```javascript
// Save operation
const apiPath = window.getAPIPath ?
    window.getAPIPath('save') :
    '/php/api/save.php';
// Production Result: '/training/online/accessilist/php/api/save'

fetch(apiPath, {
  method: 'POST',
  body: JSON.stringify(stateData)
});
// Full URL: https://webaim.org/training/online/accessilist/php/api/save
```

#### B. **Instantiate API** (`js/StateManager.js`)
```javascript
const apiPath = window.getAPIPath ?
    window.getAPIPath('instantiate') :
    '/php/api/instantiate.php';
// Production Result: '/training/online/accessilist/php/api/instantiate'
```

---

### 5. **Production URL Patterns**

**Asset URLs (Production):**
```
CSS:    https://webaim.org/training/online/accessilist/css/status.css
JS:     https://webaim.org/training/online/accessilist/js/StateManager.js
Images: https://webaim.org/training/online/accessilist/images/add-1.svg
JSON:   https://webaim.org/training/online/accessilist/json/word.json
```

**Page URLs (Production):**
```
Home:      https://webaim.org/training/online/accessilist/php/home.php
Admin:     https://webaim.org/training/online/accessilist/admin
Checklist: https://webaim.org/training/online/accessilist/?=ABC
Reports:   https://webaim.org/training/online/accessilist/php/reports.php
```

**API URLs (Production):**
```
Save:        POST https://webaim.org/training/online/accessilist/php/api/save
Restore:     GET  https://webaim.org/training/online/accessilist/php/api/restore?sessionKey=ABC
Instantiate: POST https://webaim.org/training/online/accessilist/php/api/instantiate
Delete:      POST https://webaim.org/training/online/accessilist/php/api/delete
List:        GET  https://webaim.org/training/online/accessilist/php/api/list
```

---

## COMPLETE URL CREATION FLOW DIAGRAMS

### Local Server Flow:
```
1. User clicks "Word" button
   ↓
2. Generate session ID: "ABC"
   ↓
3. POST /php/api/instantiate.php {sessionKey: "ABC", typeSlug: "word"}
   ↓
4. Redirect to: /?=ABC
   ↓
5. index.php captures ?=ABC
   ↓
6. Looks up type from php/saves/ABC.json
   ↓
7. Includes php/mychecklist.php with $_GET params
   ↓
8. URL stays: http://localhost:8000/?=ABC
```

### Production Server Flow:
```
1. User clicks "Word" button
   ↓
2. Generate session ID: "XYZ"
   ↓
3. POST /training/online/accessilist/php/api/instantiate.php {sessionKey: "XYZ", typeSlug: "word"}
   ↓
4. Redirect to: /?=XYZ
   ↓
5. index.php captures ?=XYZ
   ↓
6. Looks up type from /var/websites/webaim/htdocs/training/online/accessilist/php/saves/XYZ.json
   ↓
7. Includes php/mychecklist.php with $_GET params
   ↓
8. URL stays: https://webaim.org/training/online/accessilist/?=XYZ
```

---

## SUMMARY: Key Differences

| Aspect | Local Server | Production Server |
|--------|-------------|-------------------|
| **Base Path (PHP)** | `''` (empty) | `/training/online/accessilist` |
| **Base Path (JS)** | `''` (empty) | `/training/online/accessilist` |
| **Detection Method** | hostname, port | hostname |
| **API Extension** | `.php` added | No extension (rewrite rule) |
| **Minimal URL** | `/?=ABC` | `/?=XYZ` |
| **Full Checklist URL** | `http://localhost:8000/?=ABC` | `https://webaim.org/training/online/accessilist/?=XYZ` |
| **Admin URL** | `/admin` | `/admin` (same relative) |
| **Asset Prefix** | None | `/training/online/accessilist` |

---

## FILES INVOLVED IN URL CREATION

### PHP Files (48 `$basePath` usages):
1. `php/includes/config.php` - **SOURCE OF TRUTH** for environment detection
2. `php/includes/html-head.php` - CSS link generation (11 stylesheets)
3. `php/includes/common-scripts.php` - JS script loading
4. `php/includes/footer.php` - Footer asset paths
5. `php/home.php` - Navigation URLs (6 usages)
6. `php/admin.php` - Admin interface URLs (1 usage)
7. `php/mychecklist.php` - Checklist page URLs (8 usages)
8. `php/reports.php` - Report page URLs (1 usage)
9. `index.php` - Minimal URL routing

### JavaScript Files:
1. `js/path-utils.js` - **CLIENT-SIDE SOURCE OF TRUTH** for path generation
2. `js/StateManager.js` - API URL generation for save/restore
3. `js/ui-components.js` - Navigation URL generation
4. `js/admin.js` - Admin instance link generation
5. `js/type-manager.js` - Type-based URL routing

### Configuration Files:
1. `.htaccess` - Apache rewrite rules for clean URLs
2. `config.json` - Application configuration (deprecated for paths)

---

## CRITICAL URL CREATION PRINCIPLES

1. **Single Source of Truth (Server):** `php/includes/config.php`
2. **Single Source of Truth (Client):** `js/path-utils.js`
3. **Consistent Detection Logic:** Both PHP and JS use same hostname checks
4. **Global Variable Usage:** PHP `$basePath`, JS `window.get*Path()` functions
5. **Clean URLs:** Minimal format `/?=ABC` for easy sharing
6. **Backward Compatibility:** Fallback URLs always use full paths
7. **Rewrite Rules:** `.htaccess` handles extensionless API routing

