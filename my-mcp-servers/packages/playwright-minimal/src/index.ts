#!/usr/bin/env node

import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
  Tool,
} from "@modelcontextprotocol/sdk/types.js";
import { z } from "zod";
import {
  chromium,
  firefox,
  webkit,
  Browser,
  Page,
  BrowserType,
} from "playwright";

// Playwright API wrapper (4 essential tools)
class PlaywrightAPI {
  private browsers: Map<string, Browser> = new Map();
  private pages: Map<string, Page> = new Map();
  private currentBrowser: string = "chromium";
  private consoleLogs: string[] = [];
  private networkLogs: Array<{ url: string; status: number; method: string }> =
    [];

  async initialize(
    browserType: "chromium" | "firefox" | "webkit" = "chromium"
  ) {
    if (!this.browsers.has(browserType)) {
      const browserEngine: BrowserType =
        browserType === "firefox"
          ? firefox
          : browserType === "webkit"
          ? webkit
          : chromium;

      const browser = await browserEngine.launch({
        headless: true,
      });
      this.browsers.set(browserType, browser);
    }

    if (!this.pages.has(browserType)) {
      const browser = this.browsers.get(browserType)!;
      const page = await browser.newPage();

      // Capture console logs
      page.on("console", (msg) => {
        this.consoleLogs.push(`[${msg.type()}] ${msg.text()}`);
      });

      // Capture network activity
      page.on("response", (response) => {
        this.networkLogs.push({
          url: response.url(),
          status: response.status(),
          method: response.request().method(),
        });
      });

      this.pages.set(browserType, page);
    }

    this.currentBrowser = browserType;
  }

  async navigateAndWait(
    url: string,
    options: {
      waitUntil?: "load" | "domcontentloaded" | "networkidle" | "commit";
      timeout?: number;
      browserType?: "chromium" | "firefox" | "webkit";
    } = {}
  ) {
    const browserType = options.browserType || "chromium";
    await this.initialize(browserType);

    const page = this.pages.get(browserType);
    if (!page) throw new Error("Page not initialized");

    // Clear logs for new navigation
    this.consoleLogs = [];
    this.networkLogs = [];

    await page.goto(url, {
      waitUntil: options.waitUntil || "domcontentloaded",
      timeout: options.timeout || 30000,
    });

    return {
      browser: browserType,
      url: page.url(),
      title: await page.title(),
      ready: true,
    };
  }

  async interactWith(
    selector: string,
    action: "click" | "type" | "select" | "check",
    options: {
      text?: string;
      value?: string;
      timeout?: number;
      force?: boolean;
    } = {}
  ) {
    const page = this.pages.get(this.currentBrowser);
    if (!page)
      throw new Error("Page not initialized - call navigate_and_wait first");

    const locator = page.locator(selector);

    switch (action) {
      case "click":
        await locator.click({
          timeout: options.timeout || 30000,
          force: options.force || false,
        });
        break;

      case "type":
        if (!options.text)
          throw new Error("text option required for type action");
        await locator.fill(options.text, {
          timeout: options.timeout || 30000,
        });
        break;

      case "select":
        if (!options.value)
          throw new Error("value option required for select action");
        await locator.selectOption(options.value, {
          timeout: options.timeout || 30000,
        });
        break;

      case "check":
        await locator.check({
          timeout: options.timeout || 30000,
        });
        break;

      default:
        throw new Error(`Unknown action: ${action}`);
    }

    return {
      action,
      selector,
      success: true,
      currentUrl: page.url(),
    };
  }

