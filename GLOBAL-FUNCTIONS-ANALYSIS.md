# 🌐 Global Functions & Methods Analysis

**Generated:** October 15, 2025
**Purpose:** Comprehensive analysis of what IS and what SHOULD BE globally available

---

## 1️⃣ ALREADY AVAILABLE GLOBALLY ✅

### **A. MCP Servers (7 servers, 39 tools)** - via `~/.cursor/mcp.json`

| Server | Tools | Status | Scope |
|--------|-------|--------|-------|
| **filesystem** | 15 | ✅ GLOBAL | File operations across all projects |
| **memory** | 8 | ✅ GLOBAL | Knowledge storage across all projects |
| **github-minimal** | 4 | ✅ GLOBAL | GitHub operations |
| **shell-minimal** | 4 | ✅ GLOBAL | Shell commands |
| **puppeteer-minimal** | 4 | ✅ GLOBAL | Browser automation |
| **sequential-thinking-minimal** | 4 | ✅ GLOBAL | Problem solving |
| **everything-minimal** | 4 | ✅ GLOBAL | Protocol validation |

**Total: 39 tools globally available in ALL Cursor projects**

---

### **B. Workflows (7 workflows)** - via `~/.cursor/workflows.json`

| Workflow | Description | Status | Scope |
|----------|-------------|--------|-------|
| **ai-start** | Load AI session context | ✅ GLOBAL | Works in all projects |
| **ai-end** | Save session & generate changelog | ✅ GLOBAL | Works in all projects |
| **ai-update** | Record mid-session progress | ✅ GLOBAL | Works in all projects |
| **ai-repeat** | Reload session context | ✅ GLOBAL | Works in all projects |
| **ai-clean** | Clean temporary files | ⚠️ PROJECT-SPECIFIC | AccessiList only |
| **ai-dry** | Run duplicate code detection | ⚠️ PROJECT-SPECIFIC | AccessiList only |
| **ai-compress** | Compress session context | ✅ GLOBAL | Works in all projects |

**Note:** ai-clean and ai-dry reference project-specific paths

---

### **C. JavaScript Utility Functions** - Exposed on `window` object

| Function | File | Global Export | Purpose |
|----------|------|---------------|---------|
| **getImagePath()** | path-utils.js | ✅ window.getImagePath | Get image file paths |
| **getJSONPath()** | path-utils.js | ✅ window.getJSONPath | Get JSON file paths |
| **getConfigPath()** | path-utils.js | ✅ window.getConfigPath | Get config file paths |
| **getCSSPath()** | path-utils.js | ✅ window.getCSSPath | Get CSS file paths |
| **getPHPPath()** | path-utils.js | ✅ window.getPHPPath | Get PHP page paths |
| **getAPIPath()** | path-utils.js | ✅ window.getAPIPath | Get API endpoint paths |
| **getCleanPath()** | path-utils.js | ✅ window.getCleanPath | Get clean URL paths |
| **formatDateShort()** | date-utils.js | ✅ window.formatDateShort | Format date as MM-DD-YY |
| **formatDateLong()** | date-utils.js | ✅ window.formatDateLong | Format full date/time |
| **formatDateAdmin()** | date-utils.js | ✅ window.formatDateAdmin | Format admin timestamps |
| **TypeManager** | type-manager.js | ✅ window.TypeManager | Manage checklist types |
| **ModalActions** | ModalActions.js | ✅ window.ModalActions | Modal dialog handling |
| **statusManager** | StatusManager.js | ✅ window.statusManager | Status button management |
| **simpleModal** | simple-modal.js | ✅ window.simpleModal | Simple modal dialogs |
| **scheduleBufferUpdate()** | scroll.js | ✅ window.scheduleBufferUpdate | Scroll buffer updates |
| **updateBottomBufferImmediate()** | scroll.js | ✅ window.updateBottomBufferImmediate | Immediate buffer update |
| **updateReportBuffer()** | scroll.js | ✅ window.updateReportBuffer | Report scroll buffer |

**Status:** ✅ Available globally within browser context (not cross-project)

---

### **D. PHP Utility Functions** - Available via `require_once`

