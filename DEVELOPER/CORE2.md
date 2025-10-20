# Production Deployment Manifest

**Last Updated:** 2025-10-20
**Purpose:** Complete list of files and directories required for production deployment

---

## 🎯 Production Directory Structure

```
/var/websites/webaim/htdocs/training/online/accessilist/
├── index.php                    # Application entry point
├── .htaccess                    # Apache routing rules
│
├── config/                      # Configuration files
│   └── checklist-types.json     # Type definitions and mappings
│
├── php/                         # PHP Backend
│   ├── index.php                # PHP subdirectory entry point
│   ├── home.php                 # Landing page / checklist selection
│   ├── list.php                 # Main checklist interface
│   ├── list-report.php          # Individual checklist report page
│   ├── systemwide-report.php    # Aggregate report across all checklists
│   ├── aeit.php                 # AEIT resource link page
│   │
│   ├── api/                     # API Endpoints (8 files)
│   │   ├── save.php             # Save checklist state
│   │   ├── restore.php          # Restore checklist state
│   │   ├── list.php             # List all saved sessions
│   │   ├── list-detailed.php    # Detailed session list with status
│   │   ├── delete.php           # Delete session data
│   │   ├── instantiate.php      # Create new checklist session
│   │   ├── generate-key.php     # Generate session keys
│   │   └── health.php           # API health check
│   │
│   └── includes/                # Shared PHP Components (9 files)
│       ├── config.php           # Environment configuration (loads .env)
│       ├── api-utils.php        # API helper functions
│       ├── html-head.php        # HTML head template
│       ├── footer.php           # Footer template
│       ├── noscript.php         # No-JavaScript warning
│       ├── common-scripts.php   # Common JavaScript includes
│       ├── session-utils.php    # Session management utilities
│       ├── type-manager.php     # Checklist type validation
│       └── type-formatter.php   # Type formatting utilities
│
├── js/                          # JavaScript Modules (19 files)
│   ├── main.js                  # Application initialization
│   ├── StateManager.js          # Application state management
│   ├── StateEvents.js           # Event handling and delegation
│   ├── StatusManager.js         # Status tracking logic
│   ├── buildCheckpoints.js      # Checkpoint content builder
│   ├── buildDemo.js             # Demo content builder
│   ├── addRow.js                # Dynamic row addition
│   ├── simple-modal.js          # Modal dialog component
│   ├── ModalActions.js          # Modal event handlers
│   ├── side-panel.js            # Side navigation panel
│   ├── scroll.js                # Scroll behavior management
│   ├── path-utils.js            # Environment-aware path utilities
│   ├── simple-path-config.js    # Path configuration
│   ├── type-manager.js          # Client-side type management
│   ├── date-utils.js            # Date formatting utilities
│   ├── list-report.js           # Individual report page logic
│   ├── systemwide-report.js     # Systemwide report page logic
│   ├── ui-components.js         # Reusable UI components
│   └── postcss.config.js        # PostCSS configuration (unused in production)
│
├── css/                         # Stylesheets (16 files)
│   ├── base.css                 # CSS variables and base styles
│   ├── header.css               # Header and navigation styles
│   ├── footer.css               # Footer and status bar styles
│   ├── landing.css              # Home page and button styles
│   ├── list.css                 # Checklist page layout
│   ├── list-report.css          # Report page styles
│   ├── reports.css              # Report table styles
│   ├── systemwide-report.css    # Systemwide report styles
│   ├── simple-modal.css         # Modal dialog styles
│   ├── form-elements.css        # Form input styles
│   ├── table.css                # Table and interactive elements
│   ├── scroll.css               # Scroll buffer styles
│   ├── focus.css                # Focus and hover states
│   ├── loading.css              # Loading overlay styles
│   ├── demo-inline-icons.css    # Inline icon styles
│   └── aeit.css                 # AEIT page styles
│
├── images/                      # SVG Icons (15 files)
│   ├── active-1.svg             # Active checkpoint icon
│   ├── done.svg                 # Completed checkpoint icon
│   ├── done-1.svg               # Completed variant icon
│   ├── ready-1.svg              # Ready checkpoint icon
│   ├── add-plus.svg             # Add row button icon
│   ├── delete.svg               # Delete button icon
│   ├── reset.svg                # Reset button icon
│   ├── info-.svg                # Info icon
│   ├── show-all.svg             # Show all icon
│   ├── show-all-1.svg           # Show all variant 1
│   ├── show-all-2.svg           # Show all variant 2
│   ├── show-one.svg             # Show one icon
│   ├── show-one-1.svg           # Show one variant 1
│   ├── show-one-2.svg           # Show one variant 2
│   └── cc-icons.svg             # Creative Commons icons
│
├── json/                        # Checklist Definitions (11 files)
│   ├── demo.json                # Demo checklist (tutorial)
│   ├── word.json                # Microsoft Word checklist
│   ├── powerpoint.json          # Microsoft PowerPoint checklist
│   ├── excel.json               # Microsoft Excel checklist
│   ├── docs.json                # Google Docs checklist
│   ├── slides.json              # Google Slides checklist
│   ├── camtasia.json            # Camtasia checklist
│   ├── dojo.json                # Dojo checklist
│   ├── test-5.json              # 5-checkpoint test checklist
│   ├── test-7.json              # 7-checkpoint test checklist
│   └── test-10-checkpoints.json # 10-checkpoint test checklist
│
└── sessions/                    # User Session Data (writable directory)
    └── .htaccess                # Security rules for session files
```

