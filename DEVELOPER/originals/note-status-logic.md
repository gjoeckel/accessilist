# Notes-Status Automatic Management Logic

**Date:** October 16, 2025
**Feature:** Automatic status changes based on notes field interaction
**Status:** 📋 Planned (Implementation Ready)

---

## 🎯 Feature Overview

Implement intelligent status management where:
- Typing in notes automatically changes status from Ready → Active
- Clearing notes can automatically revert status from Active → Ready
- Manual status changes disable automatic behavior
- User intent is respected and preserved

---

## 🏗️ Core Concept

**Problem:** Users often forget to update status when they start working on a task (adding notes).

**Solution:** Detect note-taking activity and automatically update status, while respecting manual overrides.

**Key Principle:** The system should be helpful but never override explicit user actions.

---

## 🔧 Flag System

### **Three Flag States**

| Flag | Meaning | When Set |
|------|---------|----------|
| `text-manual` | Default state - normal behavior | Initial state, after reset, after Done→Ready |
| `active-auto` | Status was auto-changed due to notes | User typed in notes while Status=Ready |
| `active-manual` | Status was manually changed by user | User clicked status button Ready→Active |

### **Default State**
- All tasks start with `text-manual` flag
- Any reset operation returns to `text-manual`

---

## 📊 State Machine

### **State Transitions**

```
┌─────────────────────────────────────────────────────┐
│                    READY STATE                       │
│                  Flag: text-manual                   │
└─────────────────────────────────────────────────────┘
           │                            │
           │ Type in notes              │ Click status button
           │                            │
           ▼                            ▼
┌────────────────────┐      ┌────────────────────┐
│   ACTIVE STATE     │      │   ACTIVE STATE     │
│  Flag: active-auto │      │ Flag: active-manual│
└────────────────────┘      └────────────────────┘
           │                            │
           │ Clear all notes            │ Notes changes ignored
           │                            │
           ▼                            ▼
┌────────────────────┐      │  (stays ACTIVE)   │
│   READY STATE      │      └────────────────────┘
│ Flag: text-manual  │
└────────────────────┘
```

---

## 🔄 Detailed Logic Flow

### **Scenario 1: Automatic Status Change (Ready + Notes Added)**

**Trigger:**
- User types text in Notes field
- Current Status = "Ready"
- Current Flag = `text-manual`

**Actions:**
1. Detect text input in notes field
2. Check if Status = "Ready"
3. If true: Change Status → "Active"
4. Set flag → `active-auto`

