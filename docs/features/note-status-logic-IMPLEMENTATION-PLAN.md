# Notes-Status Logic - AI Agent Implementation Plan

**Date:** October 16, 2025
**Feature:** Automatic status management based on notes field interaction
**Complexity:** Medium
**Estimated Steps:** 35-40 tool calls
**Estimated Time:** 15-20 minutes

---

## 📋 Prerequisites

### **Required Reading**
1. ✅ `docs/features/note-status-logic.md` - Complete specification
2. ✅ Current codebase understanding

### **Key Files to Modify**
1. `js/StateManager.js` - State management and flag handling
2. `js/StateEvents.js` - Event listeners for notes field
3. `js/StatusManager.js` - Status change logic with flag awareness
4. `js/buildPrinciples.js` - Reset button visibility (verify existing logic)

### **Dependencies**
- No new dependencies needed
- Uses existing state management system
- Uses existing event delegation pattern

---

## 🎯 Implementation Strategy

### **Approach: Incremental & Testable**
1. Add flag support to data structures (backward compatible)
2. Implement flag state management
3. Add event listeners for automatic behavior
4. Update status change logic to respect flags
5. Verify reset button visibility
6. Test thoroughly

### **Key Principles**
- **Backward Compatible:** Existing sessions without flags should work
- **Non-Breaking:** Don't break existing functionality
- **Testable:** Each step can be tested independently
- **Documented:** Add code comments explaining flag logic

---

## 📝 Detailed Implementation Steps

### **PHASE 1: Data Structure Updates**

---

#### **Step 1.1: Read StateManager.js**
**Purpose:** Understand current state structure and methods

**Action:**
```javascript
read_file('js/StateManager.js')
```

**Look For:**
- State initialization methods
- Task object structure
- State save/restore methods
- Where to add `statusFlag` property

---

#### **Step 1.2: Add statusFlag to State Objects**
**Purpose:** Extend state structure to include flag tracking

**File:** `js/StateManager.js`

**Changes:**
1. Find state initialization (likely in constructor or init method)
2. Add default `statusFlag: 'text-manual'` to task objects
3. Ensure flag is included in state save operations
4. Ensure flag is restored when loading state

**Example Addition:**
```javascript
// In createPrincipleRowData or similar method
createPrincipleRowData(rowData) {
  return {
    id: rowData.id,
    task: rowData.task,
    notes: rowData.notes || '',
    status: rowData.status || 'ready',
    statusFlag: rowData.statusFlag || 'text-manual', // NEW: default flag
    isManual: rowData.isManual || false
  };
}
```

**Verification:**
- Check if flag is saved in session storage
- Check if flag is restored on page reload

---

#### **Step 1.3: Update State Restore Logic**
**Purpose:** Handle old sessions without statusFlag

**File:** `js/StateManager.js`

**Changes:**
1. Find restore/load state method
2. Add fallback for missing `statusFlag` property
3. Default to `'text-manual'` if undefined

**Example:**
```javascript
// In restoreState or similar method
restoreState(savedState) {
  // ... existing code ...

  // Ensure backward compatibility - add statusFlag if missing
  if (!taskData.statusFlag) {
    taskData.statusFlag = 'text-manual';
  }

  // ... rest of restore logic ...
}
```

**Verification:**
- Load old saved session (without statusFlag)
- Verify it works and defaults to 'text-manual'

---

### **PHASE 2: Flag State Management**

---

#### **Step 2.1: Add Flag Getter/Setter Methods**
**Purpose:** Centralize flag access and updates

**File:** `js/StateManager.js`

**Add Methods:**
```javascript
/**
 * Get status flag for a task
 * @param {string} taskId - Task ID
 * @returns {string} Flag value ('text-manual', 'active-auto', 'active-manual')
 */
getStatusFlag(taskId) {
  const state = this.getTaskState(taskId);
  return state?.statusFlag || 'text-manual';
}

/**
 * Set status flag for a task
 * @param {string} taskId - Task ID
 * @param {string} flag - Flag value
 */
setStatusFlag(taskId, flag) {
  const state = this.getTaskState(taskId);
  if (state) {
    state.statusFlag = flag;
    this.saveState(); // Persist to session storage
  }
}

/**
 * Reset flag to default state
 * @param {string} taskId - Task ID
 */
resetStatusFlag(taskId) {
  this.setStatusFlag(taskId, 'text-manual');
}
```

**Verification:**
- Call getStatusFlag() on a task
- Call setStatusFlag() and verify it persists
- Reload page and verify flag is restored

