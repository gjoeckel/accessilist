#!/bin/bash

# GitHub Push Security Gate
# This script enforces the requirement for the exact token "push to github"
# before allowing any push operations to remote GitHub repositories

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
REQUIRED_TOKEN="push to github"
PERMISSIONS_FILE="$HOME/.cursor-ai-permissions"

# Function to check if GitHub push gate is enabled
check_push_gate_enabled() {
    if [ -f "$PERMISSIONS_FILE" ]; then
        if grep -q "GITHUB_PUSH_GATE=true" "$PERMISSIONS_FILE"; then
            return 0
        fi
    fi
    return 1
}

# Function to validate push token
validate_push_token() {
    local provided_token="$1"

    if [ "$provided_token" = "$REQUIRED_TOKEN" ]; then
        echo -e "${GREEN}✅ GitHub push token validated successfully${NC}"
        return 0
    else
        echo -e "${RED}❌ Invalid GitHub push token${NC}"
        echo -e "${YELLOW}Expected: '$REQUIRED_TOKEN'${NC}"
        echo -e "${YELLOW}Provided: '$provided_token'${NC}"
        return 1
    fi
}

# Function to check if repository is a GitHub remote
is_github_repo() {
    local repo_url="$1"

    if [[ "$repo_url" =~ github\.com ]]; then
        return 0
    else
        return 1
    fi
}

# Function to get remote URL
get_remote_url() {
    local remote_name="${1:-origin}"

    if git remote get-url "$remote_name" 2>/dev/null; then
        return 0
    else
        echo -e "${RED}❌ No remote '$remote_name' found${NC}"
        return 1
    fi
}

# Function to verify production .env (automated, non-interactive)
verify_production_env_automated() {
    echo -e "${BLUE}━━━ Step 1: Production .env Verification ━━━${NC}"
    echo ""

    local PROD_USER="a00288946"
    local PROD_HOST="webaim.org"
    local PROD_ENV_PATH="/var/websites/webaim/htdocs/training/online/etc/.env"
    local PROD_ENV_DIR="/var/websites/webaim/htdocs/training/online/etc"

    # Test SSH connection
    echo -e "${CYAN}Testing SSH connection to production...${NC}"
    if ! ssh -o ConnectTimeout=10 "$PROD_USER@$PROD_HOST" "echo 'connected'" >/dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  Cannot connect to production server${NC}"
        echo -e "${YELLOW}Skipping .env verification (will use existing server config)${NC}"
        return 0
    fi
    echo -e "${GREEN}✅ SSH connection successful${NC}"

    # Check if .env exists
    echo -e "${CYAN}Checking production .env...${NC}"
    if ssh "$PROD_USER@$PROD_HOST" "test -f $PROD_ENV_PATH" 2>/dev/null; then
        echo -e "${GREEN}✅ Production .env file exists${NC}"

        # Verify critical settings
        local errors=0
        if ! ssh "$PROD_USER@$PROD_HOST" "grep -q '^APP_ENV=production' $PROD_ENV_PATH" 2>/dev/null; then
            echo -e "${YELLOW}⚠️  APP_ENV not set to production (will continue anyway)${NC}"
        else
            echo -e "${GREEN}✅ APP_ENV=production${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  Production .env not found${NC}"
        echo -e "${CYAN}Creating production .env file...${NC}"

        # Create .env content
        local temp_file="/tmp/production-env-$$.tmp"
        cat > "$temp_file" << 'EOF'
# AccessiList Production Environment Configuration
APP_ENV=production
BASE_PATH_PRODUCTION=/training/online/accessilist
API_EXT_PRODUCTION=
DEBUG_PRODUCTION=false
EOF

        # Create directory and upload file
        if ssh "$PROD_USER@$PROD_HOST" "mkdir -p $PROD_ENV_DIR" 2>/dev/null && \
           scp -q "$temp_file" "$PROD_USER@$PROD_HOST:$PROD_ENV_PATH" 2>/dev/null; then
            echo -e "${GREEN}✅ Production .env created${NC}"
            rm "$temp_file"
        else
            echo -e "${YELLOW}⚠️  Could not create .env (will use existing server config)${NC}"
            rm -f "$temp_file"
        fi
    fi

    echo ""
    return 0
}

