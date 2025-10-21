#!/bin/bash
################################################################################
# Compare Local Files with Remote Deployment
################################################################################
#
# PURPOSE: Compare local working directory with accessilist2 (test) on server
# METHOD: Uses rsync --dry-run to show differences
# SCOPE: Only compares the 89 production files (from deployment whitelist)
#
# USAGE:
#   ./compare-with-remote.sh [staging|live] [--detailed]
#
# ARGUMENTS:
#   staging (default) - Compare with accessilist2 (test environment)
#   live             - Compare with accessilist (live production)
#   --detailed       - Show detailed file diffs for changed files
#
# OUTPUT:
#   - List of files that would be created/updated/deleted
#   - Summary of changes by category
#   - Optional: Detailed diffs of changed files
#
################################################################################

set -e

# ============================================================================
# CONFIGURATION
# ============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Parse arguments
ENVIRONMENT="${1:-staging}"
DETAILED=false
if [[ "$2" == "--detailed" ]] || [[ "$1" == "--detailed" ]]; then
    DETAILED=true
fi

# Set remote path based on environment
if [ "$ENVIRONMENT" = "live" ]; then
    REMOTE_PATH="/var/websites/webaim/htdocs/training/online/accessilist/"
    ENV_LABEL="⚠️  LIVE PRODUCTION"
elif [ "$ENVIRONMENT" = "staging" ]; then
    REMOTE_PATH="/var/websites/webaim/htdocs/training/online/accessilist2/"
    ENV_LABEL="🧪 STAGING (accessilist2)"
else
    echo "❌ Invalid environment: $ENVIRONMENT"
    echo "Usage: $0 [staging|live] [--detailed]"
    exit 1
fi

DEPLOY_USER="${DEPLOY_USER:-george}"
DEPLOY_HOST="${DEPLOY_HOST:-ec2-3-20-59-76.us-east-2.compute.amazonaws.com}"
DEPLOY_TARGET="${DEPLOY_USER}@${DEPLOY_HOST}"
SSH_KEY="${SSH_KEY:-$HOME/.ssh/GeorgeWebAIMServerKey.pem}"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

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
# BANNER
# ============================================================================
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Compare Local Files with Remote Deployment          ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}$ENV_LABEL${NC}"
echo -e "${CYAN}Local:${NC} $PROJECT_DIR"
echo -e "${CYAN}Remote:${NC} ${DEPLOY_TARGET}:${REMOTE_PATH}"
echo -e "${CYAN}Files:${NC} 89 production files (deployment whitelist)"
echo ""

# ============================================================================
# PRE-FLIGHT CHECKS
# ============================================================================
log_info "Running pre-flight checks..."

# Check SSH key
if [ ! -f "$SSH_KEY" ]; then
    log_error "SSH key not found: $SSH_KEY"
    exit 1
fi

# Check if we're in project root
if [ ! -f "index.php" ] || [ ! -f ".htaccess" ]; then
    log_error "Must run from project root directory"
    exit 1
fi

log_success "Pre-flight checks passed"
echo ""

# ============================================================================
# CREATE FILE LIST (Same as upload-production-files.sh)
# ============================================================================
log_info "Creating production file list (89 files)..."

TEMP_FILE_LIST=$(mktemp)
trap "rm -f $TEMP_FILE_LIST" EXIT

cat > "$TEMP_FILE_LIST" << 'EOF'
index.php
.htaccess
config/checklist-types.json
php/index.php
php/home.php
php/list.php
php/list-report.php
php/systemwide-report.php
php/aeit.php
php/api/save.php
php/api/restore.php
php/api/list.php
php/api/list-detailed.php
php/api/delete.php
php/api/instantiate.php
php/api/generate-key.php
php/api/health.php
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
php/includes/origin-check.php
php/includes/csrf-stateless.php
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
EOF

log_success "File list created (89 files)"
echo ""

# ============================================================================
# RUN RSYNC DRY-RUN COMPARISON
# ============================================================================
log_info "Comparing local files with remote..."
echo ""

# Create temporary file for rsync output
RSYNC_OUTPUT=$(mktemp)
trap "rm -f $TEMP_FILE_LIST $RSYNC_OUTPUT" EXIT

# Run rsync in dry-run mode with itemize-changes
rsync -avzn \
    --files-from="$TEMP_FILE_LIST" \
    --itemize-changes \
    -e "ssh -i $SSH_KEY -o StrictHostKeyChecking=no" \
    "$PROJECT_DIR/" "${DEPLOY_TARGET}:${REMOTE_PATH}" \
    2>&1 | tee "$RSYNC_OUTPUT"

