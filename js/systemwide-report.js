/**
 * Reports Module
 *
 * Manages the reports page functionality:
 * - Loading checklist data with full state
 * - Calculating checklist status based on statusButtons
 * - Filtering by status
 * - Rendering the reports table
 */

export class ReportsManager {
  constructor() {
    this.allChecklists = [];
    this.currentFilter = "all"; // Default filter
    this.filterButtons = null;
    this.tableBody = null;
  }

  /**
   * Initialize the reports manager
   */
  initialize() {
    // Cache DOM elements
    this.tableBody = document.querySelector(".reports-table tbody");
    this.filterButtons = document.querySelectorAll(".filter-button");

    // Set up filter button event listeners
    this.filterButtons.forEach((button) => {
      button.addEventListener("click", (e) => {
        this.handleFilterClick(e.currentTarget);
      });
    });

    // Set up delete button event delegation
    this.tableBody.addEventListener("click", (e) => {
      if (e.target.closest(".reports-delete-button")) {
        const button = e.target.closest(".reports-delete-button");
        const sessionKey = button.getAttribute("data-session-key");
        this.handleDeleteClick(sessionKey, button);
      }
    });

    // Load initial data
    this.loadChecklists();
  }

  /**
   * Handle filter button click
   */
  handleFilterClick(button) {
    const filter = button.getAttribute("data-filter");

    // Update active state
    this.filterButtons.forEach((btn) => {
      btn.classList.remove("active");
      btn.setAttribute("aria-pressed", "false");
    });

    button.classList.add("active");
    button.setAttribute("aria-pressed", "true");

    // Update current filter and re-render
    this.currentFilter = filter;
    this.renderTable();

    // Recalculate buffer immediately, then scroll
    if (typeof window.updateReportBuffer === "function") {
      window.updateReportBuffer(); // Immediate update (no debounce)
    }

    // Scroll to top after buffer is calculated
    // Use requestAnimationFrame to ensure buffer CSS is applied
    requestAnimationFrame(() => {
      window.scrollTo({
        top: 0,
        behavior: "auto", // Instant scroll - no animation
      });
    });
  }

  /**
   * Load all checklists from API
   */
  async loadChecklists() {
    try {
      const apiPath = window.getAPIPath
        ? window.getAPIPath("list-detailed")
        : "/php/api/list-detailed.php";

      const response = await fetch(apiPath);

      if (!response.ok) {
        throw new Error(`API responded with status: ${response.status}`);
      }

      const responseData = await response.json();

      // Extract instances from standardized API response shape
      const instances = Array.isArray(responseData && responseData.data)
        ? responseData.data
        : [];

      // Process each checklist to add calculated status
      this.allChecklists = instances.map((checklist) => ({
        ...checklist,
        calculatedStatus: this.calculateStatus(
          checklist.state?.statusButtons || {}
        ),
      }));

      // Update filter counts
      this.updateFilterCounts();

      // Render the table with current filter
      this.renderTable();
    } catch (error) {
      console.error("Error loading checklists:", error);
      this.showError("Failed to load checklists");

      if (this.tableBody) {
        this.tableBody.innerHTML =
          '<tr><td colspan="5" class="error-message">Error loading checklists</td></tr>';
      }
    }
  }

  /**
   * Calculate checklist status based on statusButtons
   *
   * Logic:
   * - done: All tasks are "done"
   * - active: At least one task is "done" or "active", but not all done
   * - ready: All tasks are "ready"
   */
  calculateStatus(statusButtons) {
    if (!statusButtons || typeof statusButtons !== "object") {
      return "ready";
    }

    const statuses = Object.values(statusButtons);

    if (statuses.length === 0) {
      return "ready";
    }

    const doneCount = statuses.filter((s) => s === "done").length;
    const inProgressCount = statuses.filter((s) => s === "active").length;
    const total = statuses.length;

    // All done
    if (doneCount === total) {
      return "done";
    }

    // Some done or in progress
    if (doneCount > 0 || inProgressCount > 0) {
      return "active";
    }

    // All ready
    return "ready";
  }

