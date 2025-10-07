<?php
/**
 * Common Scripts Loader
 *
 * Loads JavaScript files with proper versioning for cache busting.
 * Script loading order is critical - path-utils must load first.
 *
 * @param string $scriptSet - 'basic', 'admin', 'checklist', or 'report'
 */
function renderCommonScripts($scriptSet = 'basic') {
    global $basePath;
    $version = time();

    // CRITICAL: path-utils.js must load first (provides getAPIPath, getImagePath, etc.)
    // Load synchronously (no type="module") to ensure it's ready before type-manager.js
    echo "<!-- Path configuration handled by path-utils.js -->\n";
    echo "<script src=\"{$basePath}/js/path-utils.js?v={$version}\"></script>\n";

    // Type manager (used by admin and some other pages)
    if (in_array($scriptSet, ['admin', 'checklist'])) {
        echo "<script src=\"{$basePath}/js/type-manager.js?v={$version}\"></script>\n";
    }

    // Admin-specific scripts
    if ($scriptSet === 'admin') {
        echo "<script type=\"module\" src=\"{$basePath}/js/ui-components.js?v={$version}\"></script>\n";
        echo "<script src=\"{$basePath}/js/simple-modal.js?v={$version}\"></script>\n";
        echo "<script src=\"{$basePath}/js/ModalActions.js?v={$version}\"></script>\n";
    }

    // Checklist-specific scripts
    if ($scriptSet === 'checklist') {
        echo "<script type=\"module\" src=\"{$basePath}/js/StatusManager.js?v={$version}\"></script>\n";
        echo "<script src=\"{$basePath}/js/simple-modal.js?v={$version}\"></script>\n";
        echo "<script src=\"{$basePath}/js/ModalActions.js?v={$version}\"></script>\n";
        echo "<script type=\"module\" src=\"{$basePath}/js/ui-components.js?v={$version}\"></script>\n";
        echo "\n<!-- Utilities (shared across modules) -->\n";
        echo "<script type=\"module\" src=\"{$basePath}/js/date-utils.js?v={$version}\"></script>\n";
        echo "\n<!-- Unified Save/Restore System (NEW - replaces 7 legacy modules) -->\n";
        echo "<script type=\"module\" src=\"{$basePath}/js/StateManager.js?v={$version}\"></script>\n";
        echo "<script type=\"module\" src=\"{$basePath}/js/StateEvents.js?v={$version}\"></script>\n";
        echo "\n<!-- Main application (refactored to use unified system) -->\n";
        echo "<script type=\"module\" src=\"{$basePath}/js/main.js?v={$version}\"></script>\n";
    }

    // Report-specific scripts
    if ($scriptSet === 'report') {
        echo "<script type=\"module\" src=\"{$basePath}/js/date-utils.js?v={$version}\"></script>\n";
    }
}
?>

