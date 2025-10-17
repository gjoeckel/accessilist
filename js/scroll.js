/**
 * scroll.js
 *
 * Dynamic scroll buffer system with safe, reliable timing
 *
 * CHECKLIST PAGES (list.php):
 * ---------------------------
 * Method: Dynamic pseudo-element buffer (calculated before scroll)
 * - Top buffer: 90px (fixed - header offset)
 * - Bottom buffer: Dynamic (calculated to stop at add row button)
 * - Calculation: Highest numbered VISIBLE checkpoint's add row button
 * - Target: Button bottom stops 100px from footer top
 * - Timing: Double RAF + 150ms for maximum reliability
 * - Triggers: Page load, side panel button clicks (before scroll)
 *
 * Why this is safe (no bounce):
 * - Updates only on discrete button clicks (not scroll/resize)
 * - Calculates BEFORE scroll happens (not during)
 * - No CSS transition (instant updates)
 * - Generous delays prevent race conditions
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
 * Update bottom buffer for checklist pages
 * Stops scrolling when last visible checkpoint's Add Row button is 100px from footer
 *
 * How it works:
 * 1. Finds all VISIBLE checkpoint sections
 * 2. Gets the highest numbered visible checkpoint (last in array)
 * 3. Finds the Add Row button in that section
 * 4. Calculates buffer so button bottom stops 100px from footer top
 *
 * Triggers: Page load, side panel button clicks
 * Timing: BEFORE scroll happens (not during or after)
 */