  async extractAndVerify(
    selector?: string,
    options: {
      attribute?: string;
      expected?: string;
      timeout?: number;
    } = {}
  ) {
    const page = this.pages.get(this.currentBrowser);
    if (!page)
      throw new Error("Page not initialized - call navigate_and_wait first");

    const attribute = options.attribute || "text";
    let content: string;

    if (selector) {
      const locator = page.locator(selector);

      // Wait for element to exist
      await locator.waitFor({
        state: "attached",
        timeout: options.timeout || 30000,
      });

      // Extract based on attribute type
      if (attribute === "text") {
        content = await locator.innerText();
      } else if (attribute === "value") {
        content = await locator.inputValue();
      } else if (attribute === "html") {
        content = await locator.innerHTML();
      } else {
        // Custom attribute
        content = (await locator.getAttribute(attribute)) || "";
      }
    } else {
      // No selector = get body text
      content = await page.locator("body").innerText();
    }

    // Optional verification
    let verified = true;
    if (options.expected !== undefined) {
      verified = content.includes(options.expected);
    }

    return {
      selector: selector || "body",
      attribute,
      content,
      verified,
      contentLength: content.length,
    };
  }

  async captureTestEvidence(
    options: {
      screenshot?: boolean | { fullPage: boolean };
      consoleLogs?: boolean;
      networkLogs?: boolean;
      html?: boolean;
      trace?: boolean;
    } = {}
  ) {
    const page = this.pages.get(this.currentBrowser);
    if (!page)
      throw new Error("Page not initialized - call navigate_and_wait first");

    const evidence: any = {
      browser: this.currentBrowser,
      url: page.url(),
      timestamp: new Date().toISOString(),
    };

    // Screenshot
    if (options.screenshot) {
      const fullPage =
        typeof options.screenshot === "object"
          ? options.screenshot.fullPage
          : true;

      const screenshot = await page.screenshot({ fullPage });
      evidence.screenshot = Buffer.from(screenshot).toString("base64");
      evidence.screenshotSize = screenshot.length;
    }

    // Console logs
    if (options.consoleLogs) {
      evidence.consoleLogs = this.consoleLogs;
      evidence.consoleLogCount = this.consoleLogs.length;
    }

    // Network logs
    if (options.networkLogs) {
      evidence.networkLogs = this.networkLogs;
      evidence.networkRequestCount = this.networkLogs.length;
    }

    // HTML source
    if (options.html) {
      evidence.html = await page.content();
      evidence.htmlSize = evidence.html.length;
    }

    return evidence;
  }

  async close() {
    for (const browser of this.browsers.values()) {
      await browser.close();
    }
    this.browsers.clear();
    this.pages.clear();
    this.consoleLogs = [];
    this.networkLogs = [];
  }
}

// Tool schemas
const NavigateAndWaitSchema = z.object({
  url: z.string().describe("URL to navigate to"),
  waitUntil: z
    .enum(["load", "domcontentloaded", "networkidle", "commit"])
    .optional()
    .describe("When to consider navigation complete"),
  timeout: z.number().optional().describe("Timeout in milliseconds"),
  browserType: z
    .enum(["chromium", "firefox", "webkit"])
    .optional()
    .describe("Browser type to use (default: chromium)"),
});

const InteractWithSchema = z.object({
  selector: z.string().describe("CSS selector or text selector"),
  action: z
    .enum(["click", "type", "select", "check"])
    .describe("Action to perform"),
  text: z.string().optional().describe("Text to type (for type action)"),
  value: z.string().optional().describe("Value to select (for select action)"),
  timeout: z.number().optional().describe("Timeout in milliseconds"),
  force: z.boolean().optional().describe("Skip actionability checks"),
});

const ExtractAndVerifySchema = z.object({
  selector: z.string().optional().describe("CSS selector (default: body)"),
  attribute: z
    .string()
    .optional()
    .describe(
      "Attribute to extract (text, value, html, or any attribute name)"
    ),
  expected: z.string().optional().describe("Expected value for verification"),
  timeout: z.number().optional().describe("Timeout in milliseconds"),
});

