<?php
require_once __DIR__ . '/../includes/api-utils.php';
require_once __DIR__ . '/../includes/type-formatter.php';
require_once __DIR__ . '/../includes/type-manager.php';

// Ensure saves directory exists
if (!file_exists('../saves') && !mkdir('../saves', 0755, true)) {
    send_error('Failed to create saves directory', 500);
}

// Get POST data
$rawData = file_get_contents('php://input');
$data = json_decode($rawData, true);

// Validate data
if (!$data || !isset($data['sessionKey'])) {
  send_error('Invalid data format', 400);
}

$sessionKey = $data['sessionKey'];

// Validate session key format (3 alphanumeric characters)
validate_session_key($sessionKey);

// Load existing data to preserve metadata
$filename = saves_path_for($sessionKey);
$existingData = null;
if (file_exists($filename)) {
    $existingContent = file_get_contents($filename);
    $existingData = json_decode($existingContent, true);
}

// Ensure metadata exists and update lastModified timestamp
if (!isset($data['metadata'])) {
    $data['metadata'] = [];
}

// Preserve existing metadata if it exists
if ($existingData && isset($existingData['metadata'])) {
    $data['metadata'] = array_merge($existingData['metadata'], $data['metadata']);
}

// Normalize and validate type fields
if (isset($data['typeSlug'])) {
    $validated = TypeManager::validateType($data['typeSlug']);
    if ($validated === null) {
        send_error('Invalid checklist type', 400);
    }
    $data['typeSlug'] = $validated;
} elseif (isset($data['type'])) {
    $converted = TypeManager::convertDisplayNameToSlug($data['type']);
    $validated = TypeManager::validateType($converted);
    if ($validated === null) {
        send_error('Invalid checklist type', 400);
    }
    $data['typeSlug'] = $validated;
} else {
    send_error('Missing checklist type', 400);
}
$data['type'] = TypeManager::formatDisplayName($data['typeSlug']);

// Update lastModified timestamp
$data['metadata']['lastModified'] = round(microtime(true) * 1000);

// Save to file system
$updatedRawData = json_encode($data, JSON_UNESCAPED_SLASHES);
$result = file_put_contents($filename, $updatedRawData);

if ($result === false) {
  send_error('Failed to save data', 500);
}

send_success(['message' => '']);