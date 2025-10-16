# Testing Guide

## Overview

AccessiList enforces comprehensive testing before commits and merges to ensure code quality and prevent regressions.

## Automated Test Enforcement

### Installation

Install git hooks to enforce testing:

```bash
npm run hooks:install
```

This installs:
- **pre-commit hook** - Runs tests before EVERY commit
- **pre-merge-commit hook** - Runs tests before merging to main

### What Gets Tested

The production mirror test suite includes:
- ✅ **75 comprehensive tests**
- ✅ Clean URL routing
- ✅ API endpoints
- ✅ Save/restore workflow
- ✅ Content verification
- ✅ Error handling
- ✅ Static assets
- ✅ Environment configuration
- ✅ Scroll buffer behavior
- ✅ Read-only textarea functionality
- ✅ Dynamic checkpoint validation

### Pre-Commit Testing

Every commit automatically:
1. Starts Docker Apache server
2. Runs 75 production mirror tests
3. Blocks commit if ANY test fails
4. Allows commit only if ALL tests pass

**Example:**
```bash
git add .
git commit -m "Fix status icons"

# Output:
# 🧪 Running production mirror tests before commit...
# [Test results...]
# ✅ All tests passed! Proceeding with commit.
```

### Pre-Merge Testing (Main Branch)

When merging to main:
1. Automatically runs all tests
2. Blocks merge if tests fail
3. Ensures main branch always has passing tests

**Example:**
```bash
git checkout main
git merge feature-branch

# Output:
# 🧪 Running production mirror tests before merge to main...
# [Test results...]
# ✅ All tests passed! Proceeding with merge to main.
```

## Manual Testing

### Run Tests Manually

```bash
# Using npm script
npm run test:pre-commit

# Using Cursor workflow
proj-test-mirror

# Direct script
BASE_URL=http://127.0.0.1:8080 ./scripts/test-production-mirror.sh
```

### Run Specific Test Suites

```bash
# All tests
npm run test:all

# Accessibility tests only
npm run test:accessibility

# Performance tests only
npm run test:performance

# MCP validation only
npm run test:mcp
```

## Bypassing Tests (NOT Recommended)

If absolutely necessary (emergency fixes only):

```bash
# Bypass pre-commit hook
git commit --no-verify -m "Emergency fix"

# Bypass pre-merge hook
git merge --no-verify feature-branch
```

**⚠️ WARNING**: Only use `--no-verify` for emergency hotfixes. Always run tests manually afterward.

## Cursor Workflows

### Safe Commit (with tests)
Use `ai-local-commit-safe` workflow - runs tests before committing

### Safe Merge to Main (with tests)
Use `ai-merge-to-main` workflow - runs tests before merging

### Regular Commit (bypasses hooks)
Use `ai-local-commit` workflow - commits WITHOUT running tests (not recommended)

## Uninstalling Hooks

To remove git hooks:

```bash
npm run hooks:uninstall
```

**Note**: This is NOT recommended for regular development. Hooks ensure code quality.

## Continuous Integration

Future enhancement: GitHub Actions will run the same test suite on every push and PR.

## Test Logs

Test results are saved to:
```
logs/test-production-mirror-[timestamp].log
```

## Troubleshooting

### Tests failing locally?

1. **Check Docker is running:**
   ```bash
   docker compose ps
   ```

2. **Restart Docker:**
   ```bash
   docker compose down
   docker compose up -d
   sleep 3
   ```

3. **Check test logs:**
   ```bash
   tail -f logs/test-production-mirror-*.log
   ```

### Hook not running?

1. **Verify hook is installed:**
   ```bash
   ls -la .git/hooks/pre-commit
   ```

2. **Reinstall hooks:**
   ```bash
   npm run hooks:install
   ```

3. **Check hook permissions:**
   ```bash
   chmod +x .git/hooks/pre-commit
   chmod +x .git/hooks/pre-merge-commit
   ```

## Best Practices

1. ✅ **Always keep hooks installed** during development
2. ✅ **Run tests locally** before pushing to remote
3. ✅ **Fix failing tests** immediately - don't accumulate technical debt
4. ✅ **Review test output** - understand what's being validated
5. ❌ **Never use `--no-verify`** except for emergencies
6. ❌ **Don't commit failing tests** to main branch

## Test Coverage

Current test coverage:
- **Unit Tests**: StateManager, API utilities
- **Integration Tests**: Save/restore workflow, API endpoints
- **E2E Tests**: Full user flows, navigation, content rendering
- **Accessibility Tests**: WCAG compliance, keyboard navigation
- **Performance Tests**: Page load times, resource optimization

Total: **75 automated tests** with 100% pass requirement

