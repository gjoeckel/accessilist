#!/bin/bash

# Setup Passwordless Apache Control
# Allows AI agent to run Apache commands autonomously without password prompts
# SECURITY: Only allows apachectl commands, nothing else

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🔐 Setup Passwordless Apache Control${NC}"
echo "=============================================="
echo ""

# Get current username
CURRENT_USER=$(whoami)

echo -e "${YELLOW}This will configure sudo to allow apachectl commands without password${NC}"
echo -e "${YELLOW}SECURITY: Only apachectl will be passwordless, nothing else${NC}"
echo ""

# Check if already configured
SUDOERS_FILE="/etc/sudoers.d/apache-$CURRENT_USER"

if sudo test -f "$SUDOERS_FILE"; then
    echo -e "${GREEN}✅ Passwordless Apache already configured${NC}"
    echo ""
    echo "Current configuration:"
    sudo cat "$SUDOERS_FILE"
    echo ""
    echo "To remove: sudo rm $SUDOERS_FILE"
    exit 0
fi

echo -e "${BLUE}📋 Creating sudoers configuration...${NC}"
echo "-------------------------------------------"

# Create sudoers file content
SUDOERS_CONTENT="# Passwordless Apache control for $CURRENT_USER
# Allows AI agent autonomous execution
# Created: $(date)
$CURRENT_USER ALL=(ALL) NOPASSWD: /usr/sbin/apachectl"

# Write to temporary file first
TMP_FILE="/tmp/sudoers-apache-$CURRENT_USER"
echo "$SUDOERS_CONTENT" > "$TMP_FILE"

# Validate syntax
if sudo visudo -c -f "$TMP_FILE" 2>&1 | grep -q "parsed OK"; then
    echo -e "${GREEN}✅ Syntax valid${NC}"
else
    echo -e "${RED}❌ Syntax error in sudoers file${NC}"
    sudo visudo -c -f "$TMP_FILE"
    rm "$TMP_FILE"
    exit 1
fi

# Move to sudoers.d
echo "Installing sudoers configuration..."
sudo cp "$TMP_FILE" "$SUDOERS_FILE"
sudo chmod 440 "$SUDOERS_FILE"
sudo chown root:wheel "$SUDOERS_FILE"
rm "$TMP_FILE"

echo -e "${GREEN}✅ Configuration installed${NC}"
echo ""

# Test it works
echo -e "${BLUE}🧪 Testing passwordless sudo...${NC}"
echo "-------------------------------------------"

if sudo -n apachectl -v &> /dev/null; then
    echo -e "${GREEN}✅ Passwordless sudo working!${NC}"
    echo ""
    echo "You can now run Apache commands without password:"
    echo "  sudo apachectl start"
    echo "  sudo apachectl stop"
    echo "  sudo apachectl restart"
else
    echo -e "${RED}❌ Test failed - password still required${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}🎉 Setup Complete!${NC}"
echo "=============================================="
echo ""
echo -e "${BLUE}📊 Configuration Details:${NC}"
echo "  File: $SUDOERS_FILE"
echo "  User: $CURRENT_USER"
echo "  Commands: apachectl only"
echo ""
echo -e "${BLUE}🤖 AI Agent Benefits:${NC}"
echo "  ✅ Can run apache-start autonomously"
echo "  ✅ Can run local-apache-start autonomously"
echo "  ✅ Can run setup-local-apache.sh autonomously"
echo "  ✅ No password prompts during execution"
echo ""
echo -e "${BLUE}🔐 Security:${NC}"
echo "  ✅ Only apachectl commands allowed"
echo "  ✅ No other sudo commands affected"
echo "  ✅ Standard practice for web development"
echo ""
echo -e "${YELLOW}💡 To remove this configuration:${NC}"
echo "  sudo rm $SUDOERS_FILE"
echo ""

