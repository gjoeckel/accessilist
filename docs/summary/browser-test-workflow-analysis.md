# Browser Test Workflow Analysis

**Date**: October 21, 2025
**Status**: Current implementation uses Puppeteer directly (NOT MCP tools)

---

## 🔍 **CURRENT STATE**

### **Test File**: `scripts/external/browser-test-user-workflow.js`
- **Tool**: Puppeteer (direct library usage)
- **Execution**: Standalone Node.js script
- **Called by**: `scripts/external/test-production.sh` (line 320)
- **MCP Integration**: ❌ NOT using MCP tools

### **Test Runner**: `scripts/external/test-production.sh`
- **Line 320**: `timeout 60 env TEST_URL="$PROD_URL" node ./scripts/external/browser-test-user-workflow.js`
- **Method**: Direct script execution
- **Comments**: References "Puppeteer" on lines 32, 280, 300

---

## ❌ **PROBLEM: NOT USING PLAYWRIGHT MCP TOOLS**

Current workflow:
```
test-production.sh (bash)
    ↓
Calls: node browser-test-user-workflow.js
    ↓
Uses: Puppeteer library directly
    ↓
Result: Hard-coded test script (NOT AI-driven)
```

**Issues**:
1. ❌ Uses Puppeteer (we migrated to Playwright!)
2. ❌ Direct library usage (NOT using MCP tools)
3. ❌ Hard-coded test script (NOT AI-driven)
4. ❌ Misaligned with stated goal: "All testing needs to be AI agent driven"

---

## ✅ **TWO OPTIONS TO FIX**

### **Option A: Convert to Playwright** (Quick Fix)
Keep the standalone script pattern but use Playwright library:

```javascript
// Change line 16 from:
const puppeteer = require("puppeteer");

// To:
const { chromium } = require("playwright");
```

**Pros**: Quick (1 hour), maintains existing workflow
**Cons**: Still hard-coded, still not AI-driven

### **Option B: AI-Driven MCP Testing** (Vision-Aligned) ⭐

Remove the hard-coded script entirely. Replace with AI-driven testing:

**test-production.sh changes**:
```bash
# OLD (line 316-320):
if [ -f "./scripts/external/browser-test-user-workflow.js" ]; then
    timeout 60 env TEST_URL="$PROD_URL" node ./scripts/external/browser-test-user-workflow.js
fi

# NEW:
# Trigger AI-driven test workflow via MCP
echo "Running AI-driven browser tests..."
# AI agent will use playwright-minimal MCP tools to:
# - navigate_and_wait to production URL
# - interact_with user elements
# - extract_and_verify results
# - capture_test_evidence for debugging
```

**Pros**: Fully AI-driven, adaptive, aligns with vision
**Cons**: Requires workflow redesign (2-3 hours)

---

## 🎯 **RECOMMENDATION**

Based on your statement "All testing needs to be AI agent driven":

### **PHASE 1: Quick Migration** (Today, 1 hour)
Convert `browser-test-user-workflow.js` to Playwright library:
- Replace Puppeteer → Playwright
- Keep same test logic
- Update test-production.sh references

### **PHASE 2: AI-Driven Testing** (This week, 2-3 hours)
Replace hard-coded script with AI workflow:
- Create `external-test-browser` workflow
- AI uses playwright-minimal MCP tools
- Adaptive testing based on actual page state

---

## 📋 **DETAILED MIGRATION PLAN**

### **Quick Fix: Update browser-test-user-workflow.js**

**Lines to change**:
```javascript
// Line 16 - Import
- const puppeteer = require("puppeteer");
+ const { chromium } = require("playwright");

// Line 30 - Launch
- const browser = await puppeteer.launch({
+ const browser = await chromium.launch({

// Line 47 - waitUntil
- waitUntil: "networkidle0"
+ waitUntil: "networkidle"

// Line 103 - Selectors
- const checkpoints = await page.$$(".checkpoint-row");
+ const checkpoints = await page.locator(".checkpoint-row").count();

// All page.$() calls → page.locator()
```

**Effort**: ~1 hour
**Benefit**: Works with Playwright immediately

---

## 🚀 **AI-DRIVEN ALTERNATIVE**

Instead of a hard-coded script, create a workflow that triggers AI testing:

**Create**: `.cursor/workflows.json` entry:
```json
{
  "external-test-browser": {
    "name": "external-test-browser",
    "description": "AI-driven browser testing of production",
    "commands": [
      "echo 'Triggering AI-driven browser test...'",
      "# AI will use playwright-minimal MCP tools automatically"
    ]
  }
}
```

**Usage**:
```
You: external-test-browser

AI: I'll test the production environment using Playwright...

[Uses navigate_and_wait]
✅ Home page loaded

[Uses interact_with]
✅ Clicked Word checklist

[Uses extract_and_verify]
✅ Found 4 checkpoints

[Uses capture_test_evidence]
📸 Evidence captured

Test complete: All workflows functional!
```

---

## 📊 **COMPARISON**

| Aspect | Current (Puppeteer Script) | Option A (Playwright Script) | Option B (AI-Driven MCP) |
|--------|---------------------------|------------------------------|--------------------------|
| **Tool** | Puppeteer | Playwright | Playwright MCP |
| **Execution** | Hard-coded script | Hard-coded script | AI-driven adaptive |
| **Flexibility** | Fixed tests only | Fixed tests only | Explores dynamically |
| **Maintenance** | Update script manually | Update script manually | AI adapts to changes |
| **Vision alignment** | ❌ Not AI-driven | ❌ Not AI-driven | ✅ Fully AI-driven |
| **Effort** | 0 (current) | 1 hour | 2-3 hours |

---

## ✅ **IMMEDIATE ACTIONS NEEDED**

**Minimum** (To use Playwright you just published):
1. Update `browser-test-user-workflow.js` to use Playwright library
2. Update test-production.sh comments (Puppeteer → Playwright)
3. Test locally
4. Commit changes

**Ideal** (To achieve AI-driven vision):
1. Create AI-driven test workflow
2. Replace hard-coded script with AI interaction
3. Use playwright-minimal MCP tools
4. Adaptive testing based on actual state

---

**Which approach should we take?**
- Quick fix (Option A): 1 hour, maintains current pattern
- Vision-aligned (Option B): 2-3 hours, fully AI-driven testing
