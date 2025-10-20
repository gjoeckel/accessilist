# Developer Assets Organization Plan

**Date:** October 20, 2025
**Purpose:** Reorganization plan for backend developer code audit documentation
**Current Files:** 21 markdown documents
**Target Structure:** 6 main topic documents + 4 supporting standalone documents

---

## 📋 Organization Strategy

Group documentation by **main code concerns** (application features) and **infrastructure** (architecture & testing), creating comprehensive topic-specific guides for code auditors.

---

## 🎯 Main Topic Documents (6)

### 1. **LIST-USER-INTERFACE.md** (NEW - Base Document)
**Focus:** Main checklist interface, interaction patterns, status management, accessibility

**Files to synthesize:**
- ✅ `note-status-logic.md` → Auto status management (Ready ↔ Active) based on notes interaction
- ✅ `WCAG-compliance-report.md` → Accessibility compliance and UI accessibility features

**Additional content from codebase (not currently documented):**
- ⚠️ **Side Panel Navigation** → Checkpoint navigation system (`side-panel.js`)
- ⚠️ **Modal System** → Simple modal and modal actions (`simple-modal.js`, `ModalActions.js`)
- ⚠️ **Home Page** → Landing page and type selection (`php/home.php`)
- ⚠️ **AEIT Page** → Accessibility info page (`php/aeit.php`)
- ⚠️ **UI Components** → Reusable component module (`ui-components.js`)
- ⚠️ **Build Functions** → Checkpoint/demo builders (`buildCheckpoints.js`, `buildDemo.js`, `addRow.js`)

**Key Topics:**
- Home page and checklist type selection
- Checklist rendering and interaction (build functions)
- Side panel checkpoint navigation (toggle, show all, scroll-to)
- Automatic status management logic
- Notes field behavior
- Modal dialogs (save, errors, notifications)
- Accessibility implementation (WCAG compliance)
- UI components and user experience
- AEIT information page

---

### 2. **SAVE-AND-RESTORE.md** (NEW - Base Document)
**Focus:** Session persistence, data management, save/restore API workflow, **ALL API endpoints**

**Files to synthesize:**
- ✅ `TEST-SESSION-GUIDE.md` → Session testing methodology and validation
- ✅ Relevant sections from `IMPLEMENTATION-STATUS.md` → Current save/restore implementation state

**Additional content from codebase (not currently documented):**
- ⚠️ **All 8 API Endpoints** → Complete API reference
  - `save.php` → Save checklist state
  - `restore.php` → Restore saved state
  - `instantiate.php` → Create new session placeholder
  - `delete.php` → Delete saved session
  - `list.php` → List all sessions (metadata only)
  - `list-detailed.php` → List sessions with full state
  - `health.php` → API health check
  - `generate-key.php` → Generate session keys
- ⚠️ **State Management System** → Core state architecture
  - `StateManager.js` → Unified save/restore (replaces 7 legacy modules)
  - `StateEvents.js` → Event handling layer
  - `StatusManager.js` → Status button management
- ⚠️ **Session Utilities** → PHP session helpers (`session-utils.php`)
- ⚠️ **Date Utilities** → Timestamp handling (`date-utils.js`)

**Key Topics:**
- **Complete API Reference** (all 8 endpoints with request/response specs)
- State Management architecture (StateManager, StateEvents, StatusManager)
- Session data structure and metadata
- Save API workflow (atomic writes, file locking)
- Restore API workflow
- Instantiate workflow (placeholder creation)
- Session file management (directory structure, naming)
- Session utilities (PHP helpers)
- Date/timestamp handling
- Error handling and validation
- API testing methodology

---

### 3. **LIST-REPORT.md** (BASE: `user-report-page.md`)
**Focus:** Individual checklist detailed report view

**Files to synthesize:**
- 📄 `user-report-page.md` → **BASE DOCUMENT** (detailed single checklist report specification)

**Key Topics:**
- User-specific report page (`/php/report.php`)
- Single checklist detailed view
- Task grouping by checkpoint
- Status indicators and timestamps
- Report navigation and UI

---

### 4. **SYSTEMWIDE-REPORT.md** (BASE: `reports-page.md`)
**Focus:** Aggregate reporting dashboard, all saved checklists

**Files to synthesize:**
- 📄 `reports-page.md` → **BASE DOCUMENT** (systemwide dashboard technical analysis)

