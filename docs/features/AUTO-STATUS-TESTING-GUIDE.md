# Automatic Status Management - Testing Guide

**Date:** October 16, 2025
**Feature:** Auto-status change based on notes field interaction
**Status:** ✅ Implementation Complete - Ready for Testing

---

## 🎯 Quick Start

The dev server is running at: **http://localhost:8000**

**Recommended test URL:**
http://localhost:8000/list?type=demo

---

## ✅ What Was Implemented

### Core Functionality
1. **Auto-change Ready → Active** when you type in notes field
2. **Auto-revert Active → Ready** when you clear notes (if auto-changed)
3. **Manual override** - clicking status button disables auto-behavior
4. **Notes locking** - notes become read-only when status is Done
5. **Flag persistence** - behavior is saved and restored with sessions

### Technical Implementation
- **Hybrid flag storage system:**
  - Template rows (from JSON): Uses DOM `data-status-flag` attribute
  - Manual rows (user-added): Uses `window.checkpointTableState` object
- **Backward compatible** with old saved sessions
- **Works on ALL rows** - both template and manually added

---

## 🧪 Test Scenarios

### ✅ Test 1: Basic Auto-Change (Ready → Active)

**Steps:**
1. Open http://localhost:8000/list?type=demo
2. Find task "1.1" - status should be **Ready** (green checkmark)
3. Click in the Notes field for task 1.1
4. Type any text (e.g., "testing auto-status")
5. **Expected:** Status automatically changes to **Active** (orange icon)
6. Open browser console (F12), look for: `[Auto-Status] 1.1: Ready → Active (notes added, flag set to active-auto)`

**Result:** ⬜ Pass | ⬜ Fail

---

### ✅ Test 2: Auto-Revert (Active → Ready)

**Steps:**
1. Continue from Test 1 (task 1.1 should be Active with notes)
2. Clear ALL text from the Notes field (delete everything)
3. **Expected:** Status automatically changes back to **Ready** (green icon)
4. Console message: `[Auto-Status] 1.1: Active → Ready (notes cleared, flag reset to text-manual)`

**Result:** ⬜ Pass | ⬜ Fail

---

### ✅ Test 3: Manual Override (No Auto-Revert)

