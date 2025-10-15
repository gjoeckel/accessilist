# 🔀 Cursor Workflows Reference

**Project workflows documentation - Auto-generated**
**Combines global and project-specific workflows**

---

## 🌐 Global Workflows (Available in ALL Projects)

- **ai-clean** - Clean temporary files and logs (works in any project)
- **ai-compress** - Compress session context into summary
- **ai-docs-sync** - Generate project workflows.md from global and project configs
- **ai-end** - Save session context and generate changelog
- **ai-local-commit** - Update changelog and commit all changes to current local branch
- **ai-local-merge** - Merge current branch to main, delete source branch
- **ai-repeat** - Reload session context
- **ai-start** - Load AI session context and initialize environment
- **ai-update** - Record mid-session progress
- **mcp-health** - Check MCP server health and status
- **mcp-restart** - Restart all MCP servers

**Total Global:** 11 workflows

## 📦 Project-Specific Workflows (This Project Only)

- **proj-deploy-check** - Run pre-deployment validation
- **proj-docker-down** - Stop Docker Apache server
- **proj-docker-up** - Start Docker Apache server
- **proj-dry** - Run duplicate code detection (AccessiList-specific)
- **proj-test-mirror** - Test production mirror configuration (Docker Apache)

**Total Project:** 5 workflows

---

## 🚀 Usage

### Type in Cursor Chat (Easiest)
Simply type the workflow name:
```
ai-start
ai-local-commit
mcp-health
proj-dry
```

### Command Palette
1. Press `Cmd+Shift+P` (Mac) or `Ctrl+Shift+P` (Windows/Linux)
2. Type workflow name
3. Select and execute

### Terminal Alternative
Global workflow scripts are in PATH:
```bash
session-start.sh
git-local-commit.sh
check-mcp-health.sh
```

---

## 📊 Summary

**Total Workflows:** 16 (11 global + 5 project)

**Categories:**
- AI Session Management (ai-start, ai-end, ai-update, ai-repeat, ai-compress)
- Git Operations (ai-local-commit, ai-local-merge)
- MCP Management (mcp-health, mcp-restart)
- Utilities (ai-clean)
- Project Tools (proj-*)

---

_Last updated: Wed Oct 15 09:43:37 MDT 2025_
_Auto-generated from ~/.cursor/workflows.json and .cursor/workflows.json_
