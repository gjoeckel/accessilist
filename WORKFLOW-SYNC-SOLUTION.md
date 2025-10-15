# 📋 Workflow Documentation Sync - Complete Solution

**Date:** October 15, 2025
**Status:** ✅ **IMPLEMENTED - Auto-generation workflow created**

---

## 🎯 The Problem

You have **TWO workflows.md files:**
1. `~/.cursor/workflows.md` - Global workflows documentation
2. `/Projects/accessilist/workflows.md` - Project workflows documentation

**Issue:** When adding new workflows, both need updating manually → risk of inconsistency

---

## ✅ **RECOMMENDED SOLUTION IMPLEMENTED**

### **Auto-Generation Workflow** ⭐

**Created:** `ai-docs-sync` workflow

**What it does:**
1. Reads `~/.cursor/workflows.json` (10 global workflows)
2. Reads `.cursor/workflows.json` (3 project workflows)
3. Generates `workflows.md` in project root (13 total workflows)
4. Keeps global and project sections separate
5. Returns: `✅ Generated workflows.md (13 workflows documented)`

**Usage:**
```
Type in Cursor: ai-docs-sync
```

Or from terminal:
```bash
generate-workflows-doc.sh
```

---

## 📁 File Structure (Recommended)

### **Global Documentation**
```
~/.cursor/workflows.md
```
- Documents ONLY global workflows (10)
- For AI agents working on ANY project
- Manually maintained (or update less frequently)
- Comprehensive with usage examples

### **Project Documentation**
```
/Projects/accessilist/workflows.md
```
- Documents ALL workflows (10 global + 3 project = 13)
- Auto-generated via `ai-docs-sync` workflow
- Shows complete picture for THIS project
- Regenerate whenever workflows change

---

## 🔄 Workflow for Updates

### **When Adding Global Workflow:**
```
1. Add workflow to ~/.cursor/workflows.json
2. Test workflow
3. Update ~/.cursor/workflows.md (detailed, manual)
4. Run: ai-docs-sync (updates project workflows.md)
```

### **When Adding Project Workflow:**
```
1. Add workflow to .cursor/workflows.json
2. Test workflow
3. Run: ai-docs-sync (updates project workflows.md)
```

### **Quick Sync Anytime:**
```
Type: ai-docs-sync
```
**Result:** Project `workflows.md` regenerated from both configs

---

## 📊 What Each File Contains

### **Global (~/.cursor/workflows.md)**
- ✅ Comprehensive documentation
- ✅ Usage instructions
- ✅ Examples for each workflow
- ✅ Troubleshooting tips
- ✅ Grouped by category
- 📝 **Manually maintained** for quality

### **Project (workflows.md)**
- ✅ Simple list of ALL workflows
- ✅ Global + project workflows combined
- ✅ Concise descriptions
- ✅ Auto-generated (always accurate)
- 🤖 **AI-generated** for consistency

---

## 🎯 Benefits of This Approach

### **Separation of Concerns** ✅
- Global docs: Comprehensive, detailed (for any project)
- Project docs: Complete list, auto-generated (for this project)

### **Always Accurate** ✅
- Project docs auto-generated from source of truth (JSON configs)
- No risk of manual sync errors
- One command updates everything

### **Best of Both Worlds** ✅
- Global: Detailed manual docs (quality)
- Project: Auto-generated lists (accuracy)

### **Easy Maintenance** ✅
- Add workflow → run `ai-docs-sync`
- Project docs always current
- No manual work needed

---

## 🚀 How to Use

### **After Adding Workflow:**
```
Type in Cursor: ai-docs-sync
```
**Result:** Project `workflows.md` updated with all workflows (global + project)

### **Check Documentation:**
```bash
# View global docs (detailed)
cat ~/.cursor/workflows.md

# View project docs (complete list)
cat workflows.md
```

---

## 📝 Example Generated Output

```markdown
# 🔀 Cursor Workflows Reference

## 🌐 Global Workflows (Available in ALL Projects)

- **ai-clean** - Clean temporary files and logs
- **ai-compress** - Compress session context
- **ai-end** - Save session context and generate changelog
- **ai-local-commit** - Update changelog and commit changes
- **ai-local-merge** - Merge branch to main, delete source
- **ai-repeat** - Reload session context
- **ai-start** - Load AI session context
- **ai-update** - Record mid-session progress
- **mcp-health** - Check MCP server health
- **mcp-restart** - Restart all MCP servers

**Total Global:** 10 workflows

## 📦 Project-Specific Workflows (This Project Only)

- **proj-deploy-check** - Run pre-deployment validation
- **proj-dry** - Run duplicate code detection
- **proj-test-mirror** - Test production mirror configuration

**Total Project:** 3 workflows

**Total Workflows:** 13 (10 global + 3 project)
```

---

## ✅ Implementation Complete

**New Workflow Added:**
- ✅ `ai-docs-sync` - Generate project workflows.md

**Script Created:**
- ✅ `~/.local/bin/cursor-tools/generate-workflows-doc.sh`

**Total Global Workflows:** 11 (was 10, added ai-docs-sync)

---

## 🎯 Summary

**Recommended Workflow:**
1. Keep `~/.cursor/workflows.md` as detailed manual documentation
2. Keep `workflows.md` in project as auto-generated combined list
3. Run `ai-docs-sync` after adding any workflow
4. Project docs always show complete picture (global + project)

**One command keeps everything in sync!** ✅

Type `ai-docs-sync` to regenerate project workflows.md anytime! 🚀
