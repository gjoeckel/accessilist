#!/usr/bin/env node

/**
 * Critical Path Tests for AccessiList
 * Tests the most important user journeys end-to-end
 */

const { chromium } = require("playwright");
const TestUtils = require("./test-utils");
const TEST_CONFIG = require("./test-config");

class CriticalPathTests {
  constructor() {
    this.browser = null;
    this.page = null;
    this.utils = null;
    this.testResults = [];
  }

  /**
   * Setup browser and page
   */
  async setup() {
    this.browser = await chromium.launch(TEST_CONFIG.browser);
    this.page = await this.browser.newPage();
    this.utils = new TestUtils(this.page);

    // Set viewport
    await this.page.setViewportSize(TEST_CONFIG.browser.viewport);

    this.utils.logStep("Browser setup complete");
  }

  /**
   * Cleanup browser
   */
  async cleanup() {
    if (this.browser) {
      await this.browser.close();
    }
  }

  /**
   * Test 1: Home to Checklist Journey
   */
  async testHomeToChecklistJourney() {
    this.utils.logStep("Testing home to checklist journey");

    try {
      // Navigate to home page
      await this.utils.navigateToPage(TEST_CONFIG.pages.home);
      await this.utils.screenshot("home-page-loaded");

      // Verify home page elements
      await this.utils.assertElementVisible(TEST_CONFIG.selectors.header);
      await this.utils.assertElementVisible(TEST_CONFIG.selectors.adminButton);

      // Click on a checklist type (Word)
      const wordChecklistLink = await this.page
        .locator('a[href*="word"]')
        .first();
      if ((await wordChecklistLink.count()) > 0) {
        await wordChecklistLink.click();
        await this.utils.waitForLoadingComplete();
        await this.utils.screenshot("checklist-page-loaded");

        // Verify we're on checklist page
        await this.utils.assertUrlContains("list.php");
        await this.utils.assertElementVisible(TEST_CONFIG.selectors.saveButton);

        this.testResults.push({
          test: "Home to Checklist Journey",
          status: "PASSED",
        });
      } else {
        throw new Error("Word checklist link not found");
      }
    } catch (error) {
      this.testResults.push({
        test: "Home to Checklist Journey",
        status: "FAILED",
        error: error.message,
      });
      await this.utils.screenshot("home-to-checklist-error");
    }
  }

  /**
   * Test 2: Checklist Interaction
   */
  async testChecklistInteraction() {
    this.utils.logStep("Testing checklist interaction");

    try {
      // Navigate to checklist page
      await this.utils.navigateToPage(
        `${TEST_CONFIG.pages.checklist}?type=word`
      );
      await this.utils.waitForLoadingComplete();
      await this.utils.screenshot("checklist-interaction-start");

      // Wait for checklist items to load
      await this.utils.waitForElement(".checklist-item", 10000);

      // Find and click a checklist item
      const firstItem = await this.page.locator(".checklist-item").first();
      if ((await firstItem.count()) > 0) {
        await firstItem.click();
        await this.utils.screenshot("checklist-item-clicked");

        // Verify item state changed
        const isChecked = await firstItem.getAttribute("data-checked");
        if (isChecked === "true") {
          this.testResults.push({
            test: "Checklist Interaction",
            status: "PASSED",
          });
        } else {
          throw new Error("Checklist item state did not change");
        }
      } else {
        throw new Error("No checklist items found");
      }
    } catch (error) {
      this.testResults.push({
        test: "Checklist Interaction",
        status: "FAILED",
        error: error.message,
      });
      await this.utils.screenshot("checklist-interaction-error");
    }
  }

  /**
   * Test 3: Save and Restore Functionality
   */
  async testSaveRestoreFunctionality() {
    this.utils.logStep("Testing save and restore functionality");

    const sessionKey = this.utils.generateSessionKey();

    try {
      // Navigate to checklist
      await this.utils.navigateToPage(
        `${TEST_CONFIG.pages.checklist}?type=word&sessionKey=${sessionKey}`
      );
      await this.utils.waitForLoadingComplete();
      await this.utils.screenshot("save-restore-start");

      // Create test data
      const testData = this.utils.createTestData(sessionKey, "word");

      // Instantiate checklist
      const instantiateResponse = await this.utils.apiCall(
        TEST_CONFIG.api.instantiate,
        "POST",
        testData
      );

      if (instantiateResponse.success) {
        // Modify checklist state
        testData.state.items = [{ id: "test-item", checked: true }];
        testData.state.notes = { "test-item": "Test note" };

        // Save checklist
        const saveResponse = await this.utils.apiCall(
          TEST_CONFIG.api.save,
          "POST",
          testData
        );

        if (saveResponse.success) {
          // Restore checklist
          const restoreResponse = await this.utils.apiCall(
            `${TEST_CONFIG.api.restore}?sessionKey=${sessionKey}`
          );

          if (restoreResponse.success && restoreResponse.data.state) {
            this.testResults.push({
              test: "Save and Restore",
              status: "PASSED",
            });
          } else {
            throw new Error("Restore failed or returned invalid data");
          }
        } else {
          throw new Error("Save failed");
        }
      } else {
        throw new Error("Instantiate failed");
      }
    } catch (error) {
      this.testResults.push({
        test: "Save and Restore",
        status: "FAILED",
        error: error.message,
      });
      await this.utils.screenshot("save-restore-error");
    } finally {
      // Cleanup test data
      await this.utils.cleanupTestData(sessionKey);
    }
  }