| Function | File | Scope | Purpose |
|----------|------|-------|---------|
| **send_json()** | api-utils.php | AccessiList only | Send JSON response |
| **send_error()** | api-utils.php | AccessiList only | Send error response |
| **send_success()** | api-utils.php | AccessiList only | Send success response |
| **validate_session_key()** | api-utils.php | AccessiList only | Validate session keys |
| **saves_path_for()** | api-utils.php | AccessiList only | Get save file path |
| **renderCommonScripts()** | common-scripts.php | AccessiList only | Render script tags |
| **loadEnv()** | config.php | AccessiList only | Load .env file |
| **renderFooter()** | footer.php | AccessiList only | Render page footer |
| **renderHTMLHead()** | html-head.php | AccessiList only | Render HTML head |
| **getChecklistTypeFromSession()** | session-utils.php | AccessiList only | Get checklist type |
| **formatTypeName()** | type-formatter.php | AccessiList only | Format type names |

**Status:** ❌ NOT globally available (project-specific PHP)

---

## 2️⃣ SHOULD BE AVAILABLE GLOBALLY ⭐

### **A. Utility Scripts** - Should be in `~/.local/bin/` or `~/bin/`

| Script | Current Location | Should Be Global? | Reason |
|--------|------------------|-------------------|--------|
| **compress-context.sh** | scripts/utils/ | ✅ YES | Session management (all projects) |
| **configure-cursor-autonomy.sh** | scripts/utils/ | ✅ YES | Cursor config (all projects) |
| **session-start.sh** | scripts/session/ | ✅ YES | Already in workflow (all projects) |
| **session-end.sh** | scripts/session/ | ✅ YES | Already in workflow (all projects) |
| **session-update.sh** | scripts/session/ | ✅ YES | Already in workflow (all projects) |
| **check-mcp-health.sh** | scripts/ | ✅ YES | MCP health check (all projects) |
| **check-mcp-tool-count.sh** | scripts/ | ✅ YES | MCP validation (all projects) |
| **setup-cursor-environment.sh** | scripts/ | ✅ YES | Cursor setup (all projects) |
| **start-mcp-servers.sh** | scripts/ | ✅ YES | MCP startup (all projects) |
| **restart-mcp-servers.sh** | scripts/ | ✅ YES | MCP restart (all projects) |

**Action Needed:**
- Create `~/.local/bin/cursor-tools/` directory
- Symlink or copy globally useful scripts
- Add to PATH

---

### **B. Workflows** - Need to be PROJECT-AGNOSTIC

Current workflows that are TOO PROJECT-SPECIFIC:

| Workflow | Issue | Fix Needed |
|----------|-------|------------|
| **ai-clean** | Hardcoded to `/Users/a00288946/Projects/accessilist/logs/` | Use `$PWD` or `${workspaceFolder}` |
| **ai-dry** | Hardcoded to `/Users/a00288946/Projects/accessilist/scripts/ai-dry.sh` | Use `$PWD` or `${workspaceFolder}` |

**All workflows** should use:
- `${workspaceFolder}` instead of absolute paths
- `$PWD` for current directory
- Environment variables for project root

---

### **C. JavaScript Utilities** - Could be NPM Package

These are genuinely useful across projects:

| Utility | Could Be NPM Package? | Package Name Suggestion |
|---------|----------------------|-------------------------|
| **path-utils.js** | ✅ YES | `@gjoeckel/path-utils` |
| **date-utils.js** | ✅ YES | `@gjoeckel/date-utils` |
| **simple-modal.js** | ✅ YES | `@gjoeckel/simple-modal` |
| **type-manager.js** | ❌ NO | Too AccessiList-specific |
| **StateManager.js** | ❌ NO | Too AccessiList-specific |

**Action Needed:**
- Create separate NPM packages for truly reusable utilities
- Publish to npm or keep as private packages
- Import into projects as dependencies

---

### **D. Global Configuration Files**

Should be in `~/.cursor/` for ALL projects:

| File | Current Location | Should Be Global? | Purpose |
|------|------------------|-------------------|---------|
| **mcp.json** | ~/.cursor/ | ✅ ALREADY GLOBAL | MCP server config |
| **workflows.json** | ~/.cursor/ | ✅ ALREADY GLOBAL | Workflow definitions |
| **settings.json** | ~/.cursor/ | ✅ ALREADY GLOBAL | Cursor IDE settings |
| **global-scripts.json** | N/A | ✅ NEW FILE NEEDED | Global utility script registry |

