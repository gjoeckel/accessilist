# Playwright Minimal MCP Server

**4 Essential Tools** - Drop-in replacement for `puppeteer-minimal` with Playwright's superior reliability

## 🎯 Features

- **Multi-browser support**: Test in Chromium, Firefox, and WebKit (Safari)
- **Auto-wait mechanisms**: Playwright automatically waits for elements to be actionable
- **Built-in retry logic**: Reduces test flakiness
- **Enhanced debugging**: Captures console logs, network requests, and screenshots
- **4-tool limit**: Stays within Cursor IDE's 40-tool MCP limit

## 🛠️ Available Tools

### 1. `navigate_and_wait`
Navigate to a URL with smart waiting and multi-browser support.

**Parameters:**
- `url` (required): URL to navigate to
- `waitUntil` (optional): When to consider navigation complete (`load`, `domcontentloaded`, `networkidle`, `commit`)
- `timeout` (optional): Timeout in milliseconds (default: 30000)
- `browserType` (optional): Browser to use (`chromium`, `firefox`, `webkit`)

**Example:**
```json
{
  "url": "https://example.com",
  "waitUntil": "domcontentloaded",
  "browserType": "chromium"
}
```

### 2. `interact_with`
Interact with page elements with auto-wait and retry.

**Parameters:**
- `selector` (required): CSS selector
- `action` (required): Action to perform (`click`, `type`, `select`, `check`)
- `text` (optional): Text to type (for `type` action)
- `value` (optional): Value to select (for `select` action)
- `timeout` (optional): Timeout in milliseconds
- `force` (optional): Skip actionability checks

**Example:**
```json
{
  "selector": "#saveButton",
  "action": "click"
}
```

### 3. `extract_and_verify`
Extract content from elements with optional verification.

**Parameters:**
- `selector` (optional): CSS selector (default: `body`)
- `attribute` (optional): Attribute to extract (`text`, `value`, `html`, or any attribute name)
- `expected` (optional): Expected value for verification
- `timeout` (optional): Timeout in milliseconds

**Example:**
```json
{
  "selector": ".notes-textarea",
  "attribute": "value",
  "expected": "Test note"
}
```

### 4. `capture_test_evidence`
Capture comprehensive test evidence for debugging.

**Parameters:**
- `screenshot` (optional): Capture screenshot (boolean or `{fullPage: true}`)
- `consoleLogs` (optional): Capture browser console logs
- `networkLogs` (optional): Capture network requests
- `html` (optional): Capture page HTML source

**Example:**
```json
{
  "screenshot": {"fullPage": true},
  "consoleLogs": true,
  "networkLogs": true
}
```

## 📦 Installation

```bash
cd my-mcp-servers/packages/playwright-minimal
npm install
npm run build
```

## ⚙️ Configuration

Add to `.cursor/mcp.json`:

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

## 🔄 Migration from Puppeteer-Minimal

| Puppeteer Tool | Playwright Tool | Migration Notes |
|----------------|-----------------|-----------------|
| `navigate` | `navigate_and_wait` | Add `browserType` parameter for multi-browser testing |
| `click_element` | `interact_with` | Use `action: "click"` - includes auto-wait |
| `extract_text` | `extract_and_verify` | Use `attribute: "text"` - can extract any attribute |
| `take_screenshot` | `capture_test_evidence` | Use `screenshot: true` - can capture logs too |

## 🎯 Advantages Over Puppeteer

1. **Auto-wait**: No need for manual `waitForSelector` before actions
2. **Multi-browser**: Test in Chrome, Firefox, and Safari
3. **Better reliability**: Built-in retry logic reduces flakiness
4. **Enhanced debugging**: Capture console logs and network requests
5. **Semantic selectors**: Use `text=Save` or `role=button` selectors
6. **Active development**: Playwright is actively maintained by Microsoft

## 📚 Examples

### Test User Workflow in All Browsers
```javascript
// Navigate in Chrome
await navigate_and_wait({
  url: "https://webaim.org/training/online/accessilist2",
  browserType: "chromium"
});

// Navigate in Firefox
await navigate_and_wait({
  url: "https://webaim.org/training/online/accessilist2",
  browserType: "firefox"
});

// Navigate in Safari
await navigate_and_wait({
  url: "https://webaim.org/training/online/accessilist2",
  browserType: "webkit"
});
```

### Click and Verify
```javascript
// Click save button (auto-waits for button to be clickable)
await interact_with({
  selector: "#saveButton",
  action: "click"
});

// Verify save success
await extract_and_verify({
  selector: "body",
  attribute: "text",
  expected: "saved successfully"
});
```

### Capture Test Evidence
```javascript
// Capture everything for debugging
const evidence = await capture_test_evidence({
  screenshot: {fullPage: true},
  consoleLogs: true,
  networkLogs: true,
  html: false  // HTML can be large
});
```

## 🔧 Tool Count Impact

**Before (Puppeteer)**: 39 tools total
- puppeteer-minimal: 4 tools

**After (Playwright)**: 39 tools total (no change!)
- playwright-minimal: 4 tools

Stays within Cursor IDE's 40-tool MCP limit! ✅

## 📝 License

MIT
