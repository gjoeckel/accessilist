#!/bin/bash

# Setup Production Path Mirror
# Creates symlink to mirror production directory structure
# Run this manually: sudo ./scripts/setup-production-path.sh

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}Setting up production path mirror...${NC}"
echo ""

PROJECT_DIR="/Users/a00288946/Desktop/accessilist"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${YELLOW}This script requires sudo privileges.${NC}"
    echo "Please run: sudo ./scripts/setup-production-path.sh"
    exit 1
fi

# Create directory structure
echo "Creating directory structure..."
mkdir -p /Library/WebServer/Documents/training/online

# Create or update symlink
if [ -L "/Library/WebServer/Documents/training/online/accessilist" ]; then
    echo "Removing existing symlink..."
    rm "/Library/WebServer/Documents/training/online/accessilist"
fi

echo "Creating symlink..."
ln -sf "$PROJECT_DIR" "/Library/WebServer/Documents/training/online/accessilist"

# Verify symlink
if [ -L "/Library/WebServer/Documents/training/online/accessilist" ]; then
    echo -e "${GREEN}✅ Symlink created successfully${NC}"
    echo ""
    echo "Production path structure:"
    ls -la /Library/WebServer/Documents/training/online/
    echo ""
    echo "Production URL: http://localhost/training/online/accessilist"
    echo ""
    echo -e "${GREEN}✅ Ready for production-mirror testing!${NC}"
else
    echo -e "${RED}❌ Failed to create symlink${NC}"
    exit 1
fi

