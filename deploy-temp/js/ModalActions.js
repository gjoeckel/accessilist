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

    window.simpleModal.reset(
      'Reset Task',
      `Do you want to reset "${taskText}" to pending?`,
      () => {
        // Execute reset
        this.stateManager.resetTask(taskId, row);
      },
      () => {
        // Cancel - no action needed
        console.log('Reset cancelled');
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

    window.simpleModal.delete(
      'Delete Row',
      `Do you want to delete "${taskText}"?`,
      () => {
        // Execute delete
        this.stateManager.deleteReportRow(rowId, row);
      },
      () => {
        // Cancel - no action needed
        console.log('Delete cancelled');
      }
    );
  }
}

// Export for use in StateEvents
window.ModalActions = ModalActions;
