/**
 * buildCheckpoints.js
 *
 * This script is responsible for:
 * 1. Fetching the JSON data
 * 2. Generating checkpoint sections dynamically
 * 3. Building tables for each checkpoint
 */

// buildReportsSection import removed - reports now handled on separate page

// Old modal HTML removed - now using SimpleModal system

// Table configuration
const TABLE_CONFIG = {
  headers: [
    { text: "Tasks", class: "task-cell" },
    { text: "Info", class: "info-cell" },
    { text: "Notes", class: "notes-cell" },
    { text: "Status", class: "status-cell" },
  ],
};

// State management functions
function saveState(id, state) {
  const currentState = getState() || {};
  currentState[id] = state;
  sessionStorage.setItem("checklistState", JSON.stringify(currentState));
}

function getState() {
  const state = sessionStorage.getItem("checklistState");
  return state ? JSON.parse(state) : null;
}

// Function to create a checkpoint section
function createCheckpointSection(checkpointId, data) {
  const section = document.createElement("section");
  section.id = checkpointId;
  section.className = `checkpoint-section ${checkpointId}`;

  // Create simplified heading with number icon
  const heading = document.createElement("h2");
  heading.id = `${checkpointId}-caption`;
  heading.className = "checklist-caption";

  // Extract checkpoint/checklist number dynamically (supports checkpoint-N or checklist-N)
  const match = checkpointId.match(/(?:checkpoint|checklist)-(\d+)/);
  const tableNumber = match ? match[1] : null;

  if (!tableNumber) {
    console.warn(`Unknown checkpoint ID format: ${checkpointId}`);
  }

  // Only set aria-label if we have a valid table number
  if (tableNumber) {
    heading.setAttribute("aria-label", `Table ${tableNumber}: ${data.caption}`);
  } else {
    heading.setAttribute("aria-label", data.caption);
  }

  // Make the heading focusable for keyboard users
  heading.setAttribute("tabindex", "0");

  // Add data attribute for CSS-generated number (replaces SVG icon)
  if (tableNumber) {
    heading.setAttribute("data-number", tableNumber);
  }

  // Add caption text directly to heading
  const captionText = document.createTextNode(` ${data.caption}`);
  heading.appendChild(captionText);

  section.appendChild(heading);

  // Create container
  const container = document.createElement("div");
  container.className = "guidelines-container";
  section.appendChild(container);

  return section;
}

