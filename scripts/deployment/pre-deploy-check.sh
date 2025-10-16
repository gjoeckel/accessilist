#!/bin/bash

# Pre-Deployment Validation Script
# Runs comprehensive checks before allowing deployment
# Integrates with production-mirror testing infrastructure

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

PROJECT_DIR="/Users/a00288946/Projects/accessilist"

echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║           Pre-Deployment Validation Check             ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

cd "$PROJECT_DIR"

# Check 1: Git Status
echo -e "${CYAN}[1/5] Checking Git Status...${NC}"
if [ -n "$(git status --porcelain)" ]; then
    echo -e "${YELLOW}⚠️  Uncommitted changes detected${NC}"
    echo ""
    git status --short
    echo ""
    echo -e "${YELLOW}Please commit or stash changes before deploying${NC}"
    exit 1
else
    echo -e "${GREEN}✅ Git status clean${NC}"
fi
echo ""

# Check 2: On correct branch
echo -e "${CYAN}[2/5] Checking Git Branch...${NC}"
CURRENT_BRANCH=$(git branch --show-current)
echo "Current branch: $CURRENT_BRANCH"

if [ "$CURRENT_BRANCH" != "main" ] && [ "$CURRENT_BRANCH" != "master" ]; then
    echo -e "${YELLOW}⚠️  Not on main/master branch${NC}"
    echo -e "${YELLOW}Production deployments should be from main/master${NC}"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${RED}Deployment cancelled${NC}"
        exit 1
    fi
fi
echo -e "${GREEN}✅ Branch check passed${NC}"
echo ""

# Check 3: Required files exist
echo -e "${CYAN}[3/5] Checking Required Files...${NC}"
REQUIRED_FILES=(
    ".env"
    ".htaccess"
    "index.php"
    "php/home.php"
    "php/systemwide-report.php"
    "php/list-report.php"
    "php/list.php"
    "php/api/save.php"
    "php/api/restore.php"
)

ALL_FILES_PRESENT=true
for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo -e "${RED}❌ Missing: $file${NC}"
        ALL_FILES_PRESENT=false
    fi
done

if [ "$ALL_FILES_PRESENT" = false ]; then
    echo -e "${RED}❌ Required files missing - cannot deploy${NC}"
    exit 1
fi
echo -e "${GREEN}✅ All required files present${NC}"
echo ""

# Check 4: Environment configuration
echo -e "${CYAN}[4/5] Checking Environment Configuration...${NC}"
if [ ! -f ".env" ]; then
    echo -e "${RED}❌ .env file missing${NC}"
    exit 1
fi

# Check current environment
CURRENT_ENV=$(grep "^APP_ENV=" .env | cut -d'=' -f2)
echo "Current environment: $CURRENT_ENV"

if [ "$CURRENT_ENV" = "production" ]; then
    echo -e "${YELLOW}⚠️  .env is set to production mode${NC}"
    echo -e "${YELLOW}Note: Production .env will be used on server${NC}"
elif [ "$CURRENT_ENV" = "apache-local" ]; then
    echo -e "${GREEN}✅ .env is set to apache-local (testing mode)${NC}"
    echo -e "${YELLOW}Note: Production .env exists separately on server${NC}"
elif [ "$CURRENT_ENV" = "local" ]; then
    echo -e "${GREEN}✅ .env is set to local mode${NC}"
    echo -e "${YELLOW}Note: Production .env exists separately on server${NC}"
fi
echo ""

# Check 5: Syntax and structure validation
echo -e "${CYAN}[5/5] Running Code Validation...${NC}"
echo -e "${BLUE}Checking PHP syntax and file structure${NC}"
echo ""

# Check PHP syntax for critical files
PHP_ERROR=false
for php_file in php/home.php php/systemwide-report.php php/list-report.php php/list.php; do
    if [ -f "$php_file" ]; then
        if ! php -l "$php_file" > /dev/null 2>&1; then
            echo -e "${RED}❌ Syntax error in $php_file${NC}"
            PHP_ERROR=true
        fi
    fi
done

if [ "$PHP_ERROR" = true ]; then
    echo -e "${RED}Deployment blocked - fix PHP syntax errors${NC}"
    exit 1
else
    echo -e "${GREEN}✅ PHP syntax valid${NC}"
fi

echo -e "${YELLOW}ℹ️  Skipping production-mirror tests (Docker-specific)${NC}"
echo -e "${CYAN}   Run 'proj-test-mirror' workflow to validate Docker Apache${NC}"
echo ""

# All checks passed
echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  ✅ PRE-DEPLOYMENT VALIDATION: ALL CHECKS PASSED  ✅   ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}Summary:${NC}"
echo "  ✅ Git status clean"
echo "  ✅ On deployable branch"
echo "  ✅ All required files present"
echo "  ✅ Environment configured"
echo "  ✅ PHP syntax valid"
echo ""
echo -e "${GREEN}🚀 Ready to deploy!${NC}"
echo ""
exit 0
