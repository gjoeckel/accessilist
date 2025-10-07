#!/bin/bash

# One-Time Production .env Setup Script
# This script creates and locks the production .env file on AWS server

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Server configuration
PEM_FILE="/Users/a00288946/Developer/projects/GeorgeWebAIMServerKey.pem"
SERVER="george@ec2-3-20-59-76.us-east-2.compute.amazonaws.com"
REMOTE_PATH="/var/websites/webaim/htdocs/training/online/accessilist"

echo -e "${BLUE}🔧 Production .env Setup${NC}"
echo "=================================="
echo ""

# Verify PEM file exists
if [ ! -f "$PEM_FILE" ]; then
    echo -e "${RED}❌ Error: PEM file not found at $PEM_FILE${NC}"
    exit 1
fi

echo -e "${YELLOW}📝 Backing up existing .env if present...${NC}"
ssh -i "$PEM_FILE" "$SERVER" "
    if [ -f $REMOTE_PATH/.env ]; then
        cp $REMOTE_PATH/.env $REMOTE_PATH/.env.backup.\$(date +%Y%m%d_%H%M%S)
        echo '✅ Backed up existing .env'
    else
        echo 'ℹ️  No existing .env to backup'
    fi
"

echo ""
echo -e "${BLUE}🔨 Creating production .env file...${NC}"

ssh -i "$PEM_FILE" "$SERVER" "
    # Make writable temporarily
    touch $REMOTE_PATH/.env
    chmod 640 $REMOTE_PATH/.env

    # Write production configuration
    cat > $REMOTE_PATH/.env << 'EOF'
# Production Environment Configuration
# DO NOT EDIT - Managed independently from git repository
# Last updated: $(date '+%Y-%m-%d %H:%M:%S')

APP_ENV=production
BASE_PATH_PRODUCTION=/training/online/accessilist
API_EXT_PRODUCTION=
DEBUG_PRODUCTION=false
EOF

    # Lock as read-only
    chmod 440 $REMOTE_PATH/.env

    echo '✅ Production .env created and locked'
"

echo ""
echo -e "${GREEN}🔍 Verifying production .env...${NC}"

ssh -i "$PEM_FILE" "$SERVER" "
    echo '📄 File permissions:'
    ls -la $REMOTE_PATH/.env
    echo ''
    echo '📄 File contents:'
    cat $REMOTE_PATH/.env
"

echo ""
echo -e "${GREEN}✅ Production .env setup complete!${NC}"
echo ""
echo -e "${YELLOW}Important notes:${NC}"
echo "- .env is now read-only (chmod 440)"
echo "- .env is NOT in git repository"
echo "- Deployments will NOT overwrite this file"
echo "- This file is permanent unless manually changed via SSH"
echo ""
echo -e "${BLUE}🎉 Production environment secured!${NC}"

