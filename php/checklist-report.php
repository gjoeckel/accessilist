<?php
require_once __DIR__ . '/includes/config.php';
require_once __DIR__ . '/includes/html-head.php';
require_once __DIR__ . '/includes/footer.php';
require_once __DIR__ . '/includes/common-scripts.php';

renderHTMLHead('Accessibility Report - AccessiList', true);
?>
<body>
<!-- Loading Overlay -->
<div id="loadingOverlay" role="alert" aria-live="polite">
  <div id="loadingSpinner"></div>
  <div id="loadingText">Loading report...</div>
</div>

<?php require __DIR__ . '/includes/noscript.php'; ?>

<!-- Skip Link -->
<a href="#report-caption" class="skip-link">Skip to report table</a>

<!-- Sticky Header -->
<header class="sticky-header">
    <h1>Accessibility Report</h1>
    <div class="header-buttons">
        <a href="<?php echo $basePath; ?>/php/mychecklist.php" class="save-button" aria-label="Back to checklist">
            <span>Back to Checklist</span>
        </a>
    </div>
</header>

<!-- Main Content -->
<main role="main" aria-label="Accessibility report content">
    <div id="content">
        <section class="report-section" id="report">
            <div class="report-container" role="region" aria-label="Report section">
                <h2 id="report-caption" tabindex="-1">Accessibility Report</h2>

                <table class="report-table" aria-labelledby="report-caption">
                    <thead>
                        <tr>
                            <th class="report-date-cell" scope="col">Date</th>
                            <th class="report-task-cell" scope="col">Tasks</th>
                            <th class="report-notes-cell" scope="col">Notes</th>
                            <th class="report-status-cell" scope="col">Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <!-- Report rows will be generated automatically here -->
                    </tbody>
                </table>
            </div>
        </section>
    </div>
</main>

<?php renderFooter('status'); ?>

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
<?php renderCommonScripts('report'); ?>

<!-- Report-specific JavaScript -->
<script type="module">
  // Get session key from URL
  const urlParams = new URLSearchParams(window.location.search);
  const sessionKey = urlParams.get('session') || '000';

  // Load and display report data
  async function loadReportData() {
    try {
      const apiPath = window.getAPIPath ? window.getAPIPath('restore.php') : '/php/api/restore.php';
      const response = await fetch(`${apiPath}?sessionKey=${sessionKey}`);

      if (!response.ok) {
        throw new Error(`Failed to load report data: ${response.status}`);
      }

      const result = await response.json();
      if (result.success && result.data && result.data.state) {
        generateReportRows(result.data.state);
      } else {
        showNoDataMessage();
      }
    } catch (error) {
      console.error('Error loading report data:', error);
      showErrorMessage();
    } finally {
      hideLoading();
    }
  }

  function generateReportRows(state) {
    const tbody = document.querySelector('.report-table tbody');
    if (!tbody) return;

    // Clear existing rows
    tbody.innerHTML = '';

    // Generate rows from principle checklist data
    const reportRows = [];

    // Process principle rows data
    if (state.principleRows) {
      Object.keys(state.principleRows).forEach(principleId => {
        const rows = state.principleRows[principleId];
        if (Array.isArray(rows)) {
          rows.forEach(rowData => {
            if (rowData.task && rowData.task.trim() !== '') {
              reportRows.push({
                date: new Date().toLocaleDateString('en-US', {
                  month: '2-digit',
                  day: '2-digit',
                  year: '2-digit'
                }),
                task: rowData.task,
                notes: rowData.notes || '',
                status: rowData.status || 'pending'
              });
            }
          });
        }
      });
    }

    // Generate rows from notes data (completed tasks)
    if (state.notes) {
      Object.keys(state.notes).forEach(taskId => {
        const notes = state.notes[taskId];
        if (notes && notes.trim() !== '') {
          // Find corresponding task from checklist data
          const taskText = findTaskText(taskId);
          if (taskText) {
            reportRows.push({
              date: new Date().toLocaleDateString('en-US', {
                month: '2-digit',
                day: '2-digit',
                year: '2-digit'
              }),
              task: taskText,
              notes: notes,
              status: 'completed'
            });
          }
        }
      });
    }

    // Render rows
    if (reportRows.length === 0) {
      showNoDataMessage();
    } else {
      reportRows.forEach(rowData => {
        const row = createReportRow(rowData);
        tbody.appendChild(row);
      });
    }
  }

  function createReportRow(rowData) {
    const tr = document.createElement('tr');
    tr.className = 'report-row';

    // Date cell
    const dateCell = document.createElement('td');
    dateCell.className = 'report-date-cell';
    dateCell.textContent = rowData.date;
    tr.appendChild(dateCell);

    // Task cell
    const taskCell = document.createElement('td');
    taskCell.className = 'report-task-cell';
    const taskDiv = document.createElement('div');
    taskDiv.className = 'report-task-text';
    taskDiv.textContent = rowData.task;
    taskCell.appendChild(taskDiv);
    tr.appendChild(taskCell);

    // Notes cell
    const notesCell = document.createElement('td');
    notesCell.className = 'report-notes-cell';
    const notesDiv = document.createElement('div');
    notesDiv.className = 'report-notes-text';
    notesDiv.textContent = rowData.notes;
    notesCell.appendChild(notesDiv);
    tr.appendChild(notesCell);

    // Status cell
    const statusCell = document.createElement('td');
    statusCell.className = 'report-status-cell';
    const statusDiv = document.createElement('div');
    statusDiv.className = 'report-status-text';
    statusDiv.textContent = rowData.status.charAt(0).toUpperCase() + rowData.status.slice(1);
    statusCell.appendChild(statusDiv);
    tr.appendChild(statusCell);

    return tr;
  }

  function findTaskText(taskId) {
    // This would need to be implemented based on your checklist data structure
    // For now, return a placeholder
    return `Task ${taskId}`;
  }

  function showNoDataMessage() {
    const tbody = document.querySelector('.report-table tbody');
    if (tbody) {
      tbody.innerHTML = '<tr><td colspan="4" class="table-no-data-message">No report data available. Complete some checklist items first.</td></tr>';
    }
  }

  function showErrorMessage() {
    const tbody = document.querySelector('.report-table tbody');
    if (tbody) {
      tbody.innerHTML = '<tr><td colspan="4" class="table-error-message">Error loading report data. Please try again.</td></tr>';
    }
  }

  function hideLoading() {
    const loadingOverlay = document.getElementById('loadingOverlay');
    if (loadingOverlay) {
      loadingOverlay.style.display = 'none';
    }
  }

  // Initialize when DOM is ready
  document.addEventListener('DOMContentLoaded', function() {
    loadReportData();
  });
</script>

</body>
</html>
