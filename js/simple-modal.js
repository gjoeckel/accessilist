/**
 * Simple Modal System - SRD Optimized
 *
 * RESPONSIBILITY: Minimal, reliable modal dialogs
 * - WCAG 2.1 AA compliant focus management
 * - Focus trapping with Tab/Shift+Tab
 * - Focus set to ACTION button (not cancel/close)
 * - No race conditions or complex timing
 * - Single file, minimal dependencies
 */

class SimpleModal {
  constructor() {
    this.modal = null;
    this.previousFocus = null;
    this.escapeHandler = null;
    this.focusTrapHandler = null;
    this.isOpen = false;

    // Create modal HTML once
    this.createModalHTML();
  }

  createModalHTML() {
    const modalHTML = `
      <div id="simpleModal" class="simple-modal" style="display: none;" role="dialog" aria-modal="true" aria-labelledby="modalTitle" aria-hidden="true">
        <div class="modal-content">
          <h2 id="modalTitle">Modal Title</h2>
          <p id="modalMessage">Modal message</p>
          <div class="modal-buttons">
            <button id="modalConfirm" class="btn btn-primary">Confirm</button>
            <button id="modalCancel" class="btn btn-secondary">Cancel</button>
          </div>
        </div>
      </div>
    `;

    document.body.insertAdjacentHTML("beforeend", modalHTML);
    this.modal = document.getElementById("simpleModal");
  }

  show(
    title,
    message,
    onConfirm,
    onCancel,
    confirmText = "Confirm",
    cancelText = "Cancel",
    isDestructive = false
  ) {
    if (this.isOpen) return; // Prevent multiple modals

    this.isOpen = true;
    this.previousFocus = document.activeElement;

    // Prevent body scroll when modal is open
    document.body.classList.add("modal-open");

    // Update modal content
    document.getElementById("modalTitle").textContent = title;
    document.getElementById("modalMessage").innerHTML = message;

    const confirmBtn = document.getElementById("modalConfirm");
    const cancelBtn = document.getElementById("modalCancel");

    confirmBtn.textContent = confirmText;
    cancelBtn.textContent = cancelText;

    // Set button styling based on action type
    if (isDestructive) {
      confirmBtn.className = "btn btn-danger";
    } else {
      confirmBtn.className = "btn btn-primary";
    }

    // Show modal
    this.modal.style.display = "flex";
    this.modal.setAttribute("aria-hidden", "false");

    // CRITICAL: Focus ACTION button immediately (WCAG requirement)
    confirmBtn.focus();

    // Setup event handlers
    confirmBtn.onclick = () => {
      this.hide();
      if (onConfirm) onConfirm();
    };

    cancelBtn.onclick = () => {
      this.hide();
      if (onCancel) onCancel();
    };

    // Escape key handler
    this.escapeHandler = (e) => {
      if (e.key === "Escape") {
        this.hide();
        if (onCancel) onCancel();
      }
    };
    document.addEventListener("keydown", this.escapeHandler);

    // Focus trap for WCAG compliance
    this.setupFocusTrap();
  }

  setupFocusTrap() {
    const focusableElements = this.modal.querySelectorAll(
      'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
    );

    if (focusableElements.length === 0) return;

    const firstElement = focusableElements[0];
    const lastElement = focusableElements[focusableElements.length - 1];

    this.focusTrapHandler = (e) => {
      if (e.key === "Tab") {
        if (e.shiftKey) {
          // Shift + Tab
          if (document.activeElement === firstElement) {
            e.preventDefault();
            lastElement.focus();
          }
        } else {
          // Tab
          if (document.activeElement === lastElement) {
            e.preventDefault();
            firstElement.focus();
          }
        }
      }
    };

    this.modal.addEventListener("keydown", this.focusTrapHandler);
  }

  hide() {
    if (!this.isOpen) return;

    this.isOpen = false;
    this.modal.style.display = "none";
    this.modal.setAttribute("aria-hidden", "true");

    // Restore body scroll when modal is closed
    document.body.classList.remove("modal-open");

    // Clean up event handlers
    if (this.escapeHandler) {
      document.removeEventListener("keydown", this.escapeHandler);
      this.escapeHandler = null;
    }

    if (this.focusTrapHandler) {
      this.modal.removeEventListener("keydown", this.focusTrapHandler);
      this.focusTrapHandler = null;
    }

    // Focus management will be handled by the callback functions
    // No automatic focus restoration here
    this.previousFocus = null;
  }

  // Convenience methods for different modal types
  confirm(title, message, onConfirm, onCancel) {
    this.show(title, message, onConfirm, onCancel, "Confirm", "Cancel");
  }

  reset(title, message, onConfirm, onCancel) {
    // Make "Ready" bold in the message
    const formattedMessage = message.replace(
      /\bReady\b/g,
      "<strong>Ready</strong>"
    );
    this.show(
      title,
      formattedMessage,
      onConfirm,
      onCancel,
      "Reset",
      "Cancel",
      true
    );
  }

  delete(title, message, onConfirm, onCancel) {
    // Make key value bold in the message (assumes format like "Do you want to delete "KEY"?")
    const formattedMessage = message.replace(
      /"([^"]+)"/g,
      '"<strong>$1</strong>"'
    );
    this.show(
      title,
      formattedMessage,
      onConfirm,
      onCancel,
      "Delete",
      "Cancel",
      true
    );
  }

  info(title, message, onClose) {
    this.show(title, message, null, onClose, "Close", "");
    // Hide cancel button for info modals
    document.getElementById("modalCancel").style.display = "none";
  }

  error(title, message, onClose) {
    this.show(title, message, null, onClose, "OK", "");
    // Hide cancel button for error modals
    document.getElementById("modalCancel").style.display = "none";
  }
}

// Global instance
window.simpleModal = new SimpleModal();
