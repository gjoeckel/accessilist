# User Report Feature - Specification Document

**Document Type:** Feature Specification for AI Agent Implementation
**Last Updated:** October 8, 2025
**Feature:** User-Specific Checklist Report
**Component:** `/php/report.php` (NEW - User report page)
**vs. Existing:** `/php/reports.php` (System-wide admin reports)

---

## Feature Overview

A user-specific report page that displays a detailed view of a single checklist instance with all tasks, notes, update timestamps, and status indicators grouped by principle.

---

## Core Requirements

### 1. File Locations

**New Files:**
- `/php/report.php` - User report page template
- `/js/report.js` - Client-side report logic (distinct from `/js/reports.js`)

**Modified Files:**
- `/php/mychecklist.php` - Add "Report" button to header
- `/router.php` - Add `/report` clean URL route
- `/css/header.css` - Report button styling (may already exist)

### 2. URL Structure

```
User Report:   /report?session=ABC  (single checklist)
System Report: /reports             (all checklists)
```

### 3. Page Structure

**Header:**
```
<h1>My [Type] Checklist</h1>
<p>Last updated: [timestamp]</p>
```

Example: "My Camtasia Checklist"
Last updated: "10-08-25 2:45 PM"

**Navigation:**
- Home button (left side of header)
- Report button opens in new window from mychecklist.php
- Positioned left of Save button
- Same CSS styling as Home page button

### 4. Table Structure

**4 Columns (in order):**

1. **Tasks Column**
   - Lists each default task from JSON
   - Lists each manually added task
   - Grouped by principle with headers
   - Maintains principle order (1.1, 1.2, 2.1, etc.)

2. **Notes Column**
   - Displays saved notes for each task
   - From `state.notes` object
   - Empty cells if no notes

3. **Updated Column**
   - Shows timestamp of last state change for that task
   - Initial load: All cells display "—" (dash placeholder)
   - After state change detection: Display timestamp from `metadata.lastModified`
   - Detection: Compare current page task state vs. saved instance state
   - Pattern: Similar to Admin page's Updated column (not populated until first save)

4. **Status Column**
   - Displays status icon (pending/in-progress/completed)
   - From `state.statusButtons` object
   - Uses existing status icon SVGs

### 5. Data Source

**API Endpoint:** `/php/api/restore.php?sessionKey=ABC`

**Data Structure:**
```json
{
  "success": true,
  "data": {
    "sessionKey": "ABC",
    "typeSlug": "camtasia",
    "state": {
      "statusButtons": {
        "status-1.1": "completed",
        "status-1.2": "in_progress",
        "status-2.1": "pending"
      },
      "notes": {
        "notes_1.1": "Task completed successfully",
        "notes_1.2": "Work in progress"
      }
    },
    "metadata": {
      "version": "1.0",
      "created": 1759860614455,
      "lastModified": 1759860709273
    }
  }
}
```

### 6. Launch Mechanism

**From mychecklist.php:**
- Add button: `<button id="reportButton" class="report-button">Report</button>`
- Position: Left of "Save" button in header
- Styling: Match Home page button color scheme
- Behavior: `window.open('/report?session=' + sessionKey, '_blank')`
- Opens in new window/tab

### 7. Task Grouping Logic

**Principle Headers:**
- Group tasks by principle ID (principle-1, principle-2, etc.)
- Display principle title as section header
- Maintain original task order within each principle
- Include manually added rows in their respective principles

**Example Structure:**
```
Principle 1: [Title]
  1.1 Task name          | Notes here  | —           | [icon]
  1.2 Another task       | More notes  | —           | [icon]

Principle 2: [Title]
  2.1 Task name          | Notes here  | —           | [icon]
  2.2 Another task       |             | —           | [icon]
```

### 8. Updated Column Logic (Simplified for V1)

**Initial Implementation:**
- Display `metadata.lastModified` as "Last updated: [timestamp]" under h2
- All "Updated" cells in table show "—" placeholder
- **Future Enhancement:** Per-task timestamp tracking when state changes detected

**Rationale:**
- Simpler initial implementation
- Matches Admin page pattern (no value until first save)
- Can enhance later with per-task change detection

### 9. Styling Requirements

**Button Styling:**
- Report button: Same color as Home page button
- Focus/hover states: Match existing button patterns
- Consistent with header.css button definitions

**Table Styling:**
- Reuse existing table CSS classes where possible
- Principle headers: Bold, larger font
- Task rows: Standard table row styling
- Status icons: Same size/alignment as mychecklist.php

### 10. Accessibility Requirements

- ARIA labels for all interactive elements
- Proper table headers with `scope` attributes
- Keyboard navigation support
- Screen reader friendly status indicators
- Focus management when opening in new window

---

## Data Flow Diagram

```
1. User clicks "Report" button on mychecklist.php
   ↓
2. Opens /report?session=ABC in new window
   ↓
3. report.php renders HTML structure
   ↓
4. report.js fetches checklist data from /php/api/restore.php
   ↓
5. Fetch checklist type JSON to get principle structure
   ↓
6. Build table grouped by principles
   ↓
7. Populate Tasks, Notes, Updated (—), Status columns
   ↓
8. Display "Last updated: [timestamp]" under title
```

