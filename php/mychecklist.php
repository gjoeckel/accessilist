<?php
require_once __DIR__ . '/includes/config.php';
require_once __DIR__ . '/includes/html-head.php';
require_once __DIR__ . '/includes/footer.php';
require_once __DIR__ . '/includes/common-scripts.php';

renderHTMLHead('Accessibility Checklist', true);
?>
<body>
<!-- Loading Overlay -->
<div id="loadingOverlay" role="alert" aria-live="polite">
  <div id="loadingSpinner"></div>
  <div id="loadingText">Loading your checklist...</div>
</div>

<?php require __DIR__ . '/includes/noscript.php'; ?>

<!-- Sticky Header -->
<header class="sticky-header">
    <h1>Accessibility Checklist</h1>
    <div class="header-buttons">
        <button id="saveButton" class="save-button" aria-label="Save checklist" type="button">
            <span>Save</span>
        </button>
    </div>
</header>

<!-- Side Panel -->
<nav class="side-panel" aria-expanded="true">
    <ul id="side-panel">
        <li>
            <a href="javascript:void(0)" data-target="checklist-1" class="infocus" aria-label="Checklist 1" title="View Checkpoint 1">
                <img src="<?php echo $basePath; ?>/images/number-1-1.svg" alt="Checkpoint 1 table" class="active-state" width="36" height="36">
                <img src="<?php echo $basePath; ?>/images/number-1-0.svg" alt="Checkpoint 1 table" class="inactive-state" width="36" height="36">
            </a>
        </li>
        <li>
            <a href="javascript:void(0)" data-target="checklist-2" aria-label="Checklist 2" title="View Checkpoint 2">
                <img src="<?php echo $basePath; ?>/images/number-2-1.svg" alt="Checkpoint 2 table" class="active-state" width="36" height="36">
                <img src="<?php echo $basePath; ?>/images/number-2-0.svg" alt="Checkpoint 2 table" class="inactive-state" width="36" height="36">
            </a>
        </li>
        <li>
            <a href="javascript:void(0)" data-target="checklist-3" aria-label="Checklist 3" title="View Checkpoint 3">
                <img src="<?php echo $basePath; ?>/images/number-3-1.svg" alt="Checkpoint 3 table" class="active-state" width="36" height="36">
                <img src="<?php echo $basePath; ?>/images/number-3-0.svg" alt="Checkpoint 3 table" class="inactive-state" width="36" height="36">
            </a>
        </li>
        <li id="checklist-4-section" style="display: none;" role="region" aria-live="polite" aria-label="Checkpoint 4 table" aria-hidden="true">
            <a href="javascript:void(0)" data-target="checklist-4" aria-label="Checkpoint 4" title="View Checkpoint 4">
                <img src="<?php echo $basePath; ?>/images/number-4-1.svg" alt="Checkpoint 4 table" class="active-state" width="36" height="36">
                <img src="<?php echo $basePath; ?>/images/number-4-0.svg" alt="Checkpoint 4 table" class="inactive-state" width="36" height="36">
            </a>
        </li>
    </ul>
    <button class="toggle-strip" aria-label="Toggle side panel" aria-expanded="true" aria-controls="side-panel" title="Toggle navigation panel">
        <span class="toggle-arrow" aria-hidden="true">◀</span>
    </button>
</nav>

<!-- Main Content -->
<main role="main" aria-label="Accessibility checklist content">
    <!-- Content will be generated dynamically -->
    <div id="content">
        <section class="principles-container">
            <!-- Principles content will be added here -->
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
          console.log('Global event delegation active');
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
