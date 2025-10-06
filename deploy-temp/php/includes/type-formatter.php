<?php
/**
 * Type Formatter Utility
 * 
 * Single responsibility: Format checklist type names for consistent display
 * Used by: instantiate.php, save.php, and other components that need type formatting
 */

require_once __DIR__ . '/type-manager.php';

/**
 * Format type names for consistent display
 * 
 * @param string|null $type The raw type slug or display name
 * @return string The formatted type name
 */
function formatTypeName($type) {
    if (empty($type)) {
        return 'Unknown';
    }
    // If a display name was passed, convert to slug first
    $slug = TypeManager::convertDisplayNameToSlug($type);
    return TypeManager::formatDisplayName($slug);
}
