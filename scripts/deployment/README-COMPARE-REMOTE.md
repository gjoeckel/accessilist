# Compare Local Files with Remote Deployment

**Script:** `compare-with-remote.sh`
**Purpose:** Compare local working directory with remote deployment (staging or live)
**Method:** rsync dry-run with itemize-changes

---

## 🎯 Use Cases

1. **Pre-Deployment Validation** - See what will change before deploying
2. **Staging Comparison** - Compare local with accessilist2 before going live
3. **Live Comparison** - Verify what's different from current production
4. **Change Tracking** - Audit deployment history

---

## 📋 Usage

### Basic Comparison (Summary Only)

```bash
# Compare with staging (accessilist2) - DEFAULT
./scripts/deployment/compare-with-remote.sh

# Or explicitly
./scripts/deployment/compare-with-remote.sh staging

# Compare with live production (accessilist)
./scripts/deployment/compare-with-remote.sh live
```

### Detailed Comparison (With File Diffs)

```bash
# Show detailed diffs for changed files (staging)
./scripts/deployment/compare-with-remote.sh staging --detailed

# Show detailed diffs for changed files (live)
./scripts/deployment/compare-with-remote.sh live --detailed
```

---

## 📊 Output Explanation

### Rsync Item Codes

The script uses rsync's `--itemize-changes` flag. Here's what the codes mean:

```
>f+++++++++ file.php    # New file (doesn't exist on remote)
>f.st...... file.php    # Modified (size or timestamp changed)
>f......... file.php    # Unchanged
```

**Common patterns:**
- `>f+++` - **New file** (will be created)
- `>f.st` - **Updated file** (size/time changed)
- `>f...` - **Unchanged** (identical)

### Summary Output

```
╔════════════════════════════════════════════════════════╗
║              Comparison Summary                        ║
╚════════════════════════════════════════════════════════╝

Environment: staging (/var/websites/.../accessilist2/)
Total Files: 89 (deployment whitelist)
Unchanged:   75
Updated:     12
New:         2

⚠️  14 files will be changed on deployment
```

### Detailed Diff Output (--detailed flag)

Shows line-by-line diffs for modified files:

```
╔═══ Diff: php/api/save.php ═══╗
--- Remote (current)
+++ Local (new)
@@ -16,7 +16,7 @@
-// Old line
+// New line
```

---

## 🔍 Example Workflows

### Scenario 1: Pre-Deployment Check

```bash
# Check what will change before deploying to staging
./scripts/deployment/compare-with-remote.sh staging

# Output shows:
# - 12 files will be updated
# - 2 new files
# - 75 unchanged

# Review changes, then deploy
./scripts/deployment/upload-to-test-directory.sh
```

### Scenario 2: Detailed Review

```bash
# Get detailed diffs to review exact changes
./scripts/deployment/compare-with-remote.sh staging --detailed

# Reviews each changed file with diff
# Decide if changes are safe to deploy
```

### Scenario 3: Live Production Comparison

```bash
# Compare current work with live production
./scripts/deployment/compare-with-remote.sh live

# See how far ahead local development is
# Plan deployment strategy
```

### Scenario 4: Post-Deployment Verification

```bash
# After deploying to staging, verify sync
./scripts/deployment/compare-with-remote.sh staging

# Should show:
# Unchanged: 89
# Updated: 0
# New: 0
# ✅ All files in sync!
```

---

## ⚙️ Configuration

### Environment Variables

```bash
# Override defaults
export DEPLOY_USER="your-username"
export DEPLOY_HOST="your-server.com"
export SSH_KEY="~/.ssh/your-key.pem"

# Run comparison
./scripts/deployment/compare-with-remote.sh staging
```

### Defaults

- **User:** george
- **Host:** ec2-3-20-59-76.us-east-2.compute.amazonaws.com
- **SSH Key:** ~/.ssh/GeorgeWebAIMServerKey.pem
- **Staging Path:** /var/websites/webaim/htdocs/training/online/accessilist2/
- **Live Path:** /var/websites/webaim/htdocs/training/online/accessilist/

---

## 🔒 Security Notes

### What's Compared

✅ **ONLY the 89 production files** (from deployment whitelist)
- Same list as `upload-production-files.sh`
- No sensitive files (config.json, .env, .git excluded)

### What's NOT Compared

❌ Development files (node_modules/, tests/, scripts/, docs/)
❌ Sensitive configuration (config.json, .env)
❌ Git repository (.git/)
❌ Any files outside the deployment whitelist

### SSH Access

- Uses same SSH key as deployment scripts
- Read-only operations (dry-run mode)
- No files modified on server
- Safe to run anytime

---

## 📈 Benefits

