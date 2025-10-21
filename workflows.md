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
- **ai-local-merge** - Merge current branch to main, auto-updates changelog (handles conflicts gracefully)
- **ai-merge-finalize** - Finalize merge after manual conflict resolution (updates changelog, run from main)
- **ai-push-deploy-github** - Push to GitHub and deploy to production (full deployment)
- **ai-push-github** - Push to GitHub only (no deployment)
- **ai-repeat** - Reload session context
- **ai-start** - Load AI session context and initialize environment
- **ai-update** - Record mid-session progress
- **mcp-health** - Check MCP server health and status
- **mcp-restart** - Restart all MCP servers

**Total Global:** 14 workflows

## 📦 Project-Specific Workflows (This Project Only)

### Testing & Validation
- **proj-mirror-production** - Test local Docker mirror (99 tests: routing, APIs, security, content validation)
- **external-test-production** - Test staging (accessilist2) - 3 phases: Programmatic (53) + Permissions (2) + Browser E2E (15)
- **external-live-production** - Test LIVE production (accessilist) - 3 phases: Programmatic (53) + Permissions (2) + Browser E2E (15)
- **external-test-browser-ai** - Instructions for AI-driven browser testing (Playwright MCP tools)
- **proj-deploy-check** - Run pre-deployment validation
- **proj-compare-staging** - Compare local with accessilist2 (shows what will change on deploy)
- **proj-compare-live** - Compare local with accessilist (shows difference from production)

### Development Servers
- **proj-user-testing** - Start PHP dev server for manual testing (port 8000)
- **proj-docker-up** - Start Docker Apache server (port 8080)
- **proj-docker-down** - Stop Docker Apache server

### Deployment
- **proj-deploy-accessilist2** - Deploy to TEST directory (accessilist2) for validation
- **proj-push-deploy-github** - Deploy to production using explicit file list (89 files)

### Code Quality
- **proj-dry** - Run duplicate code detection (AccessiList-specific)

**Total Project:** 10 workflows

---

## 🚀 Usage

