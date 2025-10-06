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
<title>Accessibility Checklists</title>
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
</head>
<body>
<!-- NoScript fallback to notify users that JavaScript is required -->
<noscript>
<p>This application requires JavaScript to function properly. Please enable JavaScript in your browser settings.</p>
</noscript>

<!-- Sticky Header -->
<header class="sticky-header">
    <div class="header-content">
        <h1>Accessibility Checklists</h1>
        <button id="adminButton" class="header-button">Admin</button>
    </div>
</header>

<!-- Main Content -->
<main>
    <div class="landing-content checklist-groups-container">
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

<!-- Footer -->
<footer>
    <p>© 2025 NCADEMI. All rights reserved.</p>
</footer>

<!-- Scripts -->
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

        try {
          // First, create the session with the correct checklist type
          const response = await fetch('api/instantiate.php', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
              sessionKey: sessionId,
              typeSlug: checklistType
            })
          });

          if (response.ok) {
            // Then redirect to minimal URL format (?=EDF)
            window.location.href = `/?=${sessionId}`;
          } else {
            console.error('Failed to create session');
            // Fallback to old method if instantiate fails
            window.location.href = `mychecklist.php?session=${sessionId}&type=${checklistType}`;
          }
        } catch (error) {
          console.error('Error creating session:', error);
          // Fallback to old method if instantiate fails
          window.location.href = `mychecklist.php?session=${sessionId}&type=${checklistType}`;
        }
      });
    });

    // Connect Admin button to redirect to php/admin.php
    const adminButton = document.getElementById('adminButton');
    if (adminButton) {
      adminButton.addEventListener('click', function() {
        window.location.href = 'admin.php';
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
