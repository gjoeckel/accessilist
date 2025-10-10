/**
 * scroll.js
 *
 * Centralized scroll management for all pages
 * Handles initial positioning and scroll boundaries
 */

class ScrollManager {
    /**
     * Initialize scroll position for mychecklist page
     * Scrolls to checkpoint 1 default position
     */
    static initChecklistScroll() {
        // Checkpoint 1 should be 90px from top (below header)
        // With 20000px ::before buffer, scroll to that position
        window.scrollTo({
            top: 20000,
            behavior: 'auto'
        });
        console.log('Checklist scroll initialized to checkpoint 1 position');
    }

    /**
     * Initialize scroll position for report pages
     * Content should start below fixed header + filters
     */
    static initReportScroll() {
        // Report pages have fixed header/filters, content starts naturally
        // No manual scroll needed - page loads at top
        window.scrollTo({
            top: 0,
            behavior: 'auto'
        });
        console.log('Report scroll initialized');
    }

    /**
     * Prevent scroll restoration by browser
     */
    static disableScrollRestoration() {
        if ('scrollRestoration' in history) {
            history.scrollRestoration = 'manual';
        }
    }
}

// Make available globally
window.ScrollManager = ScrollManager;

// Auto-initialize on page load
document.addEventListener('DOMContentLoaded', () => {
    ScrollManager.disableScrollRestoration();

    // Initialize based on page type
    if (document.body.classList.contains('checklist-page')) {
        ScrollManager.initChecklistScroll();
    } else if (document.body.classList.contains('report-page')) {
        ScrollManager.initReportScroll();
    }
});

