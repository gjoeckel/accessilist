(function() {
    'use strict';

    function getBasePath() {
        try {
            if (window.pathConfig && typeof window.pathConfig.basePath === 'string') {
                return window.pathConfig.basePath;
            }
        } catch (e) {}
        
        // Detect local environment
        const isLocal = window.location.hostname === 'localhost' ||
                       window.location.hostname === '127.0.0.1' ||
                       window.location.hostname.includes('local') ||
                       window.location.port === '8000';
        
        return isLocal ? '' : '/training/online/accessilist';
    }

    if (typeof window.getImagePath !== 'function') {
        window.getImagePath = function(filename) {
            return getBasePath() + '/images/' + filename;
        };
    }

    if (typeof window.getJSONPath !== 'function') {
        window.getJSONPath = function(filename) {
            return getBasePath() + '/json/' + filename;
        };
    }

    if (typeof window.getConfigPath !== 'function') {
        window.getConfigPath = function(filename) {
            return getBasePath() + '/config/' + filename;
        };
    }

    if (typeof window.getCSSPath !== 'function') {
        window.getCSSPath = function(filename) {
            return getBasePath() + '/' + filename;
        };
    }

    if (typeof window.getPHPPath !== 'function') {
        window.getPHPPath = function(filename) {
            return getBasePath() + '/php/' + filename;
        };
    }

    if (typeof window.getAPIPath !== 'function') {
        window.getAPIPath = function(filename) {
            // Support extensionless names in production while keeping .php locally
            const basePath = getBasePath();
            const isLocalEnv = basePath === '';
            const hasPhpExtension = /\.php$/i.test(filename);
            const effective = (!hasPhpExtension && isLocalEnv) ? `${filename}.php` : filename;
            return basePath + '/php/api/' + effective;
        };
    }
})();


