#!/bin/bash

# Apache Production Simulation Start
# Stops existing servers and starts Apache for AI automated testing

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🚀 Starting Apache Production Simulation${NC}"
echo "=============================================="
echo ""

# Check for existing PHP dev servers (info only, won't kill)
echo -e "${BLUE}📋 Checking for PHP development servers...${NC}"
PHP_PIDS=$(ps aux | grep "php -S" | grep -v grep | awk '{print $2}' || true)

if [ -n "$PHP_PIDS" ]; then
    echo -e "${GREEN}✅ PHP dev server running on port 8000 (PIDs: $PHP_PIDS)${NC}"
    echo -e "${BLUE}💡 Both servers can run simultaneously${NC}"
else
    echo -e "${BLUE}ℹ️  No PHP dev servers running${NC}"
fi

echo ""

# Stop existing Apache if running
echo -e "${YELLOW}📋 Checking Apache status...${NC}"
if sudo apachectl -k status &> /dev/null; then
    echo -e "${YELLOW}⚠️  Apache is running${NC}"
    echo "Stopping Apache..."
    sudo apachectl -k stop || true
    sleep 2
    echo -e "${GREEN}✅ Apache stopped${NC}"
else
    echo -e "${GREEN}✅ Apache not running${NC}"
fi

echo ""

# Check if Apache is configured for production simulation
echo -e "${BLUE}🔍 Verifying Apache configuration...${NC}"
if [ ! -f "/etc/apache2/other/accessilist.conf" ]; then
    echo -e "${RED}❌ Apache not configured for AccessiList${NC}"
    echo ""
    echo -e "${YELLOW}💡 Run setup first:${NC}"
    echo "   ./scripts/setup-local-apache.sh"
    exit 1
fi

# Test Apache configuration
echo "Testing Apache configuration..."
if sudo apachectl configtest 2>&1 | grep -q "Syntax OK"; then
    echo -e "${GREEN}✅ Configuration valid${NC}"
else
    echo -e "${RED}❌ Configuration errors found${NC}"
    sudo apachectl configtest
    exit 1
fi

echo ""

# Start Apache
echo -e "${BLUE}🚀 Starting Apache...${NC}"
echo "-------------------------------------------"
sudo apachectl start

# Wait for Apache to start
sleep 2

# Verify Apache is running
if sudo apachectl -k status &> /dev/null; then
    echo -e "${GREEN}✅ Apache started successfully${NC}"
else
    echo -e "${RED}❌ Apache failed to start${NC}"
    echo ""
    echo -e "${YELLOW}📋 Check error log:${NC}"
    echo "   tail -f /var/log/apache2/error_log"
    exit 1
fi

echo ""

# Display configuration
echo -e "${BLUE}📊 Server Configuration:${NC}"
echo "-------------------------------------------"
echo "URL: http://localhost/"
echo "DocumentRoot: /Users/a00288946/Projects/accessilist"
echo "Apache Version: $(apachectl -v | grep "Server version" | cut -d: -f2 | xargs)"
echo ""

# Test if mod_rewrite is enabled
echo -e "${BLUE}🔧 Module Status:${NC}"
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

# Test clean URLs
echo -e "${BLUE}🧪 Testing Clean URLs:${NC}"
echo "-------------------------------------------"

# Test root
if curl -s -o /dev/null -w "%{http_code}" http://localhost/ | grep -q "200\|302\|301"; then
    echo -e "  ${GREEN}✅ Root (/) responding${NC}"
else
    echo -e "  ${RED}❌ Root (/) not responding${NC}"
fi

# Test /home (may 404 on PHP built-in server, but should work on Apache)
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/home)
if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "302" ] || [ "$HTTP_CODE" = "301" ]; then
    echo -e "  ${GREEN}✅ /home responding (HTTP $HTTP_CODE)${NC}"
else
    echo -e "  ${YELLOW}⚠️  /home HTTP $HTTP_CODE (may need .htaccess)${NC}"
fi

# Test /admin
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/admin)
if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "302" ] || [ "$HTTP_CODE" = "301" ]; then
    echo -e "  ${GREEN}✅ /admin responding (HTTP $HTTP_CODE)${NC}"
else
    echo -e "  ${YELLOW}⚠️  /admin HTTP $HTTP_CODE (may need .htaccess)${NC}"
fi

echo ""

# Show test URLs
echo -e "${BLUE}🌐 Test URLs:${NC}"
echo "  http://localhost/"
echo "  http://localhost/home"
echo "  http://localhost/admin"
echo "  http://localhost/php/home.php"
echo ""

echo -e "${BLUE}📝 Management Commands:${NC}"
echo "  Stop:    sudo apachectl stop"
echo "  Restart: sudo apachectl restart"
echo "  Status:  sudo apachectl status"
echo "  Logs:    tail -f /var/log/apache2/accessilist_error.log"
echo ""

echo -e "${GREEN}✅ Apache production simulation ready!${NC}"
echo -e "${YELLOW}💡 Use Ctrl+C to return to shell (Apache runs in background)${NC}"

