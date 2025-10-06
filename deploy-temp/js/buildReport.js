// Function to build the reports section
function buildReportsSection(data) {
    console.log('[buildReport.js] buildReportsSection called');
    // Create the section element
    const section = document.createElement('section');
    section.className = 'report-section';
    section.id = 'report';
    console.log('[buildReport.js] Section element created');

    // Create the container div
    const container = document.createElement('div');
    container.className = 'report-container';
    container.setAttribute('role', 'region');
    container.setAttribute('aria-label', 'Report section');
    console.log('[buildReport.js] Container div created');

    // Create and style the h2 element
    const reportsHeading = document.createElement('h2');
    reportsHeading.id = 'report-caption';
    reportsHeading.textContent = data.caption || 'Report';
    reportsHeading.setAttribute('tabindex', '-1');
    console.log('[buildReport.js] Heading created');

    // Create the table
    const reportsTable = document.createElement('table');
    reportsTable.className = 'report-table';
    reportsTable.setAttribute('aria-labelledby', 'report-caption');
    console.log('[buildReport.js] Table created');

    // Create the table header
    const thead = document.createElement('thead');
    const headerRow = document.createElement('tr');

    // Create header cells with specified widths and classes
    const dateHeader = document.createElement('th');
    dateHeader.className = 'report-date-cell';
    dateHeader.setAttribute('scope', 'col');
    dateHeader.textContent = 'Date';

    const taskHeader = document.createElement('th');
    taskHeader.className = 'report-task-cell';
    taskHeader.setAttribute('scope', 'col');
    taskHeader.textContent = 'Tasks';

    const notesHeader = document.createElement('th');
    notesHeader.className = 'report-notes-cell';
    notesHeader.setAttribute('scope', 'col');
    notesHeader.textContent = 'Notes';

    const statusHeader = document.createElement('th');
    statusHeader.className = 'report-status-cell';
    statusHeader.setAttribute('scope', 'col');
    statusHeader.textContent = 'Status';

    const deleteHeader = document.createElement('th');
    deleteHeader.className = 'report-delete-cell';
    deleteHeader.setAttribute('scope', 'col');
    deleteHeader.textContent = 'Delete';

    // Append headers to the row
    headerRow.appendChild(dateHeader);
    headerRow.appendChild(taskHeader);
    headerRow.appendChild(notesHeader);
    headerRow.appendChild(statusHeader);
    headerRow.appendChild(deleteHeader);
    thead.appendChild(headerRow);
    reportsTable.appendChild(thead);
    console.log('[buildReport.js] Table header appended');

    // Create the table body
    const tbody = document.createElement('tbody');
    reportsTable.appendChild(tbody);
    console.log('[buildReport.js] Table body appended');

    // Assemble the container
    container.appendChild(reportsHeading);
    container.appendChild(reportsTable);
    section.appendChild(container);
    console.log('[buildReport.js] Section fully assembled and appended to DOM');

    // Initial render of the table from state
    setTimeout(() => { if (window.renderReportTable) window.renderReportTable(); }, 0);

    // REMOVED: taskCompleted event listener - now handled directly by StateManager.addReportRow()
    // Event-based architecture replaced with direct StateManager calls in StateEvents.js
    // This eliminates event coupling and provides clearer data flow

    return section;
}

// Export the function
export { buildReportsSection }; 