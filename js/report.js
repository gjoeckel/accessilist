/**
 * User Report Module
 *
 * Manages the user-specific checklist report functionality:
 * - Loading single checklist instance data
 * - Fetching principle structure from type JSON
 * - Rendering tasks grouped by principle
 * - Displaying notes, status, and update timestamps
 */

export class UserReportManager {
    constructor(sessionKey) {
        this.sessionKey = sessionKey;
        this.checklistData = null;
        this.principlesData = null;
        this.typeSlug = null;
        this.tableBody = null;
        this.currentFilter = 'all'; // Default filter
        this.filterButtons = null;
        this.allRows = []; // Store all rows for filtering
    }

    /**
     * Initialize the report manager
     */
    async initialize() {
        console.log('Initializing UserReportManager for session:', this.sessionKey);

        // Cache DOM elements
        this.tableBody = document.querySelector('.report-table tbody');
        this.filterButtons = document.querySelectorAll('.filter-button');

        // Set up filter button event listeners
        this.filterButtons.forEach(button => {
            button.addEventListener('click', (e) => {
                this.handleFilterClick(e.currentTarget);
            });
        });

        try {
            // 1. Load checklist data
            await this.loadChecklistData();

            // 2. Load principles structure
            await this.loadPrinciplesStructure();

            // 3. Update title
            await this.updateTitle();

            // 4. Render table
            this.renderTable();

        } catch (error) {
            console.error('Error initializing report:', error);
            this.showError('Failed to load report data');
        }
    }

    /**
     * Handle filter button click
     */
    handleFilterClick(button) {
        const filter = button.getAttribute('data-filter');

        // Update active state
        this.filterButtons.forEach(btn => {
            btn.classList.remove('active');
            btn.setAttribute('aria-pressed', 'false');
        });

        button.classList.add('active');
        button.setAttribute('aria-pressed', 'true');

        // Update current filter and re-render
        this.currentFilter = filter;
        this.applyFilter();
    }

    /**
     * Load checklist data from API
     */
    async loadChecklistData() {
        console.log('Loading checklist data for session:', this.sessionKey);

        const apiPath = window.getAPIPath
            ? window.getAPIPath('restore')
            : '/php/api/restore.php';

        const response = await fetch(`${apiPath}?sessionKey=${this.sessionKey}`);

        if (!response.ok) {
            throw new Error(`API responded with status: ${response.status}`);
        }

        const result = await response.json();
        console.log('Checklist data loaded:', result);

        if (!result.success || !result.data) {
            throw new Error('Invalid API response');
        }

        this.checklistData = result.data;
        this.typeSlug = this.checklistData.typeSlug;
    }

    /**
     * Load principles structure from type JSON
     */
    async loadPrinciplesStructure() {
        console.log('Loading principles structure for type:', this.typeSlug);

        // Get JSON filename for this type
        const jsonFile = await window.TypeManager.getJsonFileName(this.typeSlug);
        console.log('Loading principles from file:', jsonFile);

        const jsonPath = window.getJSONPath
            ? window.getJSONPath(jsonFile)
            : `/json/${jsonFile}`;

        const response = await fetch(jsonPath);

        if (!response.ok) {
            throw new Error(`Failed to load ${jsonFile}: ${response.status}`);
        }

        const rawData = await response.json();
        console.log('Raw checklist data loaded:', rawData);

        // Convert checklist-N structure to principles array
        this.principlesData = this.convertToPrinciples(rawData);
        console.log('Converted principles data:', this.principlesData);
    }

    /**
     * Convert checklist JSON structure to principles array
     * JSON format: { "checkpoint-1": { caption, table }, "checkpoint-2": {...}, ... }
     * Output: { principles: [{ id, title, rows }, ...] }
     */
    convertToPrinciples(checklistData) {
        const principles = [];

        // Find all checklist-N keys
        Object.keys(checklistData).forEach(key => {
            if (key.startsWith('checklist-')) {
                const checklistNum = key.split('-')[1];
                const checklist = checklistData[key];

                if (checklist && checklist.table) {
                    principles.push({
                        id: key,
                        title: checklist.caption || `Principle ${checklistNum}`,
                        rows: checklist.table || []
                    });
                }
            }
        });

        return { principles };
    }

