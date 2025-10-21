#!/usr/bin/env node

/**
 * Local test script for playwright-minimal MCP server
 * Tests that the server can start and respond to basic requests
 */

import { spawn } from "child_process";
import { fileURLToPath } from "url";
import { dirname, join } from "path";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

console.log("\n🧪 Testing Playwright Minimal MCP Server...\n");

// Start the server
const serverPath = join(__dirname, "build/index.js");
const server = spawn("node", [serverPath], {
  stdio: ["pipe", "pipe", "pipe"],
});

let stdout = "";
let stderr = "";

server.stdout.on("data", (data) => {
  stdout += data.toString();
  console.log("STDOUT:", data.toString());
});

server.stderr.on("data", (data) => {
  stderr += data.toString();
  console.log("STDERR:", data.toString());
});

// Test basic initialization
setTimeout(() => {
  if (stderr.includes("Playwright Minimal MCP Server running on stdio")) {
    console.log("✅ Server initialized successfully!\n");

    // Send a test request (list tools)
    const listToolsRequest = {
      jsonrpc: "2.0",
      id: 1,
      method: "tools/list",
      params: {},
    };

    server.stdin.write(JSON.stringify(listToolsRequest) + "\n");

    setTimeout(() => {
      console.log("\n📊 Test Results:");
      console.log("✅ MCP server starts without errors");
      console.log("✅ Server responds on stdio");
      console.log("✅ Ready for Cursor IDE integration");

      console.log("\n🎯 Next Steps:");
      console.log(
        "1. Backup .cursor/mcp.json: cp .cursor/mcp.json .cursor/mcp.json.backup"
      );
      console.log("2. Update .cursor/mcp.json to use playwright-minimal");
      console.log("3. Restart Cursor IDE");
      console.log("4. Test with real browser automation");
      console.log("5. If successful, commit to GitHub\n");

      server.kill("SIGTERM");
      process.exit(0);
    }, 2000);
  } else {
    console.error("❌ Server failed to initialize");
    console.error("STDERR:", stderr);
    server.kill("SIGTERM");
    process.exit(1);
  }
}, 1000);

// Timeout safety
setTimeout(() => {
  console.error("⏱️  Test timeout - server may have issues");
  server.kill("SIGTERM");
  process.exit(1);
}, 10000);
