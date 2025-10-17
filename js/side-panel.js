/**
 * side-panel.js
 *
 * Simple checkpoint navigation side panel
 * - Generates numbered circle buttons (1-10) based on JSON checkpoints
 * - Scrolls checkpoint to top of page
 * - Sets focus on checkpoint h2
 * - Collapses/expands
 */

class SidePanel {
  constructor() {
    this.panel = document.querySelector(".side-panel");
    this.ul = document.querySelector(".side-panel ul");
    this.toggleBtn = document.querySelector(".toggle-strip");
    this.currentCheckpoint = 1;
  }

  /**
   * Initialize side panel with checkpoint data
   */
  init(checklistData) {
    if (!this.panel || !this.ul) {
      console.error("Side panel elements not found");
      return;
    }

    // Find all checkpoints in JSON
    const checkpoints = Object.keys(checklistData)
      .filter((key) => key.startsWith("checkpoint-"))
      .sort((a, b) => {
        const numA = parseInt(a.split("-")[1]);
        const numB = parseInt(b.split("-")[1]);
        return numA - numB;
      });

    // Clear existing buttons
    this.ul.innerHTML = "";

    // Create "All" button first (three lines symbol) - active by default
    const allButton = this.createAllButton();
    this.ul.appendChild(allButton);

    // Create button for each checkpoint (all start selected since all are visible)
    checkpoints.forEach((key) => {
      const num = parseInt(key.split("-")[1]);
      const button = this.createButton(num, key, true); // All buttons start active
      this.ul.appendChild(button);
    });

    // Store checkpoint keys for "All" functionality
    this.checkpointKeys = checkpoints;

    // Setup toggle button
    this.setupToggle();

    // Note: showAllCheckpoints() will be called after content is built
    // This allows sections to exist before we apply .active class
    // Call applyAllCheckpointsActive() from main.js after buildContent()
  }

  /**
   * Apply selected styling to all checkpoints (called after content is built)
   */
  applyAllCheckpointsActive() {
    this.showAllCheckpoints();

    // Set initial scroll position NOW that content exists
    // Buffer is 90px, content naturally at 90px from viewport top
    // Scroll to: 0px (top of page, can't scroll higher)
    window.scrollTo(0, 0);
  }

  /**
   * Create the "All" button (arrow symbol)
   */
  createAllButton() {
    const li = document.createElement("li");

    const btn = document.createElement("button");
    btn.className = "checkpoint-btn checkpoint-all active"; // Active by default (all visible)
    btn.setAttribute("data-checkpoint", "all");
    btn.setAttribute(
      "aria-label",
      "Showing all checkpoints. Click a checkpoint number button to hide all others."
    );
    btn.textContent = ""; // Content comes from CSS ::before

    // Click handler
    btn.addEventListener("click", () => this.showAll(btn));

    li.appendChild(btn);
    return li;
  }

  /**
   * Create a checkpoint button
   */
  createButton(num, checkpointKey, isActive = false) {
    const li = document.createElement("li");

    const btn = document.createElement("button");
    btn.className = `checkpoint-btn${isActive ? " active" : ""}`;
    btn.setAttribute("data-checkpoint", checkpointKey);
    btn.setAttribute("data-number", num);
    btn.setAttribute(
      "aria-label",
      `Click to hide all checkpoints except this one.`
    );
    btn.textContent = num;

    // Click handler - Option B: clicking visible number in focused mode shows all
    btn.addEventListener("click", () => {
      const allBtn = this.ul.querySelector(".checkpoint-all");
      // If this is the only visible checkpoint (we're in single mode), show all
      if (
        btn.classList.contains("active") &&
        allBtn &&
        !allBtn.classList.contains("active")
      ) {
        this.showAll(allBtn);
      } else {
        this.goToCheckpoint(checkpointKey, btn, num);
      }
    });

    li.appendChild(btn);
    return li;
  }

