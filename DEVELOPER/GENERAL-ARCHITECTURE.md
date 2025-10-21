# AccessiList - General Architecture

**Document Type:** Backend Developer Code Audit Reference
**Last Updated:** October 20, 2025
**Purpose:** Complete system architecture overview for code auditors
**Branch:** cleanup-and-scope-server-files

---

## 📋 Table of Contents

1. [Project Overview](#project-overview)
2. [Technology Stack](#technology-stack)
3. [Directory Structure](#directory-structure)
4. [URL Routing System](#url-routing-system)
5. [TypeManager and Checklist Configuration](#typemanager-system)
6. [Scroll System Architecture](#scroll-system)
7. [Docker Development Environment](#docker-environment)
8. [Environment Configuration](#environment-configuration)
9. [Global PHP Functions](#php-utilities)
10. [Server Configuration](#server-configuration)
11. [Production Deployment](#production-deployment)

---

## 🎯 Project Overview

### Purpose
AccessiList is a web-based accessibility checklist application that helps users create, manage, and track accessibility compliance checklists for various document types (Word, PowerPoint, Excel, Google Docs, Slides, Camtasia, Dojo).

### Key Features
- **11 Checklist Types** - Pre-configured templates for different applications
- **Session Management** - Save and restore checklist progress
- **Reports Dashboard** - Systemwide aggregate reporting
- **Individual Reports** - Detailed single-checklist reports
- **AEIT Integration** - Accessible Educational & Instructional Technology information
- **Accessibility First** - WCAG 2.1 AA compliant interface

### Live Production
- **URL:** https://webaim.org/training/online/accessilist
- **Server:** AWS EC2 (Apache 2.4.52, PHP 8.1)
- **Deployment:** SSH-based push deployment

---

## 🔧 Technology Stack

### Backend
- **PHP 8.1** - Server-side logic
- **Apache 2.4** - Web server with mod_rewrite
- **JSON Files** - Session storage (no database)

### Frontend
- **Vanilla JavaScript** (ES6 modules)
- **CSS3** - Custom styling (no frameworks)
- **HTML5** - Semantic markup

### Development Tools
- **Docker** - Local production mirror (Apache 2.4 + PHP 8.1)
- **Puppeteer** - Automated testing
- **PHP Built-in Server** - Alternative local testing (router.php)

### Key Design Principles
- **No Framework Dependencies** - Pure PHP and vanilla JS
- **File-based Storage** - JSON session files (no database)
- **Clean URLs** - Extensionless routing via mod_rewrite
- **Production Parity** - Docker mirrors AWS production exactly

---

## 📁 Directory Structure

```
/Users/a00288946/Projects/accessilist/
├── php/                    # Backend PHP files
│   ├── home.php           # Landing page
│   ├── list.php           # Main checklist interface
│   ├── list-report.php    # Detailed single report
│   ├── systemwide-report.php  # Aggregate dashboard
│   ├── aeit.php           # AEIT information page
│   ├── index.php          # Alternative index
│   ├── api/               # API endpoints (8 total)
│   │   ├── save.php       # Save checklist state
│   │   ├── restore.php    # Restore saved state
│   │   ├── instantiate.php  # Create session placeholder
│   │   ├── delete.php     # Delete session
│   │   ├── list.php       # List sessions (metadata)
│   │   ├── list-detailed.php  # List with full state
│   │   ├── health.php     # API health check
│   │   └── generate-key.php  # Generate session keys
│   └── includes/          # Shared PHP modules
│       ├── config.php     # Environment configuration
│       ├── html-head.php  # HTML head template
│       ├── footer.php     # Footer template
│       ├── noscript.php   # No-JavaScript fallback
│       ├── common-scripts.php  # Script loader
│       ├── api-utils.php  # API helper functions
│       ├── session-utils.php   # Session utilities
│       ├── type-manager.php    # Server-side type handling
│       └── type-formatter.php  # Type formatting
├── js/                    # Frontend JavaScript
│   ├── main.js           # Main application entry
│   ├── StateManager.js   # Unified save/restore system
│   ├── StateEvents.js    # Event handling layer
│   ├── StatusManager.js  # Status button management
│   ├── scroll.js         # Scroll positioning system
│   ├── side-panel.js     # Checkpoint navigation
│   ├── simple-modal.js   # Modal dialogs
│   ├── ModalActions.js   # Modal action handlers
│   ├── ui-components.js  # Reusable UI components
│   ├── type-manager.js   # Client-side type handling
│   ├── buildCheckpoints.js  # Checkpoint table builder
│   ├── buildDemo.js      # Demo mode builder
│   ├── addRow.js         # Dynamic row addition
│   ├── list-report.js    # List report logic
│   ├── systemwide-report.js  # Systemwide report logic
│   ├── path-utils.js     # Path configuration
│   └── date-utils.js     # Date/timestamp utilities
├── css/                   # Stylesheets
│   ├── base.css          # Base styles
│   ├── header.css        # Header styling
│   ├── footer.css        # Footer styling
│   ├── list.css          # Checklist page styles
│   ├── list-report.css   # List report styles
│   ├── systemwide-report.css  # Systemwide report styles
│   ├── scroll.css        # Scroll buffer styles
│   ├── focus.css         # Focus indicators
│   ├── aeit.css          # AEIT page styles
│   └── simple-modal.css  # Modal styling
├── json/                  # Checklist type templates
│   ├── demo.json         # Demo checklist
│   ├── word.json         # Word checklist
│   ├── powerpoint.json   # PowerPoint checklist
│   ├── excel.json        # Excel checklist
│   ├── docs.json         # Google Docs checklist
│   ├── slides.json       # Google Slides checklist
│   ├── camtasia.json     # Camtasia checklist
│   └── dojo.json         # Dojo checklist
├── sessions/              # Saved session files
│   └── *.json            # User session data
├── config/                # Configuration files
│   ├── checklist-types.json  # Type configuration (11 types)
│   └── apache/
│       └── fixed-accessilist.conf  # Apache virtual host
├── tests/                 # Test suites
│   ├── puppeteer/        # Browser automation tests
│   └── screenshots/      # Test screenshots
├── scripts/               # Utility scripts
│   ├── test-production-mirror.sh  # 101 tests
│   └── external/
│       └── test-production.sh     # 42 tests
├── .htaccess             # Apache rewrite rules
├── router.php            # PHP dev server router
├── Dockerfile            # Production mirror image
├── docker-compose.yml    # Docker configuration
├── config.json           # Environment/deployment config
└── index.php             # Root redirect

```

---

## 🔀 URL Routing System

### Overview
AccessiList uses **extensionless URLs** via Apache mod_rewrite (production) or router.php (local development). All PHP files are accessed without the `.php` extension.

**Rule:** Remove `.php` from filename to get URL
**Example:** `/php/home.php` → `/home`

### Routing Implementation

**Files:** `.htaccess` (Apache/production) and `router.php` (local dev server)

**Logic:**
1. Allow direct access to existing files
2. API routes: `/php/api/save` → `/php/api/save.php`
3. General PHP: `/php/filename` → `/php/filename.php`
4. Root-level: `/filename` → `/php/filename.php`

**See:** `.htaccess` and `router.php` for complete implementation

### URL Endpoints

#### Public Pages (4)
| URL | File | Purpose |
|-----|------|---------|
| `/home` | `php/home.php` | Landing page - checklist type selection |
| `/list?type=X` | `php/list.php` | Main checklist interface |
| `/list-report?session=X` | `php/list-report.php` | Detailed single report |
| `/systemwide-report` | `php/systemwide-report.php` | Aggregate dashboard |

#### API Endpoints (8)
| URL | File | Method | Purpose |
|-----|------|--------|---------|
| `/php/api/health` | `php/api/health.php` | GET | Health check |
| `/php/api/save` | `php/api/save.php` | POST | Save state |
| `/php/api/restore` | `php/api/restore.php` | POST | Restore state |
| `/php/api/instantiate` | `php/api/instantiate.php` | POST | Create session |
| `/php/api/delete` | `php/api/delete.php` | DELETE | Delete session |
| `/php/api/list` | `php/api/list.php` | GET | List sessions |
| `/php/api/list-detailed` | `php/api/list-detailed.php` | GET | List with state |
| `/php/api/generate-key` | `php/api/generate-key.php` | GET | Generate key |

### Benefits
- **Consistency** - URL matches file structure
- **Predictability** - Remove `.php` to get URL
- **No Custom Aliases** - Direct filename mapping
- **Scalability** - Add pages without routing config

---

## 📦 TypeManager System

### Overview
Centralized checklist type management system handling 11 configured types. Provides type validation, slug/display name conversion, and type-specific configuration (AEIT links, JSON templates, categories).

### Configuration
**File:** `config/checklist-types.json`

**11 Types:** demo, word, powerpoint, excel, docs, slides, camtasia, dojo (+ 3 legacy)
**Categories:** Tutorial, Microsoft, Google, Other
**Properties:** displayName, jsonFile, buttonId, category, aeitLink (optional)

### Implementations
- **PHP:** `php/includes/type-manager.php` (static methods)
- **JavaScript:** `js/type-manager.js` (async static methods)

**Key Methods:** loadConfig(), validateType(), formatDisplayName(), getAvailableTypes()

**See:** `config/checklist-types.json` for complete type configuration

---

## 📜 Scroll System Architecture

### Overview
Path A/B scroll system that intelligently shows/hides scrollbars based on content size and provides optimized scroll positioning for checklist and report pages.

### Implementation: `js/scroll.js`

**Path A/B Logic (Checklist Pages):**
- **Path A:** Content fits → `body.no-scroll` class (hide scrollbar)
- **Path B:** Content doesn't fit → Remove class, show scrollbar + 100px bottom buffer

**Report Buffer (Report Pages):**
- Top buffer: 120px (header + filters)
- Bottom buffer: Dynamic (calculates viewport - targetPosition)
- Target: Last row at 400px from viewport top
- Updates: Only on filter change (not during scroll)

**CSS Variables:**
- `--bottom-buffer-report` - Dynamic bottom spacing

**Trigger Points:** Page load, Show All, Filter change, Checkpoint click

**Global API:** `window.ScrollManager` - Exports updateChecklistBuffer, updateReportBuffer, scheduleReportBufferUpdate

---

## 🐳 Docker Development Environment

### Overview
Local production mirror using Docker to exactly replicate AWS production environment (Apache 2.4.52 + PHP 8.1) for testing before deployment.

### `docker-compose.yml`

```yaml
version: '3.8'

services:
  web:
    image: php:8.1-apache
    container_name: accessilist-apache
    ports:
      - "8080:80"
    volumes:
      - .:/var/www/html
    environment:
      - APACHE_DOCUMENT_ROOT=/var/www/html
    command: >
      bash -c "
      a2enmod rewrite headers &&
      echo 'ServerName localhost' >> /etc/apache2/apache2.conf &&
      apache2-foreground
      "
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/"]
      interval: 5s
      timeout: 3s
      retries: 3
      start_period: 10s
```

**Usage:**
- Start: `proj-docker-up` → http://127.0.0.1:8080
- Test: `proj-test-mirror` (101 tests)
- Stop: `proj-docker-down`

**Benefits:** Production parity, no sudo, isolated, CI/CD ready

---

## ⚙️ Environment Configuration

### `config.json`

```json
{
  "environment": "production",
  "comment": "Set to 'local' for development, 'production' for deployment",
  "deployment": {
    "username": "george",
    "hostname": "ec2-3-20-59-76.us-east-2.compute.amazonaws.com",
    "key": "C:\\Users\\George\\.ssh\\GeorgeWebAIMServerKey.pem",
    "targetPath": "/var/websites/webaim/htdocs/training/online/accessilist/"
  }
}
```

**PHP:** `php/includes/config.php` - Loads config.json, sets BASE_PATH constant (local: '', production: '/training/online/accessilist')

**JavaScript:** `js/path-utils.js` - Provides getBasePath(), getAPIPath(), getConfigPath() based on ENV variable

---

## 🔧 Global PHP Functions

**Files:**
- `php/includes/api-utils.php` - API response utilities (send_json, send_error, send_success, validate_session_key)
- `php/includes/session-utils.php` - Session path helpers
- `php/includes/type-formatter.php` - Type formatting wrappers

**See:** [SAVE-AND-RESTORE.md](SAVE-AND-RESTORE.md) for complete API utilities documentation

---

## 🖥️ Server Configuration

### Apache (Production)

#### Version
Apache 2.4.52 on AWS EC2 (Ubuntu)

#### Key Modules
- `mod_rewrite` - URL routing
- `mod_headers` - HTTP headers
- `mod_php` - PHP processing

#### Virtual Host Configuration
Located at `/var/websites/webaim/htdocs/training/online/accessilist/`

```apache
<Directory /var/websites/webaim/htdocs/training/online/accessilist>
    Options -Indexes +FollowSymLinks
    AllowOverride All
    Require all granted
</Directory>
```


### PHP Configuration

#### Production
- PHP 8.1.x
- JSON extension enabled
- File uploads enabled (for future features)

#### Local (All Environments)
- PHP 8.1+ required
- No database extensions needed
- JSON is always available in PHP 8.1

---

## 📦 Production Deployment

### File Manifest (89 Items)

**Authoritative Source:** `scripts/deployment/upload-production-files.sh`

The production deployment uses an explicit whitelist of 89 files (2 root, 1 config, 23 PHP, 20 JS, 16 CSS, 15 images, 11 JSON).

**Key Points:**
- Sessions stored outside web root: `/var/websites/webaim/htdocs/training/online/etc/sessions/`
- Deployment uses rsync with `--files-from` for precision
- Security files excluded: `config.json`, `.env`, `.git/`, `scripts/`, docs

**Deployment Commands:**
```bash
# Verify manifest
./scripts/deployment/verify-deployment-manifest.sh

# Deploy to production
./scripts/deployment/upload-production-files.sh

# Or use workflow
proj-push-deploy-github
```

**Documentation:**
- Complete file breakdown: `scripts/deployment/upload-production-files.sh` (lines 86-231)
- Implementation guide: `docs/implementation/IMPLEMENTATION-DEPLOYMENT-EXCLUSIONS.md`
- Deployment guide: `DEPLOYMENT.md`

---

## 🎓 Getting Started (Developer Onboarding)

### Prerequisites
- PHP 8.1+
- Docker Desktop (recommended) OR Apache 2.4+ with mod_rewrite
- Node.js 14+ (for testing only)
- Git

### Quick Start

#### 1. Clone Repository
```bash
git clone https://github.com/gjoeckel/accessilist.git
cd accessilist
```

#### 2. Start Development Server

**Option A: Docker (Recommended)**
```bash
docker compose up -d
# Access: http://127.0.0.1:8080
```

**Option B: PHP Built-in Server**
```bash
php -S localhost:8000 router.php
# Access: http://localhost:8000
```

**Option C: macOS Apache**
```bash
# Setup required (see APACHE-SERVER-CONFIG.md)
sudo apachectl start
# Access: http://localhost/accessilist
```

#### 3. Run Tests
```bash
# Production mirror tests (101 tests)
./scripts/test-production-mirror.sh

# External production tests (42 tests)
./scripts/external/test-production.sh
```

#### 4. Development Workflow
```bash
# Make changes
# Test locally
./scripts/test-production-mirror.sh

# Commit (auto-updates changelog)
ai-local-commit

# Deploy to production
ai-push-deploy-github
```

### Key Files to Know
- `php/includes/config.php` - Environment configuration
- `config/checklist-types.json` - Type definitions
- `.htaccess` - URL routing rules
- `router.php` - Local routing (mirrors .htaccess)
- `docker-compose.yml` - Docker configuration

---

## 📚 Related Documentation

- **[SAVE-AND-RESTORE.md](SAVE-AND-RESTORE.md)** - Complete API reference, StateManager architecture
- **[LIST-USER-INTERFACE.md](LIST-USER-INTERFACE.md)** - UI components, side panel, modals, build functions
- **[TESTING.md](TESTING.md)** - Test suites, browser E2E and programmatic validation
- **[SYSTEMWIDE-REPORT.md](SYSTEMWIDE-REPORT.md)** - Aggregate reporting dashboard
- **[LIST-REPORT.md](LIST-REPORT.md)** - Individual checklist reports
- **[DEPLOYMENT.md](DEPLOYMENT.md)** - Deployment procedures
- **[SECURITY.md](SECURITY.md)** - Security implementation guide

---

*Document Created: October 20, 2025*
*Synthesized from: README.md, URL-ROUTING-MAP.md, GLOBAL-FUNCTIONS-ANALYSIS.md, APACHE-SERVER-CONFIG.md, DOCS-README.md, IMPLEMENTATION-STATUS.md + codebase extraction*
*Status: Complete system architecture reference for backend developers*
