# Local Commit Workflows Analysis
**Date:** October 21, 2025
**Purpose:** Identify which workflows retrieve main's last changelog entry before commit

---

## 📋 All Local Commit Workflows Identified

### 1. `ai-local-commit` (Global)
**Type:** Global workflow
**Script:** `~/cursor-global/scripts/git-local-commit.sh`
**Description:** Automated changelog and commit workflow

**Changelog Handling:**
- ✅ Creates/updates changelog entry
- ❌ **Does NOT retrieve last entry from main before commit**
- ❌ **Does NOT do smart merge**

**How It Works:**
```bash
# Lines 85-100 of git-local-commit.sh
# It just inserts entry into current branch's changelog
if grep -q "## Entries" "$CHANGELOG"; then
    LINE_NUM=$(grep -n "## Entries" "$CHANGELOG" | head -1 | cut -d: -f1)
    # Insert after that line (NO check against main)
    ...
fi
```

**Problem:** When committing on a feature branch, it adds to the feature branch's changelog without checking what's already in main. This can lead to conflicts or duplicate entries later.

---

### 2. `ai-local-commit-safe` (Project-Specific)
**Type:** Project-specific workflow
**Commands:**
```json
"commands": [
  "docker compose up -d",
  "sleep 8",
  "BASE_URL=http://127.0.0.1:8080 ./scripts/test-production-mirror.sh",
  "git add -A",
  "git commit"
]
```

**Changelog Handling:**
- ❌ **No changelog handling at all**
- ❌ **Does NOT call git-local-commit.sh**
- ❌ **Does NOT retrieve from main**

**Note:** This is just a test-and-commit workflow with no automated changelog updates.

---

### 3. `ai-local-merge` (Global)
**Type:** Global workflow
**Script:** `~/cursor-global/scripts/git-local-merge.sh`
**Description:** Merge current branch to main with smart changelog handling

**Changelog Handling:**
- ✅ **DOES retrieve last entry from main before merge** ✅
- ✅ **Has smart changelog merge strategy**
- ✅ **Prevents changelog conflicts**

**How It Works:**
```bash
# Lines 141-166 of git-local-merge.sh
# Gets last entry from main BEFORE switching branches
LAST_MAIN_ENTRY=$(git show main:changelog.md 2>/dev/null | grep "^### " | head -1 || echo "")

if [ -n "$LAST_MAIN_ENTRY" ]; then
    # Extract only NEW entries from feature branch
    # (everything between "## Entries" and main's last entry)
    ...
    # Then merges them smartly into main
fi
```

**Why This Works:**
1. While still on feature branch, retrieves main's last changelog entry
2. Extracts only entries that are new (not in main yet)
3. Switches to main
4. Pre-merges the new entries into main's changelog
5. Then does the actual branch merge (changelog already resolved!)

---

### 4. `ai-local-merge-safe` (Project-Specific)
**Type:** Project-specific workflow
**Commands:**
```json
"commands": [
  "docker compose up -d",
  "sleep 8",
  "BASE_URL=http://127.0.0.1:8080 ./scripts/test-production-mirror.sh",
  "git checkout main",
  "git merge -"
]
```

**Changelog Handling:**
- ❌ **No changelog handling at all**
- ❌ **Does NOT call git-local-merge.sh**
- ❌ **Does NOT retrieve from main**

**Note:** This is just a test-and-merge workflow with no automated changelog handling.

---

## 🎯 Summary Table

| Workflow | Type | Retrieves Main Changelog? | Smart Merge? | Script Used |
|----------|------|---------------------------|--------------|-------------|
| `ai-local-commit` | Global | ❌ **NO** | ❌ NO | `git-local-commit.sh` |
| `ai-local-commit-safe` | Project | ❌ **NO** | ❌ NO | None (direct git) |
| `ai-local-merge` | Global | ✅ **YES** ✅ | ✅ YES | `git-local-merge.sh` |
| `ai-local-merge-safe` | Project | ❌ **NO** | ❌ NO | None (direct git) |

---

## ⚠️ Current Issues

### Issue #1: `ai-local-commit` Missing Smart Merge
**Problem:** The `git-local-commit.sh` script does NOT retrieve main's last changelog entry before committing.

