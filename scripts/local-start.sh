#!/bin/bash

# Local PHP Server Start
# Kills existing PHP servers and starts fresh for manual developer testing

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🔧 Starting Local PHP Development Server${NC}"
echo "=============================================="
echo ""

# Check for existing PHP servers (info only, won't kill)
echo -e "${BLUE}📋 Checking for existing PHP servers...${NC}"
PHP_PIDS=$(ps aux | grep "php -S" | grep -v grep | awk '{print $2}' || true)

if [ -n "$PHP_PIDS" ]; then
    echo -e "${BLUE}ℹ️  Found running PHP servers (PIDs: $PHP_PIDS)${NC}"
    echo -e "${BLUE}💡 Multiple PHP servers can run on different ports${NC}"
else
    echo -e "${BLUE}ℹ️  No existing PHP servers found${NC}"
fi

echo ""

# Check if port 8000 is already in use
echo -e "${YELLOW}📋 Checking port 8000...${NC}"
PORT_CHECK=$(lsof -ti:8000 || true)
if [ -n "$PORT_CHECK" ]; then
    echo -e "${RED}❌ Port 8000 already in use (PID: $PORT_CHECK)${NC}"
    echo -e "${YELLOW}💡 Stop the conflicting process or use a different port${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Port 8000 available${NC}"

echo ""

# Start new PHP server
echo -e "${BLUE}🚀 Starting PHP development server...${NC}"
echo "-------------------------------------------"
echo "URL: http://localhost:8000"
echo "Root: /Users/a00288946/Desktop/accessilist"
echo "Press Ctrl+C to stop"
echo ""

cd /Users/a00288946/Desktop/accessilist
php -S localhost:8000

