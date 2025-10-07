#!/bin/bash

# AI DRY (Don't Repeat Yourself) - Duplicate Code Detection
# Uses JSCPD to detect code duplication across the project

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo -e "${BLUE}🔍 AI DRY - Duplicate Code Detection${NC}"
echo -e "${BLUE}=====================================${NC}"
echo ""

# Check if jscpd is installed
if ! command -v jscpd &> /dev/null; then
    echo -e "${RED}❌ JSCPD not installed${NC}"
    echo -e "${YELLOW}💡 Installing JSCPD...${NC}"
    npm install -g jscpd
    echo ""
fi

# Create reports directory if it doesn't exist
mkdir -p "$PROJECT_ROOT/tests/reports/duplication"

echo -e "${CYAN}📊 Scanning project for duplicate code...${NC}"
echo -e "${YELLOW}Project: $PROJECT_ROOT${NC}"
echo ""

# Run JSCPD
cd "$PROJECT_ROOT"

# Run detection
jscpd "$PROJECT_ROOT" || true

echo ""
echo -e "${GREEN}✅ Duplicate code detection complete!${NC}"
echo ""

# Check if HTML report was generated
if [ -f "$PROJECT_ROOT/tests/reports/duplication/html/index.html" ]; then
    echo -e "${BLUE}📄 Reports generated:${NC}"
    echo -e "   ${CYAN}HTML Report:${NC} $PROJECT_ROOT/tests/reports/duplication/html/index.html"
    echo -e "   ${CYAN}JSON Report:${NC} $PROJECT_ROOT/tests/reports/duplication/jscpd-report.json"
    echo ""
    echo -e "${YELLOW}💡 Open HTML report in browser:${NC}"
    echo -e "   open $PROJECT_ROOT/tests/reports/duplication/html/index.html"
fi

echo ""
echo -e "${BLUE}📊 Summary:${NC}"

# Parse and display summary from JSON if available
if [ -f "$PROJECT_ROOT/tests/reports/duplication/jscpd-report.json" ]; then
    # Try to extract statistics using basic tools
    if command -v node &> /dev/null; then
        node -e "
        const fs = require('fs');
        const report = JSON.parse(fs.readFileSync('$PROJECT_ROOT/tests/reports/duplication/jscpd-report.json', 'utf8'));
        const stats = report.statistics;
        console.log('   Total Files Scanned: ' + stats.total.sources);
        console.log('   Files with Duplicates: ' + stats.total.clones);
        console.log('   Duplication Lines: ' + stats.total.duplicatedLines);
        console.log('   Duplication Percentage: ' + stats.total.percentage.toFixed(2) + '%');
        " 2>/dev/null || echo -e "   ${YELLOW}Check JSON report for detailed statistics${NC}"
    fi
fi

echo ""
echo -e "${GREEN}🎯 DRY Analysis Complete!${NC}"

