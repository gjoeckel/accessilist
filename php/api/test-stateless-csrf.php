<?php
/**
 * Test endpoint for stateless CSRF validation
 *
 * This demonstrates stateless CSRF working WITHOUT cookies
 */
require_once __DIR__ . '/../includes/api-utils.php';
require_once __DIR__ . '/../includes/csrf-stateless.php';

// Only accept POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    send_error('Method not allowed', 405);
}

// Validate stateless CSRF token (NO COOKIES NEEDED!)
validate_stateless_csrf_from_header();

// If we get here, CSRF validation passed!
send_success([
    'message' => '✅ Stateless CSRF validation successful!',
    'method' => 'stateless',
    'cookies_required' => false,
    'client_id' => get_client_identifier(),
    'timestamp' => time()
]);
?>
