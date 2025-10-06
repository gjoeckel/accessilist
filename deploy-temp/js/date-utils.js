/**
 * Date Utilities - Centralized date formatting
 * 
 * RESPONSIBILITY: Consistent date formatting across the application
 * - Provides single source of truth for date formats
 * - Ensures consistency across manual rows, admin timestamps, and report entries
 */

/**
 * Format a date as MM-DD-YY (e.g., "10-02-25")
 * @param {Date|number|null} date - Date object, timestamp in milliseconds, or null for current date
 * @returns {string} Formatted date string (MM-DD-YY)
 */
function formatDateShort(date = null) {
  const d = date ? (typeof date === 'number' ? new Date(date) : date) : new Date();
  return d.toLocaleDateString('en-US', {
    month: '2-digit',
    day: '2-digit',
    year: '2-digit'
  }).replace(/\//g, '-');
}

/**
 * Format a timestamp for admin display (full date and time)
 * @param {number} timestamp - Timestamp in milliseconds
 * @returns {string} Formatted date string (e.g., "10/2/2025, 3:45:30 PM")
 */
function formatDateLong(timestamp) {
  const date = new Date(timestamp);
  return date.toLocaleString('en-US', {
    month: 'numeric',
    day: 'numeric',
    year: 'numeric',
    hour: 'numeric',
    minute: '2-digit',
    second: '2-digit',
    hour12: true
  });
}

/**
 * Format a timestamp for admin display with short date (MM-DD-YY + time)
 * @param {number} timestamp - Timestamp in milliseconds
 * @returns {string} Formatted date string (e.g., "10-02-25 3:45 PM")
 */
function formatDateAdmin(timestamp) {
  const date = new Date(timestamp);
  const dateStr = formatDateShort(date);
  const timeStr = date.toLocaleTimeString('en-US', {
    hour: 'numeric',
    minute: '2-digit',
    hour12: true
  });
  return `${dateStr} ${timeStr}`;
}

// Export for ES6 modules
export { formatDateShort, formatDateLong, formatDateAdmin };

// Also expose globally for non-module scripts
if (typeof window !== 'undefined') {
  window.formatDateShort = formatDateShort;
  window.formatDateLong = formatDateLong;
  window.formatDateAdmin = formatDateAdmin;
}