### Type in Cursor Chat (Easiest)
Simply type the workflow name:
```
ai-start
proj-test-mirror
external-test-production
ai-push-deploy-github
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

Project scripts can be run directly:
```bash
./scripts/test-production-mirror.sh
./scripts/external/test-production.sh
./scripts/deployment/pre-deploy-check.sh
```

---

## 📋 Workflow Details

### Testing Workflows

| Workflow | Environment | Tests | URL | Purpose |
|----------|-------------|-------|-----|---------|
| **proj-mirror-production** | Local Docker Apache | 99 | http://127.0.0.1:8080 | Pre-deployment testing |
| **external-test-production** | Staging (accessilist2) | 70 (3 phases) | https://webaim.org/training/online/accessilist2 | Pre-live validation (Programmatic→Permissions→Browser E2E) |
| **external-live-production** | Live Production | 70 (3 phases) | https://webaim.org/training/online/accessilist | Post-deployment verification (Programmatic→Permissions→Browser E2E) |

### Deployment Workflows

| Workflow | Action | Auto-Approve | Timeout |
|----------|--------|--------------|---------|
| **ai-push-deploy-github** | Push + Deploy | No (requires approval) | 5 min |
| **ai-push-github** | Push only | No (requires approval) | 1 min |
| **proj-deploy-check** | Validation | Yes | 30 sec |

### Development Server Workflows

| Workflow | Command | Port | Purpose |
|----------|---------|------|---------|
| **proj-user-testing** | `php -S localhost:8000 router.php` | 8000 | Manual testing (doesn't conflict with Docker) |
| **proj-docker-up** | `docker compose up -d` | 8080 | Start Apache server (automated testing) |
| **proj-docker-down** | `docker compose down` | - | Stop Apache server |

**Port Assignment**:
- Port 8000: PHP dev server (manual testing)
- Port 8080: Docker Apache (automated testing)
- **Both can run simultaneously!** ✨

---

## 📊 Summary

**Total Workflows:** 26 (14 global + 12 project)

**Categories:**
- **AI Session Management** (5): ai-start, ai-end, ai-update, ai-repeat, ai-compress
- **Git Operations** (4): ai-local-commit, ai-local-merge, ai-merge-finalize, ai-push-*
- **MCP Management** (2): mcp-health, mcp-restart
- **Testing** (7): proj-mirror-production, external-test-production, external-live-production, external-test-browser-ai, proj-deploy-check, proj-compare-staging, proj-compare-live
- **Docker** (2): proj-docker-up, proj-docker-down
- **Code Quality** (1): proj-dry
- **Deployment** (2): proj-deploy-accessilist2, proj-push-deploy-github
- **Development** (1): proj-user-testing
- **Utilities** (2): ai-clean, ai-docs-sync

---

## 🔄 Workflow Naming Convention

| Prefix | Scope | Examples |
|--------|-------|----------|
| `ai-*` | Global workflows (all projects) | ai-start, ai-end, ai-push-github |
| `proj-*` | Project-specific workflows | proj-dry, proj-test-mirror |
| `external-*` | External server testing | external-test-production |
| `mcp-*` | MCP server management | mcp-health, mcp-restart |

---

## 📝 Changelog Handling Design

### How Changelog Automation Works

**Design Philosophy:** Smart merge happens at **merge time**, not commit time.

#### During Commits (`ai-local-commit`, `ai-local-commit-safe`)
- ✅ Adds changelog entry to current branch
- ✅ Records files changed and timestamp
- ❌ Does NOT check main's changelog
- **Why:** Feature branches build their own independent history

#### During Merges (`ai-local-merge`, `ai-local-merge-safe`)
- ✅ **Retrieves last entry from main BEFORE merge**
- ✅ **Extracts only NEW entries from feature branch**
- ✅ **Pre-merges new entries into main's changelog**
- ✅ **Prevents changelog conflicts entirely**
- **Why:** This is when branches converge and conflicts could occur

#### Key Benefits
1. **Feature branches are independent** - Can evolve without cross-branch dependencies
2. **Conflict resolution at merge time** - Where it should be (clean separation of concerns)
3. **Smart merge prevents conflicts** - Pre-merges changelog entries before branch merge
4. **Proven in practice** - Recently merged security-updates with zero changelog conflicts

#### Technical Implementation
The smart merge logic (in `~/cursor-global/scripts/git-local-merge.sh` lines 141-166):
```bash
# 1. Get last entry from main BEFORE switching branches
LAST_MAIN_ENTRY=$(git show main:changelog.md 2>/dev/null | grep "^### " | head -1)

# 2. Extract only NEW entries from feature branch
# 3. Switch to main
# 4. Pre-merge new entries into main's changelog
# 5. Then merge branches (changelog already resolved!)
```

**Result:** Changelog conflicts are virtually eliminated. The merge workflow handles all the complexity.

---

## 🎯 Common Workflows

### Daily Development
```bash
ai-start                 # Start session
proj-user-testing        # Start dev server for manual testing
# Visit http://localhost:8000/home
proj-mirror-production   # Run automated tests (99 tests, 100% pass)
ai-local-commit          # Commit changes
```

### Before Deployment
```bash
proj-deploy-check        # Validate before deploy
proj-mirror-production   # Final local test (99 tests)
proj-compare-live        # Preview changes to production
ai-push-deploy-github    # Deploy to production
```

### Before Deployment (Staging)
```bash
proj-compare-staging      # Preview changes to staging
proj-deploy-accessilist2  # Deploy to staging
external-test-production  # Test staging (70 tests: 53+2+15)
```

### After Deployment (Verify Sync)
```bash
proj-compare-staging      # Verify staging sync (should show 0 changes)
proj-compare-live         # Verify live sync (should show 0 changes)
external-live-production  # Full test suite (70 tests: 53+2+15)
```

### Troubleshooting
```bash
mcp-health            # Check MCP servers
ai-clean              # Clean temp files
proj-docker-down      # Restart Docker
proj-docker-up
```

---

_Last updated: October 21, 2025_
_Auto-generated from ~/.cursor/workflows.json and .cursor/workflows.json_
