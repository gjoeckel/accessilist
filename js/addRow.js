/**
 * addRow.js
 *
 * Handles the functionality for the 'Add Row' button in the Report section.
 */

/**
 * Creates a table row element (<tr>) with appropriate cells (<td>) based on the table type.
 * @param {object} rowData - Data for the row (e.g., { id, task, notes, status, date, infoLink, isManual }).
 * @param {string} tableType - Type of table ('checkpoint' or 'report').
 * @returns {HTMLTableRowElement} The created table row element.
 */
function createTableRow(rowData, tableType) {
  const tr = document.createElement("tr");
  tr.setAttribute("data-id", rowData.id || `manual-${Date.now()}`); // Use provided ID or generate one for manual

  if (tableType === "checkpoint") {
    tr.className = "checkpoint-row";
    if (rowData.isManual) {
      tr.classList.add("manual-row");
    }
    tr.setAttribute("role", "row");

    // --- Checkpoint Cells ---
    // Order: Task, Info, Notes, Status, Restart (matching buildCheckpoints.js thead order)

    // 1. Task Cell
    const taskCell = document.createElement("td");
    taskCell.className = "task-cell";
    taskCell.setAttribute("role", "cell");

    if (rowData.isManual) {
      // Manual rows: editable textarea (matching notes textarea exactly)
      const taskTextarea = document.createElement("textarea");
      taskTextarea.className = "task-input";
      taskTextarea.setAttribute("aria-label", "Task description");
      taskTextarea.value = rowData.task || "";
      taskTextarea.placeholder = "Enter task description...";
      taskTextarea.rows = 1; // Start with single row, auto-expand
      taskCell.appendChild(taskTextarea);
    } else {
      // Default rows: static text
      taskCell.textContent = rowData.task || "";
    }
    tr.appendChild(taskCell);

    // 2. Info Cell
    const infoCell = document.createElement("td");
    infoCell.className = "info-cell";
    infoCell.setAttribute("role", "cell");

    if (rowData.isManual) {
      // Manual rows: no info resources available, show placeholder
      infoCell.textContent = "-";
      infoCell.style.textAlign = "center";
      infoCell.style.color = "#666";
    } else {
      // Default rows: info button with icon
      const infoButton = document.createElement("button");
      infoButton.className = "info-link";
      infoButton.setAttribute(
        "aria-label",
        `Show example for ${rowData.task || "this task"}`
      );
      const infoImgPath = window.getImagePath("info-.svg");
      infoButton.innerHTML = `<img src="${infoImgPath}" alt="">`;
      // TODO: Add event listeners (hover, focus, click for modal) - Likely attached elsewhere
      infoCell.appendChild(infoButton);
    }
    tr.appendChild(infoCell);

    // 3. Notes Cell
    const notesCell = document.createElement("td");
    notesCell.className = "notes-cell";
    notesCell.setAttribute("role", "cell");
    const notesTextarea = document.createElement("textarea");
    notesTextarea.className = "notes-textarea";
    notesTextarea.setAttribute(
      "aria-label",
      `Notes for ${rowData.task || "this task"}`
    );
    notesTextarea.id = `textarea-${rowData.id || Date.now()}`;
    notesTextarea.value = rowData.notes || "";
    notesTextarea.rows = 1;
    notesCell.appendChild(notesTextarea);
    tr.appendChild(notesCell);

    // 4. Status Cell
    const statusCell = document.createElement("td");
    statusCell.className = "status-cell";
    statusCell.setAttribute("role", "cell");
    const statusButton = document.createElement("button");
    statusButton.className = "status-button";
    const initialState = rowData.status || "ready"; // Status value: ready/active/done
    statusButton.setAttribute("data-state", initialState);
    statusButton.setAttribute("data-id", rowData.id);
    statusButton.setAttribute(
      "data-status-flag",
      rowData.statusFlag || "text-manual"
    ); // Initialize flag for auto-status feature

    // Map status to icon filename
    const iconMap = {
      ready: "ready-1.svg",
      active: "active-1.svg",
      done: "done-1.svg",
    };
    const statusIcon = iconMap[initialState] || "ready-1.svg";
    const statusLabel =
      initialState === "active"
        ? "Active"
        : initialState.charAt(0).toUpperCase() + initialState.slice(1);

    statusButton.setAttribute("aria-label", `Task status: ${statusLabel}`);
    const statusImgPath = window.getImagePath(statusIcon);
    statusButton.innerHTML = `<img src="${statusImgPath}" alt="">`;
    statusButton.id = `status-${rowData.id}`; // Add ID for flag system lookup
    // TODO: Add event listeners (click for state change) - Likely attached elsewhere
    statusCell.appendChild(statusButton);
    tr.appendChild(statusCell);

    // 5. Restart Cell
    const restartCell = document.createElement("td");
    restartCell.className = "restart-cell";
    restartCell.setAttribute("role", "cell");
    const restartButton = document.createElement("button");
    restartButton.className = "restart-button";
    restartButton.setAttribute("data-id", rowData.id);
    restartButton.setAttribute(
      "aria-label",
      `Restart task ${rowData.task || "this task"}`
    );
    const restartImgPath = window.getImagePath("reset.svg");
    restartButton.innerHTML = `<img src="${restartImgPath}" alt="">`;
    restartButton.disabled = initialState !== "done"; // Only enable restart if done
    restartButton.classList.add(
      initialState === "done" ? "restart-visible" : "restart-hidden"
    ); // Show restart button for done rows
    // TODO: Add event listeners (hover, focus, click for modal) - Likely attached elsewhere
    restartCell.appendChild(restartButton);
    tr.appendChild(restartCell);
  } else if (tableType === "report") {
    // Report table handling removed - reports now on separate page
    console.warn(
      "Report table type no longer supported - use systemwide-report.php page"
    );
    const errorCell = document.createElement("td");
    errorCell.textContent =
      "Report functionality moved to systemwide-report.php";
    errorCell.colSpan = 5;
    tr.appendChild(errorCell);
  } else {
    console.error(`Invalid tableType specified: ${tableType}`);
    // Optionally return an empty row or throw an error
    const errorCell = document.createElement("td");
    errorCell.textContent = "Error: Invalid table type";
    errorCell.colSpan = 5; // Span across expected columns
    tr.appendChild(errorCell);
  }

  return tr;
}

