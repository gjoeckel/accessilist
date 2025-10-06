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
    // Wait for DOM to be ready
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
    // Create the content container if it doesn't exist
    let content = this.container.querySelector('.status-content');
    if (!content) {
      content = document.createElement('div');
      content.className = 'status-content';
      this.container.appendChild(content);
    }
    this.contentContainer = content;
    console.log('Status manager initialized with container:', this.container);
  }

  announce(message, options = {}) {
    console.log('Announcing message:', message, 'with options:', options);
    if (!this.contentContainer) {
      console.error('Cannot announce - container not found');
      return;
    }
    
    const {
      type = 'status',
      timeout = 2000,
      isPersistent = false
    } = options;

    // Clear any existing content
    this.contentContainer.textContent = '';
    console.log('Cleared existing content');
    
    // Add icon based on type if needed
    if (type === 'error' || type === 'success') {
      const icon = document.createElement('img');
      const filename = (type === 'error') ? 'error.svg' : 'completed.svg';
      icon.src = window.getImagePath(filename);
      icon.alt = '';  // Decorative only, message is already in text
      icon.setAttribute('aria-hidden', 'true');
      this.contentContainer.appendChild(icon);
      console.log('Added icon for type:', type);
    }

    // Add message
    this.contentContainer.appendChild(document.createTextNode(message));
    console.log('Added message text');

    // Clear after timeout if not persistent
    if (!isPersistent) {
      setTimeout(() => {
        this.contentContainer.textContent = '';
        console.log('Cleared message after timeout');
      }, timeout);
    }
  }
}

// Export singleton instance
window.statusManager = new StatusManager(); 