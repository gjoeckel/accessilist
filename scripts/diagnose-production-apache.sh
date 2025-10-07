#!/bin/bash

# Production Apache Diagnostic Script
# Gathers all necessary Apache configuration for local testing setup

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🔍 Production Apache Configuration Diagnostic${NC}"
echo "=============================================="
echo ""

# Apache Version & Modules
echo -e "${GREEN}📋 Apache Version & Modules${NC}"
echo "-------------------------------------------"
if command -v apache2 &> /dev/null; then
    echo "Apache Version:"
    apache2 -v
    echo ""
    echo "Enabled Modules (checking for mod_rewrite):"
    apache2 -M | grep rewrite || echo "⚠️  mod_rewrite NOT found"
    echo ""
elif command -v httpd &> /dev/null; then
    echo "Apache Version:"
    httpd -v
    echo ""
    echo "Enabled Modules (checking for mod_rewrite):"
    httpd -M | grep rewrite || echo "⚠️  mod_rewrite NOT found"
    echo ""
else
    echo -e "${RED}❌ Apache not found${NC}"
fi

# Find DocumentRoot
echo -e "${GREEN}🏠 DocumentRoot Configuration${NC}"
echo "-------------------------------------------"
if [ -d /etc/apache2 ]; then
    echo "Searching /etc/apache2 for DocumentRoot:"
    grep -r "DocumentRoot" /etc/apache2/ 2>/dev/null | grep -v "#" | head -5
elif [ -d /etc/httpd ]; then
    echo "Searching /etc/httpd for DocumentRoot:"
    grep -r "DocumentRoot" /etc/httpd/ 2>/dev/null | grep -v "#" | head -5
fi
echo ""

# Find AccessiList VirtualHost
echo -e "${GREEN}🌐 AccessiList VirtualHost Configuration${NC}"
echo "-------------------------------------------"
if [ -d /etc/apache2 ]; then
    echo "Searching for accessilist configuration:"
    grep -r "accessilist" /etc/apache2/ 2>/dev/null | grep -v "#" || echo "No specific accessilist config found"
elif [ -d /etc/httpd ]; then
    echo "Searching for accessilist configuration:"
    grep -r "accessilist" /etc/httpd/ 2>/dev/null | grep -v "#" || echo "No specific accessilist config found"
fi
echo ""

# Find AllowOverride settings
echo -e "${GREEN}🔧 AllowOverride Settings (for .htaccess)${NC}"
echo "-------------------------------------------"
if [ -d /etc/apache2 ]; then
    echo "AllowOverride settings in Apache config:"
    grep -r "AllowOverride" /etc/apache2/ 2>/dev/null | grep -v "#" | head -10
elif [ -d /etc/httpd ]; then
    echo "AllowOverride settings in Apache config:"
    grep -r "AllowOverride" /etc/httpd/ 2>/dev/null | grep -v "#" | head -10
fi
echo ""

# Find actual application path
echo -e "${GREEN}📁 Application File Location${NC}"
echo "-------------------------------------------"
echo "Searching for accessilist application files:"
find /var/www /home /var/websites -type d -name "accessilist" 2>/dev/null | head -5 || echo "Not found in common locations"
echo ""

# Check for webaim directory structure
echo "Checking common WebAIM paths:"
for path in "/var/www/html/training/online/accessilist" "/var/websites/webaim/htdocs/training/online/accessilist" "/home/webaim/public_html/training/online/accessilist"; do
    if [ -d "$path" ]; then
        echo "✅ Found: $path"
        ls -la "$path" | head -10
    fi
done
echo ""

# Apache User
echo -e "${GREEN}👤 Apache User & Permissions${NC}"
echo "-------------------------------------------"
echo "Apache is running as:"
ps aux | grep -E "apache|httpd" | grep -v grep | head -1 | awk '{print $1}'
echo ""

# Directory Permissions
echo -e "${GREEN}🔒 Directory Permissions${NC}"
echo "-------------------------------------------"
for path in "/var/www/html/training/online/accessilist" "/var/websites/webaim/htdocs/training/online/accessilist"; do
    if [ -d "$path" ]; then
        echo "Permissions for: $path"
        ls -la "$path" | head -5
        echo ""
    fi
done

# .htaccess location
echo -e "${GREEN}📄 .htaccess File Location${NC}"
echo "-------------------------------------------"
find /var/www /home /var/websites -name ".htaccess" -path "*/accessilist/*" 2>/dev/null || echo "No .htaccess found"
echo ""

# PHP Info
echo -e "${GREEN}🐘 PHP Configuration${NC}"
echo "-------------------------------------------"
echo "PHP Version:"
php -v | head -1
echo ""
echo "PHP Modules (checking for Apache integration):"
php -m | grep -E "apache|fpm" || echo "⚠️  No Apache module found (might use PHP-FPM)"
echo ""

# Summary
echo -e "${BLUE}📊 Quick Summary${NC}"
echo "=============================================="
echo "Copy the above output and paste it back in the conversation."
echo ""
echo -e "${YELLOW}💡 Key Information Needed:${NC}"
echo "1. DocumentRoot path"
echo "2. Full path to accessilist application"
echo "3. AllowOverride settings"
echo "4. Apache user"
echo "5. mod_rewrite status"
echo ""

