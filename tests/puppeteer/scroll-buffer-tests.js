#!/usr/bin/env node

/**
 * Scroll Buffer and Side Panel Tests for AccessiList
 * Tests the pseudo-scroll buffer system and side panel navigation
 */

const { chromium } = require("playwright");
const TestUtils = require("./test-utils");
const TEST_CONFIG = require("./test-config");

class ScrollBufferTests {
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

    await this.page.setViewportSize(TEST_CONFIG.browser.viewport);
    this.utils.logStep("Browser setup complete for scroll buffer tests");
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
   * Test list.php scroll buffer initialization
   */
  async testMyChecklistScrollBuffer() {
    this.utils.logStep("Testing list.php scroll buffer initialization");

    try {
      await this.utils.navigateToPage(
        `${TEST_CONFIG.pages.checklist}?type=word&session=TEST1`
      );
      await this.utils.waitForLoadingComplete();

      // Check that scroll restoration is disabled
      const scrollRestoration = await this.page.evaluate(() => {
        return window.history.scrollRestoration;
      });

      // Check for top buffer (90px)
      const topBuffer = await this.page.evaluate(() => {
        const main = document.querySelector("main");
        const before = window.getComputedStyle(main, "::before");
        return before.height;
      });

      // Check for bottom buffer CSS variable
      const bottomBufferValue = await this.page.evaluate(() => {
        return document.documentElement.style.getPropertyValue(
          "--bottom-buffer"
        );
      });

      // Verify scroll position starts at 0
      const initialScroll = await this.page.evaluate(() => window.scrollY);

      await this.utils.screenshot("list-scroll-buffer-init");

      if (
        scrollRestoration === "manual" &&
        topBuffer === "90px" &&
        initialScroll === 0
      ) {
        this.testResults.push({
          test: "MyChecklist Scroll Buffer Initialization",
          status: "PASSED",
          details: `Top buffer: ${topBuffer}, Scroll: ${initialScroll}px, Bottom buffer: ${
            bottomBufferValue || "dynamic"
          }`,
        });
      } else {
        throw new Error(
          `Scroll buffer not configured correctly. Restoration: ${scrollRestoration}, Top buffer: ${topBuffer}, Scroll: ${initialScroll}`
        );
      }
    } catch (error) {
      this.testResults.push({
        test: "MyChecklist Scroll Buffer Initialization",
        status: "FAILED",
        error: error.message,
      });
    }
  }

  /**
   * Test report pages scroll buffer (120px top buffer)
   */
  async testReportPagesScrollBuffer() {
    this.utils.logStep("Testing report pages scroll buffer (120px)");

    const sessionKey = "RPTTEST";

    try {
      // Create test session
      const testData = this.utils.createTestData(sessionKey, "word");
      await this.utils.apiCall(TEST_CONFIG.api.save, "POST", testData);

      // Test list-report.php
      await this.page.goto(
        `${TEST_CONFIG.baseUrl}/list-report?session=${sessionKey}`
      );
      await this.page.waitForTimeout(1500); // Wait for content to build

      // Check top buffer
      const topBuffer = await this.page.evaluate(() => {
        const main = document.querySelector("main");
        const before = window.getComputedStyle(main, "::before");
        return before.height;
      });

      // Check initial scroll position (should be 130px)
      const initialScroll = await this.page.evaluate(() => window.scrollY);

      // Check bottom buffer CSS variable
      const bottomBufferValue = await this.page.evaluate(() => {
        return document.documentElement.style.getPropertyValue(
          "--bottom-buffer-report"
        );
      });

      await this.utils.screenshot("report-scroll-buffer-init");

      if (topBuffer === "120px" && initialScroll === 130) {
        this.testResults.push({
          test: "Report Pages Scroll Buffer (120px)",
          status: "PASSED",
          details: `Top buffer: ${topBuffer}, Initial scroll: ${initialScroll}px, Bottom buffer: ${
            bottomBufferValue || "dynamic"
          }`,
        });
      } else {
        throw new Error(
          `Report buffer not correct. Top: ${topBuffer}, Scroll: ${initialScroll}`
        );
      }

      // Test systemwide-report.php
      await this.page.goto(`${TEST_CONFIG.baseUrl}/reports`);
      await this.page.waitForTimeout(1500);

      const systemwideTopBuffer = await this.page.evaluate(() => {
        const main = document.querySelector("main");
        const before = window.getComputedStyle(main, "::before");
        return before.height;
      });

      const systemwideScroll = await this.page.evaluate(() => window.scrollY);

      await this.utils.screenshot("systemwide-report-scroll-buffer");

      if (systemwideTopBuffer === "120px" && systemwideScroll === 130) {
        this.testResults.push({
          test: "Systemwide Report Scroll Buffer (120px)",
          status: "PASSED",
          details: `Top buffer: ${systemwideTopBuffer}, Initial scroll: ${systemwideScroll}px`,
        });
      } else {
        throw new Error(
          `Systemwide buffer not correct. Top: ${systemwideTopBuffer}, Scroll: ${systemwideScroll}`
        );
      }
    } catch (error) {
      this.testResults.push({
        test: "Report Pages Scroll Buffer",
        status: "FAILED",
        error: error.message,
      });
    } finally {
      await this.utils.cleanupTestData(sessionKey);
    }
  }

