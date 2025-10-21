# Playwright Minimal MCP Server - Testing & Deployment Guide

## ✅ **TESTING STATUS**

### Phase 1: Basic Server Test ✅ PASSED
- [x] Server starts without errors
- [x] Server responds on stdio
- [x] All 4 tools registered correctly
- [x] Schemas are valid

**Result**: Ready for Cursor IDE integration testing

---

## 🧪 **RECOMMENDED TESTING WORKFLOW**

### **STEP 1: Local MCP Integration Test** (DO THIS FIRST!)

#### 1.1 Backup Current Config
```bash
cp ~/.cursor/mcp.json ~/.cursor/mcp.json.backup-$(date +%Y%m%d-%H%M%S)
# Or if using .cursor/ in project:
cp .cursor/mcp.json .cursor/mcp.json.backup-$(date +%Y%m%d-%H%M%S)
```

#### 1.2 Update MCP Configuration

Edit `.cursor/mcp.json` (or `~/.cursor/mcp.json`):

**OPTION A: Replace puppeteer-minimal entirely**
```json
{
  "mcpServers": {
    "playwright-minimal": {
      "command": "node",
      "args": [
        "/Users/a00288946/Projects/accessilist/my-mcp-servers/packages/playwright-minimal/build/index.js"
      ]
    }
  }
}
```

**OPTION B: Run both in parallel (safer for testing)**
```json
{
  "mcpServers": {
    "puppeteer-minimal": {
      "command": "node",
      "args": ["/.../puppeteer-minimal/build/index.js"]
    },
    "playwright-minimal": {
      "command": "node",
      "args": [
        "/Users/a00288946/Projects/accessilist/my-mcp-servers/packages/playwright-minimal/build/index.js"
      ]
    }
  }
}
```

**Note**: Running both temporarily gives you 43 tools (over the 40 limit), but useful for testing.

#### 1.3 Restart Cursor IDE
```bash
# Kill Cursor completely
pkill -9 Cursor

# Restart Cursor
# (Use Spotlight or Applications folder)
```

#### 1.4 Verify MCP Server Loaded
Check Cursor's MCP status (usually in settings or developer tools) to confirm:
- ✅ `playwright-minimal` server running
- ✅ 4 tools available (navigate_and_wait, interact_with, extract_and_verify, capture_test_evidence)
- ✅ No error messages

---

### **STEP 2: Functional Test with Real Browser**

Create a simple test conversation in Cursor:

```
Test: Navigate to https://example.com using playwright-minimal MCP server
```

Expected AI behavior:
1. AI calls `navigate_and_wait` tool
2. Playwright opens Chromium browser
3. Navigates to example.com
4. Returns page title and URL
5. No errors

**If this works**, proceed to Step 3.
**If this fails**, check:
- Chromium installed? (`npx playwright install chromium`)
- Correct path in mcp.json?
- Check Cursor logs for errors

---

### **STEP 3: Convert Existing Browser Test**

Update `scripts/external/browser-test-user-workflow.js` to use Playwright:

**Test Plan**:
- [ ] Navigate to AccessiList home page
- [ ] Click Word checklist button
- [ ] Verify checkpoint rows render
- [ ] Click status button
- [ ] Extract text content
- [ ] Capture screenshot + console logs
- [ ] Compare reliability vs Puppeteer

**Success Criteria**:
- ✅ Test completes without errors
- ✅ All 10 test steps pass
- ✅ No rate limit errors (429)
- ✅ No timing issues
- ✅ Auto-wait works correctly

---

### **STEP 4: Multi-Browser Test**

Test in all 3 browsers:

```bash
# Install Firefox and WebKit
cd my-mcp-servers/packages/playwright-minimal
npx playwright install firefox webkit
```

Create test script:
```javascript
// Test same workflow in 3 browsers
const browsers = ['chromium', 'firefox', 'webkit'];

for (const browser of browsers) {
  console.log(`\n🌐 Testing in ${browser}...`);

  await navigate_and_wait({
    url: "https://webaim.org/training/online/accessilist2",
    browserType: browser
  });

  // Run full test suite
}
```

**Success Criteria**:
- ✅ All tests pass in Chromium
- ✅ All tests pass in Firefox
- ✅ All tests pass in WebKit (Safari engine)
- ✅ Consistent behavior across browsers

---

### **STEP 5: Reliability & Performance Test**

Run the test 10 times to check reliability:

```bash
for i in {1..10}; do
  echo "Run $i:"
  node scripts/external/browser-test-playwright.js
done
```

**Track metrics**:
- Pass rate: __/10 (target: 9-10/10)
- Average execution time: ____ seconds
- Failures: ____ (timing issues? selectors? network?)

**Compare with Puppeteer**:
- Puppeteer pass rate: __/10
- Playwright pass rate: __/10
- Winner: Playwright (hopefully!)

---

## 🚀 **DEPLOYMENT WORKFLOW**

### **AFTER LOCAL TESTING SUCCEEDS**

#### Option A: GitHub Only (Recommended)

**Purpose**: Share code, version control, backup
**Who can use**: Only you (via git clone)
**Cost**: Free

