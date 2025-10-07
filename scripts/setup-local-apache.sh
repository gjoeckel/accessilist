#!/bin/bash

# Local macOS Apache Setup - Matches Production Configuration
# Automatically configures macOS built-in Apache to mirror production server
#
# Production Server Configuration:
# - Apache 2.4.52
# - DocumentRoot: /var/websites/webaim/htdocs
# - App Path: /var/websites/webaim/htdocs/training/online/accessilist
# - PHP 8.1 via PHP-FPM
# - mod_rewrite ENABLED
# - AllowOverride All
# - Directory permissions: www-data:www-data (775 dirs, 644 files)

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🚀 Local Apache Setup - Production Mirror${NC}"
echo "=============================================="
echo ""

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}❌ This script is for macOS only${NC}"
    exit 1
fi

# Get project directory
PROJECT_DIR="/Users/a00288946/Desktop/accessilist"
if [ ! -d "$PROJECT_DIR" ]; then
    echo -e "${RED}❌ Project directory not found: $PROJECT_DIR${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Project found: $PROJECT_DIR${NC}"
echo ""

# Step 1: Check Apache
echo -e "${BLUE}📋 Step 1: Checking Apache${NC}"
echo "-------------------------------------------"
if ! command -v apachectl &> /dev/null; then
    echo -e "${RED}❌ Apache not found${NC}"
    exit 1
fi

APACHE_VERSION=$(apachectl -v | grep "Server version" | awk '{print $3}')
echo -e "${GREEN}✅ Apache found: $APACHE_VERSION${NC}"
echo ""

# Step 2: Stop Apache if running
echo -e "${BLUE}📋 Step 2: Managing Apache Service${NC}"
echo "-------------------------------------------"
if sudo apachectl -k status &> /dev/null; then
    echo "Stopping Apache..."
    sudo apachectl -k stop || true
    sleep 2
fi
echo -e "${GREEN}✅ Apache stopped${NC}"
echo ""

# Step 3: Enable PHP module
echo -e "${BLUE}📋 Step 3: Enabling PHP Module${NC}"
echo "-------------------------------------------"

# Backup original httpd.conf
if [ ! -f /etc/apache2/httpd.conf.backup ]; then
    echo "Creating backup of httpd.conf..."
    sudo cp /etc/apache2/httpd.conf /etc/apache2/httpd.conf.backup
    echo -e "${GREEN}✅ Backup created${NC}"
fi

# Check PHP version
PHP_VERSION=$(php -v | head -1 | awk '{print $2}' | cut -d. -f1,2)
echo "PHP Version: $PHP_VERSION"

# Enable PHP module in httpd.conf
echo "Enabling PHP module..."
if grep -q "^#LoadModule php" /etc/apache2/httpd.conf; then
    sudo sed -i '' 's/^#LoadModule php/LoadModule php/' /etc/apache2/httpd.conf
    echo -e "${GREEN}✅ PHP module enabled${NC}"
else
    echo -e "${YELLOW}⚠️  PHP module already enabled or not found${NC}"
fi
echo ""

# Step 4: Enable mod_rewrite
echo -e "${BLUE}📋 Step 4: Enabling mod_rewrite${NC}"
echo "-------------------------------------------"
if grep -q "^#LoadModule rewrite_module" /etc/apache2/httpd.conf; then
    sudo sed -i '' 's/^#LoadModule rewrite_module/LoadModule rewrite_module/' /etc/apache2/httpd.conf
    echo -e "${GREEN}✅ mod_rewrite enabled${NC}"
elif grep -q "^LoadModule rewrite_module" /etc/apache2/httpd.conf; then
    echo -e "${GREEN}✅ mod_rewrite already enabled${NC}"
else
    echo -e "${RED}❌ Could not find mod_rewrite${NC}"
fi
echo ""

# Step 5: Configure VirtualHost
echo -e "${BLUE}📋 Step 5: Creating VirtualHost Configuration${NC}"
echo "-------------------------------------------"

VHOST_CONF="/etc/apache2/other/accessilist.conf"

echo "Creating VirtualHost config: $VHOST_CONF"

sudo tee "$VHOST_CONF" > /dev/null <<EOF
# AccessiList Local Development - Production Mirror
# Mirrors: ec2-3-20-59-76.us-east-2.compute.amazonaws.com
# Production Path: /var/websites/webaim/htdocs/training/online/accessilist

<VirtualHost *:80>
    ServerName localhost
    DocumentRoot "$PROJECT_DIR"

    # Match production PHP-FPM setup (macOS uses mod_php instead)
    <FilesMatch \\.php\$>
        SetHandler application/x-httpd-php
    </FilesMatch>

    # Match production directory settings
    <Directory "$PROJECT_DIR">
        Options +FollowSymLinks +Multiviews +Indexes
        AllowOverride All
        Require all granted
    </Directory>

    # Match production settings
    DirectoryIndex index.php index.htm index.html

    # Enable mod_rewrite (matches production)
    RewriteEngine On

    # Error log
    ErrorLog "/private/var/log/apache2/accessilist_error.log"
    CustomLog "/private/var/log/apache2/accessilist_access.log" combined
</VirtualHost>
EOF

echo -e "${GREEN}✅ VirtualHost created${NC}"
echo ""

# Step 6: Enable AllowOverride globally (matches production)
echo -e "${BLUE}📋 Step 6: Configuring AllowOverride${NC}"
echo "-------------------------------------------"

# Update main DocumentRoot directory
sudo sed -i '' '/<Directory "\/Library\/WebServer\/Documents">/,/<\/Directory>/{
    s/AllowOverride None/AllowOverride All/g
}' /etc/apache2/httpd.conf

