<?php
require_once __DIR__ . '/includes/config.php';
require_once __DIR__ . '/includes/html-head.php';
require_once __DIR__ . '/includes/footer.php';
require_once __DIR__ . '/includes/common-scripts.php';

renderHTMLHead('Admin');
?>
<body>
<?php require __DIR__ . '/includes/noscript.php'; ?>

<!-- Skip Link -->
<a href="#admin-caption" class="skip-link">Skip to checklists table</a>

<!-- Sticky Header -->
<header class="sticky-header">
    <h1>Admin</h1>
    <button id="homeButton" class="home-button" aria-label="Go to home page">
        <span class="button-text">Home</span>
    </button>
    <div class="header-buttons-group">
        <button id="refreshButton" class="header-button" aria-label="Refresh checklist data">
            <span class="button-text">Refresh</span>
        </button>
    </div>
</header>

<!-- Main Content -->
<main role="main">
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

<?php renderFooter('standard'); ?>

<!-- Old modal HTML removed - now using SimpleModal system -->

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
<?php renderCommonScripts('admin'); ?>
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
    // Use minimal URL format with base path
    const basePath = window.ENV?.basePath || '';
    link.href = `${basePath}/?=${instanceId}`;
    link.textContent = instanceId;
    link.className = 'instance-link';

    // WCAG compliant: Open in new window with proper accessibility attributes
    link.target = '_blank';
    link.rel = 'noopener noreferrer';
    link.setAttribute('aria-label', `Open checklist ${instanceId} in new window`);

    return link;
}

function createDeleteButton(instanceId) {
    // COMPLETELY FRESH - Based on working Status button pattern
    const button = document.createElement('button');
    button.className = 'admin-delete-button';
    button.setAttribute('aria-label', `Delete checklist ${instanceId}`);

    const img = document.createElement('img');
    img.src = window.getImagePath('delete.svg');
    img.alt = 'Delete';
    button.appendChild(img);

    // Simple click handler - no debugging, no complex logic
    button.onclick = () => showDeleteModal(instanceId);
    return button;
}

function showDeleteModal(instanceId) {
    // Store the triggering button for focus restoration
    const triggeringButton = document.activeElement;

    // Show SimpleModal confirmation with proper focus management
    window.simpleModal.delete(
        'Delete Checklist',
        `Are you sure you want to delete checklist ${instanceId}?`,
        () => {
            // Delete confirmed - focus on delete button above or Home
            deleteInstance(instanceId, triggeringButton);
        },
        () => {
            // Delete cancelled - restore focus to triggering button
            setTimeout(() => {
                if (triggeringButton && triggeringButton.classList.contains('admin-delete-button')) {
                    triggeringButton.focus();
                    console.log('Admin: Focus restored to triggering delete button after cancel');
                }
            }, 100);
        }
    );
}

async function deleteInstance(instanceId, triggeringButton) {
    try {
        const apiPath = window.getAPIPath('delete');
        const response = await fetch(apiPath + '?session=' + instanceId, {
            method: 'DELETE'
        });

        if (response.ok) {
            // Find the row being deleted and get the target focus element
            const currentRow = document.querySelector(`tr[data-instance="${instanceId}"]`);
            let targetDeleteButton = null;

            if (currentRow) {
                // Find the delete button in the row above the deleted row
                const previousRow = currentRow.previousElementSibling;
                if (previousRow) {
                    targetDeleteButton = previousRow.querySelector('.admin-delete-button');
                }

                // Remove the row immediately for better UX
                currentRow.remove();

                // Focus management after deletion
                setTimeout(() => {
                    if (targetDeleteButton) {
                        // Focus on the delete button in the row above
                        targetDeleteButton.focus();
                        console.log('Admin: Focused on delete button in row above deleted row');
                    } else {
                        // No row above - check remaining rows
                        const tableBody = document.querySelector('.admin-table tbody');
                        if (tableBody) {
                            const remainingDeleteButtons = tableBody.querySelectorAll('.admin-delete-button');

                            if (remainingDeleteButtons.length > 0) {
                                // Focus on the first remaining delete button
                                const firstDeleteButton = remainingDeleteButtons[0];
                                firstDeleteButton.focus();
                                console.log('Admin: Focused on first remaining delete button');
                            } else {
                                // No more rows - focus on Home button
                                const homeButton = document.getElementById('homeButton');
                                if (homeButton) {
                                    homeButton.focus();
                                    console.log('Admin: Focused on Home button after deletion (no more rows)');
                                }
                            }
                        } else {
                            // Fallback: focus on Home button
                            const homeButton = document.getElementById('homeButton');
                            if (homeButton) {
                                homeButton.focus();
                                console.log('Admin: Focused on Home button after deletion (fallback)');
                            }
                        }
                    }
                }, 100);
            } else {
                // Row not found - reload table and focus Home
                loadInstances();
                setTimeout(() => {
                    const homeButton = document.getElementById('homeButton');
                    if (homeButton) {
                        homeButton.focus();
                        console.log('Admin: Focused on Home button after deletion (row not found)');
                    }
                }, 100);
            }
        } else {
            // Use DRY modal for error messages too
            window.simpleModal.error(
                'Delete Failed',
                'Failed to delete checklist. Please try again.',
                () => {
                    // Restore focus to triggering button on error
                    if (triggeringButton && triggeringButton.classList.contains('admin-delete-button')) {
                        triggeringButton.focus();
                        console.log('Admin: Focus restored to triggering button after delete error');
                    }
                }
            );
        }
    } catch (error) {
        console.error('Error deleting instance:', error);
        window.simpleModal.error(
            'Delete Error',
            'An error occurred while deleting the checklist.',
            () => {
                // Restore focus to triggering button on error
                if (triggeringButton && triggeringButton.classList.contains('admin-delete-button')) {
                    triggeringButton.focus();
                    console.log('Admin: Focus restored to triggering button after delete error');
                }
            }
        );
    }
}

async function loadInstances() {
    console.log('Loading instances...');

    try {
        const apiPath = window.getAPIPath('list');
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
                row.setAttribute('data-instance', instance.sessionKey); // Add data attribute for focus management

                // Format type using TypeManager (use slug)
                const slug = instance.typeSlug || 'unknown';
                const formattedType = await TypeManager.formatDisplayName(slug);

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
