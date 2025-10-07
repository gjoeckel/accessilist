/**
 * SRD Path Utilities
 *
 * Uses environment configuration injected from PHP (window.ENV)
 * No auto-detection - relies on .env file configuration
 *
 * Fallback: If window.ENV not available, use legacy auto-detection
 */
(function() {
    'use strict';

    /**
     * Get base path from environment configuration
     * Priority:
     * 1. window.ENV.basePath (from PHP .env config)
     * 2. window.basePath (direct injection)
     * 3. window.pathConfig.basePath (legacy)
     * 4. Auto-detection fallback (backwards compatibility)
     */
    function getBasePath() {
        // NEW: Use injected environment config (preferred)
        if (window.ENV && typeof window.ENV.basePath === 'string') {
            return window.ENV.basePath;
        }

        // Direct injection
        if (window.basePath && typeof window.basePath === 'string') {
            return window.basePath;
        }

        // Legacy pathConfig
        try {
            if (window.pathConfig && typeof window.pathConfig.basePath === 'string') {
                return window.pathConfig.basePath;
            }
        } catch (e) {}

        // FALLBACK: Auto-detection (backwards compatibility)
        const isLocal = window.location.hostname === 'localhost' ||
                       window.location.hostname === '127.0.0.1' ||
                       window.location.hostname.includes('local') ||
                       window.location.port === '8000';

        return isLocal ? '' : '/training/online/accessilist';
    }

    /**
     * Get API extension from environment configuration
     * Local typically uses '.php', production uses '' (handled by .htaccess)
     */
    function getAPIExtension() {
        // NEW: Use injected environment config (preferred)
        if (window.ENV && typeof window.ENV.apiExtension !== 'undefined') {
            return window.ENV.apiExtension;
        }

        // FALLBACK: Auto-detect based on base path
        const basePath = getBasePath();
        return basePath === '' ? '.php' : '';
    }

    // Image paths
    if (typeof window.getImagePath !== 'function') {
        window.getImagePath = function(filename) {
            return getBasePath() + '/images/' + filename;
        };
    }

    // JSON paths
    if (typeof window.getJSONPath !== 'function') {
        window.getJSONPath = function(filename) {
            return getBasePath() + '/json/' + filename;
        };
    }

    // Config paths
    if (typeof window.getConfigPath !== 'function') {
        window.getConfigPath = function(filename) {
            return getBasePath() + '/config/' + filename;
        };
    }

    // CSS paths
    if (typeof window.getCSSPath !== 'function') {
        window.getCSSPath = function(filename) {
            return getBasePath() + '/' + filename;
        };
    }

    // PHP page paths
    if (typeof window.getPHPPath !== 'function') {
        window.getPHPPath = function(filename) {
            return getBasePath() + '/php/' + filename;
        };
    }

    // API paths (with environment-specific extension handling)
    if (typeof window.getAPIPath !== 'function') {
        window.getAPIPath = function(filename) {
            const basePath = getBasePath();
            const apiExtension = getAPIExtension();

            // Check if filename already has .php extension
            const hasPhpExtension = /\.php$/i.test(filename);

            // Add extension if needed
            const effective = hasPhpExtension ? filename : filename + apiExtension;

            return basePath + '/php/api/' + effective;
        };
    }

    // Export environment info for debugging
    if (window.ENV && window.ENV.debug) {
        console.log('Path Utils Loaded:', {
            environment: window.ENV.environment,
            basePath: getBasePath(),
            apiExtension: getAPIExtension()
        });
    }
})();


