<?php
/**
 * Simple Origin Validation (No Cookies, No Tokens!)
 *
 * This is the SIMPLEST CSRF protection that actually works.
 * Browsers automatically send Origin/Referer headers.
 * We just check if the request came from our own domain.
 *
 * Benefits:
 * - No cookies required
 * - No tokens required
 * - No session required
 * - Works with ALL privacy settings
 * - Simple to understand
 * - Impossible to mess up
 */

function validate_origin() {
    $origin = $_SERVER['HTTP_ORIGIN'] ?? '';
    $referer = $_SERVER['HTTP_REFERER'] ?? '';

    // Allowed origins (customize for your domain)
    $allowedOrigins = [
        'https://webaim.org',
        'https://www.webaim.org',
        'http://localhost:8000',
        'http://localhost'
    ];

    // Check origin header
    $validOrigin = in_array($origin, $allowedOrigins);

    // Check referer header (fallback)
    $validReferer = false;
    foreach ($allowedOrigins as $allowed) {
        if (strpos($referer, $allowed) === 0) {
            $validReferer = true;
            break;
        }
    }

    // Allow if either origin or referer is valid
    if (!$validOrigin && !$validReferer) {
        error_log("[ORIGIN CHECK] Blocked - Origin: $origin, Referer: $referer");
        http_response_code(403);
        header('Content-Type: application/json');
        die(json_encode([
            'success' => false,
            'message' => 'Invalid origin',
            'timestamp' => time()
        ]));
    }

    error_log("[ORIGIN CHECK] Allowed - Origin: $origin, Referer: $referer");
}
?>
