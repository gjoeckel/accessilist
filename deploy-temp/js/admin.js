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
    // Show SimpleModal confirmation
    window.simpleModal.delete(
        'Delete Checklist',
        'Do you want to delete this list?',
        () => deleteKey(keyId),
        () => console.log('Delete cancelled')
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

            const tbody = document.querySelector('.admin-table tbody');
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
                cell.style.textAlign = 'center';
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

                // Type cell
                const typeCell = document.createElement('td');
                typeCell.className = 'admin-type-cell';
                const typeText = instance.metadata?.type || 'Unknown';
                // Use TypeManager for consistent formatting
                const formattedType = await TypeManager.formatDisplayName(typeText);
                typeCell.textContent = formattedType;

                // Created date cell
                const createdCell = document.createElement('td');
                createdCell.className = 'admin-date-cell';
                createdCell.textContent = formatDate(instance.timestamp);

                // Instance ID cell
                const instanceCell = document.createElement('td');
                instanceCell.className = 'admin-instance-cell';
                const typeSlug = (instance.metadata && instance.metadata.typeSlug)
                  ? instance.metadata.typeSlug
                  : ((instance.metadata && instance.metadata.type) ? instance.metadata.type.toLowerCase().replace(/\s+/g, '_') : '');
                instanceCell.appendChild(createInstanceLink(instance.sessionKey, typeSlug));

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

function createTableRow(instance) {
    const row = document.createElement('tr');
    row.className = 'admin-row';

    // Session Key cell
    const sessionCell = document.createElement('td');
    sessionCell.className = 'admin-session-cell';
    sessionCell.textContent = instance.sessionKey;
    row.appendChild(sessionCell);

    // Type cell
    const typeCell = document.createElement('td');
    typeCell.className = 'admin-type-cell';
    // Capitalize the first letter of the type
    typeCell.textContent = instance.metadata.type.charAt(0).toUpperCase() + instance.metadata.type.slice(1);
    row.appendChild(typeCell);

    // Version cell
    const versionCell = document.createElement('td');
    versionCell.className = 'admin-version-cell';
    versionCell.textContent = instance.metadata.version;
    row.appendChild(versionCell);

    // Last Modified cell
    const lastModifiedCell = document.createElement('td');
    lastModifiedCell.className = 'admin-last-modified-cell';
    lastModifiedCell.textContent = formatDate(instance.metadata.lastModified);
    row.appendChild(lastModifiedCell);

    // Actions cell
    const actionsCell = document.createElement('td');
    actionsCell.className = 'admin-actions-cell';

    // View button
    const viewButton = document.createElement('button');
    viewButton.className = 'admin-view-button';
    viewButton.setAttribute('aria-label', `View checklist ${instance.sessionKey}`);
    const viewImgPath = window.getImagePath('view.svg');
    viewButton.innerHTML = `<img src="${viewImgPath}" alt="">`;
    viewButton.onclick = () => {
        const phpPath = (typeof window.getPHPPath === 'function')
            ? window.getPHPPath('mychecklist.php')
            : '/php/mychecklist.php';
        window.location.href = `${phpPath}?session=${instance.sessionKey}`;
    };
    actionsCell.appendChild(viewButton);

    // Delete button
    const deleteButton = document.createElement('button');
    deleteButton.className = 'admin-delete-button';
    deleteButton.setAttribute('aria-label', `Delete checklist ${instance.sessionKey}`);
    const deleteImgPath = window.getImagePath('delete.svg');
    deleteButton.innerHTML = `<img src="${deleteImgPath}" alt="">`;
    deleteButton.onclick = () => deleteChecklist(instance.sessionKey);
    actionsCell.appendChild(deleteButton);

    row.appendChild(actionsCell);

    return row;
}
