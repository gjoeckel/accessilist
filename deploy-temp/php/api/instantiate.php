<?php
require_once __DIR__ . '/../includes/api-utils.php';
require_once __DIR__ . '/../includes/type-formatter.php';
require_once __DIR__ . '/../includes/type-manager.php';

// Ensure saves directory exists
if (!file_exists('../saves') && !mkdir('../saves', 0755, true)) {
  send_error('Failed to create saves directory', 500);
}

// Only accept POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
  send_error('Method not allowed', 405);
}

$rawData = file_get_contents('php://input');
$data = json_decode($rawData, true);

if (!$data || !isset($data['sessionKey'])) {
  send_error('Invalid data format', 400);
}

$sessionKey = $data['sessionKey'];
validate_session_key($sessionKey);

$filename = saves_path_for($sessionKey);

// If file already exists, treat as success (idempotent)
if (file_exists($filename)) {
  send_success(['message' => 'Instance already exists']);
  return;
}

// Canonicalize and validate type slug
$rawTypeInput = $data['typeSlug'] ?? ($data['type'] ?? null);
$converted = $rawTypeInput ? TypeManager::convertDisplayNameToSlug($rawTypeInput) : null;
$validatedSlug = TypeManager::validateType($converted);
if ($validatedSlug === null) {
  send_error('Invalid or missing checklist type', 400);
}

// Build minimal placeholder content WITHOUT 'timestamp' so Updated remains blank in Admin
$placeholder = [
  'sessionKey' => $sessionKey,
  'type' => TypeManager::formatDisplayName($validatedSlug),
  'typeSlug' => $validatedSlug,
  'metadata' => [
    'version' => '1.0',
    // Admin prefers file mtime as created; we also store a created value for readability
    'created' => round(microtime(true) * 1000)
  ],
  // Optional initial state
  'state' => isset($data['state']) ? $data['state'] : new stdClass()
];

$json = json_encode($placeholder, JSON_UNESCAPED_SLASHES);
if ($json === false) {
  send_error('Failed to encode placeholder JSON', 500);
}

$result = file_put_contents($filename, $json);
if ($result === false) {
  send_error('Failed to write placeholder file', 500);
}

send_success(['message' => 'Instance created']);