// handleAddRow function removed - report functionality moved to systemwide-report.php

// Expose functions for global access
// window.addManualReportRow removed - report functionality moved to systemwide-report.php
window.createTableRow = createTableRow;

/**
 * Attaches event listeners to all checkpoint add row buttons.
 * Should be called after the DOM is loaded and the buttons exist.
 */
function initializeCheckpointAddRowButtons() {
  // Select ONLY Add Row buttons (not side panel navigation buttons)
  // Add Row buttons have class 'checkpoints-button' and data-checkpoint attribute
  const checkpointButtons = document.querySelectorAll(
    'button.checkpoints-button[data-checkpoint^="checklist-"], button.checkpoints-button[data-checkpoint^="checkpoint-"]'
  );
  debug.log(`Found ${checkpointButtons.length} checkpoint add row buttons`);

  checkpointButtons.forEach((button) => {
    const checkpointId = button.getAttribute("data-checkpoint");
    debug.log(`Initializing button for ${checkpointId}`);

    // Add event listener for the Add Row button
    button.addEventListener("click", (event) => {
      event.preventDefault();
      debug.log(`Add button clicked for ${checkpointId}`);
      if (typeof window.handleAddCheckpointRow === "function") {
        window.handleAddCheckpointRow(checkpointId);
      } else {
        console.error("handleAddCheckpointRow function not available");
      }
    });

    debug.log(`Event listener attached to button for ${checkpointId}`);
  });

  debug.log("All checkpoint add row buttons initialized");
}

// Initialization logic:
// Since this script is loaded as a module (implied by import/export),
// simply calling initializeAddRowButton() at the top level might be fine,
// but it depends on *when* this module is loaded relative to the DOM
// and the creation of the #addRow button in main.js.
// A safer approach for modules is often to export the initialization function
// and have the main script (main.js) import and call it at the appropriate time.

// Export the function(s) needed by other modules (if any)
// Let's export the initializer for potential use by main.js.
export { initializeCheckpointAddRowButtons };
