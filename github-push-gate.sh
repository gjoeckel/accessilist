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

# Function to execute git push with security gate
secure_git_push() {
    local push_token="$1"
    shift
    local git_args="$@"

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

    # Token is valid, prepare for production deployment
    echo -e "${BLUE}📋 Preparing for production deployment...${NC}"

    # Note: .env stays as "local" in git - production .env created on server

    # Step 2: Push to GitHub
    echo -e "${GREEN}🚀 Pushing to GitHub repository...${NC}"

    # Set upstream if not configured
    local current_branch=$(git branch --show-current)
    if ! git rev-parse --abbrev-ref --symbolic-full-name @{u} >/dev/null 2>&1; then
        echo -e "${BLUE}Setting upstream for branch $current_branch...${NC}"
        if ! git push --set-upstream origin "$current_branch" $git_args; then
            echo -e "${RED}❌ Push failed${NC}"
            return 1
        fi
    else
        if ! git push $git_args; then
            echo -e "${RED}❌ Push failed${NC}"
            return 1
        fi
    fi

    # Step 3: Deploy to AWS production
    echo -e "${BLUE}🚀 Deploying to AWS production...${NC}"

    # AWS deployment configuration
    local PEM_FILE="/Users/a00288946/Developer/projects/GeorgeWebAIMServerKey.pem"
    local SERVER="george@ec2-3-20-59-76.us-east-2.compute.amazonaws.com"
    local REMOTE_PATH="/var/websites/webaim/htdocs/training/online/accessilist"
    local LOCAL_PATH="$(pwd)"

    # Deploy files to AWS (exclude .env - will be created separately)
    rsync -avz --progress \
      --exclude .git/ \
      --exclude .gitignore \
      --exclude .cursor/ \
      --exclude node_modules/ \
      --exclude .DS_Store \
      --exclude .env \
      --exclude .env.local \
      --exclude .env.backup \
      --exclude '*.backup' \
      --exclude '*.bak' \
      -e "ssh -i $PEM_FILE" \
      "$LOCAL_PATH/" \
      "$SERVER:$REMOTE_PATH/"

    rsync_exit=$?
    # Exit code 0 = success, 23 = partial transfer (some files vanished, but OK)
    if [ $rsync_exit -eq 0 ] || [ $rsync_exit -eq 23 ]; then
        echo -e "${GREEN}✅ Deployment successful!${NC}"

        # Create production .env on server
        echo -e "${BLUE}Creating production .env configuration...${NC}"

        # Create .env directly on server with production settings
        ssh -i "$PEM_FILE" "$SERVER" "cat > $REMOTE_PATH/.env << 'ENVEOF'
# Environment Configuration
# Change APP_ENV to switch environments:
# - \"local\" for PHP dev server (php -S localhost:8000)
# - \"apache_local\" for local Apache production testing
# - \"production\" for AWS production server

APP_ENV=production

# Base paths for each environment
BASE_PATH_LOCAL=
BASE_PATH_APACHE_LOCAL=/training/online/accessilist
BASE_PATH_PRODUCTION=/training/online/accessilist

# API extensions for each environment
API_EXT_LOCAL=.php
API_EXT_APACHE_LOCAL=
API_EXT_PRODUCTION=

# Debug mode for each environment
DEBUG_LOCAL=true
DEBUG_APACHE_LOCAL=true
DEBUG_PRODUCTION=false
ENVEOF
echo '✅ Production .env created' && grep APP_ENV $REMOTE_PATH/.env"

        # Verify deployment
        echo -e "${BLUE}🔍 Verifying deployment...${NC}"
        sleep 2

        if curl -s -o /dev/null -w "%{http_code}" "https://webaim.org/training/online/accessilist/home" | grep -q "200"; then
            echo -e "${GREEN}✅ Production site is responding${NC}"
        else
            echo -e "${YELLOW}⚠️  Production site check returned non-200 status${NC}"
        fi
    else
        echo -e "${RED}❌ Deployment failed${NC}"
    fi

    echo -e "${GREEN}✅ GitHub push and deployment complete!${NC}"
    echo -e "${BLUE}Local .env remains: APP_ENV=local${NC}"
    echo -e "${BLUE}Production .env set to: APP_ENV=production${NC}"
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
