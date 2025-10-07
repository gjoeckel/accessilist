/**
 * StatusManager.js
 * WCAG 2.1 Compliant Status Message Implementation
 * Requirements:
 * - 4.1.3 Status Messages (Level AA)
 * - 1.4.1 Use of Color (Level A)
 * - 1.3.1 Info and Relationships (Level A)
 * - 2.2.1 Timing Adjustable (Level A)
 */

class StatusManager {
  constructor() {
    if (StatusManager.instance) {
      return StatusManager.instance;
    }
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', () => this.initContainer());
    } else {
      this.initContainer();
    }
    StatusManager.instance = this;
  }

  initContainer() {
    this.container = document.querySelector('.status-footer');
    if (!this.container) {
      console.error('Status footer not found in DOM');
      return;
    }
    let content = this.container.querySelector('.status-content');
    if (!content) {
      content = document.createElement('div');
      content.className = 'status-content';
      this.container.appendChild(content);
    }
    this.contentContainer = content;
  }

  announce(message, options = {}) {
    if (!this.contentContainer) {
      return;
    }
    const { type = 'status', timeout = 2000, isPersistent = false } = options;
    this.contentContainer.textContent = '';
    // Apply type-based styling
    if (this.contentContainer) {
      this.contentContainer.classList.remove('status-success', 'status-error');
      if (type === 'success') this.contentContainer.classList.add('status-success');
      if (type === 'error') this.contentContainer.classList.add('status-error');
    }
    // Support string, Node, or Node[] messages
    if (message instanceof Node) {
      this.contentContainer.appendChild(message);
    } else if (Array.isArray(message)) {
      message.forEach(node => {
        if (node instanceof Node) {
          this.contentContainer.appendChild(node);
        } else if (typeof node === 'string') {
          this.contentContainer.appendChild(document.createTextNode(node));
        }
      });
    } else {
      this.contentContainer.appendChild(document.createTextNode(String(message)));
    }
    if (!isPersistent) {
      setTimeout(() => {
        if (this.contentContainer) this.contentContainer.textContent = '';
      }, timeout);
    }
  }

  // Back-compat shim used by existing code paths
  showMessage(message, type = 'status', timeout = 2000, isPersistent = false) {
    this.announce(message, { type, timeout, isPersistent });
  }
}

window.statusManager = new StatusManager(); 