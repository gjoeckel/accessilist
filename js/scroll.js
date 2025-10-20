/**
 * scroll.js
 *
 * Simple scroll buffer system for checklist pages
 *
 * CHECKLIST PAGES (list.php):
 * ---------------------------
 * - Top buffer: 90px fixed (header offset via CSS pseudo-element)
 * - Content always starts 90px from viewport top
 * - No dynamic calculations needed
 *
 * REPORT PAGES (list-report.php, systemwide-report.php):
 * ------------------------------------------------------
 * - Top buffer: 120px (header + filters)
 * - Bottom buffer: Calculated on filter change
 * - Updates ONLY when filters change (not during scroll)
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

// Export API for report pages
window.ScrollManager = {
  updateReportBuffer: window.updateReportBuffer,
  scheduleReportBufferUpdate: window.scheduleReportBufferUpdate,
};
