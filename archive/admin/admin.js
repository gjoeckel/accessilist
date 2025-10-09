// Function to format date for admin display
function formatDate(timestamp) {
    // Use utility if available, otherwise fallback to standard format
    if (window.formatDateAdmin) {
        return window.formatDateAdmin(timestamp);
    }
    // Fallback: standard date and time
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

// Function to create key link
function createKeyLink(keyId, typeSlug) {
    const link = document.createElement('a');
    const slug = typeSlug ? encodeURIComponent(typeSlug) : '';
    const phpPath = (typeof window.getPHPPath === 'function')
        ? window.getPHPPath('mychecklist.php')
        : '/php/mychecklist.php';
    link.href = slug
        ? `${phpPath}?session=${keyId}&type=${slug}`
        : `${phpPath}?session=${keyId}`;
    link.className = 'key-link';
    link.textContent = keyId;
    link.target = '_blank';
    return link;
}

// Function to create delete button
function createDeleteButton(keyId) {
    return createButton({
        className: 'admin-delete-button',
        ariaLabel: `Delete key ${keyId}`,
        icon: 'delete.svg',
        iconAlt: 'Delete',
        onClick: () => showDeleteModal(keyId)
    });
}

// Function to show delete confirmation modal (using DRY modal manager)
function showDeleteModal(keyId) {
    // Store the triggering button for cancel focus restoration
    const triggeringButton = document.activeElement;

    // Show SimpleModal confirmation
    window.simpleModal.delete(
        'Delete Checklist',
        'Do you want to delete this list?',
        () => {
            deleteKey(keyId);

            // Focus on the nearest interactive element after delete
            setTimeout(() => {
                // Try to focus on delete button above the deleted row
                const currentRow = document.querySelector(`tr[data-key="${keyId}"]`);
                const tableBody = currentRow?.closest('tbody');

                if (tableBody) {
                    const allRows = Array.from(tableBody.querySelectorAll('tr'));
                    const currentRowIndex = allRows.indexOf(currentRow);

                    // Look for delete button in row above
                    if (currentRowIndex > 0) {
                        const rowAbove = allRows[currentRowIndex - 1];
                        const deleteButtonAbove = rowAbove.querySelector('.admin-delete-button');
                        if (deleteButtonAbove) {
                            deleteButtonAbove.focus();
                            console.log('Admin: Focused on delete button above after deletion');
                            return;
                        }
                    }
                }

                // Fallback: Focus on Home button if no more rows or no delete button above
                const homeButton = document.getElementById('homeButton');
                if (homeButton) {
                    homeButton.focus();
                    console.log('Admin: Focused on Home button after deletion (no more rows)');
                }
            }, 100);
        },
        () => {
            // Cancel - restore focus to triggering button
            setTimeout(() => {
                if (triggeringButton) {
                    triggeringButton.focus();
                    console.log('Admin: Restored focus to triggering button after cancel');
                }
            }, 100);
        }
    );
}

// Function to delete key
async function deleteKey(keyId) {
    try {
        const apiPath = window.getAPIPath('delete');
        const response = await fetch(apiPath + '?session=' + keyId, {
            method: 'DELETE'
        });
        if (response.ok) {
            // Remove the row from the table
            const row = document.querySelector(`tr[data-key="${keyId}"]`);
            if (row) {
                row.remove();
            }
        } else {
            alert('Failed to delete key');
        }
    } catch (error) {
        console.error('Error deleting key:', error);
        alert('Error deleting key');
    }
}

// Function to load keys
async function loadKeys() {
    console.log('Loading instances...');
    return new Promise(async (resolve, reject) => {
        try {
            // Enhanced path debugging
            console.log('Path config available:', !!window.pathConfig);
            if (window.pathConfig) {
                console.log('Path config details:', {
                    environment: window.pathConfig.environment,
                    basePath: window.pathConfig.basePath,
                    isLocal: window.pathConfig.isLocal
                });
            }

            const apiPath = window.getAPIPath('list');
            console.log('Attempting to fetch from:', apiPath);

            const response = await fetch(apiPath);
            console.log('API response status:', response.status, response.statusText);

            if (!response.ok) {
                throw new Error(`API responded with status: ${response.status}`);
            }

            const responseData = await response.json();
            console.log('Instances loaded:', responseData);

            const tbody = document.querySelector('.report-table tbody');
            if (!tbody) {
                console.error('Could not find tbody element');
                reject(new Error('Could not find tbody element'));
                return;
            }

            tbody.innerHTML = ''; // Clear existing rows

            // Extract instances from standardized API response shape
            const instances = Array.isArray(responseData && responseData.data)
                ? responseData.data
                : [];

            if (instances.length === 0) {
                console.log('No instances found');
                const row = document.createElement('tr');
                const cell = document.createElement('td');
                cell.colSpan = 5;
                cell.textContent = 'No instances found';
                cell.className = 'table-empty-message';
                row.appendChild(cell);
                tbody.appendChild(row);
                resolve();
                return;
            }

            // Sort instances by lastModified timestamp (newest first)
            instances.sort((a, b) => {
                const aTime = a.metadata?.lastModified || a.timestamp;
                const bTime = b.metadata?.lastModified || b.timestamp;
                return bTime - aTime;
            });

            for (const instance of instances) {
                console.log('Processing instance:', instance);
                const row = document.createElement('tr');
                row.setAttribute('data-instance', instance.sessionKey);

                // Type cell - STRICT MODE: Use typeSlug only
                const typeCell = document.createElement('td');
                typeCell.className = 'admin-type-cell';
                const typeSlug = instance.typeSlug || 'unknown';
                // Use TypeManager for consistent formatting
                const formattedType = await TypeManager.formatDisplayName(typeSlug);
                typeCell.textContent = formattedType;

                // Created date cell
                const createdCell = document.createElement('td');
                createdCell.className = 'admin-date-cell';
                createdCell.textContent = formatDate(instance.timestamp);

                // Instance ID cell
                const instanceCell = document.createElement('td');
                instanceCell.className = 'admin-instance-cell';
                instanceCell.appendChild(createKeyLink(instance.sessionKey, typeSlug));

                // Updated date cell
                const updatedCell = document.createElement('td');
                updatedCell.className = 'admin-date-cell';
                // Only show updated timestamp if it exists (after first save)
                if (instance.metadata?.lastModified) {
                    updatedCell.textContent = formatDate(instance.metadata.lastModified);
                } else {
                    updatedCell.textContent = '—'; // Em dash for "not yet saved"
                }

                // Delete button cell
                const actionCell = document.createElement('td');
                actionCell.className = 'admin-action-cell';
                actionCell.appendChild(createDeleteButton(instance.sessionKey));

                // Append cells to row
                row.appendChild(typeCell);
                row.appendChild(createdCell);
                row.appendChild(instanceCell);
                row.appendChild(updatedCell);
                row.appendChild(actionCell);

                // Append row to table
                tbody.appendChild(row);
            }

            resolve();
        } catch (error) {
            console.error('Error loading instances:', error);
            reject(error);
        }
    });
}

// Function to initialize admin functionality
function initializeAdmin() {
    console.log('Initializing admin functionality');

    // Load instances when page loads
    loadInstances();

    // Refresh instances every 30 seconds
    setInterval(loadInstances, 30000);
}

// Initialize when the DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
    initializeAdmin();
});

// Legacy createTableRow function removed - replaced by inline row creation with TypeManager
