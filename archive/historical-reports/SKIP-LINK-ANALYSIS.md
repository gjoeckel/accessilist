# SKIP LINK IMPLEMENTATION GUIDE

**WCAG 2.4.1 Bypass Blocks (Level A)**
**Purpose**: Allow keyboard users to skip repetitive navigation and go directly to main content

---

## WCAG GUIDANCE SUMMARY

### Best Practices:
1. Skip link must be **first focusable element** on page
2. Target should be **primary content** area (not header/nav)
3. Target needs `tabindex="-1"` if not naturally focusable
4. Skip link should be **visible on focus** (not hidden)
5. Multiple skip links allowed for complex layouts (skip to nav, skip to content, etc.)

### Target Element Criteria:
- ✅ First heading in main content (`<h2>` with `tabindex="-1"`)
- ✅ Main content container (`<main id="main-content">`)
- ✅ First interactive element in content area
- ❌ Header elements (defeats purpose)
- ❌ Non-focusable elements without tabindex

---

## SKIP LINK TARGET ANALYSIS BY PAGE

### 1. home.php (Landing Page)

**Page Structure**:
- Header with h1 + buttons
- Main content: Checklist selection groups

**Current State**:
- No skip link ❌
- `<main role="main">` exists (line 23)
- First content: `<h2>Microsoft</h2>` (line 26)

**Recommended Skip Target**: `#main-content` on `<main>` element

**Implementation**:
```html
<!-- Before <header> -->
<a href="#main-content" class="skip-link">Skip to checklist selection</a>

<!-- Update main -->
<main role="main" id="main-content" tabindex="-1">
```

**Focus Flow**: Skip link → Main content (checklist groups)

---

### 2. admin.php (Admin Dashboard)

**Page Structure**:
- Header with h1 + Home + Refresh buttons
- Main content: Checklists table

**Current State**:
- No skip link ❌
- `<main role="main">` exists (line 26)
- `<h2 id="admin-caption" tabindex="-1">` ✅ PERFECT TARGET (line 28)

**Recommended Skip Target**: `#admin-caption` (already has `tabindex="-1"`)

**Implementation**:
```html
<!-- Before <header> -->
<a href="#admin-caption" class="skip-link">Skip to checklists table</a>
```

**Focus Flow**: Skip link → h2 caption → Table content

**Note**: Best implementation - h2 already configured for focus!

---

### 3. reports.php (Systemwide Reports)

**Page Structure**:
- Header with h1 + Home + Refresh buttons
- Main content: Filter buttons + h2 + Table

**Current State**:
- No skip link ❌
- `<main role="main">` exists (line 27)
- `<h2 id="reports-caption" tabindex="-1">` ✅ PERFECT TARGET (line 70)
- Filter buttons before h2 (lines 30-67)

**Recommended Skip Target**: `#reports-caption` (already has `tabindex="-1"`)

**Alternative**: Skip to `#filter-completed` to include filter controls

**Implementation** (Option 1 - Skip to h2):
```html
<!-- Before <header> -->
<a href="#reports-caption" class="skip-link">Skip to reports table</a>
```

**Implementation** (Option 2 - Skip to filters):
```html
<!-- Before <header> -->
<a href="#filter-completed" class="skip-link">Skip to reports filters</a>
```

**Recommendation**: Use **Option 1** (`#reports-caption`) - filters are secondary controls

**Focus Flow**: Skip link → h2 caption → Filter controls nearby

---

### 4. report.php (User Report - Single Checklist)

**Page Structure**:
- Header with h1 + Home + Refresh buttons
- Main content: Filter buttons + h2 + Table

**Current State**:
- No skip link ❌
- `<main role="main">` exists (line 51)
- `<h2 id="report-caption" tabindex="-1">` ✅ PERFECT TARGET (line 94)
- Filter buttons before h2 (lines 54-91)

**Recommended Skip Target**: `#report-caption` (already has `tabindex="-1"`)

**Implementation**:
```html
<!-- Before <header> -->
<a href="#report-caption" class="skip-link">Skip to report table</a>
```

**Focus Flow**: Skip link → h2 caption → Filter controls nearby

---

### 5. mychecklist.php (Interactive Checklist)

**Page Structure**:
- Header with h1 + Home + Save + Report buttons
- Side panel navigation (4 checkpoint links)
- Main content: Principles sections with tables