---

## Implementation Priority

**Phase 1 (MVP):**
- [x] Add route to router.php
- [ ] Create report.php template
- [ ] Create report.js logic
- [ ] Add Report button to mychecklist.php
- [ ] Basic table rendering with 4 columns
- [ ] Principle grouping
- [ ] Simple "Last updated" timestamp display

**Phase 2 (Enhancement):**
- [ ] Per-task timestamp tracking
- [ ] State change detection logic
- [ ] Refresh button functionality
- [ ] Print-friendly styling
- [ ] Export to PDF feature

---

## Existing Code Leverage Analysis

### 1. PHP Template Structure (from reports.php)

**Reusable Components:**
- `renderHTMLHead()` - Page header with CSS loading
- `renderFooter()` - Creative Commons footer
- `renderCommonScripts()` - JavaScript dependencies
- Header structure pattern with sticky positioning
- Table HTML structure

**Implementation Pattern:**
```php
require_once __DIR__ . '/includes/config.php';
require_once __DIR__ . '/includes/html-head.php';
require_once __DIR__ . '/includes/footer.php';
require_once __DIR__ . '/includes/common-scripts.php';

renderHTMLHead('My Checklist Report');
// ... page content
renderFooter();
renderCommonScripts('report');
```

### 2. Data Fetching (from reports.js and API structure)

**Reusable Pattern:**
```javascript
async loadChecklistData() {
    const apiPath = window.getAPIPath('restore');
    const response = await fetch(`${apiPath}?sessionKey=${this.sessionKey}`);
    const result = await response.json();
    return result.data;
}
```

**API Endpoint:**
- `/php/api/restore.php` - Already exists, returns full checklist state
- Returns: `{ success, data: { sessionKey, typeSlug, state, metadata } }`

### 3. Type Management (from type-manager.js)

**Reusable Methods:**
```javascript
// Get formatted display name
const displayName = await window.TypeManager.formatDisplayName(typeSlug);
// "camtasia" → "Camtasia"

// Get JSON file for principle structure
const jsonFile = await window.TypeManager.getJsonFileName(typeSlug);
// Returns: "camtasia.json"
```

### 4. Date Formatting (from date-utils.js)

**Reusable Functions:**
```javascript
window.formatDateAdmin(timestamp);
// Returns: "10-08-25 2:45 PM"
```

**Usage:**
- "Last updated" subtitle under h1
- "Updated" column cells (future enhancement)

### 5. Status Icons (existing SVG system)

**Pattern from buildPrinciples.js:**
```javascript
const statusImgPath = window.getImagePath('pending.svg');
const imgHTML = `<img src="${statusImgPath}" alt="">`;
```

**Status Values:**
- `pending` → `images/pending.svg`
- `in_progress` → `images/in-progress.svg`
- `completed` → `images/completed.svg`

### 6. CSS Styling (reuse existing classes)

**From Existing Files:**
- `css/header.css` - Sticky header, button styles
- `css/table.css` - Table styling
- `css/admin.css` - Admin table patterns
- `css/status.css` - Status icon styling

**Classes to Reuse:**
```css
.sticky-header
.home-button
.admin-table
.status-button
```

### 7. XSS Protection (from reports.js)

**Reusable Utility:**
```javascript
escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}
```

---

## Detailed Implementation Steps

### Step 1: Add Router Entry

**File:** `/router.php`
**Location:** After `/reports` route (around line 40)

**Code Addition:**
```php
// Report page: /report → /php/report.php
if ($requestUri === '/report' || $requestUri === '/report/') {
    require __DIR__ . '/php/report.php';
    return true;
}
```

### Step 2: Create report.php Template

**File:** `/php/report.php` (NEW)

**Structure:**
1. PHP includes (config, html-head, footer, common-scripts)
2. HTML skeleton with sticky header and Home button
3. Main content area with h1/subtitle placeholders
4. Table structure (4 columns: Tasks, Notes, Updated, Status)
5. Footer
6. Inline script to initialize report
7. Report-specific styles (if needed)

**Key Features:**
- Get `session` parameter from URL
- Validate session key exists
- Pass to JavaScript for data loading
- Server-side renders structure only (data loaded client-side)

### Step 3: Create report.js Module

**File:** `/js/report.js` (NEW)

**Class Structure:**
```javascript
export class UserReportManager {
    constructor(sessionKey) {
        this.sessionKey = sessionKey;
        this.checklistData = null;
        this.principlesData = null;
        this.typeSlug = null;
    }

    async initialize() {
        // 1. Fetch checklist instance data
        // 2. Get type and fetch principle JSON
        // 3. Build title
        // 4. Render table grouped by principles
    }

    async loadChecklistData() {
        // Fetch from /php/api/restore.php
    }

    async loadPrinciplesStructure() {
        // Fetch checklist type JSON
    }

    buildTitle(typeSlug, lastModified) {
        // "My [Type] Checklist"
        // "Last updated: [timestamp]"
    }

    renderTable() {
        // Group tasks by principle
        // Render principle headers + task rows
    }

    createPrincipleHeader(principle) {
        // Row spanning all columns
    }

    createTaskRow(task, savedState) {
        // 4 cells: Task | Notes | Updated | Status
    }
}
```

