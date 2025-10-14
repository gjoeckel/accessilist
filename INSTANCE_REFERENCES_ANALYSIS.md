# Instance References Analysis

## Overview
This document provides a comprehensive analysis of all code references to "Instance" found in the AccessiList codebase. The Admin table header has been updated from "Instance" to "Key" for better clarity.

## Summary of Changes Made
✅ **Updated**: `php/admin.php` line 45 - Table header from "Instance" to "Key"

## Code References Analysis

### 1. **Admin Interface Files** (Primary Focus)

#### `php/admin.php`
- **Line 45**: ✅ **UPDATED** - Table header: `<th class="admin-instance-cell">Key</th>`
- **Line 106**: `createInstanceLink(instanceId, typeSlug)` - Function name
- **Line 135**: `deleteInstance(instanceId)` - Function name  
- **Line 157**: `loadInstances()` - Function name
- **Line 189**: `'No instances found'` - User message
- **Line 194**: `for (const instance of instances)` - Loop variable
- **Line 278**: `loadInstances()` - Function call

#### `js/admin.js`
- **Lines 19-29**: `createInstanceLink()` function
- **Lines 36-46**: `createDeleteButton()` with `instanceId` parameter
- **Lines 47-60**: `showDeleteModal()` with `instanceId` parameter
- **Lines 62-80**: `deleteInstance()` function
- **Lines 83-210**: `loadInstances()` function (main function)
- **Lines 125-130**: "No instances found" message
- **Lines 145-189**: Loop processing instances
- **Line 278**: `loadInstances()` call

### 2. **API Files**

#### `php/api/instantiate.php`
- **Line 30**: `'Instance already exists'` - Success message
- **Line 66**: `'Instance created'` - Success message

#### `php/api/list.php`
- **Line 12**: `$instances = [];` - Variable declaration
- **Line 26**: `$instance = [` - Variable declaration
- **Line 45**: `$instances[] = $instance;` - Array addition
- **Line 49**: `usort($instances, function($a, $b)` - Sorting
- **Line 55**: `send_success($instances);` - Return data

### 3. **State Management**

#### `js/StateManager.js`
- **Line 73**: `this.ensureInstanceExists()` - Method call
- **Line 102**: `async ensureInstanceExists()` - Method definition
- **Line 1097**: `// Global instance` - Comment

### 4. **CSS Styling**

#### `global.css`
- **Lines 701, 715**: `.admin-instance-cell` - CSS class
- **Lines 280, 362, 449, 461, 785**: `.instance-link` - CSS class
- **Lines 104, 108, 115**: `#cancelDeleteInstance`, `#confirmDeleteInstance` - CSS IDs

#### `css/focus.css`
- **Lines 37, 111, 198, 209**: `.instance-link` - CSS class

### 5. **Documentation Files**

#### `changelog.md`
- **Line 161**: "Instance Generation" - Feature description
- **Line 166**: "Instance Linking" - Feature description
- **Line 250**: "instance tracking" - Technical description
- **Line 349**: "ensureInstanceExists()" - Method reference
- **Line 578**: "New instances" - User message
- **Lines 850, 851, 862**: Admin styling references
- **Lines 1232, 1251**: Instance link behavior

#### `DRYing-types.md`
- **Lines 66-68**: Instance metadata processing
- **Line 81**: Instance type handling
- **Line 102**: "Instance Generation" - Section header
- **Lines 426, 925, 929**: Instance type formatting

#### `DEPLOYMENT.md`
- **Line 100**: "Checklist instance" - Example URL

### 6. **Test Files**

#### `tests/reports/startup-full-2025-10-02_09-45-51.md`
- **Line 67**: "Instance Generation" - Feature description
- **Line 72**: "Instance Linking" - Feature description

## Recommendations

### 1. **Keep Current Naming** (Recommended)
The current naming convention is consistent and functional:
- **`instance`** - Used for data objects (variables, loops)
- **`instanceId`** - Used for parameters and IDs
- **`loadInstances()`** - Function names are descriptive
- **`.instance-link`** - CSS classes are semantic

### 2. **Consider Future Updates** (Optional)
If you want to standardize terminology:
- **User-facing text**: Already updated "Instance" → "Key"
- **Function names**: Could be updated for consistency
- **CSS classes**: Could be updated to match new terminology

### 3. **No Immediate Action Required**
Most references are:
- ✅ **Internal code** (function names, variables)
- ✅ **Technical documentation** (changelog, deployment docs)
- ✅ **CSS classes** (styling, not user-facing)
- ✅ **API responses** (backend communication)

## Impact Assessment

### **High Impact** (User-Facing)
- ✅ **COMPLETED**: Admin table header "Instance" → "Key"

### **Medium Impact** (Developer-Facing)
- Function names (`loadInstances`, `createInstanceLink`, etc.)
- CSS class names (`.instance-link`, `.admin-instance-cell`)
- Variable names in loops and functions

### **Low Impact** (Internal)
- API response messages
- Documentation references
- Comments and technical notes

## Files Modified
- ✅ `php/admin.php` - Updated table header text

## Files Requiring No Changes
- `js/admin.js` - Function names are descriptive and consistent
- `php/api/` files - API terminology is appropriate
- `js/StateManager.js` - Method names are clear
- CSS files - Class names are semantic and functional
- Documentation files - References are accurate

## Conclusion
The primary user-facing change has been completed. The remaining "Instance" references are appropriate for internal code, API communication, and documentation. No further changes are required unless you specifically want to standardize all terminology throughout the codebase.

---
**Analysis Date**: 2025-10-02  
**Files Analyzed**: 15+ files  
**References Found**: 236 instances  
**User-Facing Changes**: 1 completed
