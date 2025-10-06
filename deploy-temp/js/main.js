/**
 * main.js
 *
 * This script is responsible for:
 * 1. Initializing the application
 * 2. Setting up event listeners for principle selection buttons
 * 3. Handling principle switching
 * 4. Coordinating functionality from other modules
 */

import { buildContent } from './buildPrinciples.js';
// buildReportsSection import removed - reports now handled on separate page
import { initializePrincipleAddRowButtons } from './addRow.js';

// --- Legacy Focus Management Helpers - DEPRECATED ---
// These functions are deprecated in favor of SimpleModal
// Keeping for backward compatibility but they should not be used
// Legacy focus management functions removed - using SimpleModal system

// Side panel functions removed - now handled by StateEvents.js
// Legacy functions kept for backward compatibility

function handleSidePanelToggle(event) {
    console.warn('handleSidePanelToggle called - this is now handled by StateEvents.js');
}

function handlePrincipleSelection(event) {
    console.warn('handlePrincipleSelection called - this is now handled by StateEvents.js');
}

// Function to handle report row delete button clicks
// Already expects the button as an argument
function handleDeleteReportRowClick(event) {
    const button = event.currentTarget;
    const row = button.closest('.report-row');
    if (!row) return;

    // Remove the row from the table
    row.remove();

    // Trigger save after deleting row
    if (window.saveRestoreOrchestrator) {
        window.saveRestoreOrchestrator.saveState().catch(error => {
            console.error('Failed to save state after deleting row:', error);
        });
    }
}

// Function to handle delete row button
function handleDeleteRow(event) {
    event.preventDefault();
    const manualRows = document.querySelectorAll('.report-table tbody tr.manual');
    if (manualRows.length > 0) {
        // Remove the last manual row
        manualRows[manualRows.length - 1].remove();

        // Set focus to the Report link in the side panel
        const reportLink = document.querySelector('.side-panel a[href="#report"]');
        if (reportLink) {
            reportLink.focus();
        }
    }
}

// Function to handle task completion
function handleTaskCompletion(event) {
    const button = event.currentTarget;
    const row = button.closest('.report-row');
    if (!row) return;

    const statusSelect = row.querySelector('.report-status');
    if (!statusSelect) return;

    const currentStatus = statusSelect.value;
    const statuses = ['Not Started', 'In Progress', 'Completed'];
    const currentIndex = statuses.indexOf(currentStatus);
    const nextIndex = (currentIndex + 1) % statuses.length;
    statusSelect.value = statuses[nextIndex];
}

// --- Debounced Save Helper ---
// Note: debouncedSaveContent is now defined in save-restore.js using the debounce utility

// Function to get checklist type using TypeManager
async function getChecklistType() {
    try {
        const type = await TypeManager.getTypeFromSources();
        console.log('Checklist type from TypeManager:', type);
        return type;
    } catch (error) {
        console.warn('Error getting checklist type, using fallback:', error);
        return 'camtasia';
    }
}

// === REPORT TABLE EVENT DELEGATION ===
// Note: Event delegation now handled by StateEvents.js
// This function remains for backward compatibility but is no longer needed

function setupReportTableEventDelegation() {
    console.log('Report table event delegation now handled by StateEvents.js - skipping local setup');
    // Event listeners removed - handled globally by StateEvents.js
}

// Report table state removed - reports now handled on separate page

// Report table rendering removed - reports now handled on separate page

// Function to initialize the application
async function initializeApp() {
    const checklistType = await getChecklistType();

    try {
        // Fetch the appropriate JSON data
        const jsonPath = window.getJSONPath(`${checklistType}.json`);
        const response = await fetch(jsonPath);
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        const data = await response.json();

        // Make checklist data globally available
        window.checklistData = data;

        // Update document title and header
        document.title = `${data.type} Accessibility Checklist`;
        const header = document.querySelector('.sticky-header h1');
        if (header) {
            header.textContent = `${data.type} Accessibility Checklist`;
        }

        // Handle Checklist-4 section visibility
        const checklist4Section = document.getElementById('checklist-4-section');
        if (checklist4Section) {
            const isVisible = data.showRobust;
            checklist4Section.style.display = isVisible ? 'block' : 'none';
            checklist4Section.setAttribute('aria-hidden', (!isVisible).toString());

            // Announce visibility change to screen readers
            if (isVisible) {
                const announcement = document.createElement('div');
                announcement.setAttribute('role', 'status');
                announcement.setAttribute('aria-live', 'polite');
                announcement.className = 'sr-only';
                announcement.textContent = 'Checkpoint 4 table is now available';
                document.body.appendChild(announcement);
                // Remove announcement after it's been read
                setTimeout(() => announcement.remove(), 1000);
            }
        }

        // Build content with the fetched data
        await buildContent(data);

        // Setup Report table event delegation for status buttons and textareas
        setupReportTableEventDelegation();

        // Initialize other functionality
        if (typeof initializeChecklist === 'function') initializeChecklist();
        if (typeof initializeReport === 'function') initializeReport();
        if (typeof initializeSaveRestore === 'function') initializeSaveRestore();
        if (typeof initializePrint === 'function') initializePrint();
        if (typeof initializeKeyboardNavigation === 'function') initializeKeyboardNavigation();
        if (typeof initializeAccessibilityFeatures === 'function') initializeAccessibilityFeatures();

        // Event listeners removed - now handled by StateEvents.js global delegation
        console.log('Side panel event listeners now managed by StateEvents.js');

        // Hide loading overlay only if there's no session key (no restoration happening)
        const urlParams = new URLSearchParams(window.location.search);
        const sessionKey = urlParams.get('session');
        if (!sessionKey && typeof hideLoading === 'function') {
            hideLoading();
        }
    } catch (error) {
        console.error('Error initializing app:', error);
        const loadingText = document.getElementById('loadingText');
        if (loadingText) {
            loadingText.textContent = 'Error loading checklist. Please try again.';
        }
        // Ensure loading overlay is hidden
        if (typeof hideLoading === 'function') {
            hideLoading();
        }
    }
}

// Initialize the app when the DOM is fully loaded
// NOTE: This is now handled by the modular save/restore system
// document.addEventListener('DOMContentLoaded', () => {
//     initializeApp();
//     // No need for event delegation or mutation observer for report table
// });

// Initialize Add Row buttons after content is built
document.addEventListener('contentBuilt', () => {
    initializePrincipleAddRowButtons();
});

// Export initializeApp for potential use elsewhere (e.g., testing)
window.initializeApp = initializeApp;

// === Report Status Change Delegation & Overlay Logic ===
// Functions removed - now handled by StateEvents.js

// Legacy functions kept for backward compatibility (but not used)
function handleReportStatusChange(statusButton) {
    console.warn('handleReportStatusChange called - this is now handled by StateEvents.js');
}

function handleDeleteReportRow(deleteButton) {
    console.warn('handleDeleteReportRow called - this is now handled by StateEvents.js');
}

function processCompletedRowTextareas(statusButton) {
    console.warn('processCompletedRowTextareas called - this is now handled by StateEvents.js');
}

function observeReportTableMutations() {
    const tbody = document.querySelector('.report-table tbody');
    if (!tbody) return;
    const observer = new MutationObserver(() => {
        // No-op: event delegation covers new rows
    });
    observer.observe(tbody, { childList: true, subtree: false });
}

// Legacy global exports removed - functions now in StateEvents.js
// Kept for backward compatibility but will show warnings if called

// === Report Table Data-Driven Actions ===
// Add Row button handler
// Removed local initializeAddRowButton to avoid duplicate declaration
