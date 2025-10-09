# JSON v0.8 Update Analysis - Side Panel Branch

**Date**: October 8, 2025
**Branch**: `side-panel`
**Purpose**: Document all changes needed to support new JSON format

---

## 📋 JSON Format Changes (v0.8)

### **What Changed:**
```json
OLD (pre-v0.8):
{
  "type": "Word",
  "showRobust": true,
  "checklist-1": { "caption": "...", "table": [...] },
  "checklist-2": { "caption": "...", "table": [...] },
  "checklist-3": { "caption": "...", "table": [...] },
  "checklist-4": { "caption": "...", "table": [...] }
}

NEW (v0.8):
{
  "version": "0.8",
  "type": "Word",
  "checkpoint-1": { "caption": "...", "table": [...] },
  "checkpoint-2": { "caption": "...", "table": [...] },
  "checkpoint-3": { "caption": "...", "table": [...] },
  "checkpoint-4": { "caption": "...", "table": [...] }
}
```

### **Key Changes:**
1. ✅ **Naming**: `checklist-1/2/3/4` → `checkpoint-1/2/3/4`
2. ✅ **Version tracking**: Added `"version": "0.8"`
3. ✅ **showRobust removed**: Replaced with dynamic checkpoint detection
4. ✅ **Info field**: `"show": "placeholder"` → `"info": "placeholder"` (already done)
5. ✅ **Variable checkpoints**: Camtasia has 3, others have 4

---

## 🔍 CURRENT IMPLEMENTATION ISSUES

### **Problem 1: Hardcoded "checklist-" everywhere**

**Current state**: System uses "checklist-1/2/3/4" in:
- HTML IDs and data-target attributes
- JavaScript references
- CSS classes
- Side panel navigation

**Impact**: Won't match new JSON keys "checkpoint-1/2/3/4"

---

## 🎯 SIDE PANEL DYNAMIC GENERATION REQUIREMENTS

### **New Requirements (User Specified):**

1. ✅ **Minimum Requirement**: Must have `checkpoint-1` in JSON
   - No checkpoint-1 = no side panel list displayed
   - Validate before rendering

2. ✅ **Flexible Count**: Support 2-10 checkpoints
   - Dynamic reading from JSON
   - Not hardcoded

3. ✅ **Icon Pattern**: `number-N-0.svg` and `number-N-1.svg`
   - Currently: number-1 through number-4
   - Future: Will add number-5 through number-10
   - Pattern preserved

4. ✅ **Position**: Top position stays the same
   - Don't move side panel up/down
   - Maintain current CSS `top` value

5. ✅ **Dynamic Height**: Calculate based on checkpoint count
   - **Formula**:
     ```
     height = 15px (top padding) +
              (N checkpoints × 36px button height) +
              ((N-1) × 15px spacing between buttons) +
              15px (bottom padding)
     ```
   - **Apply to**: Both `.side-panel` AND `.toggle-strip`

### **Height Calculation Examples:**

**2 checkpoints**: 15 + 36 + 15 + 36 + 15 = **117px**
**3 checkpoints** (Camtasia): 15 + 36 + 15 + 36 + 15 + 36 + 15 = **168px**
**4 checkpoints** (Word, most): 15 + (4×36) + (3×15) + 15 = **219px**
**5 checkpoints**: 15 + (5×36) + (4×15) + 15 = **270px**
**10 checkpoints**: 15 + (10×36) + (9×15) + 15 = **525px**

### **Whitespace Requirements:**
- **Top padding**: 15px
- **Bottom padding**: 15px
- **Between buttons**: 15px (using CSS `gap` or margins)

---

## 📄 HTML UPDATES NEEDED

### **File: `php/mychecklist.php`**

**Lines 38-68: Side Panel Structure**

**Current (HARDCODED - 4 buttons):**
```html
<nav class="side-panel" aria-expanded="true">
    <ul id="side-panel">
        <li>
            <a href="javascript:void(0)" data-target="checklist-1" ...>
                <img src=".../number-1-1.svg" ... class="active-state" ...>
                <img src=".../number-1-0.svg" ... class="inactive-state" ...>
            </a>
        </li>
        <!-- ... hardcoded for 2, 3, 4 ... -->
    </ul>
    <button class="toggle-strip">...</button>
</nav>
```