**Result:**
- Status = Active (orange icon)
- Notes = (user's text)
- Flag = `active-auto`

**Code Trigger:** `textarea` input event

---

### **Scenario 2: Automatic Revert (Active + Notes Cleared)**

**Trigger:**
- User removes ALL text from Notes field (empty)
- Current Status = "Active"

**Condition Check:**
- Is flag = `active-auto`?

**Actions if `active-auto = true`:**
1. Detect notes field is empty
2. Check flag state
3. If `active-auto`: Change Status → "Ready"
4. Set flag → `text-manual`

**Actions if `active-auto = false`:**
- No status change (was manually set)

**Result (when auto-revert triggers):**
- Status = Ready (green icon)
- Notes = empty
- Flag = `text-manual`

**Code Trigger:** `textarea` input event (check if value is empty)

---

### **Scenario 3: Manual Status Change (Disables Auto-Behavior)**

**Trigger:**
- User clicks status button
- Current Status = "Ready"

**Actions:**
1. Status changes: "Ready" → "Active"
2. Set flag → `active-manual`

**Behavior:**
- Adding text to notes: No status change
- Removing text from notes: No status change
- Status is "locked" from automatic changes

**Result:**
- Status = Active (orange icon)
- Notes = (any text, irrelevant)
- Flag = `active-manual`

**Code Trigger:** Status button click event

---

### **Scenario 4: Status = "Done" (Notes Locked)**

**Trigger:**
- User clicks status button: "Active" → "Done"

**Actions:**
1. Status changes to "Done"
2. Notes field becomes **READ-ONLY** (disabled/locked)
3. Flag persists (whatever it was)
4. Reset button becomes **VISIBLE**

**Notes Field Behavior:**
- Cannot edit notes while Status = Done
- Notes are visible but locked
- Prevents accidental changes to done work

**Result:**
- Status = Done (blue icon)
- Notes = (locked, read-only)
- Flag = (persists: `active-auto` OR `active-manual`)
- Reset button = VISIBLE

**Code Trigger:** Status button reaches "Done" state

---

### **Scenario 5: Done → Ready (Manual Cycle)**

**Trigger:**
- User clicks "Done" status button again
- Current Status = "Done"

**Actions:**
1. Status changes: "Done" → "Ready"
2. Notes field becomes **EDITABLE** again
3. Notes content **REMAINS** (not cleared)
4. Flag resets → `text-manual`

**Result:**
- Status = Ready (green icon)
- Notes = (original text, preserved)
- Flag = `text-manual`
- Reset button = HIDDEN

**Note:** This allows users to cycle back without losing notes, but resets auto-behavior flags.

---

### **Scenario 6: Reset Button (Clear Everything)**

**Trigger:**
- User clicks "Reset" button
- Reset button **ONLY VISIBLE** when Status = "Done"

**Actions:**
1. Status changes: ANY → "Ready"
2. Notes field: **CLEARED** (emptied)
3. Notes field: becomes editable
4. Flag resets → `text-manual`
5. Reset button becomes **HIDDEN**

**Result:**
- Status = Ready (green icon)
- Notes = empty
- Flag = `text-manual`
- Reset button = HIDDEN

**Visual Cue:** Reset button only appears when Status = Done

---

## 🎨 User Interface Implications

### **Reset Button Visibility**
```
Status = Ready  → Reset button HIDDEN
Status = Active → Reset button HIDDEN
Status = Done   → Reset button VISIBLE
```

### **Notes Field State**
```
Status = Ready  → Notes EDITABLE
Status = Active → Notes EDITABLE
Status = Done   → Notes READ-ONLY (locked)
```

### **Status Button States**
```
Ready  (green)  → Click → Active
Active (orange) → Click → Done
Done   (blue)   → Click → Ready (cycles back)
```

---

## 📝 State Transition Table

| Current State | User Action | Condition | New State | Flag Change | Notes State |
|---------------|-------------|-----------|-----------|-------------|-------------|
| Ready + empty | Type in notes | flag=`text-manual` | Active | → `active-auto` | Editable |
| Active + text | Clear notes | flag=`active-auto` | Ready | → `text-manual` | Editable |
| Active + text | Clear notes | flag=`active-manual` | Active | No change | Editable |
| Ready | Click status btn | Any | Active | → `active-manual` | Editable |
| Active | Click status btn | Any | Done | Persists | **Locked** |
| Done | Click Done btn | Any | Ready | → `text-manual` | Editable |
| Done | Click Reset btn | Any | Ready | → `text-manual` | Editable + **Cleared** |

---

## 💾 Persistence & Storage

### **Session Storage Structure**

Each task should store:
```javascript
{
  "id": "1.1",
  "status": "active",
  "notes": "Working on this task",
  "statusFlag": "active-auto",  // NEW: track flag state
  // ... other task data
}
```

### **Flag Values**
- `"text-manual"` - Default state
- `"active-auto"` - Auto-changed by notes
- `"active-manual"` - Manually changed by user

### **Save/Restore Behavior**
- Flags are saved when session is saved
- Flags are restored when session is loaded
- Missing flag defaults to `"text-manual"`

---

## 🔍 Edge Cases & Considerations

### **Edge Case 1: Loading Saved Session**
**Scenario:** User loads session with Status=Active, notes exist, flag=`active-auto`

**Behavior:**
- If user clears notes → Status auto-reverts to Ready
- Auto-behavior is preserved across sessions

---

### **Edge Case 2: Manual Row Addition**
**Scenario:** User adds custom row using "Add Row" button

**Initial State:**
- Status = Ready
- Notes = empty
- Flag = `text-manual`

**Behavior:**
- Normal auto-behavior applies to custom rows
- Same rules as template rows

---

### **Edge Case 3: Multiple Status Clicks**
**Scenario:** User clicks status multiple times: Ready→Active→Done→Ready→Active

**Behavior:**
- First Ready→Active: Sets `active-manual`
- Done→Ready: Resets to `text-manual`
- Second Ready→Active: Sets `active-manual` again
- Each cycle through Ready resets flags

---

### **Edge Case 4: Whitespace-Only Notes**
**Scenario:** User types spaces or newlines only

**Decision Needed:** Should whitespace-only count as "empty"?

**Recommendation:** Trim whitespace before checking if empty
```javascript
const isEmpty = textarea.value.trim() === '';
```

---

### **Edge Case 5: Rapid Typing/Deletion**
**Scenario:** User types, then immediately deletes within milliseconds

**Behavior:**
- First keystroke: Ready → Active (`active-auto`)
- Delete all: Active → Ready (`text-manual`)
- Result: Quick cycle, but logic remains consistent

**Consideration:** May need debouncing for performance

---

## 🎯 Benefits

1. **Reduced Cognitive Load:** Users don't need to remember to change status when starting work
2. **Accurate Progress Tracking:** Status automatically reflects actual work state
3. **Respects User Intent:** Manual changes always take precedence
4. **Intuitive Behavior:** Feels natural and predictable
5. **Zero Data Loss:** Notes are preserved, can be undone

---

## ⚠️ Important Rules

1. ✅ **Auto-change ONLY happens from Ready → Active** (never Active → Done)
2. ✅ **Auto-revert ONLY happens when flag = `active-auto`**
3. ✅ **Manual status changes DISABLE auto-behavior** (set `active-manual`)
4. ✅ **Reset button ONLY visible when Status = Done**
5. ✅ **Done status LOCKS notes field** (read-only)
6. ✅ **Cycling through Ready RESETS flags** to `text-manual`
7. ✅ **Default flag is ALWAYS `text-manual`**

---

## 🧪 Test Cases

### **Test 1: Basic Auto-Change**
1. Start: Status=Ready, Notes=empty, Flag=text-manual
2. Type "test" in notes
3. Expect: Status=Active, Flag=active-auto

### **Test 2: Auto-Revert**
1. Start: Status=Active, Notes="test", Flag=active-auto
2. Clear notes (delete all text)
3. Expect: Status=Ready, Flag=text-manual

### **Test 3: Manual Override**
1. Start: Status=Ready, Notes=empty, Flag=text-manual
2. Click status button
3. Expect: Status=Active, Flag=active-manual
4. Type "test" in notes
5. Expect: Status=Active (unchanged), Flag=active-manual

### **Test 4: Manual No Auto-Revert**
1. Start: Status=Active, Notes="test", Flag=active-manual
2. Clear notes
3. Expect: Status=Active (unchanged), Flag=active-manual

### **Test 5: Done Locks Notes**
1. Start: Status=Active, Notes="test"
2. Click status button → Done
3. Expect: Notes field is read-only/disabled
4. Expect: Reset button visible

### **Test 6: Reset Clears Everything**
1. Start: Status=Done, Notes="test", Flag=any
2. Click Reset button
3. Expect: Status=Ready, Notes=empty, Flag=text-manual, Reset hidden

### **Test 7: Done→Ready Cycle**
1. Start: Status=Done, Notes="test", Flag=any
2. Click Done button (cycle)
3. Expect: Status=Ready, Notes="test" (preserved), Flag=text-manual

### **Test 8: Persistence**
1. Start: Status=Active, Notes="test", Flag=active-auto
2. Save session
3. Reload page and restore session
4. Clear notes
5. Expect: Status=Ready (auto-revert still works)

---

## 📚 Implementation Files

### **JavaScript Files to Modify**
- `js/StateEvents.js` - Add notes field event listeners
- `js/StateManager.js` - Add flag state management
- `js/StatusManager.js` - Modify status change logic
- `js/buildPrinciples.js` - Ensure reset button visibility logic

### **State Data Structure**
Update task objects to include:
```javascript
{
  id: "1.1",
  task: "Task text",
  notes: "User notes",
  status: "active",
  statusFlag: "active-auto",  // NEW PROPERTY
  isManual: false
}
```

---

## 🚀 Rollout Plan

### **Phase 1: Backend Logic**
- Add `statusFlag` property to state objects
- Implement flag persistence in session storage

### **Phase 2: Event Handlers**
- Add textarea input listener for auto-change
- Add textarea input listener for auto-revert
- Add status button listener for manual flag

### **Phase 3: UI Updates**
- Implement notes field locking when Status=Done
- Verify reset button visibility logic

### **Phase 4: Testing**
- Run all 8 test cases
- Test with manual rows
- Test save/restore functionality
- Test across different checklist types

### **Phase 5: Documentation**
- Update user documentation
- Add feature to changelog
- Create user tutorial content

---

## 🎓 User Education

### **Tooltip/Help Text Ideas**

**Notes Field:**
> "Typing notes automatically marks task as Active. Clear notes to reset to Ready."

**Status Button (when auto-changed):**
> "Status was automatically set to Active when you added notes."

**Reset Button:**
> "Reset task to Ready and clear all notes."

---

## 📊 Success Metrics

After implementation, measure:
1. Percentage of tasks where status accurately reflects work state
2. User feedback on intuitive behavior
3. Number of manual status corrections needed
4. Time saved in checklist management

---

**End of Specification** ✅

_Ready for implementation - awaiting AI agent execution plan_
