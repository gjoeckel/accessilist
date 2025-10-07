# Complete .env Code Analysis

**Problem**: Production .env keeps getting set to `APP_ENV=local` instead of `APP_ENV=production`

---

## Files That READ .env

### 1. `php/includes/config.php` (Lines 23-56)
**Purpose**: Loads and parses .env file

```php
function loadEnv($filePath) {
    if (!file_exists($filePath)) {
        return false;
    }
    $lines = file($filePath, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    foreach ($lines as $line) {
        if (strpos(trim($line), '#') === 0) continue;
        if (strpos($line, '=') === false) continue;
        list($key, $value) = explode('=', $line, 2);
        $_ENV[trim($key)] = trim($value);
    }
    return true;
}

// Line 50: Load .env file
$envLoaded = loadEnv(__DIR__ . '/../../.env');

if (!$envLoaded) {
    http_response_code(500);
    die('Configuration Error: .env file not found.');
}

// Lines 59-74: Use environment variables
$environment = $_ENV['APP_ENV'] ?? 'local';
$envKey = str_replace('-', '_', strtoupper($environment));
$basePath = $_ENV['BASE_PATH_' . $envKey] ?? '';
$apiExtension = $_ENV['API_EXT_' . $envKey] ?? '';
$debugMode = ($_ENV['DEBUG_' . $envKey] ?? 'false') === 'true';
```

**Status**: ✅ READ-ONLY (does not modify .env)

---

## Files That DEPLOY/SYNC .env

### 2. `github-push-gate.sh` (Lines 133-159)
**Purpose**: Main deployment script - EXCLUDES .env

```bash
rsync -avz --progress \
  --exclude .git/ \
  --exclude .gitignore \
  --exclude .cursor/ \
  --exclude node_modules/ \
  --exclude .DS_Store \
  --exclude .env \           # ← EXCLUDES .env
  --exclude .env.local \
  --exclude .env.backup \
  --exclude saves/ \
  --exclude logs/ \
  --exclude tests/ \
  ...
```

**Status**: ✅ EXCLUDES .env (should NOT deploy)

### ✅ **php/includes/html-head.php** - Injects ENV to JavaScript
```php
<script>
window.ENV = <?php echo json_encode($envConfig); ?>;
window.basePath = window.ENV.basePath;
</script>
```
**Purpose**: Passes PHP environment config to JavaScript
**Status**: ✅ READ-ONLY - injects from $_ENV

### ✅ **js/path-utils.js** - Reads window.ENV
```javascript
// STRICT MODE: Requires window.ENV injected from PHP
if (!window.ENV) {
    console.error('Configuration Error: window.ENV not found. Check that .env is configured');
    throw new Error('Environment configuration missing');
}
```
**Purpose**: Uses window.ENV.basePath and window.ENV.apiExtension
**Status**: ✅ READ-ONLY

### ✅ **js/admin.js** - Reads window.ENV
```javascript
console.log('Path config details:', {
    environment: window.pathConfig.environment,
    basePath: window.pathConfig.basePath
});
```
**Purpose**: Reads environment for debugging
**Status**: ✅ READ-ONLY

### ✅ **src/index.js** - Reads process.env
```javascript
const config = {
    anthropicApiKey: process.env.ANTHROPIC_API_KEY,
    projectPath: process.env.PROJECT_PATH || process.cwd()
};
```
**Purpose**: Reads API keys from environment (different project)
**Status**: ✅ READ-ONLY

### ✅ **tests/puppeteer/test-config.js** - Reads process.env
```javascript
browser: {
    headless: process.env.HEADLESS !== 'false',
    slowMo: process.env.SLOW_MO ? parseInt(process.env.SLOW_MO) : 0
}
```
**Purpose**: Test configuration from environment
**Status**: ✅ READ-ONLY

### 3. `scripts/deploy-to-aws.sh` (Lines 40-82) ⚠️ LEGACY SCRIPT
**Purpose**: OLD standalone deployment script

