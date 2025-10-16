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

## 5) Writable paths and permissions

This app writes user progress JSON files to `php/saves/` (and historically `saves/`). Create both and make them writable. Mirroring otter's approach (chmod-based, no chown in CI):

```bash
DEPLOY_PATH="/var/websites/webaim/htdocs/training/online/accessilist"
mkdir -p "$DEPLOY_PATH/php/saves" "$DEPLOY_PATH/saves"
chmod -R 775 "$DEPLOY_PATH/php/saves" "$DEPLOY_PATH/saves"

# Baseline perms (optional, similar to otter's helper)
find "$DEPLOY_PATH" -type f -exec chmod 644 {} \;
find "$DEPLOY_PATH" -type d -exec chmod 755 {} \;

# Quick write test (should create and remove a file without error)
echo '{}' > "$DEPLOY_PATH/php/saves/_write_test.json" && rm "$DEPLOY_PATH/php/saves/_write_test.json"
```

If you encounter write errors on shared hosting, increase to 777 (as otter does for caches) and harden later.

## 6) CSS Architecture

This application uses individual CSS files for maintainability. No build process is required - all CSS files are included directly in the HTML pages in the correct order for proper cascading.

## 7) Health checks

- App home: `https://webaim.org/training/online/accessilist/php/home.php`
- Checklist instance (example): `https://webaim.org/training/online/accessilist/php/list.php?session=ABC&type=camtasia`
- Admin: `https://webaim.org/training/online/accessilist/php/admin.php`

Expect 200/302 responses like otter.

Example quick checks from a terminal:

```bash
curl -I https://webaim.org/training/online/accessilist/php/home.php
curl -I 'https://webaim.org/training/online/accessilist/php/list.php?session=ABC&type=camtasia'
```

## 8) Backups and rollback

Follow the otter pattern of deploying to a sibling folder and switching URLs if needed:

- Deploy initially to `/training/online/accessilist2/`
- Verify health and behavior
- Switch links/aliases to point to `checklists2/` or rename directories during a maintenance window

Prefer switching an Apache Alias if one is in use; otherwise, rename directories during a maintenance window.

## 9) Logs

This app does not manage logs like otter's `logs/`. Use Apache/PHP error logs. If desired, you can introduce a `logs/` folder and a small logging helper patterned after otter.

## 10) Security notes

- Enforce HTTPS at the proxy/web server
- Keep `php/saves/` non-executable; JSON is inert but treat as sensitive
- Consider restricting listing of `/php/saves/` at the web server

## 11) Differences vs otter

- No Google Sheets or enterprise configs
- No internal/external API split – simple PHP endpoints under `php/api/`
- Single writable area: `php/saves/` (plus legacy `saves/`)

---

For questions, see `README.md` and the repository scripts.