---

## 📄 Required Files by Category

### 🔹 Root Level (2 files)
- **`index.php`** - Application entry point; redirects to minimal URL or home page
- **`.htaccess`** - Apache mod_rewrite rules for clean URLs and API routing

### 🔹 Configuration (1 file)
- **`config/checklist-types.json`** - Checklist type definitions, display names, JSON file mappings, categories

### 🔹 PHP Backend (18 files)
**Pages (6 files):**
- **`php/index.php`** - PHP subdirectory entry point
- **`php/home.php`** - Landing page with checklist selection buttons
- **`php/list.php`** - Main checklist interface with checkpoints
- **`php/list-report.php`** - Individual checklist progress report
- **`php/systemwide-report.php`** - Aggregate report across all saved checklists
- **`php/aeit.php`** - AEIT (Accessible Educational Information Technology) resource page

**API Endpoints (8 files):**
- **`php/api/save.php`** - Save checklist state to sessions directory (atomic file locking)
- **`php/api/restore.php`** - Restore checklist state from session file
- **`php/api/list.php`** - List all saved sessions with basic metadata
- **`php/api/list-detailed.php`** - List sessions with detailed status calculations
- **`php/api/delete.php`** - Delete session file
- **`php/api/instantiate.php`** - Create new checklist session with type validation
- **`php/api/generate-key.php`** - Generate unique 3-character session keys
- **`php/api/health.php`** - API health check endpoint

**Includes (9 files):**
- **`php/includes/config.php`** - Environment detection and .env loading (critical)
- **`php/includes/api-utils.php`** - JSON response helpers, session key validation, file path utilities
- **`php/includes/html-head.php`** - HTML head template with CSS includes
- **`php/includes/footer.php`** - Footer template with status bar
- **`php/includes/noscript.php`** - No-JavaScript warning component
- **`php/includes/common-scripts.php`** - Common JavaScript module includes
- **`php/includes/session-utils.php`** - Session file management utilities
- **`php/includes/type-manager.php`** - Server-side checklist type validation
- **`php/includes/type-formatter.php`** - Type slug formatting and normalization

### 🔹 JavaScript Modules (19 files)
**Core Application (4 files):**
- **`js/main.js`** - Application initialization, checkpoint loading, app coordination
- **`js/StateManager.js`** - Centralized state management (checkpoints, rows, status)
- **`js/StateEvents.js`** - Event delegation and interaction handling
- **`js/StatusManager.js`** - Status button logic and checkpoint progress tracking

**Content Builders (2 files):**
- **`js/buildCheckpoints.js`** - Generates checkpoint HTML from JSON data
- **`js/buildDemo.js`** - Generates demo checklist with inline instructions

**UI Components (6 files):**
- **`js/simple-modal.js`** - Modal dialog component (save/restore/delete)
- **`js/ModalActions.js`** - Modal event handlers and actions
- **`js/side-panel.js`** - Side navigation panel (checkpoint list)
- **`js/scroll.js`** - Scroll buffer management for textareas
- **`js/addRow.js`** - Dynamic row addition for multi-item checkpoints
- **`js/ui-components.js`** - Reusable UI component builders

**Utilities (5 files):**
- **`js/path-utils.js`** - Environment-aware path resolution (basePath + apiExtension)
- **`js/simple-path-config.js`** - Client-side path configuration
- **`js/type-manager.js`** - Client-side type validation and slug management
- **`js/date-utils.js`** - Date formatting for timestamps

**Report Pages (2 files):**
- **`js/list-report.js`** - Individual checklist report page logic
- **`js/systemwide-report.js`** - Systemwide report page logic

**Optional (1 file):**
- **`js/postcss.config.js`** - PostCSS configuration (not used at runtime)

