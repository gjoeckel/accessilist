# Demo Files Guide

**Date**: October 8, 2025
**Purpose**: Comprehensive demo data for testing Reports dashboard functionality

---

## Overview

7 demo save files created to showcase all checklist types with realistic mixed-status data.

**Demo Files:**
- `WRD.json` - Word (25 tasks, 4 checkpoints)
- `PPT.json` - PowerPoint (26 tasks, 4 checkpoints)
- `XLS.json` - Excel (28 tasks, 4 checkpoints)
- `DOC.json` - Google Docs (24 tasks, 4 checkpoints)
- `SLD.json` - Google Slides (25 tasks, 4 checkpoints)
- `CAM.json` - Camtasia (11 tasks, 3 checkpoints)
- `DJO.json` - Dojo (19 tasks, 4 checkpoints)

---

## Demo Data Characteristics

### Status Distribution
Each demo file has tasks distributed as:
- **~5% Completed** (1-2 tasks) - With notes and restart button visible
- **~70% In Progress** (7-19 tasks depending on type) - With notes
- **~25% Pending** (3-7 tasks) - No notes yet

### Manual Rows
Each checkpoint (checklist-1, checklist-2, etc.) has 1 manually added row:
- **Task**: "Hey! I added this!"
- **Notes**: "Great job!"
- **Status**: completed
- **Timestamp**: Creation time

### Realistic Content
- **Completed task notes**: "Completed task X.X - all requirements met!"
- **In Progress notes**: "Working on task X.X..."
- **Pending notes**: Empty (not started)

---

## Reserved Session Keys

The following keys are **RESERVED** and will not be generated for users:

| Key | Type | Purpose |
|-----|------|---------|
| WRD | word | Word demo |
| PPT | powerpoint | PowerPoint demo |
| XLS | excel | Excel demo |
| DOC | docs | Google Docs demo |
| SLD | slides | Google Slides demo |
| CAM | camtasia | Camtasia demo |
| DJO | dojo | Dojo demo |

**Implementation**: `php/api/generate-key.php` skips these keys during generation

---

## Local Testing

### View All Demos in Reports Dashboard
```
http://localhost:8000/training/online/accessilist/reports
```

Shows all 7 demo checklists with:
- Different types
- Mixed statuses (completed/in-progress/pending)
- Progress bars
- Status icons

### View Individual Demo Reports
```
http://localhost:8000/training/online/accessilist/report?session=WRD
http://localhost:8000/training/online/accessilist/report?session=PPT
http://localhost:8000/training/online/accessilist/report?session=XLS
http://localhost:8000/training/online/accessilist/report?session=DOC
http://localhost:8000/training/online/accessilist/report?session=SLD
http://localhost:8000/training/online/accessilist/report?session=CAM
http://localhost:8000/training/online/accessilist/report?session=DJO
```

Shows individual checklist with:
- Checkpoint grouping
- Task list with notes
- Status indicators
- Filter buttons
- Manual rows ("Hey! I added this!")

### Open Demo Checklist
```
http://localhost:8000/training/online/accessilist/?=WRD
```

Opens the actual checklist view (read/write mode)

---

## Production Deployment

### One-Time Upload to Production

Run this script ONCE before your first deployment:

```bash
./scripts/deployment/upload-demo-files.sh
```

**What it does:**
1. Verifies all 7 demo files exist locally
2. Tests SSH connection to production server
3. Ensures production saves/ directory exists
4. Uploads all 7 demo files via SCP
5. Verifies files on production
6. Tests Reports dashboard accessibility

**Time**: ~30 seconds
**Required**: SSH access with PEM key
**Run**: Before first deployment, after generating demo files

---

### Production URLs (After Upload)

**Reports Dashboard:**
```
https://webaim.org/training/online/accessilist/reports
```

**Individual Demo Reports:**
```
https://webaim.org/training/online/accessilist/report?session=WRD
https://webaim.org/training/online/accessilist/report?session=PPT
https://webaim.org/training/online/accessilist/report?session=XLS
https://webaim.org/training/online/accessilist/report?session=DOC
https://webaim.org/training/online/accessilist/report?session=SLD
https://webaim.org/training/online/accessilist/report?session=CAM
https://webaim.org/training/online/accessilist/report?session=DJO
```

---

## File Structure

### Demo File Format

```json
{
  "sessionKey": "WRD",
  "timestamp": 1728419000000,
  "typeSlug": "word",
  "state": {
    "sidePanel": {
      "expanded": true,
      "activeSection": "checklist-1"
    },
    "notes": {
      "textarea-1.1": "Completed task 1.1 - all requirements met!",
      "textarea-1.2": "Working on task 1.2...",
      "textarea-1.3": "",
      ...
    },
    "statusButtons": {
      "status-1.1": "completed",
      "status-1.2": "in-progress",
      "status-1.3": "pending",
      ...
    },
    "restartButtons": {
      "restart-1.1": true,
      "restart-1.2": false,
      ...
    },
    "principleRows": {
      "checklist-1": [
        {
          "task": "Hey! I added this!",
          "notes": "Great job!",
          "status": "completed",
          "timestamp": 1728419000000
        }
      ],
      "checklist-2": [...],
      ...
    }
  },
  "metadata": {
    "version": "1.0",
    "created": 1728419000000,
    "lastModified": 1728419000000
  }
}
```

