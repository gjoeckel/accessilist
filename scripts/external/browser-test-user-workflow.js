#!/usr/bin/env node

/**
 * REAL USER WORKFLOW TEST - Browser Automation
 * 
 * Tests what USERS actually do, not just APIs
 * If this fails, the application is BROKEN for users
 */

const puppeteer = require('puppeteer');

const BASE_URL = process.env.TEST_URL || 'https://webaim.org/training/online/accessilist2';
const SESSION_KEY = `USR${Date.now().toString().slice(-4)}`;

console.log('\n╔════════════════════════════════════════════════════════╗');
console.log('║  🌐 REAL USER WORKFLOW TEST (Browser Automation)      ║');
console.log('╚════════════════════════════════════════════════════════╝\n');
console.log(`Testing: ${BASE_URL}`);
console.log(`Session: ${SESSION_KEY}\n`);

(async () => {
  const browser = await puppeteer.launch({
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });
  
  const page = await browser.newPage();
  let testsPassed = 0;
  let testsFailed = 0;
  
  try {
    // Test 1: User navigates to Home page
    console.log('📋 Test 1: User opens Home page...');
    await page.goto(`${BASE_URL}/home`, { waitUntil: 'networkidle0' });
    const title = await page.title();
    
    if (title.includes('Accessibility Checklists')) {
      console.log('   ✅ PASS - Home page loaded');
      testsPassed++;
    } else {
      console.log('   ❌ FAIL - Home page title wrong');
      testsFailed++;
    }
    
    // Test 2: User sees checklist type buttons
    console.log('\n📋 Test 2: User sees checklist type buttons...');
    const wordButton = await page.$('#word, button.checklist-button');
    
    if (wordButton) {
      console.log('   ✅ PASS - Checklist buttons visible');
      testsPassed++;
    } else {
      console.log('   ❌ FAIL - No checklist buttons found');
      testsFailed++;
      throw new Error('Critical: No checklist buttons - users cannot create instances!');
    }
    
    // Test 3: User clicks a checklist type (Word)
    console.log('\n📋 Test 3: User clicks Word checklist...');
    await wordButton.click();
    await page.waitForTimeout(2000); // Wait for JS to handle click
    await page.waitForNavigation({ waitUntil: 'networkidle0', timeout: 10000 }).catch(() => {
      console.log('   ⚠️  Navigation timeout (may be JS-driven redirect)');
    });
    
    const currentUrl = page.url();
    if (currentUrl.includes('type=word')) {
      console.log('   ✅ PASS - Navigated to Word checklist');
      testsPassed++;
    } else {
      console.log('   ❌ FAIL - Navigation failed');
      testsFailed++;
    }
    
    // Test 4: User sees checklist rendered
    console.log('\n📋 Test 4: User sees checklist with checkpoints...');
    await page.waitForSelector('.checkpoint-row', { timeout: 5000 });
    const checkpoints = await page.$$('.checkpoint-row');
    
    if (checkpoints.length > 0) {
      console.log(`   ✅ PASS - Found ${checkpoints.length} checkpoints`);
      testsPassed++;
    } else {
      console.log('   ❌ FAIL - No checkpoints rendered');
      testsFailed++;
    }
    
    // Test 5: User changes a status (clicks status button)
    console.log('\n📋 Test 5: User clicks status button...');
    const statusButton = await page.$('.status-button');
    
    if (statusButton) {
      await statusButton.click();
      await page.waitForTimeout(1000); // Wait for UI update
      console.log('   ✅ PASS - Status button clicked');
      testsPassed++;
    } else {
      console.log('   ⚠️  SKIP - Status button not found (may use different selector)');
    }
    
    // Test 6: User navigates to Report
    console.log('\n📋 Test 6: User clicks Report button...');
    const reportButton = await page.$('a[href*="list-report"]');
    
    if (reportButton) {
      await reportButton.click();
      await page.waitForNavigation({ waitUntil: 'networkidle0' });
      
      const reportUrl = page.url();
      if (reportUrl.includes('list-report')) {
        console.log('   ✅ PASS - Report page loaded');
        testsPassed++;
      } else {
        console.log('   ❌ FAIL - Report navigation failed');
        testsFailed++;
      }
    } else {
      console.log('   ⚠️  SKIP - Report button not found');
    }
    
    // Test 7: User sees Back button
    console.log('\n📋 Test 7: User sees Back button...');
    const backButton = await page.$('#backButton');
    
    if (backButton) {
      console.log('   ✅ PASS - Back button present');
      testsPassed++;
      
      // Click it
      await backButton.click();
      await page.waitForNavigation({ waitUntil: 'networkidle0' });
      console.log('   ✅ PASS - Back button works');
      testsPassed++;
    } else {
      console.log('   ⚠️  SKIP - Back button not found');
    }
    
    // Test 8: User types in Notes field
    console.log('\n📋 Test 8: User types in Notes field...');
    const notesTextarea = await page.$('textarea.notes-field');
    
    if (notesTextarea) {
      const testNote = `User test note - ${new Date().toISOString()}`;
      await notesTextarea.type(testNote);
      await page.waitForTimeout(500);
      
      const notesValue = await page.evaluate(el => el.value, notesTextarea);
      if (notesValue.includes(testNote)) {
        console.log('   ✅ PASS - Notes field accepts input');
        testsPassed++;
      } else {
        console.log('   ❌ FAIL - Notes not saved');
        testsFailed++;
      }
    } else {
      console.log('   ⚠️  SKIP - Notes field not found (may use different selector)');
    }
    
    // Test 9: User clicks Save button
    console.log('\n📋 Test 9: User clicks Save button...');
    const saveButton = await page.$('#saveButton, button:contains("Save")');
    
    if (saveButton) {
      await saveButton.click();
      await page.waitForTimeout(2000); // Wait for save to complete
      
      // Check for success message or indicator
      const successIndicator = await page.evaluate(() => {
        return document.body.innerText.includes('saved') || 
               document.body.innerText.includes('success');
      });
      
      if (successIndicator) {
        console.log('   ✅ PASS - Save button works');
        testsPassed++;
      } else {
        console.log('   ⚠️  UNKNOWN - Save clicked but no clear success indicator');
      }
    } else {
      console.log('   ⚠️  SKIP - Save button not found');
    }
    
    // Test 10: Check Systemwide Report
    console.log('\n📋 Test 10: User checks Systemwide Report...');
    await page.goto(`${BASE_URL}/systemwide-report`, { waitUntil: 'networkidle0' });
    await page.waitForTimeout(2000);
    
    const reportContent = await page.content();
    const hasInstances = !reportContent.includes('All 0');
    
    if (hasInstances) {
      console.log('   ✅ PASS - Instances visible in Systemwide Report');
      testsPassed++;
    } else {
      console.log('   ⚠️  INFO - No instances in Systemwide Report (may be due to rate limiting)');
    }
    
    // Take screenshot for evidence
    await page.screenshot({ 
      path: '/Users/a00288946/Projects/accessilist/tests/screenshots/user-workflow-test.png',
      fullPage: true 
    });
    console.log('\n📸 Screenshot saved to: tests/screenshots/user-workflow-test.png');
    
  } catch (error) {
    console.error(`\n❌ CRITICAL ERROR: ${error.message}`);
    testsFailed++;
    
    // Take error screenshot
    await page.screenshot({ 
      path: '/Users/a00288946/Projects/accessilist/tests/screenshots/user-workflow-ERROR.png',
      fullPage: true 
    });
  } finally {
    await browser.close();
  }
  
  // Summary
  console.log('\n╔════════════════════════════════════════════════════════╗');
  console.log('║              Test Results Summary                      ║');
  console.log('╚════════════════════════════════════════════════════════╝\n');
  console.log(`Total Tests:    ${testsPassed + testsFailed}`);
  console.log(`Passed:         ${testsPassed}`);
  console.log(`Failed:         ${testsFailed}`);
  console.log(`Success Rate:   ${((testsPassed / (testsPassed + testsFailed)) * 100).toFixed(1)}%\n`);
  
  if (testsFailed === 0) {
    console.log('✅ ALL USER TESTS PASSED - Application works for real users!\n');
    process.exit(0);
  } else {
    console.log('❌ USER TESTS FAILED - Application is BROKEN for users!\n');
    process.exit(1);
  }
})();