**Needed Change (DYNAMIC - Empty container):**
```html
<nav class="side-panel" aria-expanded="true">
    <ul id="side-panel">
        <!-- JavaScript will generate checkpoint buttons dynamically (2-10) -->
    </ul>
    <button class="toggle-strip">...</button>
</nav>
```

**Impact**:
- Remove all hardcoded `<li>` items
- JavaScript will populate based on JSON checkpoint count
- Height will be applied dynamically

---

## 💻 JAVASCRIPT UPDATES NEEDED

### **NEW FILE NEEDED: `js/side-panel-generator.js`**

**Purpose**: Dynamically generate side panel checkpoint buttons

**Requirements**:
1. Parse JSON to find all `checkpoint-*` keys (must have checkpoint-1)
2. Sort checkpoints by number (1, 2, 3, ...)
3. Generate `<li>` elements with checkpoint buttons
4. Calculate height based on count
5. Apply height to `.side-panel` and `.toggle-strip`

**Implementation**:
```javascript
function generateSidePanel(jsonData) {
    // 1. Find all checkpoint keys
    const checkpoints = Object.keys(jsonData)
        .filter(key => key.startsWith('checkpoint-'))
        .sort((a, b) => {
            const numA = parseInt(a.split('-')[1]);
            const numB = parseInt(b.split('-')[1]);
            return numA - numB;
        });

    // 2. Validate minimum requirement
    if (!checkpoints.includes('checkpoint-1')) {
        console.error('No checkpoint-1 found in JSON - cannot render side panel');
        return;
    }

    // 3. Calculate height
    const count = checkpoints.length;
    const buttonHeight = 36; // px
    const spacing = 15; // px
    const topPadding = 15; // px
    const bottomPadding = 15; // px

    const totalHeight = topPadding +
                       (count * buttonHeight) +
                       ((count - 1) * spacing) +
                       bottomPadding;

    console.log(`Side panel height for ${count} checkpoints: ${totalHeight}px`);

    // 4. Apply height to side panel and toggle strip
    const sidePanel = document.querySelector('.side-panel');
    const toggleStrip = document.querySelector('.toggle-strip');

    if (sidePanel) {
        sidePanel.style.height = `${totalHeight}px`;
    }
    if (toggleStrip) {
        toggleStrip.style.height = `${totalHeight}px`;
    }

    // 5. Generate checkpoint buttons
    const sidePanelUl = document.getElementById('side-panel');
    if (!sidePanelUl) return;

    sidePanelUl.innerHTML = ''; // Clear existing

    checkpoints.forEach((checkpointKey, index) => {
        const num = checkpointKey.split('-')[1];
        const isFirst = (index === 0);

        const li = document.createElement('li');
        if (index === checkpoints.length - 1) {
            li.id = `${checkpointKey}-section`; // Last checkpoint gets ID
        }

        const a = document.createElement('a');
        a.href = 'javascript:void(0)';
        a.setAttribute('data-target', checkpointKey);
        a.setAttribute('aria-label', `Checkpoint ${num}`);
        a.setAttribute('title', `View Checkpoint ${num}`);
        if (isFirst) a.className = 'infocus';

        // Active state icon
        const activeImg = document.createElement('img');
        activeImg.src = window.getImagePath(`number-${num}-1.svg`);
        activeImg.alt = `Checkpoint ${num} table`;
        activeImg.className = 'active-state';
        activeImg.width = 36;
        activeImg.height = 36;

        // Inactive state icon
        const inactiveImg = document.createElement('img');
        inactiveImg.src = window.getImagePath(`number-${num}-0.svg`);
        inactiveImg.alt = `Checkpoint ${num} table`;
        inactiveImg.className = 'inactive-state';
        inactiveImg.width = 36;
        inactiveImg.height = 36;

        a.appendChild(activeImg);
        a.appendChild(inactiveImg);
        li.appendChild(a);
        sidePanelUl.appendChild(li);
    });
}

// Call during initialization
window.generateSidePanel = generateSidePanel;
```

