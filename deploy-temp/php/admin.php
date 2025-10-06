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
<title>Admin</title>
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
</head>
<body>
<!-- NoScript fallback -->
<noscript>
<p>This application requires JavaScript to function properly. Please enable JavaScript in your browser settings.</p>
</noscript>

<!-- Sticky Header -->
<header class="sticky-header">
    <h1>Admin</h1>
    <div class="header-buttons">
        <button id="homeButton" class="home-button" aria-label="Go to home page">
            <span class="button-text">Home</span>
        </button>
        <button id="refreshButton" class="header-button" aria-label="Refresh checklist data">
            <span class="button-text">Refresh</span>
        </button>
    </div>
</header>

<!-- Main Content -->
<main>
    <section id="admin" class="admin-section">
        <h2 id="admin-caption" tabindex="-1">Checklists</h2>
        <div class="admin-container">
            <table class="admin-table" aria-labelledby="admin-caption">
                <thead>
                    <tr>
                        <th class="admin-type-cell">Type</th>
                        <th class="admin-date-cell">Created</th>
                        <th class="admin-instance-cell">Key</th>
                        <th class="admin-date-cell">Updated</th>
                        <th class="admin-delete-cell">Delete</th>
                    </tr>
                </thead>
                <tbody>
                    <!-- Will be populated dynamically -->
                </tbody>
            </table>
        </div>
    </section>
</main>

<!-- Footer -->
<footer role="contentinfo">
    <p>© 2025 NCADEMI. All rights reserved.</p>
</footer>

<!-- Old modal HTML removed - now using SimpleModal system -->

<!-- Path Configuration -->
<script src="<?php echo $basePath; ?>/js/path-utils.js?v=<?php echo time(); ?>"></script>
<script src="<?php echo $basePath; ?>/js/type-manager.js?v=<?php echo time(); ?>"></script>
<script type="module" src="<?php echo $basePath; ?>/js/ui-components.js?v=<?php echo time(); ?>"></script>
<script src="<?php echo $basePath; ?>/js/simple-modal.js?v=<?php echo time(); ?>"></script>
<script src="<?php echo $basePath; ?>/js/ModalActions.js?v=<?php echo time(); ?>"></script>
<script>
// Error monitoring for debugging
window.addEventListener('error', function(e) {
    console.error('Script error detected:', {
        message: e.message,
        filename: e.filename,
        line: e.lineno,
        column: e.colno,
        error: e.error
    });
});
</script>

<!-- Date utilities (shared) -->
<script type="module" src="<?php echo $basePath; ?>/js/date-utils.js?v=<?php echo time(); ?>"></script>