// Function to build table
function buildTable(rows, checkpointId) {
  const table = document.createElement("table");
  table.className = "checkpoints-table";
  table.setAttribute("role", "table");
  table.setAttribute("aria-label", "Checkpoints Checklist");
  // Associate table with its heading as a pseudo-caption
  table.setAttribute("aria-labelledby", `${checkpointId}-caption`);

  // Create table header
  const thead = document.createElement("thead");
  const headerRow = document.createElement("tr");

  const taskHeader = document.createElement("th");
  taskHeader.className = "task-cell";
  taskHeader.textContent = "Tasks";

  const infoHeader = document.createElement("th");
  infoHeader.className = "info-cell";
  infoHeader.textContent = "Info";

  const notesHeader = document.createElement("th");
  notesHeader.className = "notes-cell";
  notesHeader.textContent = "Notes";

  const statusHeader = document.createElement("th");
  statusHeader.className = "status-cell";
  statusHeader.textContent = "Status";

  const restartHeader = document.createElement("th");
  restartHeader.className = "restart-cell";
  restartHeader.textContent = "Reset";

  headerRow.appendChild(taskHeader);
  headerRow.appendChild(infoHeader);
  headerRow.appendChild(notesHeader);
  headerRow.appendChild(statusHeader);
  headerRow.appendChild(restartHeader);
  thead.appendChild(headerRow);
  table.appendChild(thead);

  // Create table body
  const tbody = document.createElement("tbody");
  tbody.setAttribute("role", "rowgroup");

  // Add rows for each checkpoint
  rows.forEach((row) => {
    const tr = document.createElement("tr");
    tr.setAttribute("role", "row");
    tr.setAttribute("data-id", row.id);
    tr.className = "checkpoint-row";
    tbody.appendChild(tr);

    // Add cells in correct order
    const cells = [
      { text: row.task, className: "task-cell" },
      { className: "info-cell" },
      { className: "notes-cell" },
      { className: "status-cell" },
      { className: "restart-cell" },
    ];

    cells.forEach((cell) => {
      const td = document.createElement("td");
      td.className = cell.className;
      td.setAttribute("role", "cell");
      tr.appendChild(td);

      if (cell.text) {
        td.textContent = cell.text;
      }
    });

    // Add info links to info cell
    const infoCell = tr.querySelector(".info-cell");
    const infoButton = document.createElement("button");
    infoButton.className = "info-link";
    infoButton.setAttribute("aria-label", `Show example for ${row.task}`);

    const infoImg = document.createElement("img");
    infoImg.src = window.getImagePath("info-.svg");
    infoImg.alt = "";
    infoButton.appendChild(infoImg);

    // Add click handler for modal using SimpleModal
    infoButton.addEventListener("click", () => {
      // Truncate title at last complete word within character limit
      const maxLength = 50; // Adjust this value as needed
      const words = row.task.split(" ");
      let truncatedTitle = "";

      for (const word of words) {
        if ((truncatedTitle + " " + word).length <= maxLength) {
          truncatedTitle += (truncatedTitle ? " " : "") + word;
        } else {
          break;
        }
      }

      // Use SimpleModal for info display
      if (window.simpleModal) {
        window.simpleModal.info(
          truncatedTitle,
          row.example || "No example available.",
          () => {}
        );
      } else {
        console.error("SimpleModal not available");
      }
    });

    infoCell.appendChild(infoButton);

    // Add notes textarea
    const notesCell = tr.querySelector(".notes-cell");
    const textarea = document.createElement("textarea");
    textarea.className = "notes-textarea";
    textarea.setAttribute("aria-label", `Notes for ${row.task}`);
    textarea.id = `textarea-${row.id}`;
    notesCell.appendChild(textarea);

    // Add status button
    const statusCell = tr.querySelector(".status-cell");
    const statusButton = document.createElement("button");
    statusButton.className = "status-button";
    statusButton.setAttribute("data-state", "ready");
    statusButton.setAttribute("aria-label", "Task status: Ready");
    statusButton.setAttribute("data-id", row.id);
    statusButton.setAttribute("data-status-flag", "text-manual"); // Initialize flag for auto-status feature
    statusButton.id = `status-${row.id}`;
    const readyImgPath = window.getImagePath("ready-1.svg");
    statusButton.innerHTML = `<img src="${readyImgPath}" alt="">`;
    statusCell.appendChild(statusButton);

    // Add restart button
    const restartCell = tr.querySelector(".restart-cell");
    const restartButton = document.createElement("button");
    restartButton.className = "restart-button";
    restartButton.type = "button";
    restartButton.setAttribute("aria-label", "Reset task to Ready");
    restartButton.setAttribute("data-id", row.id);
    restartButton.id = `restart-${row.id}`;
    const restartImgPath = window.getImagePath("reset.svg");
    restartButton.innerHTML = `<img src="${restartImgPath}" alt="Reset task">`;
    restartButton.classList.add("restart-hidden"); // Initially hidden
    restartCell.appendChild(restartButton);

    // Event handlers removed - now handled by StateEvents.js global event delegation
    // Status button clicks, textarea input, and reset button clicks are managed centrally
  });

  table.appendChild(tbody);

  // Create Add Row button container
  const buttonContainer = document.createElement("div");
  buttonContainer.className = "checkpoints-buttons";

  // Create Add Row button
  const addButton = document.createElement("button");
  addButton.className = "checkpoints-button add-row-button";
  addButton.id = `addRow-${checkpointId}`;
  addButton.setAttribute("data-checkpoint", checkpointId);
  addButton.setAttribute("aria-label", `Add new task to ${checkpointId}`);

  // CSS-generated plus icon (no SVG needed)

  // Add button to container
  buttonContainer.appendChild(addButton);

  // Event listener will be attached by initializeCheckpointAddRowButtons() in addRow.js
  // This ensures proper initialization timing and prevents duplicate event listeners

  // Create wrapper div to contain both table and button
  const wrapper = document.createElement("div");
  wrapper.className = "checkpoints-table-wrapper";
  wrapper.appendChild(table);
  wrapper.appendChild(buttonContainer);

  return wrapper;
}

