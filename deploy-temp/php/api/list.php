<?php
require_once __DIR__ . '/../includes/api-utils.php';

// Get all JSON files from the saves directory
$savesDir = '../../saves/';
$files = glob($savesDir . '*.json');

if ($files === false) {
    send_error('Failed to access saves directory', 500);
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
        
        // Add instance data to the array
        $instance = [
            'sessionKey' => $sessionKey,
            'timestamp' => $fileCreationTime, // Use file creation time as the base timestamp
            'created' => $fileCreationTime, // File creation time
            'type' => $data['type'] ?? 'Unknown', // Keep type at top level for easier access
            'typeSlug' => $data['typeSlug'] ?? null,
            'metadata' => [
                'version' => '1.0',
                'created' => $fileCreationTime
            ]
        ];
        
        // Only include lastModified if the file has been saved (has a lastModified in metadata)
        // This ensures "Updated" column is empty until first save
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