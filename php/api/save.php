<?php
require_once __DIR__ . '/../includes/api-utils.php';
require_once __DIR__ . '/../includes/type-formatter.php';
require_once __DIR__ . '/../includes/type-manager.php';

// Verify sessions directory exists
$savesDir = __DIR__ . '/../../sessions';
if (!file_exists($savesDir)) {
    send_error('Saves directory not found', 500);
}

// Get POST data
$rawData = file_get_contents('php://input');
$data = json_decode($rawData, true);

// Validate data
if (!$data || !isset($data['sessionKey'])) {
    send_error('Invalid data format', 400);
}

$sessionKey = $data['sessionKey'];
validate_session_key($sessionKey);

// Validate type
if (!isset($data['typeSlug'])) {
    send_error('Missing typeSlug parameter', 400);
}

$validated = TypeManager::validateType($data['typeSlug']);
if ($validated === null) {
    send_error('Invalid checklist type', 400);
}

$data['typeSlug'] = $validated;
unset($data['type']); // Remove legacy field

// Atomic save with file locking
$filename = saves_path_for($sessionKey);

$fp = fopen($filename, 'c+');
if (!$fp) {
    send_error('Failed to open file', 500);
}

if (!flock($fp, LOCK_EX)) {
    fclose($fp);
    send_error('Failed to acquire file lock', 500);
}

// Read existing data
$existingContent = '';
$fileSize = filesize($filename);
if ($fileSize > 0) {
    $existingContent = fread($fp, $fileSize);
}

$existingData = null;
if ($existingContent) {
    $existingData = json_decode($existingContent, true);
}

// Merge metadata
if (!isset($data['metadata'])) {
    $data['metadata'] = [];
}

if ($existingData && isset($existingData['metadata'])) {
    $data['metadata'] = array_merge($existingData['metadata'], $data['metadata']);
}

// Update timestamp
$data['metadata']['lastModified'] = round(microtime(true) * 1000);

// Write atomically
$updatedContent = json_encode($data, JSON_UNESCAPED_SLASHES);

ftruncate($fp, 0);
rewind($fp);
fwrite($fp, $updatedContent);

flock($fp, LOCK_UN);
fclose($fp);

send_success(['message' => '']);