    /**
     * Update page title and subtitle
     */
    async updateTitle() {
        const displayName = await window.TypeManager.formatDisplayName(this.typeSlug);
        const titleElement = document.getElementById('report-title');
        const subtitleElement = document.getElementById('report-subtitle');
        const typeNameElement = document.getElementById('report-type-name');

        // Update "My [Type] Checklist" header
        if (titleElement) {
            titleElement.textContent = `My ${displayName} Checklist`;
        }

        // Update type name in h2
        if (typeNameElement) {
            typeNameElement.textContent = `${displayName} Checklist`;
        }

        // Update subtitle with last saved timestamp
        if (subtitleElement) {
            const lastModified = this.checklistData.metadata?.lastModified;
            if (lastModified) {
                const formatted = window.formatDateAdmin
                    ? window.formatDateAdmin(lastModified)
                    : new Date(lastModified).toLocaleString();
                subtitleElement.textContent = `Last saved: ${formatted}`;
            } else {
                subtitleElement.textContent = 'Not yet saved';
            }
        }
    }

    /**
     * Render the complete report in ONE table (matches reports.php structure)
     */
    renderTable() {
        const tbody = document.querySelector('.report-table tbody');

        if (!tbody) {
            console.error('Table body not found');
            return;
        }

        tbody.innerHTML = '';
        this.allRows = []; // Reset rows array

        // Group tasks by principle
        const grouped = this.groupTasksByPrinciple();
        console.log('Grouped principles:', grouped.length, grouped);

        // Check if we have any data
        if (grouped.length === 0) {
            tbody.innerHTML = '<tr><td colspan="4" class="empty-state">No tasks found in this checklist</td></tr>';
            return;
        }

        // Render all tasks in ONE table and store rows with status
        grouped.forEach(section => {
            console.log(`Adding tasks from: ${section.title}, count: ${section.tasks.length}`);

            // Add all task rows from this section
            section.tasks.forEach(task => {
                const taskRow = this.createTaskRow(task, section.id);
                tbody.appendChild(taskRow);

                // Store row with its status for filtering
                this.allRows.push({
                    row: taskRow,
                    status: task.status
                });
            });
        });

        console.log('Report rendered successfully');

        // Update filter counts
        this.updateFilterCounts();

        // Apply initial filter
        this.applyFilter();
    }

    /**
     * Update filter count badges
     */
    updateFilterCounts() {
        const counts = {
            'completed': 0,
            'pending': 0,
            'in-progress': 0,
            'all': 0
        };

        this.allRows.forEach(item => {
            const status = item.status;
            if (counts.hasOwnProperty(status)) {
                counts[status]++;
            } else if (status === 'in_progress') {
                counts['in-progress']++;
            }
            counts['all']++; // Count all tasks
        });

        // Update count badges
        Object.keys(counts).forEach(status => {
            const countElement = document.getElementById(`count-${status}`);
            if (countElement) {
                countElement.textContent = counts[status];
            }
        });
    }

    /**
     * Apply current filter to table rows
     */
    applyFilter() {
        if (this.allRows.length === 0) return;

        let visibleCount = 0;

        this.allRows.forEach(item => {
            const status = item.status === 'in_progress' ? 'in-progress' : item.status;

            // Show all rows if filter is 'all', otherwise filter by status
            if (this.currentFilter === 'all' || this.currentFilter === status) {
                item.row.style.display = '';
                visibleCount++;
            } else {
                item.row.style.display = 'none';
            }
        });

        console.log(`Filter applied: ${this.currentFilter}, visible rows: ${visibleCount}`);
    }

