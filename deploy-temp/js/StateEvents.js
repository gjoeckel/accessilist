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
      console.log('Event listeners already setup');
      return;
    }

    // Single event delegation for ALL click interactions
    document.addEventListener('click', (e) => {
      console.log('StateEvents: Click event detected on:', e.target);

      // Status button (Principles table)
      const statusButton = e.target.closest('.status-button');
      if (statusButton) {
        console.log('StateEvents: Status button click detected');
        this.handleStatusChange(statusButton);
        return;
      }

      // Report table handling removed - reports now on separate page

      // Reset button
      const resetButton = e.target.closest('.restart-button');
      if (resetButton) {
        console.log('StateEvents: Reset button click detected');
        this.handleReset(resetButton);
        return;
      }

      // Report table delete handling removed - reports now on separate page

      // Side panel navigation
      const sidePanelLink = e.target.closest('.side-panel a');
      if (sidePanelLink) {
        console.log('StateEvents: Side panel link click detected');
        this.handleSidePanelNavigation(sidePanelLink, e);
        return;
      }

      // Side panel toggle
      const toggleStrip = e.target.closest('.toggle-strip');
      if (toggleStrip) {
        console.log('StateEvents: Side panel toggle click detected');
        this.handleSidePanelToggle(e);
        return;
      }

      // Checklist caption click - focus the heading
      const checklistCaption = e.target.closest('.checklist-caption');
      if (checklistCaption) {
        console.log('StateEvents: Checklist caption click detected');
        this.handleChecklistCaptionClick(checklistCaption, e);
        return;
      }
    });

    // Single event delegation for ALL input changes
    document.addEventListener('input', (e) => {
      const textarea = e.target.closest('textarea');
      if (textarea) {
        console.log('StateEvents: Textarea input detected:', textarea.className, 'value length:', textarea.value.length);
        this.handleTextChange(textarea, e);
        return;
      }
    });

    this.listenersSetup = true;
    console.log('StateEvents: Global event listeners setup complete');
  }

  /**
   * Handle status button click (Principles table)
   */
  handleStatusChange(statusButton) {
    console.log('StateEvents: Status button clicked');
    const row = statusButton.closest('tr');
    if (!row) {
      console.warn('StateEvents: No row found for status button');
      return;
    }

    const currentState = statusButton.getAttribute('data-state');
    const textarea = row.querySelector('.notes-textarea');
    const restartButton = row.querySelector('.restart-button');
    const taskId = statusButton.getAttribute('data-id');

    console.log(`StateEvents: Current state: ${currentState}, task ID: ${taskId}`);

    let newState, newIcon, newLabel;

    // State transitions
    if (currentState === 'pending') {
      newState = 'in-progress';
      newIcon = window.getImagePath('in-progress.svg');
      newLabel = 'Task status: In Progress';
      console.log('StateEvents: Transitioning from pending to in-progress');
    } else if (currentState === 'in-progress') {
      newState = 'completed';
      newIcon = window.getImagePath('completed.svg');
      newLabel = 'Task status: Completed';
      console.log('StateEvents: Transitioning from in-progress to completed');

      // Show and enable restart button when status is completed
      if (restartButton) {
        restartButton.style.display = 'flex';
        restartButton.disabled = false;
        console.log('StateEvents: Restart button shown and enabled');
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
      //       status: 'completed',
      //       isManual: false,
      //       id: taskId
      //     });
      //     this.stateManager.addReportRow(rowData, false); // Don't save yet (will auto-save via markDirty)
      //     console.log('StateEvents: Completed task added to Report via StateManager');
      //   }
      // }

      // Apply completed textarea state
      if (textarea) {
        this.applyCompletedTextareaState(textarea, row);
        console.log('StateEvents: Applied completed state to notes textarea');
      }

      // Also apply completed state to Task textarea for manual rows
      const taskTextarea = row.querySelector('.task-input');
      if (taskTextarea) {
        this.applyCompletedTextareaState(taskTextarea, row);
        console.log('StateEvents: Applied completed state to task textarea');
      }

    } else if (currentState === 'completed') {
      // Cycle back to pending
      newState = 'pending';
      newIcon = window.getImagePath('pending.svg');
      newLabel = 'Task status: Pending';
      console.log('StateEvents: Transitioning from completed to pending');

      // Hide restart button
      if (restartButton) {
        restartButton.style.display = 'none';
        console.log('StateEvents: Restart button hidden');
      }

      // Restore textarea to editable state
      if (textarea) {
        this.restoreTextareaState(textarea, row);
        console.log('StateEvents: Restored notes textarea to editable state');
      }

      // Also restore Task textarea for manual rows
      const taskTextarea = row.querySelector('.task-input');
      if (taskTextarea) {
        this.restoreTextareaState(taskTextarea, row);
        console.log('StateEvents: Restored task textarea to editable state');
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
    console.log('StateEvents: Marked state as dirty for auto-save');
  }

  // handleReportStatusChange method removed - reports now on separate page

  /**
   * Handle reset button click
   */
  handleReset(resetButton) {
    const row = resetButton.closest('tr');
    if (!row) return;

    const taskId = resetButton.getAttribute('data-id');
    const taskCell = row.querySelector('.task-cell');
    const taskText = taskCell ? taskCell.textContent : 'this task';

    // Update state in window.principleTableState for manual rows
    const principleId = row.closest('section')?.id;
    if (taskId && principleId && window.principleTableState && window.principleTableState[principleId]) {
      const rowData = window.principleTableState[principleId].find(r => r.id === taskId);
      if (rowData && rowData.isManual) {
        rowData.status = 'pending';
        console.log(`StateEvents: Reset manual row ${taskId} status to pending`);
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
    const row = deleteButton.closest('tr');
    if (!row) return;

    const rowId = row.getAttribute('data-id');
    const taskCell = row.querySelector('.report-task-cell');
    const taskText = taskCell ? taskCell.textContent : 'this row';

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
    statusButton.setAttribute('data-state', newState);
    statusButton.setAttribute('aria-label', newLabel);
    const statusImg = statusButton.querySelector('img');
    if (statusImg) {
      statusImg.src = newIcon;
    }
  }

  /**
   * Update manual row state in principleTableState
   * @private
   */
  _updateManualRowState(row, updates) {
    const rowId = row.getAttribute('data-id');
    const principleId = row.closest('section')?.id;
    if (rowId && principleId && window.principleTableState && window.principleTableState[principleId]) {
      const rowData = window.principleTableState[principleId].find(r => r.id === rowId);
      if (rowData && rowData.isManual) {
        Object.assign(rowData, updates);
        console.log(`StateEvents: Updated manual row ${rowId} state:`, rowData);
      }
    }
  }

  /**
   * Handle textarea input changes
   */
  handleTextChange(textarea, event) {
    const row = textarea.closest('tr');
    if (!row) return;

    // Handle Principles table textarea
    if (textarea.classList.contains('notes-textarea')) {
      const statusButton = row.querySelector('.status-button');
      if (statusButton) {
        const currentState = statusButton.getAttribute('data-state');
        const hasText = textarea.value.trim().length > 0;

        console.log(`StateEvents: Textarea change detected - current state: ${currentState}, has text: ${hasText}`);

        if (currentState === 'pending' && hasText) {
          // Has text: pending → in-progress
          this._updateStatusButton(statusButton, 'in-progress', 'Task status: In Progress', window.getImagePath('in-progress.svg'));
          console.log(`StateEvents: Status changed from pending to in-progress for row ${row.getAttribute('data-id')}`);
        } else if (currentState === 'in-progress' && !hasText) {
          // No text: in-progress → pending
          this._updateStatusButton(statusButton, 'pending', 'Task status: Pending', window.getImagePath('pending.svg'));
          console.log(`StateEvents: Status changed from in-progress to pending for row ${row.getAttribute('data-id')}`);
        }

        // Update state in window.principleTableState for manual rows
        this._updateManualRowState(row, {
          notes: textarea.value,
          status: statusButton.getAttribute('data-state')
        });
      } else {
        console.warn(`StateEvents: No status button found for textarea in row ${row.getAttribute('data-id')}`);
      }
    }

    // Handle Principles table task textarea (manual rows only)
    if (textarea.classList.contains('task-input')) {
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

    const targetId = link.getAttribute('href').substring(1);
    const targetSection = document.getElementById(targetId);
    if (!targetSection) {
      console.warn(`StateEvents: Target section ${targetId} not found`);
      return;
    }

    // Remove infocus class from all links
    const allLinks = document.querySelectorAll('.side-panel a');
    allLinks.forEach(l => {
      l.classList.remove('infocus');
      const activeImg = l.querySelector('.active-state');
      const inactiveImg = l.querySelector('.inactive-state');
      if (activeImg) activeImg.style.display = 'none';
      if (inactiveImg) inactiveImg.style.display = 'block';
    });

    // Add infocus class to clicked link
    link.classList.add('infocus');
    const activeImg = link.querySelector('.active-state');
    const inactiveImg = link.querySelector('.inactive-state');
    if (activeImg) activeImg.style.display = 'block';
    if (inactiveImg) inactiveImg.style.display = 'none';

    // Scroll to target section
    window.scrollTo({ top: targetSection.offsetTop, behavior: 'smooth' });

    // Focus the section heading with a small delay to ensure DOM is ready
    setTimeout(() => {
      const heading = targetSection.querySelector('h2.checklist-caption');
      if (heading) {
        // Ensure the heading is focusable
        if (!heading.hasAttribute('tabindex')) {
          heading.setAttribute('tabindex', '0');
        }
        // Focus the heading
        heading.focus();
        console.log(`StateEvents: Focused heading for ${targetId}`);
      } else {
        console.warn(`StateEvents: No checklist-caption heading found for ${targetId}`);
      }
    }, 100); // Small delay to ensure scroll and DOM updates are complete

    // Mark dirty for auto-save
    this.stateManager.markDirty();
  }

  /**
   * Handle side panel toggle click
   */
  handleSidePanelToggle(event) {
    const sidePanel = document.querySelector('.side-panel');
    const toggleStrip = document.querySelector('.toggle-strip');
    if (!sidePanel || !toggleStrip) return;

    const isExpanded = sidePanel.getAttribute('aria-expanded') === 'true';
    const newState = !isExpanded;
    sidePanel.setAttribute('aria-expanded', newState.toString());
    toggleStrip.setAttribute('aria-expanded', newState.toString());

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
    textarea.style.border = 'none';
    textarea.style.backgroundColor = 'transparent';
    textarea.style.color = '#666'; // Keep text visible but muted
    textarea.style.resize = 'none';
    textarea.style.pointerEvents = 'none';
    textarea.disabled = true;
    textarea.setAttribute('tabindex', '-1');
    textarea.setAttribute('aria-hidden', 'true');

    // Legacy overlay code removed - textareas now handle completed state directly
  }

  /**
   * Restore textarea to editable state
   */
  restoreTextareaState(textarea, row) {
    textarea.style.border = '';
    textarea.style.backgroundColor = '';
    textarea.style.color = '';
    textarea.style.resize = '';
    textarea.style.pointerEvents = '';
    textarea.disabled = false;
    textarea.setAttribute('tabindex', '0');
    textarea.setAttribute('aria-hidden', 'false');

    // Legacy overlay restoration code removed - textareas now handle state directly
  }

  // processCompletedRowTextareas method removed - reports now on separate page

  // REMOVED: storeCompletedTask() - Now handled directly by StateManager.addReportRow()
  // Event-based architecture replaced with direct method calls for clearer data flow
}

// Global instance (initialized after dependencies are ready)
window.stateEvents = null;

// Initialize after DOM is ready and dependencies exist
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', () => {
    if (window.unifiedStateManager && window.modalActions) {
      window.stateEvents = new StateEvents(window.unifiedStateManager, window.modalActions);
      console.log('State Events initialized - ready to setup listeners');
    }
  });
} else {
  if (window.unifiedStateManager && window.modalActions) {
    window.stateEvents = new StateEvents(window.unifiedStateManager, window.modalActions);
    console.log('State Events initialized - ready to setup listeners');
  }
}

export { StateEvents };