/**
 * Handles adding a new row to a checkpoints table
 * @param {string} checkpointId - The ID of the checkpoint (e.g., 'checklist-1')
 */
function handleAddCheckpointRow(checkpointId) {
  if (!window.unifiedStateManager) {
    console.error("StateManager not available - cannot add checkpoint row");
    return;
  }

  // Use StateManager method for consistent data creation
  const newRowData = window.unifiedStateManager.createCheckpointRowData({
    checkpointId: checkpointId,
    task: "",
    notes: "",
    status: "ready",
    isManual: true,
  });

  // Add using StateManager method
  window.unifiedStateManager.addCheckpointRow(newRowData, true);

  // Set focus on the task textarea for manual rows - reduced timeout to prevent race conditions
  setTimeout(() => {
    const currentTable = document.querySelector(
      `#${checkpointId} .checkpoints-table tbody`
    );
    if (currentTable) {
      const newRow = currentTable.querySelector(
        `tr[data-id="${newRowData.id}"]`
      );
      if (newRow) {
        const taskTextarea = newRow.querySelector(".task-input");
        if (taskTextarea) {
          taskTextarea.focus();
        }
      }
    }

    // Recalculate buffer after row is added
    if (typeof window.ScrollManager?.updateChecklistBuffer === "function") {
      window.ScrollManager.updateChecklistBuffer();
    }
  }, 50); // Reduced from 100ms to 50ms
}

// Make function globally available
window.handleAddCheckpointRow = handleAddCheckpointRow;

// createReportSection function removed - reports now handled on separate page

// storeCompletedTask function removed - now handled by StateEvents.js

// Function to build all content
async function buildContent(data) {
  try {
    const main = document.querySelector("main");
    if (!main) {
      throw new Error("Main element not found");
    }

    // Clear existing content
    main.innerHTML = "";

    // Filter and sort checkpoint keys
    const checkpointKeys = Object.keys(data)
      .filter(
        (key) => key.startsWith("checkpoint-") || key.startsWith("checklist-")
      ) // Support both new and legacy
      .sort((a, b) => {
        const numA = parseInt(a.split("-")[1]);
        const numB = parseInt(b.split("-")[1]);
        return numA - numB;
      });

    checkpointKeys.forEach((checkpointKey) => {
      const checkpointData = data[checkpointKey];

      const section = createCheckpointSection(checkpointKey, checkpointData);
      if (section) {
        const tableWrapper = buildTable(checkpointData.table, checkpointKey);
        section
          .querySelector(".guidelines-container")
          .appendChild(tableWrapper);
        main.appendChild(section);
      }
    });

    // Add Report section (consistent across all checklist types)
    // TEMPORARILY COMMENTED OUT - Report functionality is interfering with checkpoint rows
    // const reportSection = createReportSection();
    // main.appendChild(reportSection);

    // Dispatch event to signal content is built
    const contentBuiltEvent = new CustomEvent("contentBuilt");
    document.dispatchEvent(contentBuiltEvent);
  } catch (error) {
    console.error("Error building content:", error);
    throw error; // Re-throw to be caught by initializeApp
  }
}

// Export the function
export { buildContent };
