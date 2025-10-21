<?php
/**
 * Rate Limiter
 *
 * Provides rate limiting to prevent API abuse and DoS attacks.
 * Uses file-based storage for simplicity (no database required).
 *
 * Usage:
 * - enforce_rate_limit('identifier', 100, 3600); // 100 requests per hour
 * - enforce_rate_limit($_SERVER['REMOTE_ADDR'], 60, 60); // 60 requests per minute per IP
 */

class RateLimiter {
    private $maxAttempts;
    private $windowSeconds;
    private $storageDir;

    /**
     * Create rate limiter instance
     *
     * @param int $maxAttempts Maximum requests allowed in time window
     * @param int $windowSeconds Time window in seconds
     */
    public function __construct($maxAttempts = 100, $windowSeconds = 3600) {
        $this->maxAttempts = $maxAttempts;
        $this->windowSeconds = $windowSeconds;
        $this->storageDir = sys_get_temp_dir() . '/accessilist-ratelimit';

        // Create storage directory if it doesn't exist
        if (!file_exists($this->storageDir)) {
            mkdir($this->storageDir, 0755, true);
        }
    }

    /**
     * Check if identifier has exceeded rate limit
     *
     * @param string $identifier Unique identifier (IP, session key, etc)
     * @return void Dies with 429 status if limit exceeded
     */
    public function checkLimit($identifier) {
        $file = $this->storageDir . '/rl_' . md5($identifier) . '.json';
        $now = time();

        // Read existing attempts
        $attempts = [];
        if (file_exists($file)) {
            $content = file_get_contents($file);
            $attempts = json_decode($content, true) ?? [];
        }

        // Remove attempts outside the time window
        $attempts = array_filter($attempts, function($timestamp) use ($now) {
            return $timestamp > ($now - $this->windowSeconds);
        });

        // Check if limit exceeded
        if (count($attempts) >= $this->maxAttempts) {
            $retryAfter = min($attempts) + $this->windowSeconds - $now;

            http_response_code(429);
            header('Content-Type: application/json');
            header('Retry-After: ' . max(1, $retryAfter));
            die(json_encode([
                'success' => false,
                'message' => 'Rate limit exceeded. Please try again later.',
                'retry_after' => max(1, $retryAfter),
                'timestamp' => time()
            ]));
        }

        // Add current attempt
        $attempts[] = $now;

        // Save updated attempts
        file_put_contents($file, json_encode(array_values($attempts)));

        // Clean up old rate limit files (older than 24 hours)
        $this->cleanupOldFiles();
    }

    /**
     * Clean up rate limit files older than 24 hours
     * Runs with 1% probability to avoid performance impact
     */
    private function cleanupOldFiles() {
        // Only run cleanup 1% of the time
        if (rand(1, 100) !== 1) {
            return;
        }

        $files = glob($this->storageDir . '/rl_*.json');
        $cutoff = time() - 86400; // 24 hours

        foreach ($files as $file) {
            if (filemtime($file) < $cutoff) {
                @unlink($file);
            }
        }
    }
}

/**
 * Enforce rate limit on identifier
 *
 * @param string $identifier Unique identifier to rate limit
 * @param int $maxAttempts Maximum attempts allowed (default: 100)
 * @param int $windowSeconds Time window in seconds (default: 3600 = 1 hour)
 * @return void Dies with 429 status if limit exceeded
 */
function enforce_rate_limit($identifier, $maxAttempts = 100, $windowSeconds = 3600) {
    $limiter = new RateLimiter($maxAttempts, $windowSeconds);
    $limiter->checkLimit($identifier);
}
?>