**Current State**:
- No skip link ❌
- `<main role="main" aria-label="Accessibility checklist content">` (line 68)
- No h2 with tabindex in main content
- Dynamic content added by JS

**Recommended Skip Target**: `#main-content` on `<main>` element

**Alternative**: `#content` div (line 70)

**Implementation**:
```html
<!-- Before <header> -->
<a href="#main-content" class="skip-link">Skip to checklist</a>

<!-- Update main -->
<main role="main" id="main-content" tabindex="-1" aria-label="Accessibility checklist content">
```

**Focus Flow**: Skip link → Main content (bypasses both header AND side panel)

**Note**: Skips 6 elements (header + 4 side panel links + toggle)

---

### 6. checklist-report.php (Legacy Report Page)

**Page Structure**:
- Header with h1 + Back link
- Main content: h2 + Table

**Current State**:
- No skip link ❌
- `<main role="main" aria-label="Accessibility report content">` (line 29)
- `<h2 id="report-caption" tabindex="-1">` ✅ PERFECT TARGET (line 33)

**Recommended Skip Target**: `#report-caption` (already has `tabindex="-1"`)

**Implementation**:
```html
<!-- Before <header> -->
<a href="#report-caption" class="skip-link">Skip to report table</a>
```

**Focus Flow**: Skip link → h2 caption → Table content

---

## SUMMARY TABLE

| Page | Skip Link Text | Target Element | Target ID | Has tabindex? | Elements Skipped |
|------|---------------|----------------|-----------|---------------|------------------|
| home.php | "Skip to checklist selection" | `<main>` | `#main-content` | Add `-1` | 3 (h1 + 2 buttons) |
| admin.php | "Skip to checklists table" | `<h2>` | `#admin-caption` | ✅ Yes | 3 (h1 + Home + Refresh) |
| reports.php | "Skip to reports table" | `<h2>` | `#reports-caption` | ✅ Yes | 3 (h1 + Home + Refresh) |
| report.php | "Skip to report table" | `<h2>` | `#report-caption` | ✅ Yes | 3 (h1 + Home + Refresh) |
| mychecklist.php | "Skip to checklist" | `<main>` | `#main-content` | Add `-1` | 6 (header + side panel) |
| checklist-report.php | "Skip to report table" | `<h2>` | `#report-caption` | ✅ Yes | 2 (h1 + Back link) |

---

## IMPLEMENTATION NOTES

### Pages with Existing Targets (Easy):
- ✅ admin.php
- ✅ reports.php
- ✅ report.php
- ✅ checklist-report.php

**Action**: Only need to add skip link - targets already configured!

### Pages Needing Target Configuration:
- ⚠️ home.php - Add `id="main-content"` and `tabindex="-1"` to `<main>`
- ⚠️ mychecklist.php - Add `id="main-content"` and `tabindex="-1"` to `<main>`

---

## SKIP LINK CSS REQUIREMENTS

**WCAG 2.4.1 requires skip link to be:**
- Visible when focused ✅
- First in tab order ✅
- Actually functional ✅

**Recommended CSS** (add to base.css or header.css):

```css
.skip-link {
    position: absolute;
    top: -40px;
    left: 0;
    background: #000;
    color: #fff;
    padding: 8px 16px;
    text-decoration: none;
    z-index: 10000;
    font-weight: bold;
}

.skip-link:focus {
    top: 0;
    outline: 2px solid #2196F3;
    outline-offset: 2px;
}
```

**Behavior**: Hidden by default, visible when focused via keyboard

---

## RECOMMENDED IMPLEMENTATION ORDER

### Step 1: Add CSS (header.css or base.css)
Add `.skip-link` styles

### Step 2: Update Pages with Existing Targets
1. admin.php - Add skip link → `#admin-caption`
2. reports.php - Add skip link → `#reports-caption`
3. report.php - Add skip link → `#report-caption`
4. checklist-report.php - Add skip link → `#report-caption`

### Step 3: Configure New Targets + Add Skip Links
5. home.php - Add `id="main-content" tabindex="-1"` to main, add skip link
6. mychecklist.php - Add `id="main-content" tabindex="-1"` to main, add skip link

---

**Total Implementation**: 6 skip links across 6 pages
**Estimated Time**: 30-45 minutes
**WCAG Impact**: Resolves Critical Issues #1 and #2

