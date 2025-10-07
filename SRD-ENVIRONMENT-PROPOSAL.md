# SRD Environment Configuration Proposals
## Eliminating Auto-Detection: Three Simple, Reliable, DRY Methods

---

## Current Problems with Auto-Detection

### ❌ **Reliability Issues:**
- Multiple detection points (PHP + JavaScript)
- Hostname-based detection can fail (proxies, custom domains, Docker)
- Port-based detection is fragile (port 8000 assumption)
- No explicit control over environment

### ❌ **DRY Violations:**
- Detection logic duplicated in PHP and JavaScript
- Same logic written differently in each language
- 48+ `$basePath` usages across 8 PHP files
- Multiple path helper functions with similar logic

### ❌ **Simplicity Issues:**
- Complex conditional logic in multiple files
- Hard to debug when detection fails
- No single source of truth
- Manual changes needed for new environments (staging, etc.)

---

## ✅ **PROPOSAL 1: Environment Variable Method**
### Single `.env` File Configuration

**Concept:** Use a `.env` file that explicitly declares the environment once.

### Implementation:

#### **Step 1: Create `.env` file (root directory)**
```bash
# .env (NOT committed to git - use .env.example for template)
APP_ENV=local
# OR: APP_ENV=production
# OR: APP_ENV=staging

# Base paths for each environment
BASE_PATH_LOCAL=
BASE_PATH_PRODUCTION=/training/online/accessilist
BASE_PATH_STAGING=/staging/accessilist
```

#### **Step 2: Create `.env.example` (committed to git)**
```bash
# .env.example - Copy to .env and configure
APP_ENV=local
BASE_PATH_LOCAL=
BASE_PATH_PRODUCTION=/training/online/accessilist
BASE_PATH_STAGING=/staging/accessilist
```

#### **Step 3: Single PHP Config** (`php/includes/config.php`)
```php
<?php
/**
 * SRD Environment Configuration
 * Single source of truth - reads from .env file
 */

// Load environment variables (simple parser, no dependencies)
function loadEnv($filePath) {
    if (!file_exists($filePath)) {
        throw new Exception('.env file not found. Copy .env.example to .env');
    }

    $lines = file($filePath, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    foreach ($lines as $line) {
        if (strpos(trim($line), '#') === 0) continue; // Skip comments

        list($key, $value) = explode('=', $line, 2);
        $_ENV[trim($key)] = trim($value);
    }
}

// Load environment
loadEnv(__DIR__ . '/../../.env');

// Get environment from .env
$environment = $_ENV['APP_ENV'] ?? 'local';

// Map environment to base path
$basePathMap = [
    'local' => $_ENV['BASE_PATH_LOCAL'] ?? '',
    'production' => $_ENV['BASE_PATH_PRODUCTION'] ?? '/training/online/accessilist',
    'staging' => $_ENV['BASE_PATH_STAGING'] ?? '/staging/accessilist'
];

// Set base path (SINGLE SOURCE OF TRUTH)
$basePath = $basePathMap[$environment] ?? '';

// Export environment info for JavaScript
$envConfig = [
    'environment' => $environment,
    'basePath' => $basePath,
    'isProduction' => $environment === 'production'
];
```

#### **Step 4: JavaScript Injection** (`php/includes/html-head.php`)
```php
<?php
function renderHTMLHead($pageTitle = 'Accessibility Checklists', $includeLoadingStyles = false) {
    global $envConfig;
    ?>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title><?php echo htmlspecialchars($pageTitle, ENT_QUOTES, 'UTF-8'); ?></title>

<!-- Environment Configuration (Injected from PHP) -->
<script>
window.ENV = <?php echo json_encode($envConfig); ?>;
window.basePath = window.ENV.basePath;
</script>

<!-- CSS with dynamic base path -->
<link rel="stylesheet" href="<?php echo $basePath; ?>/css/simple-modal.css">
<!-- ... rest of CSS ... -->
```

