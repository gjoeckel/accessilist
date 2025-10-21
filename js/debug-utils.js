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

  /**
   * CSRF DIAGNOSTIC LOGGING - ALWAYS ON
   * Logs session/cookie/CSRF state for debugging 403 errors
   */
  logCsrfDiagnostics() {
    console.group(
      "%c🔍 CSRF DIAGNOSTICS",
      "background: #FF9800; color: white; padding: 4px 8px; font-weight: bold;"
    );

    // 1. Check CSRF token in meta tag
    const csrfToken = document
      .querySelector('meta[name="csrf-token"]')
      ?.getAttribute("content");
    console.log(
      "1️⃣ CSRF Token (meta tag):",
      csrfToken ? `✅ Present (${csrfToken.length} chars)` : "❌ MISSING"
    );
    if (csrfToken) {
      console.log("   Token:", csrfToken);
    }

    // 2. Check all cookies
    const cookies = document.cookie
      .split(";")
      .map((c) => c.trim())
      .filter((c) => c.length > 0);
    console.log("2️⃣ Cookies:", cookies.length > 0 ? cookies : "❌ NO COOKIES");
    if (cookies.length > 0) {
      cookies.forEach((cookie) => {
        const [name, value] = cookie.split("=");
        if (name && value) {
          if (name.includes("PHPSESSID") || name.includes("sess")) {
            console.log(`   🔑 ${name} = ${value.substring(0, 10)}...`);
          } else {
            console.log(`   ${name} = ${value.substring(0, 20)}...`);
          }
        }
      });
    } else {
      console.log("ℹ️  No cookies (expected - using origin-based security)");
      console.log(
        "   Application uses Origin header validation instead of cookies"
      );
      console.log(
        "   This is more privacy-friendly and works with cookie blockers"
      );
    }

    // 3. Check session storage
    console.log(
      "3️⃣ Session Storage:",
      sessionStorage.length > 0 ? `${sessionStorage.length} items` : "Empty"
    );

    // 4. Check if fetchWithCsrf is available
    console.log(
      "4️⃣ fetchWithCsrf():",
      typeof window.fetchWithCsrf === "function"
        ? "✅ Available"
        : "❌ NOT LOADED"
    );

    // 5. Check ENV config
    console.log("5️⃣ ENV Config:", window.ENV ? window.ENV : "❌ NOT LOADED");

    console.groupEnd();
  }

  /**
   * Log API request details before sending
   * Call this before fetch() to track what's being sent
   */
  logApiRequest(url, options) {
    console.group(
      `%c🌐 API REQUEST: ${url}`,
      "background: #2196F3; color: white; padding: 4px 8px;"
    );
    console.log("URL:", url);
    console.log("Method:", options.method || "GET");
    console.log("Headers:", options.headers || "None");
    console.log("Body:", options.body || "None");
    console.log("Credentials:", options.credentials || "Default");

    // Check if CSRF token is included
    if (options.headers && options.headers["X-CSRF-Token"]) {
      console.log(
        "✅ CSRF Token:",
        options.headers["X-CSRF-Token"].substring(0, 16) + "..."
      );
    } else if (
      options.method === "POST" ||
      options.method === "PUT" ||
      options.method === "DELETE"
    ) {
      console.warn(
        "⚠️ WARNING: No CSRF token in " + options.method + " request!"
      );
    }

    console.groupEnd();
  }

  /**
   * Log API response details
   */
  logApiResponse(url, response) {
    const statusColor = response.ok ? "#4CAF50" : "#F44336";
    console.group(
      `%c📥 API RESPONSE: ${url}`,
      `background: ${statusColor}; color: white; padding: 4px 8px;`
    );
    console.log("Status:", response.status, response.statusText);
    console.log("OK:", response.ok);
    console.log("Headers:", [...response.headers.entries()]);

    if (!response.ok) {
      console.error("❌ Request failed! Status:", response.status);
      if (response.status === 403) {
        console.error("🚫 403 FORBIDDEN - Likely CSRF token issue!");
        console.error("Check:");
        console.error("  1. Is CSRF token in meta tag?");
        console.error("  2. Is session cookie being sent?");
        console.error("  3. Are cookies enabled?");
        console.error("  4. Is cookie path correct?");
      }
    }

    console.groupEnd();
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
