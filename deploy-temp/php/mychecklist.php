<?php
// Determine base path for assets
$isLocal = $_SERVER['HTTP_HOST'] === 'localhost' ||
           $_SERVER['HTTP_HOST'] === '127.0.0.1' ||
           strpos($_SERVER['HTTP_HOST'], 'local') !== false;
$basePath = $isLocal ? '' : '/training/online/accessilist';
?>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<!-- Added viewport meta for responsiveness -->
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Accessibility Checklist</title>
    <link rel="stylesheet" href="<?php echo $basePath; ?>/css/simple-modal.css?v=<?php echo time(); ?>">
<link rel="stylesheet" href="<?php echo $basePath; ?>/css/focus.css?v=<?php echo time(); ?>">
<link rel="stylesheet" href="<?php echo $basePath; ?>/css/landing.css?v=<?php echo time(); ?>">
<link rel="stylesheet" href="<?php echo $basePath; ?>/css/admin.css?v=<?php echo time(); ?>">
<link rel="stylesheet" href="<?php echo $basePath; ?>/css/form-elements.css?v=<?php echo time(); ?>">
<link rel="stylesheet" href="<?php echo $basePath; ?>/css/table.css?v=<?php echo time(); ?>">
<link rel="stylesheet" href="<?php echo $basePath; ?>/css/section.css?v=<?php echo time(); ?>">
<link rel="stylesheet" href="<?php echo $basePath; ?>/css/status.css?v=<?php echo time(); ?>">
<link rel="stylesheet" href="<?php echo $basePath; ?>/css/side-panel.css?v=<?php echo time(); ?>">
<link rel="stylesheet" href="<?php echo $basePath; ?>/css/header.css?v=<?php echo time(); ?>">
<link rel="stylesheet" href="<?php echo $basePath; ?>/css/base.css?v=<?php echo time(); ?>">
<style>
  /* Loading overlay styles */
  #loadingOverlay {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background-color: rgba(255, 255, 255, 0.9);
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    z-index: 9999;
  }

  #loadingSpinner {
    width: 50px;
    height: 50px;
    border: 5px solid #f3f3f3;
    border-top: 5px solid #3498db;
    border-radius: 50%;
    margin-bottom: 20px;
  }

  #loadingText {
    font-size: 18px;
    color: #333;
  }
</style>
</head>
<body>
<!-- Loading Overlay -->
<div id="loadingOverlay" role="alert" aria-live="polite">
  <div id="loadingSpinner"></div>
  <div id="loadingText">Loading your checklist...</div>
</div>

<!-- NoScript fallback to notify users that JavaScript is required -->
<noscript>
<p>This application requires JavaScript to function properly. Please enable JavaScript in your browser settings.</p>
</noscript>

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
            <a href="#checklist-1" class="infocus" aria-label="Checklist 1" title="View Checkpoint 1">
                <img src="<?php echo $basePath; ?>/images/number-1-1.svg" alt="Checkpoint 1 table" class="active-state" width="36" height="36">
                <img src="<?php echo $basePath; ?>/images/number-1-0.svg" alt="Checkpoint 1 table" class="inactive-state" width="36" height="36">
            </a>
        </li>
        <li>
            <a href="#checklist-2" aria-label="Checklist 2" title="View Checkpoint 2">
                <img src="<?php echo $basePath; ?>/images/number-2-1.svg" alt="Checkpoint 2 table" class="active-state" width="36" height="36">
                <img src="<?php echo $basePath; ?>/images/number-2-0.svg" alt="Checkpoint 2 table" class="inactive-state" width="36" height="36">
            </a>
        </li>
        <li>
            <a href="#checklist-3" aria-label="Checklist 3" title="View Checkpoint 3">
                <img src="<?php echo $basePath; ?>/images/number-3-1.svg" alt="Checkpoint 3 table" class="active-state" width="36" height="36">
                <img src="<?php echo $basePath; ?>/images/number-3-0.svg" alt="Checkpoint 3 table" class="inactive-state" width="36" height="36">
            </a>
        </li>
        <li id="checklist-4-section" style="display: none;" role="region" aria-live="polite" aria-label="Checkpoint 4 table" aria-hidden="true">
            <a href="#checklist-4" aria-label="Checkpoint 4" title="View Checkpoint 4">
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

<!-- Status Footer -->
<div class="status-footer" role="contentinfo" aria-live="polite">
    <p class="copyright-text">© 2025 NCADEMI. All rights reserved.</p>
    <div class="status-content"></div>
</div>

<!-- Scripts -->
<!-- Path configuration handled by path-utils.js -->
<script type="module" src="<?php echo $basePath; ?>/js/path-utils.js?v=<?php echo time(); ?>"></script>
<script src="<?php echo $basePath; ?>/js/type-manager.js?v=<?php echo time(); ?>"></script>
<script type="module" src="<?php echo $basePath; ?>/js/StatusManager.js?v=<?php echo time(); ?>"></script>
<script src="<?php echo $basePath; ?>/js/simple-modal.js?v=<?php echo time(); ?>"></script>
<script src="<?php echo $basePath; ?>/js/ModalActions.js?v=<?php echo time(); ?>"></script>
<script type="module" src="<?php echo $basePath; ?>/js/ui-components.js?v=<?php echo time(); ?>"></script>

<!-- Utilities (shared across modules) -->
<script type="module" src="<?php echo $basePath; ?>/js/date-utils.js?v=<?php echo time(); ?>"></script>

<!-- Unified Save/Restore System (NEW - replaces 7 legacy modules) -->
<script type="module" src="<?php echo $basePath; ?>/js/StateManager.js?v=<?php echo time(); ?>"></script>
<script type="module" src="<?php echo $basePath; ?>/js/StateEvents.js?v=<?php echo time(); ?>"></script>

<!-- Main application (refactored to use unified system) -->
<script type="module" src="<?php echo $basePath; ?>/js/main.js?v=<?php echo time(); ?>"></script>
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
        if (window.stateEvents) {
          window.stateEvents.setupGlobalEvents();
          console.log('Global event delegation active');
        } else {
          console.warn('StateEvents not yet available');
        }
      }, 500);

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
