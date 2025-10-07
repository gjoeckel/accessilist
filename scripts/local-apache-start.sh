#!/bin/bash

# Combined Server Start
# Starts both PHP dev server (port 8000) and Apache (port 80)
# PHP server starts first for manual testing, then Apache for production validation

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🚀 Starting Both Servers (PHP + Apache)${NC}"
echo "=============================================="
echo ""

PROJECT_DIR="/Users/a00288946/Desktop/accessilist"

# Check we're in the right directory
if [ ! -d "$PROJECT_DIR" ]; then
    echo -e "${RED}❌ Project directory not found: $PROJECT_DIR${NC}"
    exit 1
fi

cd "$PROJECT_DIR"

# Step 1: Check port availability
echo -e "${BLUE}📋 Step 1: Checking Port Availability${NC}"
echo "-------------------------------------------"

PORT_8000_CHECK=$(lsof -ti:8000 || true)
PORT_80_CHECK=$(lsof -ti:80 || true)

if [ -n "$PORT_8000_CHECK" ]; then
    echo -e "${YELLOW}⚠️  Port 8000 in use (PID: $PORT_8000_CHECK)${NC}"
    echo "Killing existing process on port 8000..."
    kill $PORT_8000_CHECK 2>/dev/null || true
    sleep 1
fi

if [ -n "$PORT_80_CHECK" ]; then
    echo -e "${YELLOW}⚠️  Port 80 in use (may be Apache)${NC}"
    if sudo apachectl -k status &> /dev/null; then
        echo "Stopping Apache..."
        sudo apachectl -k stop || true
        sleep 2
    fi
fi

echo -e "${GREEN}✅ Ports available${NC}"
echo ""

# Step 2: Start PHP Dev Server (background)
echo -e "${BLUE}📋 Step 2: Starting PHP Server (Port 8000)${NC}"
echo "-------------------------------------------"
echo "Starting PHP development server in background..."

# Start PHP server in background with log file
nohup php -S localhost:8000 > /tmp/php-server-8000.log 2>&1 &
PHP_PID=$!

# Wait a moment for server to start
sleep 2

# Verify PHP server is running
if ps -p $PHP_PID > /dev/null; then
    echo -e "${GREEN}✅ PHP server started (PID: $PHP_PID)${NC}"
    echo "   URL: http://localhost:8000"
    echo "   Log: /tmp/php-server-8000.log"
else
    echo -e "${RED}❌ PHP server failed to start${NC}"
    cat /tmp/php-server-8000.log
    exit 1
fi

echo ""

# Step 3: Check Apache configuration
echo -e "${BLUE}📋 Step 3: Verifying Apache Configuration${NC}"
echo "-------------------------------------------"

if [ ! -f "/etc/apache2/other/accessilist.conf" ]; then
    echo -e "${RED}❌ Apache not configured for AccessiList${NC}"
    echo ""
    echo -e "${YELLOW}💡 Run setup first:${NC}"
    echo "   ./scripts/setup-local-apache.sh"
    exit 1
fi

# Test Apache configuration
if sudo apachectl configtest 2>&1 | grep -q "Syntax OK"; then
    echo -e "${GREEN}✅ Apache configuration valid${NC}"
else
    echo -e "${RED}❌ Apache configuration errors${NC}"
    sudo apachectl configtest
    exit 1
fi

echo ""

# Step 4: Start Apache
echo -e "${BLUE}📋 Step 4: Starting Apache (Port 80)${NC}"
echo "-------------------------------------------"

sudo apachectl start

# Wait for Apache to start
sleep 2

# Verify Apache is running
if sudo apachectl -k status &> /dev/null; then
    echo -e "${GREEN}✅ Apache started${NC}"
    echo "   URL: http://localhost"
else
    echo -e "${RED}❌ Apache failed to start${NC}"
    exit 1
fi

echo ""

# Step 5: Verify modules
echo -e "${BLUE}📋 Step 5: Module Status${NC}"
echo "-------------------------------------------"

if apachectl -M 2>/dev/null | grep -q "rewrite_module"; then
    echo -e "  ${GREEN}✅ mod_rewrite: Enabled${NC}"
else
    echo -e "  ${RED}❌ mod_rewrite: Disabled${NC}"
fi

if apachectl -M 2>/dev/null | grep -q "php"; then
    echo -e "  ${GREEN}✅ PHP module: Enabled${NC}"
else
    echo -e "  ${YELLOW}⚠️  PHP module: Not detected${NC}"
fi

echo ""

# Step 6: Test both servers
echo -e "${BLUE}📋 Step 6: Testing Both Servers${NC}"
echo "-------------------------------------------"

# Test PHP server
if curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/ | grep -q "200\|302\|301"; then
    echo -e "  ${GREEN}✅ PHP server responding (port 8000)${NC}"
else
    echo -e "  ${RED}❌ PHP server not responding${NC}"
fi

# Test Apache
if curl -s -o /dev/null -w "%{http_code}" http://localhost/ | grep -q "200\|302\|301"; then
    echo -e "  ${GREEN}✅ Apache responding (port 80)${NC}"
else
    echo -e "  ${RED}❌ Apache not responding${NC}"
fi

# Test clean URL on Apache
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/home)
if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "302" ] || [ "$HTTP_CODE" = "301" ]; then
    echo -e "  ${GREEN}✅ Clean URL /home working (HTTP $HTTP_CODE)${NC}"
else
    echo -e "  ${YELLOW}⚠️  Clean URL /home (HTTP $HTTP_CODE)${NC}"
fi

echo ""

# Summary
echo -e "${GREEN}🎉 Both Servers Running!${NC}"
echo "=============================================="
echo ""
echo -e "${BLUE}📊 Server Status:${NC}"
echo "  PHP Dev Server:"
echo "    • URL: http://localhost:8000"
echo "    • PID: $PHP_PID"
echo "    • Log: /tmp/php-server-8000.log"
echo "    • .htaccess: ❌ Not processed"
echo ""
echo "  Apache Server:"
echo "    • URL: http://localhost"
echo "    • Status: Running (daemon)"
echo "    • Log: /var/log/apache2/accessilist_error.log"
echo "    • .htaccess: ✅ Processed"
echo ""
echo -e "${BLUE}🌐 Test URLs:${NC}"
echo "  PHP Dev (quick testing):"
echo "    • http://localhost:8000/"
echo "    • http://localhost:8000/php/home.php"
echo ""
echo "  Apache (production testing):"
echo "    • http://localhost/"
echo "    • http://localhost/home (clean URL)"
echo "    • http://localhost/admin (clean URL)"
echo ""
echo -e "${BLUE}🛑 Stop Commands:${NC}"
echo "  Stop PHP:    kill $PHP_PID"
echo "  Stop Apache: sudo apachectl stop"
echo "  Stop Both:   kill $PHP_PID && sudo apachectl stop"
echo ""
echo -e "${GREEN}✅ Ready for development and testing!${NC}"

