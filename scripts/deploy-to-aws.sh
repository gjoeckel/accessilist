#!/bin/bash

# Quick deploy to AWS production
# Deploys AccessiList to ec2-3-20-59-76.us-east-2.compute.amazonaws.com

set -e

PEM_FILE="/Users/a00288946/Developer/projects/GeorgeWebAIMServerKey.pem"
SERVER="george@ec2-3-20-59-76.us-east-2.compute.amazonaws.com"
REMOTE_PATH="/var/websites/webaim/htdocs/training/online/accessilist"
LOCAL_PATH="/Users/a00288946/Desktop/accessilist"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🚀 Deploying to AWS production...${NC}"
echo "Server: ec2-3-20-59-76.us-east-2.compute.amazonaws.com"
echo "Path: $REMOTE_PATH"
echo ""

# Check if PEM file exists
if [ ! -f "$PEM_FILE" ]; then
    echo -e "${RED}❌ Error: PEM file not found: $PEM_FILE${NC}"
    exit 1
fi

# Check if local path exists
if [ ! -d "$LOCAL_PATH" ]; then
    echo -e "${RED}❌ Error: Local path not found: $LOCAL_PATH${NC}"
    exit 1
fi

# Dry run first
echo -e "${YELLOW}📋 Preview changes:${NC}"
echo "-------------------------------------------"
rsync -avz --dry-run \
  --exclude .git/ \
  --exclude .gitignore \
  --exclude .cursor/ \
  --exclude node_modules/ \
  --exclude .DS_Store \
  --exclude .env \
  --exclude '*.backup' \
  --exclude '*.bak' \
  -e "ssh -i $PEM_FILE" \
  "$LOCAL_PATH/" \
  "$SERVER:$REMOTE_PATH/" | head -50

echo ""
echo -e "${YELLOW}-------------------------------------------${NC}"

# Ask for confirmation
read -p "Deploy these changes? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo -e "${BLUE}📤 Deploying...${NC}"

    rsync -avz --progress \
      --exclude .git/ \
      --exclude .gitignore \
      --exclude .cursor/ \
      --exclude node_modules/ \
      --exclude .DS_Store \
      --exclude .env \
      --exclude '*.backup' \
      --exclude '*.bak' \
      -e "ssh -i $PEM_FILE" \
      "$LOCAL_PATH/" \
      "$SERVER:$REMOTE_PATH/"

    echo ""
    echo -e "${GREEN}✅ Deployment complete!${NC}"
    echo ""

    # Configure .env on production automatically
    echo -e "${BLUE}⚙️  Configuring production environment...${NC}"
    ssh -i "$PEM_FILE" "$SERVER" "cd $REMOTE_PATH && if [ ! -f .env ]; then cp .env.example .env && sed -i 's/APP_ENV=local/APP_ENV=production/' .env && echo '✅ .env created and configured for production'; else echo '✅ .env already exists'; fi"

    echo ""
    echo -e "${BLUE}🔍 Verification:${NC}"
    echo "-------------------------------------------"

    # Test URLs
    echo "Testing production URLs..."

    if curl -s -o /dev/null -w "%{http_code}" "https://webaim.org/training/online/accessilist/" | grep -q "200\|302\|301"; then
        echo -e "${GREEN}✅ Main page responding${NC}"
    else
        echo -e "${RED}❌ Main page not responding${NC}"
    fi

    if curl -s -o /dev/null -w "%{http_code}" "https://webaim.org/training/online/accessilist/home" | grep -q "200\|302\|301"; then
        echo -e "${GREEN}✅ /home URL responding${NC}"
    else
        echo -e "${YELLOW}⚠️  /home URL check: %{http_code}${NC}"
    fi

    if curl -s -o /dev/null -w "%{http_code}" "https://webaim.org/training/online/accessilist/admin" | grep -q "200\|302\|301"; then
        echo -e "${GREEN}✅ /admin URL responding${NC}"
    else
        echo -e "${YELLOW}⚠️  /admin URL check: %{http_code}${NC}"
    fi

    echo ""
    echo -e "${BLUE}🌐 Test URLs:${NC}"
    echo "  https://webaim.org/training/online/accessilist/"
    echo "  https://webaim.org/training/online/accessilist/home"
    echo "  https://webaim.org/training/online/accessilist/admin"
    echo ""
    echo -e "${BLUE}📊 Check logs (if needed):${NC}"
    echo "  ssh -i $PEM_FILE $SERVER \"tail -f /var/websites/webaim/logs/error.log\""

else
    echo ""
    echo -e "${RED}❌ Deployment cancelled${NC}"
    exit 1
fi

