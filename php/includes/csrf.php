<?php
/**
 * CSRF Protection
 *
 * Provides Cross-Site Request Forgery (CSRF) protection for API endpoints.
 * Uses session-based tokens that are validated on state-changing requests.
 *
 * Usage:
 * 1. Call session_start() before using CSRF functions
 * 2. Generate token: $token = generate_csrf_token()
 * 3. Include token in forms/AJAX: <meta name="csrf-token" content="<?php echo $token; ?>">
 * 4. Validate on POST/PUT/DELETE: validate_csrf_token($token)
 */

/**
 * Generate or retrieve CSRF token for current session
 *
 * @return string 64-character hex token
 */
function generate_csrf_token() {
    // Start session if not already started
    if (session_status() === PHP_SESSION_NONE) {
        session_start();
    }

    // Generate new token if none exists
    if (empty($_SESSION['csrf_token'])) {
        $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
    }

    return $_SESSION['csrf_token'];
}

/**
 * Validate CSRF token from request
 *
 * @param string $token Token to validate
 * @return void Dies with 403 error if invalid
 */
function validate_csrf_token($token) {
    // Start session if not already started
    if (session_status() === PHP_SESSION_NONE) {
        session_start();
    }

    // Check token exists and matches
    if (!isset($_SESSION['csrf_token']) || !hash_equals($_SESSION['csrf_token'], $token)) {
        http_response_code(403);
        header('Content-Type: application/json');
        die(json_encode([
            'success' => false,
            'message' => 'Invalid CSRF token',
            'timestamp' => time()
        ]));
    }
}

/**
 * Get CSRF token from request headers
 *
 * @return string Token from X-CSRF-Token header or empty string
 */
function get_csrf_token_header() {
    // Try to get headers
    if (function_exists('getallheaders')) {
        $headers = getallheaders();
        return $headers['X-CSRF-Token'] ?? $headers['x-csrf-token'] ?? '';
    }

    // Fallback: check $_SERVER for Apache/Nginx
    if (isset($_SERVER['HTTP_X_CSRF_TOKEN'])) {
        return $_SERVER['HTTP_X_CSRF_TOKEN'];
    }

    return '';
}

/**
 * Validate CSRF token from request header (convenience function)
 *
 * @return void Dies with 403 error if invalid
 */
function validate_csrf_from_header() {
    $token = get_csrf_token_header();
    validate_csrf_token($token);
}
?>
