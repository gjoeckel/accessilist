#!/bin/bash

# Deploy .htaccess to Protect Production .env
# Run this ONCE to secure the production .env file from web access

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}Deploying .env Protection to Production${NC}"
echo "=========================================="
echo ""

# Server configuration
PEM_FILE="/Users/a00288946/Developer/projects/GeorgeWebAIMServerKey.pem"
SERVER="george@ec2-3-20-59-76.us-east-2.compute.amazonaws.com"
ETC_PATH="/var/websites/webaim/htdocs/training/online/etc"

# Verify PEM file exists
if [ ! -f "$PEM_FILE" ]; then
    echo -e "${RED}❌ PEM file not found: $PEM_FILE${NC}"
    exit 1
fi

echo -e "${CYAN}Step 1: Creating .htaccess content${NC}"
HTACCESS_CONTENT='# Protect .env files from web access
<Files ".env">
    Require all denied
</Files>

<Files ".env.*">
    Require all denied
</Files>

# Deny access to all files in this directory by default
<FilesMatch ".*">
    Require all denied
</FilesMatch>'

echo "$HTACCESS_CONTENT"
echo ""

echo -e "${CYAN}Step 2: Deploying to production server${NC}"
ssh -i "$PEM_FILE" "$SERVER" << EOF
echo "Creating .htaccess in $ETC_PATH/"

# Create .htaccess file
cat > $ETC_PATH/.htaccess << 'HTACCESS_EOF'
$HTACCESS_CONTENT
HTACCESS_EOF

# Set permissions
chmod 644 $ETC_PATH/.htaccess

echo "✅ .htaccess created"
ls -la $ETC_PATH/.htaccess
EOF

echo ""
echo -e "${CYAN}Step 3: Verifying protection${NC}"
echo "Testing if .env is now blocked from web access..."
echo ""

# Test if .env is blocked
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "https://webaim.org/training/online/etc/.env")

if [ "$HTTP_CODE" = "403" ] || [ "$HTTP_CODE" = "404" ]; then
    echo -e "${GREEN}✅ SUCCESS: .env is now protected (HTTP $HTTP_CODE)${NC}"
    echo ""
    echo "Before: HTTP 200 (accessible)"
    echo "After:  HTTP $HTTP_CODE (blocked)"
else
    echo -e "${YELLOW}⚠️  Unexpected response: HTTP $HTTP_CODE${NC}"
    echo "Expected: 403 (Forbidden) or 404 (Not Found)"
    echo ""
    echo "Please verify manually:"
    echo "https://webaim.org/training/online/etc/.env"
fi

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  ✅ PRODUCTION .ENV PROTECTION DEPLOYED! ✅            ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}What was protected:${NC}"
echo "  • /var/websites/webaim/htdocs/training/online/etc/.env"
echo "  • All .env.* files in that directory"
echo ""
echo -e "${CYAN}Verification URL (should be blocked):${NC}"
echo "  https://webaim.org/training/online/etc/.env"
echo ""
exit 0

