<?php
require_once __DIR__ . '/../includes/api-utils.php';
require_once __DIR__ . '/../includes/type-manager.php';
require_once __DIR__ . '/../includes/rate-limiter.php';

// Rate limiting: 100 list requests per hour per IP
// Environment-aware rate limiting
// Production: 100/hour, Staging: 500/hour, Development: 5000/hour
enforce_rate_limit_smart('list');

// Get all JSON files from the sessions directory using the same path as other APIs
global $sessionsPath;
$files = glob($sessionsPath . '/*.json');

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

        // Add instance data to the array (standardized shape)
        $instance = [
            'sessionKey' => $sessionKey,
            'timestamp' => $fileCreationTime,
            'created' => $fileCreationTime,
            'typeSlug' => $resolvedSlug,
            'metadata' => [
                'version' => '1.0',
                'created' => $fileCreationTime
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