    /**
     * Group tasks by principle from JSON structure
     */
    groupTasksByPrinciple() {
        const grouped = [];
        const savedState = this.checklistData.state || {};

        // Handle empty or missing principles data
        if (!this.principlesData || !this.principlesData.principles) {
            console.warn('No principles data available');
            return grouped;
        }

        this.principlesData.principles.forEach(principle => {
            const section = {
                id: principle.id,
                title: principle.title,
                tasks: []
            };

            // Add default tasks from principle rows
            principle.rows.forEach(row => {
                const taskId = row.id; // e.g., "1.1", "1.2"

                section.tasks.push({
                    id: taskId,
                    task: row.task,
                    notes: this.getTaskNotes(taskId, savedState),
                    status: this.getTaskStatus(taskId, savedState),
                    isManual: false
                });
            });

            // TODO: Add manual tasks from principleRows
            // Will implement in Phase 2 when we have manual row examples

            grouped.push(section);
        });

        return grouped;
    }

    /**
     * Get task status from saved state
     */
    getTaskStatus(taskId, savedState) {
        const statusKey = `status-${taskId}`;
        return savedState.statusButtons?.[statusKey] || 'pending';
    }

    /**
     * Get task notes from saved state
     * Handles both "textarea-X.X" and "notes_X.X" key formats
     */
    getTaskNotes(taskId, savedState) {
        if (!savedState.notes) return '';

        // Try both key formats (data format has changed over time)
        const textareaKey = `textarea-${taskId}`;
        const notesKey = `notes_${taskId}`;

        return savedState.notes[textareaKey] || savedState.notes[notesKey] || '';
    }

    /**
     * Create principle section (matches mychecklist.php structure exactly)
     */
    createPrincipleSection(section) {
        // Create section element
        const sectionEl = document.createElement('section');
        sectionEl.id = section.id;
        sectionEl.className = `principle-section ${section.id}`;

        // Create h2 caption (without number icon for report view)
        const h2 = document.createElement('h2');
        h2.id = `${section.id}-caption`;
        h2.className = 'checklist-caption';
        h2.setAttribute('aria-label', section.title);
        h2.setAttribute('tabindex', '0');
        h2.textContent = section.title;
        sectionEl.appendChild(h2);

        // Create guidelines container
        const guidelinesContainer = document.createElement('div');
        guidelinesContainer.className = 'guidelines-container';

        // Create table wrapper
        const tableWrapper = document.createElement('div');
        tableWrapper.className = 'principles-table-wrapper';

        // Create table
        const table = document.createElement('table');
        table.className = 'principles-table';
        table.setAttribute('role', 'table');
        table.setAttribute('aria-label', 'Principles Checklist');
        table.setAttribute('aria-labelledby', `${section.id}-caption`);

        // Create thead
        const thead = document.createElement('thead');
        thead.innerHTML = `
            <tr>
                <th class="task-cell">Tasks</th>
                <th class="notes-cell">Notes</th>
                <th class="status-cell">Status</th>
                <th class="updated-cell">Updated</th>
            </tr>
        `;
        table.appendChild(thead);

        // Create tbody
        const tbody = document.createElement('tbody');
        tbody.setAttribute('role', 'rowgroup');

        // Add task rows
        section.tasks.forEach(task => {
            const taskRow = this.createTaskRow(task);
            tbody.appendChild(taskRow);
        });

        table.appendChild(tbody);
        tableWrapper.appendChild(table);
        guidelinesContainer.appendChild(tableWrapper);
        sectionEl.appendChild(guidelinesContainer);

        return sectionEl;
    }

