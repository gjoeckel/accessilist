<?php
require_once __DIR__ . '/includes/config.php';
require_once __DIR__ . '/includes/html-head.php';
require_once __DIR__ . '/includes/footer.php';
require_once __DIR__ . '/includes/common-scripts.php';

// Get and validate session key
$sessionKey = $_GET['session'] ?? '';
if (empty($sessionKey) || !preg_match('/^[A-Z0-9\-]{3,20}$/', $sessionKey)) {
    http_response_code(400);
    echo '<!DOCTYPE html><html><head><title>Invalid Session</title></head><body>';
    echo '<h1>Invalid Session Key</h1>';
    echo '<p>The session key provided is invalid or missing.</p>';
    echo '<a href="' . $basePath . '/home">Return to Home</a>';
    echo '</body></html>';
    exit;
}

// Check if session file exists
$sessionFile = __DIR__ . '/../saves/' . $sessionKey . '.json';
if (!file_exists($sessionFile)) {
    http_response_code(404);
    echo '<!DOCTYPE html><html><head><title>Session Not Found</title></head><body>';
    echo '<h1>Session Not Found</h1>';
    echo '<p>The session "' . htmlspecialchars($sessionKey) . '" does not exist.</p>';
    echo '<a href="' . $basePath . '/home">Return to Home</a>';
    echo '</body></html>';
    exit;
}

renderHTMLHead('List Report');
?>
<link rel="stylesheet" href="<?php echo $basePath; ?>/css/list-report.css?v=<?php echo time(); ?>">
<style>
    /* CSS overrides scoped to list-report page only */

    /* Remove sticky-header-container wrapper and extend header height */
    .list-report-page .sticky-header {
        height: 150px;
    }

    /* Position h1 with pixel values instead of percentage */
    .list-report-page .sticky-header h1 {
        position: absolute;
        left: 50%;
        top: 25px;
        transform: translateX(-50%);
        margin: 0;
        font-size: 1.5rem;
    }

    /* Position Back button with pixel values */
    .list-report-page #backButton {
        position: absolute;
        left: 2rem;
        top: 35px;
        transform: translateY(-50%);
    }

    /* Position Refresh button group with pixel values */
    .list-report-page .header-buttons-group {
        position: absolute;
        right: 1rem;
        top: 35px;
        transform: translateY(-50%);
    }

    /* Move filter-group inside header, position at 80px, full width, no background */
    .list-report-page .filter-group {
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
    .list-report-page .filter-group::before {
        display: none;
    }

    /* Adjust report section spacing */
    .list-report-page .report-section {
        padding-top: 60px;
    }

    /* Reduce h2 margin-bottom */
    .list-report-page #report-caption {
        margin-bottom: 10px;
    }

    /* Move side panel buttons down to accommodate new header height */
    /* Old: 105px (70px header + 35px spacing), New: 185px (150px header + 35px spacing) */
    .list-report-page .side-panel ul {
        padding-top: 185px;
    }
</style>
<body class="report-page list-report-page">
<?php require __DIR__ . '/includes/noscript.php'; ?>

<!-- Skip Link -->
<a href="#report-caption" class="skip-link">Skip to report table</a>

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
  console.log('🎯 [INLINE SCRIPT] Initial scroll to 130, waiting for content to build...');
</script>

<!-- Side Panel - Checkpoint Navigation -->
<nav class="side-panel" aria-expanded="true">
    <ul id="checkpoint-nav">
        <!-- Checkpoint buttons generated dynamically by list-report.js -->
    </ul>
    <button class="toggle-strip" aria-label="Toggle side panel" aria-expanded="true" title="Toggle navigation panel">
        <span class="toggle-arrow" aria-hidden="true">◀</span>
    </button>
</nav>

<!-- Sticky Header with Filters Inside -->
<header class="sticky-header">
    <h1>List Report</h1>
    <button id="backButton" class="back-button" aria-label="Back to checklist">
        <span class="button-text">Back</span>
    </button>
    <div class="header-buttons-group">
        <button id="refreshButton" class="header-button" aria-label="Refresh report data">
            <span class="button-text">Refresh</span>
        </button>
    </div>

    <!-- Filter Buttons -->
    <div class="filter-group" role="group" aria-label="Filter tasks by status">
        <button
            id="filter-completed"
            class="filter-button"
            data-filter="completed"
            aria-pressed="false"
            aria-label="Show completed tasks">
            <span class="filter-label">Done</span>
            <span class="filter-count" id="count-completed">0</span>
        </button>
        <button
            id="filter-in-progress"
            class="filter-button"
            data-filter="in-progress"
            aria-pressed="false"
            aria-label="Show in progress tasks">
            <span class="filter-label">Active</span>
            <span class="filter-count" id="count-in-progress">0</span>
        </button>
        <button
            id="filter-pending"
            class="filter-button"
            data-filter="pending"
            aria-pressed="false"
            aria-label="Show not started tasks">
            <span class="filter-label">Not Started</span>
            <span class="filter-count" id="count-pending">0</span>
        </button>
        <button
            id="filter-all"
            class="filter-button active"
            data-filter="all"
            aria-pressed="true"
            aria-label="Show all tasks">
            <span class="filter-label">All</span>
            <span class="filter-count" id="count-all">0</span>
        </button>
    </div>
</header>

<!-- Main Content -->
<main role="main">
    <section id="report" class="report-section">
        <!-- Last Update Timestamp -->
        <h2 id="report-caption" tabindex="-1"><span id="report-type-name">Checklist</span> last updated: <span id="last-update-time">Loading...</span></h2>

        <!-- Table Container -->
        <div class="report-container">
            <table class="report-table" aria-labelledby="report-caption">
                <thead>
                    <tr>
                        <th class="checkpoint-cell">Chkpt</th>
                        <th class="task-cell">Tasks</th>
                        <th class="notes-cell">Notes</th>
                        <th class="status-cell">Status</th>
                    </tr>
                </thead>
                <tbody>
                    <!-- Will be populated dynamically -->
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
<?php renderCommonScripts('admin'); ?>

<!-- Date utilities -->
<script type="module" src="<?php echo $basePath; ?>/js/date-utils.js?v=<?php echo time(); ?>"></script>

<!-- User Report functionality -->
<script type="module">
import { UserReportManager } from '<?php echo $basePath; ?>/js/list-report.js?v=<?php echo time(); ?>';

const sessionKey = '<?php echo htmlspecialchars($sessionKey, ENT_QUOTES, 'UTF-8'); ?>';

document.addEventListener('DOMContentLoaded', function() {

    console.log('Initializing user report page for session:', sessionKey);

    // Update timestamp on page load
    updateTimestamp();

    // Create report manager instance
    const reportManager = new UserReportManager(sessionKey);
    reportManager.initialize();

    // Set up Back button to return to checklist
    const backButton = document.getElementById('backButton');
    if (backButton) {
        backButton.addEventListener('click', function() {
            const basePath = window.basePath || '';
            window.location.href = `${basePath}/mychecklist?session=${sessionKey}`;
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

    // Reload the report data
    const reportManager = new UserReportManager(sessionKey);
    reportManager.initialize().then(() => {
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

        // Show error message
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
</script>


</body>
</html>
