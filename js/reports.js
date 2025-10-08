/**
 * Reports Module
 * 
 * Manages the reports page functionality:
 * - Loading checklist data with full state
 * - Calculating checklist status based on statusButtons
 * - Filtering by status
 * - Rendering the reports table
 */

export class ReportsManager {
    constructor() {
        this.allChecklists = [];
        this.currentFilter = 'completed'; // Default filter
        this.filterButtons = null;
        this.tableBody = null;
    }

    /**
     * Initialize the reports manager
     */
    initialize() {
        console.log('Initializing ReportsManager');
        
        // Cache DOM elements
        this.tableBody = document.querySelector('.reports-table tbody');
        this.filterButtons = document.querySelectorAll('.filter-button');
        
        // Set up filter button event listeners
        this.filterButtons.forEach(button => {
            button.addEventListener('click', (e) => {
                this.handleFilterClick(e.currentTarget);
            });
        });

        // Load initial data
        this.loadChecklists();
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
        this.renderTable();
    }

    /**
     * Load all checklists from API
     */
    async loadChecklists() {
        console.log('Loading checklists from API');

        try {
            const apiPath = window.getAPIPath 
                ? window.getAPIPath('list-detailed')
                : '/php/api/list-detailed.php';
                
            console.log('Fetching from:', apiPath);

            const response = await fetch(apiPath);
            console.log('Response status:', response.status);

            if (!response.ok) {
                throw new Error(`API responded with status: ${response.status}`);
            }

            const responseData = await response.json();
            console.log('Checklists loaded:', responseData);

            // Extract instances from standardized API response shape
            const instances = Array.isArray(responseData && responseData.data)
                ? responseData.data
                : [];

            console.log('Extracted instances:', instances);

            // Process each checklist to add calculated status
            this.allChecklists = instances.map(checklist => ({
                ...checklist,
                calculatedStatus: this.calculateStatus(checklist.state?.statusButtons || {})
            }));

            // Update filter counts
            this.updateFilterCounts();

            // Render the table with current filter
            this.renderTable();

        } catch (error) {
            console.error('Error loading checklists:', error);
            this.showError('Failed to load checklists');
            
            if (this.tableBody) {
                this.tableBody.innerHTML = '<tr><td colspan="5" class="error-message">Error loading checklists</td></tr>';
            }
        }
    }

    /**
     * Calculate checklist status based on statusButtons
     * 
     * Logic:
     * - completed: All tasks are "completed"
     * - in-progress: At least one task is "completed" or "in_progress", but not all completed
     * - pending: All tasks are "pending"
     */
    calculateStatus(statusButtons) {
        if (!statusButtons || typeof statusButtons !== 'object') {
            return 'pending';
        }

        const statuses = Object.values(statusButtons);
        
        if (statuses.length === 0) {
            return 'pending';
        }

        const completedCount = statuses.filter(s => s === 'completed').length;
        const inProgressCount = statuses.filter(s => s === 'in_progress').length;
        const total = statuses.length;

        // All completed
        if (completedCount === total) {
            return 'completed';
        }

        // Some completed or in progress
        if (completedCount > 0 || inProgressCount > 0) {
            return 'in-progress';
        }

        // All pending
        return 'pending';
    }

