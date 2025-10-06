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
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Accessibility Report - AccessiList</title>
<link rel="stylesheet" href="<?php echo $basePath; ?>/css/simple-modal.css">
<link rel="stylesheet" href="<?php echo $basePath; ?>/css/focus.css">
<link rel="stylesheet" href="<?php echo $basePath; ?>/css/landing.css">
<link rel="stylesheet" href="<?php echo $basePath; ?>/css/admin.css">
<link rel="stylesheet" href="<?php echo $basePath; ?>/css/form-elements.css">
<link rel="stylesheet" href="<?php echo $basePath; ?>/css/table.css">
<link rel="stylesheet" href="<?php echo $basePath; ?>/css/section.css">
<link rel="stylesheet" href="<?php echo $basePath; ?>/css/status.css">
<link rel="stylesheet" href="<?php echo $basePath; ?>/css/side-panel.css">
<link rel="stylesheet" href="<?php echo $basePath; ?>/css/header.css">
<link rel="stylesheet" href="<?php echo $basePath; ?>/css/base.css">
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
    animation: spin 1s linear infinite;
  }

  @keyframes spin {
    0% { transform: rotate(0deg); }
    100% { transform: rotate(360deg); }
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
  <div id="loadingText">Loading report...</div>
</div>

<!-- NoScript fallback -->
<noscript>
<p>This application requires JavaScript to function properly. Please enable JavaScript in your browser settings.</p>
</noscript>

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

<!-- Footer -->
<div class="status-footer" role="contentinfo" aria-live="polite">
    <p class="copyright-text">© 2025 NCADEMI. All rights reserved.</p>
    <div class="status-content"></div>
</div>

<!-- Scripts -->
<script type="module" src="<?php echo $basePath; ?>/js/path-utils.js?v=<?php echo time(); ?>"></script>
<script type="module" src="<?php echo $basePath; ?>/js/date-utils.js?v=<?php echo time(); ?>"></script>

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
      tbody.innerHTML = '<tr><td colspan="4" style="text-align: center; padding: 2rem; color: #666;">No report data available. Complete some checklist items first.</td></tr>';
    }
  }

  function showErrorMessage() {
    const tbody = document.querySelector('.report-table tbody');
    if (tbody) {
      tbody.innerHTML = '<tr><td colspan="4" style="text-align: center; padding: 2rem; color: #d32f2f;">Error loading report data. Please try again.</td></tr>';
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