### Before This Script

❌ No way to preview deployment changes
❌ Had to deploy blind or manually check each file
❌ Risk of unexpected changes on server
❌ No audit trail of what changed

### With This Script

✅ **Preview changes before deployment**
✅ **Audit what will be updated**
✅ **Detailed diffs available on demand**
✅ **Safe (read-only, dry-run mode)**
✅ **Fast** (~10 seconds for summary, ~1 min for detailed)
✅ **Accurate** (uses same file list as deployment)

---

## 🧪 Testing the Script

### Test 1: Basic Comparison

```bash
# Run comparison with staging
./scripts/deployment/compare-with-remote.sh staging

# Expected output:
# - Connection successful
# - File list created (89 files)
# - Comparison complete
# - Summary showing unchanged/updated/new counts
```

### Test 2: Detailed Diff

```bash
# Get detailed diffs
./scripts/deployment/compare-with-remote.sh staging --detailed

# Expected output:
# - Same as above
# - Plus: Line-by-line diffs for each changed file
```

### Test 3: Live Comparison

```bash
# Compare with live production (careful!)
./scripts/deployment/compare-with-remote.sh live

# Shows how far ahead local is from production
```

---

## 🔄 Integration with Deployment Workflow

### Recommended Pre-Deployment Flow

```bash
# 1. Compare with staging
./scripts/deployment/compare-with-remote.sh staging

# 2. Review changes shown

# 3. If changes look good, deploy to staging
./scripts/deployment/upload-to-test-directory.sh

# 4. Verify sync
./scripts/deployment/compare-with-remote.sh staging
# Should show: 0 updated, 0 new (all in sync)

# 5. Test staging
external-test-production

# 6. Compare with live
./scripts/deployment/compare-with-remote.sh live

# 7. Deploy to live
./scripts/deployment/upload-production-files.sh

# 8. Verify live sync
./scripts/deployment/compare-with-remote.sh live
# Should show: 0 updated, 0 new
```

---

## 💡 Advanced Usage

### Compare Specific Environment

```bash
# Staging (default)
./scripts/deployment/compare-with-remote.sh

# Live production
./scripts/deployment/compare-with-remote.sh live
```

### Get Detailed Diffs

```bash
# Summary only (fast)
./scripts/deployment/compare-with-remote.sh staging

# With diffs (slower, more detail)
./scripts/deployment/compare-with-remote.sh staging --detailed
```

### Save Comparison Report

```bash
# Save to file for review
./scripts/deployment/compare-with-remote.sh staging > comparison-report.txt

# Or with detailed diffs
./scripts/deployment/compare-with-remote.sh staging --detailed > detailed-comparison.txt
```

---

## 🎯 Best Practices

### When to Run

1. **Before deploying to staging** - Preview changes
2. **Before deploying to live** - Ensure staging tested all changes
3. **After deployment** - Verify sync
4. **When troubleshooting** - See if local and remote match

### Interpreting Results

**All files unchanged (0 updated, 0 new):**
- ✅ Local and remote are in sync
- ✅ Safe to skip deployment (no changes)

**Few files updated (1-5):**
- ✅ Normal development iteration
- ✅ Review changes, then deploy

**Many files updated (10+):**
- ⚠️ Major changes - review carefully
- ⚠️ Consider detailed diff review
- ⚠️ Test thoroughly on staging first

**Many new files (5+):**
- ⚠️ Significant additions - verify intentional
- ⚠️ Check deployment whitelist is up to date

---

## 🚨 Troubleshooting

### "SSH key not found"

**Solution:**
```bash
export SSH_KEY="$HOME/.ssh/YourKey.pem"
./scripts/deployment/compare-with-remote.sh staging
```

### "Permission denied"

**Solution:** Verify SSH key has correct permissions
```bash
chmod 600 ~/.ssh/GeorgeWebAIMServerKey.pem
```

### "Connection refused"

**Solution:** Check SSH connection
```bash
ssh -i ~/.ssh/GeorgeWebAIMServerKey.pem george@ec2-...
```

### Rsync shows many changes unexpectedly

**Possible causes:**
1. Line ending differences (CRLF vs LF)
2. Permissions changed
3. Files edited directly on server (not via deployment)

**Solution:** Review with `--detailed` flag to see actual differences

---

## 📚 Related Scripts

- **upload-production-files.sh** - Deploy to live (uses same file list)
- **upload-to-test-directory.sh** - Deploy to staging (uses same file list)
- **verify-deployment-manifest.sh** - Verify files exist locally
- **post-deploy-verify.sh** - Test after deployment

---

**Created:** 2025-10-21
**Status:** Production-ready deployment comparison tool