#### **Step 5: Simplified JavaScript** (`js/path-utils.js`)
```javascript
(function() {
    'use strict';

    // Get base path from injected environment
    function getBasePath() {
        return window.basePath || window.ENV?.basePath || '';
    }

    // Path helpers (same logic, no detection)
    window.getImagePath = function(filename) {
        return getBasePath() + '/images/' + filename;
    };

    window.getJSONPath = function(filename) {
        return getBasePath() + '/json/' + filename;
    };

    window.getPHPPath = function(filename) {
        return getBasePath() + '/php/' + filename;
    };

    window.getAPIPath = function(filename) {
        const hasPhpExtension = /\.php$/i.test(filename);
        const effective = hasPhpExtension ? filename : `${filename}.php`;
        return getBasePath() + '/php/api/' + effective;
    };
})();
```

### **Benefits:**
✅ **Simple:** One file (`.env`) controls everything
✅ **Reliable:** No auto-detection, explicit configuration
✅ **DRY:** Environment set once, used everywhere
✅ **Flexible:** Easy to add staging, dev, test environments
✅ **Secure:** `.env` not committed (sensitive data safe)
✅ **Standard:** Industry-standard pattern (Laravel, Symfony, etc.)

### **Setup Process:**
```bash
# Local development
cp .env.example .env
# Edit .env: APP_ENV=local

# Production deployment
cp .env.example .env
# Edit .env: APP_ENV=production
```

---

## ✅ **PROPOSAL 2: Build-Time Configuration Method**
### Compile Environment at Build Time

**Concept:** Use a build script to generate environment-specific config files.

### Implementation:

#### **Step 1: Environment Config Files**
```javascript
// config/environments/local.js
export const ENV_CONFIG = {
    environment: 'local',
    basePath: '',
    apiUrl: 'http://localhost:8000',
    debug: true
};

// config/environments/production.js
export const ENV_CONFIG = {
    environment: 'production',
    basePath: '/training/online/accessilist',
    apiUrl: 'https://webaim.org/training/online/accessilist',
    debug: false
};

// config/environments/staging.js
export const ENV_CONFIG = {
    environment: 'staging',
    basePath: '/staging/accessilist',
    apiUrl: 'https://staging.webaim.org/staging/accessilist',
    debug: true
};
```

#### **Step 2: Build Script** (`scripts/build-config.sh`)
```bash
#!/bin/bash

# Build configuration for specific environment
ENVIRONMENT=${1:-local}

echo "Building configuration for: $ENVIRONMENT"

# Generate PHP config
cat > php/includes/config.php << EOF
<?php
/**
 * Auto-generated configuration
 * Environment: $ENVIRONMENT
 * Generated: $(date)
 * DO NOT EDIT - Run scripts/build-config.sh to regenerate
 */

\$environment = '$ENVIRONMENT';
EOF

case $ENVIRONMENT in
    "local")
        echo "\$basePath = '';" >> php/includes/config.php
        ;;
    "production")
        echo "\$basePath = '/training/online/accessilist';" >> php/includes/config.php
        ;;
    "staging")
        echo "\$basePath = '/staging/accessilist';" >> php/includes/config.php
        ;;
esac

cat >> php/includes/config.php << EOF

\$envConfig = [
    'environment' => \$environment,
    'basePath' => \$basePath,
    'isProduction' => \$environment === 'production'
];
EOF

# Copy environment-specific JS config
cp "config/environments/${ENVIRONMENT}.js" "js/env-config.js"

echo "✅ Configuration built for $ENVIRONMENT"
```

#### **Step 3: JavaScript Usage** (`js/path-utils.js`)
```javascript
import { ENV_CONFIG } from './env-config.js';

(function() {
    'use strict';

    const basePath = ENV_CONFIG.basePath;

    window.getImagePath = function(filename) {
        return basePath + '/images/' + filename;
    };

    window.getAPIPath = function(filename) {
        const hasPhpExtension = /\.php$/i.test(filename);
        const effective = hasPhpExtension ? filename : `${filename}.php`;
        return basePath + '/php/api/' + effective;
    };

    // Export config
    window.ENV = ENV_CONFIG;
})();
```