### 🔹 Stylesheets (16 files)
**Base & Layout (4 files):**
- **`css/base.css`** - CSS variables, typography, base element styles
- **`css/header.css`** - Sticky header, navigation buttons
- **`css/footer.css`** - Footer, status bar, progress indicators
- **`css/landing.css`** - Home page layout, checklist selection buttons

**Page-Specific (4 files):**
- **`css/list.css`** - Checklist page layout and grid system
- **`css/list-report.css`** - Individual report page styles
- **`css/reports.css`** - Report table styles
- **`css/systemwide-report.css`** - Systemwide report page styles

**Components (5 files):**
- **`css/simple-modal.css`** - Modal dialog overlay and content
- **`css/form-elements.css`** - Inputs, textareas, buttons
- **`css/table.css`** - Table styles and interactive elements
- **`css/scroll.css`** - Scroll buffer overlay styles
- **`css/demo-inline-icons.css`** - Inline icon positioning

**States (3 files):**
- **`css/focus.css`** - Focus indicators and hover states
- **`css/loading.css`** - Loading overlay and spinner
- **`css/aeit.css`** - AEIT page styles

### 🔹 Images (15 SVG files)
**Status Icons (4 files):**
- **`images/active-1.svg`** - Active checkpoint indicator
- **`images/done.svg`** - Completed checkpoint indicator
- **`images/done-1.svg`** - Completed variant
- **`images/ready-1.svg`** - Ready/not started indicator

**Action Icons (4 files):**
- **`images/add-plus.svg`** - Add row button
- **`images/delete.svg`** - Delete button
- **`images/reset.svg`** - Reset button
- **`images/info-.svg`** - Information icon

**View Toggle Icons (6 files):**
- **`images/show-all.svg`** - Show all checkpoints
- **`images/show-all-1.svg`** - Show all variant 1
- **`images/show-all-2.svg`** - Show all variant 2
- **`images/show-one.svg`** - Show single checkpoint
- **`images/show-one-1.svg`** - Show single variant 1
- **`images/show-one-2.svg`** - Show single variant 2

**Other (1 file):**
- **`images/cc-icons.svg`** - Creative Commons license icons

### 🔹 JSON Checklist Data (11 files)
**Production Checklists (8 files):**
- **`json/demo.json`** - Tutorial checklist with inline instructions
- **`json/word.json`** - Microsoft Word accessibility checklist
- **`json/powerpoint.json`** - Microsoft PowerPoint accessibility checklist
- **`json/excel.json`** - Microsoft Excel accessibility checklist
- **`json/docs.json`** - Google Docs accessibility checklist
- **`json/slides.json`** - Google Slides accessibility checklist
- **`json/camtasia.json`** - Camtasia video accessibility checklist
- **`json/dojo.json`** - Dojo accessibility checklist

**Test Checklists (3 files):**
- **`json/test-5.json`** - 5-checkpoint test checklist
- **`json/test-7.json`** - 7-checkpoint test checklist
- **`json/test-10-checkpoints.json`** - 10-checkpoint test checklist

### 🔹 Data Directories (1 directory + 1 file)
- **`sessions/`** - Directory for storing user session data (must be writable by Apache)
- **`sessions/.htaccess`** - Security rules: disable directory indexing, allow JSON file access

---

## ⚙️ External Configuration (NOT in repository)

### Required: `.env` File
**Production Location:** `/var/websites/webaim/htdocs/training/online/etc/.env`

**Purpose:** Environment-specific configuration loaded by `php/includes/config.php`

**Required Variables:**
```bash
APP_ENV=production

# Production paths
BASE_PATH_PRODUCTION=/training/online/accessilist
API_EXT_PRODUCTION=
DEBUG_PRODUCTION=false

# Local development paths (for reference)
BASE_PATH_LOCAL=
API_EXT_LOCAL=.php
DEBUG_LOCAL=true

# Apache-local testing paths (for reference)
BASE_PATH_APACHE_LOCAL=/training/online/accessilist
API_EXT_APACHE_LOCAL=
DEBUG_APACHE_LOCAL=true
```

**Critical:** `php/includes/config.php` searches for `.env` in three locations (priority order):
1. `/Users/a00288946/cursor-global/config/.env` (local development)
2. `/var/websites/webaim/htdocs/training/online/etc/.env` (production)
3. `[project_root]/.env` (legacy fallback)

---

## 🚫 Files NOT Required for Production

### Development Tools
- `node_modules/` - NPM dependencies (Puppeteer, Playwright, ESLint)
- `package.json`, `package-lock.json` - NPM configuration
- `router.php` - PHP built-in server routing (dev only)
- `docker-compose.yml`, `Dockerfile` - Docker testing environment
- `config.json` - Legacy deployment configuration (superseded by .env)

