<?php
/**
 * List API - Detailed Version
 *
 * Returns all saved sessions with full state data for reports
 * Similar to list.php but includes state.statusButtons for status calculation
 */

require_once __DIR__ . '/../includes/api-utils.php';
require_once __DIR__ . '/../includes/type-manager.php';

// Get all JSON files from the sessions directory
$savesDir = dirname(saves_path_for('dummy')) . '/';
$files = glob($savesDir . '*.json');

if ($files === false) {
    send_error('Failed to access sessions directory', 500);
}

$instances = [];

foreach ($files as $file) {
    // Read the JSON file
    $json = file_get_contents($file);
    $data = json_decode($json, true);

    if ($data) {
        // Extract the session key from the filename
        $sessionKey = basename($file, '.json');

        // Get file creation time
        $fileCreationTime = filemtime($file) * 1000; // Convert to milliseconds

        // Resolve typeSlug for legacy files without it
        $resolvedSlug = $data['typeSlug'] ?? null;
        if (!$resolvedSlug && isset($data['type'])) {
            $resolvedSlug = TypeManager::convertDisplayNameToSlug($data['type']);
        }
        if (!$resolvedSlug) {
            $resolvedSlug = TypeManager::getDefaultType();
        }

        // Build instance data with full state (KEY DIFFERENCE from list.php)
        $instance = [
            'sessionKey' => $sessionKey,
            'timestamp' => $fileCreationTime,
            'created' => $data['metadata']['created'] ?? $fileCreationTime,
            'typeSlug' => $resolvedSlug,
            'state' => $data['state'] ?? [], // Include full state for status calculation
            'metadata' => [
                'version' => $data['metadata']['version'] ?? '1.0',
                'created' => $data['metadata']['created'] ?? $fileCreationTime
            ]
        ];

        // Only include lastModified if present (first save completed)
        if (isset($data['metadata']['lastModified'])) {
            $instance['metadata']['lastModified'] = $data['metadata']['lastModified'];
        }

        $instances[] = $instance;
    }
}

// Sort instances by timestamp (newest first)
usort($instances, function($a, $b) {
    return $b['timestamp'] - $a['timestamp'];
});

// Return the instances using standard response format
send_success($instances);