**CSS Update Needed:**
```css
/* css/side-panel.css */
.side-panel ul {
    padding: 15px 0; /* Top and bottom padding */
    gap: 15px; /* Space between li items */
    display: flex;
    flex-direction: column;
}

.side-panel, .toggle-strip {
    /* height set dynamically by JavaScript */
    /* Remove any fixed height values */
}
```

---

### **File: `js/buildPrinciples.js`**

**Lines 49-60: Table Number Extraction**

**Current (HARDCODED):**
```javascript
if (principleId === 'checklist-1') {
    tableNumber = '1';
} else if (principleId === 'checklist-2') {
    tableNumber = '2';
} else if (principleId === 'checklist-3') {
    tableNumber = '3';
} else if (principleId === 'checklist-4') {
    tableNumber = '4';
}
```

**Needed Change (DYNAMIC):**
```javascript
// Extract number from checkpoint-N or checklist-N format
const match = principleId.match(/(?:checkpoint|checklist)-(\d+)/);
const tableNumber = match ? match[1] : null;

if (!tableNumber) {
    console.warn(`Unknown principle ID format: ${principleId}`);
}
```

**Lines 280-283: Add Row Icons**

**Current:**
```javascript
'checklist-1': 'add-1.svg',
'checklist-2': 'add-2.svg',
'checklist-3': 'add-3.svg',
'checklist-4': 'add-4.svg'
```

**Needed Change:**
```javascript
'checkpoint-1': 'add-1.svg',
'checkpoint-2': 'add-2.svg',
'checkpoint-3': 'add-3.svg',
'checkpoint-4': 'add-4.svg'
```

**Lines 371-376: Skip checkpoint logic**

**Current:**
```javascript
if (principleId !== 'report' && principleId !== 'type' && principleId !== 'showRobust') {
    if (principleId === 'checklist-4' && !data.showRobust) {
        console.log(`Skipping ${principleId} - showRobust is false`);
        return;
    }
}
```

**Needed Change (DYNAMIC DETECTION):**
```javascript
if (principleId !== 'report' && principleId !== 'type' && principleId !== 'version') {
    // No skip logic needed - just iterate over what's in JSON
    // If checkpoint-4 doesn't exist in JSON, loop won't process it
}
```

---

### **File: `js/main.js`**

**Lines 108-126: Checkpoint-4 visibility**

**Current:**
```javascript
const checklist4Section = document.getElementById('checklist-4-section');
if (checklist4Section) {
    const isVisible = data.showRobust;
    checklist4Section.style.display = isVisible ? 'block' : 'none';
    // ...
}
```

**Needed Change (DYNAMIC DETECTION):**
```javascript
const checkpoint4Section = document.getElementById('checkpoint-4-section');
if (checkpoint4Section) {
    // Check if checkpoint-4 exists in JSON data
    const hasCheckpoint4 = 'checkpoint-4' in data;
    checkpoint4Section.style.display = hasCheckpoint4 ? 'block' : 'none';
    checkpoint4Section.setAttribute('aria-hidden', (!hasCheckpoint4).toString());
    // ...
}
```

---

### **File: `js/StateManager.js`**

**Lines 143-146: principleRows initialization**

**Current (HARDCODED):**
```javascript
principleRows: {
  'checklist-1': [],
  'checklist-2': [],
  'checklist-3': [],
  'checklist-4': []
}
```

**Needed Change (DYNAMIC):**
```javascript
principleRows: this.initializePrincipleRows()

// New method:
initializePrincipleRows() {
  const rows = {};
  if (window.checklistData) {
    Object.keys(window.checklistData).forEach(key => {
      if (key.startsWith('checkpoint-')) {
        rows[key] = [];
      }
    });
  }
  return rows;
}
```

**Lines 226, 230: Side panel defaults**

**Current:**
```javascript
const activeSection = activeLink ? ... : 'checklist-1';
```