```bash
# From accessilist project root
cd my-mcp-servers

# Add and commit
git add packages/playwright-minimal/
git commit -m "Add playwright-minimal MCP server (4 tools)"

# Push to GitHub
git push origin main
```

**Benefits**:
- ✅ Version controlled
- ✅ Backup on GitHub
- ✅ Can reference in docs
- ✅ No public npm complexity

**Usage after push**:
```bash
# On another machine
git clone https://github.com/gjoeckel/my-mcp-servers
cd my-mcp-servers/packages/playwright-minimal
npm install
npm run build
```

#### Option B: GitHub + npm Publish (Advanced)

**Purpose**: Make publicly available for others
**Who can use**: Anyone (via `npm install`)
**Cost**: Free (public package)

**Only do this if**:
- ✅ You want to share with the community
- ✅ You're confident it's production-ready
- ✅ You're willing to maintain it (updates, issues, etc.)

**Steps**:
```bash
# 1. Update package.json with public scope
cd packages/playwright-minimal
npm init --scope=@YOUR_NPM_USERNAME

# 2. Ensure package.json has correct info
{
  "name": "@gjoeckel/mcp-playwright-minimal",
  "version": "1.0.0",
  "description": "Minimal Playwright MCP server (4 tools)",
  "author": "gjoeckel",
  "license": "MIT",
  "repository": {
    "type": "git",
    "url": "https://github.com/gjoeckel/my-mcp-servers.git"
  }
}

# 3. Login to npm
npm login

# 4. Publish
npm publish --access public
```

**After publish**, others can use:
```bash
npm install -g @gjoeckel/mcp-playwright-minimal

# In .cursor/mcp.json:
{
  "playwright-minimal": {
    "command": "npx",
    "args": ["-y", "@gjoeckel/mcp-playwright-minimal"]
  }
}
```

---

## 🎯 **MY RECOMMENDATION**

### **For Your Use Case: GitHub Only (No npm)**

**Reasons**:
1. ✅ It's a custom tool for YOUR workflow
2. ✅ Not enough testing yet for public release (need 10+ successful runs)
3. ✅ Easier to iterate (no version management)
4. ✅ GitHub gives you version control + backup
5. ✅ Can publish to npm later if you want to share

### **Deployment Sequence**:

```bash
# 1. Test locally (Steps 1-5 above)
# 2. If all tests pass for 1 week:
cd my-mcp-servers
git add packages/playwright-minimal/
git commit -m "Add playwright-minimal MCP server (4 tools) - tested and stable"
git push origin main

# 3. Update README on GitHub
# 4. (Optional) Publish to npm after 1 month of stable use
```

---

## 📊 **TESTING CHECKLIST**

Before pushing to GitHub:
- [ ] Basic server test passes (✅ already done)
- [ ] MCP integration in Cursor works
- [ ] Can navigate to websites
- [ ] Can interact with elements
- [ ] Can extract content
- [ ] Can capture screenshots
- [ ] Works with AccessiList application
- [ ] Tested in Chromium (minimum)
- [ ] Tested in Firefox (bonus)
- [ ] Tested in WebKit/Safari (bonus)
- [ ] 80%+ pass rate over 10 runs
- [ ] Better or equal to Puppeteer reliability

Before publishing to npm:
- [ ] All above tests pass
- [ ] 1+ month of stable use
- [ ] Documentation complete
- [ ] Examples provided
- [ ] License file added
- [ ] Willing to maintain long-term

---

## 🐛 **TROUBLESHOOTING**

### Issue: MCP server not showing in Cursor
**Solution**:
- Check path in mcp.json is absolute
- Restart Cursor completely (pkill -9 Cursor)
- Check Cursor logs for errors

### Issue: "Page not initialized" error
**Solution**:
- Must call `navigate_and_wait` before other tools
- Each browser type needs separate navigation

### Issue: Playwright browsers not found
**Solution**:
```bash
cd packages/playwright-minimal
npx playwright install chromium firefox webkit
```

### Issue: Rate limiting (429 errors)
**Solution**:
- Add delays between requests (3-5 seconds)
- Whitelist localhost in rate-limiter.php

---

## 📝 **NEXT STEPS**

1. **Today**: Test Steps 1-2 (MCP integration + basic browser test)
2. **This week**: Test Steps 3-4 (convert test + multi-browser)
3. **Next week**: Test Step 5 (reliability)
4. **After 1 week stable**: Push to GitHub
5. **(Optional) After 1 month stable**: Publish to npm

---

## 🎉 **SUCCESS METRICS**

**Minimum for GitHub push**:
- ✅ Works in Cursor IDE
- ✅ Navigates successfully
- ✅ Interacts with elements
- ✅ Extracts content
- ✅ 50%+ pass rate

**Ideal for GitHub push**:
- ✅ All 4 tools work perfectly
- ✅ Tested in 1+ browser
- ✅ 80%+ pass rate
- ✅ Better than Puppeteer

**Required for npm publish**:
- ✅ All 4 tools work perfectly
- ✅ Tested in all 3 browsers
- ✅ 90%+ pass rate
- ✅ Documentation complete
- ✅ 1+ month stable use

---

**Current Status**: ✅ Phase 1 complete - Ready for Cursor IDE integration test!
