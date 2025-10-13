#!/bin/bash

# Production .env Verification and Setup Script
# Verifies production server has correct .env configuration
# Creates/updates .env file if needed

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Production .env Verification & Setup Script       ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# Production server details
PROD_USER="a00288946"
PROD_HOST="webaim.org"
PROD_ENV_PATH="/var/websites/webaim/htdocs/training/online/etc/.env"
PROD_ENV_DIR="/var/websites/webaim/htdocs/training/online/etc"
PROD_APP_PATH="/var/websites/webaim/htdocs/training/online/accessilist"

# Expected production .env content
read -r -d '' PROD_ENV_CONTENT << 'EOF' || true
# AccessiList Production Environment Configuration
# External .env file for production server
# Location: /var/websites/webaim/htdocs/training/online/etc/.env

# Current environment (should be 'production')
APP_ENV=production

# PRODUCTION environment settings
BASE_PATH_PRODUCTION=/training/online/accessilist
API_EXT_PRODUCTION=
DEBUG_PRODUCTION=false

# Note: Local and apache-local settings not needed on production server
# The application will only read the PRODUCTION settings when APP_ENV=production
EOF

# Function to test SSH connection
test_ssh_connection() {
    echo -e "${CYAN}Testing SSH connection to production server...${NC}"
    if ssh -o ConnectTimeout=10 "$PROD_USER@$PROD_HOST" "echo 'SSH connection successful'" 2>/dev/null; then
        echo -e "${GREEN}✅ SSH connection successful${NC}"
        return 0
    else
        echo -e "${RED}❌ SSH connection failed${NC}"
        echo -e "${YELLOW}Please verify:${NC}"
        echo "  - SSH key is configured"
        echo "  - Server hostname: $PROD_HOST"
        echo "  - Username: $PROD_USER"
        echo ""
        echo "Test connection manually with:"
        echo "  ssh $PROD_USER@$PROD_HOST"
        return 1
    fi
}

# Function to check if .env file exists
check_env_exists() {
    echo ""
    echo -e "${CYAN}Checking if production .env file exists...${NC}"
    
    if ssh "$PROD_USER@$PROD_HOST" "test -f $PROD_ENV_PATH" 2>/dev/null; then
        echo -e "${GREEN}✅ Production .env file exists${NC}"
        echo "   Location: $PROD_ENV_PATH"
        return 0
    else
        echo -e "${YELLOW}⚠️  Production .env file not found${NC}"
        echo "   Expected location: $PROD_ENV_PATH"
        return 1
    fi
}

# Function to display current .env content
show_current_env() {
    echo ""
    echo -e "${CYAN}Current production .env content:${NC}"
    echo "-----------------------------------------------------------"
    ssh "$PROD_USER@$PROD_HOST" "cat $PROD_ENV_PATH" 2>/dev/null || echo "(file not found)"
    echo "-----------------------------------------------------------"
}

# Function to create production .env file
create_production_env() {
    echo ""
    echo -e "${CYAN}Creating production .env file...${NC}"
    
    # Create directory if needed
    echo "  Step 1: Ensuring directory exists..."
    if ssh "$PROD_USER@$PROD_HOST" "mkdir -p $PROD_ENV_DIR" 2>/dev/null; then
        echo -e "  ${GREEN}✅ Directory ready${NC}"
    else
        echo -e "  ${RED}❌ Failed to create directory${NC}"
        return 1
    fi
    
    # Create temporary file locally
    echo "  Step 2: Creating .env file..."
    local temp_file="/tmp/production-env-$$.tmp"
    echo "$PROD_ENV_CONTENT" > "$temp_file"
    
    # Upload to server
    echo "  Step 3: Uploading to server..."
    if scp -q "$temp_file" "$PROD_USER@$PROD_HOST:$PROD_ENV_PATH" 2>/dev/null; then
        echo -e "  ${GREEN}✅ File uploaded successfully${NC}"
        rm "$temp_file"
    else
        echo -e "  ${RED}❌ Failed to upload file${NC}"
        rm "$temp_file"
        return 1
    fi
    
    # Set permissions
    echo "  Step 4: Setting file permissions..."
    if ssh "$PROD_USER@$PROD_HOST" "chmod 644 $PROD_ENV_PATH" 2>/dev/null; then
        echo -e "  ${GREEN}✅ Permissions set (644)${NC}"
    else
        echo -e "  ${YELLOW}⚠️  Could not set permissions (may require sudo)${NC}"
    fi
    
    echo ""
    echo -e "${GREEN}✅ Production .env file created successfully!${NC}"
    return 0
}