### Step 4: Task-to-State Mapping Logic

**Challenge:** Match tasks from JSON with saved state

**Approach:**
```javascript
// Default tasks from JSON have IDs like: "1.1", "1.2", "2.1"
// Saved state uses prefixes: "status-1.1", "notes_1.1"

function getTaskStatus(taskId, savedState) {
    const statusKey = `status-${taskId}`;
    return savedState.statusButtons?.[statusKey] || 'pending';
}

function getTaskNotes(taskId, savedState) {
    const notesKey = `notes_${taskId}`;
    return savedState.notes?.[notesKey] || '';
}

// Manually added tasks from state.principleRows
function getManualTasks(principleId, savedState) {
    const rows = savedState.principleRows?.[principleId] || [];
    return rows;
}
```

### Step 5: Principle Grouping Algorithm

```javascript
function groupTasksByPrinciple(principlesData, savedState) {
    const grouped = [];

    principlesData.principles.forEach(principle => {
        const section = {
            id: principle.id,
            title: principle.title,
            tasks: []
        };

        // Add default tasks
        principle.rows.forEach(row => {
            section.tasks.push({
                id: row.id,
                task: row.task,
                notes: getTaskNotes(row.id, savedState),
                status: getTaskStatus(row.id, savedState),
                isManual: false
            });
        });

        // Add manual tasks
        const manualTasks = getManualTasks(principle.id, savedState);
        manualTasks.forEach(task => {
            section.tasks.push({
                ...task,
                isManual: true
            });
        });

        grouped.push(section);
    });

    return grouped;
}
```

### Step 6: Add Report Button to mychecklist.php

**File:** `/php/mychecklist.php`
**Location:** Header buttons section (around line 20-25)

**Update:**
```php
<div class="header-buttons">
    <button id="reportButton" class="report-button">
        <span>Report</span>
    </button>
    <button id="saveButton" class="save-button">
        <span>Save</span>
    </button>
</div>
```

**JavaScript Handler:**
```javascript
document.getElementById('reportButton').addEventListener('click', function() {
    const sessionKey = window.stateManager.sessionKey;
    const reportUrl = window.getPHPPath ?
        window.getPHPPath('report') + '?session=' + sessionKey :
        '/report?session=' + sessionKey;
    window.open(reportUrl, '_blank', 'noopener,noreferrer');
});
```

### Step 7: Updated Column Implementation

**Phase 1 (Simple):**
```javascript
// All cells show "—"
function createUpdatedCell() {
    const td = document.createElement('td');
    td.textContent = '—';
    td.className = 'updated-cell';
    return td;
}

// Display global timestamp under h1
function displayLastUpdated(timestamp) {
    if (timestamp) {
        const formatted = window.formatDateAdmin(timestamp);
        subtitle.textContent = `Last updated: ${formatted}`;
    } else {
        subtitle.textContent = 'Not yet saved';
    }
}
```

---

## Implementation Order

### Session 1: Core Infrastructure
1. ✅ Add specification to user-report-page.md
2. Add `/report` route to router.php
3. Create basic report.php template
4. Create basic report.js with class skeleton
5. Test: Can load `/report?session=ABC`

### Session 2: Data Loading
6. Implement `loadChecklistData()` in report.js
7. Implement `loadPrinciplesStructure()` in report.js
8. Test: Console log shows fetched data
9. Implement `buildTitle()` method
10. Test: Title and subtitle render correctly

### Session 3: Table Rendering
11. Implement `renderTable()` method
12. Implement `createPrincipleHeader()` method
13. Implement `createTaskRow()` method
14. Implement task-to-state mapping utilities
15. Test: Table renders with all data

### Session 4: Integration
16. Add Report button to mychecklist.php header
17. Add button click handler
18. Test: Button opens report in new window
19. Add CSS styling for button (if needed)
20. Test: Styling matches design requirements

### Session 5: Polish & Testing
21. Add error handling for missing session
22. Add loading indicator
23. Add empty state handling
24. Accessibility audit (ARIA labels, keyboard nav)
25. Cross-browser testing

---

## Testing Checklist

### Functional Testing
- [ ] `/report` route resolves correctly
- [ ] Report opens in new window from mychecklist.php
- [ ] Session key passed correctly via URL
- [ ] Data fetches successfully from API
- [ ] Type name displays correctly in h1
- [ ] Last updated timestamp shows correct format
- [ ] Tasks grouped by principle correctly
- [ ] Default tasks display in order
- [ ] Manual tasks display in their principle groups
- [ ] Notes display correctly
- [ ] Status icons display correctly
- [ ] Updated column shows "—" placeholder