### Testing & Scripts
- `tests/` - Comprehensive test suite (30 automated tests)
- `scripts/` - 99 shell scripts for deployment, testing, MCP automation
- `logs/` - Test execution logs

### Documentation
- `README.md` - Project documentation
- `DEVELOPER/` - Developer documentation (20 files)
- `docs/` - Comprehensive documentation (100+ files)
- `IMPLEMENTATION-STATUS.md` - Development status tracking
- `changelog.md` - Change log
- `workflows.md` - Cursor workflow documentation
- All `.md` files

### Archives & Backups
- `archive/` - Historical files, planning docs, old implementations
- `my-mcp-servers/` - Custom MCP server implementations
- `saves/` - Legacy session storage (replaced by `sessions/`)
- `src/` - Legacy source directory (single index.js file)

### Build Artifacts
- `.git/` - Git repository data
- `jest.config.srd.js` - Jest testing configuration

---

## 📊 Production Deployment Summary

### Total File Count: **89 files** across **8 categories**

| Category | Files | Purpose |
|----------|-------|---------|
| Root | 2 | Entry point + Apache routing |
| Config | 1 | Checklist type definitions |
| PHP Backend | 18 | Server-side logic, API endpoints, templates |
| JavaScript | 19 | Client-side application logic |
| CSS | 16 | Stylesheets and visual design |
| Images | 15 | SVG icons and graphics |
| JSON Data | 11 | Checklist definitions |
| Data Dirs | 2 | Session storage directory + security rules |

### Critical Dependencies:
1. **Apache 2.4+** with `mod_rewrite` and `mod_headers` enabled
2. **PHP 8.x** with JSON, file locking support
3. **`.env` file** at `/var/websites/webaim/htdocs/training/online/etc/.env`
4. **Writable `sessions/` directory** with proper permissions (Apache user)

### Directory Permissions:
- **`sessions/`** - Must be writable by Apache (typically `www-data` or `apache`)
- All other files/directories can be read-only

### Apache Configuration Requirements:
- **`AllowOverride All`** in directory context (enables `.htaccess`)
- **`mod_rewrite`** enabled (clean URL routing)
- **`mod_headers`** enabled (cache control headers)

---

## 🎯 Deployment Checklist

- [ ] Upload all 89 required files maintaining directory structure
- [ ] Create `.env` file at `/var/websites/webaim/htdocs/training/online/etc/.env`
- [ ] Create `sessions/` directory if it doesn't exist
- [ ] Set write permissions on `sessions/` directory (chmod 755 or 775)
- [ ] Verify Apache has `AllowOverride All` enabled
- [ ] Verify `mod_rewrite` and `mod_headers` modules enabled
- [ ] Test clean URLs: `https://[domain]/training/online/accessilist/home`
- [ ] Test API endpoints: `https://[domain]/training/online/accessilist/php/api/health`
- [ ] Test session save/restore workflow
- [ ] Verify all checklist types load correctly

---

## 🔗 Related Documentation

- **DEPLOYMENT.md** - Complete deployment procedures
- **ROLLBACK_PLAN.md** - Emergency rollback procedures
- **SSH-SETUP.md** - SSH configuration for deployment
- **GENERAL-ARCHITECTURE.md** - System architecture overview
- **TESTING.md** - Comprehensive testing guide (76 automated tests)

---

## 🚀 Deployment Methods

This project implements **two methods** for excluding non-production files:

### Method 1: `.deployignore` (Exclusion List)
**Location:** `/.deployignore`
**Purpose:** Defines patterns for files/directories to EXCLUDE from deployment

**Usage:**
```bash
rsync -avz --exclude-from='.deployignore' ./ user@server:/path/
```

### Method 2: Explicit Include List (RECOMMENDED)
**Location:** `/scripts/deployment/upload-production-files.sh`
**Purpose:** Uploads ONLY the 89 required production files - nothing more, nothing less

**Usage:**
```bash
# Direct execution
./scripts/deployment/upload-production-files.sh

# Via Cursor workflow
proj-push-deploy-github
```

**Advantages:**
- ✅ Safest method - only uploads exactly what's needed
- ✅ No risk of uploading dev files or credentials
- ✅ Pre-flight checks verify all files exist
- ✅ Detailed logging and progress reporting

### Complete Documentation
See **`scripts/deployment/README-DEPLOYMENT-METHODS.md`** for:
- Detailed comparison of both methods
- Configuration options
- Security considerations
- Maintenance procedures
- Testing deployment

---

**Manifest Version:** 1.0.0
**Last Verified:** 2025-10-20
**Production Environment:** AWS EC2 (ec2-3-20-59-76.us-east-2.compute.amazonaws.com)
**Deployment Path:** `/var/websites/webaim/htdocs/training/online/accessilist/`
