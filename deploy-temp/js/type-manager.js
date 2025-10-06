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
            try {
                        const configPath = window.getConfigPath ? window.getConfigPath('checklist-types.json') : '/config/checklist-types.json';
                const response = await fetch(configPath);
                if (response.ok) {
                    this.typeConfig = await response.json();
                } else {
                    console.warn('Type config not found, using fallback');
                    this.typeConfig = this.getFallbackConfig();
                }
            } catch (error) {
                console.warn('Error loading type config:', error);
                this.typeConfig = this.getFallbackConfig();
            }
        }
        return this.typeConfig;
    }
    
    /**
     * Fallback configuration if JSON file is not available
     */
    static getFallbackConfig() {
        return {
            types: {
                word: { displayName: 'Word', jsonFile: 'word.json', buttonId: 'word', category: 'Microsoft' },
                powerpoint: { displayName: 'PowerPoint', jsonFile: 'powerpoint.json', buttonId: 'powerpoint', category: 'Microsoft' },
                excel: { displayName: 'Excel', jsonFile: 'excel.json', buttonId: 'excel', category: 'Microsoft' },
                docs: { displayName: 'Docs', jsonFile: 'docs.json', buttonId: 'docs', category: 'Google' },
                slides: { displayName: 'Slides', jsonFile: 'slides.json', buttonId: 'slides', category: 'Google' },
                camtasia: { displayName: 'Camtasia', jsonFile: 'camtasia.json', buttonId: 'camtasia', category: 'Other' },
                dojo: { displayName: 'Dojo', jsonFile: 'dojo.json', buttonId: 'dojo', category: 'Other' }
            },
            defaultType: 'camtasia',
            categories: {
                Microsoft: ['word', 'powerpoint', 'excel'],
                Google: ['docs', 'slides'],
                Other: ['camtasia', 'dojo']
            }
        };
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
    
    /**
     * Convert display name to slug (for backward compatibility)
     */
    static async convertDisplayNameToSlug(displayName) {
        if (!displayName || typeof displayName !== 'string') {
            return await this.getDefaultType();
        }
        
        const config = await this.loadConfig();
        for (const [slug, data] of Object.entries(config.types || {})) {
            if (data.displayName && data.displayName.toLowerCase() === displayName.toLowerCase()) {
                return slug;
            }
        }
        
        // Fallback: convert to lowercase
        return displayName.toLowerCase();
    }
}

// Make globally available
window.TypeManager = TypeManager;