**Key Topics:**
- Reports dashboard (`/php/reports.php`)
- Real-time status calculation (Done, Active, Ready)
- Progress tracking across all checklists
- Interactive filtering and sorting
- Table structure and data presentation

---

### 5. **GENERAL-ARCHITECTURE.md** (NEW - Base Document)
**Focus:** System design, routing, PHP structure, global functions, server configuration

**Files to synthesize:**
- ⚠️ `README.md` → **REPLACE with proper project overview** (currently Puppeteer docs - WRONG)
- ✅ `URL-ROUTING-MAP.md` → URL routing structure and clean URLs
- ✅ `GLOBAL-FUNCTIONS-ANALYSIS.md` → Shared PHP functions and global utilities
- ✅ `APACHE-SERVER-CONFIG.md` → Apache server configuration for macOS
- ✅ `DOCS-README.md` → Documentation navigation
- ⚠️ `IMPLEMENTATION-STATUS.md` → **EXPAND to all features** (currently only scroll buffer)

**Additional content from codebase (not currently documented):**
- ⚠️ **Router Implementation** → How routing actually works
  - `.htaccess` → Apache mod_rewrite rules
  - `router.php` → PHP built-in server router (mirrors .htaccess)
  - Extensionless URL mechanism
- ⚠️ **TypeManager System** → Checklist type management
  - `php/includes/type-manager.php` → Server-side type handling
  - `js/type-manager.js` → Client-side type handling
  - `config/checklist-types.json` → 11 type configurations
  - Type validation, slug conversion, AEIT link config
- ⚠️ **Scroll System Architecture** → Complete scroll.js overview
  - Dynamic buffer calculation
  - Path A/B logic (no-scroll class)
  - Integration with side panel and checkpoints
- ⚠️ **Docker Development Environment** → Local production mirror
  - `Dockerfile` → Apache 2.4 + PHP 8.1
  - `docker-compose.yml` → Port 8080 mapping
  - Production parity setup
- ⚠️ **Environment Configuration** → config.json and environment switching
  - Production vs. local settings
  - Deployment configuration
- ⚠️ **PHP Global Functions** → Utility functions
  - `api-utils.php` → API helpers (send_success, send_error, validate_session_key)
  - `session-utils.php` → Session path helpers
  - `type-formatter.php` → Type formatting

**Key Topics:**
- **Project Overview** (purpose, features, technology stack)
- Application architecture overview
- **URL Routing System** (how .htaccess and router.php work)
- **TypeManager and Type Configuration** (11 checklist types)
- **Scroll System Architecture** (complete scroll.js overview)
- PHP file structure and organization
- **Docker Development Environment** (local Apache setup)
- **Environment Configuration** (config.json)
- Global PHP functions and utilities
- Server configuration (Apache, mod_rewrite)
- Directory structure
- Getting started guide

---

### 6. **TESTING.md** (BASE with major synthesis)
**Focus:** Testing infrastructure with emphasis on `proj-test-mirror` (101 tests) and `external-test-production` (42 tests)

**Files to synthesize:**
- 📄 `TESTING.md` → **BASE DOCUMENT** (general testing strategy)
- ✅ `PRODUCTION-MIRROR-TESTING.md` → Local Docker Apache testing (`proj-test-mirror` - 101 tests)
- ✅ `EXTERNAL-PRODUCTION-TESTING.md` → Live production testing (`external-test-production` - 42 tests)
- ✅ `APACHE-TESTING-METHODS-RESEARCH.md` → Testing approaches and methodologies
- ✅ `LOCAL-TEST-REPORT.md` → Test results and analysis

**Key Topics:**
- Testing strategy and philosophy
- **Production Mirror Testing** (101 tests - Docker Apache on port 8080)
  - Connectivity tests
  - Clean URL routing tests
  - API endpoint tests
  - Save/restore workflow tests
  - Scroll buffer configuration tests
  - Side panel tests
  - AEIT page tests
- **External Production Testing** (42 tests - live server at webaim.org)
  - Production environment validation
  - Real-world usage testing
- Apache testing methods
- Test automation
- Session testing guide

---

## 📦 Supporting Standalone Documents (4)

These documents remain standalone as they serve specific operational purposes:

### 7. **DEPLOYMENT.md** (Standalone)
**Type:** Operational guide
**Content:** Deployment process and procedures
**Rationale:** Complete deployment workflow - keep standalone for ops reference