#### **Step 4: Package.json Scripts**
```json
{
  "scripts": {
    "build:local": "bash scripts/build-config.sh local",
    "build:production": "bash scripts/build-config.sh production",
    "build:staging": "bash scripts/build-config.sh staging",
    "deploy:production": "npm run build:production && bash deploy.sh"
  }
}
```

### **Benefits:**
✅ **Simple:** One command sets entire environment
✅ **Reliable:** Config baked in at build time, no runtime detection
✅ **DRY:** Single config source, generated everywhere needed
✅ **Safe:** Wrong environment = build fails, not runtime error
✅ **Fast:** No runtime overhead, config is static
✅ **Explicit:** Always know which environment is built

### **Usage:**
```bash
# Local development
npm run build:local

# Production deployment
npm run build:production
bash deploy.sh

# Staging deployment
npm run build:staging
```

---

## ✅ **PROPOSAL 3: PHP-Only Configuration with JSON Export**
### Single PHP Config, JavaScript Reads JSON

**Concept:** PHP determines environment once, exports config as JSON, JavaScript reads it.

### Implementation:

#### **Step 1: Single PHP Config** (`php/includes/config.php`)
```php
<?php
/**
 * SRD Configuration - Single Source of Truth
 * Set environment manually (or via environment variable)
 */

// OPTION 1: Manual setting (change this line for deployment)
$environment = 'local'; // Change to 'production' or 'staging'

// OPTION 2: Server environment variable (if available)
// $environment = getenv('APP_ENV') ?: 'local';

// Environment-specific configuration
$configs = [
    'local' => [
        'basePath' => '',
        'apiUrl' => 'http://localhost:8000',
        'debug' => true,
        'saveDir' => __DIR__ . '/../../php/saves'
    ],
    'production' => [
        'basePath' => '/training/online/accessilist',
        'apiUrl' => 'https://webaim.org/training/online/accessilist',
        'debug' => false,
        'saveDir' => '/var/websites/webaim/htdocs/training/online/accessilist/php/saves'
    ],
    'staging' => [
        'basePath' => '/staging/accessilist',
        'apiUrl' => 'https://staging.webaim.org/staging/accessilist',
        'debug' => true,
        'saveDir' => '/var/www/staging/accessilist/php/saves'
    ]
];

// Get configuration for current environment
$config = $configs[$environment] ?? $configs['local'];
$basePath = $config['basePath'];

// Export configuration for JavaScript
$envConfig = array_merge($config, [
    'environment' => $environment,
    'isProduction' => $environment === 'production'
]);

// Save config to JSON file for JavaScript access
file_put_contents(
    __DIR__ . '/../../config/runtime-config.json',
    json_encode($envConfig, JSON_PRETTY_PRINT)
);
```

#### **Step 2: JavaScript Config Loader** (`js/config-loader.js`)
```javascript
(async function() {
    'use strict';

    // Load configuration from JSON
    let config;

    try {
        // Check if injected from PHP first
        if (window.ENV) {
            config = window.ENV;
        } else {
            // Fallback: load from JSON file
            const response = await fetch('/config/runtime-config.json');
            config = await response.json();
        }
    } catch (error) {
        console.error('Failed to load config:', error);
        // Ultimate fallback
        config = {
            environment: 'local',
            basePath: '',
            debug: true
        };
    }

    // Export globally
    window.ENV = config;
    window.basePath = config.basePath;

    console.log('Environment loaded:', config.environment);
})();
```

#### **Step 3: Path Utils** (`js/path-utils.js`)
```javascript
// Wait for config to load
document.addEventListener('DOMContentLoaded', function() {
    const basePath = window.ENV?.basePath || '';

    window.getImagePath = function(filename) {
        return basePath + '/images/' + filename;
    };

    window.getJSONPath = function(filename) {
        return basePath + '/json/' + filename;
    };

    window.getPHPPath = function(filename) {
        return basePath + '/php/' + filename;
    };

    window.getAPIPath = function(filename) {
        const hasPhpExtension = /\.php$/i.test(filename);
        const effective = hasPhpExtension ? filename : `${filename}.php`;
        return basePath + '/php/api/' + effective;
    };
});
```