---

### **PHASE 3: Automatic Status Change Logic**

---

#### **Step 3.1: Read StateEvents.js**
**Purpose:** Understand event delegation system

**Action:**
```javascript
read_file('js/StateEvents.js')
```

**Look For:**
- Where textarea input events are handled
- Event delegation pattern used
- Where to add new auto-status logic

---

#### **Step 3.2: Add Auto-Status Change on Notes Input**
**Purpose:** Ready → Active when user types notes

**File:** `js/StateEvents.js`

**Find:** Textarea input event handler (likely listening on document or main)

**Add Logic:**
```javascript
// In textarea input event handler
if (target.classList.contains('notes-textarea')) {
  const taskId = target.id.replace('textarea-', '');
  const notesValue = target.value.trim();

  // Get current state
  const currentStatus = window.unifiedStateManager.getTaskState(taskId)?.status;
  const currentFlag = window.unifiedStateManager.getStatusFlag(taskId);

  // AUTO-CHANGE LOGIC: Ready + typing → Active
  if (currentStatus === 'ready' && notesValue.length > 0 && currentFlag === 'text-manual') {
    // Change status to active
    window.StatusManager.setStatus(taskId, 'active');

    // Set flag to indicate auto-change
    window.unifiedStateManager.setStatusFlag(taskId, 'active-auto');

    console.log(`[Auto-Status] ${taskId}: Ready → Active (notes added)`);
  }

  // AUTO-REVERT LOGIC: Active + clear notes + auto flag → Ready
  if (currentStatus === 'active' && notesValue.length === 0 && currentFlag === 'active-auto') {
    // Revert status to ready
    window.StatusManager.setStatus(taskId, 'ready');

    // Reset flag to default
    window.unifiedStateManager.resetStatusFlag(taskId);

    console.log(`[Auto-Status] ${taskId}: Active → Ready (notes cleared)`);
  }

  // Save notes to state (existing functionality)
  window.unifiedStateManager.updateTaskNotes(taskId, target.value);
}
```

**Verification:**
- Type in notes field when Status=Ready → Status changes to Active
- Clear notes field when Status=Active (auto) → Status changes to Ready
- Clear notes field when Status=Active (manual) → Status stays Active

---

### **PHASE 4: Manual Status Change Logic**

---

#### **Step 4.1: Read StatusManager.js**
**Purpose:** Understand status change implementation

**Action:**
```javascript
read_file('js/StatusManager.js')
```

**Look For:**
- Status button click handler
- Status change method
- Where to add flag update logic

---

#### **Step 4.2: Update Status Change to Set Flags**
**Purpose:** Manual status changes set active-manual flag

**File:** `js/StatusManager.js`

**Find:** Status change method (likely `setStatus` or similar)

**Add Logic:**
```javascript
/**
 * Set task status and update flag
 * @param {string} taskId - Task ID
 * @param {string} newStatus - New status value
 */
static setStatus(taskId, newStatus) {
  // Get current status
  const currentStatus = window.unifiedStateManager.getTaskState(taskId)?.status;

  // Update status (existing logic)
  window.unifiedStateManager.updateTaskStatus(taskId, newStatus);

  // FLAG LOGIC: Track manual vs auto changes
  // If changing from Ready → Active manually (not via auto-system)
  if (currentStatus === 'ready' && newStatus === 'active') {
    const currentFlag = window.unifiedStateManager.getStatusFlag(taskId);

    // Only set active-manual if not already auto-changed
    if (currentFlag !== 'active-auto') {
      window.unifiedStateManager.setStatusFlag(taskId, 'active-manual');
      console.log(`[Manual-Status] ${taskId}: Flag set to active-manual`);
    }
  }

  // FLAG LOGIC: Reset flag when cycling back to Ready
  if (newStatus === 'ready') {
    window.unifiedStateManager.resetStatusFlag(taskId);
    console.log(`[Status-Reset] ${taskId}: Flag reset to text-manual`);
  }

  // Update UI (existing logic)
  this.updateStatusButton(taskId, newStatus);
}
```

**Verification:**
- Click status button Ready → Active → Flag should be 'active-manual'
- Type in notes with active-manual flag → Status should NOT auto-change
- Click status button Done → Ready → Flag should reset to 'text-manual'

---

### **PHASE 5: Done Status & Notes Locking**

---

#### **Step 5.1: Add Notes Field Locking Logic**
**Purpose:** Disable notes when Status = Done

**File:** `js/StatusManager.js` (in updateStatusButton or similar method)

