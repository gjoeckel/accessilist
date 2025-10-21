#!/bin/bash
# ============================================================================
# Upload Production Files - Explicit Include List (Method 2)
# ============================================================================
# Purpose: Upload ONLY the 89 required production files to server
# Method: Explicit file list (safest - no accidental uploads)
# Reference: DEVELOPER/CORE2.md (Production Deployment Manifest)
# ============================================================================

set -e  # Exit on error

# ============================================================================
# CONFIGURATION
# ============================================================================
DEPLOY_USER="${DEPLOY_USER:-george}"
DEPLOY_HOST="${DEPLOY_HOST:-ec2-3-20-59-76.us-east-2.compute.amazonaws.com}"
DEPLOY_PATH="${DEPLOY_PATH:-/var/websites/webaim/htdocs/training/online/accessilist/}"
DEPLOY_TARGET="${DEPLOY_USER}@${DEPLOY_HOST}"

# SSH key location
SSH_KEY="${SSH_KEY:-$HOME/.ssh/GeorgeWebAIMServerKey.pem}"

# ============================================================================
# COLORS
# ============================================================================
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# ============================================================================
# PRE-FLIGHT CHECKS
# ============================================================================
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Production File Upload (Explicit Include Method)     ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

log_info "Target: ${DEPLOY_TARGET}:${DEPLOY_PATH}"
log_info "Method: Explicit file list (89 files)"
log_info "Source: DEVELOPER/CORE2.md manifest"

# Check SSH key
if [ ! -f "$SSH_KEY" ]; then
    log_error "SSH key not found: $SSH_KEY"
    exit 1
fi
log_success "SSH key found: $SSH_KEY"

# Check if we're in project root
if [ ! -f "index.php" ] || [ ! -f ".htaccess" ]; then
    log_error "Must run from project root directory"
    exit 1
fi
log_success "Running from project root"

# ============================================================================
# CREATE TEMPORARY FILE LIST
# ============================================================================
log_info "Creating production file list..."

TEMP_FILE_LIST=$(mktemp)
trap "rm -f $TEMP_FILE_LIST" EXIT

cat > "$TEMP_FILE_LIST" << 'EOF'
# ============================================================================
# PRODUCTION FILES - EXPLICIT INCLUDE LIST (89 files)
# ============================================================================
# Reference: DEVELOPER/CORE2.md
# Last Updated: 2025-10-20
# ============================================================================

# ----------------------------------------------------------------------------
# ROOT LEVEL (2 files)
# ----------------------------------------------------------------------------
index.php
.htaccess

# ----------------------------------------------------------------------------
# CONFIGURATION (1 file)
# ----------------------------------------------------------------------------
config/checklist-types.json

# ----------------------------------------------------------------------------
# PHP BACKEND - Pages (6 files)
# ----------------------------------------------------------------------------
php/index.php
php/home.php
php/list.php
php/list-report.php
php/systemwide-report.php
php/aeit.php

# ----------------------------------------------------------------------------
# PHP BACKEND - API Endpoints (8 files)
# ----------------------------------------------------------------------------
php/api/save.php
php/api/restore.php
php/api/list.php
php/api/list-detailed.php
php/api/delete.php
php/api/instantiate.php
php/api/generate-key.php
php/api/health.php

# ----------------------------------------------------------------------------
# PHP BACKEND - Includes (9 files)
# ----------------------------------------------------------------------------
php/includes/config.php
php/includes/api-utils.php
php/includes/csrf.php
php/includes/html-head.php
php/includes/footer.php
php/includes/noscript.php
php/includes/common-scripts.php
php/includes/rate-limiter.php
php/includes/security-headers.php
php/includes/session-utils.php
php/includes/type-manager.php
php/includes/type-formatter.php

# ----------------------------------------------------------------------------
# JAVASCRIPT MODULES (20 files)
# ----------------------------------------------------------------------------
js/main.js
js/StateManager.js
js/StateEvents.js
js/StatusManager.js
js/buildCheckpoints.js
js/buildDemo.js
js/addRow.js
js/csrf-utils.js
js/simple-modal.js
js/ModalActions.js
js/side-panel.js
js/scroll.js
js/path-utils.js
js/simple-path-config.js
js/type-manager.js
js/date-utils.js
js/list-report.js
js/systemwide-report.js
js/ui-components.js
js/debug-utils.js
js/postcss.config.js

# ----------------------------------------------------------------------------
# STYLESHEETS (16 files)
# ----------------------------------------------------------------------------
css/base.css
css/header.css
css/footer.css
css/landing.css
css/list.css
css/list-report.css
css/reports.css
css/systemwide-report.css
css/simple-modal.css
css/form-elements.css
css/table.css
css/scroll.css
css/focus.css
css/loading.css
css/demo-inline-icons.css
css/aeit.css

