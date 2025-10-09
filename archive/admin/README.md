# Archived Admin Files

## Date Archived
October 9, 2025

## Reason for Archival
These files were part of the original "admin" page concept that has been superseded by the unified "reports" system. The admin page functionality has been replaced by:
- `php/reports.php` - Systemwide reports list (replaces admin listing)
- `php/report.php` - Single report view
- `css/reports.css` - All shared report/admin styles (renamed from admin.css)

## Files Archived

### Active Code Files
- **admin.php** - Original admin page for managing checklist instances
  - Used `.admin-*` class names (now `.report-*`)
  - Functionality merged into reports.php

- **admin.js** - JavaScript for admin page functionality
  - Updated to use `.report-*` class names before archival
  - Functionality available in reports.php

### Test/Screenshot Files
- **admin-page-loaded_2025-10-06T16-13-03-509Z.png** - Old admin page screenshot
- **admin-page-loaded_2025-10-02T21-57-39-206Z.png** - Old admin page screenshot
- **admin-network.json** - Admin page network test data
- **admin-cssom-desktop.json** - Admin page CSS test data

## Migration Notes

### Class Name Changes (all in css/reports.css)
- `.admin-section` → `.report-section`
- `.admin-table` → `.report-table`
- `.admin-container` → `.report-container`
- `.admin-date-cell` → `.report-date-cell`
- `.admin-instance-cell` → `.report-instance-cell`
- `.admin-action-cell` → `.report-action-cell`
- `.admin-delete-cell` → `.report-delete-cell`
- `.admin-type-cell` → `.report-type-cell`
- `.admin-delete-button` → `.report-delete-button`

### CSS File Changes
- `css/admin.css` → `css/reports.css` (renamed, all classes updated)
- `css/report.css` → `css/single-report.css` (split out single report styles)
- `css/reports.css` (old) → `css/list-reports.css` (split out list styles)

### Active Replacements
- Use `php/reports.php` for systemwide reports listing
- Use `php/report.php` for individual report viewing
- All styles consolidated in `css/reports.css` with specific styles in `single-report.css` and `list-reports.css`

## Restoration
If these files need to be restored for any reason, they can be copied back from this archive folder. However, class names would need to be reverted from `.report-*` back to `.admin-*` and CSS file references would need updating.