---

## Generating Demo Files

### Automatic Generation

```bash
node scripts/generate-demo-files.js
```

**What it creates:**
- 7 demo .json files in `saves/` directory
- Proper status distribution (~5%/70%/25%)
- Realistic notes for each task
- 1 manual row per checkpoint
- Complete metadata

**Output:**
```
╔════════════════════════════════════════════════════════╗
║  ✅ ALL 7 DEMO FILES CREATED SUCCESSFULLY! ✅          ║
╚════════════════════════════════════════════════════════╝

Demo files created:
  • WRD.json - Word (25 tasks)
  • PPT.json - PowerPoint (26 tasks)
  • XLS.json - Excel (28 tasks)
  • DOC.json - Google Docs (24 tasks)
  • SLD.json - Google Slides (25 tasks)
  • CAM.json - Camtasia (11 tasks)
  • DJO.json - Dojo (19 tasks)
```

---

## Deployment Protection

### Demo Files are Preserved

Demo files are NOT affected by normal deployments:

**Reason**: `saves/` directory is **EXCLUDED** from deployment

**In `github-push-gate.sh` (removed but noted)**:
```bash
--exclude saves/
```

**In `.github/workflows/deploy-simple.yml`**:
```bash
--exclude saves/           # Don't include in package
--filter='P saves/'        # Preserve on production during rsync
```

**Result**: Demo files stay on production permanently (unless manually deleted)

---

## Workflow

### Initial Setup (One-Time)

```bash
# 1. Generate demo files locally
node scripts/generate-demo-files.js

# 2. Test locally
# Open: http://localhost:8000/training/online/accessilist/reports

# 3. Upload to production (one-time)
./scripts/deployment/upload-demo-files.sh

# 4. Verify on production
# Open: https://webaim.org/training/online/accessilist/reports
```

### Future Deployments

```bash
# Demo files are preserved - just deploy normally
npm run deploy:full
```

Demo files remain on production untouched.

---

## Regenerating Demo Files

### If Demo Files Need Updates

```bash
# 1. Regenerate locally
node scripts/generate-demo-files.js

# 2. Test locally
# Verify changes look good

# 3. Re-upload to production
./scripts/deployment/upload-demo-files.sh
```

---

## Testing Use Cases

### Reports Dashboard Testing
- ✅ View all 7 checklist types simultaneously
- ✅ Test filter buttons (Completed, In Progress, Pending, All)
- ✅ Verify progress bars display correctly
- ✅ Test status icons render properly
- ✅ Verify delete functionality (on demo files)

### User Report Testing
- ✅ Test each checklist type individually
- ✅ Verify checkpoint grouping works
- ✅ Test filter buttons on report page
- ✅ View manual rows ("Hey! I added this!")
- ✅ Test back button navigation

### Status Calculation Testing
- ✅ Verify "completed" status (all tasks completed)
- ✅ Verify "in-progress" status (some tasks completed/in-progress)
- ✅ Verify "pending" status (all tasks pending)
- ✅ Verify progress percentages accurate

---

## Cleanup (Optional)

### Remove Demo Files from Production

If needed, demo files can be deleted via SSH:

```bash
ssh -i ~/Developer/projects/GeorgeWebAIMServerKey.pem \
  george@ec2-3-20-59-76.us-east-2.compute.amazonaws.com \
  "cd /var/websites/webaim/htdocs/training/online/accessilist/saves && rm -f WRD.json PPT.json XLS.json DOC.json SLD.json CAM.json DJO.json"
```

### Remove Demo Files Locally

```bash
cd saves/
rm -f WRD.json PPT.json XLS.json DOC.json SLD.json CAM.json DJO.json
```

---

## Files Created

| File | Purpose | Lines |
|------|---------|-------|
| `scripts/generate-demo-files.js` | Generate demo .json files | 200 |
| `scripts/deployment/upload-demo-files.sh` | Upload demos to production | 140 |
| `DEMO-FILES-GUIDE.md` | This documentation | - |
| `saves/WRD.json` | Word demo data | ~130 |
| `saves/PPT.json` | PowerPoint demo data | ~140 |
| `saves/XLS.json` | Excel demo data | ~150 |
| `saves/DOC.json` | Google Docs demo data | ~130 |
| `saves/SLD.json` | Google Slides demo data | ~135 |
| `saves/CAM.json` | Camtasia demo data | ~70 |
| `saves/DJO.json` | Dojo demo data | ~100 |

---

## Quick Reference

```bash
# Generate demo files
node scripts/generate-demo-files.js

# Upload to production (one-time)
./scripts/deployment/upload-demo-files.sh

# View locally
http://localhost:8000/training/online/accessilist/reports

# View on production (after upload)
https://webaim.org/training/online/accessilist/reports
```

---

**Status**: ✅ Demo files ready for local testing and production upload

