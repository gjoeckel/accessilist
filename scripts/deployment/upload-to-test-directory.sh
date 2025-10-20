#!/bin/bash
# ============================================================================
# Deploy to Test Directory (accessilist2)
# ============================================================================
# Purpose: Deploy to production test folder for validation before live deployment
# Usage: ./scripts/deployment/upload-to-test-directory.sh
# ============================================================================

set -e

# ============================================================================
# TEST DIRECTORY CONFIGURATION
# ============================================================================
export DEPLOY_USER="${DEPLOY_USER:-george}"
export DEPLOY_HOST="${DEPLOY_HOST:-ec2-3-20-59-76.us-east-2.compute.amazonaws.com}"
export DEPLOY_PATH="/var/websites/webaim/htdocs/training/online/accessilist2/"
export SSH_KEY="${SSH_KEY:-$HOME/.ssh/GeorgeWebAIMServerKey.pem}"

# ============================================================================
# COLORS
# ============================================================================
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Deploy to TEST Directory (accessilist2)              ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${YELLOW}⚠️  DEPLOYING TO TEST DIRECTORY:${NC}"
echo -e "${YELLOW}   Path: $DEPLOY_PATH${NC}"
echo -e "${YELLOW}   This is NOT the live production directory${NC}"
echo ""

# ============================================================================
# RUN STANDARD DEPLOYMENT SCRIPT WITH TEST PATH
# ============================================================================
echo -e "${BLUE}📦 Running deployment with test directory path...${NC}"
echo ""

# Call the main deployment script with test path
./scripts/deployment/upload-production-files.sh

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  ✅ Test Deployment Complete!                         ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# ============================================================================
# POST-DEPLOYMENT INSTRUCTIONS
# ============================================================================
echo -e "${YELLOW}⚠️  IMPORTANT: Configure .env for accessilist2${NC}"
echo ""
echo "Create test .env file on server:"
echo -e "${BLUE}  ssh -i $SSH_KEY ${DEPLOY_USER}@${DEPLOY_HOST}${NC}"
echo ""
echo "Then run:"
echo -e "${BLUE}  cat > /var/websites/webaim/htdocs/training/online/etc/.env.accessilist2 << 'EOF'
APP_ENV=production

# Test directory paths (accessilist2)
BASE_PATH_PRODUCTION=/training/online/accessilist2
API_EXT_PRODUCTION=
DEBUG_PRODUCTION=false

# Local development paths (reference)
BASE_PATH_LOCAL=
API_EXT_LOCAL=.php
DEBUG_LOCAL=true
EOF${NC}"
echo ""

echo "Update config.php to check test .env location:"
echo -e "${BLUE}  # Add to config.php .env search locations:
  \$testEnvPath = '/var/websites/webaim/htdocs/training/online/etc/.env.accessilist2';
  if (file_exists(\$testEnvPath)) {
      \$envLoaded = loadEnv(\$testEnvPath);
  }${NC}"
echo ""

echo -e "${GREEN}📊 Test URL:${NC}"
echo -e "${GREEN}  https://webaim.org/training/online/accessilist2/home${NC}"
echo ""

echo -e "${YELLOW}💡 After testing successfully, deploy to live:${NC}"
echo -e "${YELLOW}  ./scripts/deployment/upload-production-files.sh${NC}"
echo ""