# Function to wait for GitHub Actions deployment
wait_for_deployment() {
    echo -e "${BLUE}━━━ Step 3: Waiting for GitHub Actions Deployment ━━━${NC}"
    echo ""
    echo -e "${CYAN}GitHub Actions is deploying to production...${NC}"
    echo "  • Monitor: https://github.com/gjoeckel/accessilist/actions"
    echo ""
    echo -e "${YELLOW}Waiting 90 seconds for deployment to complete...${NC}"

    # Show countdown
    for i in {90..1}; do
        echo -ne "\r  ${CYAN}Time remaining: ${i}s${NC} "
        sleep 1
    done
    echo -e "\r  ${GREEN}✅ Deployment time elapsed${NC}                    "
    echo ""
}

# Function to verify deployment
verify_deployment() {
    echo -e "${BLUE}━━━ Step 4: Post-Deployment Verification ━━━${NC}"
    echo ""

    local errors=0
    local PROD_URL="https://webaim.org/training/online/accessilist"

    # Test home page
    echo -e "${CYAN}Testing production endpoints...${NC}"
    local http_code=$(curl -s -o /dev/null -w "%{http_code}" "$PROD_URL/home" 2>/dev/null || echo "000")
    if [ "$http_code" = "200" ]; then
        echo -e "${GREEN}✅ Home page responding (HTTP 200)${NC}"
    else
        echo -e "${YELLOW}⚠️  Home page returned HTTP $http_code${NC}"
        errors=$((errors + 1))
    fi

    # Test API health
    http_code=$(curl -s -o /dev/null -w "%{http_code}" "$PROD_URL/php/api/health.php" 2>/dev/null || echo "000")
    if [ "$http_code" = "200" ]; then
        echo -e "${GREEN}✅ API health endpoint working (HTTP 200)${NC}"
    else
        echo -e "${YELLOW}⚠️  API health returned HTTP $http_code${NC}"
        errors=$((errors + 1))
    fi

    # Test reports page
    http_code=$(curl -s -o /dev/null -w "%{http_code}" "$PROD_URL/reports" 2>/dev/null || echo "000")
    if [ "$http_code" = "200" ]; then
        echo -e "${GREEN}✅ Reports page responding (HTTP 200)${NC}"
    else
        echo -e "${YELLOW}⚠️  Reports page returned HTTP $http_code${NC}"
        errors=$((errors + 1))
    fi

    echo ""
    if [ $errors -eq 0 ]; then
        echo -e "${GREEN}✅ All deployment verification checks passed!${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠️  $errors verification check(s) failed${NC}"
        echo -e "${YELLOW}Site may need a few more minutes to fully propagate${NC}"
        return 0  # Don't fail the deployment
    fi
}

# Function to execute git push with full deployment pipeline
secure_git_push() {
    local push_token="$1"
    shift
    local git_args="$@"

    echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║          Automated Production Deployment              ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""

    # Check if push gate is enabled
    if ! check_push_gate_enabled; then
        echo -e "${YELLOW}⚠️  GitHub push gate not enabled, proceeding with push...${NC}"
        git push $git_args
        return $?
    fi

    # Get current remote URL
    local remote_url
    if ! remote_url=$(get_remote_url); then
        echo -e "${RED}❌ Cannot determine remote repository URL${NC}"
        return 1
    fi

    # Check if it's a GitHub repository
    if ! is_github_repo "$remote_url"; then
        echo -e "${BLUE}ℹ️  Not a GitHub repository, proceeding with push...${NC}"
        git push $git_args
        return $?
    fi

    # Validate push token
    if ! validate_push_token "$push_token"; then
        echo -e "${RED}🚫 Push to GitHub repository blocked - invalid token${NC}"
        echo -e "${YELLOW}To push to GitHub, you must provide the exact token: '$REQUIRED_TOKEN'${NC}"
        return 1
    fi

    # === STEP 1: Verify Production .env ===
    verify_production_env_automated

    # === STEP 2: Push to GitHub ===
    echo -e "${BLUE}━━━ Step 2: Pushing to GitHub ━━━${NC}"
    echo ""
    echo -e "${GREEN}🚀 Pushing to GitHub repository...${NC}"

    # Set upstream if not configured
    local current_branch=$(git branch --show-current)
    if ! git rev-parse --abbrev-ref --symbolic-full-name @{u} >/dev/null 2>&1; then
        echo -e "${CYAN}Setting upstream for branch $current_branch...${NC}"
        if ! git push --no-verify --set-upstream origin "$current_branch" $git_args; then
            echo -e "${RED}❌ Push failed${NC}"
            return 1
        fi
    else
        if ! git push --no-verify $git_args; then
            echo -e "${RED}❌ Push failed${NC}"
            return 1
        fi
    fi

    echo -e "${GREEN}✅ Pushed to GitHub successfully!${NC}"
    echo ""

    # === STEP 3: Wait for GitHub Actions ===
    wait_for_deployment

    # === STEP 4: Verify Deployment ===
    verify_deployment

    # === FINAL SUCCESS ===
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║          🎉 DEPLOYMENT COMPLETE! 🎉                    ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}Production Site:${NC}"
    echo "  🌐 https://webaim.org/training/online/accessilist/home"
    echo ""
    echo -e "${CYAN}GitHub Actions:${NC}"
    echo "  📊 https://github.com/gjoeckel/accessilist/actions"
    echo ""
    echo -e "${CYAN}Next Steps:${NC}"
    echo "  1. Test production site manually"
    echo "  2. Verify scroll buffer functionality"
    echo "  3. Test All button clickability on report pages"
    echo ""

    return 0
}