#### **Step 4: Load Order** (`php/includes/html-head.php`)
```php
<!-- Load config first -->
<script src="<?php echo $basePath; ?>/js/config-loader.js"></script>
<script>
// Inject config from PHP (faster than JSON fetch)
window.ENV = <?php echo json_encode($envConfig); ?>;
window.basePath = window.ENV.basePath;
</script>
<script src="<?php echo $basePath; ?>/js/path-utils.js"></script>
```

### **Benefits:**
✅ **Simple:** One PHP file controls everything
✅ **Reliable:** PHP sets environment once
✅ **DRY:** Single config, multiple formats (PHP, JSON, JS)
✅ **Flexible:** Can use manual setting or environment variables
✅ **Backwards Compatible:** JSON fallback for static pages
✅ **Fast:** Config injected directly into HTML

### **Deployment:**
```php
// For production deployment, change one line:
$environment = 'production'; // in php/includes/config.php
```

---

## COMPARISON: All Three Methods

| Feature | Method 1: .env | Method 2: Build-Time | Method 3: PHP+JSON |
|---------|---------------|---------------------|-------------------|
| **Simplicity** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Reliability** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **DRY Score** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Setup Effort** | Low | Medium | Low |
| **Deploy Process** | Copy .env | Run build script | Change 1 line |
| **Environment Switch** | Edit .env file | Run build command | Edit PHP file |
| **Debugging** | Easy (.env visible) | Easy (static files) | Medium (check JSON) |
| **Security** | High (.env excluded) | High (build-time) | Medium (JSON visible) |
| **Industry Standard** | ✅ Yes | ✅ Yes | Hybrid |
| **Dependencies** | None (pure PHP) | Bash scripts | None |
| **Multiple Envs** | ✅ Easy | ✅ Easy | ✅ Moderate |

---

## ✅ RECOMMENDED APPROACH: **Method 1 (Environment Variable) - ENHANCED**

### Why Method 1 is Best:

1. **✅ Industry Standard:** Used by Laravel, Symfony, Express.js, Django
2. **✅ Security:** `.env` excluded from git, sensitive data safe
3. **✅ Simplicity:** One file change switches entire environment
4. **✅ No Build Step:** Immediate changes without compilation
5. **✅ Team-Friendly:** Each developer has own `.env` file
6. **✅ CI/CD Ready:** Easy to inject environment variables in pipelines
7. **✅ Zero Dependencies:** Pure PHP implementation, no packages needed

### **CRITICAL ENHANCEMENTS (Based on Code Review):**

#### **Enhancement 1: API Extension Configuration** ✅
**Problem:** Local uses `.php` extension, production uses extensionless (via .htaccess)
**Solution:** Add API extension config to .env

```bash
# .env
API_EXT_LOCAL=.php
API_EXT_PRODUCTION=
```

```javascript
// path-utils.js - Enhanced
window.getAPIPath = function(filename) {
    const basePath = window.ENV?.basePath || '';
    const apiExt = window.ENV?.apiExtension || '';
    const hasExt = /\.php$/i.test(filename);
    return basePath + '/php/api/' + (hasExt ? filename : filename + apiExt);
};
```

#### **Enhancement 2: .htaccess Compatibility** ✅
**Note:** .htaccess rewrite rules work WITH .env config (not replaced)

```apache
# .htaccess (keep these rules)
RewriteRule ^php/api/([^/.]+)$ php/api/$1.php [L]
```

The config determines what extension JavaScript adds, .htaccess ensures the file is found.

#### **Enhancement 3: Security Best Practices** ✅

**Important Security Notes:**
- ✅ `.env` must NEVER be committed to git
- ✅ Add `.env` to `.gitignore` immediately
- ✅ Commit `.env.example` as template (no sensitive values)
- ✅ Use server environment variables in production when possible
- ✅ Never put database passwords or API keys in committed files