  /**
   * Update filter count badges
   * Counts sessions with "at least one" task of each status
   */
  updateFilterCounts() {
    const counts = {
      done: 0,
      ready: 0,
      active: 0,
      all: 0,
      demos: 0,
    };

    this.allChecklists.forEach((checklist) => {
      const isDemo = checklist.typeSlug === "demo";
      const isSaved = !!checklist.metadata?.lastModified;
      const statusButtons = checklist.state?.statusButtons || {};
      const statuses = Object.values(statusButtons);

      // Count demo sessions (all demos, saved or not)
      if (isDemo) {
        counts["demos"]++;
      } else {
        // Count non-demo sessions for "All" filter (includes not-saved)
        counts["all"]++;
        
        // Count status-based filters: sessions with "at least one" of each status
        // Only count saved sessions
        if (isSaved && statuses.length > 0) {
          // Has at least 1 done task?
          if (statuses.some(s => s === "done")) {
            counts["done"]++;
          }
          // Has at least 1 active task?
          if (statuses.some(s => s === "active")) {
            counts["active"]++;
          }
          // Has at least 1 ready task?
          if (statuses.some(s => s === "ready")) {
            counts["ready"]++;
          }
        }
      }
    });

    // Update count badges
    Object.keys(counts).forEach((status) => {
      const countElement = document.getElementById(`count-${status}`);
      if (countElement) {
        countElement.textContent = counts[status];
      }
    });
  }

  /**
   * Render the table based on current filter
   */
  async renderTable() {
    if (!this.tableBody) {
      console.error("Table body not found");
      return;
    }

    // Filter checklists by current filter
    let filtered;
    if (this.currentFilter === "all") {
      // Show all NON-demo sessions (exclude demo sessions)
      // Includes "not saved" non-demo sessions
      filtered = this.allChecklists.filter(
        (checklist) => checklist.typeSlug !== "demo"
      );
    } else if (this.currentFilter === "demos") {
      // Show ONLY demo sessions (typeSlug === "demo"), hide all non-demo sessions
      // Includes both saved and not saved demo sessions
      filtered = this.allChecklists.filter(
        (checklist) => checklist.typeSlug === "demo"
      );
    } else {
      // Filter by calculated status (done, active, ready)
      // Shows NON-demo sessions with matching status
      // EXCLUDE demo sessions AND "not saved" sessions
      filtered = this.allChecklists.filter(
        (checklist) =>
          checklist.calculatedStatus === this.currentFilter &&
          checklist.metadata?.lastModified && // Only show saved sessions
          checklist.typeSlug !== "demo" // Exclude demo sessions
      );
    }

    // Clear table
    this.tableBody.innerHTML = "";

    // Show empty state if no results
    if (filtered.length === 0) {
      const row = document.createElement("tr");
      const cell = document.createElement("td");
      cell.colSpan = 6; // Updated to span all 6 columns (Type, Updated, Key, Status, Progress, Delete)

      // Custom messages based on filter type
      const messages = {
        done: "No tasks done",
        active: "No tasks active",
        ready: "No tasks ready",
        demos: "No demo sessions found",
      };

      cell.textContent = messages[this.currentFilter] || "No reports found";
      cell.className = "table-empty-message";
      row.appendChild(cell);
      this.tableBody.appendChild(row);
      return;
    }

    // Render each checklist
    for (const checklist of filtered) {
      const row = await this.createChecklistRow(checklist);
      this.tableBody.appendChild(row);
    }

    // Update buffer after rendering
    if (typeof window.scheduleReportBufferUpdate === "function") {
      window.scheduleReportBufferUpdate();
    }
  }

  /**
   * Create a table row for a checklist
   */
  async createChecklistRow(checklist) {
    const row = document.createElement("tr");
    row.setAttribute("data-session-key", checklist.sessionKey);

    // Format type using TypeManager if available
    const typeSlug = checklist.typeSlug || "unknown";
    let formattedType = typeSlug;

    if (
      window.TypeManager &&
      typeof window.TypeManager.formatDisplayName === "function"
    ) {
      formattedType = await window.TypeManager.formatDisplayName(typeSlug);
    } else {
      // Fallback: capitalize first letter
      formattedType = typeSlug.charAt(0).toUpperCase() + typeSlug.slice(1);
    }

    // Check if checklist has been manually saved (only lastModified indicates a save)
    const isSaved = !!checklist.metadata?.lastModified;

    // Format dates - only show if manually saved
    const formattedDate = isSaved
      ? this.formatDate(checklist.metadata.lastModified)
      : "-";

    // Get statusButtons for filter-dependent progress calculation
    const statusButtons = checklist.state?.statusButtons || {};

    // Status column: Show "-" for not saved sessions, otherwise show status badge
    const statusDisplay = isSaved
      ? this.createStatusBadge(checklist.calculatedStatus)
      : '<span class="status-placeholder">-</span>';

    // Build row HTML
    row.innerHTML = `
            <td class="task-cell">${this.escapeHtml(formattedType)}</td>
            <td class="task-cell">${this.escapeHtml(formattedDate)}</td>
            <td class="info-cell">${this.createInstanceLink(
              checklist.sessionKey,
              typeSlug
            )}</td>
            <td class="status-cell">${statusDisplay}</td>
            <td class="task-cell">${this.createProgressBar(
              statusButtons,
              checklist.calculatedStatus,
              isSaved
            )}</td>
            <td class="restart-cell">${this.createDeleteButton(
              checklist.sessionKey
            )}</td>
        `;

    return row;
  }