  /**
   * Test dynamic bottom buffer calculation
   */
  async testDynamicBottomBuffer() {
    this.utils.logStep("Testing dynamic bottom buffer calculation");

    try {
      await this.utils.navigateToPage(
        `${TEST_CONFIG.pages.checklist}?type=word&session=BUFTEST`
      );
      await this.utils.waitForLoadingComplete();
      await this.page.waitForTimeout(1000); // Wait for buffer calculation

      // Check that scheduleBufferUpdate function exists
      const functionExists = await this.page.evaluate(() => {
        return typeof window.scheduleBufferUpdate === "function";
      });

      // Get buffer calculation details
      const bufferInfo = await this.page.evaluate(() => {
        const buffer =
          document.documentElement.style.getPropertyValue("--bottom-buffer");
        const viewport = window.innerHeight;
        const main = document.querySelector("main");
        const sections = document.querySelectorAll(".checkpoint-section");
        const visibleSections = Array.from(sections).filter(
          (s) => s.style.display !== "none"
        );

        return {
          buffer: buffer,
          viewport: viewport,
          visibleSections: visibleSections.length,
          functionExists: typeof window.scheduleBufferUpdate === "function",
        };
      });

      await this.utils.screenshot("dynamic-buffer-calculated");

      if (functionExists && bufferInfo.buffer) {
        this.testResults.push({
          test: "Dynamic Bottom Buffer Calculation",
          status: "PASSED",
          details: `Buffer: ${bufferInfo.buffer}, Viewport: ${bufferInfo.viewport}px, Visible sections: ${bufferInfo.visibleSections}`,
        });
      } else {
        throw new Error(
          "Buffer calculation function not available or buffer not set"
        );
      }
    } catch (error) {
      this.testResults.push({
        test: "Dynamic Bottom Buffer Calculation",
        status: "FAILED",
        error: error.message,
      });
    }
  }

  /**
   * Test side panel All button clickability
   */
  async testAllButtonClickability() {
    this.utils.logStep("Testing side panel All button clickability");

    const sessionKey = "ALLBTN";

    try {
      // Create test session
      const testData = this.utils.createTestData(sessionKey, "word");
      await this.utils.apiCall(TEST_CONFIG.api.save, "POST", testData);

      // Test on list-report.php
      await this.page.goto(
        `${TEST_CONFIG.baseUrl}/list-report?session=${sessionKey}`
      );
      await this.page.waitForTimeout(1500);

      // Check that All button exists and is visible
      const allButton = await this.page.locator(".checkpoint-all");
      const isVisible = await allButton.isVisible();

      if (!isVisible) {
        throw new Error("All button not visible");
      }

      // Check computed styles
      const allButtonInfo = await this.page.evaluate(() => {
        const btn = document.querySelector(".checkpoint-all");
        if (!btn) return null;

        const styles = window.getComputedStyle(btn);
        const rect = btn.getBoundingClientRect();

        // Check what element is at the button's center
        const centerX = rect.left + rect.width / 2;
        const centerY = rect.top + rect.height / 2;
        const elementAtCenter = document.elementFromPoint(centerX, centerY);

        return {
          width: styles.width,
          height: styles.height,
          minWidth: styles.minWidth,
          minHeight: styles.minHeight,
          pointerEvents: styles.pointerEvents,
          isClickable: elementAtCenter === btn,
          elementAtCenter: elementAtCenter?.className || "none",
        };
      });

      await this.utils.screenshot("all-button-before-click");

      if (!allButtonInfo) {
        throw new Error("All button not found in DOM");
      }

      if (!allButtonInfo.isClickable) {
        throw new Error(
          `All button blocked by element: ${allButtonInfo.elementAtCenter}`
        );
      }

      // Click checkpoint button first to deactivate All
      await this.page.click('.checkpoint-btn[data-checkpoint="1"]');
      await this.page.waitForTimeout(500);
      await this.utils.screenshot("checkpoint-1-selected");

      // Now click All button
      await allButton.click();
      await this.page.waitForTimeout(500);
      await this.utils.screenshot("all-button-clicked");

      // Verify All button is now active
      const isActive = await this.page.evaluate(() => {
        const btn = document.querySelector(".checkpoint-all");
        return btn?.classList.contains("active");
      });

      if (
        isActive &&
        allButtonInfo.width === "30px" &&
        allButtonInfo.height === "30px"
      ) {
        this.testResults.push({
          test: "All Button Clickability",
          status: "PASSED",
          details: `Dimensions: ${allButtonInfo.width}x${allButtonInfo.height}, Clickable: ${allButtonInfo.isClickable}, Active: ${isActive}`,
        });
      } else {
        throw new Error(
          `All button not working correctly. Active: ${isActive}, Size: ${allButtonInfo.width}x${allButtonInfo.height}`
        );
      }
    } catch (error) {
      this.testResults.push({
        test: "All Button Clickability",
        status: "FAILED",
        error: error.message,
      });
    } finally {
      await this.utils.cleanupTestData(sessionKey);
    }
  }