**Add Logic:**
```javascript
/**
 * Update status button and handle side effects
 */
static updateStatusButton(taskId, status) {
  // ... existing button update logic ...

  // NOTES LOCKING: Disable notes field when status is Done
  const notesTextarea = document.getElementById(`textarea-${taskId}`);
  if (notesTextarea) {
    if (status === 'done') {
      notesTextarea.disabled = true;
      notesTextarea.classList.add('notes-locked');
    } else {
      notesTextarea.disabled = false;
      notesTextarea.classList.remove('notes-locked');
    }
  }

  // ... rest of existing logic ...
}
```

**CSS Addition (optional):**
```css
/* In css/form-elements.css */
.notes-textarea.notes-locked {
  background-color: #f5f5f5;
  cursor: not-allowed;
  opacity: 0.7;
}
```

**Verification:**
- Set status to Done → Notes field should be disabled
- Try typing in notes field → Should not be editable
- Change status to Active → Notes field should become editable again

---

### **PHASE 6: Reset Button Logic**

---

#### **Step 6.1: Read buildPrinciples.js for Reset Button**
**Purpose:** Verify reset button visibility logic

**Action:**
```javascript
read_file('js/buildPrinciples.js', {offset: 210, limit: 30})
// Around line 217-228 where reset button is created
```

**Look For:**
- Reset button creation
- Visibility logic (should have 'restart-hidden' class initially)
- Where visibility is toggled

---

#### **Step 6.2: Verify Reset Button Visibility in StatusManager**
**Purpose:** Ensure reset button shows ONLY when Status = Done

**File:** `js/StatusManager.js`

**Find:** updateStatusButton method or similar

**Verify/Add Logic:**
```javascript
static updateStatusButton(taskId, status) {
  // ... existing status update logic ...

  // RESET BUTTON VISIBILITY: Show only when Done
  const resetButton = document.getElementById(`restart-${taskId}`);
  if (resetButton) {
    if (status === 'done') {
      resetButton.classList.remove('restart-hidden');
    } else {
      resetButton.classList.add('restart-hidden');
    }
  }

  // ... rest of logic ...
}
```

**Verification:**
- Status = Ready → Reset button hidden
- Status = Active → Reset button hidden
- Status = Done → Reset button visible
- Click reset → Status = Ready, Reset button hidden

---

#### **Step 6.3: Update Reset Button Handler**
**Purpose:** Ensure reset clears notes and resets flags

**File:** `js/StateEvents.js` (or wherever reset button click is handled)

**Find:** Reset button click event handler

**Verify/Update Logic:**
```javascript
// In reset button click handler
if (target.classList.contains('restart-button')) {
  const taskId = target.getAttribute('data-id');

  // Reset status to Ready
  window.StatusManager.setStatus(taskId, 'ready');

  // Clear notes
  const notesTextarea = document.getElementById(`textarea-${taskId}`);
  if (notesTextarea) {
    notesTextarea.value = '';
  }

  // Update state
  window.unifiedStateManager.updateTaskNotes(taskId, '');

  // Reset flag (already handled by setStatus when status → ready)
  window.unifiedStateManager.resetStatusFlag(taskId);

  console.log(`[Reset] ${taskId}: Status→Ready, Notes cleared, Flag→text-manual`);
}
```

**Verification:**
- Status = Done, Notes = "test" → Click Reset
- Status should be Ready, Notes should be empty, Flag should be text-manual

---

### **PHASE 7: Testing & Verification**

---

#### **Step 7.1: Manual Test Case Execution**

**Test 1: Basic Auto-Change**
```bash
# Start dev server
proj-user-testing

# Manual steps:
1. Open http://localhost:8000/list?type=camtasia
2. Find a task with Status = Ready
3. Click in notes field and type "test"
4. Verify: Status changes to Active (orange)
5. Open browser console, verify flag = 'active-auto'
```

**Test 2: Auto-Revert**
```bash
# Continue from Test 1
6. Clear all text from notes field
7. Verify: Status changes back to Ready (green)
8. Verify flag = 'text-manual'
```

**Test 3: Manual Override**
```bash
# New task
1. Find task with Status = Ready, no notes
2. Click status button (don't type notes)
3. Verify: Status = Active, flag = 'active-manual'
4. Type "test" in notes field
5. Verify: Status stays Active (no auto-change)
6. Clear notes
7. Verify: Status stays Active (no auto-revert)
```

**Test 4: Done Locks Notes**
```bash
1. Set task to Active, add notes "test"
2. Click status button → Done
3. Try clicking in notes field
4. Verify: Cannot edit (disabled)
5. Verify: Reset button is visible
```

