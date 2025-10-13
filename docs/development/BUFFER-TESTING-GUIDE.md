# Buffer Calculation Testing Guide

## Overview

The dynamic scroll buffer system includes a comprehensive automated test suite to validate buffer calculations across different scenarios.

## Running the Tests

### Quick Test (Browser Console)

1. Open `mychecklist.php` in your browser
2. Open browser DevTools console (F12)
3. Run the test suite:

```javascript
window.ScrollManager.runBufferTests()
```

or

```javascript
window.testBufferCalculation()
```

### What Gets Tested

The test suite validates three critical scenarios:

#### Test 1: All Checkpoints Visible
- Shows all checkpoints
- Measures total content height
- Validates buffer calculation for maximum content
- Expected: Uses viewport-based OR content-based (whichever is smaller)
- Target: Content stops 50px above footer

#### Test 2: Single Checkpoint (Default)
- Shows only Checkpoint 1
- Measures single checkpoint height (no manual rows)
- Validates buffer for minimal content
- Expected: Usually content-based (content < viewport)
- Target: Content stops 50px above footer

#### Test 3: Single Checkpoint + Manual Row
- Adds a manual row to Checkpoint 1
- Measures increased content height
- Validates buffer recalculation after dynamic content change
- Expected: Content-based with adjusted height
- Target: Content stops 50px above footer
- Cleans up test row after validation

## Test Output

### Console Output Example

```
🧪 ========================================
🧪 BUFFER CALCULATION TEST SUITE
🧪 ========================================

📋 TEST 1: All Checkpoints Visible
─────────────────────────────────────
✓ Content height: 2650px
✓ Viewport height: 1000px
✓ Viewport-based buffer: 850px
✓ Content-based buffer: -1840px (negative = use viewport-based)
✓ Expected buffer (MIN): 850px (viewport-based)
✓ Calculated buffer: 850px
✅ PASS

📋 TEST 2: Single Checkpoint (Default)
─────────────────────────────────────
✓ Content height: 650px
✓ Viewport height: 1000px
✓ Viewport-based buffer: 850px
✓ Content-based buffer: 160px
✓ Expected buffer (MIN): 160px (content-based)
✓ Calculated buffer: 160px
✅ PASS

📋 TEST 3: Single Checkpoint + Manual Row
─────────────────────────────────────
✓ Content height before: 650px
✓ Content height after: 725px
✓ Height increase: 75px
✓ Viewport height: 1000px
✓ Viewport-based buffer: 850px
✓ Content-based buffer: 85px
✓ Expected buffer (MIN): 85px (content-based)
✓ Calculated buffer: 85px
✅ PASS

🔄 Restoring original state...

🧪 ========================================
🧪 TEST SUMMARY
🧪 ========================================

┌─────────────────────┬──────────┬─────────────┬─────────────────┬──────────────────┬────────────┐
│       (index)       │ Expected │ Calculated  │ Content Height  │   Logic Used     │   Result   │
├─────────────────────┼──────────┼─────────────┼─────────────────┼──────────────────┼────────────┤
│  All Checkpoints    │ '850px'  │   '850px'   │    '2650px'     │ 'viewport-based' │ '✅ PASS'  │
│ Single (Default)    │ '160px'  │   '160px'   │    '650px'      │ 'content-based'  │ '✅ PASS'  │
│  Single + Row       │  '85px'  │    '85px'   │    '725px'      │ 'content-based'  │ '✅ PASS'  │
└─────────────────────┴──────────┴─────────────┴─────────────────┴──────────────────┴────────────┘

🎉 ALL TESTS PASSED!
```

## Understanding the Results

### Buffer Calculation Logic

```javascript
// CASE 1: Content LARGER than viewport (e.g., All mode with many checkpoints)
if (content > viewport - topBuffer) {
    buffer = viewport - 500
    // Example: 1957 - 500 = 1457px
    // Positions last content bottom at 500px from viewport top
    // Includes header (60px) + 440px spacing
}

// CASE 2: Content SMALLER than viewport (e.g., single short checkpoint)
else {
    buffer = 0
    // Content fits in viewport - no scrolling needed
    // Prevents visual jump and unnecessary scroll space
}

// Result: Last content at 500px from top (All mode) or no scrolling (single checkpoint)
```

### "Logic Used" Interpretation

- **large-content (dynamic)**: Content is larger than viewport
  - Uses buffer = viewport - 500px (e.g., 1957 - 500 = 1457px)
  - Common for "All checkpoints" mode
  - Positions last content bottom at 500px from viewport top when scrolled to max
  - Target includes header (60px) + 440px spacing below

- **small-content (zero buffer)**: Content is smaller than viewport
  - Uses buffer = 0px
  - Common for single checkpoint mode
  - Content fits in viewport - no scrolling needed
  - Prevents visual jump and unnecessary scroll space

### Pass/Fail Criteria

- ✅ **PASS**: Calculated buffer matches expected within 1px (allows for rounding)
- ❌ **FAIL**: Difference > 1px (indicates calculation error)

## Manual Verification

### Visual Check

After running tests, manually verify:

