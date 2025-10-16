# Demo Checklist - Structure Fix

**Date:** October 16, 2025
**Issue:** Demo checklist not displaying
**Status:** ✅ Fixed

---

## 🔍 Problem Identified

The `demo.json` file was using an incorrect data structure that didn't match what the application expects.

### ❌ Incorrect Structure (Before Fix)

```json
{
  "type": "demo",
  "checkpoints": [
    {
      "id": "c1",
      "heading": "Checkpoint 1",
      "tasks": [...]
    }
  ]
}
```

**Issues:**
1. ❌ Uses `"checkpoints"` as an array
2. ❌ Each checkpoint has `"id"`, `"heading"`, `"tasks"` properties
3. ❌ Application couldn't find checkpoint keys (it looks for `"checkpoint-1"`, not an array)

---

## ✅ Correct Structure (After Fix)

```json
{
  "version": "0.8",
  "type": "Demo",
  "checkpoint-1": {
    "caption": "Getting Started - Introduction to Accessibility",
    "table": [
      {
        "id": "1.1",
        "task": "Learn how to navigate the checklist interface",
        "info": "Use the side panel to jump between checkpoints"
      }
    ]
  },
  "checkpoint-2": {
    "caption": "Working with Tasks - Managing Your Checklist",
    "table": [...]
  }
}
```

**Key Requirements:**
1. ✅ Uses `"checkpoint-X"` as **object keys** (not an array)
2. ✅ Each checkpoint has `"caption"` property (the heading text)
3. ✅ Each checkpoint has `"table"` property (array of tasks)
4. ✅ Each task has `"id"`, `"task"`, and `"info"` properties

---

## 🧩 Why This Structure?

The application's `buildContent()` function in `js/buildCheckpoints.js` expects:

```javascript
// Lines 328-337: Filter checkpoint keys
const checkpointKeys = Object.keys(data)
  .filter(
    (key) => key.startsWith("checkpoint-") || key.startsWith("checklist-")
  )
  .sort((a, b) => {
    const numA = parseInt(a.split("-")[1]);
    const numB = parseInt(b.split("-")[1]);
    return numA - numB;
  });

// Line 344: Access the table property
const tableWrapper = buildTable(checkpointData.table, checkpointKey);
```

**What the code does:**
1. Gets all object keys from the JSON data
2. Filters for keys starting with `"checkpoint-"` or `"checklist-"`
3. Sorts them numerically by the number after the dash
4. For each checkpoint, accesses the `.table` property to build the UI

**What went wrong:**
- With an array structure, there were **no keys** named `"checkpoint-1"`, `"checkpoint-2"`, etc.
- The filter found nothing, so no checkpoints were displayed

---

## 📝 JSON Template Structure Reference

All checklist JSON files must follow this structure:

```json
{
  "version": "0.8",
  "type": "TypeName",
  "checkpoint-1": {
    "caption": "First checkpoint description",
    "table": [
      {
        "id": "1.1",
        "task": "Task description",
        "info": "Help text or example"
      },
      {
        "id": "1.2",
        "task": "Another task",
        "info": "More help text"
      }
    ]
  },
  "checkpoint-2": {
    "caption": "Second checkpoint description",
    "table": [...]
  }
}
```

### Required Properties

**Top Level:**
- `version` (string): Version number (currently "0.8")
- `type` (string): Display name for the checklist type
- `checkpoint-N` (object): One or more checkpoint objects (N = 1, 2, 3, ...)

**Each Checkpoint:**
- `caption` (string): The heading text for this checkpoint
- `table` (array): Array of task objects

**Each Task:**
- `id` (string): Unique ID like "1.1", "2.3", etc.
- `task` (string): The task description text
- `info` (string): Help text shown in the info modal

---

## 🎯 Demo Checklist Features

The fixed `demo.json` now includes:

### Checkpoint 1: Getting Started
- Learn interface navigation
- Practice status changes (Ready → Active → Done)
- Add notes to tasks
- View info examples
- Reset tasks

### Checkpoint 2: Working with Tasks
- Add custom tasks
- Save/restore progress
- View reports
- Delete custom tasks
- Print/export

### Checkpoints 3-10: Accessibility Best Practices
- Understanding accessibility concepts
- Visual design checkpoints
- Content accessibility
- Navigation and interaction
- Forms and input
- Tables and data
- ARIA and semantics
- Testing and compliance

---

## 🔧 How to Create New Checklist Types

1. **Copy an existing working JSON file** (e.g., `word.json` or `camtasia.json`)

2. **Update the metadata:**
   ```json
   {
     "version": "0.8",
     "type": "YourTypeName"
   }
   ```

3. **Add/modify checkpoints:**
   ```json
   "checkpoint-1": {
     "caption": "Your checkpoint description",
     "table": [...]
   }
   ```

4. **Add tasks to each checkpoint:**
   ```json
   {
     "id": "1.1",
     "task": "What the user needs to do",
     "info": "Help text explaining how or why"
   }
   ```

5. **Register in `config/checklist-types.json`:**
   ```json
   "your-type": {
     "displayName": "Your Type Name",
     "jsonFile": "your-type.json",
     "buttonId": "your-type",
     "category": "CategoryName"
   }
   ```

6. **Add to category list:**
   ```json
   "categories": {
     "CategoryName": ["your-type", "other-types"]
   }
```

---

## 🧪 Testing

To verify a new checklist type works:

1. **Start the dev server:**
   ```bash
   php -S localhost:8000 router.php
   ```

2. **Visit the home page:**
   ```
   http://localhost:8000/home
   ```

3. **Click your checklist type button**

4. **Verify:**
   - ✅ Page loads without errors
   - ✅ All checkpoints appear in order
   - ✅ Side panel shows all checkpoints
   - ✅ Tasks are displayed correctly
   - ✅ Info buttons work and show help text
   - ✅ Status buttons work (Ready → Active → Done)
   - ✅ Add Row button works
   - ✅ Save/Restore functionality works

---

## 📚 Related Files

**JavaScript:**
- `js/buildCheckpoints.js` - Builds checkpoint sections from JSON
- `js/main.js` - Loads JSON and initializes app
- `js/side-panel.js` - Side navigation panel
- `js/type-manager.js` - Type configuration management

**Configuration:**
- `config/checklist-types.json` - Registry of all checklist types
- `json/*.json` - Individual checklist templates

**Documentation:**
- `docs/development/DRYing-types.md` - Type management system
- `README.md` - Project overview and setup

---

## 🎉 Result

The demo checklist now:
- ✅ Displays all 10 checkpoints correctly
- ✅ Shows meaningful tutorial content
- ✅ Provides interactive learning experience
- ✅ Includes helpful info text for each task
- ✅ Follows the same structure as all other checklists
- ✅ Works with save/restore functionality
- ✅ Compatible with reports and progress tracking

---

## 💡 Key Takeaway

**Always use object keys for checkpoints, never arrays:**
- ✅ `"checkpoint-1": { "caption": "...", "table": [...] }`
- ❌ `"checkpoints": [{ "id": "c1", "tasks": [...] }]`

The application expects a flat object structure with predictable key names that can be filtered and sorted.
