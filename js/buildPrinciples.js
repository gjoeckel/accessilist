/**
 * buildPrinciples.js
 *
 * This script is responsible for:
 * 1. Fetching the JSON data
 * 2. Generating principle sections dynamically
 * 3. Building tables for each principle
 */

// buildReportsSection import removed - reports now handled on separate page

// Old modal HTML removed - now using SimpleModal system

// Table configuration
const TABLE_CONFIG = {
    headers: [
        { text: 'Tasks', class: 'task-cell' },
        { text: 'Info', class: 'info-cell' },
        { text: 'Notes', class: 'notes-cell' },
        { text: 'Status', class: 'status-cell' }
    ]
};

// State management functions
function saveState(id, state) {
    const currentState = getState() || {};
    currentState[id] = state;
    sessionStorage.setItem('checklistState', JSON.stringify(currentState));
}

function getState() {
    const state = sessionStorage.getItem('checklistState');
    return state ? JSON.parse(state) : null;
}

// Function to create a principle section
function createPrincipleSection(principleId, data) {
    const section = document.createElement('section');
    section.id = principleId;
    section.className = `principle-section ${principleId}`;

    // Create simplified heading with number icon
    const heading = document.createElement('h2');
    heading.id = `${principleId}-caption`;
    heading.className = 'checklist-caption';

    // Extract checkpoint/checklist number dynamically (supports checkpoint-N or checklist-N)
    const match = principleId.match(/(?:checkpoint|checklist)-(\d+)/);
    const tableNumber = match ? match[1] : null;

    if (!tableNumber) {
        console.warn(`Unknown principle ID format: ${principleId}`);
    }

    // Only set aria-label if we have a valid table number
    if (tableNumber) {
        heading.setAttribute('aria-label', `Table ${tableNumber}: ${data.caption}`);
    } else {
        heading.setAttribute('aria-label', data.caption);
    }

    // Make the heading focusable for keyboard users
    heading.setAttribute('tabindex', '0');

    // Add data attribute for CSS-generated number (replaces SVG icon)
    if (tableNumber) {
        heading.setAttribute('data-number', tableNumber);
    }

    // Add caption text directly to heading
    const captionText = document.createTextNode(` ${data.caption}`);
    heading.appendChild(captionText);

    section.appendChild(heading);

    // Create container
    const container = document.createElement('div');
    container.className = 'guidelines-container';
    section.appendChild(container);

    return section;
}