---

### 8. **ROLLBACK_PLAN.md** (Standalone)
**Type:** Emergency procedures
**Content:** Emergency rollback procedures
**Rationale:** Critical incident response - must be quickly accessible

---

### 9. **SSH-SETUP.md** (Standalone)
**Type:** Configuration guide
**Content:** SSH configuration for production access
**Rationale:** One-time setup guide - keep separate

---

### 10. **changelog.md** (Standalone)
**Type:** Historical record
**Content:** Complete project change history (229KB)
**Rationale:** Historical reference - too large to synthesize, valuable as standalone

---

## 📊 Summary

### File Disposition Matrix

| Category | Action | Count |
|----------|--------|-------|
| **Base Documents** (used as foundation) | Kept and expanded | 3 |
| **New Documents** (synthesized content) | Created from multiple sources | 3 |
| **Source Documents** (synthesized into main topics) | Merged into topic docs | 14 |
| **Standalone Documents** (kept separate) | Remain as-is | 4 |
| **Codebase Content** (not currently documented) | Extract and document | 15 |
| **Files Needing Replacement** (wrong content) | Replace | 2 |
| **TOTAL** | | **21** → **10** |

### Document Reduction
- **Before:** 21 separate documents (with gaps)
- **After:** 10 comprehensive documents (6 main topics + 4 supporting)
- **Reduction:** 52% fewer files, better organization
- **Completeness:** +15 undocumented features/systems added from codebase analysis

### Content Sources
- **Existing Docs:** 21 markdown files (12,728 lines)
- **Codebase Analysis:** 15 undocumented systems/features
- **Validation:** 25 recommended updates from VALIDATION-FINDINGS.md

---

## 🎯 Benefits for Code Auditor

1. **Feature-Focused Organization** - Documentation grouped by application features
2. **Comprehensive Coverage** - Each topic document contains all relevant information
3. **Testing Emphasis** - Clear focus on `proj-test-mirror` and `external-test-production`
4. **Reduced Navigation** - 10 docs instead of 21
5. **Architecture First** - General architecture provides system overview
6. **Quick Reference** - Supporting docs (deployment, rollback, SSH) easily accessible

---

## 📝 Implementation Notes

### Synthesis Guidelines:
- Preserve all technical details from source documents
- Remove duplicate information across files
- Maintain code examples and specifications
- Keep chronological context where relevant
- Cross-reference related topics

### Document Structure:
Each main topic document should include:
1. **Overview** - Feature/system description
2. **Architecture** - How it's built
3. **Code Analysis** - File-by-file breakdown
4. **API/Interface** - Public contracts
5. **Testing** - How it's tested
6. **Current Status** - Implementation state

---

## 🔍 Validation Findings Integration

**Date:** October 20, 2025
**Validation Source:** `VALIDATION-FINDINGS.md`

### Critical Discoveries

#### **Missing Documentation (15 gaps identified):**
All gaps have been integrated into the plan above with ⚠️ markers:
- 8 API endpoints (only save/restore were documented)
- State management system (StateManager, StateEvents, StatusManager)
- Side panel navigation
- Modal system
- Scroll system architecture
- Router implementation details
- TypeManager and type configuration
- Docker environment
- Home page, AEIT page
- UI components, build functions, utilities

#### **Files Requiring Replacement:**
- **README.md** - Currently contains Puppeteer test docs, needs project overview
- **IMPLEMENTATION-STATUS.md** - Currently only scroll buffer, needs all features

#### **Validation Results:**
- ✅ All 21 files are human-readable markdown (12,728 total lines)
- ⚠️ 15 undocumented systems/features found in codebase
- ⚠️ 2 files have incorrect/incomplete content
- ⚠️ 8 files need updates or clarification

**Impact:** Organization plan updated to include all missing content sources

---

## ⚠️ Status: UPDATED PLAN - READY FOR REVIEW

This is an updated organization plan incorporating validation findings. No files have been modified, merged, or deleted.

**Next Steps:**
1. Review and approve this organization plan
2. Execute synthesis process to create the 6 main topic documents
3. Verify all content is preserved
4. Archive source files (move to `DEVELOPER/source-files/`)
5. Update any cross-references

---

*Organization plan created: October 20, 2025*
*Last updated: October 20, 2025 (validation findings integrated)*
*Branch: cleanup-and-scope-server-files*
