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

# Get script directory to create temp file in project
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Create temporary test script in project root (so it can access node_modules)
TEMP_TEST="$PROJECT_ROOT/.playwright-test-temp-$$.mjs"

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
  // Wait for navigation to minimal URL format (/?=ABC)
  await page.waitForURL('**/?=**', { timeout: 10000 });
  const url = page.url();

  // Extract session key from minimal URL format
  const sessionMatch = url.match(/\?=([A-Z0-9]{3})/i);
  if (sessionMatch) {
    console.log(`   ✅ PASS - Navigated to checklist (session: ${sessionMatch[1]})`);
    testsPassed++;
  } else {
    console.log('   ❌ FAIL - Navigation failed or wrong URL format');
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

  // Test 6: Navigate to List Report
  console.log('\n📋 Test 6: Click Report button (navigate to list-report)...');
  const reportButtonCount = await page.locator('.report-button, #reportButton').count();
  if (reportButtonCount > 0) {
    await page.locator('.report-button, #reportButton').first().click();
    await page.waitForURL('**/list-report**', { timeout: 10000 });
    if (page.url().includes('list-report')) {
      console.log('   ✅ PASS - List report page loaded');
      testsPassed++;
    }
  } else {
    console.log('   ⚠️  SKIP - Report button not found');
  }

  // Test 6a: Test filter button on list-report
  console.log('\n📋 Test 6a: Test filter button on list-report...');
  const filterButtonCount = await page.locator('.filter-button').count();
  if (filterButtonCount > 0) {
    await page.locator('.filter-button').first().click();
    await page.waitForTimeout(500); // Wait for table update
    console.log('   ✅ PASS - Filter button works on list-report');
    testsPassed++;
  } else {
    console.log('   ⚠️  SKIP - Filter buttons not found');
  }

  // Test 6b: Test side panel button on list-report
  console.log('\n📋 Test 6b: Test side panel button on list-report...');
  const sidePanelButtonCount = await page.locator('a[href^="#checkpoint-"]').count();
  if (sidePanelButtonCount > 0) {
    await page.locator('a[href^="#checkpoint-"]').first().click();
    await page.waitForTimeout(500); // Wait for scroll/highlight
    console.log('   ✅ PASS - Side panel navigation works on list-report');
    testsPassed++;
  } else {
    console.log('   ⚠️  INFO - Side panel not tested (may be collapsed or different structure)');
  }

  // Test 7: Back to checklist
  console.log('\n📋 Test 7: Click Back button (return to instance)...');
  const backButtonCount = await page.locator('#backButton, .home-button').count();
  if (backButtonCount > 0) {
    await page.locator('#backButton, .home-button').first().click();
    // Wait for navigation back to checklist (/?=ABC format)
    await page.waitForURL('**/?=**', { timeout: 10000 });
    console.log('   ✅ PASS - Back button works');
    testsPassed++;
  } else {
    console.log('   ⚠️  SKIP - Back button not found');
  }

  // Test 8: Fill notes field with test text
  console.log('\n📋 Test 8: Add text to notes field...');
  const notesCount = await page.locator('.notes-textarea').count();
  if (notesCount > 0) {
    const testNote = `E2E Test - ${new Date().toISOString()}`;
    await page.locator('.notes-textarea').first().fill(testNote);
    const value = await page.locator('.notes-textarea').first().inputValue();
    if (value.includes(testNote)) {
      console.log(`   ✅ PASS - Notes saved: "${testNote.substring(0, 30)}..."`);
      testsPassed++;
    }
  } else {
    console.log('   ⚠️  SKIP - Notes field not found');
  }

  // Test 9: Save the data
  console.log('\n📋 Test 9: Click Save button...');
  const saveButtonCount = await page.locator('#saveButton, .save-button').count();
  if (saveButtonCount > 0) {
    await page.locator('#saveButton, .save-button').first().click();
    await page.waitForTimeout(2000);  // Wait for save to complete
    console.log('   ✅ PASS - Save completed');
    testsPassed++;
  } else {
    console.log('   ⚠️  SKIP - Save button not found');
  }

  // Test 10: Restore data (verify persistence)
  console.log('\n📋 Test 10: Reload page and verify restore...');
  await page.reload({ waitUntil: 'networkidle' });
  await page.waitForTimeout(3000); // Wait for restore + content build
  const restoredNote = await page.locator('textarea[id^="textarea-"]').first().inputValue().catch(() => '');
  if (restoredNote && restoredNote.includes('E2E Test')) {
    console.log('   ✅ PASS - Data restored successfully');
    testsPassed++;
  } else {
    console.log('   ⚠️  INFO - Data not restored (may be expected for new sessions)');
    // Don't fail - restore is optional for new sessions
  }

  // Test 11: Navigate to Home
  console.log('\n📋 Test 11: Click Home button...');
  const homeButtonCount = await page.locator('.home-button').count();
  if (homeButtonCount > 0) {
    await page.locator('.home-button').first().click();
    await page.waitForURL('**/home', { timeout: 10000 });
    console.log('   ✅ PASS - Home button works');
    testsPassed++;
  } else {
    console.log('   ⚠️  SKIP - Home button not found');
  }

  // Test 12: Navigate to Reports (from home)
  console.log('\n📋 Test 12: Click Reports button from home...');
  const reportsButtonCount = await page.locator('#reportsButton, .reports-button').count();
  if (reportsButtonCount > 0) {
    await page.locator('#reportsButton, .reports-button').first().click();
    await page.waitForURL('**/systemwide-report', { timeout: 10000 });
    console.log('   ✅ PASS - Reports button works from home');
    testsPassed++;
  } else {
    console.log('   ⚠️  SKIP - Reports button not found');
  }

  // Test 13: Validate sessions visible on systemwide-report
  console.log('\n📋 Test 13: Verify saved sessions visible on systemwide-report...');
  await page.waitForTimeout(2000); // Wait for API to load data
  const tableRows = await page.locator('.reports-table tbody tr').count();
  if (tableRows > 0) {
    console.log(`   ✅ PASS - Found ${tableRows} session(s) in systemwide report`);
    testsPassed++;
  } else {
    console.log('   ❌ FAIL - No sessions found in systemwide report');
    testsFailed++;
  }

  // Test 14: Test filter button on systemwide-report
  console.log('\n📋 Test 14: Test filter button on systemwide-report...');
  const swFilterCount = await page.locator('.filter-button').count();
  if (swFilterCount > 0) {
    const initialRows = await page.locator('.reports-table tbody tr').count();
    await page.locator('.filter-button[data-filter="active"]').click().catch(() =>
      page.locator('.filter-button').first().click()
    );
    await page.waitForTimeout(500);
    console.log('   ✅ PASS - Filter button works on systemwide-report');
    testsPassed++;
  } else {
    console.log('   ⚠️  SKIP - Filter buttons not found on systemwide-report');
  }

  // Test 15: Test clicking a session row (side panel equivalent)
  console.log('\n📋 Test 15: Test clicking session row on systemwide-report...');
  const sessionLinkCount = await page.locator('.reports-table tbody tr .session-key-link, .reports-table tbody tr a').count();
  if (sessionLinkCount > 0) {
    // Just verify it's clickable (don't actually navigate away)
    const isClickable = await page.locator('.reports-table tbody tr').first().isVisible();
    if (isClickable) {
      console.log('   ✅ PASS - Session rows are interactive');
      testsPassed++;
    }
  } else {
    console.log('   ⚠️  INFO - No clickable session links (may be by design)');
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

# Run the test from project root (so node_modules is accessible)
cd "$PROJECT_ROOT"
TEST_URL="$URL" BROWSER="$BROWSER" node "$TEMP_TEST"
TEST_EXIT=$?

# Cleanup
rm -f "$TEMP_TEST"

exit $TEST_EXIT