// Function to build table
function buildTable(rows, principleId) {
    const table = document.createElement('table');
    table.className = 'principles-table';
    table.setAttribute('role', 'table');
    table.setAttribute('aria-label', 'Principles Checklist');
    // Associate table with its heading as a pseudo-caption
    table.setAttribute('aria-labelledby', `${principleId}-caption`);

    // Create table header
    const thead = document.createElement('thead');
    const headerRow = document.createElement('tr');

    const taskHeader = document.createElement('th');
    taskHeader.className = 'task-cell';
    taskHeader.textContent = 'Tasks';

    const infoHeader = document.createElement('th');
    infoHeader.className = 'info-cell';
    infoHeader.textContent = 'Info';

    const notesHeader = document.createElement('th');
    notesHeader.className = 'notes-cell';
    notesHeader.textContent = 'Notes';

    const statusHeader = document.createElement('th');
    statusHeader.className = 'status-cell';
    statusHeader.textContent = 'Status';

    const restartHeader = document.createElement('th');
    restartHeader.className = 'restart-cell';
    restartHeader.textContent = 'Reset';

    headerRow.appendChild(taskHeader);
    headerRow.appendChild(infoHeader);
    headerRow.appendChild(notesHeader);
    headerRow.appendChild(statusHeader);
    headerRow.appendChild(restartHeader);
    thead.appendChild(headerRow);
    table.appendChild(thead);

    // Create table body
    const tbody = document.createElement('tbody');
    tbody.setAttribute('role', 'rowgroup');

    // Add rows for each principle
    rows.forEach(row => {
        const tr = document.createElement('tr');
        tr.setAttribute('role', 'row');
        tr.setAttribute('data-id', row.id);
        tr.className = 'principle-row';
        tbody.appendChild(tr);

        // Add cells in correct order
        const cells = [
            { text: row.task, className: 'task-cell' },
            { className: 'info-cell' },
            { className: 'notes-cell' },
            { className: 'status-cell' },
            { className: 'restart-cell' }
        ];

        cells.forEach(cell => {
            const td = document.createElement('td');
            td.className = cell.className;
            td.setAttribute('role', 'cell');
            tr.appendChild(td);

            if (cell.text) {
                td.textContent = cell.text;
            }
        });

        // Add info links to info cell
        const infoCell = tr.querySelector('.info-cell');
        const infoButton = document.createElement('button');
        infoButton.className = 'info-link';
        infoButton.setAttribute('aria-label', `Show example for ${row.task}`);

        const infoImg = document.createElement('img');
        infoImg.src = window.getImagePath('info-.svg');
        infoImg.alt = '';
        infoButton.appendChild(infoImg);

        // Add click handler for modal using SimpleModal
        infoButton.addEventListener('click', () => {
            // Truncate title at last complete word within character limit
            const maxLength = 50; // Adjust this value as needed
            const words = row.task.split(' ');
            let truncatedTitle = '';

            for (const word of words) {
                if ((truncatedTitle + ' ' + word).length <= maxLength) {
                    truncatedTitle += (truncatedTitle ? ' ' : '') + word;
                } else {
                    break;
                }
            }

            // Use SimpleModal for info display
            if (window.simpleModal) {
                window.simpleModal.info(
                    truncatedTitle,
                    row.example || 'No example available.',
                    () => console.log('Info modal closed')
                );
            } else {
                console.error('SimpleModal not available');
            }
        });

        infoCell.appendChild(infoButton);

        // Add notes textarea
        const notesCell = tr.querySelector('.notes-cell');
        const textarea = document.createElement('textarea');
        textarea.className = 'notes-textarea';
        textarea.setAttribute('aria-label', `Notes for ${row.task}`);
        textarea.id = `textarea-${row.id}`;
        notesCell.appendChild(textarea);

        // Add status button
        const statusCell = tr.querySelector('.status-cell');
        const statusButton = document.createElement('button');
        statusButton.className = 'status-button';
        statusButton.setAttribute('data-state', 'pending');
        statusButton.setAttribute('aria-label', 'Task status: Ready');
        statusButton.setAttribute('data-id', row.id);
        statusButton.id = `status-${row.id}`;
        const pendingImgPath = window.getImagePath('ready-1.svg');
        statusButton.innerHTML = `<img src="${pendingImgPath}" alt="">`;
        statusCell.appendChild(statusButton);

        // Add restart button
        const restartCell = tr.querySelector('.restart-cell');
        const restartButton = document.createElement('button');
        restartButton.className = 'restart-button';
        restartButton.type = 'button';
        restartButton.setAttribute('aria-label', 'Reset task to Ready');
        restartButton.setAttribute('data-id', row.id);
        restartButton.id = `restart-${row.id}`;
        const restartImgPath = window.getImagePath('reset.svg');
        restartButton.innerHTML = `<img src="${restartImgPath}" alt="Reset task">`;
        restartButton.classList.add('restart-hidden'); // Initially hidden
        restartCell.appendChild(restartButton);

        // Event handlers removed - now handled by StateEvents.js global event delegation
        // Status button clicks, textarea input, and reset button clicks are managed centrally
    });

    table.appendChild(tbody);

    // Create Add Row button container
    const buttonContainer = document.createElement('div');
    buttonContainer.className = 'principles-buttons';

    // Create Add Row button
    const addButton = document.createElement('button');
    addButton.className = 'principles-button';
    addButton.id = `addRow-${principleId}`;
    addButton.setAttribute('data-principle', principleId);
    addButton.setAttribute('aria-label', `Add new task to ${principleId}`);

    // CSS-generated plus icon (no SVG needed)

    // Add button to container
    buttonContainer.appendChild(addButton);

    // Event listener will be attached by initializePrincipleAddRowButtons() in addRow.js
    // This ensures proper initialization timing and prevents duplicate event listeners

    // Create wrapper div to contain both table and button
    const wrapper = document.createElement('div');
    wrapper.className = 'principles-table-wrapper';
    wrapper.appendChild(table);
    wrapper.appendChild(buttonContainer);

    return wrapper;
}