    /**
     * Update filter count badges
     */
    updateFilterCounts() {
        const counts = {
            'completed': 0,
            'pending': 0,
            'in-progress': 0
        };

        this.allChecklists.forEach(checklist => {
            const status = checklist.calculatedStatus;
            if (counts.hasOwnProperty(status)) {
                counts[status]++;
            }
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
     * Render the table based on current filter
     */
    async renderTable() {
        if (!this.tableBody) {
            console.error('Table body not found');
            return;
        }

        // Filter checklists by current filter
        const filtered = this.allChecklists.filter(
            checklist => checklist.calculatedStatus === this.currentFilter
        );

        console.log(`Rendering ${filtered.length} checklists with filter: ${this.currentFilter}`);

        // Clear table
        this.tableBody.innerHTML = '';

        // Show empty state if no results
        if (filtered.length === 0) {
            const row = document.createElement('tr');
            const cell = document.createElement('td');
            cell.colSpan = 5;
            cell.textContent = `No ${this.currentFilter.replace('-', ' ')} checklists found`;
            cell.style.textAlign = 'center';
            cell.style.padding = '2rem';
            cell.style.color = '#6c757d';
            row.appendChild(cell);
            this.tableBody.appendChild(row);
            
            this.updateStatusMessage(`No ${this.currentFilter.replace('-', ' ')} checklists found`);
            return;
        }

        // Render each checklist
        for (const checklist of filtered) {
            const row = await this.createChecklistRow(checklist);
            this.tableBody.appendChild(row);
        }

        // Update status message
        const filterLabel = this.currentFilter.replace('-', ' ');
        this.updateStatusMessage(`Showing ${filtered.length} ${filterLabel} checklist${filtered.length !== 1 ? 's' : ''}`);
    }

    /**
     * Create a table row for a checklist
     */
    async createChecklistRow(checklist) {
        const row = document.createElement('tr');
        row.setAttribute('data-session-key', checklist.sessionKey);

        // Format type using TypeManager if available
        const typeSlug = checklist.typeSlug || 'unknown';
        let formattedType = typeSlug;
        
        if (window.TypeManager && typeof window.TypeManager.formatDisplayName === 'function') {
            formattedType = await window.TypeManager.formatDisplayName(typeSlug);
        } else {
            // Fallback: capitalize first letter
            formattedType = typeSlug.charAt(0).toUpperCase() + typeSlug.slice(1);
        }

        // Format dates
        const createdDate = checklist.metadata?.created || checklist.timestamp || checklist.created;
        const formattedDate = this.formatDate(createdDate);

        // Calculate progress
        const progress = this.calculateProgress(checklist.state?.statusButtons || {});

        // Build row HTML
        row.innerHTML = `
            <td>${this.escapeHtml(formattedType)}</td>
            <td>${this.escapeHtml(formattedDate)}</td>
            <td>${this.createInstanceLink(checklist.sessionKey, typeSlug)}</td>
            <td>${this.createStatusBadge(checklist.calculatedStatus)}</td>
            <td>${this.createProgressBar(progress.completed, progress.total, checklist.calculatedStatus)}</td>
        `;

        return row;
    }

    /**
     * Calculate progress (completed tasks / total tasks)
     */
    calculateProgress(statusButtons) {
        if (!statusButtons || typeof statusButtons !== 'object') {
            return { completed: 0, total: 0 };
        }

        const statuses = Object.values(statusButtons);
        const total = statuses.length;
        const completed = statuses.filter(s => s === 'completed').length;

        return { completed, total };
    }

    /**
     * Create instance link HTML
     */
    createInstanceLink(sessionKey, typeSlug) {
        const basePath = window.ENV?.basePath || '';
        const href = `${basePath}/?=${sessionKey}`;
        
        return `<a href="${this.escapeHtml(href)}" 
                   class="instance-link" 
                   target="_blank" 
                   rel="noopener noreferrer"
                   aria-label="Open checklist ${this.escapeHtml(sessionKey)} in new window">
                   ${this.escapeHtml(sessionKey)}
                </a>`;
    }

    /**
     * Create status badge HTML
     */
    createStatusBadge(status) {
        const labels = {
            'completed': 'Completed',
            'pending': 'Pending',
            'in-progress': 'In Progress'
        };

        const label = labels[status] || status;
        return `<span class="status-badge ${status}">${this.escapeHtml(label)}</span>`;
    }

    /**
     * Create progress bar HTML
     */
    createProgressBar(completed, total, status) {
        if (total === 0) {
            return '<span class="progress-text">—</span>';
        }

        const percentage = (completed / total) * 100;
        
        return `
            <div class="progress-container">
                <div class="progress-bar">
                    <div class="progress-fill ${status}" style="width: ${percentage}%"></div>
                </div>
                <span class="progress-text">${completed}/${total}</span>
            </div>
        `;
    }

    /**
     * Format date timestamp
     */
    formatDate(timestamp) {
        if (!timestamp) return '—';

        // Use existing date formatter if available
        if (window.formatDateAdmin && typeof window.formatDateAdmin === 'function') {
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

    /**
     * Update status message in footer
     */
    updateStatusMessage(message) {
        const statusContent = document.querySelector('.status-content');
        if (statusContent) {
            statusContent.textContent = message;
        }
    }

    /**
     * Show error message
     */
    showError(message) {
        this.updateStatusMessage(`Error: ${message}`);
        
        // Clear error after 5 seconds
        setTimeout(() => {
            const statusContent = document.querySelector('.status-content');
            if (statusContent && statusContent.textContent.startsWith('Error:')) {
                statusContent.textContent = '';
            }
        }, 5000);
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

// Export for use in reports.php
export default ReportsManager;