**Needed Change:**
```javascript
const activeSection = activeLink ? ... : 'checkpoint-1';
```

**Line 287: Iterate checkpoints**

**Current:**
```javascript
['checklist-1', 'checklist-2', 'checklist-3', 'checklist-4'].forEach(principleId => {
```

**Needed Change (DYNAMIC):**
```javascript
Object.keys(window.checklistData || {}).forEach(principleId => {
  if (principleId.startsWith('checkpoint-')) {
    // Process this checkpoint
  }
});
```

---

### **File: `js/report.js`**

**Line 136: Comment update**

**Current:**
```javascript
// JSON format: { "checklist-1": { caption, table }, "checklist-2": {...}, ... }
```

**Needed Change:**
```javascript
// JSON format: { "checkpoint-1": { caption, table }, "checkpoint-2": {...}, ... }
```

**Line 433: Extract checkpoint number**

**Current (HARDCODED for "checklist-"):**
```javascript
const checkpointNum = principleId.split('-')[1];
```

**Needed Change (FLEXIBLE):**
```javascript
// Handle both checkpoint-N and checklist-N formats
const match = principleId.match(/(?:checkpoint|checklist)-(\d+)/);
const checkpointNum = match ? match[1] : '0';
```

---

## 🎨 CSS UPDATES NEEDED

### **File: `css/*.css`**

**Search for:**
- `.checklist-1`, `.checklist-2`, `.checklist-3`, `.checklist-4`
- `#checklist-1`, `#checklist-2`, `#checklist-3`, `#checklist-4`
- `#checklist-4-section`

**Needed:**
- Update to `.checkpoint-1`, etc.
- Update to `#checkpoint-1`, etc.
- Update to `#checkpoint-4-section`

**OR (Better):**
- Keep generic classes that don't reference numbers
- Use `.principle-section` instead of numbered classes

---

## 🔧 IMPLEMENTATION STRATEGY

### **Phase 1: Backward Compatibility Layer**
1. Create utility function to normalize keys:
```javascript
function normalizeCheckpointKey(key) {
  // Convert checklist-N to checkpoint-N
  return key.replace(/^checklist-/, 'checkpoint-');
}

function getCheckpointData(data, num) {
  // Try checkpoint-N first, fallback to checklist-N
  return data[`checkpoint-${num}`] || data[`checklist-${num}`];
}
```

### **Phase 2: Update HTML**
1. Change all `data-target="checklist-N"` to `data-target="checkpoint-N"`
2. Change `id="checklist-4-section"` to `id="checkpoint-4-section"`

### **Phase 3: Update JavaScript**
1. Replace hardcoded "checklist-" strings with "checkpoint-"
2. Replace hardcoded arrays/objects with dynamic detection
3. Remove `showRobust` logic, use dynamic checkpoint detection
4. Update number extraction to use regex pattern

### **Phase 4: Dynamic Detection**
1. Iterate `Object.keys(data)` to find all `checkpoint-*` entries
2. Generate side panel items dynamically (2-10 checkpoints)
3. Initialize principleRows dynamically
4. No hardcoded checkpoint counts

### **Phase 5: Testing**
1. Test with Camtasia (3 checkpoints)
2. Test with Word (4 checkpoints)
3. Test with all 7 checklist types
4. Verify backward compatibility with old saves

---

## 📊 FILE IMPACT SUMMARY

| File | Lines Changed | Complexity | Priority |
|------|--------------|------------|----------|
| `mychecklist.php` | ~20 lines | Low | HIGH |
| `buildPrinciples.js` | ~50 lines | Medium | HIGH |
| `main.js` | ~30 lines | Low | HIGH |
| `StateManager.js` | ~40 lines | High | HIGH |
| `report.js` | ~10 lines | Low | MEDIUM |
| `StateEvents.js` | ~10 lines | Low | LOW |
| `CSS files` | ~20 lines | Low | MEDIUM |

**Total Estimated Changes**: ~180 lines across 7-10 files

---

## ⚠️ BREAKING CHANGES

### **Potential Issues:**

