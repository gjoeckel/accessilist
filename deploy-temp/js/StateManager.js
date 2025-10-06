/**
 * Unified State Manager - Consolidates all save/restore/session/state management
 * 
 * REPLACES:
 * - save-restore-orchestrator.js
 * - save-restore-api.js
 * - state-collector.js
 * - state-restorer.js
 * - session-manager.js
 * - auto-save-manager.js
 * - save-ui-manager.js
 * 
 * RESPONSIBILITIES:
 * - Session ID management
 * - State collection from DOM
 * - State restoration to DOM
 * - API communication (save/restore)
 * - Auto-save management
 * - Manual save UI
 * - Dirty state tracking
 * - Reset task functionality
 * - Delete report row functionality
 */

class UnifiedStateManager {
  constructor() {
    // Session management
    this.sessionKey = null;
    
    // Save/restore state
    this.isSaving = false;
    this.saveQueue = [];
    
    // Auto-save management
    this.isDirty = false;
    this.autoSaveTimeout = null;
    this.autoSaveEnabled = false;
    this.lastAutoSaveTime = null;
    this.manualSaveVerified = false;
    this.autoSaveListenersSetup = false;
    
    // UI elements
    this.saveButton = null;
    this.loadingOverlay = null;
    
    // Initialization
    this.initialized = false;
  }

  // ============================================================
  // INITIALIZATION
  // ============================================================

  initialize() {
    if (this.initialized) return;
    
    console.log('Initializing Unified State Manager');
    
    // Get session ID from URL
    this.sessionKey = this.getSessionId();
    
    // Initialize global state objects
    this.initializeGlobalStateObjects();
    
    // Initialize the main application first
    if (typeof window.initializeApp === 'function') {
      window.initializeApp();
    }
    
    // Setup UI
    this.initializeSaveButton();
    
    // Ensure instance exists in backend so Admin shows Created immediately
    this.ensureInstanceExists()
      .catch((e) => console.warn('Instantiate skipped or failed:', e));

    // Setup state restoration
    this.setupStateRestoration();
    
    // Enable auto-save immediately
    this.enableAutoSave();
    
    // Setup before unload handler for unsaved changes
    this.setupBeforeUnloadHandler();
    
    // Wait for content to be built before performing initial save
    // Only perform initial save if no restoration is needed
    document.addEventListener('contentBuilt', () => {
      if (!this.sessionKey) {
        // No session key means no restoration needed, safe to do initial save
        setTimeout(() => this.performInitialSave(), 100);
      } else {
        // Session key exists - restoration will handle the initial save if needed
        console.log('Skipping initial save - restoration will handle state initialization');
      }
    });
    
    this.initialized = true;
    console.log('Unified State Manager initialized with session:', this.sessionKey);
  }