**Current Behavior:**
```bash
# On feature branch
1. Creates changelog entry
2. Inserts it into feature branch's changelog
3. Commits
# NO check against what's in main
```

**Impact:**
- When multiple feature branches are created from different points in main's history
- They each add their entries without knowing about each other
- Leads to potential conflicts or duplicate entries when merging

**Example Scenario:**
```
main:      [Entry A] → [Entry B] → [Entry C]
                ↓
feature1:  [Entry A] → [Entry B] → [NEW: Entry X]  ← ai-local-commit
                ↓
feature2:  [Entry A] → [Entry B] → [NEW: Entry Y]  ← ai-local-commit

Later when merging:
- feature1 → main: OK (Entry C + Entry X)
- feature2 → main: CONFLICT! (Entry C + Entry X vs Entry C + Entry Y)
```

---

### Issue #2: `-safe` Variants Have No Changelog Automation
**Problem:** The `-safe` variants just run tests and use direct git commands.

**Current Behavior:**
- No automated changelog updates
- User must manually update changelog.md
- No smart merge logic

**Impact:**
- Inconsistent changelog updates
- More manual work required
- Higher chance of merge conflicts

---

## ✅ What Works Well

### `ai-local-merge` Smart Changelog Merge
**This workflow DOES have the desired functionality!**

**Key Code (git-local-merge.sh lines 141-166):**
```bash
# 1. Get last entry from main BEFORE merge
LAST_MAIN_ENTRY=$(git show main:changelog.md 2>/dev/null | grep "^### " | head -1 || echo "")

# 2. Extract only NEW entries from feature branch
if [ -n "$LAST_MAIN_ENTRY" ]; then
    # Find where main's last entry appears in feature branch's changelog
    LAST_MAIN_LINE=$(grep -n "^${LAST_MAIN_ENTRY}" "$CHANGELOG" | head -1 | cut -d: -f1 || echo "")

    if [ -n "$LAST_MAIN_LINE" ]; then
        # Extract ONLY new entries (between "## Entries" and last main entry)
        sed -n "$((ENTRIES_LINE + 1)),$((LAST_MAIN_LINE - 1))p" "$CHANGELOG" > "$TEMP_NEW_ENTRIES"
    fi
fi

# 3. Switch to main and pre-merge the new entries
git checkout main
# Insert new entries into main's changelog
# This prevents merge conflicts entirely!
```

**Why This Is Excellent:**
- ✅ Retrieves main's state BEFORE any changes
- ✅ Extracts only truly new entries
- ✅ Prevents duplicate entries
- ✅ Prevents merge conflicts
- ✅ Works even if feature branch is behind main

---

## 🔧 Recommendations

### Recommendation #1: Fix `ai-local-commit` to Match `ai-local-merge` Logic
**Priority:** HIGH

The `git-local-commit.sh` script should:
1. Before committing, retrieve the last entry from main's changelog
2. Extract only new entries from current branch
3. Store them separately
4. When merging, use the stored new entries (like ai-local-merge does)

**OR:**

Simply acknowledge that commits don't need smart merge - only the merge workflow does (which already has it).

### Recommendation #2: Update `-safe` Variants to Use Smart Scripts
**Priority:** MEDIUM

Instead of:
```json
"commands": ["git add -A", "git commit"]
```

Use:
```json
"commands": ["bash ~/cursor-global/scripts/git-local-commit.sh"]
```

This would give them the same changelog automation (even if not perfect).

---

## 📊 Conclusion

**Answer to Original Question:**
> "Which workflows retrieve the last changelog entry from main BEFORE the commit?"

**Answer:**
- ✅ **`ai-local-merge` - YES** (lines 141-166 of git-local-merge.sh)
- ❌ **`ai-local-commit` - NO**
- ❌ **`ai-local-commit-safe` - NO**
- ❌ **`ai-local-merge-safe` - NO**

**Only 1 out of 4 workflows has this functionality.**

**The Good News:**
The one that matters most (`ai-local-merge`) DOES have it, and it works excellently!

---

**Next Steps:** WAITING for further instructions...