**Better Production Practice:**
```apache
# Apache VirtualHost (production)
SetEnv APP_ENV production
SetEnv BASE_PATH /training/online/accessilist
SetEnv API_EXT ""
```

```php
// config.php - Read from server env
$environment = getenv('APP_ENV') ?: $_ENV['APP_ENV'] ?? 'local';
```

#### **Enhancement 4: index.php Base Path Routing** ✅

**Problem:** Minimal URLs (/?=ABC) don't work with production base path
**Solution:** Strip base path before pattern matching

```php
// index.php - Enhanced
require_once 'php/includes/config.php';

$requestUri = $_SERVER['REQUEST_URI'] ?? '';

// Remove base path for routing
// /training/online/accessilist/?=ABC → /?=ABC
$routePath = $basePath && $basePath !== ''
    ? str_replace($basePath, '', $requestUri)
    : $requestUri;

// Now pattern matches work in all environments
if (preg_match('/\/?\?=([A-Z0-9]{3})$/', $routePath, $matches)) {
    // ... routing logic
}
```

#### **Enhancement 5: Backwards Compatibility** ✅

All changes include fallbacks to old auto-detection:

```php
// config.php
$envLoaded = loadEnv(__DIR__ . '/../../.env');

if ($envLoaded) {
    // NEW: Use .env configuration
    $environment = $_ENV['APP_ENV'] ?? 'local';
    $basePath = $_ENV["BASE_PATH_" . strtoupper($environment)] ?? '';
} else {
    // FALLBACK: Old auto-detection
    $isLocal = $_SERVER['HTTP_HOST'] === 'localhost' ...;
    $basePath = $isLocal ? '' : '/training/online/accessilist';
}
```

#### **Enhancement 6: Debug Mode Configuration** ✅

```bash
# .env
DEBUG_LOCAL=true
DEBUG_PRODUCTION=false
DEBUG_STAGING=true
```

```javascript
// path-utils.js
if (window.ENV && window.ENV.debug) {
    console.log('Path Utils Loaded:', {
        environment: window.ENV.environment,
        basePath: getBasePath(),
        apiExtension: getAPIExtension()
    });
}
```

### Migration Steps:

```bash
# 1. Create .env files
cp .env.example .env

# 2. Update config.php to read .env
# (Replace auto-detection with loadEnv() function)

# 3. Update .gitignore
echo ".env" >> .gitignore
echo "!.env.example" >> .gitignore

# 4. Test locally
# Environment: local (from .env)

# 5. Deploy to production
# Copy .env.example to server
# Set APP_ENV=production in server's .env
```

### Implementation Checklist:

- [ ] Create `.env.example` template
- [ ] Update `php/includes/config.php` with loadEnv()
- [ ] Remove auto-detection logic from PHP
- [ ] Inject config into HTML head
- [ ] Remove auto-detection from `js/path-utils.js`
- [ ] Update `.gitignore` to exclude `.env`
- [ ] Test all three environments (local, staging, production)
- [ ] Update deployment documentation
- [ ] Update README with environment setup instructions

---

## ELIMINATED PROBLEMS

### ❌ **Before (Auto-Detection):**
- 2 detection systems (PHP + JS)
- Hostname/port-based guessing
- 48 duplicate `$basePath` usages
- Complex conditional logic
- Hard to debug failures
- Can't support staging easily

### ✅ **After (SRD Method 1):**
- 1 configuration source (.env)
- Explicit environment setting
- Single `$basePath` definition
- Simple map lookup
- Easy debugging (check .env)
- Any environment supported (just add to map)

---

## NEXT STEPS

**If Method 1 (Recommended) is chosen:**

1. **Create `.env.example`** with all environment options
2. **Update `config.php`** to use loadEnv() function
3. **Test locally** with `.env` file
4. **Update all documentation** with new setup process
5. **Deploy to production** with production .env file

**Estimated Time:** 1-2 hours
**Risk Level:** Low (backwards compatible)
**Benefits:** Immediate simplification + future flexibility

