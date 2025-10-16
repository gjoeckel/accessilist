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

  async initialize() {
    if (this.initialized) return;

    console.log("Initializing Unified State Manager");

    // Get session ID from URL or server
    this.sessionKey = await this.getSessionId();

    // Initialize global state objects
    this.initializeGlobalStateObjects();

    // Initialize the main application first
    if (typeof window.initializeApp === "function") {
      window.initializeApp();
    }

    // Initialize ModalActions for StateEvents
    this.initializeModalActions();

    // Setup UI
    this.initializeSaveButton();

    // Ensure instance exists in backend so Admin shows Created immediately
    this.ensureInstanceExists().catch((e) =>
      console.warn("Instantiate skipped or failed:", e)
    );

    // Setup state restoration
    await this.setupStateRestoration();

    // Enable auto-save immediately
    this.enableAutoSave();

    // Setup before unload handler for unsaved changes
    this.setupBeforeUnloadHandler();

    // Wait for content to be built before performing initial save
    // Only perform initial save if no restoration is needed
    document.addEventListener("contentBuilt", () => {
      if (!this.sessionKey) {
        // No session key means no restoration needed, safe to do initial save
        setTimeout(() => this.performInitialSave(), 100);
      } else {
        // Session key exists - restoration will handle the initial save if needed
        console.log(
          "Skipping initial save - restoration will handle state initialization"
        );
      }
    });

    this.initialized = true;
    console.log(
      "Unified State Manager initialized with session:",
      this.sessionKey
    );
  }

  async ensureInstanceExists() {
    try {
      // STRICT MODE: getAPIPath must be available (no fallback)
      if (!window.getAPIPath) {
        throw new Error(
          "path-utils.js not loaded - getAPIPath function missing"
        );
      }

      const apiPath = window.getAPIPath("instantiate");
      const typeSlug = await TypeManager.getTypeFromSources();
      const payload = {
        sessionKey: this.sessionKey,
        // Provide only slug; server derives display consistently
        typeSlug: typeSlug,
      };
      const response = await fetch(apiPath, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload),
      });
      if (!response.ok) {
        throw new Error(`instantiate failed: ${response.status}`);
      }
      const result = await response.json();
      if (!result.success) {
        throw new Error(result.message || "instantiate error");
      }
      return true;
    } catch (err) {
      // Non-fatal: Admin may still work; we warn and continue
      console.warn("ensureInstanceExists error:", err);
      return false;
    }
  }

  initializeGlobalStateObjects() {
    // Initialize checkpoint table state for manual rows only
    if (!window.checkpointTableState) {
      // Dynamic initialization based on JSON checkpoints
      const checkpointRows = {};

      if (window.checklistData) {
        // Find all checkpoint-* or checklist-* keys
        Object.keys(window.checklistData).forEach((key) => {
          if (key.startsWith("checkpoint-") || key.startsWith("checklist-")) {
            checkpointRows[key] = [];
          }
        });
      }

      // Fallback to empty object if no checklistData available yet
      window.checkpointTableState =
        Object.keys(checkpointRows).length > 0 ? checkpointRows : {};

      console.log(
        "Initialized checkpointTableState:",
        window.checkpointTableState
      );
    }
  }

  initializeModalActions() {
    // Initialize ModalActions for StateEvents dependency
    if (!window.modalActions && window.ModalActions) {
      window.modalActions = new window.ModalActions(this);
      console.log("ModalActions initialized");
    } else if (!window.ModalActions) {
      console.warn(
        "ModalActions class not available - StateEvents may not initialize"
      );
    }
  }

  // ============================================================
  // SESSION MANAGEMENT
  // ============================================================

  async getSessionId() {
    if (this.sessionKey) {
      return this.sessionKey;
    }

    // Prefer PHP-injected session key (minimal URL include)
    if (
      window.sessionKeyFromPHP &&
      /^[A-Z0-9]{3}$/.test(window.sessionKeyFromPHP)
    ) {
      this.sessionKey = window.sessionKeyFromPHP;
      return this.sessionKey;
    }

    // Parse minimal URL pattern: ?=XYZ
    const minimalMatch = (window.location.search || "").match(
      /^\?=([A-Z0-9]{3})$/
    );
    if (minimalMatch) {
      this.sessionKey = minimalMatch[1];
      return this.sessionKey;
    }

    const urlParams = new URLSearchParams(window.location.search);
    let sessionKey = urlParams.get("session");

    // Validate existing session key (3-character alphanumeric)
    if (sessionKey && /^[A-Z0-9]{3}$/.test(sessionKey)) {
      this.sessionKey = sessionKey;
      return sessionKey;
    }

    // Request new unique key from server
    try {
      const apiPath = window.getAPIPath("generate-key");
      const response = await fetch(apiPath);
      const result = await response.json();

      if (result.success && result.data && result.data.sessionKey) {
        this.sessionKey = result.data.sessionKey;
        return this.sessionKey;
      }

      throw new Error("Server failed to generate key");
    } catch (error) {
      console.error("Failed to get session key from server:", error);
      throw new Error(
        "Unable to initialize session - server key generation failed"
      );
    }
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
      checkpointRows: this.collectCheckpointRowsState(),
    };
  }

  collectSidePanelState() {
    const sidePanel = document.querySelector(".side-panel");
    if (!sidePanel) return { expanded: true, activeSection: "checkpoint-1" };

    const expanded = sidePanel.getAttribute("aria-expanded") === "true";
    const activeLink = sidePanel.querySelector("a.infocus");
    const activeSection = activeLink
      ? activeLink.getAttribute("data-target") ||
        activeLink.getAttribute("href")?.substring(1)
      : "checkpoint-1";

    return { expanded, activeSection };
  }

  collectNotesState() {
    const notes = {};
    const textareas = document.querySelectorAll(
      ".notes-textarea, .report-task-textarea, .report-notes-textarea"
    );

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
    const buttons = document.querySelectorAll(
      ".status-button[data-state], .report-status-button[data-state]"
    );

    buttons.forEach((button, index) => {
      if (button.id) {
        statusButtons[button.id] = {
          state: button.getAttribute("data-state"),
          flag: button.getAttribute("data-status-flag") || "text-manual", // Save status flag for template rows
        };
      } else {
        // Try to create an ID based on other attributes or position
        const fallbackId = `status-button-${index}`;
        statusButtons[fallbackId] = {
          state: button.getAttribute("data-state"),
          flag: button.getAttribute("data-status-flag") || "text-manual",
        };
      }
    });

    return statusButtons;
  }

  collectRestartButtonsState() {
    const restartButtons = {};
    const buttons = document.querySelectorAll(".restart-button");

    buttons.forEach((button) => {
      if (button.id) {
        restartButtons[button.id] =
          button.classList.contains("restart-visible");
      }
    });

    return restartButtons;
  }

  collectCheckpointRowsState() {
    if (!window.checkpointTableState) return {};

    const checkpointRows = {};

    // Dynamic checkpoint detection from JSON data
    const checkpointKeys = window.checklistData
      ? Object.keys(window.checklistData).filter(
          (key) => key.startsWith("checkpoint-") || key.startsWith("checklist-")
        )
      : Object.keys(window.checkpointTableState); // Fallback to existing state keys

    checkpointKeys.forEach((checkpointId) => {
      // Only collect manually added rows (not default static rows)
      checkpointRows[checkpointId] =
        window.checkpointTableState[checkpointId] || [];
    });
    return checkpointRows;
  }

  // ============================================================
  // STATE RESTORATION
  // ============================================================

  async setupStateRestoration() {
    // Session key is already set in initialize()
    const sessionKey = this.sessionKey;

    if (!sessionKey) {
      console.log("No session key found, skipping restoration");
      this.hideLoading();
      return;
    }

    console.log("Session key found, setting up restoration for:", sessionKey);

    // Ensure loading overlay is visible during restoration
    this.showLoading();

    // Wait for contentBuilt event
    document.addEventListener("contentBuilt", () => {
      setTimeout(() => this.restoreState(), 100);
    });
  }

  async restoreState() {
    const startTime = Date.now();
    const MIN_LOADING_TIME = 2000; // 2 seconds minimum

    try {
      // STRICT MODE: getAPIPath must be available (no fallback)
      if (!window.getAPIPath) {
        throw new Error(
          "path-utils.js not loaded - getAPIPath function missing"
        );
      }

      const apiPath = window.getAPIPath("restore");
      const response = await fetch(`${apiPath}?sessionKey=${this.sessionKey}`);

      if (response.status === 404) {
        console.log(
          "No saved data found for this session. Performing initial save."
        );
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
        const key = this.sessionKey || window.sessionKeyFromPHP || "--no key";
        if (
          window.statusManager &&
          typeof window.statusManager.announce === "function"
        ) {
          const frag = document.createDocumentFragment();
          frag.append(document.createTextNode("Restored using "));
          const strong = document.createElement("strong");
          strong.textContent = key;
          frag.append(strong);
          window.statusManager.announce(frag, {
            type: "success",
            timeout: 5000,
          });
        } else {
          this.showStatusMessage(`Restored using ${key}`, "success");
        }
      }
    } catch (error) {
      console.error("Restore error:", error);
      const key = this.sessionKey || window.sessionKeyFromPHP || "--no key";
      if (
        window.statusManager &&
        typeof window.statusManager.announce === "function"
      ) {
        const frag = document.createDocumentFragment();
        frag.append(document.createTextNode("Error restoring "));
        const strong = document.createElement("strong");
        strong.textContent = key;
        frag.append(strong);
        window.statusManager.announce(frag, { type: "error", timeout: 4000 });
      } else {
        this.showStatusMessage(`Error restoring ${key}`, "error");
      }
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
    console.log("Applying state:", state);
    if (!state) return;

    // FIRST: Immediately jump to the saved section
    if (state.sidePanel && state.sidePanel.activeSection) {
      this.jumpToSection(state.sidePanel.activeSection);
    }

    // THEN: Restore all UI state components
    this.restoreNotesState(state.notes);
    this.restoreStatusButtonsState(state.statusButtons);
    this.restoreRestartButtonsState(state.restartButtons);
    // TEMPORARILY COMMENTED OUT - Report functionality is interfering with checkpoint rows
    // this.restoreReportRowsState(state.reportRows);
    this.restoreCheckpointRowsState(state.checkpointRows);

    // FINALLY: Set side panel state
    this.restoreSidePanelUIState(state.sidePanel);

    console.log("State restoration completed");
  }

  /**
   * Scroll a section to the standard position (below sticky header)
   * @param {HTMLElement} section - The section element to scroll to
   * @param {Object} options - Options for scroll behavior
   * @returns {number} The scroll position used
   */
  scrollSectionToPosition(section, options = {}) {
    if (!section) return 0;

    const SECTION_TOP_POSITION = 90; // 70px header + 20px breathing room
    const scrollToPosition = section.offsetTop - SECTION_TOP_POSITION;
    const behavior = options.smooth ? "smooth" : "auto";
    const clampedPosition = Math.max(0, scrollToPosition);

    console.log(
      `StateManager: Scrolling section to position:`,
      clampedPosition
    );
    console.log(
      "Section offsetTop:",
      section.offsetTop,
      "SECTION_TOP_POSITION:",
      SECTION_TOP_POSITION
    );

    window.scrollTo({ top: clampedPosition, behavior });
    return clampedPosition;
  }

  jumpToSection(sectionId) {
    const section = document.getElementById(sectionId);
    if (section) {
      this.scrollSectionToPosition(section, { smooth: false });
    } else {
      console.warn(
        `StateManager: Section ${sectionId} not found for jumpToSection`
      );
    }
  }

  restoreSidePanelUIState(sidePanelState) {
    if (!sidePanelState) return;

    const sidePanel = document.querySelector(".side-panel");
    if (!sidePanel) return;

    // Restore expanded state
    sidePanel.setAttribute("aria-expanded", sidePanelState.expanded);

    // Restore active section highlighting
    if (sidePanelState.activeSection) {
      const activeLink = sidePanel.querySelector(
        `a[href="#${sidePanelState.activeSection}"]`
      );
      if (activeLink) {
        // Remove existing active states
        sidePanel.querySelectorAll("a").forEach((link) => {
          link.classList.remove("infocus");
          const activeImg = link.querySelector(".active-state");
          const inactiveImg = link.querySelector(".inactive-state");
          if (activeImg) activeImg.classList.remove("show");
          if (inactiveImg) inactiveImg.classList.remove("hide");
        });

        // Set new active state
        activeLink.classList.add("infocus");
        const activeImg = activeLink.querySelector(".active-state");
        const inactiveImg = activeLink.querySelector(".inactive-state");
        if (activeImg) activeImg.classList.add("show");
        if (inactiveImg) inactiveImg.classList.add("hide");
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

    Object.entries(statusButtonsState).forEach(([id, stateData]) => {
      const button = document.getElementById(id);
      if (button) {
        // Handle both old format (string) and new format (object with state and flag)
        const state =
          typeof stateData === "string" ? stateData : stateData.state;
        const flag =
          typeof stateData === "object"
            ? stateData.flag || "text-manual"
            : "text-manual";

        button.setAttribute("data-state", state);
        button.setAttribute("data-status-flag", flag); // Restore status flag for auto-behavior

        // Update aria-label
        const stateLabels = {
          ready: "Task status: Ready",
          active: "Task status: Active",
          done: "Task status: Done",
        };
        button.setAttribute(
          "aria-label",
          stateLabels[state] || "Task status: Ready"
        );

        // Update image
        const img = button.querySelector("img");
        if (img) {
          const imageMap = {
            ready: "ready-1.svg",
            active: "active-1.svg",
            done: "done-1.svg",
          };
          img.src = window.getImagePath
            ? window.getImagePath(imageMap[state])
            : imageMap[state];
        }

        // If status is 'done', apply the completed textarea state
        if (state === "done") {
          this.applyCompletedTextareaState(button);
        }
      }
    });
  }

  applyCompletedTextareaState(statusButton) {
    const row = statusButton.closest("tr");
    if (!row) return;

    const isReportRow = row.querySelector(
      ".report-task-cell, .report-notes-cell"
    );

    if (false) {
      // Report table removed - no longer needed
      // Report table handling removed
    } else {
      // Handle Checkpoints table: Notes column AND Task column for manual rows
      const textarea = row.querySelector(
        '.notes-textarea, textarea[id^="textarea-"]'
      );
      if (textarea) {
        textarea.classList.add("textarea-completed");
        textarea.disabled = true;
        textarea.setAttribute("aria-hidden", "true");
        textarea.setAttribute("tabindex", "-1");

        // Legacy overlay code removed - textareas now handle completed state directly
      }

      // Handle Task textarea for manual rows
      const isManualRow = row.classList.contains("manual-row");
      if (isManualRow) {
        const taskTextarea = row.querySelector(".task-input");
        if (taskTextarea) {
          taskTextarea.classList.add("textarea-completed");
          taskTextarea.disabled = true;
          taskTextarea.setAttribute("aria-hidden", "true");
          taskTextarea.setAttribute("tabindex", "-1");

          // Legacy overlay code removed - textareas now handle completed state directly
        }
      }
    }

    // Show restart button if it exists
    const restartButton = row.querySelector(".restart-button");
    if (restartButton) {
      restartButton.classList.remove("restart-hidden");
      restartButton.classList.add("restart-visible");
    }

    // Keep status button active
    statusButton.disabled = false;
    statusButton.classList.add("status-interactive");
  }

  restoreRestartButtonsState(restartButtonsState) {
    if (!restartButtonsState) return;

    Object.entries(restartButtonsState).forEach(([id, visible]) => {
      const button = document.getElementById(id);
      if (button) {
        if (visible) {
          button.classList.remove("restart-hidden");
          button.classList.add("restart-visible");
        } else {
          button.classList.remove("restart-visible");
          button.classList.add("restart-hidden");
        }
      }
    });
  }

  restoreCheckpointRowsState(checkpointRows) {
    if (!checkpointRows) return;

    Object.keys(checkpointRows).forEach((checkpointId) => {
      const rows = checkpointRows[checkpointId];
      if (Array.isArray(rows)) {
        // Update window.checkpointTableState with restored data
        if (!window.checkpointTableState) {
          window.checkpointTableState = {};
        }
        window.checkpointTableState[checkpointId] = rows.filter(
          (row) => row.isManual
        );

        rows.forEach((rowData) => {
          // Only restore manually added rows (not default ones)
          if (rowData.isManual) {
            // Check if row already exists in DOM to prevent duplicates
            const existingRow = document.querySelector(
              `tr[data-id="${rowData.id}"]`
            );
            if (!existingRow) {
              this.renderSingleCheckpointRow(rowData);
            } else {
              console.log(
                `Row ${rowData.id} already exists, skipping restoration`
              );
            }
          }
        });
      }
    });
  }

  convertOldFormatToNew(oldData) {
    return {
      sidePanel: oldData.sidePanelState || {
        expanded: true,
        activeSection: "checkpoint-1",
      },
      notes: oldData.textareas || {},
      statusButtons: oldData.statusButtons || {},
      restartButtons: oldData.restartButtons || {},
      reportRows: oldData.reportRows || [],
    };
  }

  // ============================================================
  // SAVE OPERATIONS
  // ============================================================

  async saveState(operation = "manual") {
    if (this.isSaving) {
      this.saveQueue.push(operation);
      return;
    }

    this.isSaving = true;

    const state = this.collectCurrentState();

    const typeSlug = await TypeManager.getTypeFromSources();

    // STRICT MODE: Only send typeSlug (no legacy 'type' field)
    const saveData = {
      sessionKey: this.sessionKey,
      timestamp: Date.now(),
      typeSlug: typeSlug,
      state: state,
    };

    try {
      // STRICT MODE: getAPIPath must be available (no fallback)
      if (!window.getAPIPath) {
        throw new Error(
          "path-utils.js not loaded - getAPIPath function missing"
        );
      }

      const apiPath = window.getAPIPath("save");
      const response = await fetch(apiPath, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(saveData),
      });

      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }

      const result = await response.json();
      if (result.success) {
        const ts = new Date();
        const timeString = ts.toLocaleTimeString([], {
          hour: "numeric",
          minute: "2-digit",
        });
        const msg = `Saved at ${timeString}`;
        if (
          window.statusManager &&
          typeof window.statusManager.announce === "function"
        ) {
          window.statusManager.announce(msg, {
            type: "success",
            timeout: 5000,
          });
        } else {
          this.showStatusMessage(msg, "success");
        }

        if (operation === "manual") {
          this.markManualSaveVerified();
        }

        this.clearDirty();
        return true;
      } else {
        throw new Error(result.message || "Save failed");
      }
    } catch (error) {
      console.error("Save error:", error);
      const key = this.sessionKey || window.sessionKeyFromPHP || "--no key";
      if (
        window.statusManager &&
        typeof window.statusManager.announce === "function"
      ) {
        const frag = document.createDocumentFragment();
        frag.append(document.createTextNode("Error saving "));
        const strong = document.createElement("strong");
        strong.textContent = key;
        frag.append(strong);
        window.statusManager.announce(frag, { type: "error", timeout: 4000 });
      } else {
        this.showStatusMessage(`Error saving ${key}`, "error");
      }
      return false;
    } finally {
      this.isSaving = false;
      this.processSaveQueue().catch((error) => {
        console.error("Error processing save queue:", error);
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
    console.log("Resetting task:", taskId);

    const statusButton = taskRow.querySelector(".status-button");
    const notesCell = taskRow.querySelector(".notes-cell");
    const textarea = notesCell?.querySelector(".notes-textarea");
    const restartButton = taskRow.querySelector(".restart-button");

    // Check if this is a manual row (has task-input)
    const isManualRow = taskRow.classList.contains("manual-row");
    const taskTextarea = isManualRow
      ? taskRow.querySelector(".task-input")
      : null;

    // Legacy overlay removal code removed - overlays no longer used

    // Clear and restore Notes textarea
    if (textarea) {
      textarea.value = "";
      textarea.classList.remove("textarea-completed");
      textarea.setAttribute("aria-hidden", "false");
      textarea.setAttribute("tabindex", "0");
      textarea.disabled = false;
    }

    // Clear and restore Task textarea for manual rows
    if (taskTextarea) {
      taskTextarea.value = "";
      taskTextarea.classList.remove("textarea-completed");
      taskTextarea.setAttribute("aria-hidden", "false");
      taskTextarea.setAttribute("tabindex", "0");
      taskTextarea.disabled = false;
    }

    // Reset status button to ready
    if (statusButton) {
      statusButton.setAttribute("data-state", "ready");
      statusButton.setAttribute("aria-label", "Task status: Ready");
      statusButton.removeAttribute("aria-disabled");
      statusButton.classList.add("status-interactive");
      statusButton.disabled = false;
      const statusImg = statusButton.querySelector("img");
      if (statusImg) {
        statusImg.src = window.getImagePath("ready-1.svg");
      }
    }

    // Reset status flag to default
    this.resetStatusFlag(taskId);
    console.log(`[Reset] ${taskId}: Flag reset to text-manual`);

    // Hide restart button
    if (restartButton) {
      restartButton.classList.remove("restart-visible");
      restartButton.classList.add("restart-hidden");
    }

    // Save state immediately
    this.saveState("reset")
      .then(() => {
        console.log("State saved immediately after reset operation");
      })
      .catch((error) => {
        console.error("Failed to save state after reset:", error);
      });

    // Focus status button
    if (statusButton) {
      statusButton.focus();
    }
  }

  // ============================================================
  // STATUS FLAG MANAGEMENT
  // ============================================================

  /**
   * Get status flag for a task row
   * @param {string} taskId - Task ID (e.g., "1.1")
   * @returns {string} Flag value ('text-manual', 'active-auto', 'active-manual')
   */
  getStatusFlag(taskId) {
    // First check if task exists in checkpointTableState (manual rows)
    if (window.checkpointTableState) {
      for (const checkpointId in window.checkpointTableState) {
        const rows = window.checkpointTableState[checkpointId];
        const taskRow = rows.find((row) => row.id === taskId);
        if (taskRow) {
          return taskRow.statusFlag || "text-manual";
        }
      }
    }

    // For template rows, check DOM data attribute
    const statusButton = document.getElementById(`status-${taskId}`);
    if (statusButton && statusButton.hasAttribute("data-status-flag")) {
      return statusButton.getAttribute("data-status-flag");
    }

    // Default to text-manual if not found
    return "text-manual";
  }

  /**
   * Set status flag for a task row
   * @param {string} taskId - Task ID (e.g., "1.1")
   * @param {string} flag - Flag value ('text-manual', 'active-auto', 'active-manual')
   */
  setStatusFlag(taskId, flag) {
    // First try to update in checkpointTableState (manual rows)
    if (window.checkpointTableState) {
      for (const checkpointId in window.checkpointTableState) {
        const rows = window.checkpointTableState[checkpointId];
        const taskRow = rows.find((row) => row.id === taskId);
        if (taskRow) {
          taskRow.statusFlag = flag;
          console.log(`[StatusFlag] ${taskId}: Set to ${flag} (in state)`);
          return;
        }
      }
    }

    // For template rows, use DOM data attribute
    const statusButton = document.getElementById(`status-${taskId}`);
    if (statusButton) {
      statusButton.setAttribute("data-status-flag", flag);
      console.log(`[StatusFlag] ${taskId}: Set to ${flag} (in DOM)`);
      return;
    }

    console.warn(`[StatusFlag] ${taskId}: Task not found in state or DOM`);
  }

  /**
   * Reset status flag to default state
   * @param {string} taskId - Task ID (e.g., "1.1")
   */
  resetStatusFlag(taskId) {
    this.setStatusFlag(taskId, "text-manual");
  }

  /**
   * Get task state including status and flag
   * @param {string} taskId - Task ID
   * @returns {Object|null} Task state object or null
   */
  getTaskState(taskId) {
    if (window.checkpointTableState) {
      for (const checkpointId in window.checkpointTableState) {
        const rows = window.checkpointTableState[checkpointId];
        const taskRow = rows.find((row) => row.id === taskId);
        if (taskRow) {
          return taskRow;
        }
      }
    }
    return null;
  }

  /**
   * Update task notes
   * @param {string} taskId - Task ID
   * @param {string} notes - New notes value
   */
  updateTaskNotes(taskId, notes) {
    if (window.checkpointTableState) {
      for (const checkpointId in window.checkpointTableState) {
        const rows = window.checkpointTableState[checkpointId];
        const taskRow = rows.find((row) => row.id === taskId);
        if (taskRow) {
          taskRow.notes = notes;
          return;
        }
      }
    }
  }

  /**
   * Update task status
   * @param {string} taskId - Task ID
   * @param {string} status - New status value
   */
  updateTaskStatus(taskId, status) {
    if (window.checkpointTableState) {
      for (const checkpointId in window.checkpointTableState) {
        const rows = window.checkpointTableState[checkpointId];
        const taskRow = rows.find((row) => row.id === taskId);
        if (taskRow) {
          taskRow.status = status;
          return;
        }
      }
    }
  }

  createCheckpointRowData({
    checkpointId,
    task = "",
    notes = "",
    status = "ready",
    isManual = true,
    id = null,
    statusFlag = "text-manual",
  }) {
    let rowId;

    if (id) {
      // Use provided ID (for restoration)
      rowId = id;
    } else {
      // Generate new ID (for new rows)
      // Count only manual rows in the state to avoid conflicts
      const existingManualRows =
        window.checkpointTableState && window.checkpointTableState[checkpointId]
          ? window.checkpointTableState[checkpointId].filter(
              (row) => row.isManual
            )
          : [];

      // Count existing DOM rows to get the next sequential number
      const existingRows = document.querySelectorAll(
        `#${checkpointId} .checkpoints-table tbody tr`
      );
      const nextRowNumber = existingRows.length + 1;
      rowId = `${checkpointId.split("-")[1]}.${nextRowNumber}`;
    }

    return {
      id: rowId,
      checkpointId: checkpointId,
      task: task,
      notes: notes,
      status: status,
      statusFlag: statusFlag, // NEW: Track status change origin (manual vs automatic)
      isManual: isManual,
      infoLink: "", // No info link for user-added rows
    };
  }

  addCheckpointRow(rowData, saveImmediately = true) {
    console.log("StateManager: Adding checkpoint row:", rowData);

    // Validate required global dependencies
    if (!window.checkpointTableState) {
      console.error("StateManager: checkpointTableState not available");
      return;
    }

    if (typeof window.createTableRow !== "function") {
      console.error("StateManager: createTableRow function not available");
      return;
    }

    // Add to state
    if (!window.checkpointTableState[rowData.checkpointId]) {
      window.checkpointTableState[rowData.checkpointId] = [];
    }
    window.checkpointTableState[rowData.checkpointId].push(rowData);
    console.log(
      "StateManager: Added to checkpointTableState, total rows:",
      window.checkpointTableState[rowData.checkpointId].length
    );

    // Render the new row
    this.renderSingleCheckpointRow(rowData);

    // Save if requested
    if (saveImmediately) {
      this.saveState("manual").catch((error) => {
        console.error("Error saving state after adding row:", error);
      });
    }

    console.log("StateManager: Checkpoint row added successfully");
  }

  renderSingleCheckpointRow(rowData) {
    const checkpointId = rowData.checkpointId;
    const currentTable = document.querySelector(
      `#${checkpointId} .checkpoints-table tbody`
    );

    if (!currentTable) {
      console.error(`Table not found for ${checkpointId}`);
      return;
    }

    // Double-check if row already exists to prevent duplicates
    const existingRow = document.querySelector(`tr[data-id="${rowData.id}"]`);
    if (existingRow) {
      console.log(`Row ${rowData.id} already exists in DOM, skipping render`);
      return;
    }

    if (typeof window.createTableRow === "function") {
      const newRowElement = window.createTableRow(rowData, "checkpoint");
      currentTable.appendChild(newRowElement);

      // Apply the saved status state after rendering
      if (rowData.status === "done") {
        this.applyCompletedStateToRow(newRowElement);
      }

      console.log(
        `Checkpoint row rendered: ${rowData.id} with status: ${rowData.status}`
      );
    } else {
      console.error("createTableRow function not available");
    }
  }

  /**
   * Apply completed state to a restored row (for manual rows)
   */
  applyCompletedStateToRow(rowElement) {
    const statusButton = rowElement.querySelector(".status-button");
    const restartButton = rowElement.querySelector(".restart-button");

    if (!statusButton) {
      console.error("Status button not found in row");
      return;
    }

    // Update status button to done state
    statusButton.setAttribute("data-state", "done");
    statusButton.setAttribute("aria-label", "Task status: Done");
    const completedImgPath = window.getImagePath("done-1.svg");
    const statusImg = statusButton.querySelector("img");
    if (statusImg) {
      statusImg.src = completedImgPath;
    }

    // Show restart button
    if (restartButton) {
      restartButton.classList.remove("restart-hidden");
      restartButton.classList.add("restart-visible");
      restartButton.disabled = false;
    }

    // Apply completed state to textareas WITHOUT creating overlays (restore scenario)
    this.applyCompletedTextareaStateForRestore(rowElement);

    console.log(
      `Applied completed state to row: ${rowElement.getAttribute("data-id")}`
    );
  }

  /**
   * Apply completed state to textareas during restore (without creating overlays)
   */
  applyCompletedTextareaStateForRestore(rowElement) {
    // Handle Notes textarea
    const notesTextarea = rowElement.querySelector(
      '.notes-textarea, textarea[id^="textarea-"]'
    );
    if (notesTextarea) {
      notesTextarea.classList.add("textarea-completed");
      notesTextarea.disabled = true;
      notesTextarea.setAttribute("aria-hidden", "true");
      notesTextarea.setAttribute("tabindex", "-1");
    }

    // Handle Task textarea for manual rows
    const isManualRow = rowElement.classList.contains("manual-row");
    if (isManualRow) {
      const taskTextarea = rowElement.querySelector(".task-input");
      if (taskTextarea) {
        taskTextarea.classList.add("textarea-completed");
        taskTextarea.disabled = true;
        taskTextarea.setAttribute("aria-hidden", "true");
        taskTextarea.setAttribute("tabindex", "-1");
      }
    }
  }

  // ============================================================
  // BEFORE UNLOAD HANDLER
  // ============================================================

  setupBeforeUnloadHandler() {
    window.addEventListener("beforeunload", (event) => {
      if (this.isDirty) {
        // Show browser's native confirmation dialog
        // This is the standard, reliable approach used by Google Docs, GitHub, etc.
        event.preventDefault();
        event.returnValue =
          "You have unsaved changes. Are you sure you want to leave?";
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
        this.saveState("auto")
          .then(() => {
            this.isDirty = false;
            this.lastAutoSaveTime = Date.now();
          })
          .catch((error) => {
            console.error("Auto-save error:", error);
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
    console.log("Manual save verified - auto-save enabled");

    // Setup auto-save listeners after first manual save
    this.setupAutoSaveListeners();
  }

  enableAutoSave() {
    this.autoSaveEnabled = true;
    console.log("Auto-save enabled");

    // Setup auto-save listeners immediately
    this.setupAutoSaveListeners();
  }

  async performInitialSave() {
    try {
      console.log("Performing initial save...");
      const success = await this.saveState("auto");
      if (success) {
        console.log("Initial save completed successfully");
        this.markManualSaveVerified(); // Enable full auto-save functionality
      }
    } catch (error) {
      console.warn("Initial save failed:", error);
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
    document.addEventListener("input", (event) => {
      if (
        event.target.classList.contains("notes-textarea") ||
        event.target.classList.contains("task-input") ||
        event.target.classList.contains("report-task-textarea") ||
        event.target.classList.contains("report-notes-textarea")
      ) {
        this.markDirty();
      }
    });

    document.addEventListener("click", (event) => {
      // Status button changes
      if (
        event.target.closest(".status-button") ||
        event.target.closest(".report-status-button")
      ) {
        this.markDirty();
      }

      // Restart button changes
      if (event.target.closest(".restart-button")) {
        this.markDirty();
      }

      // Side panel navigation
      if (event.target.closest(".side-panel a")) {
        this.markDirty();
      }

      // Side panel toggle
      if (event.target.closest(".toggle-strip")) {
        this.markDirty();
      }
    });

    console.log("Auto-save listeners setup complete");
  }

  setupUnsavedChangesProtection() {
    window.addEventListener("beforeunload", (event) => {
      if (this.isDirty) {
        event.preventDefault();
        event.returnValue =
          "You have unsaved changes. Are you sure you want to leave?";
        return event.returnValue;
      }
    });
  }

  // ============================================================
  // SAVE BUTTON UI
  // ============================================================

  initializeSaveButton() {
    const saveButton = document.getElementById("saveButton");

    if (saveButton && !this.saveButton) {
      this.saveButton = saveButton;
      this.setupSaveButtonEventListeners();
      console.log("Save button initialized");
    } else if (!saveButton) {
      console.error("Save button not found in HTML");
    }
  }

  setupSaveButtonEventListeners() {
    if (!this.saveButton) return;

    this.saveButton.addEventListener("click", async (event) => {
      event.preventDefault();

      try {
        this.saveButton.setAttribute("aria-busy", "true");
        this.saveButton.disabled = true;

        this.announceSaveAction("Saving checklist...");

        const success = await this.saveState("manual");

        if (success) {
          this.announceSaveAction("Checklist saved successfully");

          // Update buffer after save (content may have changed)
          if (typeof window.scheduleBufferUpdate === "function") {
            window.scheduleBufferUpdate();
          }

          // Keep focus for 3 seconds while success message shows
          setTimeout(() => {
            if (this.saveButton) {
              this.saveButton.blur(); // Release focus when message disappears
            }
          }, 3000);
        } else {
          this.announceSaveAction("Error saving checklist");
        }
      } catch (error) {
        console.error("Save error:", error);
        this.announceSaveAction("Error saving checklist");
      } finally {
        this.saveButton.removeAttribute("aria-busy");
        this.saveButton.disabled = false;
        this.saveButton.focus(); // Keep focus while success message shows
      }
    });
  }

  announceSaveAction(message) {
    let statusElement = document.getElementById("save-status");
    if (!statusElement) {
      statusElement = document.createElement("div");
      statusElement.id = "save-status";
      statusElement.setAttribute("role", "status");
      statusElement.setAttribute("aria-live", "polite");
      statusElement.className = "sr-only";
      document.body.appendChild(statusElement);
    }

    statusElement.textContent = message;

    setTimeout(() => {
      if (statusElement) {
        statusElement.textContent = "";
      }
    }, 3000);
  }

  // ============================================================
  // LOADING OVERLAY
  // ============================================================

  showLoading() {
    const loadingOverlay = document.getElementById("loadingOverlay");
    if (loadingOverlay) {
      console.log("Showing loading overlay");
      loadingOverlay.style.display = "flex";
    } else {
      console.log("Loading overlay element not found!");
    }
  }

  hideLoading() {
    const loadingOverlay = document.getElementById("loadingOverlay");
    if (loadingOverlay) {
      console.log("Hiding loading overlay");
      loadingOverlay.style.display = "none";
    }
  }

  // ============================================================
  // STATUS MESSAGES
  // ============================================================

  showStatusMessage(message, type = "info") {
    if (
      window.statusManager &&
      typeof window.statusManager.showMessage === "function"
    ) {
      window.statusManager.showMessage(message, type);
    } else {
      console.log(`[${type.toUpperCase()}] ${message}`);
    }
  }
}

// Global instance
window.unifiedStateManager = new UnifiedStateManager();

// Auto-initialize when DOM is ready
if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", () => {
    window.unifiedStateManager.initialize();
  });
} else {
  window.unifiedStateManager.initialize();
}

// Export global convenience functions for backward compatibility
window.saveChecklistState = () =>
  window.unifiedStateManager.saveState("manual").catch((error) => {
    console.error("Error in global save function:", error);
  });
window.restoreChecklistState = () => window.unifiedStateManager.restoreState();
window.markChecklistDirty = () => window.unifiedStateManager.markDirty();
window.hideLoading = () => window.unifiedStateManager.hideLoading();
window.clearChecklistDirty = () => window.unifiedStateManager.clearDirty();

export { UnifiedStateManager };
