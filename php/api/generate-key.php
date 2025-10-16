<?php
require_once __DIR__ . '/../includes/api-utils.php';

// Only accept GET/POST
if (!in_array($_SERVER['REQUEST_METHOD'], ['GET', 'POST'])) {
    send_error('Method not allowed', 405);
}

/**
 * Reserved keys for demo files
 * These keys are reserved and will not be generated for users
 */
function getReservedKeys() {
    return ['WRD', 'PPT', 'XLS', 'DOC', 'SLD', 'CAM', 'DJO'];
}

/**
 * Check if a key is reserved
 */
function isReservedKey($key) {
    return in_array($key, getReservedKeys(), true);
}

/**
 * Generate a random 3-character alphanumeric key
 * Uses cryptographically secure random_int()
 * Skips reserved demo keys
 */
function generateRandomKey() {
    $chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    $key = '';
    for ($i = 0; $i < 3; $i++) {
        $key .= $chars[random_int(0, strlen($chars) - 1)];
    }
    return $key;
}

/**
 * Generate unique key by checking filesystem
 * Simple approach: try until unique key found
 * No fallbacks - returns error if exhausted
 */
function generateUniqueKey() {
    $savesDir = __DIR__ . '/../../sessions';

    if (!file_exists($savesDir)) {
        send_error('Saves directory not found', 500);
    }

    // Try up to 100 times to find unique key
    // With 46,656 combinations and typical usage, this should succeed quickly
    $maxAttempts = 100;

    for ($i = 0; $i < $maxAttempts; $i++) {
        $key = generateRandomKey();

        // Skip reserved demo keys
        if (isReservedKey($key)) {
            continue;
        }

        $filename = "$savesDir/$key.json";

        if (!file_exists($filename)) {
            return $key;
        }
    }

    // Clear error - no fallback
    send_error('Unable to generate unique key - all attempts exhausted', 503);
}

// Generate and return unique key
$uniqueKey = generateUniqueKey();
send_success(['sessionKey' => $uniqueKey]);
