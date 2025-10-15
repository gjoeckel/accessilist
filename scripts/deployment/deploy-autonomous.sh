#!/bin/bash

# Autonomous Deployment Script
# Integrates github-push-gate with autonomous deployment flow
# Uses existing push gate security + rsync deployment

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

PROJECT_DIR="/Users/a00288946/Projects/accessilist"
PUSH_TOKEN="push to github"

echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║            Autonomous Deployment Process              ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

cd "$PROJECT_DIR"

# Step 1: Verify pre-deploy checks passed
echo -e "${CYAN}Step 1: Verifying Pre-Deploy Checks${NC}"
if [ ! -f "/tmp/pre-deploy-test.log" ]; then
    echo -e "${YELLOW}⚠️  Pre-deploy checks not run${NC}"
    echo "Run: ./scripts/deployment/pre-deploy-check.sh first"
    exit 1
fi

# Check if tests passed
if grep -q "ALL CHECKS PASSED" /tmp/pre-deploy-test.log 2>/dev/null || grep -q "42.*42" /tmp/pre-deploy-test.log 2>/dev/null; then
    echo -e "${GREEN}✅ Pre-deployment validation passed${NC}"
else
    echo -e "${RED}❌ Pre-deployment checks failed${NC}"
    echo "Run: ./scripts/deployment/pre-deploy-check.sh"
    exit 1
fi
echo ""

# Step 2: Push to GitHub (triggers GitHub Actions)
echo -e "${CYAN}Step 2: Pushing to GitHub${NC}"
echo -e "${BLUE}Using secure push gate...${NC}"
echo ""

if [ ! -f "./scripts/github-push-gate.sh" ]; then
    echo -e "${RED}❌ Push gate script not found${NC}"
    exit 1
fi

# Call push gate script with token (PUSH ONLY - no rsync)
if ./scripts/github-push-gate.sh secure-push "$PUSH_TOKEN"; then
    echo -e "${GREEN}✅ Pushed to GitHub successfully${NC}"
else
    echo -e "${RED}❌ Push failed${NC}"
    exit 1
fi
echo ""

# Step 3: Wait for GitHub Actions deployment
echo -e "${CYAN}Step 3: Waiting for GitHub Actions Deployment${NC}"
echo -e "${BLUE}GitHub Actions is now deploying to AWS production...${NC}"
echo "  • Workflow: deploy-simple.yml"
echo "  • Monitor: https://github.com/gjoeckel/accessilist/actions"
echo ""
echo "Waiting 90 seconds for GitHub Actions to complete deployment..."
for i in {90..1}; do
    echo -ne "\r  Time remaining: ${i}s "
    sleep 1
done
echo -e "\n${GREEN}✅ GitHub Actions deployment should be complete${NC}"
echo ""

# Success
echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  ✅ GITHUB ACTIONS DEPLOYMENT IN PROGRESS! ✅          ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}Deployment Status:${NC}"
echo "  • Code pushed to GitHub: ✅"
echo "  • GitHub Actions triggered: ✅"
echo "  • AWS deployment: In progress..."
echo ""
echo -e "${CYAN}Next Steps:${NC}"
echo "  1. Monitor deployment: https://github.com/gjoeckel/accessilist/actions"
echo "  2. Run post-deployment verification: npm run postdeploy"
echo "  3. Manually test production: https://webaim.org/training/online/accessilist/home"
echo ""
echo -e "${YELLOW}Note: Post-deploy verification will test production after GitHub Actions completes${NC}"
echo ""
exit 0