    /**
     * Create task row with 5 columns: Checkpoint | Tasks | Notes | Status | Updated
     */
    createTaskRow(task, principleId) {
        const row = document.createElement('tr');
        row.setAttribute('role', 'row');
        row.setAttribute('data-id', task.id);
        row.className = 'principle-row';

        // Extract checkpoint number from principle ID (checkpoint-1 → 1 or checklist-1 → 1)
        const match = principleId.match(/(?:checkpoint|checklist)-(\d+)/);
        const checkpointNum = match ? match[1] : '0';

        // 1. Checkpoint cell with number icon
        const checkpointCell = document.createElement('td');
        checkpointCell.className = 'checkpoint-cell';
        checkpointCell.setAttribute('role', 'cell');

        const checkpointIcon = document.createElement('img');
        checkpointIcon.src = window.getImagePath
            ? window.getImagePath(`number-${checkpointNum}-0.svg`)
            : `/images/number-${checkpointNum}-0.svg`;
        checkpointIcon.alt = checkpointNum;
        checkpointIcon.width = 36;
        checkpointIcon.height = 36;
        checkpointCell.appendChild(checkpointIcon);
        row.appendChild(checkpointCell);

        // 2. Task cell with textarea (read-only, matches mychecklist.php disabled style)
        const taskCell = document.createElement('td');
        taskCell.className = 'task-cell';
        taskCell.setAttribute('role', 'cell');

        const taskTextarea = document.createElement('textarea');
        taskTextarea.className = 'notes-textarea';
        taskTextarea.value = task.task;
        taskTextarea.disabled = true;
        taskTextarea.setAttribute('aria-hidden', 'true');
        taskTextarea.setAttribute('tabindex', '-1');
        taskTextarea.style.border = 'none';
        taskTextarea.style.backgroundColor = 'transparent';
        taskTextarea.style.color = '#666';
        taskTextarea.style.resize = 'none';
        taskTextarea.style.pointerEvents = 'none';
        taskCell.appendChild(taskTextarea);
        row.appendChild(taskCell);

        // 3. Notes cell with textarea (read-only, matches mychecklist.php disabled style)
        const notesCell = document.createElement('td');
        notesCell.className = 'notes-cell';
        notesCell.setAttribute('role', 'cell');

        const notesTextarea = document.createElement('textarea');
        notesTextarea.className = 'notes-textarea';
        notesTextarea.value = task.notes || '';
        notesTextarea.disabled = true;
        notesTextarea.setAttribute('aria-hidden', 'true');
        notesTextarea.setAttribute('tabindex', '-1');
        notesTextarea.style.border = 'none';
        notesTextarea.style.backgroundColor = 'transparent';
        notesTextarea.style.color = '#666';
        notesTextarea.style.resize = 'none';
        notesTextarea.style.pointerEvents = 'none';
        notesCell.appendChild(notesTextarea);
        row.appendChild(notesCell);

        // 4. Status cell with button (matches mychecklist.php exactly)
        const statusCell = document.createElement('td');
        statusCell.className = 'status-cell';
        statusCell.setAttribute('role', 'cell');
        const statusButton = this.createStatusButton(task.status, task.id);
        statusCell.appendChild(statusButton);
        row.appendChild(statusCell);

        return row;
    }

    /**
     * Create status icon (non-interactive, just displays status)
     */
    createStatusButton(status, taskId) {
        // Use img instead of button for read-only report view
        const img = document.createElement('img');
        const iconPath = window.getImagePath
            ? window.getImagePath(`${status}.svg`)
            : `/images/${status}.svg`;

        img.src = iconPath;
        img.alt = this.formatStatusLabel(status);
        img.className = 'status-icon';
        img.width = 75;
        img.height = 75;
        img.style.display = 'block';
        img.style.margin = '0 auto';

        return img;
    }

    /**
     * Format status label for aria-label
     */
    formatStatusLabel(status) {
        const labels = {
            'pending': 'Pending',
            'in-progress': 'In Progress',
            'in_progress': 'In Progress',
            'completed': 'Completed'
        };
        return labels[status] || status;
    }

    /**
     * Show error message
     */
    showError(message) {
        const titleElement = document.getElementById('report-title');
        const subtitleElement = document.getElementById('report-subtitle');

        if (titleElement) {
            titleElement.textContent = 'Error';
        }

        if (subtitleElement) {
            subtitleElement.textContent = message;
            subtitleElement.style.color = '#d32f2f';
        }

        // Show error in table
        const tbody = document.querySelector('.report-table tbody');
        if (tbody) {
            tbody.innerHTML = `<tr><td colspan="4" class="empty-state">${this.escapeHtml(message)}</td></tr>`;
        }
    }

    /**
     * Escape HTML to prevent XSS
     */
    escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }
}

// Export for use in report.php
export default UserReportManager;

