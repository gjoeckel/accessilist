<?php
require_once __DIR__ . '/../includes/api-utils.php';

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