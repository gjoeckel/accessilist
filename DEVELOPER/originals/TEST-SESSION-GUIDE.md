# Test Session Guide

**Reserved Test Session for Automated Testing**
**Date**: October 15, 2025

---

## 🔑 Reserved Test Session: AAA

| Property | Value |
|----------|-------|
| **Session Key** | `AAA` |
| **Type** | Word checklist |
| **Status** | Always available for testing |
| **File** | `saves/AAA.json` |
| **Committed** | ✅ Yes (version controlled) |

---

## 📋 Purpose

The `AAA` session is reserved for automated testing:

- ✅ **Always exists** - Committed to git, never deleted
- ✅ **Predictable test data** - Known checkpoint states
- ✅ **Used by all test scripts** - Consistent across tests
- ✅ **No 404 errors** - Reliable for testing
- ✅ **Safe to use** - Clearly marked as test data

---

## 🎯 Usage

### In Automated Tests

```bash
# Use AAA for all automated tests
curl "https://webaim.org/training/online/accessilist/?=AAA"

# Test list-report with AAA
curl "https://webaim.org/training/online/accessilist/list-report?session=AAA"

# Verify minimal URL format
curl "https://webaim.org/training/online/accessilist/?=AAA"
```

### In Test Scripts

**External Production Test** (`scripts/external/test-production.sh`):
```bash
# Back button validation uses AAA
content=$(curl -s "$PROD_URL/list-report?session=AAA")

# Behavioral test uses AAA
http_code=$(curl -s -o /dev/null -w "%{http_code}" "$PROD_URL/?=AAA")
```

**Production Mirror Test** (`scripts/test-production-mirror.sh`):
```bash
# Similar usage in local Docker testing
http_code=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/?=AAA")
```

---

## 📊 Test Data Structure

**File**: `saves/AAA.json`

```json
{
  "session": "AAA",
  "type": "word",
  "checkpoints": [
    {
      "id": "c1-heading-levels",
      "status": "completed"
    },
    {
      "id": "c2-lists",
      "status": "in-progress"
    },
    {
      "id": "c3-tables",
      "status": "pending"
    },
    {
      "id": "c4-alt-text",
      "status": "pending"
    }
  ],
  "metadata": {
    "purpose": "Reserved test session",
    "do_not_delete": true
  }
}
```

---

## ⚠️ Important Notes

### DO NOT Delete

The `AAA` session file should **never be deleted** as it's required for:
- ✅ External production tests
- ✅ Local Docker tests
- ✅ Pre-deployment validation
- ✅ Post-deployment verification

### Version Control

The file is **intentionally committed** to git with an exception in `.gitignore`:

```gitignore
# User data and test files
saves/*.json
!saves/AAA.json  # Exception: Always commit test session
```

### Reserved Keys

The following session keys are reserved for testing:

| Key | Purpose | Status |
|-----|---------|--------|
| **AAA** | Primary test session | ✅ Active |
| ~~TEST~~ | (Deprecated - may not exist) | ⚠️ Avoid |
| ~~ABC~~ | (Deprecated - may not exist) | ⚠️ Avoid |

---

## 🧪 Test Coverage

The AAA session is used to validate:

1. **URL Format** - Minimal format `/?=AAA` works correctly
2. **Back Button** - Navigates using minimal format
3. **List Report** - Loads with valid session
4. **Session Routing** - index.php handles minimal URLs
5. **No Redirects** - Minimal format doesn't redirect to /home

---

## 🔄 Benefits

| Benefit | Description |
|---------|-------------|
| **Reliability** | Tests always work (no 404s) |
| **Predictability** | Known test data every time |
| **Clarity** | Obvious when testing vs production |
| **Maintainability** | One place to manage test data |
| **Speed** | No need to create/delete sessions |
| **Consistency** | All tests use same session |

---

## 📝 Maintenance

### Updating Test Data

If you need to update the test session:

```bash
# Edit the file
vim saves/AAA.json

# Commit the changes
git add saves/AAA.json
git commit -m "Update AAA test session data"
```

### Verifying Test Session

```bash
# Local verification
curl http://localhost:8000/?=AAA

# Production verification
curl https://webaim.org/training/online/accessilist/?=AAA
```

---

## 🚀 Integration

### Pre-Deployment Validation

The test session is validated before every deployment:

```bash
./scripts/deployment/pre-deploy-check.sh
# Verifies AAA.json exists and is valid
```

### Post-Deployment Verification

After deployment, AAA is used to verify the system:

```bash
./scripts/external/test-production.sh
# Uses AAA to test Back button and URL routing
```

---

## 📚 Related Documentation

- **EXTERNAL-PRODUCTION-TESTING.md** - How AAA is used in production tests
- **PRODUCTION-MIRROR-TESTING.md** - How AAA is used in local tests
- **URL-ROUTING-MAP.md** - Minimal URL format explanation

---

## ✅ Quick Reference

**Access URLs**:
```
Local:      http://localhost:8000/?=AAA
Production: https://webaim.org/training/online/accessilist/?=AAA
```

**Test Commands**:
```bash
# Run external tests (uses AAA)
./scripts/external/test-production.sh

# Run local tests (uses AAA)
BASE_URL=http://127.0.0.1:8080 ./scripts/test-production-mirror.sh
```

**File Location**:
```
saves/AAA.json
```

---

_Last updated: October 15, 2025_
_Status: Active and committed to repository_
