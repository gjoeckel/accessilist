/**
 * Test Configuration for AccessiList Puppeteer Tests
 * Centralized configuration for all test suites
 */

const path = require("path");

const TEST_CONFIG = {
  // Server configuration
  baseUrl: "http://localhost:8000",
  serverPort: 8000,

  // Test timeouts
  defaultTimeout: 30000,
  navigationTimeout: 10000,
  actionTimeout: 5000,

  // Browser configuration
  browser: {
    headless: process.env.HEADLESS !== "false",
    slowMo: process.env.SLOW_MO ? parseInt(process.env.SLOW_MO) : 0,
    devtools: process.env.DEVTOOLS === "true",
    viewport: {
      width: 1280,
      height: 720,
    },
    // Additional options for better visibility
    args: [
      "--start-maximized",
      "--disable-web-security",
      "--disable-features=VizDisplayCompositor",
    ],
  },

  // Test data
  testData: {
    sessionKey: "tst", // Test session key
    checklistTypes: [
      "word",
      "excel",
      "powerpoint",
      "slides",
      "docs",
      "camtasia",
      "dojo",
    ],
    testUser: {
      name: "Test User",
      email: "test@accessilist.local",
    },
  },

  // File paths
  paths: {
    screenshots: path.join(__dirname, "../screenshots"),
    reports: path.join(__dirname, "../reports"),
    testData: path.join(__dirname, "test-data"),
  },

  // API endpoints
  api: {
    health: "/php/api/health.php",
    list: "/php/api/list.php",
    save: "/php/api/save.php",
    restore: "/php/api/restore.php",
    instantiate: "/php/api/instantiate.php",
    delete: "/php/api/delete.php",
  },

  // Page URLs
  pages: {
    home: "/php/home.php",
    checklist: "/php/list.php",
    reports: "/php/reports.php",
    admin: "/php/admin.php",
  },

  // Selectors (common elements)
  selectors: {
    // Header elements
    header: ".sticky-header",
    homeButton: "#homeButton",
    saveButton: "#saveButton",
    adminButton: "#adminButton",
    refreshButton: "#refreshButton",

    // Navigation
    sidePanel: ".side-panel",
    checklistLinks: ".checklist-link",

    // Checklist elements
    checklistItems: ".checklist-item",
    statusButtons: ".status-button",
    notesInput: ".notes-input",
    addRowButton: ".add-row-button",

    // Modal elements
    modal: ".modal",
    modalContent: ".modal-content",
    modalClose: ".modal-close",

    // Admin elements
    adminTable: ".admin-table",
    deleteButton: ".delete-button",

    // Loading elements
    loadingOverlay: "#loadingOverlay",
    loadingSpinner: "#loadingSpinner",
  },

  // Test scenarios
  scenarios: {
    // Critical user journeys
    criticalPaths: [
      "home-to-checklist",
      "checklist-interaction",
      "save-restore",
      "report-generation",
      "admin-management",
    ],

    // Error scenarios
    errorScenarios: [
      "invalid-session-key",
      "network-failure",
      "server-error",
      "malformed-data",
    ],
  },
};

module.exports = TEST_CONFIG;
