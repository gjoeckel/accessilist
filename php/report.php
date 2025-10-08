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

renderHTMLHead('My Checklist Report');
?>
<body>
<?php require __DIR__ . '/includes/noscript.php'; ?>

<!-- Sticky Header -->
<header class="sticky-header">
    <h1>Report</h1>
    <button id="homeButton" class="home-button" aria-label="Go to home page">
        <span class="button-text">Home</span>
    </button>
    <div class="header-buttons-group">
        <button id="refreshButton" class="header-button" aria-label="Refresh report data">
            <span class="button-text">Refresh</span>
        </button>
    </div>
</header>

<!-- Main Content -->
<main role="main">
    <section id="report" class="admin-section">
        <!-- Filter Buttons -->
        <div class="filter-group" role="group" aria-label="Filter tasks by status">
            <button
                id="filter-completed"
                class="filter-button active"
                data-filter="completed"
                aria-pressed="true"
                aria-label="Show completed tasks">
                <span class="filter-label">Completed</span>
                <span class="filter-count" id="count-completed">0</span>
            </button>
            <button
                id="filter-pending"
                class="filter-button"
                data-filter="pending"
                aria-pressed="false"
                aria-label="Show pending tasks">
                <span class="filter-label">Pending</span>
                <span class="filter-count" id="count-pending">0</span>
            </button>
            <button
                id="filter-in-progress"
                class="filter-button"
                data-filter="in-progress"
                aria-pressed="false"
                aria-label="Show in progress tasks">
                <span class="filter-label">In Progress</span>
                <span class="filter-count" id="count-in-progress">0</span>
            </button>
        </div>

        <!-- Last Update Timestamp -->
        <h2 id="report-caption" tabindex="-1"><span id="report-type-name">Checklist</span> last updated: <span id="last-update-time">Loading...</span></h2>

        <!-- Table Container -->
        <div class="admin-container">
            <table class="admin-table report-table" aria-labelledby="report-caption">
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
<?php renderCommonScripts('admin'); ?>

<!-- Date utilities -->
<script type="module" src="<?php echo $basePath; ?>/js/date-utils.js?v=<?php echo time(); ?>"></script>

<!-- User Report functionality -->
<script type="module">
import { UserReportManager } from '<?php echo $basePath; ?>/js/report.js?v=<?php echo time(); ?>';

const sessionKey = '<?php echo htmlspecialchars($sessionKey, ENT_QUOTES, 'UTF-8'); ?>';

document.addEventListener('DOMContentLoaded', function() {
    console.log('Initializing user report page for session:', sessionKey);

    // Update timestamp on page load
    updateTimestamp();

    // Create report manager instance
    const reportManager = new UserReportManager(sessionKey);
    reportManager.initialize();

    // Set up Home button
    const homeButton = document.getElementById('homeButton');
    if (homeButton) {
        homeButton.addEventListener('click', function() {
            const target = window.getPHPPath
                ? window.getPHPPath('home')
                : '/home';
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

function refreshData() {
    const refreshButton = document.getElementById('refreshButton');
    if (!refreshButton) return;

    // Indicate refresh in progress
    refreshButton.setAttribute('aria-busy', 'true');
    refreshButton.disabled = true;

    // Reload the report data
    const reportManager = new UserReportManager(sessionKey);
    reportManager.initialize().then(() => {
        // Update timestamp after successful refresh
        updateTimestamp();

        // After refresh completes
        refreshButton.setAttribute('aria-busy', 'false');
        refreshButton.disabled = false;
    }).catch(error => {
        console.error('Error refreshing data:', error);
        refreshButton.setAttribute('aria-busy', 'false');
        refreshButton.disabled = false;
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

<!-- Report-specific styles -->
<style>
/* Report header info section */
.report-header-info {
    margin: 2rem 0 1.5rem 0;
    padding: 0 2rem;
}

.report-header-info h2 {
    margin: 0 0 0.5rem 0;
}

/* Subtitle under h2 */
.subtitle {
    font-size: 0.9rem;
    color: #666;
    margin: 0 0 1.5rem 0;
    font-weight: normal;
}

/* Filter Buttons */
.filter-group {
    display: flex;
    gap: 0.75rem;
    margin-bottom: 1.5rem;
    flex-wrap: wrap;
}

.filter-button {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    padding: 0.75rem 1.25rem;
    border: 2px solid #ddd;
    background-color: white;
    color: #333;
    border-radius: 6px;
    cursor: pointer;
    font-size: 0.95rem;
    font-weight: 600;
    transition: all 0.2s ease;
}

.filter-button:hover {
    background-color: #f8f9fa;
    border-color: #adb5bd;
}

.filter-button:focus {
    outline: 2px solid #2196F3;
    outline-offset: 2px;
}

.filter-button.active {
    color: white;
}

.filter-button[data-filter="completed"].active {
    background-color: #4CAF50;
    border-color: #4CAF50;
}

.filter-button[data-filter="pending"].active {
    background-color: #666666;
    border-color: #666666;
}

.filter-button[data-filter="in-progress"].active {
    background-color: #2196F3;
    border-color: #2196F3;
}

.filter-count {
    background-color: rgba(0, 0, 0, 0.1);
    padding: 0.15rem 0.5rem;
    border-radius: 12px;
    font-size: 0.85rem;
    font-weight: 700;
    min-width: 1.5rem;
    text-align: center;
}

.filter-button.active .filter-count {
    background-color: rgba(255, 255, 255, 0.3);
}

/* Checkpoint column - just enough for icon */
.checkpoint-cell {
    width: 5%;
    text-align: center;
    vertical-align: middle;
    padding: 8px;
}

.checkpoint-cell img {
    width: 36px;
    height: 36px;
    display: block;
    margin: 0 auto;
}

/* Updated column (matches table.css pattern) */
.updated-cell {
    width: 8%;
    text-align: center;
    vertical-align: middle;
    padding: 8px;
}

/* Empty state */
.empty-state {
    text-align: center;
    padding: 2rem;
    color: #6c757d;
    font-style: italic;
}
</style>

</body>
</html>

