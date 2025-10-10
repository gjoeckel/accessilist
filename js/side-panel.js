/**
 * side-panel.js
 *
 * Simple checkpoint navigation side panel
 * - Generates numbered circle buttons (1-10) based on JSON checkpoints
 * - Scrolls checkpoint to top of page
 * - Sets focus on checkpoint h2
 * - Collapses/expands
 */

class SidePanel {
    constructor() {
        this.panel = document.querySelector('.side-panel');
        this.ul = document.querySelector('.side-panel ul');
        this.toggleBtn = document.querySelector('.toggle-strip');
        this.currentCheckpoint = 1;
        this.minScrollPosition = 20000; // Prevent scrolling above checkpoint 1
        this.setupScrollBoundary();
    }

    /**
     * Initialize side panel with checkpoint data
     */
    init(checklistData) {
        if (!this.panel || !this.ul) {
            console.error('Side panel elements not found');
            return;
        }

        // Find all checkpoints in JSON
        const checkpoints = Object.keys(checklistData)
            .filter(key => key.startsWith('checkpoint-'))
            .sort((a, b) => {
                const numA = parseInt(a.split('-')[1]);
                const numB = parseInt(b.split('-')[1]);
                return numA - numB;
            });

        console.log(`Generating ${checkpoints.length} checkpoint buttons:`, checkpoints);

        // Clear existing buttons
        this.ul.innerHTML = '';

        // Create "All" button first (three lines symbol) - active by default
        const allButton = this.createAllButton();
        this.ul.appendChild(allButton);

        // Create button for each checkpoint
        checkpoints.forEach((key) => {
            const num = parseInt(key.split('-')[1]);
            const button = this.createButton(num, key, false); // All is active, not individual checkpoints
            this.ul.appendChild(button);
        });

        // Store checkpoint keys for "All" functionality
        this.checkpointKeys = checkpoints;

        // Setup toggle button
        this.setupToggle();

        // Note: showAllCheckpoints() will be called after content is built
        // This allows sections to exist before we apply .active class
        // Call applyAllCheckpointsActive() from main.js after buildContent()

        console.log(`✅ Side panel ready with All button + ${checkpoints.length} checkpoints`);
    }

    /**
     * Apply selected styling to all checkpoints (called after content is built)
     */
    applyAllCheckpointsActive() {
        this.showAllCheckpoints();
        console.log('Applied selected styling to all checkpoints on page load');
    }

    /**
     * Create the "All" button (three lines symbol)
     */
    createAllButton() {
        const li = document.createElement('li');

        const btn = document.createElement('button');
        btn.className = 'checkpoint-btn checkpoint-all active'; // Active by default
        btn.setAttribute('data-checkpoint', 'all');
        btn.setAttribute('aria-label', 'Show all checkpoints');
        btn.textContent = '≡'; // Three lines (will be replaced by SVG mask)

        // Click handler
        btn.addEventListener('click', () => this.showAll(btn));

        li.appendChild(btn);
        return li;
    }

    /**
     * Create a checkpoint button
     */
    createButton(num, checkpointKey, isActive = false) {
        const li = document.createElement('li');

        const btn = document.createElement('button');
        btn.className = `checkpoint-btn${isActive ? ' active' : ''}`;
        btn.setAttribute('data-checkpoint', checkpointKey);
        btn.setAttribute('aria-label', `Go to checkpoint ${num}`);
        btn.textContent = num;

        // Click handler
        btn.addEventListener('click', () => this.goToCheckpoint(checkpointKey, btn));

        li.appendChild(btn);
        return li;
    }

    /**
     * Show all checkpoints (All button clicked)
     */
    showAll(clickedBtn) {
        console.log('Showing all checkpoints');

        // Update active button
        this.ul.querySelectorAll('.checkpoint-btn').forEach(btn => {
            btn.classList.remove('active');
        });
        clickedBtn.classList.add('active');

        // Show all checkpoint sections and apply selected styling
        this.showAllCheckpoints();

        // Scroll to checkpoint 1 position (default view)
        window.scrollTo({
            top: 20000,
            behavior: 'auto' // Instant scroll - no animation
        });

        console.log('All checkpoints visible with selected styling');
    }