  async ensureInstanceExists() {
    try {
      const apiPath = window.getAPIPath ? window.getAPIPath('instantiate') : '/php/api/instantiate.php';
      const typeSlug = await TypeManager.getTypeFromSources();
      const payload = {
        sessionKey: this.sessionKey,
        // Provide only slug; server derives display consistently
        typeSlug: typeSlug
      };
      const response = await fetch(apiPath, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
      });
      if (!response.ok) {
        throw new Error(`instantiate failed: ${response.status}`);
      }
      const result = await response.json();
      if (!result.success) {
        throw new Error(result.message || 'instantiate error');
      }
      return true;
    } catch (err) {
      // Non-fatal: Admin may still work; we warn and continue
      console.warn('ensureInstanceExists error:', err);
      return false;
    }
  }

  initializeGlobalStateObjects() {
    // Initialize principle table state for manual rows only
    if (!window.principleTableState) {
      window.principleTableState = {
        'checklist-1': [],
        'checklist-2': [],
        'checklist-3': [],
        'checklist-4': []
      };
    }
  }

  // ============================================================
  // SESSION MANAGEMENT
  // ============================================================

  getSessionId() {
    if (this.sessionKey) {
      return this.sessionKey;
    }
    
    // Prefer PHP-injected session key (minimal URL include)
    if (window.sessionKeyFromPHP && /^[A-Z0-9]{3}$/.test(window.sessionKeyFromPHP)) {
      this.sessionKey = window.sessionKeyFromPHP;
      return this.sessionKey;
    }
    // Parse minimal URL pattern: ?=XYZ
    const minimalMatch = (window.location.search || '').match(/^\?=([A-Z0-9]{3})$/);
    if (minimalMatch) {
      this.sessionKey = minimalMatch[1];
      return this.sessionKey;
    }
    const urlParams = new URLSearchParams(window.location.search);
    let sessionKey = urlParams.get('session');
    
    // Validate session key (3-10 alphanumeric characters)
    if (!sessionKey || !/^[A-Z0-9]{3,10}$/.test(sessionKey)) {
      sessionKey = this.generateSessionId();
    }
    
    this.sessionKey = sessionKey;
    return sessionKey;
  }

  generateSessionId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    let result = '';
    for (let i = 0; i < 3; i++) {
      result += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return result;
  }

  // ============================================================
  // STATE COLLECTION
  // ============================================================

  collectCurrentState() {
    return {
      sidePanel: this.collectSidePanelState(),
      notes: this.collectNotesState(),
      statusButtons: this.collectStatusButtonsState(),
      restartButtons: this.collectRestartButtonsState(),
      principleRows: this.collectPrincipleRowsState()
    };
  }

  collectSidePanelState() {
    const sidePanel = document.querySelector('.side-panel');
    if (!sidePanel) return { expanded: true, activeSection: 'checklist-1' };
    
    const expanded = sidePanel.getAttribute('aria-expanded') === 'true';
    const activeLink = sidePanel.querySelector('a.infocus');
    const activeSection = activeLink ? activeLink.getAttribute('href').substring(1) : 'checklist-1';
    
    return { expanded, activeSection };
  }

  collectNotesState() {
    const notes = {};
    const textareas = document.querySelectorAll('.notes-textarea, .report-task-textarea, .report-notes-textarea');
    
    textareas.forEach((textarea, index) => {
      if (textarea.id) {
        notes[textarea.id] = textarea.value;
      } else {
        // Try to create an ID based on other attributes
        const fallbackId = textarea.name || `textarea-${index}`;
        notes[fallbackId] = textarea.value;
      }
    });
    
    return notes;
  }

  collectStatusButtonsState() {
    const statusButtons = {};
    const buttons = document.querySelectorAll('.status-button[data-state], .report-status-button[data-state]');
    
    buttons.forEach((button, index) => {
      if (button.id) {
        statusButtons[button.id] = button.getAttribute('data-state');
      } else {
        // Try to create an ID based on other attributes or position
        const fallbackId = `status-button-${index}`;
        statusButtons[fallbackId] = button.getAttribute('data-state');
      }
    });
    
    return statusButtons;
  }

  collectRestartButtonsState() {
    const restartButtons = {};
    const buttons = document.querySelectorAll('.restart-button');
    
    buttons.forEach(button => {
      if (button.id) {
        restartButtons[button.id] = button.style.display !== 'none';
      }
    });
    
    return restartButtons;
  }


  collectPrincipleRowsState() {
    if (!window.principleTableState) return {};
    
    const principleRows = {};
    ['checklist-1', 'checklist-2', 'checklist-3', 'checklist-4'].forEach(principleId => {
      // Only collect manually added rows (not default static rows)
      principleRows[principleId] = window.principleTableState[principleId] || [];
    });
    return principleRows;
  }

  // ============================================================
  // STATE RESTORATION
  // ============================================================

  setupStateRestoration() {
    // Use the proper session key detection method
    const sessionKey = this.getSessionId();
    
    if (!sessionKey) {
      console.log('No session key found, skipping restoration');
      this.hideLoading();
      return;
    }
    
    console.log('Session key found, setting up restoration for:', sessionKey);
    
    // Ensure loading overlay is visible during restoration
    this.showLoading();
    
    // Wait for contentBuilt event
    document.addEventListener('contentBuilt', () => {
      setTimeout(() => this.restoreState(), 100);
    });
  }

  async restoreState() {
    const startTime = Date.now();
    const MIN_LOADING_TIME = 2000; // 2 seconds minimum
    
    try {
      const apiPath = window.getAPIPath ? window.getAPIPath('restore') : '/php/api/restore.php';
      const response = await fetch(`${apiPath}?sessionKey=${this.sessionKey}`);
      
      if (response.status === 404) {
        console.log('No saved data found for this session. Performing initial save.');
        // No existing data found, perform initial save to establish baseline
        setTimeout(() => this.performInitialSave(), 100);
        return;
      }
      
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }
      
      const result = await response.json();
      if (result.success && result.data) {
        // Handle both old and new data formats
        let stateData;
        if (result.data.state) {
          stateData = result.data.state;
        } else {
          stateData = this.convertOldFormatToNew(result.data);
        }
        
        // Apply state to DOM
        this.applyState(stateData);
        this.showStatusMessage('Data restored', 'success');
      }
    } catch (error) {
      console.error('Restore error:', error);
      this.showStatusMessage('Error restoring data', 'error');
    } finally {
      // Calculate remaining time before hiding overlay
      const elapsedTime = Date.now() - startTime;
      const remainingTime = Math.max(0, MIN_LOADING_TIME - elapsedTime);
      
      setTimeout(() => {
        this.hideLoading();
      }, remainingTime);
    }
  }

  applyState(state) {
    console.log('Applying state:', state);
    if (!state) return;
    
    // FIRST: Immediately jump to the saved section
    if (state.sidePanel && state.sidePanel.activeSection) {
      this.jumpToSection(state.sidePanel.activeSection);
    }
    
    // THEN: Restore all UI state components
    this.restoreNotesState(state.notes);
    this.restoreStatusButtonsState(state.statusButtons);
    this.restoreRestartButtonsState(state.restartButtons);
    // TEMPORARILY COMMENTED OUT - Report functionality is interfering with principle rows
    // this.restoreReportRowsState(state.reportRows);
    this.restorePrincipleRowsState(state.principleRows);
    
    // FINALLY: Set side panel state
    this.restoreSidePanelUIState(state.sidePanel);
    
    console.log('State restoration completed');
  }

  jumpToSection(sectionId) {
    const section = document.getElementById(sectionId);
    if (section) {
      console.log('Jumping to section:', sectionId);
      window.scrollTo(0, section.offsetTop);
    }
  }

  restoreSidePanelUIState(sidePanelState) {
    if (!sidePanelState) return;
    
    const sidePanel = document.querySelector('.side-panel');
    if (!sidePanel) return;
    
    // Restore expanded state
    sidePanel.setAttribute('aria-expanded', sidePanelState.expanded);
    
    // Restore active section highlighting
    if (sidePanelState.activeSection) {
      const activeLink = sidePanel.querySelector(`a[href="#${sidePanelState.activeSection}"]`);
      if (activeLink) {
        // Remove existing active states
        sidePanel.querySelectorAll('a').forEach(link => {
          link.classList.remove('infocus');
          const activeImg = link.querySelector('.active-state');
          const inactiveImg = link.querySelector('.inactive-state');
          if (activeImg) activeImg.style.display = 'none';
          if (inactiveImg) inactiveImg.style.display = 'block';
        });
        
        // Set new active state
        activeLink.classList.add('infocus');
        const activeImg = activeLink.querySelector('.active-state');
        const inactiveImg = activeLink.querySelector('.inactive-state');
        if (activeImg) activeImg.style.display = 'block';
        if (inactiveImg) inactiveImg.style.display = 'none';
      }
    }
  }

  restoreNotesState(notesState) {
    if (!notesState) return;
    
    Object.entries(notesState).forEach(([id, value]) => {
      const textarea = document.getElementById(id);
      if (textarea) {
        textarea.value = value;
      }
    });
  }

  restoreStatusButtonsState(statusButtonsState) {
    if (!statusButtonsState) return;
    
    Object.entries(statusButtonsState).forEach(([id, state]) => {
      const button = document.getElementById(id);
      if (button) {
        button.setAttribute('data-state', state);
        
        // Update aria-label
        const stateLabels = {
          'pending': 'Task status: Pending',
          'in-progress': 'Task status: In Progress',
          'completed': 'Task status: Completed'
        };
        button.setAttribute('aria-label', stateLabels[state] || 'Task status: Pending');
        
        // Update image
        const img = button.querySelector('img');
        if (img) {
          const imageMap = {
            'pending': 'pending.svg',
            'in-progress': 'in-progress.svg',
            'completed': 'completed.svg'
          };
          img.src = window.getImagePath ? window.getImagePath(imageMap[state]) : imageMap[state];
        }
        
        // If status is 'completed', apply the completed textarea state
        if (state === 'completed') {
          this.applyCompletedTextareaState(button);
        }
      }
    });
  }

  applyCompletedTextareaState(statusButton) {
    const row = statusButton.closest('tr');
    if (!row) return;
    
    const isReportRow = row.querySelector('.report-task-cell, .report-notes-cell');
    
    if (false) { // Report table removed - no longer needed
      // Report table handling removed
    } else {
      // Handle Principles table: Notes column AND Task column for manual rows
      const textarea = row.querySelector('.notes-textarea, textarea[id^="textarea-"]');
      if (textarea) {
        textarea.style.border = 'none';
        textarea.style.backgroundColor = 'transparent';
        textarea.style.color = '#666'; // Keep text visible but muted
        textarea.style.resize = 'none';
        textarea.style.pointerEvents = 'none';
        textarea.disabled = true;
        textarea.setAttribute('aria-hidden', 'true');
        textarea.setAttribute('tabindex', '-1');
        
        // Legacy overlay code removed - textareas now handle completed state directly
      }
      
      // Handle Task textarea for manual rows
      const isManualRow = row.classList.contains('manual-row');
      if (isManualRow) {
        const taskTextarea = row.querySelector('.task-input');
        if (taskTextarea) {
          taskTextarea.style.border = 'none';
          taskTextarea.style.backgroundColor = 'transparent';
          taskTextarea.style.color = '#666'; // Keep text visible but muted
          taskTextarea.style.resize = 'none';
          taskTextarea.style.pointerEvents = 'none';
          taskTextarea.disabled = true;
          taskTextarea.setAttribute('aria-hidden', 'true');
          taskTextarea.setAttribute('tabindex', '-1');
          
          // Legacy overlay code removed - textareas now handle completed state directly
        }
      }
    }
    
    // Show restart button if it exists
    const restartButton = row.querySelector('.restart-button');
    if (restartButton) {
      restartButton.style.display = 'flex';
    }
    
    // Keep status button active
    statusButton.disabled = false;
    statusButton.style.pointerEvents = 'auto';
  }

  restoreRestartButtonsState(restartButtonsState) {
    if (!restartButtonsState) return;
    
    Object.entries(restartButtonsState).forEach(([id, visible]) => {
      const button = document.getElementById(id);
      if (button) {
        button.style.display = visible ? 'block' : 'none';
      }
    });
  }


  restorePrincipleRowsState(principleRows) {
    if (!principleRows) return;
    
    Object.keys(principleRows).forEach(principleId => {
      const rows = principleRows[principleId];
      if (Array.isArray(rows)) {
        // Update window.principleTableState with restored data
        if (!window.principleTableState) {
          window.principleTableState = {};
        }
        window.principleTableState[principleId] = rows.filter(row => row.isManual);
        
        rows.forEach(rowData => {
          // Only restore manually added rows (not default ones)
          if (rowData.isManual) {
            // Check if row already exists in DOM to prevent duplicates
            const existingRow = document.querySelector(`tr[data-id="${rowData.id}"]`);
            if (!existingRow) {
              this.renderSinglePrincipleRow(rowData);
            } else {
              console.log(`Row ${rowData.id} already exists, skipping restoration`);
            }
          }
        });
      }
    });
  }

  convertOldFormatToNew(oldData) {
    return {
      sidePanel: oldData.sidePanelState || { expanded: true, activeSection: 'checklist-1' },
      notes: oldData.textareas || {},
      statusButtons: oldData.statusButtons || {},
      restartButtons: oldData.restartButtons || {},
      reportRows: oldData.reportRows || []
    };
  }

  // ============================================================
  // SAVE OPERATIONS
  // ============================================================

  async saveState(operation = 'manual') {
    if (this.isSaving) {
      this.saveQueue.push(operation);
      return;
    }
    
    this.isSaving = true;
    
    const state = this.collectCurrentState();
    
    const typeSlug = await TypeManager.getTypeFromSources();
    const displayName = await TypeManager.formatDisplayName(typeSlug);
    const saveData = {
      sessionKey: this.sessionKey,
      timestamp: Date.now(),
      // Use TypeManager for consistent type handling
      type: displayName,
      typeSlug: typeSlug,
      state: state
    };
    
    try {
      const apiPath = window.getAPIPath ? window.getAPIPath('save') : '/php/api/save.php';
      const response = await fetch(apiPath, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(saveData)
      });
      
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }
      
      const result = await response.json();
      if (result.success) {
        this.showStatusMessage('Saved', 'success');
        
        // Mark manual save as verified to enable auto-save
        if (operation === 'manual') {
          this.markManualSaveVerified();
        }
        
        this.clearDirty();
        return true;
      } else {
        throw new Error(result.message || 'Save failed');
      }
    } catch (error) {
      console.error('Save error:', error);
      this.showStatusMessage('Error saving changes', 'error');
      return false;
    } finally {
      this.isSaving = false;
      this.processSaveQueue().catch(error => {
        console.error('Error processing save queue:', error);
      });
    }
  }

  async processSaveQueue() {
    if (this.saveQueue.length > 0) {
      const operation = this.saveQueue.shift();
      await this.saveState(operation);
    }
  }

  // ============================================================
  // RESET TASK OPERATION
  // ============================================================

  resetTask(taskId, taskRow) {
    console.log('Resetting task:', taskId);
    
    const statusButton = taskRow.querySelector('.status-button');
    const notesCell = taskRow.querySelector('.notes-cell');
    const textarea = notesCell?.querySelector('.notes-textarea');
    const restartButton = taskRow.querySelector('.restart-button');
    
    // Check if this is a manual row (has task-input)
    const isManualRow = taskRow.classList.contains('manual-row');
    const taskTextarea = isManualRow ? taskRow.querySelector('.task-input') : null;
    
    // Legacy overlay removal code removed - overlays no longer used
    
    // Clear and restore Notes textarea
    if (textarea) {
      textarea.value = '';
      textarea.setAttribute('aria-hidden', 'false');
      textarea.removeAttribute('tabindex');
      textarea.removeAttribute('style');
      textarea.disabled = false;
    }
    
    // Clear and restore Task textarea for manual rows
    if (taskTextarea) {
      taskTextarea.value = '';
      taskTextarea.setAttribute('aria-hidden', 'false');
      taskTextarea.removeAttribute('tabindex');
      taskTextarea.removeAttribute('style');
      taskTextarea.disabled = false;
    }
    
    // Reset status button to pending
    if (statusButton) {
      statusButton.setAttribute('data-state', 'pending');
      statusButton.setAttribute('aria-label', 'Task status: Pending');
      statusButton.removeAttribute('aria-disabled');
      statusButton.style.pointerEvents = 'auto';
      statusButton.disabled = false;
      const statusImg = statusButton.querySelector('img');
      if (statusImg) {
        statusImg.src = window.getImagePath('pending.svg');
      }
    }
    
    // Hide restart button
    if (restartButton) {
      restartButton.style.display = 'none';
    }
    
    
    // Save state immediately
    this.saveState('reset').then(() => {
      console.log('State saved immediately after reset operation');
    }).catch((error) => {
      console.error('Failed to save state after reset:', error);
    });
    
    // Focus status button
    if (statusButton) {
      statusButton.focus();
    }
  }



  createPrincipleRowData({ principleId, task = '', notes = '', status = 'pending', isManual = true, id = null }) {
    let rowId;
    
    if (id) {
      // Use provided ID (for restoration)
      rowId = id;
    } else {
      // Generate new ID (for new rows)
      // Count only manual rows in the state to avoid conflicts
      const existingManualRows = window.principleTableState && window.principleTableState[principleId] 
        ? window.principleTableState[principleId].filter(row => row.isManual)
        : [];
      
      // Count existing DOM rows to get the next sequential number
      const existingRows = document.querySelectorAll(`#${principleId} .principles-table tbody tr`);
      const nextRowNumber = existingRows.length + 1;
      rowId = `${principleId.split('-')[1]}.${nextRowNumber}`;
    }
    
    return {
      id: rowId,
      principleId: principleId,
      task: task,
      notes: notes,
      status: status,
      isManual: isManual,
      infoLink: '' // No info link for user-added rows
    };
  }


  addPrincipleRow(rowData, saveImmediately = true) {
    console.log('StateManager: Adding principle row:', rowData);
    
    // Validate required global dependencies
    if (!window.principleTableState) {
      console.error('StateManager: principleTableState not available');
      return;
    }
    
    if (typeof window.createTableRow !== 'function') {
      console.error('StateManager: createTableRow function not available');
      return;
    }
    
    // Add to state
    if (!window.principleTableState[rowData.principleId]) {
      window.principleTableState[rowData.principleId] = [];
    }
    window.principleTableState[rowData.principleId].push(rowData);
    console.log('StateManager: Added to principleTableState, total rows:', window.principleTableState[rowData.principleId].length);
    
    // Render the new row
    this.renderSinglePrincipleRow(rowData);
    
    // Save if requested
    if (saveImmediately) {
      this.saveState('manual').catch(error => {
        console.error('Error saving state after adding row:', error);
      });
    }
    
    console.log('StateManager: Principle row added successfully');
  }


  renderSinglePrincipleRow(rowData) {
    const principleId = rowData.principleId;
    const currentTable = document.querySelector(`#${principleId} .principles-table tbody`);
    
    if (!currentTable) {
      console.error(`Table not found for ${principleId}`);
      return;
    }
    
    // Double-check if row already exists to prevent duplicates
    const existingRow = document.querySelector(`tr[data-id="${rowData.id}"]`);
    if (existingRow) {
      console.log(`Row ${rowData.id} already exists in DOM, skipping render`);
      return;
    }
    
    if (typeof window.createTableRow === 'function') {
      const newRowElement = window.createTableRow(rowData, 'principle');
      currentTable.appendChild(newRowElement);
      
      // Apply the saved status state after rendering
      if (rowData.status === 'completed') {
        this.applyCompletedStateToRow(newRowElement);
      }
      
      console.log(`Principle row rendered: ${rowData.id} with status: ${rowData.status}`);
    } else {
      console.error('createTableRow function not available');
    }
  }

  /**
   * Apply completed state to a restored row (for manual rows)
   */
  applyCompletedStateToRow(rowElement) {
    const statusButton = rowElement.querySelector('.status-button');
    const restartButton = rowElement.querySelector('.restart-button');
    
    if (!statusButton) {
      console.error('Status button not found in row');
      return;
    }
    
    // Update status button to completed state
    statusButton.setAttribute('data-state', 'completed');
    statusButton.setAttribute('aria-label', 'Task status: Completed');
    const completedImgPath = window.getImagePath('completed.svg');
    const statusImg = statusButton.querySelector('img');
    if (statusImg) {
      statusImg.src = completedImgPath;
    }
    
    // Show restart button
    if (restartButton) {
      restartButton.style.display = 'flex';
      restartButton.disabled = false;
    }
    
    // Apply completed state to textareas WITHOUT creating overlays (restore scenario)
    this.applyCompletedTextareaStateForRestore(rowElement);
    
    console.log(`Applied completed state to row: ${rowElement.getAttribute('data-id')}`);
  }

  /**
   * Apply completed state to textareas during restore (without creating overlays)
   */
  applyCompletedTextareaStateForRestore(rowElement) {
    // Handle Notes textarea
    const notesTextarea = rowElement.querySelector('.notes-textarea, textarea[id^="textarea-"]');
    if (notesTextarea) {
      notesTextarea.style.border = 'none';
      notesTextarea.style.backgroundColor = 'transparent';
      notesTextarea.style.color = '#666'; // Keep text visible but muted
      notesTextarea.style.resize = 'none';
      notesTextarea.style.pointerEvents = 'none';
      notesTextarea.disabled = true;
      notesTextarea.setAttribute('aria-hidden', 'true');
      notesTextarea.setAttribute('tabindex', '-1');
    }
    
    // Handle Task textarea for manual rows
    const isManualRow = rowElement.classList.contains('manual-row');
    if (isManualRow) {
      const taskTextarea = rowElement.querySelector('.task-input');
      if (taskTextarea) {
        taskTextarea.style.border = 'none';
        taskTextarea.style.backgroundColor = 'transparent';
        taskTextarea.style.color = '#666'; // Keep text visible but muted
        taskTextarea.style.resize = 'none';
        taskTextarea.style.pointerEvents = 'none';
        taskTextarea.disabled = true;
        taskTextarea.setAttribute('aria-hidden', 'true');
        taskTextarea.setAttribute('tabindex', '-1');
      }
    }
  }

  // ============================================================
  // BEFORE UNLOAD HANDLER
  // ============================================================

  setupBeforeUnloadHandler() {
    window.addEventListener('beforeunload', (event) => {
      if (this.isDirty) {
        // Show browser's native confirmation dialog
        // This is the standard, reliable approach used by Google Docs, GitHub, etc.
        event.preventDefault();
        event.returnValue = 'You have unsaved changes. Are you sure you want to leave?';
        return event.returnValue;
      }
    });
  }

  // ============================================================
  // AUTO-SAVE MANAGEMENT
  // ============================================================

  markDirty() {
    this.isDirty = true;
    
    // Clear existing timeout
    if (this.autoSaveTimeout) {
      clearTimeout(this.autoSaveTimeout);
    }
    
    // Only auto-save if enabled and not too frequent
    if (this.autoSaveEnabled && this.canAutoSave()) {
      this.autoSaveTimeout = setTimeout(() => {
        this.saveState('auto').then(() => {
          this.isDirty = false;
          this.lastAutoSaveTime = Date.now();
        }).catch((error) => {
          console.error('Auto-save error:', error);
        });
      }, 3000); // 3 seconds debounce
    }
  }

  canAutoSave() {
    if (this.lastAutoSaveTime) {
      const timeSinceLastSave = Date.now() - this.lastAutoSaveTime;
      return timeSinceLastSave > 10000; // 10 seconds minimum between auto-saves
    }
    return true;
  }

  clearDirty() {
    this.isDirty = false;
    if (this.autoSaveTimeout) {
      clearTimeout(this.autoSaveTimeout);
      this.autoSaveTimeout = null;
    }
  }

  markManualSaveVerified() {
    this.manualSaveVerified = true;
    this.autoSaveEnabled = true;
    console.log('Manual save verified - auto-save enabled');
    
    // Setup auto-save listeners after first manual save
    this.setupAutoSaveListeners();
  }

  enableAutoSave() {
    this.autoSaveEnabled = true;
    console.log('Auto-save enabled');
    
    // Setup auto-save listeners immediately
    this.setupAutoSaveListeners();
  }

  async performInitialSave() {
    try {
      console.log('Performing initial save...');
      const success = await this.saveState('auto');
      if (success) {
        console.log('Initial save completed successfully');
        this.markManualSaveVerified(); // Enable full auto-save functionality
      }
    } catch (error) {
      console.warn('Initial save failed:', error);
      // Don't throw - this is not critical for app functionality
    }
  }

  setupAutoSaveListeners() {
    // Prevent duplicate listeners
    if (this.autoSaveListenersSetup) {
      return;
    }
    this.autoSaveListenersSetup = true;
    
    // Listen for changes that should trigger auto-save
    document.addEventListener('input', (event) => {
      if (event.target.classList.contains('notes-textarea') ||
          event.target.classList.contains('task-input') ||
          event.target.classList.contains('report-task-textarea') ||
          event.target.classList.contains('report-notes-textarea')) {
        this.markDirty();
      }
    });
    
    document.addEventListener('click', (event) => {
      // Status button changes
      if (event.target.closest('.status-button') || event.target.closest('.report-status-button')) {
        this.markDirty();
      }
      
      // Restart button changes
      if (event.target.closest('.restart-button')) {
        this.markDirty();
      }
      
      // Side panel navigation
      if (event.target.closest('.side-panel a')) {
        this.markDirty();
      }
      
      // Side panel toggle
      if (event.target.closest('.toggle-strip')) {
        this.markDirty();
      }
    });
    
    console.log('Auto-save listeners setup complete');
  }

  setupUnsavedChangesProtection() {
    window.addEventListener('beforeunload', (event) => {
      if (this.isDirty) {
        event.preventDefault();
        event.returnValue = 'You have unsaved changes. Are you sure you want to leave?';
        return event.returnValue;
      }
    });
  }

  // ============================================================
  // SAVE BUTTON UI
  // ============================================================

  initializeSaveButton() {
    const saveButton = document.getElementById('saveButton');
    
    if (saveButton && !this.saveButton) {
      this.saveButton = saveButton;
      this.setupSaveButtonEventListeners();
      console.log('Save button initialized');
    } else if (!saveButton) {
      console.error('Save button not found in HTML');
    }
  }

  setupSaveButtonEventListeners() {
    if (!this.saveButton) return;
    
    this.saveButton.addEventListener('click', async (event) => {
      event.preventDefault();
      
      try {
        this.saveButton.setAttribute('aria-busy', 'true');
        this.saveButton.disabled = true;
        
        this.announceSaveAction('Saving checklist...');
        
        const success = await this.saveState('manual');
        
        if (success) {
          this.announceSaveAction('Checklist saved successfully');
        } else {
          this.announceSaveAction('Error saving checklist');
        }
      } catch (error) {
        console.error('Save error:', error);
        this.announceSaveAction('Error saving checklist');
      } finally {
        this.saveButton.removeAttribute('aria-busy');
        this.saveButton.disabled = false;
      }
    });
  }

  announceSaveAction(message) {
    let statusElement = document.getElementById('save-status');
    if (!statusElement) {
      statusElement = document.createElement('div');
      statusElement.id = 'save-status';
      statusElement.setAttribute('role', 'status');
      statusElement.setAttribute('aria-live', 'polite');
      statusElement.className = 'sr-only';
      document.body.appendChild(statusElement);
    }
    
    statusElement.textContent = message;
    
    setTimeout(() => {
      if (statusElement) {
        statusElement.textContent = '';
      }
    }, 3000);
  }

  // ============================================================
  // LOADING OVERLAY
  // ============================================================

  showLoading() {
    const loadingOverlay = document.getElementById('loadingOverlay');
    if (loadingOverlay) {
      console.log('Showing loading overlay');
      loadingOverlay.style.display = 'flex';
    } else {
      console.log('Loading overlay element not found!');
    }
  }

  hideLoading() {
    const loadingOverlay = document.getElementById('loadingOverlay');
    if (loadingOverlay) {
      console.log('Hiding loading overlay');
      loadingOverlay.style.display = 'none';
    }
  }

  // ============================================================
  // STATUS MESSAGES
  // ============================================================

  showStatusMessage(message, type = 'info') {
    if (window.statusManager && typeof window.statusManager.showMessage === 'function') {
      window.statusManager.showMessage(message, type);
    } else {
      console.log(`[${type.toUpperCase()}] ${message}`);
    }
  }
}

// Global instance
window.unifiedStateManager = new UnifiedStateManager();

// Auto-initialize when DOM is ready
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', () => {
    window.unifiedStateManager.initialize();
  });
} else {
  window.unifiedStateManager.initialize();
}

// Export global convenience functions for backward compatibility
window.saveChecklistState = () => window.unifiedStateManager.saveState('manual').catch(error => {
  console.error('Error in global save function:', error);
});
window.restoreChecklistState = () => window.unifiedStateManager.restoreState();
window.markChecklistDirty = () => window.unifiedStateManager.markDirty();
window.hideLoading = () => window.unifiedStateManager.hideLoading();
window.clearChecklistDirty = () => window.unifiedStateManager.clearDirty();

export { UnifiedStateManager };

