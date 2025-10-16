#!/usr/bin/env node

/**
 * Demo Test to Show Different Puppeteer Modes
 * This demonstrates the speed difference between headless and headed modes
 */

const { chromium } = require("playwright");
const TEST_CONFIG = require("./test-config");

class DemoTest {
  constructor() {
    this.browser = null;
    this.page = null;
    this.sessionToken = process.env.SESSION_TOKEN || "test new";
    this.persistentBrowser = global.persistentBrowser;
    this.sessionKey = this.extractSessionKey(this.sessionToken);
  }

  extractSessionKey(token) {
    if (token === "test new") {
      return null; // No specific session key
    }
    if (token.startsWith("test ")) {
      return token.substring(5); // Remove "test " prefix
    }
    return token; // Use token as-is if no "test " prefix
  }

  async closeAllChromiumInstances() {
    console.log("🧹 Closing all existing Chromium instances...");
    try {
      // Kill any existing Chromium processes
      const { exec } = require("child_process");
      const util = require("util");
      const execAsync = util.promisify(exec);

      // Close Chromium processes (works on macOS/Linux)
      await execAsync("pkill -f chromium || pkill -f chrome || true");
      console.log("✅ Existing Chromium instances closed");
    } catch (error) {
      console.log(
        "⚠️ Could not close existing instances (this is usually fine)"
      );
    }

    // Clear global browser reference
    global.persistentBrowser = null;
    this.persistentBrowser = null;
  }

  getMonitorControlArgs() {
    // Monitor control options for different scenarios
    const monitorArgs = [
      "--window-position=0,0", // Position at top-left of primary monitor
      "--start-maximized", // Start maximized
      "--disable-web-security",
      "--disable-features=VizDisplayCompositor",
      "--force-device-scale-factor=1", // Prevent scaling issues
      "--disable-background-timer-throttling",
      "--disable-backgrounding-occluded-windows",
      "--disable-renderer-backgrounding",
    ];

    // Add monitor-specific positioning if needed
    const monitorId = process.env.MONITOR_ID;
    if (monitorId) {
      console.log(`🖥️ Using monitor: ${monitorId}`);
      // For multi-monitor setups, you can specify which monitor
      monitorArgs.push(
        `--window-position=${monitorId === "1" ? "0,0" : "1920,0"}`
      );
    }

    return monitorArgs;
  }

  async setup() {
    console.log(`🔑 Session Token: ${this.sessionToken}`);
    console.log(`🔑 Session Key: ${this.sessionKey || "new session"}`);

    // Step 0: Close all existing Chromium instances first
    await this.closeAllChromiumInstances();

    // Step 1: Create fresh browser instance with monitor control
    console.log("🚀 Creating fresh browser instance...");

    // Enhanced browser options for monitor control
    const browserOptions = {
      ...TEST_CONFIG.browser,
      args: this.getMonitorControlArgs(),
    };

    this.browser = await chromium.launch(browserOptions);
    global.persistentBrowser = this.browser;
    this.page = await this.browser.newPage();

    await this.page.setViewportSize(TEST_CONFIG.browser.viewport);
  }

  async cleanup(keepBrowserOpen = false) {
    if (this.browser && !keepBrowserOpen) {
      await this.browser.close();
    } else if (keepBrowserOpen) {
      console.log("🌐 Browser kept open for inspection");
    }
  }