**Test 5: Reset Clears Everything**
```bash
# Continue from Test 4
6. Click Reset button
7. Verify: Status = Ready
8. Verify: Notes = empty
9. Verify: Reset button hidden
10. Verify: Flag = 'text-manual'
```

**Test 6: Done→Ready Cycle**
```bash
1. Set task to Done with notes "test"
2. Click Done button again (cycle)
3. Verify: Status = Ready
4. Verify: Notes = "test" (preserved)
5. Verify: Flag = 'text-manual'
6. Type more notes
7. Verify: Status changes to Active (auto-behavior works again)
```

**Test 7: Persistence**
```bash
1. Set task to Active via notes (auto)
2. Save session (generate session key)
3. Reload page
4. Restore session
5. Verify: Status = Active, Flag = 'active-auto'
6. Clear notes
7. Verify: Status → Ready (auto-revert still works)
```

**Test 8: Manual Rows**
```bash
1. Add custom row using "Add Row" button
2. Type notes in custom row
3. Verify: Auto-status change works
4. Verify: Same behavior as template rows
```

---

#### **Step 7.2: Browser Console Verification**

**Check State Structure:**
```javascript
// In browser console
const state = window.unifiedStateManager.getState();
console.log(state);

// Should see statusFlag property on tasks:
// {
//   "1.1": {
//     status: "active",
//     notes: "test",
//     statusFlag: "active-auto"  // <-- NEW
//   }
// }
```

**Check Flag Methods:**
```javascript
// Test flag getter
window.unifiedStateManager.getStatusFlag('1.1');
// Should return: "active-auto" or "active-manual" or "text-manual"

// Test flag setter
window.unifiedStateManager.setStatusFlag('1.1', 'active-manual');
window.unifiedStateManager.getStatusFlag('1.1');
// Should return: "active-manual"
```

---

#### **Step 7.3: Edge Case Testing**

**Edge Case 1: Whitespace Only**
```bash
1. Status = Ready
2. Type spaces only: "   "
3. Verify: Should NOT trigger auto-status change (trim whitespace)
```

**Edge Case 2: Rapid Type/Delete**
```bash
1. Status = Ready
2. Type "a" → Backspace rapidly
3. Verify: Status cycles Ready→Active→Ready smoothly
```

**Edge Case 3: Multiple Cycles**
```bash
1. Ready → Active (auto) → Done → Ready
2. Ready → Active (manual) → Done → Ready
3. Verify flag resets after each cycle through Ready
```

---

### **PHASE 8: Code Quality & Documentation**

---

#### **Step 8.1: Add Code Comments**
**Purpose:** Document the flag system for future developers

**Files to Comment:**
- `js/StateManager.js` - Flag methods and data structure
- `js/StateEvents.js` - Auto-status change logic
- `js/StatusManager.js` - Flag tracking on manual changes

**Comment Template:**
```javascript
/**
 * STATUS FLAG SYSTEM
 *
 * Three flag states control automatic status changes:
 * - 'text-manual': Default state, normal behavior
 * - 'active-auto': Status was auto-changed by notes, can auto-revert
 * - 'active-manual': Status was manually set, no auto-behavior
 *
 * See: docs/features/note-status-logic.md
 */
```

---

#### **Step 8.2: Check for Console.log Cleanup**
**Purpose:** Remove debug console logs or keep only essential ones

**Action:**
```javascript
grep('console.log.*Auto-Status', 'js/')
grep('console.log.*Manual-Status', 'js/')
```

**Decision:**
- Keep: Logs that help users understand auto-behavior
- Remove: Excessive debug logs

---

#### **Step 8.3: Run Linter**
**Purpose:** Ensure no syntax errors introduced

**Action:**
```javascript
read_lints(['js/StateManager.js', 'js/StateEvents.js', 'js/StatusManager.js'])
```

**Fix:** Any linter errors found

---

### **PHASE 9: Integration & Final Verification**

---

#### **Step 9.1: Test with Multiple Checklist Types**

**Test Across Types:**
```bash
# Test with different JSON templates
1. Camtasia (3 checkpoints)
2. Word (4 checkpoints)
3. Demo (10 checkpoints)
4. Test-5 (5 checkpoints)

# Verify auto-status works for all
```

---

#### **Step 9.2: Test Save/Restore with Different Flags**

