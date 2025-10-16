/**
 * State Events - Centralized event delegation
 *
 * REPLACES:
 * - Event listeners scattered in buildPrinciples.js
 * - Event listeners scattered in main.js
 * - Event listeners scattered in addRow.js
 *
 * RESPONSIBILITIES:
 * - Global event delegation for all interactions
 * - Status button click handling
 * - Reset button click handling
 * - Delete button click handling
 * - Textarea input handling
 * - Side panel interactions
 */

class StateEvents {
  constructor(stateManager, modalActions) {
    this.stateManager = stateManager;
    this.modalActions = modalActions;
    this.listenersSetup = false;
  }

  /**
   * Setup all global event listeners
   */
  setupGlobalEvents() {
    if (this.listenersSetup) {
      console.log("Event listeners already setup");
      return;
    }

    // Single event delegation for ALL click interactions
    document.addEventListener("click", (e) => {
      console.log("StateEvents: Click event detected on:", e.target);

      // Status button (Principles table)
      const statusButton = e.target.closest(".status-button");
      if (statusButton) {
        console.log("StateEvents: Status button click detected");
        this.handleStatusChange(statusButton);
        return;
      }

      // Report table handling removed - reports now on separate page

      // Reset button
      const resetButton = e.target.closest(".restart-button");
      if (resetButton) {
        console.log("StateEvents: Reset button click detected");
        this.handleReset(resetButton);
        return;
      }

      // Side panel navigation now handled by SidePanel class

      // Side panel toggle
      const toggleStrip = e.target.closest(".toggle-strip");
      if (toggleStrip) {
        console.log("StateEvents: Side panel toggle click detected");
        this.handleSidePanelToggle(e);
        return;
      }

      // Checklist caption click - focus the heading
      const checklistCaption = e.target.closest(".checklist-caption");
      if (checklistCaption) {
        console.log("StateEvents: Checklist caption click detected");
        this.handleChecklistCaptionClick(checklistCaption, e);
        return;
      }
    });

    // Single event delegation for ALL input changes
    document.addEventListener("input", (e) => {
      const textarea = e.target.closest("textarea");
      if (textarea) {
        console.log(
          "StateEvents: Textarea input detected:",
          textarea.className,
          "value length:",
          textarea.value.length
        );
        this.handleTextChange(textarea, e);
        return;
      }
    });

    this.listenersSetup = true;
    console.log("StateEvents: Global event listeners setup complete");
  }

