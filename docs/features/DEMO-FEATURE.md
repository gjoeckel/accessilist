# Demo Feature Implementation

**Date**: October 15, 2025
**Purpose**: Interactive tutorial system for AccessiList
**Status**: ✅ Implemented - Ready for instruction content

---

## 🎯 Overview

The demo feature provides an interactive tutorial system where users can learn how to use AccessiList through hands-on practice with a dedicated demo checklist.

---

## 🚀 Features Implemented

### 1. "Start Here" Section on Home Page

**Location**: Top of home page, before Microsoft section

```html
<div class="checklist-group">
  <h2>Start Here</h2>
  <div class="checklist-buttons-row">
    <button id="demo" class="header-button">Demo</button>
  </div>
</div>
```

**Styling**: Green button (matches Save/Refresh buttons)

---

### 2. Demo Template

**File**: `json/demo.json`

**Structure**:
- 10 checkpoints
- 5 tasks per checkpoint
- All h2 headings: "Checkpoint X"
- All tasks: "Task 1", "Task 2", etc.
- Ready for instruction content (dogfooding approach)

```json
{
  "type": "demo",
  "name": "AccessiList Tutorial",
  "checkpoints": [
    {
      "id": "c1",
      "heading": "Checkpoint 1",
      "tasks": [
        {"id": "t1", "text": "Task 1", "notes": ""},
        {"id": "t2", "text": "Task 2", "notes": ""},
        ...
      ]
    },
    ... (10 total checkpoints)
  ]
}
```

---

### 3. "Demos" Filter in Systemwide Report

**Location**: After "All" button in systemwide-report.php

**Features**:
- ✅ Same styling as other filter buttons
- ✅ Shows count of demo sessions
- ✅ Filters to show only demo sessions
- ✅ Integrated with existing filter logic

```html
<button
    id="filter-demos"
    class="filter-button"
    data-filter="demos"
    aria-pressed="false"
    aria-label="Show demo sessions only">
    <span class="filter-label">Demos</span>
    <span class="filter-count" id="count-demos">0</span>
</button>
```

---

### 4. Demo Session Handling

**Behavior**:
- ✅ User clicks "Demo" button
- ✅ Generates unique 3-character session ID
- ✅ Creates demo instance via API
- ✅ Redirects to `/?={sessionID}`
- ✅ Demo sessions saved like regular sessions
- ✅ Can be retrieved with session key
- ✅ Appear in systemwide report
- ✅ Filterable with "Demos" button
- ✅ No expiration
- ✅ Unlimited instances allowed

---

## 📁 Files Modified

| File | Changes | Purpose |
|------|---------|---------|
| `json/demo.json` | NEW (340 lines) | Demo template with 10 checkpoints |
| `config/checklist-types.json` | +2 lines | Added demo type configuration |
| `php/home.php` | +34 lines | Added Start Here section + Demo button |
| `php/systemwide-report.php` | +9 lines | Added Demos filter button |
| `js/systemwide-report.js` | +21 lines | Added demos filtering logic |

**Total**: 1 new file, 4 files modified, 66 lines added

---

## 🎨 User Interface

### Home Page

```
┌─────────────────────────────┐
│   Accessibility Checklists   │
├─────────────────────────────┤
│                             │
│  Start Here                 │
│  ┌──────┐                   │
│  │ Demo │ (green button)    │
│  └──────┘                   │
│                             │
│  Microsoft                  │
│  ┌──────┬───────────┬──────┐│
│  │ Word │PowerPoint │Excel ││
│  └──────┴───────────┴──────┘│
│                             │
│  ... (other sections)       │
└─────────────────────────────┘
```

### Systemwide Report

```
Filter buttons:
┌──────┬────────┬────────────┬─────┬───────┐
│ Done │ Active │ Not Started│ All │ Demos │
└──────┴────────┴────────────┴─────┴───────┘
        Count: 0    Count: 0   Count: 0  Count: 0
```

---

## 🔄 User Flow

### Creating a Demo Session

1. User visits home page
2. Sees "Start Here" section at top
3. Clicks green "Demo" button
4. System generates unique session ID (e.g., `A1B`)
5. Creates demo instance from template
6. Redirects to `/?=A1B`
7. User works through demo checklist
8. All actions save automatically
9. Session appears in systemwide report

### Viewing Demo Sessions

1. User visits `/systemwide-report`
2. Clicks "Demos" filter button
3. Table shows only demo sessions
4. Can view, restore, or delete demos
5. Can create multiple demo instances

---

## 📊 Demo Session Properties