**Scenario:**
```bash
1. Create session with mixed flags:
   - Task 1.1: active-auto
   - Task 1.2: active-manual
   - Task 2.1: text-manual
2. Save session
3. Reload and restore
4. Verify each task behaves according to its flag
```

---

#### **Step 9.3: Test Systemwide Report Compatibility**

**Verify:**
```bash
1. Create session with auto-status changes
2. Navigate to Reports page
3. Verify: Completed tasks appear correctly
4. Verify: Status flags don't break report generation
```

---

#### **Step 9.4: Test List Report Compatibility**

**Verify:**
```bash
1. Save session with auto-status tasks
2. Go to List Report (saved sessions)
3. Restore session
4. Verify: Auto-behavior still works after restore
```

---

### **PHASE 10: Documentation & Changelog**

---

#### **Step 10.1: Update Changelog**
**Purpose:** Document new feature

**File:** `changelog.md`

**Add Entry:**
```markdown
## [Unreleased]

### Added
- **Automatic Status Management**: Status now automatically changes from Ready to Active when notes are added, and reverts when notes are cleared (if auto-changed). Manual status changes disable automatic behavior. (#feature-notes-status-auto)
  - New flag system tracks status change origin (manual vs automatic)
  - Notes field locks when status is Done
  - Reset button only visible when status is Done
  - See: docs/features/note-status-logic.md
```

---

#### **Step 10.2: Update README (Optional)**
**Purpose:** Mention new feature in project overview

**File:** `README.md`

**Add to Features Section:**
```markdown
### Smart Status Management
- Automatic status changes based on note-taking activity
- Manual overrides respected and preserved
- Intelligent behavior that adapts to user intent
```

---

#### **Step 10.3: Create User-Facing Documentation**
**Purpose:** Help users understand the feature

**File:** `docs/features/note-status-logic-USER-GUIDE.md` (optional)

**Content:**
- Simple explanation of auto-status
- Screenshots/examples
- How to override automatic behavior
- FAQ section

---

## 🎯 Success Criteria

### **Feature Complete When:**
- ✅ All 8 test cases pass
- ✅ Auto-status works: Ready→Active on notes
- ✅ Auto-revert works: Active→Ready on clear (if auto-flagged)
- ✅ Manual override works: No auto-behavior when manually set
- ✅ Notes lock when Status=Done
- ✅ Reset button only shows when Done
- ✅ Reset clears notes and resets flags
- ✅ Done→Ready cycle preserves notes, resets flags
- ✅ Flags persist across save/restore
- ✅ No linter errors
- ✅ No breaking changes to existing functionality
- ✅ Code is documented with comments
- ✅ Changelog updated

---

## ⚠️ Potential Issues & Solutions

### **Issue 1: Event Listener Conflicts**
**Problem:** Multiple listeners on textarea might conflict

**Solution:** Use event delegation (already implemented), ensure only one listener handles auto-status

---

### **Issue 2: State Sync**
**Problem:** Flag might get out of sync with actual status

**Solution:** Always update flag atomically with status change, never separately

---

### **Issue 3: Performance**
**Problem:** Checking status on every keystroke might be slow

**Solution:** Add debouncing if needed, but likely not necessary for this use case

---

### **Issue 4: Backward Compatibility**
**Problem:** Old saved sessions without statusFlag

**Solution:** Already handled - default to 'text-manual' if undefined

---

## 📊 Estimated Timeline

| Phase | Steps | Estimated Time |
|-------|-------|----------------|
| Phase 1: Data Structure | 3 steps | 3 min |
| Phase 2: Flag Management | 1 step | 2 min |
| Phase 3: Auto-Status Logic | 2 steps | 4 min |
| Phase 4: Manual Status Logic | 2 steps | 3 min |
| Phase 5: Notes Locking | 1 step | 2 min |
| Phase 6: Reset Button | 3 steps | 3 min |
| Phase 7: Testing | 3 steps | 5 min |
| Phase 8: Code Quality | 3 steps | 2 min |
| Phase 9: Integration | 4 steps | 3 min |
| Phase 10: Documentation | 3 steps | 2 min |
| **Total** | **25 steps** | **~30 min** |

---

## 🚀 Ready to Execute

This implementation plan is:
- ✅ **Detailed** - Every step clearly defined
- ✅ **Testable** - Clear verification at each phase
- ✅ **Safe** - Non-breaking, backward compatible
- ✅ **Complete** - Covers all aspects from code to docs

**Next Step:** Execute Phase 1 - Begin with reading and modifying StateManager.js

---

**Implementation Plan Complete** ✅

_Ready for AI agent execution - awaiting "proceed" command_