### Edge Cases
- [ ] Invalid session key → error handling
- [ ] No notes → empty cells
- [ ] No manual rows → only default tasks
- [ ] Never saved → "Not yet saved" subtitle
- [ ] Different checklist types → correct JSON loaded

### Accessibility
- [ ] Keyboard navigation works
- [ ] Screen reader announces table structure
- [ ] Status icons have proper alt text
- [ ] Focus visible on all interactive elements
- [ ] Table headers properly associated

### Styling
- [ ] Report button matches Home button color
- [ ] Table responsive on mobile
- [ ] Principle headers visually distinct
- [ ] Consistent with existing design

---

## Key Differences: System Reports vs. User Report

| Aspect | System Reports (`/reports`) | User Report (`/report`) |
|--------|---------------------------|------------------------|
| **Scope** | All checklists | Single checklist |
| **URL** | `/reports` | `/report?session=ABC` |
| **Data Source** | `list-detailed.php` | `restore.php` |
| **Table Columns** | Type, Created, Key, Status, Progress | Tasks, Notes, Updated, Status |
| **Grouping** | Filter buttons (status-based) | Principle headers |
| **Access** | Admin page link | Report button on mychecklist.php |
| **Target User** | Admin/instructor | End user |
| **JavaScript** | `reports.js` (`ReportsManager`) | `report.js` (`UserReportManager`) |

---

# REFERENCE: System-wide Reports Feature Documentation

**Note:** The following section documents the existing `/php/reports.php` (system-wide admin reports) for reference purposes. The user report feature above is a separate, distinct feature.

---

# Reports Feature - Technical Documentation

**Document Type:** AI Agent Reference
**Last Updated:** October 8, 2025
**Component:** Reports Page (`/php/reports.php`)
**Purpose:** Complete technical analysis of the Reports feature for AI agent consumption

---

# Overview

## Executive Summary

The Reports feature provides a comprehensive dashboard for viewing all saved checklists with:
- **Real-time status calculation** (Completed, In Progress, Pending)
- **Progress tracking** (completed tasks / total tasks)
- **Interactive filtering** by status
- **Sortable table** with clickable links to each checklist
- **Responsive UI** with accessible markup

---

# File-by-File Code Analysis

## File 1: `/php/reports.php` (Main Page Template)

**Type:** PHP Template
**Role:** Server-side rendering of Reports page HTML structure
**Dependencies:** config.php, html-head.php, footer.php, common-scripts.php

### Section A: PHP Dependencies (Lines 2-5)
```php
require_once __DIR__ . '/includes/config.php';
require_once __DIR__ . '/includes/html-head.php';
require_once __DIR__ . '/includes/footer.php';
require_once __DIR__ . '/includes/common-scripts.php';
```
- **`config.php`**: Loads environment configuration (`$basePath`, `$envConfig`)
- **`html-head.php`**: Renders HTML head with CSS files and environment injection
- **`footer.php`**: Renders Creative Commons footer
- **`common-scripts.php`**: Loads JavaScript dependencies

### Section B: Page Header (Lines 11-20)
```php
<header class="sticky-header">
    <h1>Reports</h1>
    <div class="header-buttons">
        <button id="homeButton" class="home-button">Home</button>
        <button id="refreshButton" class="header-button">Refresh</button>
    </div>
</header>
```
- **Sticky header**: Fixed position at top
- **Home button**: Navigation back to landing page
- **Refresh button**: Reloads report data without page refresh

### Section C: Filter Buttons (Lines 25-53)
```php
<div class="filter-group" role="group" aria-label="Filter checklists by status">
    <button id="filter-completed" class="filter-button active"
            data-filter="completed" aria-pressed="true">
        <span class="filter-label">Completed</span>
        <span class="filter-count" id="count-completed">0</span>
    </button>
    <!-- ... similar for pending and in-progress -->
</div>
```
**Features:**
- **ARIA attributes**: `role="group"`, `aria-pressed` for accessibility
- **Count badges**: Dynamic counters updated by JavaScript
- **Active state**: One filter active at a time
- **Default**: "Completed" filter active on page load

### Section D: Reports Table (Lines 56-70)
```php
<table class="admin-table reports-table" aria-labelledby="reports-caption">
    <thead>
        <tr>
            <th class="admin-type-cell">Type</th>
            <th class="admin-date-cell">Created</th>
            <th class="admin-instance-cell">Key</th>
            <th class="reports-status-cell">Status</th>
            <th class="reports-progress-cell">Progress</th>
        </tr>
    </thead>
    <tbody><!-- Populated by JavaScript --></tbody>
</table>
```
**Columns:**
1. **Type**: Checklist type (Word, Excel, Camtasia, etc.)
2. **Created**: Timestamp when checklist was created
3. **Key**: 3-character session identifier (clickable link)
4. **Status**: Badge showing Completed/Pending/In Progress
5. **Progress**: Visual progress bar (X/Y tasks completed)

