# Rollback Plan: Type System DRY Refactoring

## Overview
This document outlines the rollback procedures for the type system refactoring work on the `drying-types` branch.

## Current State (Before Refactoring)
- **Branch**: `drying-types` (new branch created from `master`)
- **Status**: All existing functionality working
- **Type System**: Dual-field approach with `type` and `typeSlug`
- **Issues**: Multiple SRD violations (DRY, Simple, Reliable)

## Rollback Triggers
Rollback should be initiated if any of the following occur:
1. **Critical Functionality Broken**: Any checklist type fails to load or save
2. **Admin Table Issues**: Type column displays incorrectly or links break
3. **Save/Restore Failures**: Session data corruption or loss
4. **Performance Degradation**: Significant slowdown in type processing
5. **User Experience Issues**: Confusing type names or broken navigation

## Rollback Procedures

### Phase 1: Immediate Assessment (5 minutes)
```bash
# Check current branch status
git status
git log --oneline -5

# Verify critical functionality
curl -s http://localhost:8000/php/api/health.php | grep -q "ok" && echo "API OK" || echo "API FAILED"
```

### Phase 2: Quick Rollback (10 minutes)
```bash
# Switch back to master branch
git checkout master

# Verify master branch is clean
git status

# Test critical paths
./tests/start_server.sh
# Test: http://localhost:8000/php/home.php
# Test: Create checklist, save, restore
# Test: Admin page type display
```

### Phase 3: Full Validation (15 minutes)
```bash
# Run comprehensive tests
php tests/run_comprehensive_tests.php

# Verify all checklist types work
# - Word, PowerPoint, Excel, Docs, Slides, Camtasia, Dojo
# - Button clicks, JSON loading, save/restore, admin display

# Check for any lingering issues
git clean -fd  # Remove any untracked files
```

## Rollback Validation Checklist

### ✅ Core Functionality
- [ ] All 7 checklist types load correctly
- [ ] Button IDs match JSON filenames
- [ ] Save/restore works for all types
- [ ] Admin table shows correct types
- [ ] Instance links work properly

### ✅ User Experience
- [ ] Page titles display correctly
- [ ] H1 headers show proper type names
- [ ] Navigation between pages works
- [ ] No console errors or warnings

### ✅ Data Integrity
- [ ] Existing saved sessions load
- [ ] New sessions create correctly
- [ ] Type information preserved in saves
- [ ] No data corruption

## Emergency Contacts
- **Primary**: Development team lead
- **Secondary**: System administrator
- **Escalation**: Project manager

## Post-Rollback Actions
1. **Document Issues**: Record what went wrong and why
2. **Analyze Root Cause**: Identify specific problems in refactoring
3. **Plan Fixes**: Address issues before re-attempting refactoring
4. **Update Rollback Plan**: Improve based on lessons learned

## Prevention Measures
- **Incremental Changes**: Make small, testable changes
- **Feature Flags**: Use configuration to enable/disable new features
- **Comprehensive Testing**: Test all checklist types after each change
- **Backup Strategy**: Keep working state available for quick rollback

## Recovery Time Objectives
- **Detection**: < 5 minutes
- **Assessment**: < 5 minutes  
- **Rollback**: < 10 minutes
- **Validation**: < 15 minutes
- **Total**: < 35 minutes

## Success Criteria for Rollback
- All functionality returns to pre-refactoring state
- No data loss or corruption
- User experience identical to before changes
- System performance maintained
- No lingering technical debt introduced

---
**Created**: 2025-10-01
**Branch**: drying-types
**Status**: Ready for refactoring work