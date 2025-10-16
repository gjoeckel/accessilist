# Event Handler Conflict Analysis Guide

**Last Updated:** 2025-10-13

## Purpose

This guide provides methods and tools to identify duplicate event handlers that could cause conflicts in the codebase.

---

## Quick Reference: Analysis Methods

| Method | Speed | Detail | Best For |
|--------|-------|--------|----------|
| **Simple Grep** | ⚡ Fast | Basic | Quick spot checks |
| **Automated Script** | ⚡⚡ Medium | Good | Regular audits |
| **Codebase Search** | ⚡⚡⚡ Slow | Excellent | Deep analysis |
| **Manual Review** | ⚡⚡⚡⚡ Slowest | Complete | Critical changes |

---

## Method 1: Simple Grep Search (Fastest)

### Find all event listeners:
```bash
grep -rn "addEventListener" js/ --include="*.js"
```

### Find specific selector conflicts:
```bash
# Check if element has both global and direct listeners
grep -n ".toggle-strip" js/StateEvents.js
grep -n ".toggle-strip" js/side-panel.js
```

### Count handlers by file:
```bash
for file in js/*.js; do
  count=$(grep -c "addEventListener" "$file" 2>/dev/null || echo "0")
  if [ "$count" -gt 0 ]; then
    printf "%-30s %2d handlers\n" "$(basename $file)" "$count"
  fi
done
```

---

## Method 2: Automated Script (Recommended)

Run the analysis script:
```bash
./scripts/find-duplicate-handlers.sh
```

**What it checks:**
- Compares global delegation (StateEvents.js) vs direct listeners
- Lists all files with event handlers
- Shows event type distribution
- Flags potential conflicts

---

## Method 3: Semantic Codebase Search

### Find event delegation patterns:
```bash
# Using grep with context
grep -B 5 -A 5 "addEventListener" js/*.js | less
```

### Search for specific elements:
```bash
# Find all code related to toggle button
grep -rn "toggle-strip\|toggleBtn\|setupToggle" js/
```

---

## Common Conflict Patterns

### Pattern 1: Global + Direct Listeners

**Problem:**
```javascript
// File: StateEvents.js (GLOBAL)
document.addEventListener('click', (e) => {
    const toggle = e.target.closest('.toggle-strip');
    if (toggle) {
        // Handle toggle → Executes FIRST
    }
});

// File: side-panel.js (DIRECT)
this.toggleBtn.addEventListener('click', () => {
    // Handle toggle → Executes SECOND
    // CONFLICT: Toggles twice!
});
```

**Solution:** Remove direct listener, use global delegation only.

---

### Pattern 2: Multiple Direct Listeners

**Problem:**
```javascript
// File: main.js
document.querySelector('.save-button').addEventListener('click', save);

// File: StateManager.js
document.querySelector('.save-button').addEventListener('click', save);

// CONFLICT: save() runs twice
```

**Solution:** Consolidate into single listener or use event delegation.

---

### Pattern 3: Event Bubbling Conflicts

**Problem:**
```javascript
// Parent listener
container.addEventListener('click', handleContainer);

// Child listener with stopPropagation
child.addEventListener('click', (e) => {
    e.stopPropagation(); // Breaks parent handler
    handleChild();
});
```

**Solution:** Use event delegation at parent level only.

---

## Current Architecture

### Global Event Delegation (StateEvents.js)

**Handles these elements on list.php:**
- `.status-button` - Status buttons (click)
- `.restart-button` - Reset buttons (click)
- `.toggle-strip` - Side panel toggle (click)
- `.checklist-caption` - Checklist captions (click)
- All `textarea` elements - Notes and task inputs (input)

**Why global delegation?**
- Single event listener for entire document
- Handles dynamically added elements
- Better performance (fewer listeners)
- Centralized event handling logic

---

### Direct Listeners (Other Files)

**side-panel.js:**
- `.checkpoint-btn` - Navigation buttons (click)
- `.toggle-strip` - Keyboard support ONLY (keydown)

**list-report.js:**
- `.filter-button` - Filter buttons (click)
- `.checkpoint-btn` - Navigation buttons (click)
- `.toggle-strip` - Both click and keydown (no StateEvents on this page)

**addRow.js:**
- Add row buttons (click)

**buildPrinciples.js:**
- `.info-link` - Info modal buttons (click)

---

## Conflict Detection Checklist

When adding new event handlers, check:

### ✅ Step 1: Check Global Delegation
```bash
grep -n "e.target.closest('.YOUR-SELECTOR')" js/StateEvents.js
```

**If found:** Add logic to StateEvents.js, don't create direct listener.

