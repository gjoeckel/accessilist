<?php
require_once __DIR__ . '/includes/config.php';
require_once __DIR__ . '/includes/html-head.php';
require_once __DIR__ . '/includes/footer.php';
require_once __DIR__ . '/includes/common-scripts.php';

renderHTMLHead('Systemwide Reports');
?>
<link rel="stylesheet" href="<?php echo $basePath; ?>/css/reports.css?v=<?php echo time(); ?>">
<body>
<?php require __DIR__ . '/includes/noscript.php'; ?>

<!-- Skip Link -->
<a href="#reports-caption" class="skip-link">Skip to reports table</a>

<!-- Sticky Header -->
<header class="sticky-header">
    <h1>Systemwide Reports</h1>
    <button id="homeButton" class="home-button" aria-label="Go to home page">
        <span class="button-text">Home</span>
    </button>
    <div class="header-buttons-group">
        <button id="refreshButton" class="header-button" aria-label="Refresh reports data">
            <span class="button-text">Refresh</span>
        </button>
    </div>
</header>

<!-- Main Content -->
<main role="main">
    <section id="reports" class="admin-section">
        <!-- Filter Buttons -->
        <div class="filter-group" role="group" aria-label="Filter checklists by status">
            <button
                id="filter-completed"
                class="filter-button"
                data-filter="completed"
                aria-pressed="false"
                aria-label="Show completed checklists">
                <span class="filter-label">Completed</span>
                <span class="filter-count" id="count-completed">0</span>
            </button>
            <button
                id="filter-in-progress"
                class="filter-button"
                data-filter="in-progress"
                aria-pressed="false"
                aria-label="Show in progress checklists">
                <span class="filter-label">In Progress</span>
                <span class="filter-count" id="count-in-progress">0</span>
            </button>
            <button
                id="filter-pending"
                class="filter-button"
                data-filter="pending"
                aria-pressed="false"
                aria-label="Show checklists where all tasks are pending">
                <span class="filter-label">All Pending</span>
                <span class="filter-count" id="count-pending">0</span>
            </button>
            <button
                id="filter-all"
                class="filter-button active"
                data-filter="all"
                aria-pressed="true"
                aria-label="Show all checklists">
                <span class="filter-label">All</span>
                <span class="filter-count" id="count-all">0</span>
            </button>
        </div>

        <!-- Last Update Timestamp -->
        <h2 id="reports-caption" tabindex="-1">Last update: <span id="last-update-time" aria-live="polite" aria-atomic="true">Loading...</span></h2>

        <!-- Table Container -->
        <div class="admin-container">
            <table class="admin-table reports-table" aria-labelledby="reports-caption">
                <thead>
                    <tr>
                        <th class="admin-type-cell">Type</th>
                        <th class="admin-date-cell">Updated</th>
                        <th class="admin-instance-cell">Key</th>
                        <th class="reports-status-cell">Status</th>
                        <th class="reports-progress-cell">Progress</th>
                        <th class="reports-delete-cell">Delete</th>
                    </tr>
                </thead>
                <tbody>
                    <!-- Will be populated dynamically -->
                </tbody>
            </table>
        </div>
    </section>
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
<?php
// FIXED: Changed from 'reports' to 'admin' since common-scripts.php doesn't have 'reports' case
// Admin includes: path-utils, type-manager, ui-components, simple-modal, ModalActions
renderCommonScripts('admin');
?>

<!-- Date utilities (shared) -->
<script type="module" src="<?php echo $basePath; ?>/js/date-utils.js?v=<?php echo time(); ?>"></script>

<!-- Reports functionality -->
<script type="module">
import { ReportsManager } from '<?php echo $basePath; ?>/js/reports.js?v=<?php echo time(); ?>';

// Initialize reports manager
let reportsManager;

document.addEventListener('DOMContentLoaded', function() {

    console.log('Initializing reports page');

    // Update timestamp on page load
    updateTimestamp();

    // Create reports manager instance
    reportsManager = new ReportsManager();
    reportsManager.initialize();

    // Set up Home button
    const homeButton = document.getElementById('homeButton');
    if (homeButton) {
        homeButton.addEventListener('click', function() {
            const target = window.getPHPPath
                ? window.getPHPPath('home.php')
                : '/php/home.php';
            window.location.href = target;
        });
    }

    // Set up Refresh button
    const refreshButton = document.getElementById('refreshButton');
    if (refreshButton) {
        refreshButton.addEventListener('click', function() {
            refreshData();
        });
    }
});

function updateTimestamp() {
    const timestampElement = document.getElementById('last-update-time');
    if (timestampElement) {
        const now = Date.now();
        const formatted = window.formatDateAdmin
            ? window.formatDateAdmin(now)
            : new Date(now).toLocaleString();
        timestampElement.textContent = formatted;
    }
}

function refreshData() {
    const refreshButton = document.getElementById('refreshButton');
    const statusContent = document.querySelector('.status-content');
    if (!refreshButton) return;

    // Indicate refresh in progress
    refreshButton.setAttribute('aria-busy', 'true');
    refreshButton.disabled = true;

    if (statusContent) {
        statusContent.textContent = 'Refreshing reports...';
        statusContent.classList.remove('status-success', 'status-error');
    }

    // Reload the data
    if (reportsManager) {
        reportsManager.loadChecklists().then(() => {
            // Update timestamp after successful refresh
            updateTimestamp();

            // After refresh completes
            refreshButton.setAttribute('aria-busy', 'false');
            refreshButton.disabled = false;

            // Announce completion to screen readers
            if (statusContent) {
                statusContent.textContent = 'Reports refreshed successfully';
                statusContent.classList.add('status-success');
                setTimeout(() => {
                    statusContent.textContent = '';
                    statusContent.classList.remove('status-success');
                }, 5000);
            }
        }).catch(error => {
            console.error('Error refreshing data:', error);
            refreshButton.setAttribute('aria-busy', 'false');
            refreshButton.disabled = false;

            if (window.simpleModal) {
                window.simpleModal.error(
                    'Refresh Failed',
                    'Failed to refresh reports data. Please try again.',
                    () => {
                        refreshButton.focus();
                    }
                );
            }
        });
    }
}
</script>

<!-- Status Footer -->
<div class="status-footer" role="status" aria-live="polite">
    <div class="status-content"></div>
</div>


</body>
</html>