### Section E: JavaScript Initialization (Lines 82-140)
```javascript
import { ReportsManager } from '/js/reports.js';

let reportsManager;

document.addEventListener('DOMContentLoaded', function() {
    reportsManager = new ReportsManager();
    reportsManager.initialize();

    // Home button navigation
    homeButton.addEventListener('click', function() {
        window.location.href = window.getPHPPath('home.php');
    });

    // Refresh button functionality
    refreshButton.addEventListener('click', function() {
        refreshData();
    });
});
```
**Functionality:**
- **ES6 module import**: Imports `ReportsManager` class
- **Singleton pattern**: Single instance manages all reports
- **Event delegation**: Sets up button handlers
- **Path utilities**: Uses `window.getPHPPath()` for environment-aware URLs

### Section F: Refresh Function (Lines 112-138)
```javascript
function refreshData() {
    refreshButton.setAttribute('aria-busy', 'true');
    refreshButton.disabled = true;

    reportsManager.loadChecklists().then(() => {
        refreshButton.setAttribute('aria-busy', 'false');
        refreshButton.disabled = false;
    }).catch(error => {
        // Error handling with modal
        window.simpleModal.error('Refresh Failed', 'Failed to refresh...');
    });
}
```
**Features:**
- **Accessibility**: Uses `aria-busy` attribute
- **Disabled state**: Prevents double-clicks during loading
- **Promise-based**: Async/await pattern
- **Error handling**: Shows modal on failure

### Section G: Inline CSS Styles (Lines 148-284)
Embedded styles for Reports-specific components:

**Filter Buttons:**
- Flexbox layout with gap
- Active state changes background color based on status
- Hover effects
- Focus outline for keyboard navigation

**Status Badges:**
- Color-coded by status (green/orange/blue)
- Rounded corners
- Consistent padding

**Progress Bars:**
- Flexbox container
- Visual bar with animated fill
- Percentage-based width
- Text showing "X/Y" completed

---

## File 2: `/js/reports.js` (Client-Side Logic)

**Type:** JavaScript ES6 Module
**Role:** Manages all reports functionality (data loading, filtering, rendering)
**Exports:** ReportsManager class

### Section A: Class Structure
```javascript
export class ReportsManager {
    constructor() {
        this.allChecklists = [];
        this.currentFilter = 'completed';
        this.filterButtons = null;
        this.tableBody = null;
    }
}
```
**Properties:**
- **`allChecklists`**: Array of all loaded checklist data
- **`currentFilter`**: Currently active filter ('completed', 'pending', 'in-progress')
- **`filterButtons`**: Cached DOM references
- **`tableBody`**: Cached table body element

### Section B: Initialization (Lines 17-34)
```javascript
initialize() {
    // Cache DOM elements
    this.tableBody = document.querySelector('.reports-table tbody');
    this.filterButtons = document.querySelectorAll('.filter-button');

    // Set up filter button event listeners
    this.filterButtons.forEach(button => {
        button.addEventListener('click', (e) => {
            this.handleFilterClick(e.currentTarget);
        });
    });

    // Load initial data
    this.loadChecklists();
}
```
**DOM Caching Strategy:**
- Stores references to avoid repeated queries
- Improves performance for dynamic updates

### Section C: Filter Handling (Lines 36-52)
```javascript
handleFilterClick(button) {
    const filter = button.getAttribute('data-filter');

    // Update active state
    this.filterButtons.forEach(btn => {
        btn.classList.remove('active');
        btn.setAttribute('aria-pressed', 'false');
    });

    button.classList.add('active');
    button.setAttribute('aria-pressed', 'true');

    this.currentFilter = filter;
    this.renderTable();
}
```
**Accessibility Features:**
- Updates `aria-pressed` state
- Single active filter at a time
- Re-renders table with new filter

### Section D: Data Loading (Lines 54-96)
```javascript
async loadChecklists() {
    const apiPath = window.getAPIPath('list-detailed');
    const response = await fetch(apiPath);

    if (!response.ok) {
        throw new Error(`API responded with status: ${response.status}`);
    }

    const responseData = await response.json();

    // Extract instances from API response
    const instances = Array.isArray(responseData?.data)
        ? responseData.data
        : [];

    // Process each checklist to add calculated status
    this.allChecklists = instances.map(checklist => ({
        ...checklist,
        calculatedStatus: this.calculateStatus(checklist.state?.statusButtons || {})
    }));

    this.updateFilterCounts();
    this.renderTable();
}
```
**Key Steps:**
1. **Fetch from API**: Uses `list-detailed.php` endpoint
2. **Extract data**: Handles standardized `{ success, data, timestamp }` format
3. **Calculate status**: Adds `calculatedStatus` property to each checklist
4. **Update UI**: Refreshes counts and table

### Section E: Status Calculation (Lines 98-130)
```javascript
calculateStatus(statusButtons) {
    if (!statusButtons || typeof statusButtons !== 'object') {
        return 'pending';
    }

    const statuses = Object.values(statusButtons);

    if (statuses.length === 0) {
        return 'pending';
    }

    const completedCount = statuses.filter(s => s === 'completed').length;
    const inProgressCount = statuses.filter(s => s === 'in_progress').length;
    const total = statuses.length;

    // All completed
    if (completedCount === total) {
        return 'completed';
    }

    // Some completed or in progress
    if (completedCount > 0 || inProgressCount > 0) {
        return 'in-progress';
    }

    // All pending
    return 'pending';
}
```
**Status Logic:**
- **Completed**: ALL tasks are "completed"
- **In Progress**: At least ONE task is "completed" or "in_progress"
- **Pending**: ALL tasks are "pending" (or no tasks exist)

