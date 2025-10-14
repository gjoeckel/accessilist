#!/bin/bash

# AccessiList Deployment Script
# Deploys to production server with proper permissions and health checks

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 AccessiList Deployment Script${NC}"
echo "=================================="

# Configuration
DEPLOY_PATH="/var/websites/webaim/htdocs/training/online/accessilist"
SERVER_USER="user@server"  # Update with actual server details
BASE_URL="https://webaim.org/training/online/accessilist"

# Check if we're in the right directory
if [ ! -f "package.json" ] || [ ! -f "global.css" ]; then
    echo -e "${RED}❌ Error: Must be run from accessilist root directory${NC}"
    echo "Required files: package.json, global.css"
    exit 1
fi

echo -e "${BLUE}📦 Pre-deployment Steps${NC}"

# 1. Build CSS if needed
if [ ! -f "global.css" ] || [ "package.json" -nt "global.css" ]; then
    echo "Building CSS..."
    npm run build:css
    echo -e "${GREEN}✅ CSS built successfully${NC}"
else
    echo -e "${GREEN}✅ CSS is up to date${NC}"
fi

# 2. Create deployment package
echo "Creating deployment package..."
mkdir -p deploy-temp
rsync -av --delete \
  --exclude .git/ \
  --exclude .github/ \
  --exclude .cursor/ \
  --exclude node_modules/ \
  --exclude deploy-temp/ \
  --exclude "*.log" \
  --exclude ".DS_Store" \
  ./ deploy-temp/

echo -e "${GREEN}✅ Deployment package created${NC}"

# 3. Upload to server (commented out - requires actual server details)
echo -e "${YELLOW}📤 Upload to server (manual step)${NC}"
echo "Run this command to upload:"
echo "rsync -av --delete deploy-temp/ ${SERVER_USER}:${DEPLOY_PATH}/"

# 4. Server setup commands (to be run on server)
echo -e "${BLUE}🔧 Server Setup Commands${NC}"
echo "Run these commands on the server:"
echo ""
echo "# Create writable directories"
echo "mkdir -p ${DEPLOY_PATH}/php/saves ${DEPLOY_PATH}/saves"
echo ""
echo "# Set permissions"
echo "chmod -R 775 ${DEPLOY_PATH}/php/saves ${DEPLOY_PATH}/saves"
echo "find ${DEPLOY_PATH} -type f -exec chmod 644 {} \\;"
echo "find ${DEPLOY_PATH} -type d -exec chmod 755 {} \\;"
echo ""
echo "# Test write permissions"
echo "echo '{}' > ${DEPLOY_PATH}/php/saves/_write_test.json && rm ${DEPLOY_PATH}/php/saves/_write_test.json"

# 5. Health check URLs
echo -e "${BLUE}🏥 Health Check URLs${NC}"
echo "Test these URLs after deployment:"
echo "- App home: ${BASE_URL}/php/home.php"
echo "- Checklist: ${BASE_URL}/php/mychecklist.php?session=TEST&type=camtasia"
echo "- Admin: ${BASE_URL}/php/admin.php"
echo ""
echo "Quick health check commands:"
echo "curl -I ${BASE_URL}/php/home.php"
echo "curl -I '${BASE_URL}/php/mychecklist.php?session=TEST&type=camtasia'"

# 6. Cleanup
echo -e "${BLUE}🧹 Cleanup${NC}"
echo "Deployment package ready in: deploy-temp/"
echo "Remove after successful deployment: rm -rf deploy-temp/"

echo ""
echo -e "${GREEN}🎉 Deployment preparation complete!${NC}"
echo "Next steps:"
echo "1. Upload deploy-temp/ to server"
echo "2. Run server setup commands"
echo "3. Test health check URLs"
echo "4. Clean up deploy-temp/ directory"