/**
 * main.js
 *
 * This script is responsible for:
 * 1. Initializing the application
 * 2. Setting up event listeners for checkpoint selection buttons
 * 3. Handling checkpoint switching
 * 4. Coordinating functionality from other modules
 */

import { buildContent } from "./buildCheckpoints.js";
// buildReportsSection import removed - reports now handled on separate page
import { initializeCheckpointAddRowButtons } from "./addRow.js";

// Legacy functions completely removed - StateEvents.js handles all interactions

// Function to handle report row delete button clicks
// Already expects the button as an argument
function handleDeleteReportRowClick(event) {
  const button = event.currentTarget;
  const row = button.closest(".report-row");
  if (!row) return;

  // Remove the row from the table
  row.remove();

  // Trigger save after deleting row
  if (window.saveRestoreOrchestrator) {
    window.saveRestoreOrchestrator.saveState().catch((error) => {
      console.error("Failed to save state after deleting row:", error);
    });
  }
}

// Function to handle delete row button
function handleDeleteRow(event) {
  event.preventDefault();
  const manualRows = document.querySelectorAll(".report-table tbody tr.manual");
  if (manualRows.length > 0) {
    // Remove the last manual row
    manualRows[manualRows.length - 1].remove();

    // Set focus to the Report link in the side panel
    const reportLink = document.querySelector('.side-panel a[href="#report"]');
    if (reportLink) {
      reportLink.focus();
    }
  }
}

// Function to handle task completion
function handleTaskCompletion(event) {
  const button = event.currentTarget;
  const row = button.closest(".report-row");
  if (!row) return;

  const statusSelect = row.querySelector(".report-status");
  if (!statusSelect) return;

  const currentStatus = statusSelect.value;
  const statuses = ["Not Started", "In Progress", "Completed"];
  const currentIndex = statuses.indexOf(currentStatus);
  const nextIndex = (currentIndex + 1) % statuses.length;
  statusSelect.value = statuses[nextIndex];
}

// --- Debounced Save Helper ---
// Note: debouncedSaveContent is now defined in save-restore.js using the debounce utility

// Function to get checklist type using TypeManager
async function getChecklistType() {
  // STRICT MODE: No fallback - fail if type can't be determined
  const type = await TypeManager.getTypeFromSources();

  if (!type) {
    throw new Error(
      "Failed to determine checklist type - check URL parameters and session data"
    );
  }

  return type;
}

// Report table delegation removed - StateEvents.js handles all interactions

// Function to initialize the application
async function initializeApp() {
  const checklistType = await getChecklistType();

  try {
    // Fetch the appropriate JSON data
    const jsonPath = window.getJSONPath(`${checklistType}.json`);
    const response = await fetch(jsonPath);
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    const data = await response.json();

    // Make checklist data globally available
    window.checklistData = data;

    // Update document title and header
    document.title = `${data.type} Accessibility Checklist`;
    const header = document.querySelector(".sticky-header h1");
    if (header) {
      header.textContent = `${data.type} Accessibility Checklist`;
    }

    // Initialize side panel with checkpoint data
    let sidePanel = null;
    if (window.SidePanel) {
      sidePanel = new window.SidePanel();
      sidePanel.init(data);
    } else {
      console.error(
        "SidePanel class not available - side panel will not render"
      );
    }

    // Build content with the fetched data
    await buildContent(data);

    // Schedule bottom buffer calculation (500ms delay for DOM to settle)
    if (typeof window.scheduleBufferUpdate === "function") {
      window.scheduleBufferUpdate();
    }

    // Apply selected styling to all checkpoints AFTER content is built
    if (sidePanel) {
      sidePanel.applyAllCheckpointsActive();
    }

    // Initialize other functionality
    if (typeof initializeChecklist === "function") initializeChecklist();
    if (typeof initializeReport === "function") initializeReport();
    if (typeof initializeSaveRestore === "function") initializeSaveRestore();
    if (typeof initializePrint === "function") initializePrint();
    if (typeof initializeKeyboardNavigation === "function")
      initializeKeyboardNavigation();
    if (typeof initializeAccessibilityFeatures === "function")
      initializeAccessibilityFeatures();

    // Hide loading overlay only if there's no session key (no restoration happening)
    const urlParams = new URLSearchParams(window.location.search);
    const sessionKey = urlParams.get("session");
    if (!sessionKey && typeof hideLoading === "function") {
      hideLoading();
    }
  } catch (error) {
    console.error("Error initializing app:", error);
    const loadingText = document.getElementById("loadingText");
    if (loadingText) {
      loadingText.textContent = "Error loading checklist. Please try again.";
    }
    // Ensure loading overlay is hidden
    if (typeof hideLoading === "function") {
      hideLoading();
    }
  }
}

// Initialize the app when the DOM is fully loaded
// NOTE: This is now handled by the modular save/restore system
// document.addEventListener('DOMContentLoaded', () => {
//     initializeApp();
//     // No need for event delegation or mutation observer for report table
// });

// Initialize Add Row buttons after content is built
document.addEventListener("contentBuilt", () => {
  initializeCheckpointAddRowButtons();
});

// Export initializeApp for potential use elsewhere (e.g., testing)
window.initializeApp = initializeApp;

// All report table and status management now in StateEvents.js
