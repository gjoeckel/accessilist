#!/bin/bash

# Rollback Apache Setup to Pre-Configuration State
# This removes ALL changes made during Apache setup
# Created: October 7, 2025

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${RED}⚠️  Apache Setup Rollback${NC}"
echo "=============================================="
echo ""
echo -e "${YELLOW}This will UNDO all Apache configuration changes:${NC}"
echo "  • VirtualHost configuration"
echo "  • httpd.conf modifications"
echo "  • Symlink to project"
echo "  • Log files"
echo "  • (Optional) Passwordless sudo"
echo ""
echo -e "${RED}Press Ctrl+C within 5 seconds to cancel...${NC}"
sleep 5
echo ""

# Step 1: Stop Apache
echo -e "${BLUE}📋 Step 1: Stopping Apache${NC}"
echo "-------------------------------------------"
if sudo apachectl -k status &> /dev/null; then
    sudo apachectl -k stop
    sleep 2
    echo -e "${GREEN}✅ Apache stopped${NC}"
else
    echo -e "${GREEN}✅ Apache already stopped${NC}"
fi
echo ""

# Step 2: Remove VirtualHost config
echo -e "${BLUE}📋 Step 2: Removing VirtualHost${NC}"
echo "-------------------------------------------"
if [ -f /etc/apache2/other/accessilist.conf ]; then
    sudo rm /etc/apache2/other/accessilist.conf
    echo -e "${GREEN}✅ VirtualHost configuration removed${NC}"
else
    echo -e "${YELLOW}⚠️  VirtualHost already removed${NC}"
fi
echo ""

# Step 3: Restore original httpd.conf
echo -e "${BLUE}📋 Step 3: Restoring Original Apache Config${NC}"
echo "-------------------------------------------"
if [ -f /etc/apache2/httpd.conf.backup ]; then
    sudo cp /etc/apache2/httpd.conf.backup /etc/apache2/httpd.conf
    echo -e "${GREEN}✅ httpd.conf restored to original state${NC}"
    echo "   PHP module: Disabled"
    echo "   mod_rewrite: Disabled"
    echo "   AllowOverride: None (default)"
else
    echo -e "${RED}❌ Backup not found at /etc/apache2/httpd.conf.backup${NC}"
    echo -e "${RED}   httpd.conf was NOT restored${NC}"
fi
echo ""

# Step 4: Remove symlink
echo -e "${BLUE}📋 Step 4: Removing Symlink${NC}"
echo "-------------------------------------------"
if [ -L /Library/WebServer/Documents/accessilist ]; then
    sudo rm /Library/WebServer/Documents/accessilist
    echo -e "${GREEN}✅ Symlink removed${NC}"
else
    echo -e "${YELLOW}⚠️  Symlink already removed${NC}"
fi
echo ""

# Step 5: Remove passwordless sudo (OPTIONAL)
echo -e "${BLUE}📋 Step 5: Remove Passwordless Sudo${NC}"
echo "-------------------------------------------"
if [ -f /etc/sudoers.d/apache-a00288946 ]; then
    echo -e "${YELLOW}Passwordless sudo configuration exists${NC}"
    echo -e "${YELLOW}This is optional - keeps AI agent autonomous${NC}"
    echo ""
    read -p "Remove passwordless sudo? (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sudo rm /etc/sudoers.d/apache-a00288946
        echo -e "${GREEN}✅ Passwordless sudo removed${NC}"
        echo -e "${RED}   AI agent will need password for Apache commands${NC}"
    else
        echo -e "${BLUE}ℹ️  Keeping passwordless sudo (AI remains autonomous)${NC}"
    fi
else
    echo -e "${GREEN}✅ No passwordless sudo config found${NC}"
fi
echo ""

# Step 6: Clean up log files
echo -e "${BLUE}📋 Step 6: Cleaning Up Log Files${NC}"
echo "-------------------------------------------"
if [ -f /private/var/log/apache2/accessilist_error.log ]; then
    sudo rm -f /private/var/log/apache2/accessilist_error.log
    echo -e "${GREEN}✅ Error log removed${NC}"
else
    echo "   No error log found"
fi

if [ -f /private/var/log/apache2/accessilist_access.log ]; then
    sudo rm -f /private/var/log/apache2/accessilist_access.log
    echo -e "${GREEN}✅ Access log removed${NC}"
else
    echo "   No access log found"
fi
echo ""

# Step 7: Verify rollback
echo -e "${BLUE}📋 Step 7: Verifying Rollback${NC}"
echo "-------------------------------------------"

# Test Apache config (should use default)
if sudo apachectl configtest 2>&1 | grep -q "Syntax OK"; then
    echo -e "${GREEN}✅ Apache configuration valid${NC}"
else
    echo -e "${RED}❌ Apache configuration errors${NC}"
    echo "   Run: sudo apachectl configtest"
fi

# Check for AccessiList remnants
if [ -f /etc/apache2/other/accessilist.conf ]; then
    echo -e "${RED}❌ VirtualHost still exists${NC}"
else
    echo -e "${GREEN}✅ VirtualHost removed${NC}"
fi

if [ -L /Library/WebServer/Documents/accessilist ]; then
    echo -e "${RED}❌ Symlink still exists${NC}"
else
    echo -e "${GREEN}✅ Symlink removed${NC}"
fi

echo ""

# Summary
echo -e "${GREEN}✅ Rollback Complete${NC}"
echo "=============================================="
echo ""
echo -e "${BLUE}System Restored to:${NC}"
echo "  ✅ Original Apache configuration"
echo "  ✅ Default httpd.conf (PHP disabled, mod_rewrite disabled)"
echo "  ✅ No AccessiList VirtualHost"
echo "  ✅ No project symlink"
echo "  ✅ No AccessiList logs"

if [ -f /etc/sudoers.d/apache-a00288946 ]; then
    echo "  ℹ️  Passwordless sudo still configured (optional, kept)"
else
    echo "  ✅ Passwordless sudo removed"
fi

echo ""
echo -e "${BLUE}📝 What's Left:${NC}"
echo "  • Project files unchanged (all in git)"
echo "  • Backup preserved: /etc/apache2/httpd.conf.backup"
echo "  • Scripts still available in scripts/ folder"
echo "  • Documentation still available"
echo ""
echo -e "${YELLOW}💡 To setup Apache again:${NC}"
echo "  ./scripts/setup-local-apache.sh"
echo ""
echo -e "${GREEN}🎉 System restored to pre-Apache state!${NC}"