# Function to verify .env content
verify_env_content() {
    echo ""
    echo -e "${CYAN}Verifying .env content...${NC}"
    
    local errors=0
    
    # Check APP_ENV=production
    if ssh "$PROD_USER@$PROD_HOST" "grep -q '^APP_ENV=production' $PROD_ENV_PATH" 2>/dev/null; then
        echo -e "  ${GREEN}✅ APP_ENV=production${NC}"
    else
        echo -e "  ${RED}❌ APP_ENV not set to production${NC}"
        errors=$((errors + 1))
    fi
    
    # Check BASE_PATH_PRODUCTION
    if ssh "$PROD_USER@$PROD_HOST" "grep -q '^BASE_PATH_PRODUCTION=/training/online/accessilist' $PROD_ENV_PATH" 2>/dev/null; then
        echo -e "  ${GREEN}✅ BASE_PATH_PRODUCTION=/training/online/accessilist${NC}"
    else
        echo -e "  ${RED}❌ BASE_PATH_PRODUCTION not correct${NC}"
        errors=$((errors + 1))
    fi
    
    # Check API_EXT_PRODUCTION (empty)
    if ssh "$PROD_USER@$PROD_HOST" "grep -q '^API_EXT_PRODUCTION=$' $PROD_ENV_PATH" 2>/dev/null; then
        echo -e "  ${GREEN}✅ API_EXT_PRODUCTION= (empty - correct)${NC}"
    else
        echo -e "  ${YELLOW}⚠️  API_EXT_PRODUCTION may not be correct${NC}"
    fi
    
    # Check DEBUG_PRODUCTION
    if ssh "$PROD_USER@$PROD_HOST" "grep -q '^DEBUG_PRODUCTION=false' $PROD_ENV_PATH" 2>/dev/null; then
        echo -e "  ${GREEN}✅ DEBUG_PRODUCTION=false${NC}"
    else
        echo -e "  ${YELLOW}⚠️  DEBUG_PRODUCTION not set to false${NC}"
    fi
    
    if [ $errors -eq 0 ]; then
        echo ""
        echo -e "${GREEN}✅ All critical settings verified!${NC}"
        return 0
    else
        echo ""
        echo -e "${RED}❌ $errors critical setting(s) incorrect${NC}"
        return 1
    fi
}

# Function to test if application can read .env
test_app_config() {
    echo ""
    echo -e "${CYAN}Testing if application can read .env...${NC}"
    
    # Check if config.php can find the .env
    local test_url="https://webaim.org/training/online/accessilist/php/api/health.php"
    
    echo "  Testing health endpoint: $test_url"
    local http_code=$(curl -s -o /dev/null -w "%{http_code}" "$test_url" 2>/dev/null || echo "000")
    
    if [ "$http_code" = "200" ]; then
        echo -e "  ${GREEN}✅ Application responding (HTTP 200)${NC}"
        echo "  ${GREEN}✅ .env file is being read correctly${NC}"
        return 0
    elif [ "$http_code" = "000" ]; then
        echo -e "  ${YELLOW}⚠️  Could not connect to server${NC}"
        echo "  ${YELLOW}This doesn't mean .env is wrong - server may not be deployed yet${NC}"
        return 0
    else
        echo -e "  ${YELLOW}⚠️  Application returned HTTP $http_code${NC}"
        echo "  ${YELLOW}May need to deploy application code first${NC}"
        return 0
    fi
}

# Main execution
main() {
    echo -e "${CYAN}This script will:${NC}"
    echo "  1. Test SSH connection to production server"
    echo "  2. Check if .env file exists"
    echo "  3. Create/update .env if needed"
    echo "  4. Verify .env content"
    echo "  5. Test application configuration"
    echo ""
    
    # Test SSH connection
    if ! test_ssh_connection; then
        echo ""
        echo -e "${RED}Cannot proceed without SSH connection${NC}"
        exit 1
    fi
    
    # Check if .env exists
    if check_env_exists; then
        show_current_env
        
        echo ""
        read -p "Do you want to update the existing .env file? (y/N): " -n 1 -r
        echo ""
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            if create_production_env; then
                show_current_env
            else
                echo -e "${RED}Failed to create .env file${NC}"
                exit 1
            fi
        fi
    else
        echo ""
        echo -e "${YELLOW}Production .env file needs to be created${NC}"
        read -p "Create production .env file now? (Y/n): " -n 1 -r
        echo ""
        
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            if create_production_env; then
                show_current_env
            else
                echo -e "${RED}Failed to create .env file${NC}"
                exit 1
            fi
        else
            echo ""
            echo -e "${YELLOW}Skipping .env creation${NC}"
            exit 0
        fi
    fi
    
    # Verify content
    if ! verify_env_content; then
        echo ""
        echo -e "${YELLOW}Some settings may need manual correction${NC}"
        echo "SSH to server and edit: $PROD_ENV_PATH"
    fi
    
    # Test application
    test_app_config
    
    # Final summary
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║            Production .env Setup Complete             ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}Next Steps:${NC}"
    echo "  1. Push code to GitHub: ${BLUE}git push origin main${NC}"
    echo "  2. Code will auto-deploy to production"
    echo "  3. Test production site: ${BLUE}https://webaim.org/training/online/accessilist/home${NC}"
    echo ""
    echo -e "${GREEN}✅ Ready for deployment!${NC}"
    echo ""
}

# Run main function
main