1. **Saved Sessions**: Old saves use "checklist-1/2/3/4" in state
   - **Solution**: Add backward compatibility in state restoration

2. **URLs**: May have `#checklist-1` hash fragments
   - **Solution**: Handle both formats in URL parsing

3. **CSS Selectors**: May break if using ID selectors
   - **Solution**: Use class selectors instead

---

## ✅ RECOMMENDED APPROACH

### **Option 1: Full Migration (Recommended)**
- Update all references to use "checkpoint-*"
- Add backward compatibility for old data
- Clean, future-proof solution
- ~4-6 hours of work

### **Option 2: Compatibility Layer**
- Keep internal "checklist-*" IDs
- Convert JSON "checkpoint-*" to "checklist-*" on load
- Faster but maintains technical debt
- ~2-3 hours of work

### **Option 3: Hybrid**
- Use "checkpoint-*" in new code
- Support both formats dynamically
- Best for gradual migration
- ~3-4 hours of work

---

## 🎯 IMPLEMENTATION PLAN

### **Phase 1: Create Side Panel Generator** ✅ CONFIRMED
1. Create `js/side-panel-generator.js`
2. Implement dynamic checkpoint detection
3. Implement height calculation (15px spacing)
4. Generate `<li>` elements dynamically
5. Apply height to `.side-panel` and `.toggle-strip`

### **Phase 2: Update HTML** ✅ CONFIRMED
1. Remove hardcoded `<li>` items from `mychecklist.php`
2. Keep empty `<ul id="side-panel"></ul>` container
3. Add script import for side-panel-generator.js

### **Phase 3: Update CSS** ✅ CONFIRMED
1. Add `padding: 15px 0` to `.side-panel ul`
2. Add `gap: 15px` for spacing between buttons
3. Remove fixed height from `.side-panel` and `.toggle-strip`
4. Update any `#checklist-*` selectors to `#checkpoint-*`

### **Phase 4: Update All JavaScript** ✅ CONFIRMED
1. `buildPrinciples.js` - Dynamic number extraction, checkpoint keys
2. `main.js` - Dynamic checkpoint-4 detection, call generateSidePanel()
3. `StateManager.js` - Dynamic principleRows initialization
4. `report.js` - Flexible checkpoint number extraction
5. Update all "checklist-" → "checkpoint-"

### **Phase 5: Testing** ✅ CONFIRMED
1. Test Camtasia (3 checkpoints) - Height should be 168px
2. Test Word (4 checkpoints) - Height should be 219px
3. Test all 7 types
4. Verify backward compatibility with existing saves
5. Test side panel navigation clicks

---

## 📐 TECHNICAL SPECIFICATIONS

### **Side Panel Height Formula:**
```
height = topPadding + (count × buttonHeight) + ((count-1) × spacing) + bottomPadding
height = 15 + (N × 36) + ((N-1) × 15) + 15
```

### **Validation Rules:**
- Must have `checkpoint-1` (minimum requirement)
- Support 2-10 checkpoints
- If no checkpoint-1: Don't render side panel

### **Spacing System:**
- Top padding: 15px
- Bottom padding: 15px
- Between buttons: 15px (CSS gap)
- Button dimensions: 36px × 36px (existing)

### **Position Preservation:**
- Current `.side-panel` top position: MAINTAINED
- No changes to vertical position from top of page
- Only height changes dynamically

---

## 🔧 EXECUTION ORDER

1. **First**: Create `js/side-panel-generator.js` with dynamic generation
2. **Second**: Update `php/mychecklist.php` to remove hardcoded HTML
3. **Third**: Update CSS for spacing and dynamic height
4. **Fourth**: Update all other JS files for "checkpoint-" naming
5. **Fifth**: Test with all checklist types
6. **Sixth**: Verify backward compatibility

---

## 🎯 NEXT STEPS

**Status**: ✅ Requirements confirmed, ready to implement

**Awaiting**: Go-ahead to begin implementation

---

**READY TO PROCEED WITH SIDE PANEL DYNAMIC GENERATION!** 🚀

