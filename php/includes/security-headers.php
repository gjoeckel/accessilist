<?php
/**
 * Security Headers
 *
 * Provides comprehensive security headers to protect against common web vulnerabilities.
 * Implements OWASP recommendations for secure web applications.
 *
 * Headers provided:
 * - X-Frame-Options: Prevents clickjacking attacks
 * - X-Content-Type-Options: Prevents MIME sniffing
 * - X-XSS-Protection: Legacy XSS protection for older browsers
 * - Content-Security-Policy: Modern XSS and injection protection
 * - Referrer-Policy: Controls referrer information
 * - Permissions-Policy: Restricts browser features
 * - Strict-Transport-Security: Enforces HTTPS (production only)
 */

function set_security_headers() {
    // Prevent clickjacking by disallowing iframe embedding
    header('X-Frame-Options: DENY');

    // Prevent MIME type sniffing
    header('X-Content-Type-Options: nosniff');

    // Enable XSS protection in legacy browsers
    header('X-XSS-Protection: 1; mode=block');

    // Content Security Policy - allows self-hosted resources and inline styles/scripts
    // Inline scripts/styles needed for PHP-injected configuration
    header("Content-Security-Policy: default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'; img-src 'self' data:; font-src 'self'; connect-src 'self'; frame-ancestors 'none';");

    // Control referrer information sent to other sites
    header('Referrer-Policy: strict-origin-when-cross-origin');

    // Restrict access to browser features
    header('Permissions-Policy: geolocation=(), microphone=(), camera=(), payment=(), usb=()');

    // Enforce HTTPS in production (HSTS)
    global $envConfig;
    if (isset($envConfig['isProduction']) && $envConfig['isProduction']) {
        // Max age: 1 year, include subdomains
        header('Strict-Transport-Security: max-age=31536000; includeSubDomains');
    }
}
?>