  /**
   * Show all checkpoints (All button or single checkpoint clicked when in focused mode)
   */
  showAll(clickedBtn) {
    // Update All button to active (down arrow, non-interactive)
    const allBtn = this.ul.querySelector(".checkpoint-all");
    if (allBtn) {
      allBtn.classList.add("active");
      allBtn.setAttribute(
        "aria-label",
        "Showing all checkpoints. Click a checkpoint number button to hide all others."
      );
    }

    // Set all checkpoint numbers to selected mode (all visible)
    this.ul
      .querySelectorAll(".checkpoint-btn:not(.checkpoint-all)")
      .forEach((btn) => {
        btn.classList.add("active");
        btn.setAttribute(
          "aria-label",
          "Click to hide all checkpoints except this one."
        );
      });

    // Show all checkpoint sections and apply selected styling
    this.showAllCheckpoints();

    // Scroll to top of page
    window.scrollTo({
      top: 0,
      behavior: "auto", // Instant scroll - no animation
    });
  }

  /**
   * Show all checkpoints with selected styling
   */
  showAllCheckpoints() {
    document.querySelectorAll(".checkpoint-section").forEach((section) => {
      section.style.display = "block"; // Make visible
      section.classList.add("active"); // Apply selected styling (brown h2 circles, brown add-row buttons)
    });
  }

  /**
   * Navigate to specific checkpoint (hide others)
   */
  goToCheckpoint(checkpointKey, clickedBtn, num) {
    // Find the checkpoint section
    const section = document.querySelector(`section.${checkpointKey}`);
    if (!section) {
      console.error(`Section ${checkpointKey} not found`);
      return;
    }

    // Update All button to right arrow (interactive)
    const allBtn = this.ul.querySelector(".checkpoint-all");
    if (allBtn) {
      allBtn.classList.remove("active");
      allBtn.setAttribute(
        "aria-label",
        `Only checkpoint ${num} visible. Click to show all checkpoints.`
      );
    }

    // Set clicked button to selected, others to default mode (all remain visible)
    this.ul
      .querySelectorAll(".checkpoint-btn:not(.checkpoint-all)")
      .forEach((btn) => {
        if (btn === clickedBtn) {
          btn.classList.add("active");
          btn.setAttribute("aria-label", "Click to show all checkpoints.");
        } else {
          btn.classList.remove("active");
          btn.setAttribute(
            "aria-label",
            "Click to hide all checkpoints except this one."
          );
        }
      });

    // Hide all sections, then show only the selected one with active styling
    document.querySelectorAll(".checkpoint-section").forEach((sec) => {
      sec.classList.remove("active");
      sec.style.display = "none"; // Hide all
    });
    section.classList.add("active"); // Apply selected styling
    section.style.display = "block"; // Show only selected

    // Scroll to position section 90px from top of viewport
    // Buffer is always 90px, so offsetTop is relative to that
    // Subtract 90 to account for header
    const targetScroll = section.offsetTop - 90;

    window.scrollTo({
      top: targetScroll,
      behavior: "auto", // Instant scroll - no animation
    });

    // Focus on checkpoint h2
    // Use preventScroll to avoid any scroll adjustment
    const heading = section.querySelector("h2");
    if (heading) {
      heading.focus({ preventScroll: true });
    }
  }

  /**
   * Setup toggle button for collapse/expand
   * Note: Mouse clicks are handled by StateEvents.js global delegation
   * This method only adds keyboard support (Enter/Space keys)
   */
  setupToggle() {
    if (!this.toggleBtn) return;

    // Toggle function for keyboard events only
    // (Mouse clicks handled by StateEvents.js)
    const togglePanel = () => {
      const isExpanded = this.panel.getAttribute("aria-expanded") === "true";
      const newState = !isExpanded;

      this.panel.setAttribute("aria-expanded", newState.toString());
      this.toggleBtn.setAttribute("aria-expanded", newState.toString());

      // Mark dirty for auto-save (same as StateEvents does for clicks)
      if (window.unifiedStateManager) {
        window.unifiedStateManager.markDirty();
      }
    };

    // Keyboard support only (Enter and Space keys)
    // Mouse clicks are handled by StateEvents.js
    this.toggleBtn.addEventListener("keydown", (event) => {
      if (event.key === "Enter" || event.key === " ") {
        event.preventDefault(); // Prevent space from scrolling page
        togglePanel();
      }
    });
  }
}

// Initialize when page loads
window.SidePanel = SidePanel;