### Section F: Filter Count Update (Lines 132-150)
```javascript
updateFilterCounts() {
    const counts = {
        'completed': 0,
        'pending': 0,
        'in-progress': 0
    };

    this.allChecklists.forEach(checklist => {
        const status = checklist.calculatedStatus;
        if (counts.hasOwnProperty(status)) {
            counts[status]++;
        }
    });

    // Update count badges
    Object.keys(counts).forEach(status => {
        const countElement = document.getElementById(`count-${status}`);
        if (countElement) {
            countElement.textContent = counts[status];
        }
    });
}
```
**Updates badges** with current counts for each status category

### Section G: Table Rendering (Lines 152-185)
```javascript
async renderTable() {
    const filtered = this.allChecklists.filter(
        checklist => checklist.calculatedStatus === this.currentFilter
    );

    this.tableBody.innerHTML = '';

    // Empty state
    if (filtered.length === 0) {
        const row = document.createElement('tr');
        const cell = document.createElement('td');
        cell.colSpan = 5;
        cell.textContent = `No ${this.currentFilter.replace('-', ' ')} checklists found`;
        cell.style.textAlign = 'center';
        row.appendChild(cell);
        this.tableBody.appendChild(row);
        return;
    }

    // Render each checklist
    for (const checklist of filtered) {
        const row = await this.createChecklistRow(checklist);
        this.tableBody.appendChild(row);
    }

    this.updateStatusMessage(`Showing ${filtered.length} ${filterLabel} checklist(s)`);
}
```
**Features:**
- Filters by current status
- Empty state message
- Async row creation
- Status footer update

### Section H: Row Creation (Lines 187-226)
```javascript
async createChecklistRow(checklist) {
    const row = document.createElement('tr');
    row.setAttribute('data-session-key', checklist.sessionKey);

    // Format type using TypeManager
    const typeSlug = checklist.typeSlug || 'unknown';
    let formattedType = typeSlug;

    if (window.TypeManager?.formatDisplayName) {
        formattedType = await window.TypeManager.formatDisplayName(typeSlug);
    }

    // Format dates
    const createdDate = checklist.metadata?.created || checklist.timestamp;
    const formattedDate = this.formatDate(createdDate);

    // Calculate progress
    const progress = this.calculateProgress(checklist.state?.statusButtons || {});

    // Build row HTML
    row.innerHTML = `
        <td>${this.escapeHtml(formattedType)}</td>
        <td>${this.escapeHtml(formattedDate)}</td>
        <td>${this.createInstanceLink(checklist.sessionKey, typeSlug)}</td>
        <td>${this.createStatusBadge(checklist.calculatedStatus)}</td>
        <td>${this.createProgressBar(progress.completed, progress.total,
                                     checklist.calculatedStatus)}</td>
    `;

    return row;
}
```
**Row Construction:**
1. **Type formatting**: Uses `TypeManager` to get display name
2. **Date formatting**: Uses centralized date utilities
3. **Progress calculation**: Counts completed vs total tasks
4. **XSS protection**: All output is escaped

### Section I: Progress Calculation (Lines 228-239)
```javascript
calculateProgress(statusButtons) {
    if (!statusButtons || typeof statusButtons !== 'object') {
        return { completed: 0, total: 0 };
    }

    const statuses = Object.values(statusButtons);
    const total = statuses.length;
    const completed = statuses.filter(s => s === 'completed').length;

    return { completed, total };
}
```
**Returns object** with completed count and total count

### Section J: HTML Component Creators (Lines 241-296)

**Instance Link:**
```javascript
createInstanceLink(sessionKey, typeSlug) {
    const basePath = window.ENV?.basePath || '';
    const href = `${basePath}/?=${sessionKey}`;

    return `<a href="${this.escapeHtml(href)}"
               class="instance-link"
               target="_blank"
               rel="noopener noreferrer"
               aria-label="Open checklist ${sessionKey} in new window">
               ${this.escapeHtml(sessionKey)}
            </a>`;
}
```
- Opens in new window
- Uses minimal URL format `/?=ABC`
- Includes ARIA label

**Status Badge:**
```javascript
createStatusBadge(status) {
    const labels = {
        'completed': 'Completed',
        'pending': 'Pending',
        'in-progress': 'In Progress'
    };

    const label = labels[status] || status;
    return `<span class="status-badge ${status}">${this.escapeHtml(label)}</span>`;
}
```
- Color-coded CSS classes
- Human-readable labels

