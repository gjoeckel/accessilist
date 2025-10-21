<?php
require_once __DIR__ . '/../includes/api-utils.php';
require_once __DIR__ . '/../includes/rate-limiter.php';

// Rate limiting: 200 restores per hour per IP
// Environment-aware rate limiting
// Production: 200/hour, Staging: 1000/hour, Development: 10000/hour
enforce_rate_limit_smart('restore');

// Get session key from query parameters
$sessionKey = isset($_GET['sessionKey']) ? $_GET['sessionKey'] : '';

// Validate session key
if (empty($sessionKey)) {
  send_error('Invalid session key', 400);
}
validate_session_key($sessionKey);

// Check if file exists
$filename = saves_path_for($sessionKey);
if (!file_exists($filename)) {
  send_error('No saved data found', 404);
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