| Property | Value | Notes |
|----------|-------|-------|
| **Type** | `demo` | Identifies as demo session |
| **Template** | `json/demo.json` | Source template |
| **Session Keys** | `A1B`, `C2D`, etc. | Unique 3-char IDs |
| **Saved In** | `saves/{KEY}.json` | Same as other sessions |
| **Retrievable** | ✅ Yes | Via `/?={KEY}` |
| **In Reports** | ✅ Yes | Visible when "Demos" filter clicked |
| **Expiration** | None | Persists indefinitely |
| **Instance Limit** | None | Create as many as needed |

---

## 🎓 Dogfooding Approach

**Instructions will be placed in existing form elements**:

### Where Instructions Go

1. **Task Text** - Main instruction content
2. **Notes Field** - Detailed explanations, tips
3. **Checkpoint Headings** - Section titles

### Example

```json
{
  "id": "c1",
  "heading": "Checkpoint 1: Introduction",
  "tasks": [
    {
      "id": "t1",
      "text": "Click this checkbox to mark the task complete",
      "notes": "Notice how the status changes from Ready → Active → Done"
    },
    {
      "id": "t2",
      "text": "Try typing in this notes field",
      "notes": "Instructions can guide users through features using the actual interface"
    }
  ]
}
```

---

## 🧪 Testing

### Local Testing

```bash
# Start PHP server
php -S localhost:8000 router.php

# Test home page has Demo button
curl http://localhost:8000/home | grep "Start Here"
curl http://localhost:8000/home | grep 'id="demo"'

# Test systemwide report has Demos filter
curl http://localhost:8000/systemwide-report | grep "filter-demos"

# Test demo type is recognized
curl http://localhost:8000/json/demo.json  # Should return 200
```

### Manual Testing

1. Visit `http://localhost:8000/home`
2. Verify "Start Here" section appears first
3. Click "Demo" button
4. Should create demo instance and redirect to `/?={KEY}`
5. Visit `/systemwide-report`
6. Click "Demos" filter
7. Should show demo sessions only

---

## 🔧 Next Steps: Adding Instructions

### Process

1. **Identify feature to teach** (e.g., "How to mark tasks complete")
2. **Choose checkpoint** (c1, c2, etc.)
3. **Write instruction in task text**
4. **Add details in notes field**
5. **Test the instruction**
6. **Repeat for next feature**

### Example Workflow

```bash
# You say: "Update c1-t1 to teach checkbox clicking"
# I update json/demo.json:
{
  "id": "t1",
  "text": "Click the checkbox next to this task to mark it complete",
  "notes": "Watch the status change from Ready to Done"
}

# Commit and test
```

---

## 📋 Suggested Instruction Topics

### Checkpoint 1: Basics
- Task 1: How to mark tasks complete
- Task 2: How to use notes field
- Task 3: How to navigate checkpoints
- Task 4: How to use side panel
- Task 5: Understanding status indicators

### Checkpoint 2: Side Panel
- Task 1: Clicking checkpoint links
- Task 2: Collapsing/expanding panel
- Task 3: Visual indicators for completion

### Checkpoint 3: Status Management
- Task 1: Ready → Active → Done workflow
- Task 2: Status buttons explained
- Task 3: Progress tracking

### Checkpoint 4: Saving & Reports
- Task 1: How saving works
- Task 2: Accessing list reports
- Task 3: Viewing systemwide reports

... (Continue for remaining checkpoints)

---

## 🎯 Benefits

1. **Interactive Learning** - Hands-on experience
2. **Dogfooding** - Uses actual interface for instructions
3. **Repeatable** - Users can create multiple demo instances
4. **Trackable** - Demos appear in reports
5. **Filterable** - Easy to find demo sessions
6. **No Complexity** - Uses existing functionality

---

## ✅ Implementation Status

```
✅ Demo template created (10 checkpoints, 5 tasks each)
✅ "Start Here" section added to home page
✅ Green "Demo" button added (matches Save/Refresh styling)
✅ Demo button wired to instantiate API
✅ "Demos" filter added to systemwide report
✅ Filtering logic updated to support demos
✅ Type configuration updated
✅ All components tested locally
✅ Ready for instruction content

Next: Add instructional content to demo.json
```

---

## 📚 Related Files

- `json/demo.json` - Demo template (ready for instructions)
- `config/checklist-types.json` - Type configuration
- `php/home.php` - Demo button implementation
- `php/systemwide-report.php` - Demos filter
- `js/systemwide-report.js` - Filtering logic

---

**Demo feature fully implemented and ready for instructional content!** ✨

You can now start adding instructions, and I'll update `demo.json` as you provide the content. Just tell me which checkpoint/task to update and what instruction to add!