  /**
   * Handle status button click (Principles table)
   *
   * MANUAL STATUS CHANGE LOGIC:
   * - When user clicks Ready → Active: Set flag to 'active-manual'
   * - When user clicks Done → Ready: Reset flag to 'text-manual'
   * - This prevents auto-status behavior after manual intervention
   */
  handleStatusChange(statusButton) {
    console.log("StateEvents: Status button clicked");
    const row = statusButton.closest("tr");
    if (!row) {
      console.warn("StateEvents: No row found for status button");
      return;
    }

    const currentState = statusButton.getAttribute("data-state");
    const textarea = row.querySelector(".notes-textarea");
    const restartButton = row.querySelector(".restart-button");
    const taskId = statusButton.getAttribute("data-id");

    // Get current flag
    const currentFlag = this.stateManager.getStatusFlag(taskId);

    console.log(
      `StateEvents: Current state: ${currentState}, task ID: ${taskId}, flag: ${currentFlag}`
    );

    let newState, newIcon, newLabel;

    // State transitions
    if (currentState === "ready") {
      newState = "active";
      newIcon = window.getImagePath("active-1.svg");
      newLabel = "Task status: Active";
      console.log("StateEvents: Transitioning from ready to active");

      // FLAG LOGIC: Manual change from Ready → Active
      // Only set active-manual if not already auto-changed
      if (currentFlag !== "active-auto") {
        this.stateManager.setStatusFlag(taskId, "active-manual");
        console.log(`[Manual-Status] ${taskId}: Flag set to active-manual`);
      }
    } else if (currentState === "active") {
      newState = "done";
      newIcon = window.getImagePath("done-1.svg");
      newLabel = "Task status: Done";
      console.log("StateEvents: Transitioning from active to done");

      // FLAG LOGIC: Flag persists when going to Done (no change)

      // Show and enable restart button when status is done
      if (restartButton) {
        restartButton.classList.remove("restart-hidden");
        restartButton.classList.add("restart-visible");
        restartButton.disabled = false;
        console.log("StateEvents: Restart button shown and enabled");
      }

      // Create report row when completed - use StateManager
      // TEMPORARILY COMMENTED OUT - Report functionality is interfering with principle rows
      // if (textarea) {
      //   const notesText = textarea.value;
      //   const taskCell = row.querySelector('.task-cell');
      //   if (taskCell) {
      //     const taskText = taskCell.textContent || '';
      //
      //     // Use StateManager to add report row (replaces event-based coupling)
      //     const rowData = this.stateManager.createReportRowData({
      //       task: taskText,
      //       notes: notesText,
      //       status: 'done',
      //       isManual: false,
      //       id: taskId
      //     });
      //     this.stateManager.addReportRow(rowData, false); // Don't save yet (will auto-save via markDirty)
      //     console.log('StateEvents: Done task added to Report via StateManager');
      //   }
      // }

      // Apply completed textarea state
      if (textarea) {
        this.applyCompletedTextareaState(textarea, row);
        console.log("StateEvents: Applied completed state to notes textarea");
      }

      // Also apply completed state to Task textarea for manual rows
      const taskTextarea = row.querySelector(".task-input");
      if (taskTextarea) {
        this.applyCompletedTextareaState(taskTextarea, row);
        console.log("StateEvents: Applied completed state to task textarea");
      }
    } else if (currentState === "done") {
      // Cycle back to ready
      newState = "ready";
      newIcon = window.getImagePath("ready-1.svg");
      newLabel = "Task status: Ready";
      console.log("StateEvents: Transitioning from done to ready");

      // FLAG LOGIC: Reset flag when cycling Done → Ready
      this.stateManager.resetStatusFlag(taskId);
      console.log(`[Status-Reset] ${taskId}: Flag reset to text-manual`);

      // Hide restart button
      if (restartButton) {
        restartButton.classList.remove("restart-visible");
        restartButton.classList.add("restart-hidden");
        console.log("StateEvents: Restart button hidden");
      }

      // Restore textarea to editable state
      if (textarea) {
        this.restoreTextareaState(textarea, row);
        console.log("StateEvents: Restored notes textarea to editable state");
      }

      // Also restore Task textarea for manual rows
      const taskTextarea = row.querySelector(".task-input");
      if (taskTextarea) {
        this.restoreTextareaState(taskTextarea, row);
        console.log("StateEvents: Restored task textarea to editable state");
      }
    }

    // Update status button
    if (newState) {
      this._updateStatusButton(statusButton, newState, newLabel, newIcon);
      console.log(`StateEvents: Status button updated to ${newState}`);
    }

    // Update state in window.principleTableState for manual rows
    this._updateManualRowState(row, { status: newState || currentState });

    // Mark dirty for auto-save
    this.stateManager.markDirty();
    console.log("StateEvents: Marked state as dirty for auto-save");
  }

  // handleReportStatusChange method removed - reports now on separate page

  /**
   * Handle reset button click
   */
  handleReset(resetButton) {
    const row = resetButton.closest("tr");
    if (!row) return;

    const taskId = resetButton.getAttribute("data-id");
    const taskCell = row.querySelector(".task-cell");
    const taskText = taskCell ? taskCell.textContent : "this task";

    // Update state in window.principleTableState for manual rows
    const principleId = row.closest("section")?.id;
    if (
      taskId &&
      principleId &&
      window.principleTableState &&
      window.principleTableState[principleId]
    ) {
      const rowData = window.principleTableState[principleId].find(
        (r) => r.id === taskId
      );
      if (rowData && rowData.isManual) {
        rowData.status = "ready";
        console.log(`StateEvents: Reset manual row ${taskId} status to ready`);
      }
    }

    // Show modal confirmation
    if (this.modalActions) {
      this.modalActions.resetTask(taskId, taskText, row);
    }
  }

  /**
   * Handle delete button click (Report table)
   */
  handleDelete(deleteButton) {
    const row = deleteButton.closest("tr");
    if (!row) return;

    const rowId = row.getAttribute("data-id");
    const taskCell = row.querySelector(".report-task-cell");
    const taskText = taskCell ? taskCell.textContent : "this row";

    // Show modal confirmation
    if (this.modalActions) {
      this.modalActions.deleteReportRow(rowId, taskText, row);
    }
  }