window.updateChecklistBottomBuffer = function () {
  console.log("🎯 ========================================");
  console.log("🎯 [Buffer Calc] Function called");

  // Find all VISIBLE checkpoint sections
  const visibleSections = Array.from(
    document.querySelectorAll(".checkpoint-section")
  ).filter((section) => section.style.display !== "none");

  console.log("🎯 [Buffer Calc] Visible sections:", visibleSections.length);

  if (visibleSections.length === 0) {
    console.log("🎯 [Buffer Calc] No visible sections - exiting");
    return;
  }

  // Calculate total height of all visible content
  let totalContentHeight = 0;
  visibleSections.forEach((section) => {
    const height = section.offsetHeight;
    console.log(`🎯 [Buffer Calc] Section ${section.id} height: ${height}px`);
    totalContentHeight += height;
  });

  // Constants
  const viewportHeight = window.innerHeight;
  const topBuffer = 90; // Content always starts 90px from top
  const footerHeight = 50;
  const targetGap = 100;
  const targetMargin = footerHeight + targetGap; // 150px from viewport bottom

  console.log("🎯 [Buffer Calc] ─────────────────────");
  console.log("🎯 [Buffer Calc] Total content:", totalContentHeight + "px");
  console.log("🎯 [Buffer Calc] Viewport:", viewportHeight + "px");
  console.log("🎯 [Buffer Calc] Top buffer:", topBuffer + "px");
  console.log("🎯 [Buffer Calc] Target margin:", targetMargin + "px");

  // PATH A/B Logic: Simple viewport vs content comparison
  const viewportContentDiff = viewportHeight - totalContentHeight;
  console.log(
    "🎯 [Buffer Calc] Viewport - Content difference:",
    viewportContentDiff + "px"
  );

  let buffer;
  let fits;

  if (viewportContentDiff >= 150) {
    // PATH A: Content FITS - hide scrollbar, lock scrolling
    console.log("🎯 [Buffer Calc] >>> PATH A: Content FITS (diff >= 150px)");
    fits = true;
    // PATH A: Content fits - set buffer to 0px to prevent any scroll
    // No extra space = no scroll possible
    buffer = 0;
    console.log(
      "🎯 [Buffer Calc] Buffer calculated to prevent scroll:",
      buffer + "px"
    );
  } else {
    // PATH B: Content DOESN'T FIT - allow scroll (will implement later)
    console.log(
      "🎯 [Buffer Calc] >>> PATH B: Content DOES NOT FIT (diff < 150px)"
    );
    fits = false;
    buffer = 150; // Temporary - will fix in Path B implementation
    console.log("🎯 [Buffer Calc] Buffer set to 150px (temporary)");
  }

  // Set CSS variable (instant, no transition)
  console.log(
    "🎯 [Buffer Calc] Setting CSS variable --bottom-buffer to:",
    buffer + "px"
  );
  document.documentElement.style.setProperty("--bottom-buffer", `${buffer}px`);

  // Toggle no-scroll class based on fits
  const body = document.body;
  if (fits) {
    body.classList.add("no-scroll");
    console.log("🎯 [Buffer Calc] Added 'no-scroll' class - hiding scrollbar");
  } else {
    body.classList.remove("no-scroll");
    console.log(
      "🎯 [Buffer Calc] Removed 'no-scroll' class - showing scrollbar"
    );
  }

  // Verify it was set
  const actualValue = getComputedStyle(
    document.documentElement
  ).getPropertyValue("--bottom-buffer");
  console.log("🎯 [Buffer Calc] CSS variable actual value:", actualValue);

  // Check resulting document height
  setTimeout(() => {
    const docHeight = document.documentElement.scrollHeight;
    console.log("🎯 [Buffer Calc] ─────────────────────");
    console.log("🎯 [Buffer Calc] Final document height:", docHeight + "px");
    console.log(
      "🎯 [Buffer Calc] Expected:",
      topBuffer + totalContentHeight + buffer + "px"
    );
    console.log(
      "🎯 [Buffer Calc] Can scroll?",
      docHeight > viewportHeight ? "YES ⚠️" : "NO ✅"
    );
    console.log("🎯 ========================================");
  }, 50);

  // Visual debug overlay
  let debugDiv = document.getElementById("buffer-debug");
  if (!debugDiv) {
    debugDiv = document.createElement("div");
    debugDiv.id = "buffer-debug";
    debugDiv.style.cssText = `
      position: fixed;
      top: 10px;
      right: 10px;
      background: yellow;
      border: 2px solid red;
      padding: 10px;
      z-index: 10000;
      font-family: monospace;
      font-size: 11px;
      line-height: 1.4;
      max-width: 280px;
    `;
    document.body.appendChild(debugDiv);
  }

  debugDiv.innerHTML = `
    <strong style="color: red;">BUFFER DEBUG</strong><br>
    Viewport: ${viewportHeight}px<br>
    Content: ${totalContentHeight}px<br>
    <strong>Diff: ${viewportContentDiff}px</strong><br>
    <br>
    <strong>Fits? ${fits ? "YES ✅" : "NO ❌"}</strong><br>
    <strong style="color: blue;">Buffer: ${buffer}px</strong><br>
    <br>
    <strong>Scroll? ${fits ? "NO ✅" : "YES ⚠️"}</strong>
  `;
};

/**
 * Safe wrapper with generous delays for maximum reliability
 *
 * Strategy: Double RAF + 150ms timeout
 * - First RAF: Wait for current frame to complete
 * - Second RAF: Wait for layout to be fully applied
 * - setTimeout(150ms): Extra safety margin for any remaining layout work
 *
 * Total delay: ~170ms (imperceptible to humans, well under 2s threshold)
 *
 * Why this is reliable:
 * - Ensures DOM changes are complete
 * - Ensures browser layout calculations are done
 * - Prevents race conditions
 * - Prioritizes correctness over speed (Simple & Reliable principle)
 */
window.safeUpdateChecklistBuffer = function () {
  requestAnimationFrame(() => {
    // Wait for next paint
    requestAnimationFrame(() => {
      // Wait for one more paint
      setTimeout(() => {
        // Wait 150ms more
        window.updateChecklistBottomBuffer();
      }, 150);
    });
  });
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

// Export API for both checklist and report pages
window.ScrollManager = {
  // Checklist page functions
  updateChecklistBuffer: window.updateChecklistBottomBuffer,
  safeUpdateChecklistBuffer: window.safeUpdateChecklistBuffer,

  // Report page functions
  updateReportBuffer: window.updateReportBuffer,
  scheduleReportBufferUpdate: window.scheduleReportBufferUpdate,
};
