<?php
require_once __DIR__ . '/includes/config.php';
require_once __DIR__ . '/includes/html-head.php';
require_once __DIR__ . '/includes/footer.php';
require_once __DIR__ . '/includes/common-scripts.php';

renderHTMLHead('Reports');
?>
<body>
<?php require __DIR__ . '/includes/noscript.php'; ?>

<!-- Sticky Header -->
<header class="sticky-header">
    <h1>Reports</h1>
    <div class="header-buttons">
        <button id="homeButton" class="home-button" aria-label="Go to home page">
            <span class="button-text">Home</span>
        </button>
        <button id="refreshButton" class="header-button" aria-label="Refresh reports data">
            <span class="button-text">Refresh</span>
        </button>
    </div>
</header>

<!-- Main Content -->
<main role="main">
    <section id="reports" class="admin-section">
        <h2 id="reports-caption" tabindex="-1">Checklist Reports</h2>
        
        <!-- Filter Buttons -->
        <div class="filter-group" role="group" aria-label="Filter checklists by status">
            <button 
                id="filter-completed" 
                class="filter-button active" 
                data-filter="completed"
                aria-pressed="true"
                aria-label="Show completed checklists">
                <span class="filter-label">Completed</span>
                <span class="filter-count" id="count-completed">0</span>
            </button>
            <button 
                id="filter-pending" 
                class="filter-button" 
                data-filter="pending"
                aria-pressed="false"
                aria-label="Show pending checklists">
                <span class="filter-label">Pending</span>
                <span class="filter-count" id="count-pending">0</span>
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
        </div>

        <!-- Table Container -->
        <div class="admin-container">
            <table class="admin-table reports-table" aria-labelledby="reports-caption">
                <thead>
                    <tr>
                        <th class="admin-type-cell">Type</th>
                        <th class="admin-date-cell">Created</th>
                        <th class="admin-instance-cell">Key</th>
                        <th class="reports-status-cell">Status</th>
                        <th class="reports-progress-cell">Progress</th>
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

function refreshData() {
    const refreshButton = document.getElementById('refreshButton');
    if (!refreshButton) return;

    // Indicate refresh in progress
    refreshButton.setAttribute('aria-busy', 'true');
    refreshButton.disabled = true;

    // Reload the data
    if (reportsManager) {
        reportsManager.loadChecklists().then(() => {
            // After refresh completes
            refreshButton.setAttribute('aria-busy', 'false');
            refreshButton.disabled = false;
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

<!-- Additional CSS for Reports-specific styling -->
<style>
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
    background-color: #FF9800;
    border-color: #FF9800;
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

/* Status Badge */
.status-badge {
    display: inline-block;
    padding: 0.25rem 0.75rem;
    border-radius: 12px;
    font-size: 0.85rem;
    font-weight: 600;
}

.status-badge.completed {
    background-color: #e8f5e9;
    color: #2e7d32;
}

.status-badge.pending {
    background-color: #fff3e0;
    color: #e65100;
}

.status-badge.in-progress {
    background-color: #e3f2fd;
    color: #1565c0;
}

/* Progress Bar */
.progress-container {
    display: flex;
    align-items: center;
    gap: 0.75rem;
}

.progress-bar {
    flex: 1;
    height: 8px;
    background-color: #e0e0e0;
    border-radius: 4px;
    overflow: hidden;
}

.progress-fill {
    height: 100%;
    transition: width 0.3s ease;
    border-radius: 4px;
}

.progress-fill.completed {
    background-color: #4CAF50;
}

.progress-fill.in-progress {
    background-color: #2196F3;
}

.progress-fill.pending {
    background-color: #9E9E9E;
}

.progress-text {
    font-size: 0.85rem;
    color: #666;
    font-weight: 600;
    min-width: 50px;
}

/* Table Columns */
.reports-status-cell {
    width: 130px;
}

.reports-progress-cell {
    width: 180px;
}
</style>

</body>
</html>
