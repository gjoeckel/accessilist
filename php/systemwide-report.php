<?php
require_once __DIR__ . '/includes/config.php';
require_once __DIR__ . '/includes/html-head.php';
require_once __DIR__ . '/includes/footer.php';
require_once __DIR__ . '/includes/common-scripts.php';

renderHTMLHead('Systemwide Report');
?>
<link rel="stylesheet" href="<?php echo $basePath; ?>/css/systemwide-report.css?v=<?php echo time(); ?>">
<style>
    /* CSS overrides scoped to systemwide-report page only */

    /* Remove sticky-header-container wrapper and extend header height */
    .systemwide-report-page .sticky-header {
        height: 150px;
    }

    /* Position h1 with pixel values instead of percentage */
    .systemwide-report-page .sticky-header h1 {
        position: absolute;
        left: 50%;
        top: 25px;
        transform: translateX(-50%);
        margin: 0;
        font-size: 1.5rem;
    }

    /* Position Home button with pixel values */
    .systemwide-report-page #homeButton {
        position: absolute;
        left: 2rem;
        top: 35px;
        transform: translateY(-50%);
    }

    /* Position Refresh button group with pixel values */
    .systemwide-report-page .header-buttons-group {
        position: absolute;
        right: 1rem;
        top: 35px;
        transform: translateY(-50%);
    }

    /* Move filter-group inside header, position at 80px, full width, no background */
    .systemwide-report-page .filter-group {
        position: absolute;
        top: 80px;
        left: 0;
        width: 100%;
        background-color: transparent;
        padding-top: 0;
        padding-bottom: 0;
        margin: 0;
    }

    /* Remove white background pseudo-element from filter-group */
    .systemwide-report-page .filter-group::before {
        display: none;
    }

    /* Adjust report section spacing */
    .systemwide-report-page .report-section {
        padding-top: 60px;
    }

    /* Reduce h2 margin-bottom */
    .systemwide-report-page #reports-caption {
        margin-bottom: 10px;
    }
</style>
<body class="report-page systemwide-report-page">
<?php require __DIR__ . '/includes/noscript.php'; ?>

<!-- Skip Link -->
<a href="#reports-caption" class="skip-link">Skip to reports table</a>

<!-- Immediate Scroll Initialization - Prevents visual stutter -->
<script>
  // Disable scroll restoration
  if ('scrollRestoration' in history) {
    history.scrollRestoration = 'manual';
  }
  // Scroll immediately to h2 position (before page renders)
  // ::before pseudo-element is 120px tall
  // Scrolling to 120 puts viewport at END of ::before (start of .report-section)
  // .report-section has 90px padding-top, so h2 is at 120 + 90 = 210
  // But we scroll slightly less to show h2 just below the filters: 130px
  window.scrollTo(0, 130);
</script>

<!-- Sticky Header with Filters Inside -->
<header class="sticky-header">
    <h1>Systemwide Report</h1>
    <button id="homeButton" class="home-button" aria-label="Go to home page">
        <span class="button-text">Home</span>
    </button>
    <div class="header-buttons-group">
        <button id="refreshButton" class="header-button" aria-label="Refresh reports data">
            <span class="button-text">Refresh</span>
        </button>
    </div>

    <!-- Filter Buttons -->
    <div class="filter-group" role="group" aria-label="Filter reports by status">
        <button
            id="filter-completed"
            class="filter-button"
            data-filter="completed"
            aria-pressed="false"
            aria-label="Show completed reports">
            <span class="filter-label">Done</span>
            <span class="filter-count" id="count-completed">0</span>
        </button>
        <button
            id="filter-in-progress"
            class="filter-button"
            data-filter="in-progress"
            aria-pressed="false"
            aria-label="Show in progress reports">
            <span class="filter-label">Active</span>
            <span class="filter-count" id="count-in-progress">0</span>
        </button>
        <button
            id="filter-pending"
            class="filter-button"
            data-filter="pending"
            aria-pressed="false"
            aria-label="Show reports where all tasks are not started">
            <span class="filter-label">Not Started</span>
            <span class="filter-count" id="count-pending">0</span>
        </button>
        <button
            id="filter-all"
            class="filter-button active"
            data-filter="all"
            aria-pressed="true"
            aria-label="Show all reports">
            <span class="filter-label">All</span>
            <span class="filter-count" id="count-all">0</span>
        </button>
    </div>
</header>

<!-- Main Content -->
<main role="main">
    <section id="reports" class="report-section">
        <!-- Last Update Timestamp -->
        <h2 id="reports-caption" tabindex="-1">Last update: <span id="last-update-time">Loading...</span></h2>


        <!-- Table Container -->
        <div class="report-container">
            <table class="principles-table reports-table" aria-labelledby="reports-caption">
                <thead>
                    <tr>
                        <th class="task-cell">Type</th>
                        <th class="task-cell">Updated</th>
                        <th class="info-cell">Key</th>
                        <th class="status-cell">Status</th>
                        <th class="task-cell">Progress</th>
                        <th class="restart-cell">Delete</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td class="task-cell">Sample type</td>
                        <td class="task-cell">2024-01-15</td>
                        <td class="info-cell">
                            <button class="info-link" aria-label="Show example">
                                <img src="/images/info-.svg" alt="">
                            </button>
                        </td>
                        <td class="status-cell">
                            <button class="status-button" aria-label="Task status: Active">
                                <img src="/images/active-1.svg" alt="">
                            </button>
                        </td>
                        <td class="task-cell">5/10 tasks</td>
                        <td class="restart-cell">
                            <button class="restart-button restart-hidden" aria-label="Reset task">
                                <img src="/images/reset.svg" alt="">
                            </button>
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
    </section>
</main>

<?php renderFooter(); ?>

<!-- Scripts -->
<script>
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
import { ReportsManager } from '<?php echo $basePath; ?>/js/systemwide-report.js?v=<?php echo time(); ?>';

// Initialize reports manager
let reportsManager;

document.addEventListener('DOMContentLoaded', function() {

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
        statusContent.textContent = 'Refreshing report...';
        statusContent.classList.remove('status-success', 'status-error');
    }

    // Reload the data
    if (reportsManager) {
        reportsManager.loadChecklists().then(() => {
            // Update timestamp after successful refresh
            updateTimestamp();

            // Recalculate buffer after refresh
            if (typeof window.scheduleReportBufferUpdate === 'function') {
                window.scheduleReportBufferUpdate();
            }

            // After refresh completes
            refreshButton.setAttribute('aria-busy', 'false');
            refreshButton.disabled = false;
            refreshButton.focus(); // Keep focus while success message shows

            // Announce completion to screen readers
            if (statusContent) {
                statusContent.textContent = 'Report refreshed successfully';
                statusContent.classList.add('status-success');
                setTimeout(() => {
                    statusContent.textContent = '';
                    statusContent.classList.remove('status-success');
                    refreshButton.blur(); // Release focus when message disappears
                }, 5000);
            }
        }).catch(error => {
            console.error('Error refreshing data:', error);
            refreshButton.setAttribute('aria-busy', 'false');
            refreshButton.disabled = false;
            refreshButton.focus(); // Keep focus while error message shows

            // Show error message in footer
            if (statusContent) {
                statusContent.textContent = 'Error refreshing report';
                statusContent.classList.add('status-error');
                setTimeout(() => {
                    statusContent.textContent = '';
                    statusContent.classList.remove('status-error');
                    refreshButton.blur(); // Release focus when error message disappears
                }, 5000);
            }
        });
    }
}
</script>

</body>
</html>
