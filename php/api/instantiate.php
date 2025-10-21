<?php
require_once __DIR__ . '/../includes/api-utils.php';
require_once __DIR__ . '/../includes/type-formatter.php';
require_once __DIR__ . '/../includes/type-manager.php';
require_once __DIR__ . '/../includes/csrf.php';
require_once __DIR__ . '/../includes/rate-limiter.php';

// Only accept POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    send_error('Method not allowed', 405);
}

// Rate limiting: 20 instantiations per hour per IP
enforce_rate_limit($_SERVER['REMOTE_ADDR'] . '_instantiate', 20, 3600);

// CSRF protection
validate_csrf_from_header();

// Ensure sessions directory exists
global $sessionsPath;
if (!file_exists($sessionsPath) && !mkdir($sessionsPath, 0755, true)) {
    send_error('Failed to create sessions directory', 500);
}

$rawData = file_get_contents('php://input');
$data = json_decode($rawData, true);

if (!$data || !isset($data['sessionKey'])) {
    send_error('Invalid data format', 400);
}

$sessionKey = $data['sessionKey'];
validate_session_key($sessionKey);

$filename = saves_path_for($sessionKey);

// Validate type
if (!isset($data['typeSlug'])) {
    send_error('Missing typeSlug parameter', 400);
}

$validatedSlug = TypeManager::validateType($data['typeSlug']);
if ($validatedSlug === null) {
    send_error('Invalid checklist type', 400);
}

// Build placeholder content
$placeholder = [
    'sessionKey' => $sessionKey,
    'typeSlug' => $validatedSlug,
    'metadata' => [
        'version' => '1.0',
        'created' => round(microtime(true) * 1000)
    ],
    'state' => isset($data['state']) ? $data['state'] : new stdClass()
];

$json = json_encode($placeholder, JSON_UNESCAPED_SLASHES);

// Atomic write with exclusive lock
$fp = fopen($filename, 'c');
if (!$fp) {
    send_error('Failed to open file', 500);
}

if (!flock($fp, LOCK_EX)) {
    fclose($fp);
    send_error('Failed to acquire file lock', 500);
}

// Check if already exists (idempotent operation)
$fileSize = filesize($filename);
if ($fileSize > 0) {
    flock($fp, LOCK_UN);
    fclose($fp);
    send_success(['message' => 'Instance already exists']);
    return;
}

// Write new file
fwrite($fp, $json);
flock($fp, LOCK_UN);
fclose($fp);

send_success(['message' => 'Instance created']);
