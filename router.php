<?php
/**
 * PHP Built-in Server Router
 *
 * Enables clean URL routing for PHP's built-in development server.
 * This mimics Apache's .htaccess rewrite rules for local testing.
 *
 * Simplified: Just removes .php extensions from files in /php/ directory
 *
 * Usage: php -S localhost:8000 router.php
 */

// Get the request URI
$requestUri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);

// Allow direct access to existing files and directories
if ($requestUri !== '/' && file_exists(__DIR__ . $requestUri)) {
    return false; // Serve the file directly
}

// Simplified Routing: Remove .php extension

// API Routes: /php/api/save → /php/api/save.php
if (preg_match('#^/php/api/([^/.]+)$#', $requestUri, $matches)) {
    $apiFile = __DIR__ . '/php/api/' . $matches[1] . '.php';
    if (file_exists($apiFile)) {
        require $apiFile;
        return true;
    }
}

// General PHP Routes: /php/filename → /php/filename.php
if (preg_match('#^/php/([^/.]+)$#', $requestUri, $matches)) {
    $phpFile = __DIR__ . '/php/' . $matches[1] . '.php';
    if (file_exists($phpFile)) {
        require $phpFile;
        return true;
    }
}

// Root-level clean URLs (no /php/ prefix): /filename → /php/filename.php
// Examples: /home → /php/home.php, /systemwide-report → /php/systemwide-report.php
if (preg_match('#^/([^/.]+)$#', $requestUri, $matches)) {
    $phpFile = __DIR__ . '/php/' . $matches[1] . '.php';
    if (file_exists($phpFile)) {
        require $phpFile;
        return true;
    }
}

// Default: serve index.php for root and unknown routes
require __DIR__ . '/index.php';
return true;