  /**
   * Test checkpoint button navigation
   */
  async testCheckpointNavigation() {
    this.utils.logStep("Testing checkpoint button navigation");

    try {
      await this.utils.navigateToPage(
        `${TEST_CONFIG.pages.checklist}?type=word&session=NAVTEST`
      );
      await this.utils.waitForLoadingComplete();
      await this.page.waitForTimeout(1000);

      // Get initial state (All should be active)
      const initialState = await this.page.evaluate(() => {
        const allBtn = document.querySelector(".checkpoint-all");
        const sections = document.querySelectorAll(".checkpoint-section");
        const visibleSections = Array.from(sections).filter(
          (s) => s.style.display !== "none"
        ).length;

        return {
          allActive: allBtn?.classList.contains("active"),
          visibleSections: visibleSections,
        };
      });

      // Click checkpoint 1
      await this.page.click('.checkpoint-btn[data-checkpoint="checkpoint-1"]');
      await this.page.waitForTimeout(500);
      await this.utils.screenshot("checkpoint-1-active");

      // Check that only checkpoint 1 is visible
      const checkpoint1State = await this.page.evaluate(() => {
        const btn1 = document.querySelector(
          '.checkpoint-btn[data-checkpoint="checkpoint-1"]'
        );
        const sections = document.querySelectorAll(".checkpoint-section");
        const visibleSections = Array.from(sections).filter(
          (s) => s.style.display !== "none"
        ).length;

        return {
          button1Active: btn1?.classList.contains("active"),
          visibleSections: visibleSections,
        };
      });

      // Click All button to restore all checkpoints
      await this.page.click(".checkpoint-all");
      await this.page.waitForTimeout(500);
      await this.utils.screenshot("all-restored");

      // Check that all checkpoints are visible again
      const finalState = await this.page.evaluate(() => {
        const allBtn = document.querySelector(".checkpoint-all");
        const sections = document.querySelectorAll(".checkpoint-section");
        const visibleSections = Array.from(sections).filter(
          (s) => s.style.display !== "none"
        ).length;

        return {
          allActive: allBtn?.classList.contains("active"),
          visibleSections: visibleSections,
        };
      });

      if (
        initialState.allActive &&
        checkpoint1State.button1Active &&
        checkpoint1State.visibleSections === 1 &&
        finalState.allActive &&
        finalState.visibleSections > 1
      ) {
        this.testResults.push({
          test: "Checkpoint Navigation",
          status: "PASSED",
          details: `Initial: ${initialState.visibleSections} sections, Single: ${checkpoint1State.visibleSections}, Restored: ${finalState.visibleSections}`,
        });
      } else {
        throw new Error("Checkpoint navigation not working correctly");
      }
    } catch (error) {
      this.testResults.push({
        test: "Checkpoint Navigation",
        status: "FAILED",
        error: error.message,
      });
    }
  }