echo -e "${GREEN}✅ AllowOverride set to All${NC}"
echo ""

# Step 7: Configure PHP settings to match production
echo -e "${BLUE}📋 Step 7: Configuring PHP${NC}"
echo "-------------------------------------------"

# Create .env file if it doesn't exist
if [ ! -f "$PROJECT_DIR/.env" ]; then
    echo "Creating .env file..."
    cat > "$PROJECT_DIR/.env" <<EOF
APP_ENV=local
BASE_PATH_LOCAL=
BASE_PATH_PRODUCTION=/training/online/accessilist
API_EXT_LOCAL=.php
API_EXT_PRODUCTION=
DEBUG_LOCAL=true
DEBUG_PRODUCTION=false
EOF
    chmod 600 "$PROJECT_DIR/.env"
    echo -e "${GREEN}✅ .env file created${NC}"
else
    echo -e "${YELLOW}⚠️  .env file already exists${NC}"
fi
echo ""

# Step 8: Set file permissions (match production as close as possible)
echo -e "${BLUE}📋 Step 8: Setting File Permissions${NC}"
echo "-------------------------------------------"

echo "Setting directory permissions (755)..."
find "$PROJECT_DIR" -type d -exec chmod 755 {} \;

echo "Setting file permissions (644)..."
find "$PROJECT_DIR" -type f -exec chmod 644 {} \;

echo "Setting execute permission on scripts..."
find "$PROJECT_DIR/scripts" -type f -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true

# Make saves directory writable
# Note: Removed php/saves - saves directory is at project root only
if [ -d "$PROJECT_DIR/saves" ]; then
    chmod 775 "$PROJECT_DIR/saves"
fi

echo -e "${GREEN}✅ Permissions set${NC}"
echo ""

# Step 9: Verify .htaccess
echo -e "${BLUE}📋 Step 9: Verifying .htaccess${NC}"
echo "-------------------------------------------"

if [ -f "$PROJECT_DIR/.htaccess" ]; then
    echo -e "${GREEN}✅ .htaccess found${NC}"
    echo ""
    echo "Current .htaccess rewrite rules:"
    grep -E "RewriteRule|RewriteBase" "$PROJECT_DIR/.htaccess" | head -10
else
    echo -e "${RED}❌ .htaccess not found${NC}"
fi
echo ""

# Step 10: Start Apache
echo -e "${BLUE}📋 Step 10: Starting Apache${NC}"
echo "-------------------------------------------"

# Test configuration
echo "Testing Apache configuration..."
if sudo apachectl configtest 2>&1 | grep -q "Syntax OK"; then
    echo -e "${GREEN}✅ Configuration valid${NC}"
else
    echo -e "${RED}❌ Configuration errors found${NC}"
    sudo apachectl configtest
    exit 1
fi

echo "Starting Apache..."
sudo apachectl start

# Wait for Apache to start
sleep 2

if sudo apachectl -k status &> /dev/null; then
    echo -e "${GREEN}✅ Apache running${NC}"
else
    echo -e "${RED}❌ Apache failed to start${NC}"
    echo "Check error log: tail -f /var/log/apache2/error_log"
    exit 1
fi
echo ""

# Step 11: Verification
echo -e "${BLUE}📋 Step 11: Verification${NC}"
echo "-------------------------------------------"

echo "Apache Modules:"
apachectl -M 2>/dev/null | grep -E "rewrite|php" || echo "No rewrite or PHP modules found"
echo ""

echo "Testing URLs:"
echo "1. Root: http://localhost/"
echo "2. Home (clean URL): http://localhost/home"
echo "3. Admin (clean URL): http://localhost/admin"
echo "4. Direct PHP: http://localhost/php/home.php"
echo ""

# Test if Apache is responding
if curl -s -o /dev/null -w "%{http_code}" http://localhost/ | grep -q "200\|302\|301"; then
    echo -e "${GREEN}✅ Apache responding on http://localhost/${NC}"
else
    echo -e "${YELLOW}⚠️  Apache may not be responding correctly${NC}"
fi
echo ""

# Summary
echo -e "${GREEN}🎉 Setup Complete!${NC}"
echo "=============================================="
echo ""
echo -e "${BLUE}📊 Configuration Summary:${NC}"
echo "- Apache: Running on port 80"
echo "- DocumentRoot: $PROJECT_DIR"
echo "- PHP: Enabled (version $PHP_VERSION)"
echo "- mod_rewrite: Enabled"
echo "- AllowOverride: All"
echo "- .htaccess: Active"
echo ""
echo -e "${BLUE}🌐 Test URLs:${NC}"
echo "- http://localhost/ → Should redirect to /home"
echo "- http://localhost/home → Home page (clean URL)"
echo "- http://localhost/admin → Admin page (clean URL)"
echo "- http://localhost/php/home.php → Direct access"
echo ""
echo -e "${BLUE}📝 Next Steps:${NC}"
echo "1. Open http://localhost/ in your browser"
echo "2. Test clean URL navigation"
echo "3. Verify .htaccess rewrite rules work"
echo "4. Check error log if issues: tail -f /var/log/apache2/accessilist_error.log"
echo ""
echo -e "${YELLOW}💡 To stop Apache:${NC}"
echo "sudo apachectl stop"
echo ""
echo -e "${YELLOW}💡 To restart Apache:${NC}"
echo "sudo apachectl restart"
echo ""
echo -e "${YELLOW}💡 To restore original config:${NC}"
echo "sudo cp /etc/apache2/httpd.conf.backup /etc/apache2/httpd.conf"
echo ""

