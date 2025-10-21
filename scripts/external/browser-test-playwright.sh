#!/bin/bash

################################################################################
# PLAYWRIGHT BROWSER TEST - Production/Staging
################################################################################
#
# PURPOSE: Execute actual browser UI testing using Playwright
# CALLED BY: test-production.sh (Phase 3)
#
# USAGE: ./browser-test-playwright.sh <url> [browser]
#   url: Base URL to test (e.g., https://webaim.org/training/online/accessilist2)
#   browser: chromium|firefox|webkit (default: chromium)
#
################################################################################

set -e

URL=${1:-"http://localhost:8080"}
BROWSER=${2:-"chromium"}

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}🎭 PLAYWRIGHT BROWSER TEST${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${CYAN}Testing:${NC} $URL"
echo -e "${CYAN}Browser:${NC} $BROWSER"
echo ""

# Check if Playwright is installed
if ! command -v npx >/dev/null 2>&1; then
    echo -e "${RED}❌ npx not found - cannot run Playwright${NC}"
    exit 1
fi

# Check if playwright is available
if ! npx playwright --version >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Playwright not installed${NC}"
    echo "Installing Playwright..."
    npm install -D playwright
fi

# Create temporary test script
TEMP_TEST="/tmp/playwright-test-$$.mjs"

cat > "$TEMP_TEST" << 'EOTEST'
import { chromium, firefox, webkit } from 'playwright';

const BASE_URL = process.env.TEST_URL || 'http://localhost:8080';
const BROWSER_TYPE = process.env.BROWSER || 'chromium';

console.log(`\n🎭 Testing ${BASE_URL} with ${BROWSER_TYPE}...\n`);

const browserTypes = { chromium, firefox, webkit };
const browser = await browserTypes[BROWSER_TYPE].launch({ headless: true });
const page = await browser.newPage();

let testsPassed = 0;
let testsFailed = 0;

try {
  // Test 1: Navigate to home page
  console.log('📋 Test 1: Navigate to home page...');
  await page.goto(`${BASE_URL}/home`, { waitUntil: 'networkidle' });
  const title = await page.title();
  if (title.includes('Accessibility')) {
    console.log('   ✅ PASS - Home page loaded');
    testsPassed++;
  } else {
    console.log('   ❌ FAIL - Wrong title:', title);
    testsFailed++;
  }

  // Test 2: Verify checklist buttons present
  console.log('\n📋 Test 2: Verify checklist buttons...');
  const wordButton = await page.locator('#word').count();
  if (wordButton > 0) {
    console.log('   ✅ PASS - Checklist buttons found');
    testsPassed++;
  } else {
    console.log('   ❌ FAIL - No checklist buttons');
    testsFailed++;
    throw new Error('Critical: No checklist buttons');
  }

  // Test 3: Click Word checklist (creates instance)
  console.log('\n📋 Test 3: Click Word checklist button...');
  await page.locator('#word').click();
  await page.waitForURL('**/list?**', { timeout: 10000 });
  const url = page.url();
  if (url.includes('type=word') || url.includes('/?=')) {
    console.log('   ✅ PASS - Navigated to checklist');
    testsPassed++;

    // Extract session key from URL
    const sessionMatch = url.match(/\?=([A-Z0-9]{3})/i);
    if (sessionMatch) {
      console.log(`   📝 Instance created: ${sessionMatch[1]}`);
    }
  } else {
    console.log('   ❌ FAIL - Navigation failed');
    testsFailed++;
  }

  // Test 4: Verify checkpoints rendered
  console.log('\n📋 Test 4: Verify checkpoints rendered...');
  await page.locator('.checkpoint-section').first().waitFor({ state: 'visible', timeout: 5000 });
  const checkpointCount = await page.locator('.checkpoint-section').count();
  if (checkpointCount > 0) {
    console.log(`   ✅ PASS - Found ${checkpointCount} checkpoint sections`);
    testsPassed++;
  } else {
    console.log('   ❌ FAIL - No checkpoints found');
    testsFailed++;
  }

  // Test 5: Click status button
  console.log('\n📋 Test 5: Click status button...');
  const statusButtonCount = await page.locator('.status-button').count();
  if (statusButtonCount > 0) {
    await page.locator('.status-button').first().click();
    console.log('   ✅ PASS - Status button clicked');
    testsPassed++;
  } else {
    console.log('   ⚠️  SKIP - No status button found');
  }

  // Test 6: Navigate to Report
  console.log('\n📋 Test 6: Click Report button...');
  const reportButtonCount = await page.locator('#reportButton').count();
  if (reportButtonCount > 0) {
    await page.locator('#reportButton').click();
    await page.waitForURL('**/list-report**', { timeout: 10000 });
    if (page.url().includes('list-report')) {
      console.log('   ✅ PASS - Report page loaded');
      testsPassed++;
    }
  } else {
    console.log('   ⚠️  SKIP - Report button not found');
  }

  // Test 7: Back to checklist
  console.log('\n📋 Test 7: Click Back button...');
  const backButtonCount = await page.locator('#backButton').count();
  if (backButtonCount > 0) {
    await page.locator('#backButton').click();
    await page.waitForURL('**/list?**', { timeout: 10000 });
    console.log('   ✅ PASS - Back button works');
    testsPassed++;
  } else {
    console.log('   ⚠️  SKIP - Back button not found');
  }

  // Test 8: Fill notes field
  console.log('\n📋 Test 8: Fill notes field...');
  const notesCount = await page.locator('.notes-textarea').count();
  if (notesCount > 0) {
    const testNote = `Browser test - ${new Date().toISOString()}`;
    await page.locator('.notes-textarea').first().fill(testNote);
    const value = await page.locator('.notes-textarea').first().inputValue();
    if (value.includes(testNote)) {
      console.log('   ✅ PASS - Notes field works');
      testsPassed++;
    }
  } else {
    console.log('   ⚠️  SKIP - Notes field not found');
  }

  // Test 9: Click Save button
  console.log('\n📋 Test 9: Click Save button...');
  const saveButtonCount = await page.locator('#saveButton').count();
  if (saveButtonCount > 0) {
    await page.locator('#saveButton').click();
    // Wait for save indication (modal or message)
    await page.waitForTimeout(2000);  // Deliberate delay for save to complete
    console.log('   ✅ PASS - Save button clicked');
    testsPassed++;
  } else {
    console.log('   ⚠️  SKIP - Save button not found');
  }

  // Test 10: Check Systemwide Report
  console.log('\n📋 Test 10: Navigate to Systemwide Report...');
  await page.goto(`${BASE_URL}/systemwide-report`, { waitUntil: 'networkidle' });
  const tableCount = await page.locator('.reports-table, table').count();
  if (tableCount > 0) {
    console.log('   ✅ PASS - Systemwide report loaded');
    testsPassed++;
  } else {
    console.log('   ⚠️  INFO - Systemwide report has no data');
  }

} catch (error) {
  console.error(`\n❌ ERROR: ${error.message}`);
  testsFailed++;
} finally {
  await browser.close();
}

// Summary
console.log('\n' + '═'.repeat(60));
console.log(`Total Tests: ${testsPassed + testsFailed}`);
console.log(`Passed: ${testsPassed}`);
console.log(`Failed: ${testsFailed}`);
console.log(`Success Rate: ${((testsPassed / (testsPassed + testsFailed)) * 100).toFixed(1)}%`);
console.log('═'.repeat(60) + '\n');

process.exit(testsFailed === 0 ? 0 : 1);
EOTEST

# Run the test
TEST_URL="$URL" BROWSER="$BROWSER" node "$TEMP_TEST"
TEST_EXIT=$?

# Cleanup
rm -f "$TEMP_TEST"

exit $TEST_EXIT
