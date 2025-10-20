# URL Routing Map

**Date**: October 15, 2025
**Status**: Simplified routing - extensionless URLs

---

## Overview

All PHP files in the `/php/` directory can be accessed without the `.php` extension. The routing is now simplified - just remove `.php` from the filename.

---

## Public-Facing Pages

### Main Application Pages

| User-Friendly URL | Actual File | Purpose |
|-------------------|-------------|---------|
| `/` or `/home` | `/php/home.php` | Home page - checklist type selection |
| `/list` | `/php/list.php` | Individual checklist page (requires `?type=` parameter) |
| `/list-report` | `/php/list-report.php` | Detailed list report (requires `?session=` parameter) |
| `/systemwide-report` | `/php/systemwide-report.php` | Systemwide aggregate report |

### Examples with Parameters

| Complete URL Example | Description |
|----------------------|-------------|
| `https://webaim.org/training/online/accessilist/` | Home page |
| `https://webaim.org/training/online/accessilist/home` | Home page (explicit) |
| `https://webaim.org/training/online/accessilist/list?type=word` | Word checklist |
| `https://webaim.org/training/online/accessilist/list?type=excel` | Excel checklist |
| `https://webaim.org/training/online/accessilist/list?type=powerpoint` | PowerPoint checklist |
| `https://webaim.org/training/online/accessilist/?session=ABC123` | Resume saved session |
| `https://webaim.org/training/online/accessilist/list-report?session=ABC123` | List report for session |
| `https://webaim.org/training/online/accessilist/systemwide-report` | Systemwide report |

---

## API Endpoints

All API endpoints follow the same pattern: `/php/api/{endpoint}` (no `.php` extension)

| User-Friendly URL | Actual File | Method | Purpose |
|-------------------|-------------|--------|---------|
| `/php/api/health` | `/php/api/health.php` | GET | Health check endpoint |
| `/php/api/save` | `/php/api/save.php` | POST | Save checklist data |
| `/php/api/restore` | `/php/api/restore.php` | POST | Restore saved data |
| `/php/api/list` | `/php/api/list.php` | GET | List saved sessions |
| `/php/api/list-detailed` | `/php/api/list-detailed.php` | GET | Detailed session list |
| `/php/api/delete` | `/php/api/delete.php` | DELETE | Delete saved session |
| `/php/api/generate-key` | `/php/api/generate-key.php` | GET | Generate session key |
| `/php/api/instantiate` | `/php/api/instantiate.php` | POST | Instantiate checklist |

### API Examples

| Complete API URL Example | Description |
|--------------------------|-------------|
| `https://webaim.org/training/online/accessilist/php/api/health` | Health check |
| `https://webaim.org/training/online/accessilist/php/api/list?type=word` | List Word sessions |
| `https://webaim.org/training/online/accessilist/php/api/save` | Save session (POST) |

---

## Internal Pages (Direct Access)

These pages can be accessed directly via the `/php/` prefix:

| URL | File | Purpose |
|-----|------|---------|
| `/php/index` | `/php/index.php` | Alternative index |
| `/php/home` | `/php/home.php` | Same as `/home` |
| `/php/list` | `/php/list.php` | Same as `/list` |
| `/php/list-report` | `/php/list-report.php` | Same as `/list-report` |
| `/php/systemwide-report` | `/php/systemwide-report.php` | Same as `/systemwide-report` |

---

## Legacy URL Changes

### Before (Old Routes)

| Old URL | Description |
|---------|-------------|
| `/reports` | Systemwide report (custom alias) |

### After (Simplified Routes)

| New URL | Description |
|---------|-------------|
| `/systemwide-report` | Systemwide report (matches filename) |

**Migration**: The `/reports` alias has been removed. Use `/systemwide-report` instead to match the actual filename.

---

## Routing Rules

### .htaccess (Apache/Production)

