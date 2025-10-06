// UI Components for AccessiList
// Centralized UI element creation functions

// Generic button creation utility
function createButton(options) {
  const {
    id = null,
    className = '',
    ariaLabel = '',
    text = null,
    icon = null,
    iconAlt = '',
    onClick = null
  } = options;
  
  const button = document.createElement('button');
  
  if (id) button.id = id;
  if (className) button.className = className;
  if (ariaLabel) button.setAttribute('aria-label', ariaLabel);
  
  // Add text content if provided
  if (text) {
    const buttonText = document.createElement('span');
    buttonText.className = 'button-text';
    buttonText.textContent = text;
    button.appendChild(buttonText);
  }
  
  // Add icon if provided
  if (icon) {
    const img = document.createElement('img');
    img.src = window.getImagePath ? window.getImagePath(icon) : icon;
    img.alt = iconAlt;
    button.appendChild(img);
  }
  
  // Add click handler if provided
  if (onClick) {
    button.addEventListener('click', onClick);
  }
  
  return button;
}

// Generic API call utility
async function apiCall(url, options = {}) {
  const {
    method = 'GET',
    headers = {},
    body = null,
    timeout = 10000
  } = options;
  
  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), timeout);
  
  try {
    const response = await fetch(url, {
      method,
      headers: {
        'Content-Type': 'application/json',
        ...headers
      },
      body: body ? JSON.stringify(body) : null,
      signal: controller.signal
    });
    
    clearTimeout(timeoutId);
    
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`);
    }
    
    const contentType = response.headers.get('content-type');
    if (contentType && contentType.includes('application/json')) {
      return await response.json();
    } else {
      return await response.text();
    }
  } catch (error) {
    clearTimeout(timeoutId);
    if (error.name === 'AbortError') {
      throw new Error('Request timeout');
    }
    throw error;
  }
}

// Create home button
function createHomeButton() {
  return createButton({
    id: 'homeButton',
    className: 'home-button',
    ariaLabel: 'Go to home page',
    text: 'Home',
    onClick: function() {
      var target = (window.getPHPPath && typeof window.getPHPPath === 'function')
        ? window.getPHPPath('home.php')
        : '/php/home.php';
      window.location.href = target;
    }
  });
}

// Create clear data button
function createClearDataButton() {
  return createButton({
    id: 'clearDataButton',
    className: 'clear-data-button',
    ariaLabel: 'Clear all stored data',
    text: 'Clear Data',
    onClick: function() {
      if (confirm('Are you sure you want to clear all stored data? This action cannot be undone.')) {
        localStorage.clear();
        sessionStorage.clear();
        alert('All stored data has been cleared.');
      }
    }
  });
}

// Add UI components to page
function addUIComponents() {
  const header = document.querySelector('header');
  if (header) {
    const headerButtons = document.querySelector('.header-buttons');
    if (headerButtons) {
      const homeButton = createHomeButton();
      headerButtons.appendChild(homeButton);
    }
  }
  
  const main = document.querySelector('main');
  if (main) {
    // Add clear data button to landing page
    if (document.querySelector('.landing-content')) {
      const clearDataButton = createClearDataButton();
      const landingContent = document.querySelector('.landing-content');
      landingContent.appendChild(clearDataButton);
    }
  }
}

// Initialize UI components
function initializeUIComponents() {
  addUIComponents();
}

// Export functions
window.initializeUIComponents = initializeUIComponents; 