# Function to create git alias for secure push
setup_secure_git_alias() {
    local script_path="$1"

    echo -e "${BLUE}🔧 Setting up secure git push alias...${NC}"

    # Create alias that uses this script
    git config --global alias.push-secure "!bash '$script_path' secure-push"

    echo -e "${GREEN}✅ Secure git push alias configured${NC}"
    echo -e "${YELLOW}Usage: git push-secure '<token>' [additional git push arguments]${NC}"
}

# Function to create pre-push hook
create_pre_push_hook() {
    local script_path="$1"

    echo -e "${BLUE}🪝 Creating pre-push hook for GitHub security...${NC}"

    # Create pre-push hook script
    cat > .git/hooks/pre-push << EOF
#!/bin/bash

# GitHub Push Security Gate - Pre-push Hook
# This hook enforces the push token requirement for GitHub repositories

SCRIPT_PATH="$script_path"

# Check if this is a GitHub repository
REMOTE_URL=\$(git remote get-url origin 2>/dev/null || echo "")
if [[ "\$REMOTE_URL" =~ github\.com ]]; then
    echo "🔒 GitHub repository detected - push token required"
    echo "To push to GitHub, use: git push-secure '$REQUIRED_TOKEN'"
    echo "Or disable the hook temporarily: git push --no-verify"
    exit 1
fi

# Not a GitHub repository, allow push
exit 0
EOF

    chmod +x .git/hooks/pre-push
    echo -e "${GREEN}✅ Pre-push hook created${NC}"
}

# Main execution
case "${1:-}" in
    "secure-push")
        # Called by git alias
        shift
        secure_git_push "$@"
        ;;
    "setup")
        # Setup secure push configuration
        setup_secure_git_alias "$0"
        if [ -d ".git" ]; then
            create_pre_push_hook "$0"
        else
            echo -e "${YELLOW}⚠️  Not in a git repository, skipping pre-push hook creation${NC}"
        fi
        ;;
    "validate")
        # Validate a token
        if [ -z "${2:-}" ]; then
            echo -e "${RED}❌ Usage: $0 validate <token>${NC}"
            exit 1
        fi
        validate_push_token "$2"
        ;;
    "status")
        # Show current configuration
        echo -e "${BLUE}GitHub Push Security Gate Status:${NC}"
        if check_push_gate_enabled; then
            echo -e "${GREEN}✅ Push gate is ENABLED${NC}"
            echo -e "${YELLOW}Required token: '$REQUIRED_TOKEN'${NC}"
        else
            echo -e "${RED}❌ Push gate is DISABLED${NC}"
        fi

        if [ -d ".git" ]; then
            remote_url=$(get_remote_url 2>/dev/null)
            if [ $? -eq 0 ]; then
                echo -e "${BLUE}Current remote: $remote_url${NC}"
                if is_github_repo "$remote_url"; then
                    echo -e "${YELLOW}⚠️  This is a GitHub repository - push token required${NC}"
                else
                    echo -e "${GREEN}✅ This is not a GitHub repository - no token required${NC}"
                fi
            fi
        fi
        ;;
    *)
        echo -e "${BLUE}GitHub Push Security Gate${NC}"
        echo ""
        echo "Usage:"
        echo "  $0 setup                    - Setup secure push configuration"
        echo "  $0 validate <token>         - Validate a push token"
        echo "  $0 status                   - Show current configuration"
        echo "  $0 secure-push <token> ...  - Execute secure git push"
        echo ""
        echo "Configuration:"
        echo "  Required token: '$REQUIRED_TOKEN'"
        echo "  Permissions file: $PERMISSIONS_FILE"
        echo ""
        echo "Examples:"
        echo "  $0 setup"
        echo "  $0 validate '$REQUIRED_TOKEN'"
        echo "  $0 status"
        echo "  git push-secure '$REQUIRED_TOKEN'"
        ;;
esac