### ✅ Step 2: Check Direct Listeners
```bash
grep -rn ".YOUR-SELECTOR.*addEventListener" js/
```

**If found:** Review why direct listener is needed.

### ✅ Step 3: Test Both Input Methods
- Mouse click
- Keyboard (Enter/Space if button)
- Touch (mobile devices)

### ✅ Step 4: Check Console Logs
Look for:
- Double execution (handler runs twice)
- Missing execution (handler blocked)
- Error messages

---

## Best Practices

### 1. Prefer Global Delegation

✅ **DO:**
```javascript
// In StateEvents.js
document.addEventListener('click', (e) => {
    const myButton = e.target.closest('.my-button');
    if (myButton) {
        handleMyButton(myButton);
    }
});
```

❌ **DON'T:**
```javascript
// In random-file.js
document.querySelector('.my-button').addEventListener('click', handleMyButton);
```

### 2. Document Exceptions

When direct listeners are necessary, document why:
```javascript
// Direct listener needed because:
// - This page doesn't use StateEvents.js
// - Keyboard-only listener (clicks handled by StateEvents)
// - Third-party component requirement
this.element.addEventListener('click', handler);
```

### 3. Use Comments for Clarity

```javascript
// Mouse clicks handled by StateEvents.js global delegation
// This listener is for keyboard support only
this.toggleBtn.addEventListener('keydown', (event) => {
    if (event.key === 'Enter' || event.key === ' ') {
        togglePanel();
    }
});
```

### 4. Test After Changes

```bash
# Run analysis after adding handlers
./scripts/find-duplicate-handlers.sh

# Check for conflicts
grep -A 5 "POTENTIAL CONFLICT" scripts/output.log
```

---

## Troubleshooting Guide

### Symptom: Button does nothing when clicked

**Possible causes:**
1. Two handlers toggling twice (appears to do nothing)
2. Event propagation stopped
3. Handler not attached yet (timing issue)

**Diagnosis:**
```javascript
// Add temporary logging
element.addEventListener('click', (e) => {
    console.log('Click detected on:', e.target);
    console.log('Current state:', element.getAttribute('aria-expanded'));
});
```

### Symptom: Handler runs twice

**Possible causes:**
1. Global delegation + direct listener
2. Multiple direct listeners
3. Event bubbling through multiple handlers

**Diagnosis:**
```bash
# Find all listeners for element
grep -rn ".YOUR-SELECTOR.*addEventListener" js/

# Check StateEvents.js
grep -n "closest('.YOUR-SELECTOR')" js/StateEvents.js
```

### Symptom: Keyboard works but mouse doesn't (or vice versa)

**Possible causes:**
1. Separate handlers for click vs keydown
2. Event propagation issues
3. Focus state problems

**Solution:**
Extract shared logic:
```javascript
const handleAction = () => {
    // Shared logic here
};

// Mouse
element.addEventListener('click', handleAction);

// Keyboard
element.addEventListener('keydown', (e) => {
    if (e.key === 'Enter' || e.key === ' ') {
        e.preventDefault();
        handleAction();
    }
});
```

---

## Quick Commands Reference

```bash
# Find all addEventListener calls
grep -rn "addEventListener" js/

# Count handlers by file
for f in js/*.js; do echo "$f: $(grep -c addEventListener $f)"; done | sort -t: -k2 -rn

# Find specific element
grep -rn ".toggle-strip" js/

# Check global delegation
grep -n "closest(" js/StateEvents.js

# Find keyboard handlers
grep -rn "keydown.*Enter\|Space" js/

# Find click handlers
grep -rn "addEventListener('click'" js/

# Generate full report
./scripts/find-duplicate-handlers.sh > event-handlers-report.txt
```

---

## Maintenance Schedule

### Weekly
- Run `find-duplicate-handlers.sh` script
- Review any new conflicts

### Before Major Changes
- Document current event handlers
- Plan event delegation strategy
- Test all input methods

### After Adding Features
- Check for new conflicts
- Update this guide if patterns change
- Verify keyboard accessibility

---

## Related Documentation

- [WCAG 2.1 Keyboard Accessibility](https://www.w3.org/WAI/WCAG21/Understanding/keyboard.html)
- [Event Delegation Pattern](https://javascript.info/event-delegation)
- [MDN: addEventListener](https://developer.mozilla.org/en-US/docs/Web/API/EventTarget/addEventListener)

---

## Changelog

**2025-10-13:**
- Initial guide created
- Added automated analysis script
- Documented current architecture
- Added conflict detection checklist
- Included troubleshooting guide