**Progress Bar:**
```javascript
createProgressBar(completed, total, status) {
    if (total === 0) {
        return '<span class="progress-text">—</span>';
    }

    const percentage = (completed / total) * 100;

    return `
        <div class="progress-container">
            <div class="progress-bar">
                <div class="progress-fill ${status}" style="width: ${percentage}%"></div>
            </div>
            <span class="progress-text">${completed}/${total}</span>
        </div>
    `;
}
```
- Percentage-based width
- Visual bar + text
- Status-based coloring

### Section K: Utility Functions (Lines 298-329)

**Date Formatting:**
```javascript
formatDate(timestamp) {
    if (!timestamp) return '—';

    // Use global formatter if available
    if (window.formatDateAdmin) {
        return window.formatDateAdmin(timestamp);
    }

    // Fallback: MM-DD-YY HH:MM AM/PM
    const date = new Date(timestamp);
    return date.toLocaleString('en-US', {
        month: '2-digit',
        day: '2-digit',
        year: '2-digit',
        hour: 'numeric',
        minute: '2-digit',
        hour12: true
    });
}
```

**XSS Protection:**
```javascript
escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}
```
- Uses DOM to escape HTML entities
- Prevents XSS injection

---

## File 3: `/php/api/list-detailed.php` (Data API)

**Type:** PHP API Endpoint
**Role:** Returns all saved checklists with full state data for status calculation
**HTTP Method:** GET
**Response Format:** JSON

### Key Differences from `list.php`:
```php
// list.php excludes state
'state' => [] // Empty

// list-detailed.php includes full state
'state' => $data['state'] ?? []  // Full statusButtons data
```

### Code Flow:
```php
// 1. Get all JSON files
$savesDir = dirname(saves_path_for('dummy')) . '/';
$files = glob($savesDir . '*.json');

// 2. Read each file
foreach ($files as $file) {
    $json = file_get_contents($file);
    $data = json_decode($json, true);

    // 3. Extract session key from filename
    $sessionKey = basename($file, '.json');

    // 4. Resolve typeSlug (with fallback logic)
    $resolvedSlug = $data['typeSlug'] ?? null;
    if (!$resolvedSlug && isset($data['type'])) {
        $resolvedSlug = TypeManager::convertDisplayNameToSlug($data['type']);
    }

    // 5. Build instance object
    $instance = [
        'sessionKey' => $sessionKey,
        'timestamp' => $fileCreationTime,
        'created' => $data['metadata']['created'] ?? $fileCreationTime,
        'typeSlug' => $resolvedSlug,
        'state' => $data['state'] ?? [],  // INCLUDES FULL STATE
        'metadata' => [...]
    ];

    $instances[] = $instance;
}

// 6. Sort by timestamp (newest first)
usort($instances, function($a, $b) {
    return $b['timestamp'] - $a['timestamp'];
});

// 7. Return standardized response
send_success($instances);
```

**Response Format:**
```json
{
  "success": true,
  "timestamp": 1728403200,
  "data": [
    {
      "sessionKey": "CAM",
      "timestamp": 1759860614455,
      "created": 1759860614455,
      "typeSlug": "camtasia",
      "state": {
        "statusButtons": {
          "status-1.1": "completed",
          "status-1.2": "in_progress",
          "status-2.1": "pending"
        },
        "notes": {...},
        "sidePanel": {...}
      },
      "metadata": {
        "version": "1.0",
        "created": 1759860614455,
        "lastModified": 1759860709273
      }
    }
  ]
}
```

---

## File 4: `/php/includes/api-utils.php` (API Helpers)

**Type:** PHP Utility Library
**Role:** Standardized API response formatting and error handling
**Used By:** All API endpoints

### Functions:

**`send_success($payload)`**
```php
function send_success($payload = []) {
    $base = [
        'success' => true,
        'timestamp' => time()
    ];

    // Wrap payload in 'data' property
    if (!empty($payload)) {
        $base['data'] = $payload;
    }

    send_json($base);
}
```
**Ensures consistent API response shape**

**`send_error($message, $code)`**
```php
function send_error($message, $code = 400) {
    http_response_code($code);
    send_json([
        'success' => false,
        'message' => $message,
        'timestamp' => time()
    ]);
}
```
**Handles error responses** with HTTP status codes

---

## File 5: `/js/date-utils.js` (Date Formatting)

**Type:** JavaScript Utility Module
**Role:** Centralized date formatting functions
**Exports:** formatDateShort, formatDateLong, formatDateAdmin

### Functions:

**`formatDateShort(date)`** - Returns "MM-DD-YY"
```javascript
function formatDateShort(date = null) {
    const d = date ? (typeof date === 'number' ? new Date(date) : date) : new Date();
    return d.toLocaleDateString('en-US', {
        month: '2-digit',
        day: '2-digit',
        year: '2-digit'
    }).replace(/\//g, '-');
}
```

**`formatDateAdmin(timestamp)`** - Returns "MM-DD-YY HH:MM AM/PM"
```javascript
function formatDateAdmin(timestamp) {
    const date = new Date(timestamp);
    const dateStr = formatDateShort(date);
    const timeStr = date.toLocaleTimeString('en-US', {
        hour: 'numeric',
        minute: '2-digit',
        hour12: true
    });
    return `${dateStr} ${timeStr}`;
}
```