# ----------------------------------------------------------------------------
# IMAGES - SVG Icons (15 files)
# ----------------------------------------------------------------------------
images/active-1.svg
images/done.svg
images/done-1.svg
images/ready-1.svg
images/add-plus.svg
images/delete.svg
images/reset.svg
images/info-.svg
images/show-all.svg
images/show-all-1.svg
images/show-all-2.svg
images/show-one.svg
images/show-one-1.svg
images/show-one-2.svg
images/cc-icons.svg

# ----------------------------------------------------------------------------
# JSON CHECKLIST DATA (11 files)
# ----------------------------------------------------------------------------
json/demo.json
json/word.json
json/powerpoint.json
json/excel.json
json/docs.json
json/slides.json
json/camtasia.json
json/dojo.json
json/test-5.json
json/test-7.json
json/test-10-checkpoints.json

# ----------------------------------------------------------------------------
# DATA DIRECTORIES
# ----------------------------------------------------------------------------
# NOTE: sessions/.htaccess removed - sessions now stored in etc/sessions (outside web root)
# No .htaccess needed for etc/ directory (already inaccessible via HTTP)

# ============================================================================
# END OF FILE LIST - Total: 89 files
# ============================================================================
EOF

# Count files (exclude comments and blank lines)
FILE_COUNT=$(grep -v '^#' "$TEMP_FILE_LIST" | grep -v '^$' | wc -l | tr -d ' ')
log_success "File list created: $FILE_COUNT files"

# ============================================================================
# VERIFY FILES EXIST LOCALLY
# ============================================================================
log_info "Verifying files exist locally..."

MISSING_FILES=0
while IFS= read -r file; do
    # Skip comments and empty lines
    [[ "$file" =~ ^#.*$ ]] && continue
    [[ -z "$file" ]] && continue

    if [ ! -f "$file" ]; then
        log_warning "Missing file: $file"
        MISSING_FILES=$((MISSING_FILES + 1))
    fi
done < "$TEMP_FILE_LIST"

if [ $MISSING_FILES -gt 0 ]; then
    log_error "Found $MISSING_FILES missing files - deployment aborted"
    exit 1
fi
log_success "All files verified locally"

# ============================================================================
# RSYNC DEPLOYMENT
# ============================================================================
log_info "Starting rsync upload..."
echo ""

# Clean file list (remove comments and blank lines)
CLEAN_FILE_LIST=$(mktemp)
trap "rm -f $TEMP_FILE_LIST $CLEAN_FILE_LIST" EXIT
grep -v '^#' "$TEMP_FILE_LIST" | grep -v '^$' > "$CLEAN_FILE_LIST"

# Rsync with explicit file list
rsync -avz \
    --files-from="$CLEAN_FILE_LIST" \
    -e "ssh -i $SSH_KEY -o StrictHostKeyChecking=no" \
    --progress \
    --itemize-changes \
    ./ "${DEPLOY_TARGET}:${DEPLOY_PATH}"

RSYNC_EXIT_CODE=$?

echo ""
if [ $RSYNC_EXIT_CODE -eq 0 ]; then
    log_success "Upload complete!"
    log_info "Uploaded $FILE_COUNT files to production"
else
    log_error "Upload failed with exit code: $RSYNC_EXIT_CODE"
    exit 1
fi

# ============================================================================
# POST-DEPLOYMENT TASKS
# ============================================================================
log_info "Running post-deployment tasks..."

# Ensure sessions directory exists in etc/ (outside web root for security)
# Location: /var/websites/webaim/htdocs/training/online/etc/sessions
# Use 775: Owner + Group can write, Others read-only (secure)
# Apache runs as www-data (group member) so group write access is sufficient
ssh -i "$SSH_KEY" "${DEPLOY_TARGET}" "mkdir -p /var/websites/webaim/htdocs/training/online/etc/sessions && chmod 775 /var/websites/webaim/htdocs/training/online/etc/sessions"
log_success "Sessions directory verified in etc/ (outside web root - permissions: 775)"

# ============================================================================
# DEPLOYMENT SUMMARY
# ============================================================================
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  ✅ Production Deployment Complete                    ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
log_info "Files uploaded: $FILE_COUNT"
log_info "Target: ${DEPLOY_TARGET}:${DEPLOY_PATH}"
log_info "Method: Explicit include list (safest)"
echo ""
log_warning "Next steps:"
echo "  1. Verify .env file exists at: /var/websites/webaim/htdocs/training/online/etc/.env"
echo "  2. Test application: https://webaim.org/training/online/accessilist/home"
echo "  3. Run post-deployment verification: ./scripts/deployment/post-deploy-verify.sh"
echo ""

# ============================================================================
# END OF SCRIPT
# ============================================================================