<!-- Core Admin Functionality (Embedded) -->
<script>
// Embedded admin functionality to avoid script loading issues
function formatDate(timestamp) {
    // Use utility if available, otherwise fallback to standard format
    if (window.formatDateAdmin) {
        return window.formatDateAdmin(timestamp);
    }
    // Fallback: MM-DD-YY HH:MM AM/PM format
    const date = new Date(timestamp);
    return date.toLocaleString('en-US', {
        month: '2-digit',
        day: '2-digit',
        year: '2-digit',
        hour: 'numeric',
        minute: '2-digit',
        hour12: true
    }).replace(/\//g, '-').replace(',', '');
}

function createInstanceLink(instanceId, typeSlug) {
    const link = document.createElement('a');
    // Use minimal URL format instead of full URL
    link.href = `/?=${instanceId}`;
    link.textContent = instanceId;
    link.className = 'instance-link';

    // WCAG compliant: Open in new window with proper accessibility attributes
    link.target = '_blank';
    link.rel = 'noopener noreferrer';
    link.setAttribute('aria-label', `Open checklist ${instanceId} in new window`);

    return link;
}

function createDeleteButton(instanceId) {
    const button = document.createElement('button');
    button.className = 'admin-delete-button';
    button.setAttribute('aria-label', `Delete checklist ${instanceId}`);

    const img = document.createElement('img');
    img.src = window.getImagePath('delete.svg');
    img.alt = 'Delete';
    button.appendChild(img);

    button.onclick = () => showDeleteModal(instanceId);
    return button;
}

function showDeleteModal(instanceId) {
    // Show SimpleModal confirmation
    window.simpleModal.delete(
        'Delete Checklist',
        `Are you sure you want to delete checklist ${instanceId}?`,
        () => deleteInstance(instanceId),
        () => console.log('Delete cancelled')
    );
}

async function deleteInstance(instanceId) {
    try {
        const apiPath = window.getAPIPath('delete.php');
        const response = await fetch(apiPath + '?session=' + instanceId, {
            method: 'DELETE'
        });

        if (response.ok) {
            loadInstances();
        } else {
            // Use DRY modal for error messages too
            window.simpleModal.error(
                'Delete Failed',
                'Failed to delete checklist. Please try again.',
                () => console.log('Error modal closed')
            );
        }
    } catch (error) {
        console.error('Error deleting instance:', error);
        window.simpleModal.error(
            'Delete Error',
            'An error occurred while deleting the checklist.',
            () => console.log('Error modal closed')
        );
    }
}

async function loadInstances() {
    console.log('Loading instances...');

    try {
        const apiPath = window.getAPIPath('list.php');
        console.log('Fetching from:', apiPath);

        const response = await fetch(apiPath);
        console.log('Response status:', response.status);

        if (!response.ok) {
            throw new Error(`API responded with status: ${response.status}`);
        }

        const responseData = await response.json();
        console.log('Instances loaded:', responseData);

        // Extract instances from standardized API response shape
        const instances = Array.isArray(responseData && responseData.data)
            ? responseData.data
            : [];

        console.log('Extracted instances array:', instances);

        const tbody = document.querySelector('.admin-table tbody');
        if (tbody) {
            tbody.innerHTML = '';

            if (instances.length === 0) {
                const row = document.createElement('tr');
                const cell = document.createElement('td');
                cell.colSpan = 5;
                cell.textContent = 'No instances found';
                cell.style.textAlign = 'center';
                row.appendChild(cell);
                tbody.appendChild(row);
            } else {
                for (const instance of instances) {
                // Use creation date if available, otherwise fall back to timestamp
                const createdDate = instance.created || instance.metadata?.created || instance.timestamp;

                // Only show updated timestamp if it exists (after first save)
                const updatedText = instance.metadata?.lastModified
                    ? formatDate(instance.metadata.lastModified)
                    : '—'; // Em dash for "not yet saved"

                const row = document.createElement('tr');

                // Format type using TypeManager
                const typeText = instance.type || 'Unknown';
                const formattedType = await TypeManager.formatDisplayName(typeText);

                row.innerHTML = `
                    <td>${formattedType}</td>
                    <td>${formatDate(createdDate)}</td>
                    <td>${createInstanceLink(instance.sessionKey, instance.typeSlug).outerHTML}</td>
                    <td>${updatedText}</td>
                    <td class="admin-delete-cell"></td>
                `;

                const actionsCell = row.querySelector('.admin-delete-cell');
                const deleteButton = createDeleteButton(instance.sessionKey);
                actionsCell.appendChild(deleteButton);

                tbody.appendChild(row);
                }
            }
        }
    } catch (error) {
        console.error('Error loading instances:', error);
        const tbody = document.querySelector('.admin-table tbody');
        if (tbody) {
            tbody.innerHTML = '<tr><td colspan="4" class="error-message">Error loading instances</td></tr>';
        }
    }
}

function initializeAdmin() {
    console.log('Initializing admin functionality');
    loadInstances();
}
</script>
<script>
  document.addEventListener('DOMContentLoaded', function() {
    // Set up Home button
    const homeButton = document.getElementById('homeButton');
    if (homeButton) {
      homeButton.addEventListener('click', function() {
        var target = (window.getPHPPath && typeof window.getPHPPath === 'function')
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

    // Initialize admin functionality
    if (typeof initializeAdmin === 'function') {
      console.log('Initializing admin functionality');
      initializeAdmin();
    } else {
      console.error('initializeAdmin function not found');
    }
  });

  function refreshData() {
    const refreshButton = document.getElementById('refreshButton');
    const statusContent = document.querySelector('.status-content');
    if (!refreshButton || !statusContent) return;

    // Indicate refresh in progress
    refreshButton.setAttribute('aria-busy', 'true');

    // Reload the table data
    if (typeof loadInstances === 'function') {
      loadInstances().then(() => {
        // After refresh completes
        refreshButton.setAttribute('aria-busy', 'false');
      }).catch(error => {
        console.error('Error refreshing data:', error);
        refreshButton.setAttribute('aria-busy', 'false');
        statusContent.textContent = 'Error';

        // Clear error message after 5 seconds
        setTimeout(() => {
          statusContent.textContent = '';
        }, 5000);
      });
    } else {
      console.error('loadInstances function not found');
      refreshButton.setAttribute('aria-busy', 'false');
      statusContent.textContent = 'Error';

      // Clear error message after 5 seconds
      setTimeout(() => {
        statusContent.textContent = '';
      }, 5000);
    }
  }
</script>

<!-- Status Footer -->
<div class="status-footer" role="status" aria-live="polite">
    <div class="status-content"></div>
</div>

</body>
</html>
