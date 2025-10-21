<?php
require_once 'php/includes/config.php';
require_once 'php/includes/session-utils.php';
require_once 'php/includes/type-manager.php';
require_once 'php/includes/security-headers.php';
require_once 'php/includes/csrf.php';

// Set security headers
set_security_headers();

// Generate CSRF token for the session and make it globally available
$GLOBALS['csrfToken'] = generate_csrf_token();

// Handle minimal URL parameter format: ?=EDF
$requestUri = $_SERVER['REQUEST_URI'] ?? '';
$sessionKey = null;

// Remove base path from URI for routing (environment-aware)
// Example: /training/online/accessilist/?=ABC becomes /?=ABC
$routePath = $basePath && $basePath !== ''
    ? str_replace($basePath, '', $requestUri)
    : $requestUri;

// Check for minimal URL format: ?=EDF or /?=EDF (3-character session key)
if (preg_match('/\/?\?=([A-Z0-9]{3})$/', $routePath, $matches)) {
    $sessionKey = $matches[1];

    // Get the checklist type from the session file (validated slug or error)
    $checklistType = getChecklistTypeFromSession($sessionKey, '');
    if ($checklistType === null || $checklistType === '') {
        http_response_code(404);
        echo '<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Checklist Not Found</title>
    <style>
        body { font-family: Arial, sans-serif; text-align: center; padding: 50px; }
        .error-container { max-width: 600px; margin: 0 auto; }
        .error-code { font-size: 72px; color: #e74c3c; margin: 0; }
        .error-message { font-size: 24px; color: #2c3e50; margin: 20px 0; }
        .error-details { font-size: 16px; color: #7f8c8d; margin: 20px 0; }
        .home-link { display: inline-block; background: #3498db; color: white; padding: 12px 24px; text-decoration: none; border-radius: 5px; margin-top: 20px; }
        .home-link:hover { background: #2980b9; }
    </style>
</head>
<body>
    <div class="error-container">
        <h1 class="error-code">404</h1>
        <h2 class="error-message">Checklist Not Found</h2>
        <p class="error-details">
            The checklist with ID "<strong>' . htmlspecialchars($sessionKey) . '</strong>" could not be found.<br>
            This may be because the checklist was deleted or the link is incorrect.
        </p>
        <a href="' . $basePath . '/home" class="home-link">← Return to Home</a>
    </div>
</body>
</html>';
        exit;
    }

    // Instead of redirecting, include the checklist page directly
    // This keeps the minimal URL format visible to users
    $_GET['session'] = $sessionKey;
    $_GET['type'] = $checklistType;

    // Include the checklist page without changing the URL
    include 'php/list.php';
    exit;
}

// Default behavior - redirect to home (clean URL)
header('Location: ' . $basePath . '/home');
exit;
