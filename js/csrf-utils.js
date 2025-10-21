/**
 * CSRF Utilities
 *
 * Provides functions to handle CSRF tokens for API requests.
 * CSRF token is automatically included in all POST/PUT/DELETE requests.
 */

/**
 * Get CSRF token from meta tag
 * @returns {string|null} CSRF token or null if not found
 */
function getCsrfToken() {
  const meta = document.querySelector('meta[name="csrf-token"]');
  return meta ? meta.getAttribute("content") : null;
}

/**
 * Fetch wrapper with automatic CSRF token inclusion
 * @param {string} url - URL to fetch
 * @param {object} options - Fetch options
 * @returns {Promise<Response>} Fetch promise
 */
function fetchWithCsrf(url, options = {}) {
  // Clone options to avoid mutating original
  const fetchOptions = { ...options };

  // Add CSRF token for state-changing requests
  const method = (fetchOptions.method || "GET").toUpperCase();
  if (method === "POST" || method === "PUT" || method === "DELETE") {
    const token = getCsrfToken();

    if (token) {
      // Initialize headers if not present
      if (!fetchOptions.headers) {
        fetchOptions.headers = {};
      }

      // Add CSRF token header
      fetchOptions.headers["X-CSRF-Token"] = token;
    } else {
      console.warn("[CSRF] CSRF token not found in page meta tags");
    }
  }

  // DIAGNOSTIC LOGGING - Log request details
  if (window.debug && typeof window.debug.logApiRequest === "function") {
    window.debug.logApiRequest(url, fetchOptions);
  }

  // Make the fetch request and log response
  return fetch(url, fetchOptions).then((response) => {
    // Log response details
    if (window.debug && typeof window.debug.logApiResponse === "function") {
      window.debug.logApiResponse(url, response);
    }
    return response;
  });
}

// Export for use in other modules
if (typeof window !== "undefined") {
  window.getCsrfToken = getCsrfToken;
  window.fetchWithCsrf = fetchWithCsrf;
}
