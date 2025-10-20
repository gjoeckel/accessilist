/**
 * Modal Actions - Simple Modal System Integration
 *
 * RESPONSIBILITY: Handle modal confirmations for reset and delete operations
 * - Uses SimpleModal system for consistent, WCAG-compliant modals
 * - Focus set to ACTION button (Reset/Delete) not Cancel
 * - Clean, minimal implementation without race conditions
 */

class ModalActions {
  constructor(stateManager) {
    this.stateManager = stateManager;
  }

  /**
   * Show reset confirmation modal
   */
  resetTask(taskId, taskText, row) {
    if (!window.simpleModal) {
      console.error("SimpleModal not available");
      return;
    }

    // Store the triggering button for cancel focus restoration
    const triggeringButton = document.activeElement;

    // Limit task text length to keep modal message to two lines
    // Target: "Do you want to reset "TASK_TEXT" to Ready?" should fit in two lines
    const maxTaskLength = 50; // Adjust based on modal width and font size
    const truncatedTaskText =
      taskText.length > maxTaskLength
        ? taskText.substring(0, maxTaskLength - 3) + "..."
        : taskText;

    window.simpleModal.reset(
      "Reset Task",
      `Do you want to reset "${truncatedTaskText}" to Ready?`,
      () => {
        // Execute reset
        this.stateManager.resetTask(taskId, row);

        // Focus on the Status Ready button after reset
        setTimeout(() => {
          const statusButton = row.querySelector(".status-button");
          if (statusButton) {
            statusButton.focus();
            debug.log(
              "ModalActions: Focused on Status Ready button after reset"
            );
          }
        }, 100);
      },
      () => {
        // Cancel - restore focus to triggering button
        setTimeout(() => {
          if (triggeringButton) {
            triggeringButton.focus();
            debug.log(
              "ModalActions: Restored focus to triggering button after cancel"
            );
          }
        }, 100);
      }
    );
  }

  // deleteReportRow() removed - report functionality moved to separate page (list-report.php)
}

// Export for use in StateEvents
window.ModalActions = ModalActions;
