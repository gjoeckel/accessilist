/**
 * scroll.js
 *
 * Simple Path A/B scroll system for checklist pages
 *
 * CHECKLIST PAGES (list.php):
 * ---------------------------
 * - Top buffer: 90px fixed (header offset via CSS pseudo-element)
 * - Path A: Content fits → hide scrollbar, no bottom buffer
 * - Path B: Content doesn't fit → show scrollbar, 100px bottom buffer
 *
 * REPORT PAGES (list-report.php, systemwide-report.php):
 * ------------------------------------------------------
 * - Top buffer: 120px (header + filters)
 * - Bottom buffer: Calculated on filter change
 * - Updates ONLY when filters change (not during scroll)
 */

/**
 * Update checklist buffer based on Path A/B logic
 * Calculates whether content fits and shows/hides scrollbar accordingly
 */
window.updateChecklistBuffer = function () {
  // Find all VISIBLE checkpoint sections
  const visibleSections = Array.from(
    document.querySelectorAll(".checkpoint-section")
  ).filter((section) => section.style.display !== "none");

  if (visibleSections.length === 0) {
    return;
  }

  // Calculate total height of all visible content
  let totalContentHeight = 0;
  visibleSections.forEach((section) => {
    totalContentHeight += section.offsetHeight;
  });

  // Get viewport height from DOM
  const viewportHeight = window.innerHeight;

  // Constants
  const footerHeight = 50;
  const desiredGap = 100;

  // Calculate if content fits
  // viewport - (content + footer + gap)
  const result =
    viewportHeight - (totalContentHeight + footerHeight + desiredGap);

  const body = document.body;

  if (result >= 0) {
    // PATH A: Content FITS - hide scrollbar
    body.classList.add("no-scroll");
  } else {
    // PATH B: Content DOESN'T FIT - show scrollbar
    body.classList.remove("no-scroll");
  }
};

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

// Export API
window.ScrollManager = {
  // Checklist page function
  updateChecklistBuffer: window.updateChecklistBuffer,

  // Report page functions
  updateReportBuffer: window.updateReportBuffer,
  scheduleReportBufferUpdate: window.scheduleReportBufferUpdate,
};
