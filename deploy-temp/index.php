<?php
require_once 'php/includes/session-utils.php';
require_once 'php/includes/type-manager.php';

// Handle minimal URL parameter format: ?=EDF
$requestUri = $_SERVER['REQUEST_URI'] ?? '';
$sessionKey = null;

// Check for minimal URL format: ?=EDF (3-character session key)
if (preg_match('/\?=([A-Z0-9]{3})$/', $requestUri, $matches)) {
    $sessionKey = $matches[1];
    
    // Get the checklist type from the session file (validated slug or error)
    $checklistType = getChecklistTypeFromSession($sessionKey, '');
    if ($checklistType === null || $checklistType === '') {
        http_response_code(400);
        echo 'Invalid or missing checklist type for session';
        exit;
    }
    
    // Instead of redirecting, include the checklist page directly
    // This keeps the minimal URL format visible to users
    $_GET['session'] = $sessionKey;
    $_GET['type'] = $checklistType;
    
    // Include the checklist page without changing the URL
    include 'php/mychecklist.php';
    exit;
}

// Default behavior - redirect to home
header('Location: php/home.php');
exit; 