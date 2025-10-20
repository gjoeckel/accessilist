/**
 * Debug Logging Utility
 *
 * Conditionally logs based on ENV.debug setting from .env configuration
 *
 * Usage:
 *   debug.log("Debug message");           // Only shown when DEBUG=true
 *   debug.info("Info message");           // Only shown when DEBUG=true
 *   debug.warn("Warning message");        // ALWAYS shown
 *   debug.error("Error message");         // ALWAYS shown
 *   debug.group("Group name");            // Only in debug mode
 *   debug.groupEnd();                     // Only in debug mode
 *
 * Configuration:
 *   Set in .env file:
 *   - DEBUG_PRODUCTION=false  (clean console)
 *   - DEBUG_LOCAL=true        (verbose logging)
 *   - DEBUG_APACHE_LOCAL=true (verbose logging)
 */

class DebugLogger {
  constructor() {
    // Check if debug mode is enabled from ENV config
    // Default to false for safety (clean console in production)
    this.enabled = false;

    // Wait for ENV config to be available
    this.checkDebugMode();
  }

  /**
   * Check and set debug mode from ENV configuration
   */
  checkDebugMode() {
    // Check if ENV config is available
    if (window.ENV && typeof window.ENV.debug === "boolean") {
      this.enabled = window.ENV.debug;
    } else if (window.basePath !== undefined) {
      // Fallback: check if we're in local development (no basePath)
      this.enabled = window.basePath === "" || window.basePath === "/";
    }

    // Log debug mode status (only once, using native console)
    if (this.enabled) {
      console.log(
        "%c[DEBUG MODE ENABLED]",
        "background: #4CAF50; color: white; padding: 2px 6px; border-radius: 3px;",
        "Verbose logging active"
      );
    } else {
      console.log(
        "%c[PRODUCTION MODE]",
        "background: #2196F3; color: white; padding: 2px 6px; border-radius: 3px;",
        "Debug logs hidden. Errors and warnings still visible."
      );
    }
  }

  /**
   * Debug log - only shown when debug mode enabled
   * Use for: State changes, event tracking, verbose output
   */
  log(...args) {
    if (this.enabled) {
      console.log("[DEBUG]", ...args);
    }
  }

  /**
   * Info log - only shown when debug mode enabled
   * Use for: Informational messages, initialization status
   */
  info(...args) {
    if (this.enabled) {
      console.log("[INFO]", ...args);
    }
  }

  /**
   * Warning - ALWAYS shown (critical for diagnostics)
   * Use for: Non-critical issues, edge cases, fallbacks
   */
  warn(...args) {
    console.warn("[WARN]", ...args);
  }

  /**
   * Error - ALWAYS shown (critical failures)
   * Use for: Errors, exceptions, failed operations
   */
  error(...args) {
    console.error("[ERROR]", ...args);
  }

  /**
   * Grouped debug logs - only in debug mode
   * Use for: Organizing related debug messages
   */
  group(label) {
    if (this.enabled) {
      console.group(`[DEBUG] ${label}`);
    }
  }

  groupEnd() {
    if (this.enabled) {
      console.groupEnd();
    }
  }

  /**
   * Table display - only in debug mode
   * Use for: Displaying objects/arrays in table format
   */
  table(data) {
    if (this.enabled && console.table) {
      console.table(data);
    }
  }

  /**
   * Check if debug mode is enabled
   * Use for: Conditional expensive operations
   */
  isEnabled() {
    return this.enabled;
  }

  /**
   * Force enable debug mode (for troubleshooting)
   * Usage: debug.enable() in browser console
   */
  enable() {
    this.enabled = true;
    console.log(
      "%c[DEBUG MODE ENABLED]",
      "background: #4CAF50; color: white; padding: 2px 6px; border-radius: 3px;",
      "Verbose logging activated"
    );
  }

  /**
   * Force disable debug mode
   * Usage: debug.disable() in browser console
   */
  disable() {
    this.enabled = false;
    console.log(
      "%c[DEBUG MODE DISABLED]",
      "background: #F44336; color: white; padding: 2px 6px; border-radius: 3px;",
      "Verbose logging deactivated"
    );
  }
}

// Create and export global debug instance
window.debug = new DebugLogger();

// Make it available in console for manual control
console.log(
  "%cDebug Utility Loaded",
  "color: #2196F3; font-weight: bold;",
  "- Use debug.enable() or debug.disable() to toggle"
);
