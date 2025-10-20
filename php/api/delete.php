<?php
require_once __DIR__ . '/../includes/api-utils.php';
require_once __DIR__ . '/../includes/csrf.php';
require_once __DIR__ . '/../includes/rate-limiter.php';

// Only accept DELETE method (proper HTTP semantics)
if ($_SERVER['REQUEST_METHOD'] !== 'DELETE') {
    send_error('Method not allowed. Use DELETE method.', 405);
}

// Rate limiting: 50 deletes per hour per IP
enforce_rate_limit($_SERVER['REMOTE_ADDR'] . '_delete', 50, 3600);

// CSRF protection
validate_csrf_from_header();

// Get the session key from the query string
$sessionKey = $_GET['session'] ?? '';

if (empty($sessionKey)) {
    send_error('Session key is required', 400);
}

// Validate the session key (3 characters, alphanumeric)
validate_session_key($sessionKey);

// Construct the file path
$filePath = saves_path_for($sessionKey);

// Check if the file exists
if (!file_exists($filePath)) {
    send_error('Instance not found', 404);
}

// Delete the file
if (unlink($filePath)) {
    send_success(['message' => 'Instance deleted successfully']);
} else {
    send_error('Failed to delete instance', 500);
}
