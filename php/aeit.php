<?php
require_once __DIR__ . '/includes/config.php';
require_once __DIR__ . '/includes/html-head.php';
require_once __DIR__ . '/includes/footer.php';

// Get session key from URL parameter
$sessionKey = $_GET['session'] ?? '';

renderHTMLHead('Accessibility Evaluation and Implementation Tools');
?>
<link rel="stylesheet" href="<?php echo $basePath; ?>/css/aeit.css?v=<?php echo time(); ?>">
<body>
<?php require __DIR__ . '/includes/noscript.php'; ?>

<!-- Skip Link -->
<a href="#main-content" class="skip-link">Skip to main content</a>

<!-- Sticky Header -->
<header class="sticky-header">
    <h1>Accessibility Evaluation and Implementation Tools</h1>
    <?php if (!empty($sessionKey)): ?>
    <button id="backButton" class="back-button" aria-label="Back to checklist">
        <span class="button-text">Back</span>
    </button>
    <?php endif; ?>
</header>

<!-- Main Content -->
<main role="main" id="main-content">
    <div class="landing-content">
        <p>Content for this checklist was adapted from the Accessibility Evaluation and Implementation Tools (AEIT)&mdash;a set of checklists with detailed innstructions for meeting WCAG requirements in popular content authoring software. These resources were developed at the University of Tennessee, Knoxville by:</p>
        <ul>
            <li>Eric J Moore, PhD</li>
            <li>Esther Durrant</li>
            <li>Erin Garty, PhD</li>
        </ul>
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

  // Handle skip link
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

    // Connect Back button (if present)
    const backButton = document.getElementById('backButton');
    if (backButton) {
      backButton.addEventListener('click', function() {
        const sessionKey = '<?php echo htmlspecialchars($sessionKey, ENT_QUOTES, 'UTF-8'); ?>';
        const basePath = window.basePath || '<?php echo $basePath; ?>';
        window.location.href = `${basePath}/?=${sessionKey}`;
      });
    }
  });
</script>
<script type="module" src="<?php echo $basePath; ?>/js/path-utils.js?v=<?php echo time(); ?>"></script>
</body>
</html>
