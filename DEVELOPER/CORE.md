# AccessiList - Production Core Files

**Document Type:** Production Deployment Reference
**Purpose:** Complete list of files/directories required for production deployment
**Last Updated:** October 20, 2025

---

## 📋 Overview

This document identifies **ALL** files and directories that **MUST** be deployed to the production server for AccessiList to function properly. Files not listed here are development/testing/documentation assets and should be excluded from production deployment.

---

## 🗂️ Production Directory Structure

```
accessilist/                         (Project root)
├── .htaccess                        Apache URL rewriting
├── .env                             Environment configuration
├── router.php                       PHP built-in server routing (optional)
├── index.php                        Application entry point
│
├── php/                             Backend PHP application
│   ├── home.php                     Home page
│   ├── list.php                     Checklist interface
│   ├── list-report.php              Individual checklist reports
│   ├── systemwide-report.php        Aggregate dashboard
│   ├── aeit.php                     AEIT reference page
│   ├── index.php                    PHP directory index (not used)
│   │
│   ├── includes/                    Shared PHP libraries
│   │   ├── config.php               Environment and path configuration
│   │   ├── session-utils.php        Session management utilities
│   │   ├── type-manager.php         Checklist type definitions and validation
│   │   ├── api-utils.php            Shared API functions
│   │   ├── html-head.php            Common HTML head template
│   │   ├── common-scripts.php       Shared JavaScript injection
│   │   ├── footer.php               Common footer template
│   │   ├── noscript.php             No-JavaScript fallback message
│   │   └── type-formatter.php       Type display formatting utilities
│   │
│   └── api/                         RESTful API endpoints
│       ├── save.php                 Save checklist state
│       ├── restore.php              Restore checklist from session
│       ├── instantiate.php          Create new checklist from type
│       ├── delete.php               Delete saved checklist
│       ├── list.php                 List all saved checklists
│       ├── list-detailed.php        List with full metadata
│       ├── generate-key.php         Generate unique session key
│       └── health.php               API health check endpoint
│
├── css/                             Frontend stylesheets
│   ├── base.css                     Global styles, resets, typography
│   ├── header.css                   Top navigation and header
│   ├── footer.css                   Footer styles
│   ├── landing.css                  Home page styles
│   ├── list.css                     Checklist interface styles
│   ├── list-report.css              Individual report styles
│   ├── systemwide-report.css        Dashboard report styles
│   ├── reports.css                  Shared report styles
│   ├── table.css                    Table component styles
│   ├── form-elements.css            Form inputs and controls
│   ├── simple-modal.css             Modal dialog styles
│   ├── loading.css                  Loading overlay styles
│   ├── scroll.css                   Scroll behavior styles
│   ├── focus.css                    Keyboard focus indicators
│   ├── aeit.css                     AEIT page styles
│   └── demo-inline-icons.css        Inline icon styles
│
├── js/                              Frontend JavaScript (ES modules)
│   ├── main.js                      Application initialization
│   ├── StateManager.js              Centralized state management
│   ├── StateEvents.js               Event handling and delegation
│   ├── StatusManager.js             Status calculation logic
│   ├── type-manager.js              Type definitions (client-side)
│   ├── scroll.js                    Scroll buffer management
│   ├── side-panel.js                Navigation side panel
│   ├── simple-modal.js              Modal dialog system
│   ├── ModalActions.js              Modal action handlers
│   ├── ui-components.js             Reusable UI components
│   ├── addRow.js                    Dynamic row addition
│   ├── buildCheckpoints.js          Checkpoint list builder
│   ├── buildDemo.js                 Demo checklist builder
│   ├── list-report.js               Individual report logic
│   ├── systemwide-report.js         Dashboard report logic
│   ├── date-utils.js                Date formatting utilities
│   ├── path-utils.js                Path resolution utilities
│   └── simple-path-config.js        Path configuration client-side
│
├── images/                          UI icons and graphics
│   ├── active-1.svg                 Active status icon
│   ├── done-1.svg                   Done status icon (primary)
│   ├── done.svg                     Done status icon (alternate)
│   ├── ready-1.svg                  Ready status icon
│   ├── add-plus.svg                 Add button icon
│   ├── delete.svg                   Delete button icon
│   ├── reset.svg                    Reset button icon
│   ├── info-.svg                    Info icon
│   ├── show-all-1.svg               Show all icon (variant 1)
│   ├── show-all-2.svg               Show all icon (variant 2)
│   ├── show-all.svg                 Show all icon (primary)
│   ├── show-one-1.svg               Show one icon (variant 1)
│   ├── show-one-2.svg               Show one icon (variant 2)
│   ├── show-one.svg                 Show one icon (primary)
│   └── cc-icons.svg                 Creative Commons icons
│
├── json/                            Checklist data files
│   ├── demo.json                    Demo/tutorial checklist
│   ├── word.json                    Microsoft Word checklist
│   ├── powerpoint.json              PowerPoint checklist
│   ├── excel.json                   Excel checklist
│   ├── docs.json                    Google Docs checklist
│   ├── slides.json                  Google Slides checklist
│   ├── camtasia.json                Camtasia checklist
│   ├── dojo.json                    Dojo checklist
│   ├── test-5.json                  5-checkpoint test (testing)
│   ├── test-7.json                  7-checkpoint test (testing)
│   └── test-10-checkpoints.json     10-checkpoint test (testing)
│
├── config/                          Application configuration
│   └── checklist-types.json         Type definitions and categories
│
├── sessions/                        User session storage (writable)
│   └── (empty on deploy)            Created session files: {KEY}.json
│
└── saves/                           User saved checklists (writable)
    └── (empty on deploy)            Created save files: {TYPE}-{KEY}.json
```

