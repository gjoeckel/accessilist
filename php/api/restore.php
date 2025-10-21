<?php
require_once __DIR__ . '/../includes/config.php'; // CRITICAL: Load config first!
require_once __DIR__ . '/../includes/api-utils.php';
require_once __DIR__ . '/../includes/rate-limiter.php';

// Rate limiting: 200 restores per hour per IP
// TEMPORARILY DISABLED: Rate limiting causing test failures
// TODO: Re-enable after testing is stable with more lenient limits
// Environment-aware rate limiting
// Production: 200/hour, Staging: 1000/hour, Development: 10000/hour
// enforce_rate_limit_smart('restore');

// Get session key from query parameters
$sessionKey = isset($_GET['sessionKey']) ? $_GET['sessionKey'] : '';

// Validate session key
if (empty($sessionKey)) {
  send_error('Invalid session key', 400);
}
validate_session_key($sessionKey);

// Check if file exists
$filename = saves_path_for($sessionKey);

// DIAGNOSTIC LOGGING
error_log("[RESTORE] SessionKey: $sessionKey");
error_log("[RESTORE] Filename: $filename");
error_log("[RESTORE] Sessions path: " . $GLOBALS['sessionsPath']);
error_log("[RESTORE] File exists: " . (file_exists($filename) ? 'YES' : 'NO'));
error_log("[RESTORE] Directory exists: " . (file_exists(dirname($filename)) ? 'YES' : 'NO'));
error_log("[RESTORE] CWD: " . getcwd());

if (!file_exists($filename)) {
  error_log("[RESTORE] FAILED - File not found at: $filename");
  // Include diagnostic info in response for debugging
  http_response_code(404);
  header('Content-Type: application/json');
  die(json_encode([
    'success' => false,
    'message' => 'No saved data found',
    'timestamp' => time(),
    'debug' => [
      'sessionKey' => $sessionKey,
      'filename' => $filename,
      'sessionsPath' => $GLOBALS['sessionsPath'],
      'dirname' => dirname($filename),
      'dirExists' => file_exists(dirname($filename)),
      'cwd' => getcwd()
    ]
  ]));
}

// Read and return file contents
$data = file_get_contents($filename);
if ($data === false) {
  send_error('Failed to read saved data', 500);
}

// Decode and validate JSON data
$decoded = json_decode($data, true);
if ($decoded === null) {
  send_error('Invalid saved data format', 500);
}

// Return the saved data using standard response format
send_success($decoded);