  /**
   * Create instance link HTML
   */
  createInstanceLink(sessionKey, typeSlug) {
    const basePath = window.ENV?.basePath || "";
    const href = `${basePath}/?=${sessionKey}`;

    return `<a href="${this.escapeHtml(href)}"
                   class="instance-link"
                   target="_blank"
                   rel="noopener noreferrer"
                   aria-label="Open checklist ${this.escapeHtml(
                     sessionKey
                   )} in new window">
                   ${this.escapeHtml(sessionKey)}
                </a>`;
  }

  /**
   * Create status icon HTML (non-interactive display only)
   */
  createStatusBadge(status) {
    // Map status values to checkpoint table SVG files
    const statusMap = {
      done: "done-1",
      ready: "ready-1",
      active: "active-1",
      active: "active-1",
    };

    const labels = {
      done: "Done",
      ready: "Ready",
      active: "Active",
    };

    const svgName = statusMap[status] || status;
    const label = labels[status] || status;
    const iconPath = window.getImagePath
      ? window.getImagePath(`${svgName}.svg`)
      : `/images/${svgName}.svg`;

    return `<img src="${this.escapeHtml(iconPath)}"
                     alt="${this.escapeHtml(label)}"
                     class="status-icon"
                     aria-label="${this.escapeHtml(label)}">`;
  }

  /**
   * Create progress bar HTML (filter-dependent)
   */
  createProgressBar(statusButtons, status, isSaved = true) {
    // Show "not saved" for unsaved checklists or when no statusButtons
    if (!isSaved || !statusButtons || Object.keys(statusButtons).length === 0) {
      return '<span class="progress-text" style="text-align: center; display: block;">not saved</span>';
    }

    const statuses = Object.values(statusButtons);
    const total = statuses.length;
    const doneCount = statuses.filter((s) => s === "done").length;
    const activeCount = statuses.filter((s) => s === "active").length;
    const readyCount = statuses.filter((s) => s === "ready").length;

    // ALL FILTER: No progress bar, just text summary
    if (this.currentFilter === "all") {
      return `<span class="progress-text" style="text-align: center; display: block;">${doneCount} Done | ${activeCount} Active | ${readyCount} Ready | ${total} Tasks</span>`;
    }

    // DONE FILTER: V/X Tasks Done
    if (this.currentFilter === "done") {
      const percentage = (doneCount / total) * 100;
      return `
              <div class="progress-container">
                  <div class="progress-bar">
                      <div class="progress-fill ${status}" style="width: ${percentage}%"></div>
                  </div>
                  <span class="progress-text">${doneCount}/${total} Tasks Done</span>
              </div>
          `;
    }

    // ACTIVE FILTER: Z/(X-V) Open Tasks Active
    if (this.currentFilter === "active") {
      const openTasks = total - doneCount; // Total - Done = Open Tasks
      const percentage = openTasks > 0 ? (activeCount / openTasks) * 100 : 0;
      return `
              <div class="progress-container">
                  <div class="progress-bar">
                      <div class="progress-fill ${status}" style="width: ${percentage}%"></div>
                  </div>
                  <span class="progress-text">${activeCount}/${openTasks} Open Tasks Active</span>
              </div>
          `;
    }

    // READY FILTER: (V+Z)/X Tasks Started
    if (this.currentFilter === "ready") {
      const tasksStarted = doneCount + activeCount; // Done + Active = Started
      const percentage = total > 0 ? (tasksStarted / total) * 100 : 0;
      return `
              <div class="progress-container">
                  <div class="progress-bar">
                      <div class="progress-fill ${status}" style="width: ${percentage}%"></div>
                  </div>
                  <span class="progress-text">${tasksStarted}/${total} Tasks Started</span>
              </div>
          `;
    }

    // DEMOS FILTER: Use same logic as All (no progress bar)
    if (this.currentFilter === "demos") {
      return `<span class="progress-text" style="text-align: center; display: block;">${doneCount} Done | ${activeCount} Active | ${readyCount} Ready | ${total} Tasks</span>`;
    }

    // Fallback (shouldn't reach here)
    const percentage = (doneCount / total) * 100;
    return `
            <div class="progress-container">
                <div class="progress-bar">
                    <div class="progress-fill ${status}" style="width: ${percentage}%"></div>
                </div>
                <span class="progress-text">${doneCount}/${total}</span>
            </div>
        `;
  }