/**
 * Handles adding a new row to a principles table
 * @param {string} principleId - The ID of the principle (e.g., 'checklist-1')
 */
function handleAddPrincipleRow(principleId) {
    console.log(`Adding new row to ${principleId}`);

    if (!window.unifiedStateManager) {
        console.error('StateManager not available - cannot add principle row');
        return;
    }

    // Use StateManager method for consistent data creation
    const newRowData = window.unifiedStateManager.createPrincipleRowData({
        principleId: principleId,
        task: '',
        notes: '',
        status: 'pending',
        isManual: true
    });

    // Add using StateManager method
    window.unifiedStateManager.addPrincipleRow(newRowData, true);

    // Schedule buffer update (row changes content height)
    if (typeof window.scheduleBufferUpdate === 'function') {
        window.scheduleBufferUpdate();
    }

    // Set focus on the task textarea for manual rows - reduced timeout to prevent race conditions
    setTimeout(() => {
        const currentTable = document.querySelector(`#${principleId} .principles-table tbody`);
        if (currentTable) {
            const newRow = currentTable.querySelector(`tr[data-id="${newRowData.id}"]`);
            if (newRow) {
                const taskTextarea = newRow.querySelector('.task-input');
                if (taskTextarea) {
                    taskTextarea.focus();
                }
            }
        }
    }, 50); // Reduced from 100ms to 50ms
}

// Make function globally available
window.handleAddPrincipleRow = handleAddPrincipleRow;

// createReportSection function removed - reports now handled on separate page

// storeCompletedTask function removed - now handled by StateEvents.js

// Function to build all content
async function buildContent(data) {
    console.log('Starting to build content');
    try {
        console.log('Building content with data:', data);

        const main = document.querySelector('main');
        if (!main) {
            throw new Error('Main element not found');
        }
        console.log('Found main element:', main);

        // Clear existing content
        console.log('Clearing existing content');
        main.innerHTML = '';

        // Create checkpoint sections dynamically (supports checkpoint-1 through checkpoint-10)
        console.log('Creating checkpoint sections');

        // Filter and sort checkpoint keys
        const checkpointKeys = Object.keys(data)
            .filter(key => key.startsWith('checkpoint-') || key.startsWith('checklist-')) // Support both new and legacy
            .sort((a, b) => {
                const numA = parseInt(a.split('-')[1]);
                const numB = parseInt(b.split('-')[1]);
                return numA - numB;
            });

        console.log(`Found ${checkpointKeys.length} checkpoints:`, checkpointKeys);

        checkpointKeys.forEach(checkpointKey => {
            const checkpointData = data[checkpointKey];

            console.log(`Creating section for checkpoint: ${checkpointKey}`);
            const section = createPrincipleSection(checkpointKey, checkpointData);
            if (section) {
                console.log(`Building table for checkpoint: ${checkpointKey}`);
                const tableWrapper = buildTable(checkpointData.table, checkpointKey);
                section.querySelector('.guidelines-container').appendChild(tableWrapper);
                main.appendChild(section);
                console.log(`Section for ${checkpointKey} added to main`);
            }
        });

        // Add Report section (consistent across all checklist types)
        // TEMPORARILY COMMENTED OUT - Report functionality is interfering with principle rows
        // console.log('Adding Report section');
        // const reportSection = createReportSection();
        // main.appendChild(reportSection);
        // console.log('Report section added to main');

        // Dispatch event to signal content is built
        console.log('Content built, dispatching contentBuilt event');
        const contentBuiltEvent = new CustomEvent('contentBuilt');
        document.dispatchEvent(contentBuiltEvent);
        console.log('contentBuilt event dispatched');

    } catch (error) {
        console.error('Error building content:', error);
        throw error; // Re-throw to be caught by initializeApp
    }
}

// Export the function
export { buildContent };