```apache
# API Routes: /php/api/save → /php/api/save.php
RewriteRule ^php/api/([^/.]+)$ php/api/$1.php [L]

# General PHP Routes: /php/filename → /php/filename.php
RewriteRule ^php/([^/.]+)$ php/$1.php [L]

# Root-level clean URLs: /filename → /php/filename.php
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule ^([^/.]+)$ php/$1.php [L]
```

### router.php (PHP Dev Server/Local)

```php
// API Routes: /php/api/save → /php/api/save.php
if (preg_match('#^/php/api/([^/.]+)$#', $requestUri, $matches)) {
    $apiFile = __DIR__ . '/php/api/' . $matches[1] . '.php';
    if (file_exists($apiFile)) {
        require $apiFile;
        return true;
    }
}

// General PHP Routes: /php/filename → /php/filename.php
if (preg_match('#^/php/([^/.]+)$#', $requestUri, $matches)) {
    $phpFile = __DIR__ . '/php/' . $matches[1] . '.php';
    if (file_exists($phpFile)) {
        require $phpFile;
        return true;
    }
}

// Root-level clean URLs: /filename → /php/filename.php
if (preg_match('#^/([^/.]+)$#', $requestUri, $matches)) {
    $phpFile = __DIR__ . '/php/' . $matches[1] . '.php';
    if (file_exists($phpFile)) {
        require $phpFile;
        return true;
    }
}
```

---

## Benefits of Simplified Routing

1. **Consistency**: URL structure matches file structure
2. **Predictability**: Just remove `.php` from filename to get URL
3. **Maintainability**: No custom alias mappings to remember
4. **Scalability**: Adding new pages requires no routing configuration
5. **Simplicity**: Fewer lines of code in both `.htaccess` and `router.php`

---

## Testing URLs

### Test Commands (Local)

```bash
# Start local server
php -S localhost:8000 router.php

# Test main pages
curl -I http://localhost:8000/home
curl -I http://localhost:8000/list?type=word
curl -I http://localhost:8000/list-report
curl -I http://localhost:8000/systemwide-report

# Test API endpoints
curl -I http://localhost:8000/php/api/health
curl -I http://localhost:8000/php/api/list
```

### Test Commands (Production)

```bash
# Run external test suite
./scripts/external/test-production.sh

# Manual tests
curl -I https://webaim.org/training/online/accessilist/home
curl -I https://webaim.org/training/online/accessilist/systemwide-report
curl -I https://webaim.org/training/online/accessilist/php/api/health
```

---

## Static Assets

Static assets (CSS, JS, JSON, images) are accessed directly without routing:

| Asset Type | URL Pattern | Example |
|------------|-------------|---------|
| CSS | `/css/{filename}.css` | `/css/base.css` |
| JavaScript | `/js/{filename}.js` | `/js/main.js` |
| JSON | `/json/{filename}.json` | `/json/word.json` |
| Images | `/images/{filename}.svg` | `/images/done-1.svg` |

---

## Complete Page Inventory

### User-Facing Pages (4)

1. **Home** - `/home` → Select checklist type
2. **My Checklist** - `/list?type=X` → Work on checklist
3. **List Report** - `/list-report?session=X` → View detailed report
4. **Systemwide Report** - `/systemwide-report` → View aggregate data

### API Endpoints (8)

1. **Health** - `/php/api/health` → System health
2. **Save** - `/php/api/save` → Save session
3. **Restore** - `/php/api/restore` → Restore session
4. **List** - `/php/api/list` → List sessions
5. **List Detailed** - `/php/api/list-detailed` → Detailed list
6. **Delete** - `/php/api/delete` → Delete session
7. **Generate Key** - `/php/api/generate-key` → Create session ID
8. **Instantiate** - `/php/api/instantiate` → Create checklist

### Total: 12 distinct endpoints

---

## Summary

The routing is now **fully simplified** - all URLs follow a consistent pattern of removing the `.php` extension from filenames. No special aliases or custom mappings are required.

**Key Change**: `/reports` → `/systemwide-report` (to match actual filename)
