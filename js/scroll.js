/**
 * scroll.js
 *
 * Centralized scroll management for all pages
 * Handles initial positioning and scroll boundaries
 */

class ScrollManager {
    /**
     * Initialize scroll position for mychecklist page
     * Scrolls to checkpoint 1 default position (90px from viewport top)
     */
    static initChecklistScroll() {
        // Checkpoint 1 h2 should appear 90px from top (below 70px header + 20px spacing)
        // With 20000px ::before buffer + 90px padding-top on main:
        // Scroll to: 20000px (buffer) - 90px (target position) = 19910px
        const targetScroll = 20000 - 90;

        window.scrollTo({
            top: targetScroll,
            behavior: 'auto'
        });
        console.log('Checklist scroll initialized - checkpoint 1 at 90px from top');
    }

    /**
     * Initialize scroll position for report pages
     * H2 should appear below fixed header + filters container
     */
    static initReportScroll() {
        // Fixed header/filters container height: ~180px (70px header + 110px filters area)
        // With 5000px ::before buffer:
        // Scroll to position where h2 appears right below the fixed container
        // Target: 5000px (buffer) - 180px (container height) = 4820px
        const targetScroll = 5000 - 180;

        window.scrollTo({
            top: targetScroll,
            behavior: 'auto'
        });
        console.log('Report scroll initialized - h2 below fixed container');
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