const CaptureTestEvidenceSchema = z.object({
  screenshot: z
    .union([z.boolean(), z.object({ fullPage: z.boolean() })])
    .optional()
    .describe("Capture screenshot"),
  consoleLogs: z.boolean().optional().describe("Capture browser console logs"),
  networkLogs: z.boolean().optional().describe("Capture network requests"),
  html: z.boolean().optional().describe("Capture page HTML source"),
  trace: z.boolean().optional().describe("Capture Playwright trace (future)"),
});

// Initialize Playwright API
const playwrightAPI = new PlaywrightAPI();

// Define available tools (only 4 essential tools)
const tools: Tool[] = [
  {
    name: "navigate_and_wait",
    description:
      "Navigate to a URL with smart waiting and multi-browser support. Auto-waits for page ready state. Supports Chromium, Firefox, and WebKit.",
    inputSchema: {
      type: "object",
      properties: NavigateAndWaitSchema.shape,
      required: ["url"],
    },
  },
  {
    name: "interact_with",
    description:
      "Interact with page elements (click, type, select, check). Auto-waits for element to be actionable (visible, stable, enabled). Includes built-in retry logic.",
    inputSchema: {
      type: "object",
      properties: InteractWithSchema.shape,
      required: ["selector", "action"],
    },
  },
  {
    name: "extract_and_verify",
    description:
      "Extract content from page elements with optional verification. Can extract text, values, HTML, or any attribute. Optionally verify against expected value.",
    inputSchema: {
      type: "object",
      properties: ExtractAndVerifySchema.shape,
      required: [],
    },
  },
  {
    name: "capture_test_evidence",
    description:
      "Capture comprehensive test evidence including screenshots, console logs, network logs, and page HTML. Useful for debugging and test reports.",
    inputSchema: {
      type: "object",
      properties: CaptureTestEvidenceSchema.shape,
      required: [],
    },
  },
];

// Create MCP server
const server = new Server(
  {
    name: "playwright-minimal",
    version: "1.0.0",
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

// List tools handler
server.setRequestHandler(ListToolsRequestSchema, async () => ({
  tools,
}));

// Call tool handler
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;

  try {
    switch (name) {
      case "navigate_and_wait": {
        const params = NavigateAndWaitSchema.parse(args);
        const result = await playwrightAPI.navigateAndWait(params.url, params);
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(result, null, 2),
            },
          ],
        };
      }

      case "interact_with": {
        const params = InteractWithSchema.parse(args);
        const result = await playwrightAPI.interactWith(
          params.selector,
          params.action,
          params
        );
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(result, null, 2),
            },
          ],
        };
      }

      case "extract_and_verify": {
        const params = ExtractAndVerifySchema.parse(args);
        const result = await playwrightAPI.extractAndVerify(
          params.selector,
          params
        );
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(result, null, 2),
            },
          ],
        };
      }

      case "capture_test_evidence": {
        const params = CaptureTestEvidenceSchema.parse(args);
        const result = await playwrightAPI.captureTestEvidence(params);
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(
                {
                  ...result,
                  screenshot: result.screenshot
                    ? `${result.screenshot.substring(0, 50)}... (${
                        result.screenshotSize
                      } bytes)`
                    : undefined,
                },
                null,
                2
              ),
            },
          ],
        };
      }

      default:
        throw new Error(`Unknown tool: ${name}`);
    }
  } catch (error) {
    return {
      content: [
        {
          type: "text",
          text: `Error: ${
            error instanceof Error ? error.message : String(error)
          }`,
        },
      ],
      isError: true,
    };
  }
});

// Graceful shutdown
process.on("SIGINT", async () => {
  await playwrightAPI.close();
  process.exit(0);
});

process.on("SIGTERM", async () => {
  await playwrightAPI.close();
  process.exit(0);
});

// Start server
async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error("Playwright Minimal MCP Server running on stdio");
}

main().catch((error) => {
  console.error("Server error:", error);
  playwrightAPI.close().finally(() => process.exit(1));
});
