<?php
require_once __DIR__ . '/includes/config.php';
require_once __DIR__ . '/includes/html-head.php';
require_once __DIR__ . '/includes/footer.php';

renderHTMLHead('Accessibility Checklists');
?>
<body>
<?php require __DIR__ . '/includes/noscript.php'; ?>

<!-- Skip Link -->
<a href="#checklist-groups" class="skip-link">Skip to checklist selection</a>

<!-- Sticky Header -->
<header class="sticky-header">
    <div class="header-content">
        <h1>Accessibility Checklists</h1>
        <div class="header-buttons-group">
            <button id="reportsButton" class="header-button reports-button">Reports</button>
        </div>
    </div>
</header>

<!-- Main Content -->
<main role="main">
    <div class="landing-content checklist-groups-container" id="checklist-groups" tabindex="-1">
      <div class="checklist-group">
        <h2>Start Here</h2>
        <div class="checklist-buttons-row">
          <button id="demo" class="checklist-button">Demo</button>
        </div>
      </div>
      <div class="checklist-group">
        <h2>Microsoft</h2>
        <div class="checklist-buttons-row">
          <button id="word" class="checklist-button">Word</button>
          <button id="powerpoint" class="checklist-button">PowerPoint</button>
          <button id="excel" class="checklist-button">Excel</button>
        </div>
      </div>
      <div class="checklist-group">
        <h2>Google</h2>
        <div class="checklist-buttons-row">
          <button id="docs" class="checklist-button">Docs</button>
          <button id="slides" class="checklist-button">Slides</button>
        </div>
      </div>
      <div class="checklist-group">
        <h2>Other</h2>
        <div class="checklist-buttons-row">
          <button id="camtasia" class="checklist-button">Camtasia</button>
          <button id="dojo" class="checklist-button">Dojo</button>
        </div>
      </div>
    </div>
</main>

<?php renderFooter('standard'); ?>

<!-- Scripts -->
<script>
  // Prevent browser from restoring scroll position
  if ('scrollRestoration' in history) {
    history.scrollRestoration = 'manual';
  }
  // Reset scroll position immediately
  window.scrollTo(0, 0);

  // Handle skip link - focus without scrolling
  document.addEventListener('DOMContentLoaded', function() {
    const skipLink = document.querySelector('.skip-link');
    if (skipLink) {
      skipLink.addEventListener('click', function(e) {
        e.preventDefault();
        const targetId = this.getAttribute('href').substring(1);
        const target = document.getElementById(targetId);
        if (target) {
          target.focus();
        }
      });
    }
  });
</script>
<script type="module" src="<?php echo $basePath; ?>/js/path-utils.js?v=<?php echo time(); ?>"></script>
<script src="<?php echo $basePath; ?>/js/type-manager.js?v=<?php echo time(); ?>"></script>
<script>
  document.addEventListener('DOMContentLoaded', function() {


    // Connect buttons to redirect to php/mychecklist.php
    const buttons = document.querySelectorAll('.checklist-button');
    buttons.forEach(button => {
      button.addEventListener('click', async function() {
        const checklistType = this.id;
        // Generate a 3-character session ID using numbers and capital letters
        const sessionId = generateAlphanumericSessionId();

        // Create session and redirect to minimal URL
        // STRICT MODE: Use path helper (handles environment-specific API extension)
        const apiPath = window.getAPIPath('instantiate');
        const response = await fetch(apiPath, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            sessionKey: sessionId,
            typeSlug: checklistType
          })
        });

        if (!response.ok) {
          console.error('Failed to create session:', await response.text());
          alert('Failed to create checklist session. Please try again.');
          return;
        }

        // Redirect to minimal URL format (?=ABC)
        window.location.href = `<?php echo $basePath; ?>/?=${sessionId}`;
      });
    });

    // Show initial message in footer
    const statusContent = document.querySelector('.status-content');
    if (statusContent) {
      statusContent.textContent = 'Select a checklist type';
    }

    // Connect Reports button to redirect to systemwide report
    const reportsButton = document.getElementById('reportsButton');
    if (reportsButton) {
      reportsButton.addEventListener('click', function() {
        window.location.href = '<?php echo $basePath; ?>/systemwide-report';
      });
    }

    // Connect Clear Data button
    const clearDataButton = document.getElementById('clearDataButton');
    if (clearDataButton) {
      clearDataButton.addEventListener('click', function() {
        if (confirm('Are you sure you want to clear all stored data? This action cannot be undone.')) {
          localStorage.clear();
          sessionStorage.clear();
          alert('All stored data has been cleared.');
        }
      });
    }

    // Function to generate a 3-character session ID using numbers and capital letters
    function generateAlphanumericSessionId() {
      const characters = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
      let result = '';
      for (let i = 0; i < 3; i++) {
        result += characters.charAt(Math.floor(Math.random() * characters.length));
      }
      return result;
    }
  });
</script>
</body>
</html>
