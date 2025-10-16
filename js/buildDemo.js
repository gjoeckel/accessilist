/**
 * buildDemo.js
 *
 * Demo-specific version of buildCheckpoints.js with special features:
 * 1. Inline image support: [image-name.svg] → renders actual image
 * 2. Custom demo-specific transformations
 * 3. All other functionality same as buildCheckpoints.js
 */

// Table configuration
const TABLE_CONFIG = {
  headers: [
    { text: "Tasks", class: "task-cell" },
    { text: "Info", class: "info-cell" },
    { text: "Notes", class: "notes-cell" },
    { text: "Status", class: "status-cell" },
  ],
};

/**
 * Process inline images and CSS icons in text
 * Replaces [image-name.svg] with actual <img> tag (3.5rem size)
 * Replaces [text CSS], [text default CSS], [text selected CSS] with CSS-generated icons
 * Uses CSS classes from demo-inline-icons.css instead of inline styles
 */
function processInlineImages(text) {
  if (!text || typeof text !== "string") return text;

  let processed = text;

  // 1. Replace CSS icons: [text CSS], [text default CSS], [text selected CSS]
  processed = processed.replace(
    /\[([^\]]+?)\s+(default\s+|selected\s+)?CSS\]/gi,
    (match, cssText, stateText) => {
      const cleanText = cssText.trim();
      const state = stateText ? stateText.trim().toLowerCase() : "default";

      // Handle "number X" pattern for checkpoint-style circles
      const numberMatch = cleanText.match(/^number\s+(\d+)$/i);
      if (numberMatch) {
        const num = numberMatch[1];
        return `<span class="inline-css-icon checkpoint-number ${state}">${num}</span>`;
      }

      // Handle "add row" pattern for plus icon
      if (cleanText.toLowerCase() === "add row") {
        return `<span class="inline-css-icon add-row ${state}">+</span>`;
      }

      // Generic CSS icon with text
      return `<span class="inline-css-icon text-label ${state}">${cleanText}</span>`;
    }
  );

  // 2. Replace SVG images: [imagename.svg]
  processed = processed.replace(/\[([^\]]+\.svg)\]/g, (match, imageName) => {
    const imagePath = window.getImagePath
      ? window.getImagePath(imageName)
      : `/images/${imageName}`;
    return `<img src="${imagePath}" alt="${imageName}" class="inline-demo-image">`;
  });

  return processed;
}

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

  // Extract checkpoint/checklist number dynamically
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

  // Add data attribute for CSS-generated number
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

    // Process task text for inline images (DEMO-SPECIFIC FEATURE)
    const processedTaskText = processInlineImages(row.task);

    // Add cells in correct order
    const cells = [
      { html: processedTaskText, className: "task-cell" },
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

      if (cell.html) {
        // Use innerHTML for demo to support inline images
        td.innerHTML = cell.html;
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
    // Process info text for inline images too
    const processedInfoText = processInlineImages(
      row.info || row.example || "No example available."
    );

    infoButton.addEventListener("click", () => {
      // Strip SVG images and CSS icons from title (plain text only)
      let plainTextTitle = row.task
        // Remove CSS icons: [text CSS], [text default CSS], [text selected CSS]
        .replace(/\[([^\]]+?)\s+(default\s+|selected\s+)?CSS\]/gi, "")
        // Remove SVG images: [imagename.svg]
        .replace(/\[([^\]]+\.svg)\]/g, "")
        // Remove empty parentheses left behind
        .replace(/\(\s*\)/g, "")
        // Clean up extra spaces
        .replace(/\s+/g, " ")
        .trim();

      // Truncate title at last complete word within character limit
      const maxLength = 75; // Increased by 50% from 50
      const words = plainTextTitle.split(" ");
      let truncatedTitle = "";

      for (const word of words) {
        if ((truncatedTitle + " " + word).length <= maxLength) {
          truncatedTitle += (truncatedTitle ? " " : "") + word;
        } else {
          break;
        }
      }

      // Add ellipsis if title was truncated
      if (truncatedTitle.length < plainTextTitle.length) {
        truncatedTitle += "...";
      }

      // Use SimpleModal for info display
      if (window.simpleModal) {
        window.simpleModal.info(truncatedTitle, processedInfoText, () => {});
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
    statusButton.setAttribute("data-status-flag", "text-manual");
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
    restartButton.classList.add("restart-hidden");
    restartCell.appendChild(restartButton);

    // Event handlers managed by StateEvents.js global event delegation
  });

  table.appendChild(tbody);

  // Create Add Row button container
  const buttonContainer = document.createElement("div");
  buttonContainer.className = "checkpoints-buttons";

  // Create Add Row button
  const addButton = document.createElement("button");
  addButton.className = "checkpoints-button";
  addButton.id = `addRow-${checkpointId}`;
  addButton.setAttribute("data-checkpoint", checkpointId);
  addButton.setAttribute("aria-label", `Add new task to ${checkpointId}`);

  // Add button to container
  buttonContainer.appendChild(addButton);

  // Event listener attached by initializeCheckpointAddRowButtons() in addRow.js

  // Create wrapper div to contain both table and button
  const wrapper = document.createElement("div");
  wrapper.className = "checkpoints-table-wrapper";
  wrapper.appendChild(table);
  wrapper.appendChild(buttonContainer);

  return wrapper;
}

/**
 * Handles adding a new row to a checkpoints table
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

  // Schedule buffer update
  if (typeof window.scheduleBufferUpdate === "function") {
    window.scheduleBufferUpdate();
  }

  // Set focus on the task textarea for manual rows
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
  }, 50);
}

// Make function globally available
window.handleAddCheckpointRow = handleAddCheckpointRow;

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
      )
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

    // Dispatch event to signal content is built
    const contentBuiltEvent = new CustomEvent("contentBuilt");
    document.dispatchEvent(contentBuiltEvent);
  } catch (error) {
    console.error("Error building content:", error);
    throw error;
  }
}

// Export the function
export { buildContent };
