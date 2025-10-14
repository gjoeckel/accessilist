#!/bin/bash

# Local PHP Server Start
# Starts PHP server with router.php for clean URL support
# Supports both foreground and background modes

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check for background flag
BACKGROUND=false
if [[ "$1" == "--background" ]] || [[ "$1" == "-bg" ]]; then
    BACKGROUND=true
fi

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

# Start new PHP server with router.php
echo -e "${BLUE}🚀 Starting PHP development server with router.php...${NC}"
echo "-------------------------------------------"
echo "URL: http://localhost:8000"
echo "Root: /Users/a00288946/Projects/accessilist"
echo "Router: router.php (enables clean URLs)"

cd /Users/a00288946/Projects/accessilist

if [ "$BACKGROUND" = true ]; then
    echo "Mode: Background (logging to logs/php-server.log)"
    echo ""
    echo -e "${GREEN}✅ Server starting in background...${NC}"
    php -S localhost:8000 router.php > logs/php-server.log 2>&1 &
    SERVER_PID=$!
    sleep 1

    # Verify server started
    if ps -p $SERVER_PID > /dev/null; then
        echo -e "${GREEN}✅ Server running (PID: $SERVER_PID)${NC}"
        echo ""
        echo -e "${BLUE}📋 Useful commands:${NC}"
        echo "  View logs: tail -f logs/php-server.log"
        echo "  Stop server: kill $SERVER_PID"
        echo "  Or: lsof -ti:8000 | xargs kill"
    else
        echo -e "${RED}❌ Server failed to start${NC}"
        echo "Check logs/php-server.log for details"
        exit 1
    fi
else
    echo "Mode: Foreground (Press Ctrl+C to stop)"
    echo ""
    php -S localhost:8000 router.php
fi
