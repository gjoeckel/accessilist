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
    $sessionFile = "saves/{$sessionKey}.json";
    
    if (!file_exists($sessionFile)) {
        return $defaultType;
    }
    
    $sessionData = json_decode(file_get_contents($sessionFile), true);
    
    if (!$sessionData) {
        return $defaultType;
    }
    
    // Prefer typeSlug for JSON loading (validated), fallback to converting display name
    if (isset($sessionData['typeSlug'])) {
        $validated = TypeManager::validateType($sessionData['typeSlug']);
        if ($validated !== null) {
            return $validated;
        }
    }
    if (isset($sessionData['type'])) {
        $converted = TypeManager::convertDisplayNameToSlug($sessionData['type']);
        $validated = TypeManager::validateType($converted);
        if ($validated !== null) {
            return $validated;
        }
    }
    // No valid type available
    return null;
}
