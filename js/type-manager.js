/**
 * Type Manager - Centralized type handling for AccessiList (JavaScript)
 *
 * Single responsibility: Manage all type-related operations in JavaScript
 * Used by: All JS components that need type formatting, validation, or mapping
 */

class TypeManager {
    static typeConfig = null;

    /**
     * Load type configuration from JSON file
     */
    static async loadConfig() {
        if (this.typeConfig === null) {
            // STRICT MODE: getConfigPath must be available (no fallback)
            if (!window.getConfigPath) {
                throw new Error('path-utils.js not loaded - getConfigPath function missing');
            }

            const configPath = window.getConfigPath('checklist-types.json');
            const response = await fetch(configPath);

            if (!response.ok) {
                throw new Error(`Failed to load type config: ${response.status} ${response.statusText}`);
            }

            this.typeConfig = await response.json();
        }
        return this.typeConfig;
    }

    /**
     * Get all available types
     */
    static async getAvailableTypes() {
        const config = await this.loadConfig();
        return Object.keys(config.types || {});
    }

    /**
     * Validate if a type is valid
     */
    static async validateType(type) {
        if (!type || typeof type !== 'string') {
            return await this.getDefaultType();
        }

        const validTypes = await this.getAvailableTypes();
        return validTypes.includes(type) ? type : await this.getDefaultType();
    }

    /**
     * Format type name for display
     */
    static async formatDisplayName(typeSlug) {
        if (!typeSlug || typeof typeSlug !== 'string') {
            return 'Unknown';
        }

        const config = await this.loadConfig();
        const typeData = config.types[typeSlug];

        if (typeData && typeData.displayName) {
            return typeData.displayName;
        }

        // Fallback to title case
        return typeSlug.charAt(0).toUpperCase() + typeSlug.slice(1);
    }

    /**
     * Get JSON file name for a type
     */
    static async getJsonFileName(typeSlug) {
        const config = await this.loadConfig();
        const typeData = config.types[typeSlug];

        if (typeData && typeData.jsonFile) {
            return typeData.jsonFile;
        }

        return `${typeSlug}.json`;
    }

    /**
     * Get button ID for a type
     */
    static async getButtonId(typeSlug) {
        const config = await this.loadConfig();
        const typeData = config.types[typeSlug];

        if (typeData && typeData.buttonId) {
            return typeData.buttonId;
        }

        return typeSlug;
    }

    /**
     * Get category for a type
     */
    static async getCategory(typeSlug) {
        const config = await this.loadConfig();
        const typeData = config.types[typeSlug];

        if (typeData && typeData.category) {
            return typeData.category;
        }

        return 'Other';
    }

    /**
     * Get types by category
     */
    static async getTypesByCategory(category) {
        const config = await this.loadConfig();
        return config.categories[category] || [];
    }

    /**
     * Get default type
     */
    static async getDefaultType() {
        const config = await this.loadConfig();
        return config.defaultType || 'camtasia';
    }

    /**
     * Get type from multiple sources with consistent fallback
     */
    static async getTypeFromSources() {
        // Priority order: PHP-injected > URL parameter > body attribute > default
        if (window.checklistTypeFromPHP) {
            return await this.validateType(window.checklistTypeFromPHP);
        }

        const urlParams = new URLSearchParams(window.location.search);
        const urlType = urlParams.get('type');
        if (urlType) {
            return await this.validateType(urlType);
        }

        const bodyType = document.body.getAttribute('data-checklist-type');
        if (bodyType) {
            return await this.validateType(bodyType);
        }

        return await this.getDefaultType();
    }

    // REMOVED: convertDisplayNameToSlug - legacy compatibility no longer needed
    // All code must use typeSlug directly
}

// Make globally available
window.TypeManager = TypeManager;
