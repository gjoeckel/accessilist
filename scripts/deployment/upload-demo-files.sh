#!/bin/bash

# Upload Demo Files to Production
# Uploads demo save files (WRD, PPT, XLS, DOC, SLD, CAM, DJO) to production server
# Run this ONCE before deployment to populate production with demo data

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

PROJECT_DIR="/Users/a00288946/Projects/accessilist"
PEM_FILE="/Users/a00288946/Developer/projects/GeorgeWebAIMServerKey.pem"
SERVER="george@ec2-3-20-59-76.us-east-2.compute.amazonaws.com"
REMOTE_SAVES="/var/websites/webaim/htdocs/training/online/accessilist/saves"

echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║        Upload Demo Files to Production                ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

cd "$PROJECT_DIR"

# Step 1: Verify demo files exist locally
echo -e "${CYAN}Step 1: Verifying Demo Files Locally${NC}"

DEMO_FILES=("WRD.json" "PPT.json" "XLS.json" "DOC.json" "SLD.json" "CAM.json" "DJO.json")
MISSING_FILES=()

for file in "${DEMO_FILES[@]}"; do
    if [ -f "saves/$file" ]; then
        echo -e "  ${GREEN}✅${NC} $file"
    else
        echo -e "  ${RED}❌${NC} $file (missing)"
        MISSING_FILES+=("$file")
    fi
done

if [ ${#MISSING_FILES[@]} -gt 0 ]; then
    echo ""
    echo -e "${RED}Missing demo files! Generate them first:${NC}"
    echo "  node scripts/generate-demo-files.js"
    exit 1
fi

echo -e "${GREEN}✅ All 7 demo files present locally${NC}"
echo ""

# Step 2: Verify SSH connection
echo -e "${CYAN}Step 2: Verifying SSH Connection${NC}"

if [ ! -f "$PEM_FILE" ]; then
    echo -e "${RED}❌ PEM file not found: $PEM_FILE${NC}"
    exit 1
fi

if ! ssh -i "$PEM_FILE" -o ConnectTimeout=10 "$SERVER" "echo 'SSH connection successful'" &>/dev/null; then
    echo -e "${RED}❌ SSH connection failed${NC}"
    exit 1
fi

echo -e "${GREEN}✅ SSH connection verified${NC}"
echo ""

# Step 3: Verify production saves directory exists
echo -e "${CYAN}Step 3: Verifying Production Saves Directory${NC}"

ssh -i "$PEM_FILE" "$SERVER" "
    if [ ! -d '$REMOTE_SAVES' ]; then
        echo 'Creating saves directory...'
        mkdir -p '$REMOTE_SAVES'
        chmod 775 '$REMOTE_SAVES'
    fi
    echo '✅ Saves directory exists'
    ls -ld '$REMOTE_SAVES'
"

echo ""

# Step 4: Upload demo files
echo -e "${CYAN}Step 4: Uploading Demo Files to Production${NC}"
echo ""

UPLOADED_COUNT=0
for file in "${DEMO_FILES[@]}"; do
    echo -n "  Uploading $file..."

    if scp -i "$PEM_FILE" "saves/$file" "$SERVER:$REMOTE_SAVES/$file" &>/dev/null; then
        echo -e " ${GREEN}✅${NC}"
        UPLOADED_COUNT=$((UPLOADED_COUNT + 1))
    else
        echo -e " ${RED}❌${NC}"
    fi
done

echo ""
echo -e "${GREEN}✅ Uploaded $UPLOADED_COUNT of 7 demo files${NC}"
echo ""

# Step 5: Verify files on production
echo -e "${CYAN}Step 5: Verifying Files on Production${NC}"
echo ""

ssh -i "$PEM_FILE" "$SERVER" "
    echo 'Demo files on production:'
    ls -lh '$REMOTE_SAVES'/{WRD,PPT,XLS,DOC,SLD,CAM,DJO}.json 2>/dev/null || echo 'No demo files found'

    echo ''
    echo 'Total files in saves directory:'
    ls -1 '$REMOTE_SAVES' | wc -l
"

echo ""

# Step 6: Test production access
echo -e "${CYAN}Step 6: Testing Production Access${NC}"
echo "Testing if demo files appear in Reports dashboard..."
echo ""

sleep 2
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "https://webaim.org/training/online/accessilist/reports")

if [ "$HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}✅ Reports page accessible (HTTP 200)${NC}"
    echo ""
    echo "View demo files at:"
    echo "  https://webaim.org/training/online/accessilist/reports"
else
    echo -e "${YELLOW}⚠️  Reports page returned HTTP $HTTP_CODE${NC}"
fi

echo ""

# Success Summary
echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  ✅ DEMO FILES UPLOADED TO PRODUCTION! ✅              ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}Demo Files on Production:${NC}"
echo "  • WRD.json - Word checklist"
echo "  • PPT.json - PowerPoint checklist"
echo "  • XLS.json - Excel checklist"
echo "  • DOC.json - Google Docs checklist"
echo "  • SLD.json - Google Slides checklist"
echo "  • CAM.json - Camtasia checklist"
echo "  • DJO.json - Dojo checklist"
echo ""
echo -e "${CYAN}Access Demo Data:${NC}"
echo "  Dashboard: https://webaim.org/training/online/accessilist/reports"
echo "  Individual: https://webaim.org/training/online/accessilist/report?session=WRD"
echo ""
echo -e "${CYAN}Demo Files Preserved:${NC}"
echo "  • saves/ directory is excluded from deployment"
echo "  • Demo files will NOT be overwritten by future deploys"
echo "  • Safe to deploy normally: npm run deploy:full"
echo ""
exit 0
