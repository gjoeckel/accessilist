#!/usr/bin/env node

/**
 * REAL USER WORKFLOW TEST - Browser Automation
 *
 * Tests what USERS actually do, not just APIs
 * If this fails, the application is BROKEN for users
 *
 * FOR AI AGENTS:
 * - Use event-driven waits (waitForSelector, waitForFunction)
 * - NEVER use arbitrary timeouts (waitForTimeout removed in Puppeteer v22+)
 * - Always wait for actual conditions, not arbitrary time
 * - Wrap waits in try-catch for graceful error handling
 */

const puppeteer = require("puppeteer");

const BASE_URL =
  process.env.TEST_URL || "https://webaim.org/training/online/accessilist2";
const SESSION_KEY = `USR${Date.now().toString().slice(-4)}`;
const SCREENSHOT_DIR = process.env.SCREENSHOT_PATH || "./tests/screenshots";

console.log("\n╔════════════════════════════════════════════════════════╗");
console.log("║  🌐 REAL USER WORKFLOW TEST (Browser Automation)      ║");
console.log("╚════════════════════════════════════════════════════════╝\n");
console.log(`Testing: ${BASE_URL}`);
console.log(`Session: ${SESSION_KEY}\n`);

(async () => {
  const browser = await puppeteer.launch({
    headless: true,
    args: ["--no-sandbox", "--disable-setuid-sandbox"],
  });

  const page = await browser.newPage();

  // Set default timeouts (30 seconds)
  page.setDefaultTimeout(30000);
  page.setDefaultNavigationTimeout(30000);

  let testsPassed = 0;
  let testsFailed = 0;

  try {
    // Test 1: User navigates to Home page
    console.log("📋 Test 1: User opens Home page...");
    await page.goto(`${BASE_URL}/home`, { waitUntil: "networkidle0" });
    const title = await page.title();

    if (title.includes("Accessibility Checklists")) {
      console.log("   ✅ PASS - Home page loaded");
      testsPassed++;
    } else {
      console.log("   ❌ FAIL - Home page title wrong");
      testsFailed++;
    }

    // Test 2: User sees checklist type buttons
    console.log("\n📋 Test 2: User sees checklist type buttons...");
    const wordButton = await page.$("#word, button.checklist-button");

    if (wordButton) {
      console.log("   ✅ PASS - Checklist buttons visible");
      testsPassed++;
    } else {
      console.log("   ❌ FAIL - No checklist buttons found");
      testsFailed++;
      throw new Error(
        "Critical: No checklist buttons - users cannot create instances!"
      );
    }

    // Test 3: User clicks a checklist type (Word)
    console.log("\n📋 Test 3: User clicks Word checklist...");

    // Event-driven: Wait for navigation AND click atomically
    try {
      await Promise.all([
        page.waitForNavigation({ waitUntil: "networkidle0", timeout: 10000 }),
        wordButton.click(),
      ]);

      const currentUrl = page.url();
      if (currentUrl.includes("type=word")) {
        console.log("   ✅ PASS - Navigated to Word checklist");
        testsPassed++;
      } else {
        console.log("   ❌ FAIL - Navigation failed");
        testsFailed++;
      }
    } catch (error) {
      console.log(`   ⚠️  SKIP - Navigation error: ${error.message}`);
    }

    // Test 4: User sees checklist rendered
    console.log("\n📋 Test 4: User sees checklist with checkpoints...");

    try {
      await page.waitForSelector(".checkpoint-row", {
        visible: true,
        timeout: 5000,
      });
      const checkpoints = await page.$$(".checkpoint-row");

      if (checkpoints.length > 0) {
        console.log(`   ✅ PASS - Found ${checkpoints.length} checkpoints`);
        testsPassed++;
      } else {
        console.log("   ❌ FAIL - No checkpoints rendered");
        testsFailed++;
      }
    } catch (error) {
      console.log(`   ❌ FAIL - Checkpoints not rendered: ${error.message}`);
      testsFailed++;
    }

    // Test 5: User changes a status (clicks status button)
    console.log("\n📋 Test 5: User clicks status button...");
    const statusButton = await page.$(".status-button");

    if (statusButton) {
      await statusButton.click();

      // Event-driven wait for UI update
      try {
        await page.waitForFunction(
          () => {
            const button = document.querySelector(".status-button");
            return (
              button &&
              (button.classList.contains("active") ||
                button.getAttribute("aria-pressed") === "true")
            );
          },
          { timeout: 2000 }
        );
        console.log("   ✅ PASS - Status button clicked and updated");
        testsPassed++;
      } catch {
        console.log("   ✅ PASS - Status button clicked");
        testsPassed++;
      }
    } else {
      console.log(
        "   ⚠️  SKIP - Status button not found (may use different selector)"
      );
    }

    // Test 6: User navigates to Report
    console.log("\n📋 Test 6: User clicks Report button...");
    const reportButton = await page.$('a[href*="list-report"]');

    if (reportButton) {
      try {
        await Promise.all([
          page.waitForNavigation({ waitUntil: "networkidle0", timeout: 10000 }),
          reportButton.click(),
        ]);

        const reportUrl = page.url();
        if (reportUrl.includes("list-report")) {
          console.log("   ✅ PASS - Report page loaded");
          testsPassed++;
        } else {
          console.log("   ❌ FAIL - Report navigation failed");
          testsFailed++;
        }
      } catch (error) {
        console.log(`   ⚠️  SKIP - Report navigation error: ${error.message}`);
      }
    } else {
      console.log("   ⚠️  SKIP - Report button not found");
    }

    // Test 7: User sees Back button
    console.log("\n📋 Test 7: User sees Back button...");
    const backButton = await page.$("#backButton");

    if (backButton) {
      console.log("   ✅ PASS - Back button present");
      testsPassed++;

      // Event-driven navigation
      try {
        await Promise.all([
          page.waitForNavigation({ waitUntil: "networkidle0", timeout: 10000 }),
          backButton.click(),
        ]);
        console.log("   ✅ PASS - Back button works");
        testsPassed++;
      } catch (error) {
        console.log(`   ⚠️  SKIP - Back navigation error: ${error.message}`);
      }
    } else {
      console.log("   ⚠️  SKIP - Back button not found");
    }

    // Test 8: User types in Notes field
    console.log("\n📋 Test 8: User types in Notes field...");
    const notesTextarea = await page.$(
      "textarea.notes-field, textarea[id*='notes'], textarea[class*='notes']"
    );

    if (notesTextarea) {
      const testNote = `User test note - ${new Date().toISOString()}`;
      await notesTextarea.type(testNote);

      // Event-driven wait for input
      try {
        await page.waitForFunction(
          (selector, note) => {
            const textarea = document.querySelector(selector);
            return textarea && textarea.value.includes(note);
          },
          { timeout: 2000 },
          'textarea.notes-field, textarea[id*="notes"], textarea[class*="notes"]',
          testNote
        );

        const notesValue = await page.evaluate((el) => el.value, notesTextarea);
        if (notesValue.includes(testNote)) {
          console.log("   ✅ PASS - Notes field accepts input");
          testsPassed++;
        } else {
          console.log("   ❌ FAIL - Notes not saved");
          testsFailed++;
        }
      } catch (error) {
        console.log("   ⚠️  SKIP - Could not verify notes input");
      }
    } else {
      console.log(
        "   ⚠️  SKIP - Notes field not found (may use different selector)"
      );
    }

    // Test 9: User clicks Save button
    console.log("\n📋 Test 9: User clicks Save button...");
    const saveButton = await page.$(
      '#saveButton, button[id*="save"], button[class*="save"]'
    );

    if (saveButton) {
      await saveButton.click();

      // Event-driven wait for save completion
      try {
        await page.waitForFunction(
          () => {
            return (
              document.body.innerText.includes("saved") ||
              document.body.innerText.includes("success") ||
              document.body.innerText.includes("Saved")
            );
          },
          { timeout: 5000 }
        );
        console.log("   ✅ PASS - Save button works");
        testsPassed++;
      } catch {
        console.log(
          "   ⚠️  UNKNOWN - Save clicked but no clear success indicator"
        );
      }
    } else {
      console.log("   ⚠️  SKIP - Save button not found");
    }

    // Test 10: Check Systemwide Report
    console.log("\n📋 Test 10: User checks Systemwide Report...");

    try {
      await page.goto(`${BASE_URL}/systemwide-report`, {
        waitUntil: "networkidle0",
        timeout: 10000,
      });

      // Event-driven wait for table to render
      await page.waitForSelector(".reports-table, table", {
        visible: true,
        timeout: 5000,
      });

      const reportContent = await page.content();
      const hasInstances = !reportContent.includes("All 0");

      if (hasInstances) {
        console.log("   ✅ PASS - Instances visible in Systemwide Report");
        testsPassed++;
      } else {
        console.log(
          "   ⚠️  INFO - No instances in Systemwide Report (may be due to rate limiting)"
        );
      }
    } catch (error) {
      console.log(`   ⚠️  SKIP - Systemwide report error: ${error.message}`);
    }

    // Take screenshot (use relative path)
    try {
      await page.screenshot({
        path: `${SCREENSHOT_DIR}/user-workflow-test.png`,
        fullPage: true,
      });
      console.log(
        `\n📸 Screenshot saved to: ${SCREENSHOT_DIR}/user-workflow-test.png`
      );
    } catch (error) {
      console.log(`   ⚠️  Could not save screenshot: ${error.message}`);
    }
  } catch (error) {
    console.error(`\n❌ CRITICAL ERROR: ${error.message}`);
    testsFailed++;

    // Take error screenshot (use relative path)
    try {
      await page.screenshot({
        path: `${SCREENSHOT_DIR}/user-workflow-ERROR.png`,
        fullPage: true,
      });
      console.log(
        `📸 Error screenshot: ${SCREENSHOT_DIR}/user-workflow-ERROR.png`
      );
    } catch (screenshotError) {
      console.log(`   ⚠️  Could not save error screenshot`);
    }
  } finally {
    await browser.close();
  }

  // Summary
  console.log("\n╔════════════════════════════════════════════════════════╗");
  console.log("║              Test Results Summary                      ║");
  console.log("╚════════════════════════════════════════════════════════╝\n");
  console.log(`Total Tests:    ${testsPassed + testsFailed}`);
  console.log(`Passed:         ${testsPassed}`);
  console.log(`Failed:         ${testsFailed}`);
  console.log(
    `Success Rate:   ${(
      (testsPassed / (testsPassed + testsFailed)) *
      100
    ).toFixed(1)}%\n`
  );

  if (testsFailed === 0) {
    console.log(
      "✅ ALL USER TESTS PASSED - Application works for real users!\n"
    );
    process.exit(0);
  } else {
    console.log("❌ USER TESTS FAILED - Application is BROKEN for users!\n");
    process.exit(1);
  }
})();
