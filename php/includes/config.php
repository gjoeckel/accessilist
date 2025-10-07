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

// Load .env file (REQUIRED - no fallback)
$envLoaded = loadEnv(__DIR__ . '/../../.env');

if (!$envLoaded) {
    // STRICT MODE: .env file is required
    http_response_code(500);
    die('Configuration Error: .env file not found. Copy .env.example to .env and configure.');
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

// Export configuration for JavaScript injection
$envConfig = [
    'environment' => $environment,
    'basePath' => $basePath,
    'apiExtension' => $apiExtension,
    'debug' => $debugMode,
    'isProduction' => $environment === 'production',
    'isLocal' => $environment === 'local'
];