  /**
   * Create delete button HTML (reused from admin.php)
   */
  createDeleteButton(sessionKey) {
    const iconPath = window.getImagePath
      ? window.getImagePath("delete.svg")
      : `/images/delete.svg`;

    return `
            <button class="reports-delete-button"
                    data-session-key="${this.escapeHtml(sessionKey)}"
                    aria-label="Delete checklist ${this.escapeHtml(
                      sessionKey
                    )}">
                <img src="${this.escapeHtml(iconPath)}" alt="Delete">
            </button>
        `;
  }

  /**
   * Format date timestamp
   */
  formatDate(timestamp) {
    if (!timestamp) return "—";

    // Use existing date formatter if available
    if (
      window.formatDateAdmin &&
      typeof window.formatDateAdmin === "function"
    ) {
      return window.formatDateAdmin(timestamp);
    }

    // Fallback: MM-DD-YY HH:MM AM/PM format
    const date = new Date(timestamp);
    return date
      .toLocaleString("en-US", {
        month: "2-digit",
        day: "2-digit",
        year: "2-digit",
        hour: "numeric",
        minute: "2-digit",
        hour12: true,
      })
      .replace(/\//g, "-")
      .replace(",", "");
  }

  /**
   * Show error message
   */
  showError(message) {
    console.error("ReportsManager Error:", message);
  }

  /**
   * Handle delete button click
   */
  handleDeleteClick(sessionKey, button) {
    // Store the triggering button for focus restoration
    const triggeringButton = button;

    // Show SimpleModal confirmation with proper focus management
    window.simpleModal.delete(
      "Delete Checklist",
      `Are you sure you want to delete checklist ${sessionKey}?`,
      () => {
        // Delete confirmed - perform deletion
        this.deleteChecklist(sessionKey, triggeringButton);
      },
      () => {
        // Delete cancelled - restore focus to triggering button
        setTimeout(() => {
          if (
            triggeringButton &&
            triggeringButton.classList.contains("reports-delete-button")
          ) {
            triggeringButton.focus();
          }
        }, 100);
      }
    );
  }

  /**
   * Delete a checklist
   */
  async deleteChecklist(sessionKey, triggeringButton) {
    try {
      const apiPath = window.getAPIPath
        ? window.getAPIPath("delete")
        : "/php/api/delete.php";

      const response = await fetchWithCsrf(apiPath + "?session=" + sessionKey, {
        method: "DELETE",
      });

      if (response.ok) {
        // Find the row being deleted
        const currentRow = document.querySelector(
          `tr[data-session-key="${sessionKey}"]`
        );
        let targetDeleteButton = null;

        if (currentRow) {
          // Find the delete button in the row above the deleted row
          const previousRow = currentRow.previousElementSibling;
          if (previousRow) {
            targetDeleteButton = previousRow.querySelector(
              ".reports-delete-button"
            );
          }

          // Remove the row from the DOM
          currentRow.remove();

          // Update the allChecklists array
          this.allChecklists = this.allChecklists.filter(
            (checklist) => checklist.sessionKey !== sessionKey
          );

          // Update filter counts
          this.updateFilterCounts();

          // Focus management after deletion
          setTimeout(() => {
            if (targetDeleteButton) {
              // Focus on the delete button in the row above
              targetDeleteButton.focus();
            } else {
              // No row above - check remaining rows
              const remainingDeleteButtons = this.tableBody.querySelectorAll(
                ".reports-delete-button"
              );

              if (remainingDeleteButtons.length > 0) {
                // Focus on the first remaining delete button
                remainingDeleteButtons[0].focus();
              } else {
                // No more rows - focus on Home button
                const homeButton = document.getElementById("homeButton");
                if (homeButton) {
                  homeButton.focus();
                }
              }
            }
          }, 100);
        } else {
          // Row not found - reload data and focus Home
          await this.loadChecklists();
          setTimeout(() => {
            const homeButton = document.getElementById("homeButton");
            if (homeButton) {
              homeButton.focus();
            }
          }, 100);
        }
      } else {
        // Show error modal
        window.simpleModal.error(
          "Delete Failed",
          "Failed to delete checklist. Please try again.",
          () => {
            // Restore focus to triggering button on error
            if (
              triggeringButton &&
              triggeringButton.classList.contains("reports-delete-button")
            ) {
              triggeringButton.focus();
            }
          }
        );
      }
    } catch (error) {
      console.error("Error deleting checklist:", error);
      window.simpleModal.error(
        "Delete Error",
        "An error occurred while deleting the checklist.",
        () => {
          // Restore focus to triggering button on error
          if (
            triggeringButton &&
            triggeringButton.classList.contains("reports-delete-button")
          ) {
            triggeringButton.focus();
          }
        }
      );
    }
  }

  /**
   * Escape HTML to prevent XSS
   */
  escapeHtml(text) {
    const div = document.createElement("div");
    div.textContent = text;
    return div.innerHTML;
  }
}

// Export for use in systemwide-report.php
export default ReportsManager;