    /**
     * Show all checkpoints with selected styling
     */
    showAllCheckpoints() {
        document.querySelectorAll('.principle-section').forEach(section => {
            section.style.display = 'block'; // Make visible
            section.classList.add('active'); // Apply selected styling (brown h2 circles, brown add-row buttons)
        });
    }

    /**
     * Navigate to specific checkpoint (hide others)
     */
    goToCheckpoint(checkpointKey, clickedBtn) {
        console.log(`Navigating to ${checkpointKey}`);

        // Find the checkpoint section
        const section = document.querySelector(`section.${checkpointKey}`);
        if (!section) {
            console.error(`Section ${checkpointKey} not found`);
            return;
        }

        // Update active button
        this.ul.querySelectorAll('.checkpoint-btn').forEach(btn => {
            btn.classList.remove('active');
        });
        clickedBtn.classList.add('active');

        // Hide all sections, then show only the selected one with active styling
        document.querySelectorAll('.principle-section').forEach(sec => {
            sec.classList.remove('active');
            sec.style.display = 'none'; // Hide all
        });
        section.classList.add('active'); // Apply selected styling
        section.style.display = 'block'; // Show only selected

        // Scroll to position section 90px from top of viewport
        // offsetTop = distance from document top
        // Subtract 90 to account for header and match checkpoint 1's initial position
        const targetScroll = section.offsetTop - 90;

        window.scrollTo({
            top: targetScroll,
            behavior: 'auto' // Instant scroll - no animation
        });

        console.log(`Scrolled to ${checkpointKey}, hidden other checkpoints`);

        // Focus on checkpoint h2
        // Use preventScroll to avoid any scroll adjustment
        const heading = section.querySelector('h2');
        if (heading) {
            heading.focus({ preventScroll: true });
        }
    }

    /**
     * Setup toggle button for collapse/expand
     */
    setupToggle() {
        if (!this.toggleBtn) return;

        this.toggleBtn.addEventListener('click', () => {
            const isExpanded = this.panel.getAttribute('aria-expanded') === 'true';
            const newState = !isExpanded;

            this.panel.setAttribute('aria-expanded', newState.toString());
            this.toggleBtn.setAttribute('aria-expanded', newState.toString());

            console.log(`Side panel ${newState ? 'expanded' : 'collapsed'}`);
        });
    }

    /**
     * Prevent scrolling above checkpoint 1 (into the buffer space)
     * Uses event interception to stop scroll before it happens (no fighting)
     */
    setupScrollBoundary() {
        // Prevent mouse wheel scrolling up when at boundary
        window.addEventListener('wheel', (e) => {
            const isScrollingUp = e.deltaY < 0;
            const atBoundary = window.scrollY <= this.minScrollPosition;

            if (atBoundary && isScrollingUp) {
                e.preventDefault();
            }
        }, { passive: false });

        // Prevent touch scrolling up when at boundary
        let touchStartY = 0;

        window.addEventListener('touchstart', (e) => {
            touchStartY = e.touches[0].clientY;
        }, { passive: true });

        window.addEventListener('touchmove', (e) => {
            const touchEndY = e.touches[0].clientY;
            const isScrollingUp = touchEndY > touchStartY;
            const atBoundary = window.scrollY <= this.minScrollPosition;

            if (atBoundary && isScrollingUp) {
                e.preventDefault();
            }
        }, { passive: false });

        // Fallback: snap back if somehow user gets above boundary
        // (e.g., programmatic scroll, keyboard navigation)
        window.addEventListener('scroll', () => {
            if (window.scrollY < this.minScrollPosition) {
                window.scrollTo({
                    top: this.minScrollPosition,
                    behavior: 'auto'
                });
            }
        }, { passive: true });
    }
}

// Initialize when page loads
window.SidePanel = SidePanel;