# ============================================================================
# PARSE RSYNC OUTPUT
# ============================================================================
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Summary of Changes${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Count different types of changes
NEW_FILES=$(grep -c "^>f+++++++++" "$RSYNC_OUTPUT" || true)
UPDATED_FILES=$(grep -c "^>f\.st\.\.\.\.\.\." "$RSYNC_OUTPUT" || true)
UNCHANGED_FILES=$(grep -c "^>f\.\.\.\.\.\.\.\.\." "$RSYNC_OUTPUT" || true)

# Try alternate patterns for updated files (size or timestamp changed)
if [ "$UPDATED_FILES" -eq 0 ]; then
    UPDATED_FILES=$(grep -E "^>f" "$RSYNC_OUTPUT" | grep -v "^>f+++++++++" | grep -v "^>f\.\.\.\.\.\.\.\.\." | wc -l | tr -d ' ')
fi

echo -e "${GREEN}Unchanged Files:${NC} $UNCHANGED_FILES"
echo -e "${YELLOW}Updated Files:${NC}   $UPDATED_FILES"
echo -e "${CYAN}New Files:${NC}       $NEW_FILES"
echo ""

# ============================================================================
# LIST CHANGED FILES
# ============================================================================
if [ "$UPDATED_FILES" -gt 0 ] || [ "$NEW_FILES" -gt 0 ]; then
    echo -e "${YELLOW}Files that will be updated/created:${NC}"
    echo ""

    grep -E "^>f\+" "$RSYNC_OUTPUT" | awk '{print "  " $2}' || true
    grep -E "^>f\.st" "$RSYNC_OUTPUT" | awk '{print "  " $2}' || true
    grep -E "^>f" "$RSYNC_OUTPUT" | grep -v "^>f\.\.\.\.\.\.\.\.\." | awk '{print "  " $2}' || true

    echo ""
fi

# ============================================================================
# DETAILED DIFF (if requested)
# ============================================================================
if [ "$DETAILED" = true ]; then
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}Detailed File Diffs${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    # Get list of changed files (excluding new files)
    CHANGED_FILES=$(grep -E "^>f\.st|^>fc" "$RSYNC_OUTPUT" | awk '{print $2}' || true)

    if [ -n "$CHANGED_FILES" ]; then
        for file in $CHANGED_FILES; do
            echo -e "${CYAN}╔═══ Diff: $file ═══╗${NC}"

            # Download remote file to temp location
            TEMP_REMOTE=$(mktemp)
            trap "rm -f $TEMP_FILE_LIST $RSYNC_OUTPUT $TEMP_REMOTE" EXIT

            scp -i "$SSH_KEY" -q "${DEPLOY_TARGET}:${REMOTE_PATH}${file}" "$TEMP_REMOTE" 2>/dev/null || {
                echo -e "${YELLOW}  Remote file doesn't exist (new file)${NC}"
                echo ""
                continue
            }

            # Show diff
            diff -u "$TEMP_REMOTE" "$PROJECT_DIR/$file" || true
            echo ""

            rm -f "$TEMP_REMOTE"
        done
    else
        log_info "No modified files to diff (only new files or unchanged)"
    fi
fi

# ============================================================================
# SUMMARY
# ============================================================================
echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║              Comparison Summary                        ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}Environment:${NC} $ENVIRONMENT ($REMOTE_PATH)"
echo -e "${CYAN}Total Files:${NC} 89 (deployment whitelist)"
echo -e "${GREEN}Unchanged:${NC}   $UNCHANGED_FILES"
echo -e "${YELLOW}Updated:${NC}     $UPDATED_FILES"
echo -e "${CYAN}New:${NC}         $NEW_FILES"
echo ""

if [ "$UPDATED_FILES" -eq 0 ] && [ "$NEW_FILES" -eq 0 ]; then
    log_success "No changes detected - local and remote are in sync!"
else
    log_warning "$(($UPDATED_FILES + $NEW_FILES)) files will be changed on deployment"
    echo ""
    log_info "To deploy these changes:"
    if [ "$ENVIRONMENT" = "staging" ]; then
        echo "  ./scripts/deployment/upload-to-test-directory.sh"
    else
        echo "  ./scripts/deployment/upload-production-files.sh"
    fi
fi

echo ""
log_info "For detailed diffs, run: $0 $ENVIRONMENT --detailed"
echo ""

# ============================================================================
# END OF SCRIPT
# ============================================================================
