# AccessiList - Save and Restore System

**Document Type:** Backend Developer Code Audit Reference
**Last Updated:** October 20, 2025
**Purpose:** Complete API reference and state management architecture
**Branch:** cleanup-and-scope-server-files

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Complete API Reference](#complete-api-reference)
3. [State Management Architecture](#state-management-architecture)
4. [Session Data Structure](#session-data-structure)
5. [Save Workflow](#save-workflow)
6. [Restore Workflow](#restore-workflow)
7. [Auto-Save System](#auto-save-system)
8. [Error Handling](#error-handling)
9. [Testing](#testing)

---

## 🎯 Overview

### Purpose
Complete session persistence and state management system enabling users to save checklist progress and restore it later. Includes 8 API endpoints, unified state management architecture (StateManager/StateEvents), and auto-save functionality.

### Key Features
- **8 RESTful API Endpoints** - Full CRUD operations for sessions
- **File-Based Storage** - JSON files (no database required)
- **Atomic Writes** - File locking prevents data corruption
- **Auto-Save** - Automatic state persistence during user interaction
- **Manual Save** - User-triggered save with confirmation
- **State Restoration** - Complete DOM state reconstruction from saved data
- **Session Management** - 3-character alphanumeric session keys

### Architecture Principles
- **Unified State Manager** - Single source of truth (replaces 7 legacy modules)
- **Event Delegation** - Centralized event handling (StateEvents)
- **API Utilities** - Standard response format across all endpoints
- **Idempotent Operations** - Safe retries for network failures

---

## 📡 Complete API Reference

### ⚠️ CRITICAL: All API Files Must Load config.php First

**Requirement:**
```php
<?php
require_once __DIR__ . '/../includes/config.php'; // MUST BE FIRST!
require_once __DIR__ . '/../includes/api-utils.php';
```

**Why:**
- `config.php` sets global `$sessionsPath`
- `config.php` loads `.env` configuration
- Without it: `$sessionsPath = null` → APIs fail

**Files That MUST Have This:**
- ✅ php/api/instantiate.php
- ✅ php/api/save.php
- ✅ php/api/restore.php
- ✅ php/api/delete.php
- ✅ php/api/list.php
- ✅ php/api/list-detailed.php
- ✅ php/api/generate-key.php (if needs sessions)
- ❌ php/api/health.php (doesn't need sessions)

---

### API Endpoint Summary

| Endpoint | Method | Purpose | Response |
|----------|--------|---------|----------|
| `/php/api/health` | GET | Health check | Server status |
| `/php/api/generate-key` | GET | Generate session key | 3-char unique key |
| `/php/api/instantiate` | POST | Create session placeholder | Success confirmation |
| `/php/api/save` | POST | Save checklist state | Success confirmation |
| `/php/api/restore` | GET | Restore saved state | Complete session data |
| `/php/api/list` | GET | List all sessions | Metadata array |
| `/php/api/list-detailed` | GET | List with full state | Complete data array |
| `/php/api/delete` | DELETE | Delete session | Success confirmation |

---

### 1. Health Check Endpoint

**Purpose:** API health monitoring
**Endpoint:** `GET /php/api/health`
**Response:** `{status: "ok", timestamp: number, version: "1.0.0", environment: "local"}`
**File:** `php/api/health.php`

---

### 2. Generate Key Endpoint

**Purpose:** Generate unique 3-character alphanumeric session keys
**Endpoint:** `GET /php/api/generate-key`
**Response:** `{success: true, data: {sessionKey: "A4K"}}`
**File:** `php/api/generate-key.php`

**Key Specs:**
- Length: 3 chars (A-Z, 0-9)
- Combinations: 46,656
- Reserved: WRD, PPT, XLS, DOC, SLD, CAM, DJO (demos)
- Algorithm: Random generation with uniqueness check (max 100 attempts)

---

### 3. Instantiate Endpoint

**Purpose:** Create empty session placeholder before first save
**Endpoint:** `POST /php/api/instantiate`
**Request:** `{sessionKey, typeSlug, state: {}}`
**Response:** `{success: true, data: {message: "Instance created"}}`
**File:** `php/api/instantiate.php`

**Key Features:**
- Creates placeholder with metadata (version, created timestamp)
- Idempotent (returns success if already exists)
- Uses atomic write with file locking (LOCK_EX)
- Validates typeSlug via TypeManager

---

### 4. Save Endpoint

**Purpose:** Save complete checklist state
**Endpoint:** `POST /php/api/save`
**Request:** `{sessionKey, typeSlug, metadata, state: {statusButtons, textareas}}`
**Response:** `{success: true, data: {message: ""}}`
**File:** `php/api/save.php`

**Key Features:**
- Atomic write with file locking (LOCK_EX) prevents corruption
- Metadata merge (preserves created, updates lastModified)
- Type validation via TypeManager
- Idempotent (safe to retry)

---

### 5. Restore Endpoint

**Purpose:** Restore saved session
**Endpoint:** `GET /php/api/restore?sessionKey=A4K`
**Response:** `{success: true, data: {sessionKey, typeSlug, metadata, state}}`
**File:** `php/api/restore.php`

### 6. List Sessions Endpoint

**Purpose:** List all sessions (metadata only, lightweight)
**Endpoint:** `GET /php/api/list`
**Response:** `{success: true, data: [{sessionKey, timestamp, typeSlug, metadata}, ...]}`
**File:** `php/api/list.php`
**Usage:** Systemwide dashboard quick loading (no state data)

### 7. List Detailed Endpoint

**Purpose:** List all sessions with full state (for status calculation)
**Endpoint:** `GET /php/api/list-detailed`
**Response:** Same as `/list` but includes `state: {statusButtons, textareas}` property
**File:** `php/api/list-detailed.php`
**Usage:** Systemwide report (needs full state for client-side status calc)

### 8. Delete Session Endpoint

**Purpose:** Delete session file
**Endpoint:** `DELETE /php/api/delete?session=A4K`
**Response:** `{success: true, data: {message: "Instance deleted successfully"}}`
**File:** `php/api/delete.php`

---

## 🏗️ State Management Architecture

### Overview
AccessiList uses a **Unified State Manager** that replaces 7 legacy modules with a single, cohesive system. This architecture provides centralized control over save/restore operations, auto-save, event delegation, and state synchronization.

### Legacy System (Replaced)
The old system had 7 separate modules:
1. `save-restore-orchestrator.js`
2. `save-restore-api.js`
3. `state-collector.js`
4. `state-restorer.js`
5. `session-manager.js`
6. `auto-save-manager.js`
7. `save-ui-manager.js`

**Problems:**
- Code duplication
- Inconsistent state handling
- Race conditions
- Hard to maintain
- No single source of truth

### New System (Current)
**Two core modules:**
1. **StateManager.js** - State management, save/restore logic
2. **StateEvents.js** - Centralized event delegation

---

### StateManager.js Architecture

**Purpose:** Unified state management (replaces 7 legacy modules)

**Core Responsibilities:**
- Session ID management
- State collection/restoration (statusButtons, textareas)
- API communication (all 8 endpoints)
- Auto-save (2s debounce)
- Manual save UI
- Dirty state tracking
- Loading overlay control

**Key Properties:**
```javascript
{
  sessionKey: null,
  isSaving: false,
  isDirty: false,
  autoSaveTimeout: null,
  autoSaveEnabled: false,
  saveButton, loadingOverlay
}
```

**Initialization Flow:**
1. Get sessionKey from URL or generate new
2. Initialize global state objects
3. Ensure backend instance exists (instantiate API)
4. Restore saved state if sessionKey present
5. Enable auto-save (2s debounce)
6. Setup before unload handler

---

### StateEvents.js Architecture

**Purpose:** Centralized event delegation for all user interactions

**Handles:**
- Status button clicks (mark dirty, trigger auto-save)
- Reset button clicks (confirm, reset task state)
- Textarea input (mark dirty, trigger auto-save)
- Side panel interactions

**Pattern:** Single event delegation (click + input) for all DOM interactions
- Performance: 1 listener vs. hundreds
- Dynamic content compatible
- No memory leaks

---

### StatusManager.js

**Purpose:** Status button state management
**States:** ready (gray) → active (yellow) → done (green) → ready (cycle)
**File:** `js/StatusManager.js`

---

## 📦 Session Data Structure

**Location:** `sessions/{SESSION_KEY}.json`

**Structure:**
```json
{
  "sessionKey": "A4K",
  "typeSlug": "word",
  "metadata": {
    "version": "1.0",
    "created": 1729450789000,
    "lastModified": 1729450999000
  },
  "state": {
    "statusButtons": {"0": "done", "1": "active", "2": "ready"},
    "textareas": {"0": "Notes text", "1": "More notes", "2": ""}
  }
}
```

**Key Fields:**
- `sessionKey` - 3-char unique ID
- `typeSlug` - Checklist type (word, excel, etc.)
- `metadata` - version, created/lastModified timestamps (ms)
- `state.statusButtons` - Task ID → status ("ready"/"active"/"done")
- `state.textareas` - Task ID → notes text

---

## 💾 Save Workflow

**Manual Save:** User clicks Save → Collect state → POST /php/api/save → Show loading overlay → Success modal
**Auto-Save:** User makes change → Mark dirty → Debounce 2s → POST /php/api/save (silent)

**Debouncing:** Each change resets 2s timer, saves only after inactivity

---

## 🔄 Restore Workflow

**Flow:** Page loads with ?session=XXX → GET /php/api/restore → Wait for contentBuilt event → Restore statusButtons and textareas to DOM
**Error Handling:** 404 → Start fresh, Invalid JSON → Error modal, Network fail → Retry option

---

## ⚡ Auto-Save System

**Triggers:** Status click, textarea input, add row, reset task
**Delay:** 2000ms (2s debounce)
**UX:** Silent (no overlay/modals)
**Optimization:** Only saves if dirty flag set

---

## ⚠️ Error Handling

**Standard Format:** `{success: false, message: "Error", timestamp: number}`

**Common HTTP Codes:**
- 400: Invalid session key/data/type
- 404: Session not found
- 405: Wrong HTTP method
- 500: File system/lock error
- 503: Key generation exhausted

**Client Handling:**
- Manual save fails → Show error modal
- Auto-save fails → Silent retry on next change
- Network timeout → 10s default
- Concurrent writes → Server file locking prevents corruption

---

## 🧪 Testing

**Test Coverage:** See [TESTING.md](TESTING.md) for complete test suite

**Key Scenarios:**
1. Save/restore cycle (full workflow)
2. Auto-save after 2s inactivity
3. All 8 API endpoints (curl tests)
4. Error handling (invalid keys, missing sessions)
5. Atomic write verification (concurrent saves)

**Production Mirror:** `proj-test-mirror` - 101 tests including save/restore workflow

---

## 📚 Related Documentation

- **[GENERAL-ARCHITECTURE.md](GENERAL-ARCHITECTURE.md)** - System overview, routing, TypeManager
- **[LIST-USER-INTERFACE.md](LIST-USER-INTERFACE.md)** - UI components, event handling
- **[TESTING.md](TESTING.md)** - Complete testing suite documentation
- **[SYSTEMWIDE-REPORT.md](SYSTEMWIDE-REPORT.md)** - Uses list-detailed endpoint
- **[DEPLOYMENT.md](DEPLOYMENT.md)** - Production deployment procedures

---

*Document Created: October 20, 2025*
*Synthesized from: TEST-SESSION-GUIDE.md, IMPLEMENTATION-STATUS.md + codebase extraction (StateManager.js, StateEvents.js, all 8 API endpoints)*
*Status: Complete API reference and state management architecture for backend developers*