---

## 3️⃣ PROJECT-SPECIFIC (Should NOT be Global) ❌

### **A. AccessiList-Specific Code**

These should NEVER be globally available:

| Item | Type | Reason |
|------|------|--------|
| **API endpoints** | PHP | Project-specific business logic |
| **buildPrinciples.js** | JavaScript | AccessiList checklist logic |
| **addRow.js** | JavaScript | AccessiList UI components |
| **StatusManager.js** | JavaScript | AccessiList-specific state |
| **saves/** directory | Data | Project-specific session storage |
| **deployment scripts** | Shell | AccessiList deployment to WebAIM |

### **B. Test/Development Tools**

These are project-specific:

| Script | Reason |
|--------|--------|
| **test-production-mirror.sh** | Tests AccessiList Apache config |
| **upload-demo-files.sh** | Deploys to WebAIM server |
| **pre-deploy-check.sh** | Validates AccessiList deployment |

---

## 4️⃣ RECOMMENDATIONS 📋

### **Priority 1: Fix Workflow Paths (HIGH PRIORITY)**

**Current Issue:**
```json
{
  "ai-clean": {
    "working_directory": "/Users/a00288946/Projects/accessilist"
  }
}
```

**Should Be:**
```json
{
  "ai-clean": {
    "working_directory": "${workspaceFolder}"
  }
}
```

**Impact:** Workflows will work in ANY Cursor project

---

### **Priority 2: Create Global Script Directory (MEDIUM PRIORITY)**

**Structure:**
```
~/.local/bin/cursor-tools/
├── session-start.sh          # Symlink to script
├── session-end.sh            # Symlink to script
├── session-update.sh         # Symlink to script
├── compress-context.sh       # Symlink to script
├── check-mcp-health.sh       # Symlink to script
└── setup-cursor.sh           # Symlink to script
```

**Add to PATH:**
```bash
export PATH="$HOME/.local/bin/cursor-tools:$PATH"
```

---

### **Priority 3: Create Reusable NPM Packages (LOW PRIORITY)**

**Extract to npm packages:**
1. **@gjoeckel/path-utils** - Environment-aware path resolution
2. **@gjoeckel/date-utils** - Date formatting utilities
3. **@gjoeckel/simple-modal** - Simple modal dialogs

**Benefits:**
- Versioned dependencies
- Reusable across projects
- Standard npm workflow

---

### **Priority 4: Document Global vs Local (HIGH PRIORITY)**

Create `/Users/a00288946/.cursor/README.md`:

```markdown
# Global Cursor Configuration

This directory contains configurations that apply to ALL Cursor projects.

## Files

- **mcp.json** - MCP servers (39 tools globally available)
- **workflows.json** - Workflow commands (ai-start, ai-end, etc.)
- **settings.json** - Cursor IDE preferences

## Adding New Workflows

Workflows must use \${workspaceFolder} for project paths:
- ✅ Good: "./scripts/my-script.sh"
- ❌ Bad: "/Users/a00288946/Projects/myproject/scripts/my-script.sh"
```

---

## 5️⃣ SUMMARY 📊

### **What's Already Global:**
- ✅ 7 MCP servers (39 tools)
- ✅ 7 workflows (but 2 are project-specific)
- ✅ 17 JavaScript utility functions (browser-global only)
- ✅ Global Cursor settings

### **What SHOULD Be Global:**
- ⭐ 10 utility scripts (session management, MCP tools)
- ⭐ 3 JavaScript NPM packages (path-utils, date-utils, simple-modal)
- ⭐ Global script directory in PATH

### **What Should NEVER Be Global:**
- ❌ AccessiList business logic
- ❌ Project-specific API endpoints
- ❌ Project-specific deployment scripts
- ❌ Project-specific data/saves

---

## 6️⃣ NEXT STEPS 🚀

**WAITING FOR APPROVAL:**

1. Fix workflow paths to use `${workspaceFolder}`
2. Create `~/.local/bin/cursor-tools/` directory
3. Symlink globally useful scripts
4. Document global configuration
5. (Optional) Extract JavaScript utilities to NPM packages

**Ready to proceed when you give the go-ahead!** ✅