1. **All mode**: Scroll to bottom → last checkpoint bottom should be ~500px from viewport top (includes header)
2. **Single checkpoint**: Should NOT allow scrolling (content fits in viewport, zero buffer)
3. **Manual row**: Add row manually - buffer should adjust, preventing excessive scrolling
4. **Save button**: Click "Save" - buffer should recalculate after save completes

### Console Monitoring

Watch for these logs during normal use:

```javascript
🎯 [Buffer Update Scheduled] Will calculate in 500ms...
🎯 [Section checkpoint-1] Height: 650px
🎯 [Buffer Update Complete] {
  visibleContentHeight: 650,
  viewportHeight: 1000,
  viewportBasedBuffer: 850,
  contentBasedBuffer: 160,
  optimalBuffer: 160,
  calculationTime: "2.45ms"
}
```

## Troubleshooting

### Test Shows FAIL

**Possible causes:**
1. CSS not loaded (`--bottom-buffer` not set)
2. DOM not settled (increase wait time in test)
3. Calculation constants changed (footer height, margin, etc.)
4. Browser zoom level affecting measurements

**Solutions:**
- Reload page and ensure all CSS loaded
- Check browser zoom is at 100%
- Verify constants in `updateBottomBufferNow()` match actual DOM

### Tests Don't Run

**Possible causes:**
1. Script not loaded
2. Function not available
3. DOM not ready

**Solutions:**
- Ensure page fully loaded before running tests
- Check console for script errors
- Verify `window.ScrollManager` exists:
  ```javascript
  console.log(window.ScrollManager)
  ```

## Integration with CI/CD

For automated testing, this test can be integrated with:

- **Playwright/Puppeteer**: Run headless browser tests
- **Jest + JSDOM**: Unit test the calculation logic
- **Cypress**: E2E testing with visual verification

Example Playwright test:

```javascript
test('buffer calculations are correct', async ({ page }) => {
  await page.goto('http://localhost/mychecklist.php');

  const results = await page.evaluate(() => {
    return window.testBufferCalculation();
  });

  expect(results.all.pass).toBe(true);
  expect(results.singleDefault.pass).toBe(true);
  expect(results.singleWithRow.pass).toBe(true);
});
```

## Report Pages Buffer System

### Overview

The report pages (`list-report.php` and `systemwide-report.php`) use the same pseudo-scroll methodology as `mychecklist.php` with adaptations for their table-based content.

### Key Differences from mychecklist.php

| Feature | mychecklist.php | Report Pages |
|---------|-----------------|--------------|
| **Top Buffer** | 90px | 170px |
| **Purpose** | Header offset | Positions h2 below sticky header/filters (70px + 100px) |
| **Bottom Buffer** | Dynamic (viewport - 500px) | Dynamic (viewport - 500px) |
| **CSS Property** | `--bottom-buffer` | `--bottom-buffer-report` |
| **Function** | `updateBottomBufferNow()` | `updateReportBuffer()` |
| **Target Position** | 500px from top | 500px from top |

### Buffer Calculation Formula

```javascript
// Report pages calculation
const topBuffer = 170;  // 70px header + 100px filters
const targetPosition = 500;  // Last row at 500px from top

if (reportContent > viewport - topBuffer) {
    buffer = viewport - targetPosition;  // Last row at 500px from top
} else {
    buffer = 100;  // Minimal buffer for footer spacing
}
```

### Trigger Points

Report buffers update on:
1. **Page load**: After initial table render
2. **Filter changes**: When status/checkpoint filters hide/show rows
3. **Refresh**: After clicking "Refresh" button
4. **Window resize**: When viewport dimensions change

### Testing

**Manual test in browser console:**
```javascript
// Force immediate buffer calculation
window.updateReportBuffer();

// Or schedule with 500ms debounce
window.scheduleReportBufferUpdate();
```

**Check current buffer:**
```javascript
getComputedStyle(document.documentElement)
    .getPropertyValue('--bottom-buffer-report');
```

### Console Logs

Look for these indicators on report pages:
```
🎯 [INLINE SCRIPT] Initial scroll to 5090, waiting for content to build...
🎯 [Report Buffer Scheduled] Will calculate in 500ms...
🎯 [Report Buffer Update] {
  reportContentHeight: 1200,
  viewportHeight: 1957,
  visibleRows: 15,
  optimalBuffer: 1457,
  targetPosition: '500px from top',
  logic: 'large-content (dynamic)'
}
```

### Expected Behavior

| Scenario | Expected Buffer | Result |
|----------|-----------------|--------|
| **Large table** (many rows) | viewport - 500px | Last row stops 500px from viewport top |
| **Small table** (few rows) | 100px | Minimal buffer for footer spacing |
| **Filter to 0 rows** | 100px | Empty state message with minimal buffer |
| **Window resize** | Recalculates | Adapts to new viewport size |

### Visual Verification

1. Load `list-report.php` or `systemwide-report.php`
2. Scroll to bottom of table
3. Verify last row stops ~500px from viewport top
4. Click filter button to show fewer rows
5. Verify buffer adjusts (no excessive scrolling)
6. Resize window
7. Verify buffer recalculates after 500ms

---

## Related Documentation

- [Scroll Buffer Architecture](../architecture/scroll-system.md)
- [Testing Infrastructure](TESTING-INFRASTRUCTURE.md)
- [Changelog Entry: Dynamic Buffer System](../../changelog.md)

