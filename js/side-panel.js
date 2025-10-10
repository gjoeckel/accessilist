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

        // Create button for each checkpoint
        checkpoints.forEach((key, index) => {
            const num = parseInt(key.split('-')[1]);
            const button = this.createButton(num, key, index === 0);
            this.ul.appendChild(button);
        });

        // Setup toggle button
        this.setupToggle();

        console.log(`✅ Side panel ready with ${checkpoints.length} checkpoints`);
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
     * Navigate to checkpoint
     * Position checkpoint 90px from top of viewport (same as checkpoint 1 on page load)
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

        // Update active section for filled number circle
        document.querySelectorAll('.principle-section').forEach(sec => {
            sec.classList.remove('active');
        });
        section.classList.add('active');

        // Scroll to position section 90px from top of viewport
        // offsetTop = distance from document top
        // Subtract 90 to account for header and match checkpoint 1's initial position
        const targetScroll = section.offsetTop - 90;

        window.scrollTo({
            top: targetScroll,
            behavior: 'auto' // Instant scroll - no animation
        });

        console.log(`Scrolled to ${checkpointKey}`);

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