  /**
   * Test 4: Report Generation
   */
  async testReportGeneration() {
    this.utils.logStep("Testing report generation");

    try {
      // Navigate to reports page
      await this.utils.navigateToPage(TEST_CONFIG.pages.reports);
      await this.utils.waitForLoadingComplete();
      await this.utils.screenshot("reports-page-loaded");

      // Verify reports page elements
      await this.utils.assertElementVisible(TEST_CONFIG.selectors.header);

      // Check for report content
      const reportContent = await this.page.locator("main").textContent();
      if (reportContent && reportContent.length > 0) {
        this.testResults.push({ test: "Report Generation", status: "PASSED" });
      } else {
        throw new Error("Report content not found");
      }
    } catch (error) {
      this.testResults.push({
        test: "Report Generation",
        status: "FAILED",
        error: error.message,
      });
      await this.utils.screenshot("report-generation-error");
    }
  }

  /**
   * Test 5: Admin Management
   */
  async testAdminManagement() {
    this.utils.logStep("Testing admin management");

    try {
      // Navigate to admin page
      await this.utils.navigateToPage(TEST_CONFIG.pages.admin);
      await this.utils.waitForLoadingComplete();
      await this.utils.screenshot("admin-page-loaded");

      // Verify admin page elements
      await this.utils.assertElementVisible(TEST_CONFIG.selectors.header);
      await this.utils.assertElementVisible(TEST_CONFIG.selectors.adminTable);

      // Check for admin table content
      const tableRows = await this.page
        .locator(".admin-table tbody tr")
        .count();
      if (tableRows >= 0) {
        // Table can be empty, that's OK
        this.testResults.push({ test: "Admin Management", status: "PASSED" });
      } else {
        throw new Error("Admin table not found");
      }
    } catch (error) {
      this.testResults.push({
        test: "Admin Management",
        status: "FAILED",
        error: error.message,
      });
      await this.utils.screenshot("admin-management-error");
    }
  }

  /**
   * Test 6: API Health Check
   */
  async testApiHealthCheck() {
    this.utils.logStep("Testing API health check");

    try {
      const healthResponse = await this.utils.apiCall(TEST_CONFIG.api.health);

      if (healthResponse.success) {
        this.testResults.push({ test: "API Health Check", status: "PASSED" });
      } else {
        throw new Error("Health check failed");
      }
    } catch (error) {
      this.testResults.push({
        test: "API Health Check",
        status: "FAILED",
        error: error.message,
      });
    }
  }

  /**
   * Run all critical path tests
   */
  async runAllTests() {
    console.log("🚀 Starting Critical Path Tests for AccessiList");
    console.log("=".repeat(60));

    await this.setup();

    try {
      await this.testApiHealthCheck();
      await this.testHomeToChecklistJourney();
      await this.testChecklistInteraction();
      await this.testSaveRestoreFunctionality();
      await this.testReportGeneration();
      await this.testAdminManagement();
    } finally {
      await this.cleanup();
    }

    // Generate report
    const report = this.utils.generateTestReport(
      "critical-path-tests",
      this.testResults
    );

    // Display results
    console.log("\n" + "=".repeat(60));
    console.log("📊 CRITICAL PATH TEST RESULTS");
    console.log("=".repeat(60));
    console.log(`Total Tests: ${report.summary.total}`);
    console.log(`Passed: ${report.summary.passed}`);
    console.log(`Failed: ${report.summary.failed}`);
    console.log(
      `Success Rate: ${(
        (report.summary.passed / report.summary.total) *
        100
      ).toFixed(2)}%`
    );
    console.log("=".repeat(60));

    // Show failed tests
    const failedTests = this.testResults.filter((r) => r.status === "FAILED");
    if (failedTests.length > 0) {
      console.log("\n❌ Failed Tests:");
      failedTests.forEach((test) => {
        console.log(`   • ${test.test}: ${test.error}`);
      });
    }

    return report;
  }
}

// Run tests if this file is executed directly
if (require.main === module) {
  const testSuite = new CriticalPathTests();
  testSuite
    .runAllTests()
    .then((report) => {
      process.exit(report.summary.failed > 0 ? 1 : 0);
    })
    .catch((error) => {
      console.error("💥 Critical path tests failed:", error);
      process.exit(1);
    });
}

module.exports = CriticalPathTests;
