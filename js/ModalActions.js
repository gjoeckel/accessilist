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
      console.error('SimpleModal not available');
      return;
    }

    // Store the triggering button for cancel focus restoration
    const triggeringButton = document.activeElement;

    // Limit task text length to keep modal message to two lines
    // Target: "Do you want to reset "TASK_TEXT" to Pending?" should fit in two lines
    const maxTaskLength = 50; // Adjust based on modal width and font size
    const truncatedTaskText = taskText.length > maxTaskLength
      ? taskText.substring(0, maxTaskLength - 3) + '...'
      : taskText;

    window.simpleModal.reset(
      'Reset Task',
      `Do you want to reset "${truncatedTaskText}" to Pending?`,
      () => {
        // Execute reset
        this.stateManager.resetTask(taskId, row);

        // Focus on the Status Pending button after reset
        setTimeout(() => {
          const statusButton = row.querySelector('.status-button');
          if (statusButton) {
            statusButton.focus();
            console.log('ModalActions: Focused on Status Pending button after reset');
          }
        }, 100);
      },
      () => {
        // Cancel - restore focus to triggering button
        setTimeout(() => {
          if (triggeringButton) {
            triggeringButton.focus();
            console.log('ModalActions: Restored focus to triggering button after cancel');
          }
        }, 100);
      }
    );
  }

  /**
   * Show delete confirmation modal for report rows
   */
  deleteReportRow(rowId, taskText, row) {
    if (!window.simpleModal) {
      console.error('SimpleModal not available');
      return;
    }

    // Store the triggering button for cancel focus restoration
    const triggeringButton = document.activeElement;

    window.simpleModal.delete(
      'Delete Row',
      `Do you want to delete "${taskText}"?`,
      () => {
        // Execute delete
        this.stateManager.deleteReportRow(rowId, row);

        // Focus on the nearest interactive element after delete
        setTimeout(() => {
          // Try to focus on delete button above the deleted row
          const tableBody = row.closest('tbody');
          if (tableBody) {
            const allRows = Array.from(tableBody.querySelectorAll('tr'));
            const currentRowIndex = allRows.indexOf(row);

            // Look for delete button in row above
            if (currentRowIndex > 0) {
              const rowAbove = allRows[currentRowIndex - 1];
              const deleteButtonAbove = rowAbove.querySelector('.report-delete-button');
              if (deleteButtonAbove) {
                deleteButtonAbove.focus();
                console.log('ModalActions: Focused on delete button above after deletion');
                return;
              }
            }
          }

          // Fallback: Focus on Home button if no more rows or no delete button above
          const homeButton = document.getElementById('homeButton');
          if (homeButton) {
            homeButton.focus();
            console.log('ModalActions: Focused on Home button after deletion (no more rows)');
          }
        }, 100);
      },
      () => {
        // Cancel - restore focus to triggering button
        setTimeout(() => {
          if (triggeringButton) {
            triggeringButton.focus();
            console.log('ModalActions: Restored focus to triggering button after cancel');
          }
        }, 100);
      }
    );
  }
}

// Export for use in StateEvents
window.ModalActions = ModalActions;
