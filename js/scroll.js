/**
 * scroll.js
 *
 * Pure CSS scroll buffer system with minimal JavaScript
 *
 * CHECKLIST PAGES (list.php):
 * ---------------------------
 * Method: Fixed pseudo-element buffers (pure CSS)
 * - Top buffer: 90px (header offset)
 * - Bottom buffer: 20000px (scroll space for all checkpoints)
 * - No JavaScript involvement in scroll physics
 * - Browser handles all scrolling naturally
 *
 * Scroll Calculations:
 * - "All" button: scrollTo(0, 0) - top of page
 * - Checkpoint buttons: scrollTo(section.offsetTop - 90)
 * - No dynamic updates during user interaction
 *
 * REPORT PAGES (list-report.php, systemwide-report.php):
 * ------------------------------------------------------
 * Method: Dynamic buffer (JavaScript) for filter changes only
 * - Top buffer: 120px (header + filters)
 * - Bottom buffer: Calculated on filter change
 * - Updates ONLY when filters change (not during scroll)
 * - Prevents unnecessary scrollbar when few results
 */

/**
 * Update report page buffer
 * Only for report pages - updates on filter changes, not scroll
 * Target: Last row at 400px from viewport top
 */
window.updateReportBuffer = function () {
  const reportSection = document.querySelector(".report-section");
  if (!reportSection) {
    return;
  }

  const table = reportSection.querySelector(".report-table, .reports-table");
  if (!table) {
    return;
  }

  const reportContentHeight = reportSection.offsetHeight;
  const viewportHeight = window.innerHeight;
  const topBuffer = 120;
  const targetPosition = 400;

  let optimalBuffer;

  if (reportContentHeight > viewportHeight - topBuffer) {
    // Content larger than viewport
    optimalBuffer = Math.max(0, viewportHeight - targetPosition);
  } else {
    // Content fits in viewport - minimal buffer for footer spacing
    optimalBuffer = 100;
  }

  // Set CSS custom property
  document.documentElement.style.setProperty(
    "--bottom-buffer-report",
    `${optimalBuffer}px`
  );
};

/**
 * Schedule report buffer update with minimal debounce
 * Only used for report pages when filters change
 */
window.scheduleReportBufferUpdate = function () {
  setTimeout(() => {
    window.updateReportBuffer();
  }, 100);
};

// Export minimal API (only for report pages)
window.ScrollManager = {
  updateReportBuffer: window.updateReportBuffer,
  scheduleReportBufferUpdate: window.scheduleReportBufferUpdate,
};
