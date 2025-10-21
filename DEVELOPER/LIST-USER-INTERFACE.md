# AccessiList - List User Interface

**Document Type:** Backend Developer Code Audit Reference
**Last Updated:** October 20, 2025
**Purpose:** Complete UI component architecture and interaction patterns
**Branch:** cleanup-and-scope-server-files

---

## 📋 Table of Contents

- [AccessiList - List User Interface](#accessilist---list-user-interface)
  - [📋 Table of Contents](#-table-of-contents)
  - [🎯 Overview](#-overview)
    - [Key Components](#key-components)
  - [🏠 Home Page](#-home-page)
  - [✅ Main Checklist Interface](#-main-checklist-interface)
  - [🧭 Side Panel Navigation](#-side-panel-navigation)
  - [🪟 Modal System](#-modal-system)
  - [🔨 Build Functions](#-build-functions)
  - [🎨 UI Components](#-ui-components)
  - [📚 AEIT Page](#-aeit-page)
  - [♿ Accessibility](#-accessibility)
  - [📚 Related Documentation](#-related-documentation)

---

## 🎯 Overview

The List User Interface encompasses all user-facing components for checklist interaction, including the home page (type selection), main checklist interface, side panel navigation, modal dialogs, and AEIT information page.

### Key Components
- **Home Page** (`php/home.php`) - Landing page with 11 checklist types
- **Main Checklist** (`php/list.php`) - Primary checklist interface
- **Side Panel** (`js/side-panel.js`) - Checkpoint navigation
- **Modals** (`js/simple-modal.js`, `js/ModalActions.js`) - Dialogs and confirmations
- **Build Functions** (`js/buildCheckpoints.js`, `js/buildDemo.js`, `js/addRow.js`) - Dynamic content generation
- **UI Components** (`js/ui-components.js`) - Reusable components
- **AEIT Page** (`php/aeit.php`) - Accessibility information

---

## 🏠 Home Page

**File:** `php/home.php`

**Purpose:** Landing page for checklist type selection (11 types)

**Layout:**
- Tutorial group: demo
- Microsoft group: word, powerpoint, excel
- Google group: docs, slides
- Other group: camtasia, dojo

**Interaction:** Button click → Navigate to `/list?type=X`

**See:** `php/home.php` for complete template

---

## ✅ Main Checklist Interface

**File:** `php/list.php`

**Components:**
- Loading overlay
- Sticky header (Home, Save, Report buttons)
- Side panel (checkpoint navigation + toggle)
- Main content (checkpoint sections with tables)
- Footer (status div + optional AEIT link)

**Table Structure:**
- Checkpoint sections (heading + Add Row button)
- Task rows: Task text | Status button | Notes textarea | Reset button

**See:** `php/list.php` and `js/buildCheckpoints.js` for complete structure

---

## 🧭 Side Panel Navigation

**File:** `js/side-panel.js`

**Features:**
- Numbered checkpoint buttons
- Show All/One toggle
- Panel collapse/expand (◀/▶)
- Scroll-to-checkpoint with buffer update

**See:** `js/side-panel.js` (SidePanel class)

---

## 🪟 Modal System

**Files:** `js/simple-modal.js`, `js/ModalActions.js`

**Types:** Success (green), Error (red), Info (blue), Confirm (yes/no)

**Methods:** showSuccess(), showError(), showInfo(), confirmAction()

**See:** `js/simple-modal.js` and `js/ModalActions.js` for implementation

---

## 🔨 Build Functions

**buildCheckpoints.js:** Generate checklist DOM from JSON template (fires `contentBuilt` event)
**buildDemo.js:** Same as buildCheckpoints but with pre-filled demo data
**addRow.js:** Dynamically add task rows to checkpoint tables

**See:** `js/buildCheckpoints.js`, `js/buildDemo.js`, `js/addRow.js`

---

## 🎨 UI Components

**File:** `js/ui-components.js` - Reusable component library

---

## 📚 AEIT Page

**File:** `php/aeit.php`
**URL:** `/aeit?session=XXX` (optional session parameter)
**Purpose:** Accessibility information (Eric J Moore, PhD)
**Footer Link:** Shows for types with `aeitLink: true` in config

---

## ♿ Accessibility

**Compliance:** WCAG 2.1 AA
**Features:** Keyboard navigation, focus indicators, ARIA labels, skip links, semantic HTML, color contrast 4.5:1

**See:** `css/focus.css` for focus indicator styling

---

## 📚 Related Documentation

- **[GENERAL-ARCHITECTURE.md](GENERAL-ARCHITECTURE.md)** - System overview, routing
- **[SAVE-AND-RESTORE.md](SAVE-AND-RESTORE.md)** - StateManager, StateEvents, API
- **[TESTING.md](TESTING.md)** - UI testing, accessibility testing
- **[SYSTEMWIDE-REPORT.md](SYSTEMWIDE-REPORT.md)** - Reports dashboard
- **[LIST-REPORT.md](LIST-REPORT.md)** - Individual checklist reports

---

*Document Created: October 20, 2025*
*Synthesized from: Codebase extraction (side-panel.js, simple-modal.js, ModalActions.js, buildCheckpoints.js, buildDemo.js, addRow.js, ui-components.js, php/home.php, php/aeit.php)*
*Status: Complete UI component architecture for backend developers*