**Steps:**
1. Find task "1.2" - status should be Ready
2. **Click the status button** (don't type notes first)
3. Status changes to Active (orange) - flag is now `active-manual`
4. Now type some text in the Notes field
5. **Expected:** Status stays Active (no auto-change)
6. Clear all text from Notes field
7. **Expected:** Status stays Active (no auto-revert)
8. Console should show: `[Auto-Status] 1.2: No auto-change (flag is active-manual)`

**Result:** ⬜ Pass | ⬜ Fail

---

### ✅ Test 4: Notes Locking When Done

**Steps:**
1. Find task "1.3"
2. Type some notes: "This task is complete"
3. Click status button → Active
4. Click status button again → **Done** (blue checkmark)
5. **Expected:**
   - Notes field is **disabled/grayed out**
   - Cannot edit notes
   - Reset button becomes **visible**
6. Click status button again (cycles back to Ready)
7. **Expected:**
   - Notes field becomes **editable** again
   - Notes text is **preserved** (not cleared)
   - Reset button becomes **hidden**

**Result:** ⬜ Pass | ⬜ Fail

---

### ✅ Test 5: Reset Button Clears Everything

**Steps:**
1. Find task "1.4"
2. Type notes: "Will be reset"
3. Status auto-changes to Active
4. Click status button → Done
5. **Expected:** Reset button is visible
6. Click **Reset** button
7. **Expected:**
   - Status changes to **Ready**
   - Notes field is **empty**
   - Notes field is **editable**
   - Reset button is **hidden**
   - Console: `[Reset] 1.4: Flag reset to text-manual`

**Result:** ⬜ Pass | ⬜ Fail

---

### ✅ Test 6: Manual Row (User-Added)

**Steps:**
1. Scroll to any checkpoint (e.g., checkpoint-1)
2. Click the **"Add Row"** button at the bottom of the table
3. A new row appears with empty task and notes fields
4. Type in the **Notes** field for the new row
5. **Expected:** Status auto-changes from Ready to Active
6. Clear the notes
7. **Expected:** Status auto-reverts to Ready
8. **Verify:** Manual rows work exactly like template rows

**Result:** ⬜ Pass | ⬜ Fail

---

### ✅ Test 7: Session Persistence

**Steps:**
1. Find task "2.1"
2. Type notes: "Testing persistence"
3. Status auto-changes to Active (flag = `active-auto`)
4. Copy the current URL (with session key)
5. Click the **Save** button (footer)
6. Wait for "Saved at [time]" message
7. **Reload the page** (F5)
8. **Expected:**
   - Task 2.1 still shows Active status
   - Notes are still there: "Testing persistence"
   - Flag is preserved as `active-auto`
9. Clear the notes
10. **Expected:** Status auto-reverts to Ready (because flag was `active-auto`)

**Result:** ⬜ Pass | ⬜ Fail

---

### ✅ Test 8: Flag Reset After Cycle

**Steps:**
1. Find task "2.2"
2. Click status button (manual change) → Active (flag = `active-manual`)
3. Click status button → Done
4. Click status button → Ready (cycles back)
5. **Expected:** Flag resets to `text-manual` (default)
6. Type notes
7. **Expected:** Status auto-changes to Active (auto-behavior works again)
8. Console: `[Auto-Status] 2.2: Ready → Active`

**Result:** ⬜ Pass | ⬜ Fail

---

## 🔍 Console Debugging

Open browser console (F12 → Console tab) to see debug messages:

### Expected Console Messages

**Auto-Status Change:**
```
[Auto-Status] 1.1: Ready → Active (notes added, flag set to active-auto)
[StatusFlag] 1.1: Set to active-auto (in DOM)
```

**Auto-Revert:**
```
[Auto-Status] 1.1: Active → Ready (notes cleared, flag reset to text-manual)
[StatusFlag] 1.1: Set to text-manual (in DOM)
```

**Manual Override:**
```
[Manual-Status] 1.2: Flag set to active-manual
[StatusFlag] 1.2: Set to active-manual (in DOM)
```

**No Auto-Change (Manual Flag):**
```
[Auto-Status] 1.2: No auto-change (flag is active-manual)
```

**Reset:**
```
[Status-Reset] 1.4: Flag reset to text-manual
[Reset] 1.4: Flag reset to text-manual
```

---

## 🎨 Visual Indicators

### Status Icons
- **Ready (Ready):** Green checkmark icon (`ready-1.svg`)
- **Active (In Progress):** Orange circular arrow icon (`active-1.svg`)
- **Done (Completed):** Blue checkmark with circle (`done-1.svg`)

### Notes Field States
- **Editable:** White background, cursor visible, can type
- **Locked (Done):** Gray background, cursor not-allowed, disabled

### Reset Button
- **Hidden:** When status is Ready or Active
- **Visible:** Only when status is Done

---

## 🐛 Known Edge Cases

### Whitespace-Only Notes
**Behavior:** Typing only spaces does NOT trigger auto-status change
- The system uses `.trim()` to check if notes are truly empty
- This prevents accidental status changes from whitespace

### Rapid Typing/Deleting
**Behavior:** Quick type → delete cycles work correctly
- May see rapid Ready → Active → Ready in console
- System handles this gracefully without errors

### Old Saved Sessions
**Backward Compatibility:** Sessions saved before this feature was added
- Will default to `text-manual` flag
- Auto-behavior will work correctly after reload

---

## ✨ Success Criteria

The feature is working correctly if:

- ✅ All 8 test scenarios pass
- ✅ No console errors appear
- ✅ Auto-status works on template rows (from JSON)
- ✅ Auto-status works on manual rows (user-added)
- ✅ Manual overrides are respected
- ✅ Notes lock when status is Done
- ✅ Reset clears everything correctly
- ✅ Flags persist across page reloads
- ✅ Old sessions still work without errors

---

## 📊 Test Results Summary

| Test | Description | Result | Notes |
|------|-------------|--------|-------|
| 1 | Auto-change Ready→Active | ⬜ | |
| 2 | Auto-revert Active→Ready | ⬜ | |
| 3 | Manual override | ⬜ | |
| 4 | Notes locking | ⬜ | |
| 5 | Reset button | ⬜ | |
| 6 | Manual rows | ⬜ | |
| 7 | Persistence | ⬜ | |
| 8 | Flag reset | ⬜ | |

**Overall Status:** ⬜ All Pass | ⬜ Some Fail | ⬜ Not Tested

---

## 🔧 Troubleshooting

### Issue: Auto-status not working
**Check:**
1. Open console - any errors?
2. Check if `data-status-flag` attribute exists on status buttons
3. Verify StateEvents listeners are setup (console should show "Global event listeners setup complete")

### Issue: Console shows "Task not found in state or DOM"
**Fix:**
- This is a warning, not an error
- Usually happens for rows that don't exist yet
- Should not affect functionality

### Issue: Notes field not locking when Done
**Check:**
1. Verify status button shows `data-state="done"`
2. Check textarea for `disabled` attribute
3. Check textarea for `textarea-done` class

---

## 📚 Related Documentation

- **Feature Specification:** `docs/features/note-status-logic.md`
- **Implementation Plan:** `docs/features/note-status-logic-IMPLEMENTATION-PLAN.md`
- **Changelog Entry:** `changelog.md` (line 11)

---

**Testing done by:** ___________________
**Date:** ___________________
**Result:** ⬜ Pass | ⬜ Fail | ⬜ Needs Revision

---

_Happy Testing! 🚀_
