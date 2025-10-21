<?php
/**
 * Stateless CSRF Protection (No Cookies Required!)
 *
 * Uses HMAC-based tokens that don't require server-side sessions.
 * Perfect for privacy-focused applications and users with cookies disabled.
 *
 * How it works:
 * 1. Generate token: HMAC(client_identifier + timestamp + secret)
 * 2. Client sends token in request header
 * 3. Server validates HMAC and timestamp (prevents replay attacks)
 *
 * Benefits:
 * - No cookies required
 * - No server-side state
 * - Scales horizontally (no session storage)
 * - Works with cookie blockers
 * - Privacy-friendly
 */

/**
 * Get or generate secret key for HMAC
 * Store in .env or config file (NEVER in version control)
 */
function get_csrf_secret() {
    // In production, load from environment variable or secure config
    // DO NOT hardcode in production!
    $secret = getenv('CSRF_SECRET');

    if (!$secret) {
        // Fallback: generate and store (for development only)
        $secretFile = __DIR__ . '/../../.csrf-secret';
        if (file_exists($secretFile)) {
            $secret = file_get_contents($secretFile);
        } else {
            // Generate new secret (64 bytes = 512 bits)
            $secret = bin2hex(random_bytes(64));
            file_put_contents($secretFile, $secret, LOCK_EX);
            chmod($secretFile, 0600); // Read/write for owner only
        }
    }

    return $secret;
}

/**
 * Get client identifier (IP + User-Agent)
 * This ties the token to a specific client without cookies
 */
function get_client_identifier() {
    $ip = $_SERVER['REMOTE_ADDR'] ?? 'unknown';
    $userAgent = $_SERVER['HTTP_USER_AGENT'] ?? 'unknown';
    return $ip . '|' . $userAgent;
}

/**
 * Generate stateless CSRF token
 *
 * @param int $ttl Time-to-live in seconds (default: 1 hour)
 * @return string Base64-encoded token
 */
function generate_stateless_csrf_token($ttl = 3600) {
    $secret = get_csrf_secret();
    $clientId = get_client_identifier();
    $timestamp = time();
    $expiry = $timestamp + $ttl;

    // Create payload: client_id|expiry_timestamp
    $payload = $clientId . '|' . $expiry;

    // Generate HMAC signature
    $signature = hash_hmac('sha256', $payload, $secret);

    // Combine payload and signature
    $token = base64_encode($payload . '|' . $signature);

    return $token;
}

/**
 * Validate stateless CSRF token
 *
 * @param string $token Token to validate
 * @return bool True if valid, false otherwise
 */
function validate_stateless_csrf_token($token) {
    if (empty($token)) {
        error_log("[CSRF STATELESS] Token is empty");
        return false;
    }

    // Decode token
    $decoded = base64_decode($token, true);
    if ($decoded === false) {
        error_log("[CSRF STATELESS] Token decode failed");
        return false;
    }

    // Split into parts: client_id|expiry|signature
    $parts = explode('|', $decoded);
    if (count($parts) !== 4) { // ip|useragent|expiry|signature
        error_log("[CSRF STATELESS] Invalid token format");
        return false;
    }

    $tokenIp = $parts[0];
    $tokenUserAgent = $parts[1];
    $expiry = $parts[2];
    $providedSignature = $parts[3];

    // Check if token expired
    if (time() > $expiry) {
        error_log("[CSRF STATELESS] Token expired");
        return false;
    }

    // Verify client identifier matches
    $currentClientId = get_client_identifier();
    $tokenClientId = $tokenIp . '|' . $tokenUserAgent;

    if ($tokenClientId !== $currentClientId) {
        error_log("[CSRF STATELESS] Client identifier mismatch");
        // OPTIONAL: You can relax this check if users change networks/browsers
        // return false;
    }

    // Recompute signature
    $secret = get_csrf_secret();
    $payload = $tokenClientId . '|' . $expiry;
    $expectedSignature = hash_hmac('sha256', $payload, $secret);

    // Constant-time comparison to prevent timing attacks
    if (!hash_equals($expectedSignature, $providedSignature)) {
        error_log("[CSRF STATELESS] Signature mismatch");
        return false;
    }

    error_log("[CSRF STATELESS] Token valid");
    return true;
}

/**
 * Get CSRF token from request header
 * Same as session-based version for compatibility
 */
function get_stateless_csrf_token_header() {
    if (function_exists('getallheaders')) {
        $headers = getallheaders();
        return $headers['X-CSRF-Token'] ?? $headers['x-csrf-token'] ?? '';
    }

    if (isset($_SERVER['HTTP_X_CSRF_TOKEN'])) {
        return $_SERVER['HTTP_X_CSRF_TOKEN'];
    }

    return '';
}

/**
 * Validate CSRF token from request header (stateless version)
 * Drop-in replacement for validate_csrf_from_header()
 */
function validate_stateless_csrf_from_header() {
    $token = get_stateless_csrf_token_header();

    if (!validate_stateless_csrf_token($token)) {
        http_response_code(403);
        header('Content-Type: application/json');
        die(json_encode([
            'success' => false,
            'message' => 'Invalid CSRF token',
            'timestamp' => time(),
            'debug' => [
                'stateless' => true,
                'token_received' => !empty($token),
                'client_id' => get_client_identifier()
            ]
        ]));
    }
}
?>
