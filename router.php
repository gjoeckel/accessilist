<?php
/**
 * PHP Built-in Server Router
 *
 * Enables clean URL routing for PHP's built-in development server.
 * This mimics Apache's .htaccess rewrite rules for local testing.
 *
 * Usage: php -S localhost:8000 router.php
 */

// Get the request URI
$requestUri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);

// Allow direct access to existing files and directories
if ($requestUri !== '/' && file_exists(__DIR__ . $requestUri)) {
    return false; // Serve the file directly
}

// Clean URL Routes (match .htaccess rules)

// Home page: /home → /php/home.php
if ($requestUri === '/home' || $requestUri === '/home/') {
    require __DIR__ . '/php/home.php';
    return true;
}

// Admin page: /admin → /php/admin.php
if ($requestUri === '/admin' || $requestUri === '/admin/') {
    require __DIR__ . '/php/admin.php';
    return true;
}

// Systemwide Report page: /reports → /php/systemwide-report.php
if ($requestUri === '/reports' || $requestUri === '/reports/') {
    require __DIR__ . '/php/systemwide-report.php';
    return true;
}

// List Report page: /list-report → /php/list-report.php
if ($requestUri === '/list-report' || $requestUri === '/list-report/') {
    require __DIR__ . '/php/list-report.php';
    return true;
}

// My Checklist page: /mychecklist → /php/mychecklist.php
if ($requestUri === '/mychecklist' || $requestUri === '/mychecklist/') {
    require __DIR__ . '/php/mychecklist.php';
    return true;
}

// Checklist report page: /checklist-report → /php/checklist-report.php
if ($requestUri === '/checklist-report' || $requestUri === '/checklist-report/') {
    require __DIR__ . '/php/checklist-report.php';
    return true;
}

// API Routes: /php/api/save → /php/api/save.php
if (preg_match('#^/php/api/([^/.]+)$#', $requestUri, $matches)) {
    $apiFile = __DIR__ . '/php/api/' . $matches[1] . '.php';
    if (file_exists($apiFile)) {
        require $apiFile;
        return true;
    }
}

// General PHP Routes: /php/something → /php/something.php
if (preg_match('#^/php/([^/.]+)$#', $requestUri, $matches)) {
    $phpFile = __DIR__ . '/php/' . $matches[1] . '.php';
    if (file_exists($phpFile)) {
        require $phpFile;
        return true;
    }
}

// Default: serve index.php for root and unknown routes
require __DIR__ . '/index.php';
return true;