---

## 📦 File Count Summary

| Directory | Files | Purpose |
|-----------|-------|---------|
| **Root** | 3-4 files | Entry points and routing |
| **php/** | 5 files | Page controllers |
| **php/includes/** | 9 files | Shared backend libraries |
| **php/api/** | 8 files | RESTful API endpoints |
| **css/** | 16 files | Stylesheets |
| **js/** | 19 files | Frontend logic |
| **images/** | 16 files | UI icons |
| **json/** | 11 files | Checklist data |
| **config/** | 1 file | Type configuration |
| **sessions/** | Directory | Session storage (writable) |
| **saves/** | Directory | User saves (writable) |
| **TOTAL** | **88-89 files** + **2 directories** | Complete application |

---

## 🔧 Root Files (3-4 files)

### .htaccess
**Purpose:** Apache mod_rewrite URL routing for clean URLs
**Required:** Yes (Apache only)
**Details:** Enables extensionless PHP files, API routing without .php extension

### .env
**Purpose:** Environment-specific configuration (base paths, API extensions, debug mode)
**Required:** Yes
**Details:** Must be configured for production environment before deployment

### index.php
**Purpose:** Application entry point, handles root access and minimal URLs (?=KEY)
**Required:** Yes
**Details:** Includes config, session utils, type manager; routes to appropriate pages

### router.php
**Purpose:** PHP built-in server routing (dev/testing alternative to Apache)
**Required:** No (production uses Apache)
**Details:** Mimics .htaccess for php -S localhost:8000, optional for production

---

## 🔧 PHP Backend (22 files)

### php/ - Page Controllers (5 files)

#### php/home.php
**Purpose:** Landing page with checklist type selection

#### php/list.php
**Purpose:** Main checklist interface with status tracking

#### php/list-report.php
**Purpose:** Individual checklist detailed report view

#### php/systemwide-report.php
**Purpose:** Aggregate dashboard across all checklists

#### php/aeit.php
**Purpose:** AEIT reference documentation page

### php/includes/ - Shared Libraries (9 files)

#### php/includes/config.php
**Purpose:** Environment detection, .env loading, path configuration

#### php/includes/session-utils.php
**Purpose:** Session file management, key generation, type extraction

#### php/includes/type-manager.php
**Purpose:** Checklist type definitions, validation, JSON file mapping

#### php/includes/api-utils.php
**Purpose:** Shared API functions (validation, responses, error handling)

#### php/includes/html-head.php
**Purpose:** Common HTML head template (meta tags, CSS links)

#### php/includes/common-scripts.php
**Purpose:** JavaScript injection, environment config export

#### php/includes/footer.php
**Purpose:** Common footer HTML template

#### php/includes/noscript.php
**Purpose:** No-JavaScript fallback message template

#### php/includes/type-formatter.php
**Purpose:** Type display name formatting utilities

### php/api/ - RESTful Endpoints (8 files)

#### php/api/save.php
**Purpose:** Save checklist state to session file

#### php/api/restore.php
**Purpose:** Restore checklist state from session key

#### php/api/instantiate.php
**Purpose:** Create new checklist from type template

#### php/api/delete.php
**Purpose:** Delete saved checklist session file

#### php/api/list.php
**Purpose:** List all saved checklists (basic)

#### php/api/list-detailed.php
**Purpose:** List all checklists with full metadata

#### php/api/generate-key.php
**Purpose:** Generate unique 3-character session key

#### php/api/health.php
**Purpose:** API health check endpoint

---

## 🎨 CSS Stylesheets (16 files)

### Core Styles

#### css/base.css
**Purpose:** Global resets, typography, layout primitives

#### css/header.css
**Purpose:** Top navigation bar and header styles

#### css/footer.css
**Purpose:** Footer layout and styles

#### css/landing.css
**Purpose:** Home page type selection layout

### Page-Specific Styles

#### css/list.css
**Purpose:** Checklist interface table, rows, status indicators

#### css/list-report.css
**Purpose:** Individual report formatting and layout

#### css/systemwide-report.css
**Purpose:** Dashboard aggregate report styles

#### css/reports.css
**Purpose:** Shared report components and utilities

#### css/aeit.css
**Purpose:** AEIT reference page styles

### Component Styles

#### css/table.css
**Purpose:** Table component base styles

#### css/form-elements.css
**Purpose:** Form inputs, buttons, controls

#### css/simple-modal.css
**Purpose:** Modal dialog overlay and content

#### css/loading.css
**Purpose:** Loading overlay and spinner

#### css/scroll.css
**Purpose:** Scroll buffer and overflow styles

#### css/focus.css
**Purpose:** Keyboard focus indicators for accessibility

#### css/demo-inline-icons.css
**Purpose:** Inline icon styling and positioning

---

## 💻 JavaScript Frontend (19 files)

### Core Application

#### js/main.js
**Purpose:** Application initialization and DOM ready handling

#### js/StateManager.js
**Purpose:** Centralized state management (checklist, checkpoints, status)

#### js/StateEvents.js
**Purpose:** Event delegation and user interaction handling

#### js/StatusManager.js
**Purpose:** Status calculation logic and automatic updates

#### js/type-manager.js
**Purpose:** Client-side type definitions and validation

### UI Components

#### js/scroll.js
**Purpose:** Scroll buffer management for fixed headers

#### js/side-panel.js
**Purpose:** Navigation side panel open/close logic

#### js/simple-modal.js
**Purpose:** Modal dialog system (open, close, confirm, prompt)

#### js/ModalActions.js
**Purpose:** Modal action handlers (save, restore, delete)

#### js/ui-components.js
**Purpose:** Reusable UI component builders

### Builders

#### js/buildCheckpoints.js
**Purpose:** Dynamic checkpoint list rendering from JSON

#### js/buildDemo.js
**Purpose:** Demo checklist builder with example data

#### js/addRow.js
**Purpose:** Dynamic row addition to checklist

### Reports

#### js/list-report.js
**Purpose:** Individual checklist report generation

#### js/systemwide-report.js
**Purpose:** Dashboard aggregate report calculations

### Utilities

#### js/date-utils.js
**Purpose:** Date formatting and parsing utilities

#### js/path-utils.js
**Purpose:** Path resolution for environment-aware URLs

#### js/simple-path-config.js
**Purpose:** Client-side path configuration

---

## 🖼️ Images (16 files)

### Status Icons

#### images/active-1.svg
**Purpose:** Active status indicator icon

#### images/done-1.svg
**Purpose:** Done status indicator (primary variant)

#### images/done.svg
**Purpose:** Done status indicator (alternate variant)

#### images/ready-1.svg
**Purpose:** Ready status indicator icon

### Action Icons

#### images/add-plus.svg
**Purpose:** Add/create button icon

#### images/delete.svg
**Purpose:** Delete/remove button icon

#### images/reset.svg
**Purpose:** Reset/clear button icon

#### images/info-.svg
**Purpose:** Information/help icon

### View Toggle Icons

#### images/show-all-1.svg
**Purpose:** Show all items icon (variant 1)

#### images/show-all-2.svg
**Purpose:** Show all items icon (variant 2)

#### images/show-all.svg
**Purpose:** Show all items icon (primary)

#### images/show-one-1.svg
**Purpose:** Show one item icon (variant 1)

#### images/show-one-2.svg
**Purpose:** Show one item icon (variant 2)

#### images/show-one.svg
**Purpose:** Show one item icon (primary)

### Other

#### images/cc-icons.svg
**Purpose:** Creative Commons license icons

---

## 📄 JSON Data Files (11 files)

### Production Checklists

#### json/demo.json
**Purpose:** Tutorial/demo checklist with example data

#### json/word.json
**Purpose:** Microsoft Word accessibility checklist

#### json/powerpoint.json
**Purpose:** PowerPoint accessibility checklist

#### json/excel.json
**Purpose:** Excel accessibility checklist

#### json/docs.json
**Purpose:** Google Docs accessibility checklist

#### json/slides.json
**Purpose:** Google Slides accessibility checklist

#### json/camtasia.json
**Purpose:** Camtasia video accessibility checklist

#### json/dojo.json
**Purpose:** Dojo framework accessibility checklist

### Testing Checklists

#### json/test-5.json
**Purpose:** 5-checkpoint test checklist (can be removed in production)

#### json/test-7.json
**Purpose:** 7-checkpoint test checklist (can be removed in production)

#### json/test-10-checkpoints.json
**Purpose:** 10-checkpoint test checklist (can be removed in production)

---

## ⚙️ Configuration Files (1 file)

### config/checklist-types.json
**Purpose:** Checklist type definitions, display names, categories, JSON file mapping
**Required:** Yes
**Details:** Defines all available checklist types and their properties

---

## 📁 Writable Directories (2 directories)

### sessions/
**Purpose:** User session file storage
**Required:** Yes (must be writable by web server)
**Permissions:** 755 or 775 directory, 644 files
**Contents:** Created at runtime: `{KEY}.json` (e.g., `ABC.json`)
**Details:** Stores checklist state for save/restore functionality

### saves/
**Purpose:** User saved checklist storage
**Required:** Yes (must be writable by web server)
**Permissions:** 755 or 775 directory, 644 files
**Contents:** Created at runtime: `{TYPE}-{KEY}.json` (e.g., `word-ABC.json`)
**Details:** Persistent storage for named saves

---

## ❌ Files/Directories NOT Needed in Production

The following should be **excluded** from production deployment:

### Development Tools
- `node_modules/` - NPM dependencies (dev only)
- `package.json` - NPM package config (dev only)
- `package-lock.json` - NPM lock file (dev only)
- `src/` - Source files (dev only)
- `my-mcp-servers/` - MCP development servers (dev only)

### Testing
- `tests/` - Test files and reports (dev only)
- `logs/` - Test logs (generated)

### Documentation
- `DEVELOPER/` - Developer documentation (not needed for runtime)
- `docs/` - Documentation files (not needed for runtime)
- `archive/` - Historical files (not needed for runtime)
- `README.md` - Project documentation (not needed for runtime)
- `changelog.md` - Change history (not needed for runtime)
- `workflows.md` - Workflow documentation (not needed for runtime)
- `IMPLEMENTATION-STATUS.md` - Status tracking (not needed for runtime)

### Build/Deployment Scripts
- `scripts/` - Development and deployment scripts (not needed for runtime)
- `Dockerfile` - Docker config (dev only)
- `docker-compose.yml` - Docker compose config (dev only)
- `.dockerignore` - Docker ignore file (dev only)

### Version Control
- `.git/` - Git repository (version control only)
- `.gitignore` - Git ignore file (version control only)

### IDE/Editor
- `.cursor/` - Cursor IDE config (dev only)
- `.vscode/` - VS Code config (dev only)

### Configuration (Deploy-Time Only)
- `config/apache/` - Local Apache config files (not for production Apache)
- `.env.example` - Environment template (copy to .env before deploy)
- `.env.backup` - Environment backup (not needed)
- `.env.docker` - Docker environment (dev only)
- `config.json` - Unknown config (verify if needed)

---

## 🚀 Deployment Checklist

### Pre-Deployment
1. ✅ Verify all **88-89 production files** are present
2. ✅ Configure `.env` for production environment
3. ✅ Verify `config/checklist-types.json` includes all needed types
4. ✅ Create `sessions/` directory with write permissions
5. ✅ Create `saves/` directory with write permissions
6. ✅ Test checklist JSON files are valid
7. ✅ Verify all SVG images exist and are not corrupted

### Post-Deployment
1. ✅ Verify `.htaccess` URL rewriting works
2. ✅ Test all page routes: `/home`, `/list`, `/systemwide-report`, `/list-report`, `/aeit`
3. ✅ Test all API endpoints: save, restore, instantiate, delete, list, health
4. ✅ Verify sessions/ directory is writable
5. ✅ Verify saves/ directory is writable
6. ✅ Test complete save/restore workflow
7. ✅ Verify all CSS files load correctly
8. ✅ Verify all JS files load correctly
9. ✅ Verify all images load correctly

### Security
1. ✅ Set proper file permissions (644 for files, 755 for directories)
2. ✅ Set writable permissions only for `sessions/` and `saves/`
3. ✅ Verify `.env` is readable by web server but not publicly accessible
4. ✅ Verify no development files (tests/, scripts/) are deployed

---

## 📊 Production File Size Estimates

| Category | File Count | Approx Size |
|----------|------------|-------------|
| **PHP** | 22 files | ~150 KB |
| **CSS** | 16 files | ~100 KB |
| **JavaScript** | 19 files | ~200 KB |
| **Images (SVG)** | 16 files | ~50 KB |
| **JSON** | 11 files | ~500 KB |
| **Config** | 2 files | ~2 KB |
| **TOTAL** | **88-89 files** | **~1 MB** |

**Note:** Sizes are estimates and may vary based on actual content.

---

## 🔍 File Validation Commands

### Count Production Files
```bash
# Root files (3-4)
ls -1 .htaccess .env index.php router.php 2>/dev/null | wc -l

# PHP files (22)
find php -name "*.php" | wc -l

# CSS files (16)
find css -name "*.css" | wc -l

# JavaScript files (19)
find js -name "*.js" ! -name "postcss.config.js" | wc -l

# Images (16)
find images -name "*.svg" | wc -l

# JSON files (11)
find json -name "*.json" | wc -l

# Config files (1)
find config -name "checklist-types.json" | wc -l
```

### Verify Writable Directories
```bash
# Check if directories exist and are writable
test -d sessions && test -w sessions && echo "✅ sessions/ OK"
test -d saves && test -w saves && echo "✅ saves/ OK"
```

### Verify All Required Files
```bash
# Run from project root
# Exits with error if any required file is missing
./scripts/deployment/verify-core-files.sh
```

---

**Last Updated:** October 20, 2025
**Maintainer:** AccessiList Development Team
**Status:** ✅ Complete and ready for production deployment
