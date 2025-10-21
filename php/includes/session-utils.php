<?php
/**
 * Session Utilities
 *
 * Single responsibility: Handle session data retrieval and processing
 * Used by: index.php and other components that need session data
 */

/**
 * Get checklist type from session file
 *
 * @param string $sessionKey The session key
 * @param string $defaultType Default type if not found
 * @return string The checklist type to use
 */
require_once __DIR__ . '/type-manager.php';

function getChecklistTypeFromSession($sessionKey, $defaultType = 'camtasia') {
    // Use centralized saves_path_for() function for consistent path handling
    require_once __DIR__ . '/api-utils.php';
    $sessionFile = saves_path_for($sessionKey);

    if (!file_exists($sessionFile)) {
        return $defaultType;
    }

    $sessionData = json_decode(file_get_contents($sessionFile), true);

    if (!$sessionData) {
        return $defaultType;
    }

    // STRICT MODE: Only use typeSlug (no legacy 'type' field fallback)
    if (!isset($sessionData['typeSlug'])) {
        return null; // No type slug in session data
    }

    $validated = TypeManager::validateType($sessionData['typeSlug']);
    return $validated; // Returns validated slug or null if invalid
}