  /**
   * Update status button appearance and state
   * @private
   */
  _updateStatusButton(statusButton, newState, newLabel, newIcon) {
    statusButton.setAttribute("data-state", newState);
    statusButton.setAttribute("aria-label", newLabel);
    const statusImg = statusButton.querySelector("img");
    if (statusImg) {
      statusImg.src = newIcon;
    }
  }

  /**
   * Update manual row state in principleTableState
   * @private
   */
  _updateManualRowState(row, updates) {
    const rowId = row.getAttribute("data-id");
    const principleId = row.closest("section")?.id;
    if (
      rowId &&
      principleId &&
      window.principleTableState &&
      window.principleTableState[principleId]
    ) {
      const rowData = window.principleTableState[principleId].find(
        (r) => r.id === rowId
      );
      if (rowData && rowData.isManual) {
        Object.assign(rowData, updates);
        console.log(`StateEvents: Updated manual row ${rowId} state:`, rowData);
      }
    }
  }

  /**
   * Handle textarea input changes
   *
   * AUTO-STATUS LOGIC:
   * - If status is Ready and user types notes → auto-change to Active (set active-auto flag)
   * - If status is Active and user clears notes AND flag is active-auto → auto-revert to Ready
   * - If flag is active-manual, notes changes do NOT affect status
   */
  handleTextChange(textarea, event) {
    const row = textarea.closest("tr");
    if (!row) return;

    // Handle Principles table textarea
    if (textarea.classList.contains("notes-textarea")) {
      const statusButton = row.querySelector(".status-button");
      if (statusButton) {
        const currentState = statusButton.getAttribute("data-state");
        const hasText = textarea.value.trim().length > 0;
        const taskId =
          statusButton.getAttribute("data-id") || row.getAttribute("data-id");

        // Get current flag state
        const currentFlag = this.stateManager.getStatusFlag(taskId);

        console.log(
          `StateEvents: Textarea change - state: ${currentState}, hasText: ${hasText}, flag: ${currentFlag}`
        );

        // AUTO-CHANGE LOGIC: Ready + typing → Active (set active-auto flag)
        if (
          currentState === "ready" &&
          hasText &&
          currentFlag === "text-manual"
        ) {
          this._updateStatusButton(
            statusButton,
            "active",
            "Task status: Active",
            window.getImagePath("active-1.svg")
          );
          this.stateManager.setStatusFlag(taskId, "active-auto");
          console.log(
            `[Auto-Status] ${taskId}: Ready → Active (notes added, flag set to active-auto)`
          );
        }
        // AUTO-REVERT LOGIC: Active + clear notes + auto flag → Ready
        else if (
          currentState === "active" &&
          !hasText &&
          currentFlag === "active-auto"
        ) {
          this._updateStatusButton(
            statusButton,
            "ready",
            "Task status: Ready",
            window.getImagePath("ready-1.svg")
          );
          this.stateManager.resetStatusFlag(taskId);
          console.log(
            `[Auto-Status] ${taskId}: Active → Ready (notes cleared, flag reset to text-manual)`
          );
        }
        // MANUAL FLAG: No auto-behavior when flag is active-manual
        else if (currentFlag === "active-manual") {
          console.log(
            `[Auto-Status] ${taskId}: No auto-change (flag is active-manual)`
          );
        }

        // Update state in window.principleTableState for manual rows
        this._updateManualRowState(row, {
          notes: textarea.value,
          status: statusButton.getAttribute("data-state"),
        });
      } else {
        console.warn(
          `StateEvents: No status button found for textarea in row ${row.getAttribute(
            "data-id"
          )}`
        );
      }
    }

    // Handle Principles table task textarea (manual rows only)
    if (textarea.classList.contains("task-input")) {
      this._updateManualRowState(row, { task: textarea.value });
    }

    // Report table textarea handling removed - reports now on separate page

    // Mark dirty for auto-save
    this.stateManager.markDirty();
  }

