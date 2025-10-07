<?php
/**
 * SRD Environment Configuration
 *
 * Single source of truth for environment detection using .env file.
 * Eliminates auto-detection and provides explicit environment control.
 *
 * Setup:
 * 1. Copy .env.example to .env
 * 2. Set APP_ENV to 'local', 'production', or 'staging'
 * 3. Configure base paths for each environment
 */

/**
 * Load environment variables from .env file
 *
 * @param string $filePath Path to .env file
 * @throws Exception if .env file not found
 */
function loadEnv($filePath) {
    if (!file_exists($filePath)) {
        // Fallback to old auto-detection if .env doesn't exist (backwards compatibility)
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

// Try to load .env file
$envLoaded = loadEnv(__DIR__ . '/../../.env');

if ($envLoaded) {
    // NEW METHOD: Use .env configuration
    $environment = $_ENV['APP_ENV'] ?? 'local';

    // Get base path from environment-specific variable
    $basePathKey = 'BASE_PATH_' . strtoupper($environment);
    $basePath = $_ENV[$basePathKey] ?? '';

    // Get API extension from environment-specific variable
    $apiExtKey = 'API_EXT_' . strtoupper($environment);
    $apiExtension = $_ENV[$apiExtKey] ?? '';

    // Get debug mode
    $debugKey = 'DEBUG_' . strtoupper($environment);
    $debugMode = ($_ENV[$debugKey] ?? 'false') === 'true';

} else {
    // FALLBACK: Old auto-detection method (backwards compatibility)
    $httpHost = $_SERVER['HTTP_HOST'] ?? '';
    $isLocal = $httpHost === 'localhost' ||
               $httpHost === '127.0.0.1' ||
               strpos($httpHost, 'local') !== false;
    
    $environment = $isLocal ? 'local' : 'production';
    $basePath = $isLocal ? '' : '/training/online/accessilist';
    $apiExtension = $isLocal ? '.php' : '';
    $debugMode = $isLocal;
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