```bash
# Line 46: EXCLUDES .env from dry run
rsync -avz --dry-run \
  --exclude .env \
  ...

# Line 69: EXCLUDES .env from actual deploy
rsync -avz --progress \
  --exclude .env \
  ...

# Line 82: CREATES .env on production (PROBLEMATIC!)
ssh -i "$PEM_FILE" "$SERVER" "cd $REMOTE_PATH && if [ ! -f .env ]; then cp .env.example .env && sed -i 's/APP_ENV=local/APP_ENV=production/' .env && echo '✅ .env created and configured for production'; else echo '✅ .env already exists'; fi"
```

**Status**: ❌ **THIS IS THE PROBLEM!**
- Script was supposed to be DELETED
- Still exists and may be run accidentally
- Line 82 tries to copy .env.example (which doesn't exist)
- Falls back to "✅ .env already exists" message
- **DOES NOT actually check or update production .env**

---

## Files That REFERENCE .env

### 4. `.gitignore` (Lines 21-24)
```bash
# Note: .env is version controlled (no sensitive data)
# Only exclude local override files
.env.local
.env.*.local
```

**Status**: ✅ Correct - .env is in git

### 5. `start.sh` - May reference .env
**Need to check if this exists**

### 6. `scripts/setup-local-apache.sh` - May set up .env
**Need to check deployment/setup code**

---

## ROOT CAUSE ANALYSIS

### Why Production .env Keeps Reverting to `APP_ENV=local`:

**Theory 1**: `scripts/deploy-to-aws.sh` still being run
- This script was supposed to be deleted
- It has logic that could be interfering
- **ACTION**: DELETE this file

**Theory 2**: Some other script is copying local .env
- Need to search all shell scripts for .env manipulation
- **ACTION**: Find and eliminate

**Theory 3**: .env file permissions prevent modification
- Current: `-r--r----- 1 george www-data 590`  (read-only)
- This is GOOD - prevents accidental changes
- But means we need to:
  1. Change permissions temporarily: `chmod 640 .env`
  2. Update content to `APP_ENV=production`
  3. Lock it: `chmod 440 .env`

---

## RECOMMENDED ACTIONS

### Immediate Fix:
```bash
# 1. DELETE the legacy deploy script
rm scripts/deploy-to-aws.sh

# 2. Fix production .env (with permissions handling)
ssh ... '
  chmod 640 /var/.../accessilist/.env
  cat > /var/.../accessilist/.env << EOF
APP_ENV=production
BASE_PATH_PRODUCTION=/training/online/accessilist
API_EXT_PRODUCTION=
DEBUG_PRODUCTION=false
EOF
  chmod 440 /var/.../accessilist/.env
  cat /var/.../accessilist/.env
'

# 3. Verify exclusion is working
grep "exclude .env" github-push-gate.sh

# 4. Test deployment doesn't touch .env
# Add marker, deploy, check marker survives
```

### Search All Shell Scripts:
```bash
find scripts/ -name "*.sh" -exec grep -l "\.env\|APP_ENV" {} \;
```

---

## All Shell Scripts That Touch .env:

### ❌ **scripts/deploy-to-aws.sh** (LEGACY - DELETE)
**Lines 46, 69, 82**
```bash
--exclude .env \  # Excludes from rsync

# Line 82: TRIES to configure .env (BROKEN!)
ssh ... "if [ ! -f .env ]; then cp .env.example .env && sed -i 's/APP_ENV=local/APP_ENV=production/' .env; else echo '✅ .env already exists'; fi"
```
**Problem**: Tries to copy .env.example (doesn't exist), silently fails
**ACTION**: DELETE THIS FILE

### ⚠️ **scripts/setup-local-apache.sh** (Line 166-181)
```bash
if [ ! -f "$PROJECT_DIR/.env" ]; then
    cat > "$PROJECT_DIR/.env" <<EOF
APP_ENV=local
BASE_PATH_LOCAL=
BASE_PATH_PRODUCTION=/training/online/accessilist
...
EOF
    chmod 600 "$PROJECT_DIR/.env"
fi
```
**Purpose**: Creates LOCAL .env for Apache testing
**Status**: OK - only runs for local setup

### ⚠️ **scripts/verify-mcp-autonomous.sh** (Line 136)
```bash
echo "autonomous_mcp_ready=true" >> "$PROJECT_ROOT/.env"
```
**Problem**: APPENDS to .env file!
**ACTION**: Review - should not modify .env

### ⚠️ **scripts/start-mcp-servers.sh** (Lines 18-19)
```bash
if [ -f "$PROJECT_ROOT/.env" ]; then
    export $(grep -v '^#' "$PROJECT_ROOT/.env" | xargs)
fi
```
**Purpose**: READS .env for MCP environment
**Status**: OK - read-only

### ⚠️ **scripts/setup-cursor-environment.sh** (Lines 50-71, 85-87)
```bash
if [ ! -f ".env" ]; then
    cat > .env << 'EOF'
# Cursor MCP Environment Variables
...
EOF
fi

# Also READS .env
if [ -f "$PROJECT_ROOT/.env" ]; then
    export $(grep -v '^#' "$PROJECT_ROOT/.env" | xargs)
fi
```
**Purpose**: Creates MCP-related .env (different project)
**Status**: OK - different context

### ⚠️ **scripts/autonomous-mode.sh** (Lines 11-12)
```bash
echo "autonomous_mode=true" >> .env
echo "mcp_only_operations=true" >> .env
```
**Problem**: APPENDS to .env file!
**ACTION**: Review - should not modify .env

### ⚠️ **start.sh** (Line 3)
```bash
source .env
```
**Purpose**: READS .env for Node.js app
**Status**: OK - read-only

### ❌ **deploy.sh** (Lines 38-46) - LEGACY DEPLOY
```bash
rsync -av --delete \
  --exclude .git/ \
  --exclude .github/ \
  --exclude .cursor/ \
  --exclude node_modules/ \
  --exclude deploy-temp/ \
  --exclude "*.log" \
  --exclude ".DS_Store" \
  ./ deploy-temp/
```
**Problem**: Does NOT exclude .env - will copy it to deploy-temp!
**Status**: ❌ LEGACY - Should be deleted or fixed

### ❌ **.github/workflows/deploy-simple.yml** (Lines 33-40)
```yaml
- name: Create deployment package
  run: |
    rsync -av --delete \
      --exclude .git/ \
      --exclude .github/ \
      --exclude .cursor/ \
      --exclude node_modules/ \
      --exclude deploy-temp/ \
      --exclude "*.log" \
      . deploy-temp/
```
**Problem**: Does NOT exclude .env - will deploy it!
**Status**: ❌ ACTIVE GITHUB WORKFLOW - WILL OVERWRITE PRODUCTION .env

### ❌ **.github/workflows/deploy.yml** (Lines 95-106)
```yaml
- name: Create deployment package
  run: |
    rsync -av --delete \
      --exclude .git/ \
      --exclude .github/ \
      --exclude .cursor/ \
      --exclude node_modules/ \
      --exclude deploy-temp/ \
      --exclude "*.log" \
      --exclude tests/ \
      --exclude scripts/ \
      --exclude archive/ \
      --exclude backups/ \
      . deploy-temp/
```
**Problem**: Does NOT exclude .env - will deploy it!
**Status**: ❌ DISABLED BUT DANGEROUS if re-enabled

---

## ROOT CAUSE IDENTIFIED:

**Production .env is MANUALLY SET, but local .env in git contains `APP_ENV=local`**

When ANY deployment happens that DOESN'T exclude .env properly, it syncs the LOCAL version to production.

### Check Current Local .env:
```bash
cat .env | grep APP_ENV
# Result: APP_ENV=apache-local  (or local)
```

### Check Production .env:
```bash
ssh ... "cat /var/.../accessilist/.env | grep APP_ENV"
# Result: APP_ENV=local  (WRONG!)
```

### rsync Exclusion Test:
```bash
# Verify github-push-gate.sh EXCLUDES .env
grep "exclude .env" github-push-gate.sh
# Result: --exclude .env \  (Line 139)
```

---

## THE SMOKING GUN:

**LOOK AT THE PRODUCTION .ENV FILE CONTENT:**
```
# Environment Configuration
# Change APP_ENV to switch environments:
# - "local" for PHP dev server (php -S localhost:8000)
# - "apache_local" for local Apache production testing
# - "production" for AWS production server

APP_ENV=local
```

**This is the FULL LOCAL .env file content!**

It means:
1. The `--exclude .env` is NOT working in rsync
2. OR some other process is syncing it
3. OR the local .env file WAS synced before exclusion was added

---

## RECOMMENDED ACTIONS:

### 1. DELETE Legacy Deploy Script
```bash
rm scripts/deploy-to-aws.sh
git add scripts/deploy-to-aws.sh
git commit -m "Remove legacy deployment script"
```

### 2. Fix Production .env (PERMANENTLY)
```bash
ssh ... '
  # Change permissions to allow write
  chmod 640 /var/websites/webaim/htdocs/training/online/accessilist/.env

  # Write minimal production config
  cat > /var/websites/webaim/htdocs/training/online/accessilist/.env << EOF
APP_ENV=production
BASE_PATH_PRODUCTION=/training/online/accessilist
API_EXT_PRODUCTION=
DEBUG_PRODUCTION=false
EOF

  # Lock it as read-only
  chmod 440 /var/websites/webaim/htdocs/training/online/accessilist/.env

  # Verify
  cat /var/websites/webaim/htdocs/training/online/accessilist/.env
'
```

### 3. Test rsync Exclusion
```bash
# Add test marker to production
ssh ... "echo '# TEST MARKER' >> /var/.../accessilist/.env"

# Deploy
./github-push-gate.sh secure-push 'push to github'

# Check if marker survived
ssh ... "grep 'TEST MARKER' /var/.../accessilist/.env"
# If found: exclusion works ✅
# If not found: exclusion FAILED ❌
```

### 4. Remove Scripts That Modify .env
- Line 136 in `scripts/verify-mcp-autonomous.sh` - remove append
- Lines 11-12 in `scripts/autonomous-mode.sh` - remove append

---

## HYPOTHESIS CONFIRMED:

The production .env contains the EXACT content from local .env, including all comments. This proves .env WAS synced at some point, overwriting the production-specific values.

**ROOT CAUSE**: Multiple deployment workflows exist that DO NOT exclude .env:

1. ✅ **github-push-gate.sh** - Correctly excludes .env
2. ❌ **scripts/deploy-to-aws.sh** - Legacy script (should be deleted)
3. ❌ **deploy.sh** - Does NOT exclude .env
4. ❌ **.github/workflows/deploy-simple.yml** - ACTIVE workflow that deploys .env
5. ❌ **.github/workflows/deploy.yml** - Disabled but dangerous

**The GitHub Actions workflow (deploy-simple.yml) is likely the culprit** - it runs on every push to main and WILL deploy the local .env file, overwriting production settings.

---

## FINAL RECOMMENDED ACTIONS:

### 1. FIX GitHub Workflows (CRITICAL)
```bash
# Add --exclude .env to .github/workflows/deploy-simple.yml line 35
# Add --exclude .env to .github/workflows/deploy.yml line 98
# Add --exclude saves/ to both workflows
```

### 2. DELETE or FIX Legacy Scripts
```bash
rm scripts/deploy-to-aws.sh
# OR add --exclude .env to deploy.sh line 40
```

### 3. Fix Production .env (ONE TIME)
```bash
ssh ... 'chmod 640 /var/websites/webaim/htdocs/training/online/accessilist/.env && \
  cat > /var/websites/webaim/htdocs/training/online/accessilist/.env << EOF
APP_ENV=production
BASE_PATH_PRODUCTION=/training/online/accessilist
API_EXT_PRODUCTION=
DEBUG_PRODUCTION=false
EOF
  chmod 440 /var/websites/webaim/htdocs/training/online/accessilist/.env'
```

### 4. Remove Scripts That Append to .env
```bash
# Remove line 136 from scripts/verify-mcp-autonomous.sh
# Remove lines 11-12 from scripts/autonomous-mode.sh
```

### 5. Use ONLY github-push-gate.sh for deployment
```bash
./github-push-gate.sh secure-push 'push to github'
```