  async runDemo() {
    console.log("🎭 Puppeteer Demo Test");
    console.log("=".repeat(50));
    console.log(
      `Mode: ${TEST_CONFIG.browser.headless ? "HEADLESS" : "HEADED"}`
    );
    console.log(`Slow Motion: ${TEST_CONFIG.browser.slowMo}ms`);
    console.log(
      `DevTools: ${TEST_CONFIG.browser.devtools ? "OPEN" : "CLOSED"}`
    );
    console.log("=".repeat(50));

    const startTime = Date.now();

    try {
      await this.setup();

      // Navigate based on session key
      if (this.sessionKey) {
        const targetUrl = `http://localhost:8000/?=${this.sessionKey}`;
        console.log(`🌐 Navigating to session: ${targetUrl}...`);
        await this.page.goto(targetUrl);
      } else {
        console.log("🌐 Navigating to local server (new session)...");
        await this.page.goto("http://localhost:8000");
      }

      // Take a screenshot
      console.log("📸 Taking screenshot...");
      await this.page.screenshot({
        path: "tests/screenshots/demo-test.png",
        fullPage: true,
      });

      // Custom workflow: Click Word (if on home page), add notes, save, refresh
      console.log("🔍 Starting custom workflow...");

      // Check if we're on the home page or already on a checklist page
      const currentUrl = this.page.url();
      const isOnHomePage =
        currentUrl === "http://localhost:8000/" ||
        currentUrl === "http://localhost:8000/index.php";

      if (isOnHomePage) {
        // Step 1: Click on Word checklist (only if on home page)
        console.log("📝 Step 1: Clicking on Word checklist...");
        try {
          await this.page.locator("#word.checklist-button").click();
          await this.page.waitForTimeout(2000); // Wait for navigation
          console.log("✅ Word checklist opened");
        } catch (error) {
          console.log("⚠️ Word button not found, trying alternative...");
          // Try clicking on any checklist button
          await this.page.locator(".checklist-button").first().click();
          await this.page.waitForTimeout(2000);
        }
      } else {
        console.log("📝 Step 1: Skipped - already on checklist page");
        console.log(`📍 Current URL: ${currentUrl}`);
      }

      // Step 2: Find first checkpoint row and add notes
      console.log('📝 Step 2: Adding "Test" to first checkpoint row notes...');
      try {
        // Look for notes textarea in first row (based on CSS analysis)
        const firstNotesTextarea = this.page.locator(".notes-textarea").first();
        await firstNotesTextarea.fill("Test");
        await this.page.waitForTimeout(500);
        console.log("✅ Notes added to first checkpoint row");
      } catch (error) {
        console.log(
          "⚠️ Notes textarea not found, trying alternative selector..."
        );
        // Try alternative selector
        const altInput = this.page.locator("textarea").first();
        await altInput.fill("Test");
        await this.page.waitForTimeout(500);
      }

      // Step 3: Click Save button
      console.log("💾 Step 3: Clicking Save button...");
      try {
        await this.page.locator("#saveButton").click();
        await this.page.waitForTimeout(1000);
        console.log("✅ Save button clicked");
      } catch (error) {
        console.log("⚠️ Save button not found, trying alternative...");
        // Try alternative save button selector
        await this.page.locator('button:has-text("Save")').first().click();
        await this.page.waitForTimeout(1000);
      }

      // Step 4: Refresh page
      console.log("🔄 Step 4: Refreshing page...");
      await this.page.reload();
      await this.page.waitForTimeout(1000);
      console.log("✅ Page refreshed");

      // Wait a moment to see the final state
      await this.page.waitForTimeout(1000);

      // Take another screenshot
      console.log("📸 Taking final screenshot...");
      await this.page.screenshot({
        path: "tests/screenshots/demo-test-final.png",
        fullPage: true,
      });

      const endTime = Date.now();
      const duration = endTime - startTime;

      console.log("=".repeat(50));
      console.log(`✅ Demo completed in ${duration}ms`);
      console.log("📁 Screenshots saved to tests/screenshots/");
      console.log("=".repeat(50));
    } catch (error) {
      console.error("❌ Demo failed:", error.message);
    } finally {
      const keepOpen = process.env.KEEP_BROWSER_OPEN !== "false"; // Default to true unless explicitly set to false
      await this.cleanup(keepOpen);

      if (keepOpen) {
        // Keep process running in background to maintain browser
        console.log(
          "🎯 Demo completed - browser kept open, process running in background..."
        );
        console.log(
          "💡 Browser will stay open until you manually close it or restart the system"
        );
        console.log(
          "🔄 You can now return to chat - browser remains interactive"
        );

        // Keep process alive but minimize terminal interaction
        setInterval(() => {
          // Keep process alive with minimal activity
        }, 30000); // Check every 30 seconds

        // Handle graceful shutdown
        process.on("SIGINT", async () => {
          console.log("\n🛑 Received SIGINT, closing browser...");
          if (this.browser) {
            await this.browser.close();
          }
          process.exit(0);
        });

        process.on("SIGTERM", async () => {
          console.log("\n🛑 Received SIGTERM, closing browser...");
          if (this.browser) {
            await this.browser.close();
          }
          process.exit(0);
        });
      } else {
        // Exit process to return focus to chat
        console.log("🎯 Demo completed - returning focus to chat...");
        process.exit(0);
      }
    }
  }
}

// Run demo if this file is executed directly
if (require.main === module) {
  const demo = new DemoTest();
  demo.runDemo().catch((error) => {
    console.error("💥 Demo failed:", error);
    process.exit(1);
  });
}

module.exports = DemoTest;
