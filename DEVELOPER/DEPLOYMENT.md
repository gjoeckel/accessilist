# Deployment Guide (modeled after otter)

This document describes how to deploy `accessilist` on the same server that runs the `otter` application, under the folder name `accessilist`. It mirrors otter's structure: Apache + PHP, simple file-based storage, explicit writable paths, and a permissions helper.

## 1) Server assumptions

- Apache with PHP (7.4+ works; otter targets PHP 8.x)
- You have SSH/SFTP access to the target path
- Existing site base: `/var/websites/webaim/htdocs/training/online`
- This app will deploy under a sibling folder: `/var/websites/webaim/htdocs/training/online/accessilist/`


If your server paths differ, adjust the paths below accordingly.

## 2) Directory layout

```text
/var/websites/webaim/htdocs/training/online/
├── otter/                  # existing app (reference)
├── otter2/                 # staging for otter
└── accessilist/            # this app (target)
    ├── php/
    ├── js/
    ├── css/
    ├── json/
    ├── saves/              # writable
    └── ...
```

DocumentRoot can be the app root (recommended) because routes are simple and `.htaccess` exists at root.

## 3) Files to upload

Upload the repository contents excluding development-only items:

- Exclude: `.git/`, `.github/`, `.cursor/`, `node_modules/` (not required at runtime), local caches
- Optional: exclude `scripts/` if not needed on the server
- Include everything else (PHP, JS, CSS, json/, saves/ directory)

Rsync example from your workstation:

```bash
rsync -av --delete \
  --exclude .git/ --exclude .github/ --exclude .cursor/ --exclude node_modules/ --exclude scripts/ \
  ./  user@server:/var/websites/webaim/htdocs/training/online/accessilist/
```

SFTP/GUI uploads are fine as long as structure remains identical.

## 4) Apache configuration

Minimal vhost snippet (adapt to your server):

```apache
<Directory /var/websites/webaim/htdocs/training/online/accessilist>
    AllowOverride All
    Require all granted
</Directory>

Alias /training/online/accessilist \
      /var/websites/webaim/htdocs/training/online/accessilist
```

This app ships a root `.htaccess` that enables simple rewrites and disables client caching for development. Ensure `mod_rewrite`, `mod_headers`, and `mod_alias` are enabled, as they are for otter.

## 5) Session Storage Setup (Secure)

**Critical:** Sessions are stored OUTSIDE the application directory for security.

```bash
# Create sessions directory (outside web root)
sudo mkdir -p /var/websites/webaim/htdocs/training/online/etc/sessions
sudo chown www-data:www-data /var/websites/webaim/htdocs/training/online/etc/sessions
sudo chmod 775 /var/websites/webaim/htdocs/training/online/etc/sessions

# Verify HTTP access is blocked
curl -I https://webaim.org/training/online/etc/sessions/
# Should return: 403 Forbidden ✅
```

**Directory Structure:**
```
/var/websites/webaim/htdocs/training/online/
├── accessilist/       (web root - production)
├── accessilist2/      (web root - test/staging)
└── etc/               (OUTSIDE web roots)
    ├── .env           (shared config for production)
    ├── .env.accessilist2 (config for test environment)
    └── sessions/      (shared session storage - SECURE)
```

**Security Benefits:**
- ✅ Sessions not web-accessible (403)
- ✅ Shared between environments
- ✅ Outside both web roots
- ✅ Proper Apache blocking

## 6) Environment Configuration (.env)

**Critical:** Each environment requires a `.env` file in `/var/websites/.../online/etc/`

### Production Environment (.env)
```bash
# Location: /var/websites/webaim/htdocs/training/online/etc/.env
BASE_PATH=/training/online/accessilist
API_EXT=
DEBUG=false
SESSIONS_PATH=/var/websites/webaim/htdocs/training/online/etc/sessions
```

### Test/Staging Environment (.env.accessilist2)
```bash
# Location: /var/websites/webaim/htdocs/training/online/etc/.env.accessilist2
BASE_PATH=/training/online/accessilist2
API_EXT=
DEBUG=true
SESSIONS_PATH=/var/websites/webaim/htdocs/training/online/etc/sessions
```

**Configuration Notes:**
- `BASE_PATH`: URL path to application root
- `API_EXT`: Empty for extensionless API routes
- `DEBUG`: Enable/disable debug logging
- `SESSIONS_PATH`: Absolute path to sessions directory (shared)

**Setup Commands:**
```bash
# Create .env files
sudo nano /var/websites/webaim/htdocs/training/online/etc/.env
sudo nano /var/websites/webaim/htdocs/training/online/etc/.env.accessilist2

# Set permissions
sudo chown www-data:www-data /var/websites/webaim/htdocs/training/online/etc/.env*
sudo chmod 644 /var/websites/webaim/htdocs/training/online/etc/.env*
```

## 7) CSS Architecture

This application uses individual CSS files for maintainability. No build process is required - all CSS files are included directly in the HTML pages in the correct order for proper cascading.

## 8) Health checks

- App home: `https://webaim.org/training/online/accessilist/php/home.php`
- Checklist instance (example): `https://webaim.org/training/online/accessilist/php/list.php?session=ABC&type=camtasia`
- Admin: `https://webaim.org/training/online/accessilist/php/admin.php`

Expect 200/302 responses like otter.

Example quick checks from a terminal:

```bash
curl -I https://webaim.org/training/online/accessilist/php/home.php
curl -I 'https://webaim.org/training/online/accessilist/php/list.php?session=ABC&type=camtasia'
```

## 9) Dual Environment Setup

This deployment supports two parallel environments:

### Production (accessilist/)
- **URL:** `/training/online/accessilist`
- **Config:** `/var/websites/.../online/etc/.env`
- **Purpose:** Live production site

### Test/Staging (accessilist2/)
- **URL:** `/training/online/accessilist2`
- **Config:** `/var/websites/.../online/etc/.env.accessilist2`
- **Purpose:** Testing and staging before production deployment

**Workflow:**
1. Deploy changes to `accessilist2/`
2. Run full test suite against test environment
3. Verify browser E2E tests pass
4. Deploy to `accessilist/` (production)
5. Run production tests

**Shared Resources:**
- Both environments use same `/etc/sessions/` directory
- Sessions are portable between environments
- Same Apache configuration handles both

## 10) Backups and rollback

Follow the otter pattern of deploying to a sibling folder and switching URLs if needed:

- Deploy initially to `/training/online/accessilist2/`
- Verify health and behavior
- Switch to production when stable

Prefer switching an Apache Alias if one is in use; otherwise, rename directories during a maintenance window.

## 11) Logs

This app does not manage logs like otter's `logs/`. Use Apache/PHP error logs. If desired, you can introduce a `logs/` folder and a small logging helper patterned after otter.

## 12) Security notes

- Enforce HTTPS at the proxy/web server
- Sessions stored outside web root (403 on HTTP access)
- Origin-based CSRF protection (no cookies required)
- Security headers set on all HTML responses
- Rate limiting currently disabled (see SECURITY.md)

## 13) Differences vs otter

- No Google Sheets or enterprise configs
- No internal/external API split – simple PHP endpoints under `php/api/`
- Sessions stored outside web root (more secure than otter's approach)
- Origin-based CSRF (simpler than session tokens)

---

For questions, see `README.md` and the repository scripts.