  /**
   * Handle side panel navigation click
   */
  handleSidePanelNavigation(link, event) {
    event.preventDefault();

    const targetId =
      link.getAttribute("data-target") ||
      link.getAttribute("href")?.substring(1);
    const targetSection = document.getElementById(targetId);

    // === DEBUG LOGGING ===
    console.log("=== SIDE PANEL NAVIGATION DEBUG ===");
    console.log("Target ID:", targetId);
    console.log("Section exists:", !!targetSection);
    if (targetSection) {
      console.log(
        "Section display:",
        window.getComputedStyle(targetSection).display
      );
      console.log(
        "Section visibility:",
        window.getComputedStyle(targetSection).visibility
      );
      console.log("Section offsetTop:", targetSection.offsetTop);
      console.log("Section offsetParent:", targetSection.offsetParent);
      console.log(
        "Section getBoundingClientRect:",
        targetSection.getBoundingClientRect()
      );
    }
    console.log("Current scrollY:", window.scrollY);
    console.log("Window height:", window.innerHeight);
    console.log("=================================");

    if (!targetSection) {
      console.warn(`StateEvents: Target section ${targetId} not found`);
      return;
    }

    // Remove infocus class from all links (pure CSS solution - no SVG manipulation)
    const allLinks = document.querySelectorAll(".side-panel a");
    allLinks.forEach((l) => {
      l.classList.remove("infocus");
    });

    // Add infocus class to clicked link (CSS handles visual state)
    link.classList.add("infocus");

    // Scroll using StateManager's DRY method
    if (
      this.stateManager &&
      typeof this.stateManager.scrollSectionToPosition === "function"
    ) {
      this.stateManager.scrollSectionToPosition(targetSection, {
        smooth: false,
      });
    } else {
      console.error(
        "StateEvents: scrollSectionToPosition method not available on StateManager"
      );
    }

    // Focus the section heading with a small delay to ensure DOM is ready
    setTimeout(() => {
      const heading = targetSection.querySelector("h2.checklist-caption");
      if (heading) {
        // Ensure the heading is focusable
        if (!heading.hasAttribute("tabindex")) {
          heading.setAttribute("tabindex", "0");
        }
        // Focus the heading
        heading.focus();
        console.log(`StateEvents: Focused heading for ${targetId}`);
      } else {
        console.warn(
          `StateEvents: No checklist-caption heading found for ${targetId}`
        );
      }
    }, 300); // Increased delay to ensure scroll completes

    // Mark dirty for auto-save
    this.stateManager.markDirty();
  }

  /**
   * Handle side panel toggle click
   */
  handleSidePanelToggle(event) {
    const sidePanel = document.querySelector(".side-panel");
    const toggleStrip = document.querySelector(".toggle-strip");
    if (!sidePanel || !toggleStrip) return;

    const isExpanded = sidePanel.getAttribute("aria-expanded") === "true";
    const newState = !isExpanded;
    sidePanel.setAttribute("aria-expanded", newState.toString());
    toggleStrip.setAttribute("aria-expanded", newState.toString());

    // Mark dirty for auto-save
    this.stateManager.markDirty();
  }

  /**
   * Handle checklist caption click - focus the heading
   */
  handleChecklistCaptionClick(caption, event) {
    event.preventDefault();

    // Focus the caption element
    caption.focus({ preventScroll: true });
    console.log(`StateEvents: Focused checklist caption via mouse click`);

    // Mark dirty for auto-save
    this.stateManager.markDirty();
  }

  /**
   * Apply completed state to textarea
   */
  applyCompletedTextareaState(textarea, row) {
    const notesText = textarea.value;

    // Make textarea non-interactive but keep it visible
    textarea.classList.add("textarea-completed");
    textarea.disabled = true;
    textarea.setAttribute("tabindex", "-1");
    textarea.setAttribute("aria-hidden", "true");

    // Legacy overlay code removed - textareas now handle completed state directly
  }

  /**
   * Restore textarea to editable state
   */
  restoreTextareaState(textarea, row) {
    textarea.classList.remove("textarea-completed");
    textarea.disabled = false;
    textarea.setAttribute("tabindex", "0");
    textarea.setAttribute("aria-hidden", "false");

    // Legacy overlay restoration code removed - textareas now handle state directly
  }

  // processCompletedRowTextareas method removed - reports now on separate page

  // REMOVED: storeCompletedTask() - Now handled directly by StateManager.addReportRow()
  // Event-based architecture replaced with direct method calls for clearer data flow
}

// Global instance (initialized after dependencies are ready)
window.stateEvents = null;

// Initialize after DOM is ready and dependencies exist
if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", () => {
    if (window.unifiedStateManager && window.modalActions) {
      window.stateEvents = new StateEvents(
        window.unifiedStateManager,
        window.modalActions
      );
      console.log("State Events initialized - ready to setup listeners");
    }
  });
} else {
  if (window.unifiedStateManager && window.modalActions) {
    window.stateEvents = new StateEvents(
      window.unifiedStateManager,
      window.modalActions
    );
    console.log("State Events initialized - ready to setup listeners");
  }
}

export { StateEvents };