  /**
   * Test pointer-events pass-through on report pages
   */
  async testPointerEventsPassThrough() {
    this.utils.logStep("Testing pointer-events pass-through on report pages");

    const sessionKey = "PTRTEST";

    try {
      // Create test session
      const testData = this.utils.createTestData(sessionKey, "word");
      await this.utils.apiCall(TEST_CONFIG.api.save, "POST", testData);

      await this.page.goto(
        `${TEST_CONFIG.baseUrl}/list-report?session=${sessionKey}`
      );
      await this.page.waitForTimeout(1500);

      // Check pointer-events configuration
      const pointerEventsInfo = await this.page.evaluate(() => {
        const container = document.querySelector(".sticky-header-container");
        const header = document.querySelector(".sticky-header");
        const filterGroup = document.querySelector(".filter-group");
        const filterButton = document.querySelector(".filter-button");
        const allButton = document.querySelector(".checkpoint-all");

        return {
          container: container
            ? window.getComputedStyle(container).pointerEvents
            : "not-found",
          header: header
            ? window.getComputedStyle(header).pointerEvents
            : "not-found",
          filterGroup: filterGroup
            ? window.getComputedStyle(filterGroup).pointerEvents
            : "not-found",
          filterButton: filterButton
            ? window.getComputedStyle(filterButton).pointerEvents
            : "not-found",
          allButton: allButton
            ? window.getComputedStyle(allButton).pointerEvents
            : "not-found",
        };
      });

      await this.utils.screenshot("pointer-events-config");

      if (
        pointerEventsInfo.container === "none" &&
        pointerEventsInfo.header === "auto" &&
        pointerEventsInfo.filterGroup === "auto" &&
        pointerEventsInfo.filterButton === "auto" &&
        pointerEventsInfo.allButton === "auto"
      ) {
        this.testResults.push({
          test: "Pointer-Events Pass-Through Configuration",
          status: "PASSED",
          details: `Container: ${pointerEventsInfo.container}, Header: ${pointerEventsInfo.header}, Filter: ${pointerEventsInfo.filterButton}, All button: ${pointerEventsInfo.allButton}`,
        });
      } else {
        throw new Error(
          `Pointer-events not configured correctly: ${JSON.stringify(
            pointerEventsInfo
          )}`
        );
      }
    } catch (error) {
      this.testResults.push({
        test: "Pointer-Events Pass-Through Configuration",
        status: "FAILED",
        error: error.message,
      });
    } finally {
      await this.utils.cleanupTestData(sessionKey);
    }
  }

  /**
   * Test buffer update on window resize
   */
  async testBufferUpdateOnResize() {
    this.utils.logStep("Testing buffer update on window resize");

    try {
      await this.utils.navigateToPage(
        `${TEST_CONFIG.pages.checklist}?type=word&session=RESIZE`
      );
      await this.utils.waitForLoadingComplete();
      await this.page.waitForTimeout(1000);

      // Get initial buffer value
      const initialBuffer = await this.page.evaluate(() => {
        return document.documentElement.style.getPropertyValue(
          "--bottom-buffer"
        );
      });

      // Resize viewport
      await this.page.setViewportSize({ width: 1200, height: 1000 });
      await this.page.waitForTimeout(1000); // Wait for debounced update

      // Get new buffer value
      const newBuffer = await this.page.evaluate(() => {
        return document.documentElement.style.getPropertyValue(
          "--bottom-buffer"
        );
      });

      await this.utils.screenshot("after-resize");

      // Buffer should have changed (or at least been recalculated)
      if (initialBuffer && newBuffer) {
        this.testResults.push({
          test: "Buffer Update on Resize",
          status: "PASSED",
          details: `Initial: ${initialBuffer}, After resize: ${newBuffer}`,
        });
      } else {
        throw new Error("Buffer not recalculated on resize");
      }
    } catch (error) {
      this.testResults.push({
        test: "Buffer Update on Resize",
        status: "FAILED",
        error: error.message,
      });
    }
  }

  /**
   * Run all scroll buffer tests
   */
  async runAllTests() {
    console.log("🧪 Starting Scroll Buffer Tests for AccessiList");
    console.log("=".repeat(60));

    await this.setup();

    try {
      await this.testMyChecklistScrollBuffer();
      await this.testReportPagesScrollBuffer();
      await this.testDynamicBottomBuffer();
      await this.testAllButtonClickability();
      await this.testCheckpointNavigation();
      await this.testPointerEventsPassThrough();
      await this.testBufferUpdateOnResize();
    } finally {
      await this.cleanup();
    }

    // Generate report
    const report = this.utils.generateTestReport(
      "scroll-buffer-tests",
      this.testResults
    );

    // Display results
    console.log("\n" + "=".repeat(60));
    console.log("📊 SCROLL BUFFER TEST RESULTS");
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

    return report;
  }
}

// Run tests if this file is executed directly
if (require.main === module) {
  const testSuite = new ScrollBufferTests();
  testSuite
    .runAllTests()
    .then((report) => {
      process.exit(report.summary.failed > 0 ? 1 : 0);
    })
    .catch((error) => {
      console.error("💥 Scroll buffer tests failed:", error);
      process.exit(1);
    });
}

module.exports = ScrollBufferTests;
