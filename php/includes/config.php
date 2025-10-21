<?php
/**
 * SRD Environment Configuration
 *
 * Single source of truth for environment detection using .env file.
 * Eliminates auto-detection and provides explicit environment control.
 *
 * Setup:
 * - Change APP_ENV in .env to switch environments:
 *   - 'local' = PHP dev server (php -S localhost:8000)
 *   - 'apache-local' = Local Apache production testing
 *   - 'production' = AWS production server
 * - .env file is version controlled (no sensitive data)
 * - Hyphens in APP_ENV are normalized to underscores for key lookups
 */

/**
 * Load environment variables from .env file
 *
 * @param string $filePath Path to .env file
 * @throws Exception if .env file not found
 */
function loadEnv($filePath) {
    if (!file_exists($filePath)) {
        // STRICT MODE: .env is required - no fallback
        return false;
    }

    $lines = file($filePath, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    foreach ($lines as $line) {
        // Skip comments
        if (strpos(trim($line), '#') === 0) {
            continue;
        }

        // Skip lines without =
        if (strpos($line, '=') === false) {
            continue;
        }

        // Parse key=value
        list($key, $value) = explode('=', $line, 2);
        $_ENV[trim($key)] = trim($value);
    }

    return true;
}

// Load .env file (REQUIRED) - priority order:
// 1. Test directory config (accessilist2 only - for production testing)
// 2. Global cursor-global config (machine-specific, survives across projects)
// 3. Production external config (AWS server only)
// 4. Project local config (legacy fallback)
$globalEnvPath = '/Users/a00288946/cursor-global/config/.env';
$externalEnvPath = '/var/websites/webaim/htdocs/training/online/etc/.env';
$projectEnvPath = __DIR__ . '/../../.env';
$envLoaded = false;

// PRIORITY 1: Check for test directory (accessilist2)
$currentPath = __DIR__;
if (strpos($currentPath, 'accessilist2') !== false) {
    $testEnvPath = '/var/websites/webaim/htdocs/training/online/etc/.env.accessilist2';
    if (file_exists($testEnvPath)) {
        $envLoaded = loadEnv($testEnvPath);
    }
}

// PRIORITY 2: Try global config first (preferred for local development)
if (!$envLoaded && file_exists($globalEnvPath)) {
    $envLoaded = loadEnv($globalEnvPath);
}

// Try production external config (AWS server)
if (!$envLoaded && file_exists($externalEnvPath)) {
    $envLoaded = loadEnv($externalEnvPath);
}

// Try project local config (legacy fallback)
if (!$envLoaded && file_exists($projectEnvPath)) {
    $envLoaded = loadEnv($projectEnvPath);
}

if (!$envLoaded) {
    http_response_code(500);
    die('Configuration Error: .env file not found. Expected locations: ' . $globalEnvPath . ' OR ' . $externalEnvPath . ' OR ' . $projectEnvPath);
}

// Use .env configuration (no auto-detection fallback)
$environment = $_ENV['APP_ENV'] ?? 'local';

// Normalize environment name for key lookups (convert hyphens to underscores)
$envKey = str_replace('-', '_', strtoupper($environment));

// Get base path from environment-specific variable
$basePathKey = 'BASE_PATH_' . $envKey;
$basePath = $_ENV[$basePathKey] ?? '';

// Get API extension from environment-specific variable
$apiExtKey = 'API_EXT_' . $envKey;
$apiExtension = $_ENV[$apiExtKey] ?? '';

// Get debug mode
$debugKey = 'DEBUG_' . $envKey;
$debugMode = ($_ENV[$debugKey] ?? 'false') === 'true';

// Sessions directory path (outside web root in production for security)
if ($environment === 'production') {
    // Production: Store in etc/sessions (sibling to .env, outside web root)
    $sessionsPath = $_ENV['SESSIONS_PATH'] ?? '/var/websites/webaim/htdocs/training/online/etc/sessions';
} else {
    // Local development: keep in project for convenience
    $sessionsPath = __DIR__ . '/../../sessions';
}

// Export sessions path globally for use in all PHP files
$GLOBALS['sessionsPath'] = $sessionsPath;

// Configure PHP session parameters BEFORE any session_start() calls
// This must be done in config.php to ensure consistent session handling
if ($environment === 'production') {
    // Production: Secure session cookies
    session_set_cookie_params([
        'lifetime' => 0, // Until browser closes
        'path' => '/', // Use root path - simpler and more compatible
        'domain' => '',
        'secure' => true, // HTTPS only
        'httponly' => true, // Not accessible via JavaScript
        'samesite' => 'Lax' // CSRF protection
    ]);
} else {
    // Local development: Less restrictive for testing
    session_set_cookie_params([
        'lifetime' => 0,
        'path' => '/',
        'domain' => '',
        'secure' => false, // Allow HTTP for local testing
        'httponly' => true,
        'samesite' => 'Lax'
    ]);
}

// Export configuration for JavaScript injection
$envConfig = [
    'environment' => $environment,
    'basePath' => $basePath,
    'apiExtension' => $apiExtension,
    'debug' => $debugMode,
    'isProduction' => $environment === 'production',
    'isLocal' => $environment === 'local'
];
