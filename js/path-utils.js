/**
 * SRD Path Utilities
 *
 * STRICT MODE: Requires environment configuration injected from PHP (window.ENV)
 * .env file must be configured - NO auto-detection fallbacks
 * Throws errors if configuration is missing
 */
(function() {
    'use strict';

    /**
     * Get base path from environment configuration
     * STRICT MODE: Requires window.ENV to be injected from PHP
     * No auto-detection fallback
     */
    function getBasePath() {
        // Check for injected environment config
        if (window.ENV && typeof window.ENV.basePath === 'string') {
            return window.ENV.basePath;
        }

        // Direct injection (alternative)
        if (window.basePath && typeof window.basePath === 'string') {
            return window.basePath;
        }

        // STRICT MODE: No fallback - fail with error
        console.error('Configuration Error: window.ENV not found. Check that .env is configured and PHP is injecting environment.');
        throw new Error('Environment configuration missing - window.ENV required');
    }

    /**
     * Get API extension from environment configuration
     * STRICT MODE: Requires window.ENV.apiExtension
     */
    function getAPIExtension() {
        // Check for injected environment config
        if (window.ENV && typeof window.ENV.apiExtension !== 'undefined') {
            return window.ENV.apiExtension;
        }

        // STRICT MODE: No fallback - fail with error
        console.error('Configuration Error: window.ENV.apiExtension not found');
        throw new Error('API extension configuration missing');
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

    // Clean URL paths (for modern routing)
    if (typeof window.getCleanPath !== 'function') {
        window.getCleanPath = function(page) {
            const basePath = getBasePath();
            const cleanPages = {
                'home': '/home',
                'admin': '/admin'
            };
            return basePath + (cleanPages[page] || '/php/' + page);
        };
    }

})();