**Global Exposure:**
```javascript
if (typeof window !== 'undefined') {
    window.formatDateAdmin = formatDateAdmin;
}
```
Makes functions available globally

---

## File 6: `/php/includes/type-manager.php` (Server-Side Type Handling)

**Type:** PHP Static Class
**Role:** Type validation, slug/display name conversion
**Configuration Source:** `/config/checklist-types.json`

### Key Methods:

**`getAvailableTypes()`**
```php
public static function getAvailableTypes() {
    $config = self::loadConfig();
    return array_keys($config['types'] ?? []);
}
// Returns: ['word', 'powerpoint', 'excel', 'docs', 'slides', 'camtasia', 'dojo']
```

**`formatDisplayName($typeSlug)`**
```php
public static function formatDisplayName($typeSlug) {
    $config = self::loadConfig();
    $typeData = $config['types'][$typeSlug] ?? null;
    if ($typeData && isset($typeData['displayName'])) {
        return $typeData['displayName'];
    }
    return ucfirst($typeSlug);
}
// 'powerpoint' -> 'PowerPoint'
```

**`convertDisplayNameToSlug($displayName)`**
```php
public static function convertDisplayNameToSlug($displayName) {
    $config = self::loadConfig();
    foreach (($config['types'] ?? []) as $slug => $data) {
        if (strcasecmp($data['displayName'], $displayName) === 0) {
            return $slug;
        }
    }
    return self::getDefaultType();
}
// 'PowerPoint' -> 'powerpoint'
```

---

## File 7: `/config/checklist-types.json` (Type Configuration)

**Type:** JSON Configuration File
**Role:** Central source of truth for all checklist type definitions
**Used By:** TypeManager (PHP & JS)

```json
{
  "types": {
    "word": {
      "displayName": "Word",
      "jsonFile": "word.json",
      "buttonId": "word",
      "category": "Microsoft"
    },
    "powerpoint": {...},
    "excel": {...},
    "docs": {...},
    "slides": {...},
    "camtasia": {...},
    "dojo": {...}
  },
  "defaultType": "camtasia",
  "categories": {
    "Microsoft": ["word", "powerpoint", "excel"],
    "Google": ["docs", "slides"],
    "Other": ["camtasia", "dojo"]
  }
}
```

**Configuration Structure:**
- `types`: Object mapping slugs to type metadata
- `defaultType`: Fallback type when validation fails
- `categories`: Grouped types by vendor (Microsoft, Google, Other)

**Use Cases:**
- Type validation
- Display name formatting
- JSON file lookup
- Category grouping

---

# Data Flow & Logic

## Data Flow Diagram

```
1. User loads /reports
   ↓
2. reports.php renders HTML template
   ↓
3. ReportsManager.initialize() runs
   ↓
4. loadChecklists() fetches /php/api/list-detailed.php
   ↓
5. list-detailed.php reads all *.json files from /saves/
   ↓
6. Returns array with full state.statusButtons data
   ↓
7. ReportsManager calculates status for each checklist
   ↓
8. Updates filter counts (completed: X, pending: Y, in-progress: Z)
   ↓
9. Renders table with filtered results
   ↓
10. User clicks filter → re-render table
11. User clicks refresh → re-fetch from API
12. User clicks row link → opens checklist in new tab
```

## Status Calculation Logic

```
Given statusButtons: {
  "status-1.1": "completed",
  "status-1.2": "in_progress",
  "status-2.1": "pending",
  "status-2.2": "completed"
}

Count:
- completed: 2
- in_progress: 1
- pending: 1
- total: 4

Logic:
IF completed === total THEN "completed"
ELSE IF (completed > 0 OR in_progress > 0) THEN "in-progress"
ELSE "pending"

Result: "in-progress" (because 2 > 0)
```

---

# Feature Summary

## Key Capabilities

- **Real-time filtering**: No page reload needed, client-side filtering
- **Status auto-calculation**: Based on actual task completion state
- **Progress visualization**: Visual progress bar + numeric fraction (X/Y)
- **Accessibility**: ARIA labels, keyboard navigation, screen reader support
- **Security**: XSS protection via HTML escaping on all dynamic content
- **Error handling**: Graceful degradation with modal error messages
- **Responsive design**: Mobile-friendly, works on all screen sizes
- **Environment-aware**: Uses `basePath` for deployment flexibility

## Technology Stack

- **Frontend**: Vanilla JavaScript (ES6 modules), no framework dependencies
- **Backend**: PHP 8.x with JSON file storage
- **API**: RESTful JSON endpoints with standardized response format
- **Styling**: CSS with BEM-like naming conventions
- **Accessibility**: WCAG 2.1 compliant with ARIA attributes

## Integration Points

- Uses `path-utils.js` for environment-aware URL generation
- Uses `TypeManager` (PHP & JS) for type formatting consistency
- Uses `date-utils.js` for standardized date formatting
- Uses `simple-modal.js` for error dialogs
- Reads from `/saves/*.json` for checklist data

---

**End of Document**
