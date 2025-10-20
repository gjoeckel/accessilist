<?php
require_once __DIR__ . '/includes/config.php';
require_once __DIR__ . '/includes/html-head.php';
require_once __DIR__ . '/includes/footer.php';
require_once __DIR__ . '/includes/common-scripts.php';
require_once __DIR__ . '/includes/security-headers.php';
require_once __DIR__ . '/includes/csrf.php';

// Set security headers
set_security_headers();

// Generate CSRF token and make it globally available
$GLOBALS['csrfToken'] = generate_csrf_token();

renderHTMLHead('Accessibility Checklist', true);
?>
<body class="checklist-page">
<!-- Loading Overlay -->
<div id="loadingOverlay" role="alert" aria-live="polite">
  <div id="loadingSpinner"></div>
  <div id="loadingText">Loading your checklist...</div>
</div>

<?php require __DIR__ . '/includes/noscript.php'; ?>

<!-- Skip Link -->
<a href="#checkpoint-1-caption" class="skip-link">Skip to checklist</a>

<!-- Immediate Scroll Initialization - Prevents visual stutter -->
<script>
  // Disable scroll restoration
  if ('scrollRestoration' in history) {
    history.scrollRestoration = 'manual';
  }
</script>

<!-- Sticky Header -->
<header class="sticky-header">
    <h1>Accessibility Checklist</h1>
    <button id="homeButton" class="home-button" aria-label="Go to home page">
        <span class="button-text">Home</span>
    </button>
    <div class="header-buttons-group">
        <button id="saveButton" class="save-button header-button" aria-label="Save checklist" type="button">
            <span>Save</span>
        </button>
        <button id="reportButton" class="report-button header-button" aria-label="View report" type="button">
            <span>Report</span>
        </button>
    </div>
</header>

<!-- Side Panel - Checkpoint Navigation -->
<nav class="side-panel" aria-expanded="true">
    <ul>
        <!-- Checkpoint buttons generated dynamically by side-panel.js -->
    </ul>
    <button class="toggle-strip" aria-label="Toggle side panel" aria-expanded="true" title="Toggle navigation panel">
        <span class="toggle-arrow" aria-hidden="true">◀</span>
    </button>
</nav>

<!-- Main Content -->
<main role="main" id="main-content" tabindex="-1" aria-label="Accessibility checklist content">
    <!-- Content will be generated dynamically -->
    <div id="content">
        <section class="checkpoints-container">
            <!-- Checkpoints content will be added here -->
        </section>
    </div>
</main>

<!-- Legacy modal HTML removed - now handled by SimpleModal -->

<!-- Footer -->
<!-- <footer role="contentinfo">
    <p>© 2025 NCADEMI. All rights reserved.</p>
</footer> -->

<?php renderFooter('status'); ?>

<!-- Scripts -->
<script>
  // Handle skip link - focus on first h2 without scrolling
  document.addEventListener('DOMContentLoaded', function() {
    const skipLink = document.querySelector('.skip-link');
    if (skipLink) {
      skipLink.addEventListener('click', function(e) {
        e.preventDefault();
        // Target checkpoint 1 h2 specifically
        const target = document.getElementById('checkpoint-1-caption');
        if (target) {
          target.focus();
        }
      });
    }
  });
</script>
<?php renderCommonScripts('checklist'); ?>
<script>
  // Make checklist type and session key available to JavaScript (supports minimal URL include)
  window.checklistTypeFromPHP = '<?php echo isset($_GET['type']) ? htmlspecialchars($_GET['type'], ENT_QUOTES, 'UTF-8') : ''; ?>';
  window.sessionKeyFromPHP = '<?php echo isset($_GET['session']) ? htmlspecialchars($_GET['session'], ENT_QUOTES, 'UTF-8') : ''; ?>';
</script>
<script type="module">
  document.addEventListener('DOMContentLoaded', function() {
    try {
      // Initialize UI components
      if (typeof initializeUIComponents === 'function') {
        initializeUIComponents();
      }

      // Setup unified state events after modules are loaded
      setTimeout(() => {
        if (window.unifiedStateManager && window.modalActions && window.stateEvents) {
          window.stateEvents.setupGlobalEvents();
        } else {
          console.error('Missing dependencies for StateEvents initialization:', {
            unifiedStateManager: !!window.unifiedStateManager,
            modalActions: !!window.modalActions,
            stateEvents: !!window.stateEvents
          });
        }
      }, 100);

      // Initialize the app - now handled by unified StateManager
      if (typeof window.initializeApp === 'function') {
        window.initializeApp();
      }

      // Home button handler
      const homeButton = document.getElementById('homeButton');
      if (homeButton) {
        homeButton.addEventListener('click', function() {
          const target = window.getCleanPath ? window.getCleanPath('home') : '/home';
          window.location.href = target;
        });
      }

      // Report button handler - auto-save before opening list report
      const reportButton = document.getElementById('reportButton');
      if (reportButton) {
        reportButton.addEventListener('click', async function(event) {
          event.preventDefault(); // Prevent immediate navigation

          // Auto-save if there are unsaved changes
          if (window.unifiedStateManager?.isDirty) {
            try {
              await window.unifiedStateManager.saveState('manual');
            } catch (error) {
              console.error('Auto-save failed:', error);
              // Continue anyway - user can save later
            }
          }

          // Navigate to report
          const sessionKey = window.sessionKeyFromPHP || window.unifiedStateManager?.sessionKey;
          if (sessionKey) {
            const reportUrl = window.basePath
              ? `${window.basePath}/list-report?session=${sessionKey}`
              : `/list-report?session=${sessionKey}`;
            window.location.href = reportUrl;
          } else {
            console.error('Session key not available for report');
          }
        });
      }

    } catch (error) {
      console.error('Error during initialization:', error);
      const loadingText = document.getElementById('loadingText');
      if (loadingText) {
        loadingText.textContent = 'Error loading checklist. Please try again.';
      }
    }
  });
</script>

</body>
</html>
