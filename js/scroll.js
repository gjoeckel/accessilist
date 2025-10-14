/**
 * scroll.js
 *
 * Scroll buffer documentation and utilities
 *
 * Scroll Position Calculations:
 *
 * mychecklist.php (Dynamic Buffer System):
 *   - Top buffer: 90px (main::before - prevents scrolling above content)
 *   - Bottom buffer: Dynamic (main::after - calculated based on content/viewport)
 *
 *   Buffer Calculation:
 *   - Large content (> viewport): buffer = viewport - 500px (last content bottom at 500px from top)
 *   - Small content (< viewport): buffer = 0 (content fits, no scrolling needed)
 *   - Target: Last checkpoint bottom at 500px from viewport top when scrolled to max
 *   - Includes header (60px) + 440px spacing = 500px total
 *
 *   Update Strategy:
 *   - 500ms debounce for reliability (ensures DOM fully settled)
 *   - Triggered on: page load, checkpoint changes, manual row addition, save button, window resize
 *   - Prevents race conditions and ensures accurate measurement
 *
 * Report pages (list-report.php, systemwide-report.php):
 *   - Top buffer: 120px (main::before - fixed, positions h2 below sticky header/filters)
 *   - Bottom buffer: Dynamic (main::after - calculated based on table content/viewport)
 *   - Target: Last row at 400px from viewport top when scrolled to max
 *   - Triggers: Page load, filter changes, refresh, window resize
 */

let bufferUpdateTimeout = null;
let lastUpdateTime = 0;
const UPDATE_DELAY = 500; // 500ms settle time for reliability

/**
 * Schedule a buffer update after DOM settles
 * Debounced to prevent multiple rapid updates
 */
window.scheduleBufferUpdate = function() {
    // Clear any pending update
    if (bufferUpdateTimeout) {
        clearTimeout(bufferUpdateTimeout);
    }

    console.log('🎯 [Buffer Update Scheduled] Will calculate in 500ms...');

    // Schedule new update after 500ms
    bufferUpdateTimeout = setTimeout(() => {
        updateBottomBufferNow();
        lastUpdateTime = Date.now();
    }, UPDATE_DELAY);
};

/**
 * Immediate buffer update (for critical paths)
 * Only use when absolutely necessary
 */
window.updateBottomBufferImmediate = function() {
    if (bufferUpdateTimeout) {
        clearTimeout(bufferUpdateTimeout);
    }
    updateBottomBufferNow();
};

/**
 * Internal function to calculate and set bottom buffer
 * Measures actual DOM, uses most restrictive calculation
 */
function updateBottomBufferNow() {
    const startTime = performance.now();

    const main = document.querySelector('main');
    if (!main) {
        console.warn('🎯 [Buffer Update] Main element not found');
        return;
    }

    // Force browser to complete any pending layout
    main.offsetHeight; // Trigger reflow to ensure DOM is settled

    // Calculate visible content height
    const sections = main.querySelectorAll('.principle-section');
    let visibleContentHeight = 0;

    sections.forEach(section => {
        if (section.style.display !== 'none') {
            // Force layout calculation for this section
            const height = section.offsetHeight;
            visibleContentHeight += height;
            console.log(`🎯 [Section ${section.className}] Height: ${height}px`);
        }
    });

    const viewportHeight = window.innerHeight;
    const footerHeight = 50;
    const desiredMargin = 50;  // Space above footer (for small content)
    const topBuffer = 90;
    const targetPositionFromTop = 500;  // Last content bottom at 500px from viewport top (includes header)

    // Calculate appropriate buffer based on content size
    let optimalBuffer;

    if (visibleContentHeight > viewportHeight - topBuffer) {
        // CASE 1: Content LARGER than viewport (e.g., "All" mode)
        // Calculate buffer so last content bottom lands at targetPositionFromTop
        // When scrolled to max: (topBuffer + content) - maxScroll = targetPositionFromTop
        // Solving for buffer: buffer = viewportHeight - targetPositionFromTop
        optimalBuffer = Math.max(0, viewportHeight - targetPositionFromTop);

    } else {
        // CASE 2: Content SMALLER than viewport (e.g., single checkpoint)
        // Content fits - no scrolling needed, use zero buffer
        // This prevents visual jump and unnecessary scrolling
        optimalBuffer = 0;
    }

    // Set CSS custom property
    document.documentElement.style.setProperty('--bottom-buffer', `${optimalBuffer}px`);

    const duration = performance.now() - startTime;

    console.log('🎯 [Buffer Update Complete]', {
        visibleContentHeight,
        viewportHeight,
        topBuffer,
        optimalBuffer,
        targetPosition: visibleContentHeight > viewportHeight - topBuffer ? '500px from top' : 'N/A (no scroll)',
        logic: visibleContentHeight > viewportHeight - topBuffer ? 'large-content (dynamic)' : 'small-content (zero)',
        calculationTime: `${duration.toFixed(2)}ms`
    });
}

/**
 * Update report page buffer
 * Simpler than mychecklist - only needs to handle table content
 * Target: Last row at 500px from viewport top
 */
window.updateReportBuffer = function() {
    const startTime = performance.now();

    const reportSection = document.querySelector('.report-section');
    if (!reportSection) {
        console.warn('🎯 [Report Buffer] .report-section not found');
        return;
    }

    // Force layout calculation
    reportSection.offsetHeight;

    // Get table container
    const table = reportSection.querySelector('.report-table, .reports-table');
    if (!table) {
        console.warn('🎯 [Report Buffer] Table not found');
        return;
    }

    // Count visible rows (not display:none)
    const visibleRows = Array.from(table.querySelectorAll('tbody tr'))
        .filter(row => row.style.display !== 'none');

    const reportContentHeight = reportSection.offsetHeight;
    const viewportHeight = window.innerHeight;
    const topBuffer = 120;  // Fixed top buffer for reports
    const targetPosition = 400;  // Last content at 400px from top

    let optimalBuffer;

    if (reportContentHeight > viewportHeight - topBuffer) {
        // Content larger than viewport
        // Calculate buffer so last content lands at targetPosition
        optimalBuffer = Math.max(0, viewportHeight - targetPosition);
    } else {
        // Content fits in viewport - minimal buffer for footer spacing
        optimalBuffer = 100;
    }

    // Set CSS custom property
    document.documentElement.style.setProperty('--bottom-buffer-report', `${optimalBuffer}px`);

    const duration = performance.now() - startTime;

    console.log('🎯 [Report Buffer Update]', {
        reportContentHeight,
        viewportHeight,
        visibleRows: visibleRows.length,
        optimalBuffer,
        targetPosition: reportContentHeight > viewportHeight - topBuffer ? '400px from top' : 'N/A (fits)',
        logic: reportContentHeight > viewportHeight - topBuffer ? 'large-content (dynamic)' : 'small-content (minimal)',
        calculationTime: `${duration.toFixed(2)}ms`
    });
};

// Schedule report buffer update with debounce
let reportBufferTimeout = null;
window.scheduleReportBufferUpdate = function() {
    if (reportBufferTimeout) {
        clearTimeout(reportBufferTimeout);
    }

    console.log('🎯 [Report Buffer Scheduled] Will calculate in 500ms...');

    reportBufferTimeout = setTimeout(() => {
        window.updateReportBuffer();
    }, 500);
};

// Window resize handler - recalculate buffer when viewport changes
let resizeTimeout;
window.addEventListener('resize', () => {
    // Debounce resize events (already has 500ms from scheduleBufferUpdate)
    clearTimeout(resizeTimeout);
    resizeTimeout = setTimeout(() => {
        // Update mychecklist buffer
        if (typeof window.scheduleBufferUpdate === 'function') {
            window.scheduleBufferUpdate();
        }

        // Update report buffer
        if (typeof window.scheduleReportBufferUpdate === 'function') {
            window.scheduleReportBufferUpdate();
        }
    }, 150); // Wait for resize to stop, then schedule buffer update
});

/**
 * Test utility to validate buffer calculations
 * Run from console: window.ScrollManager.runBufferTests()
 */
window.testBufferCalculation = async function() {
    console.log('\n🧪 ========================================');
    console.log('🧪 BUFFER CALCULATION TEST SUITE');
    console.log('🧪 ========================================\n');

    const results = {
        all: null,
        singleDefault: null,
        singleWithRow: null
    };

    // Save current state
    const originalState = {
        activeButton: document.querySelector('.checkpoint-btn.active'),
        visibleSections: Array.from(document.querySelectorAll('.principle-section'))
            .filter(s => s.style.display !== 'none')
            .map(s => s.className)
    };

    try {
        // TEST 1: All checkpoints visible
        console.log('📋 TEST 1: All Checkpoints Visible');
        console.log('─────────────────────────────────────');

        const allButton = document.querySelector('.checkpoint-btn[data-checkpoint="all"]');
        if (allButton) {
            allButton.click();

            // Wait for DOM to settle
            await new Promise(resolve => setTimeout(resolve, 600));

            // Force immediate calculation
            window.updateBottomBufferImmediate();

            // Get calculated buffer
            const allBuffer = getComputedStyle(document.documentElement)
                .getPropertyValue('--bottom-buffer');

            // Measure actual content
            const sections = document.querySelectorAll('.principle-section');
            let totalHeight = 0;
            sections.forEach(s => {
                if (s.style.display !== 'none') {
                    totalHeight += s.offsetHeight;
                }
            });

            const viewport = window.innerHeight;
            const footer = 50;
            const margin = 50;  // Space above footer
            const topBuffer = 90;
            const targetPosition = 500;  // Last content at 500px from top

            // Use same logic as main calculation
            let expectedBuffer;
            if (totalHeight > viewport - topBuffer) {
                // Content > viewport: dynamic buffer for 500px target
                expectedBuffer = Math.max(0, viewport - targetPosition);
            } else {
                // Content < viewport: no buffer needed (content fits)
                expectedBuffer = 0;
            }

            results.all = {
                calculated: parseInt(allBuffer) || 0,
                expected: expectedBuffer,
                contentHeight: totalHeight,
                viewport: viewport,
                usedCalculation: totalHeight > viewport - topBuffer ? 'large-content' : 'small-content',
                pass: Math.abs(parseInt(allBuffer) - expectedBuffer) <= 1 // Allow 1px rounding
            };

            console.log(`✓ Content height: ${totalHeight}px`);
            console.log(`✓ Viewport height: ${viewport}px`);
            console.log(`✓ Content > viewport? ${totalHeight > viewport - topBuffer ? 'YES' : 'NO'}`);
            console.log(`✓ Expected buffer: ${expectedBuffer}px (${results.all.usedCalculation})`);
            console.log(`✓ Calculated buffer: ${allBuffer}`);
            console.log(`${results.all.pass ? '✅ PASS' : '❌ FAIL'}\n`);
        }

        // TEST 2: Single checkpoint (default - no manual rows)
        console.log('📋 TEST 2: Single Checkpoint (Default)');
        console.log('─────────────────────────────────────');

        const checkpoint1Btn = document.querySelector('.checkpoint-btn[data-checkpoint="checkpoint-1"]');
        if (checkpoint1Btn) {
            checkpoint1Btn.click();

            // Wait for DOM to settle
            await new Promise(resolve => setTimeout(resolve, 600));

            // Force immediate calculation
            window.updateBottomBufferImmediate();

            const singleBuffer = getComputedStyle(document.documentElement)
                .getPropertyValue('--bottom-buffer');

            const section = document.querySelector('.checkpoint-1');
            const singleHeight = section ? section.offsetHeight : 0;

            const viewport = window.innerHeight;
            const footer = 50;
            const margin = 50;  // Space above footer
            const topBuffer = 90;
            const targetPosition = 500;  // Last content at 500px from top

            // Use same logic as main calculation
            let expectedBuffer;
            if (singleHeight > viewport - topBuffer) {
                // Content > viewport: dynamic buffer for 500px target
                expectedBuffer = Math.max(0, viewport - targetPosition);
            } else {
                // Content < viewport: no buffer needed (content fits)
                expectedBuffer = 0;
            }

            results.singleDefault = {
                calculated: parseInt(singleBuffer) || 0,
                expected: expectedBuffer,
                contentHeight: singleHeight,
                viewport: viewport,
                usedCalculation: singleHeight > viewport - topBuffer ? 'large-content' : 'small-content',
                pass: Math.abs(parseInt(singleBuffer) - expectedBuffer) <= 1
            };

            console.log(`✓ Content height: ${singleHeight}px`);
            console.log(`✓ Viewport height: ${viewport}px`);
            console.log(`✓ Content > viewport? ${singleHeight > viewport - topBuffer ? 'YES' : 'NO'}`);
            console.log(`✓ Expected buffer: ${expectedBuffer}px (${results.singleDefault.usedCalculation})`);
            console.log(`✓ Calculated buffer: ${singleBuffer}`);
            console.log(`${results.singleDefault.pass ? '✅ PASS' : '❌ FAIL'}\n`);
        }

        // TEST 3: Single checkpoint with manual row added
        console.log('📋 TEST 3: Single Checkpoint + Manual Row');
        console.log('─────────────────────────────────────');

        // Add a manual row
        const addRowBtn = document.querySelector('button[data-principle="checkpoint-1"]');
        if (addRowBtn && typeof window.handleAddPrincipleRow === 'function') {
            const beforeHeight = document.querySelector('.checkpoint-1').offsetHeight;

            window.handleAddPrincipleRow('checkpoint-1');

            // Wait for DOM to settle and buffer to update
            await new Promise(resolve => setTimeout(resolve, 600));

            // Force immediate calculation
            window.updateBottomBufferImmediate();

            const withRowBuffer = getComputedStyle(document.documentElement)
                .getPropertyValue('--bottom-buffer');

            const section = document.querySelector('.checkpoint-1');
            const withRowHeight = section ? section.offsetHeight : 0;

            const viewport = window.innerHeight;
            const footer = 50;
            const margin = 50;  // Space above footer
            const topBuffer = 90;
            const targetPosition = 500;  // Last content at 500px from top

            // Use same logic as main calculation
            let expectedBuffer;
            if (withRowHeight > viewport - topBuffer) {
                // Content > viewport: dynamic buffer for 500px target
                expectedBuffer = Math.max(0, viewport - targetPosition);
            } else {
                // Content < viewport: no buffer needed (content fits)
                expectedBuffer = 0;
            }

            results.singleWithRow = {
                calculated: parseInt(withRowBuffer) || 0,
                expected: expectedBuffer,
                contentHeight: withRowHeight,
                heightIncrease: withRowHeight - beforeHeight,
                viewport: viewport,
                usedCalculation: withRowHeight > viewport - topBuffer ? 'large-content' : 'small-content',
                pass: Math.abs(parseInt(withRowBuffer) - expectedBuffer) <= 1
            };

            console.log(`✓ Content height before: ${beforeHeight}px`);
            console.log(`✓ Content height after: ${withRowHeight}px`);
            console.log(`✓ Height increase: ${results.singleWithRow.heightIncrease}px`);
            console.log(`✓ Viewport height: ${viewport}px`);
            console.log(`✓ Content > viewport? ${withRowHeight > viewport - topBuffer ? 'YES' : 'NO'}`);
            console.log(`✓ Expected buffer: ${expectedBuffer}px (${results.singleWithRow.usedCalculation})`);
            console.log(`✓ Calculated buffer: ${withRowBuffer}`);
            console.log(`${results.singleWithRow.pass ? '✅ PASS' : '❌ FAIL'}\n`);

            // Delete the test row
            const testRow = document.querySelector('.checkpoint-1 tbody tr:last-child');
            if (testRow) {
                testRow.remove();
                await new Promise(resolve => setTimeout(resolve, 100));
                window.scheduleBufferUpdate();
            }
        }

    } catch (error) {
        console.error('❌ Test error:', error);
    }

    // Restore original state
    console.log('🔄 Restoring original state...');
    if (originalState.activeButton) {
        originalState.activeButton.click();
    }
    await new Promise(resolve => setTimeout(resolve, 100));

    // Print summary
    console.log('\n🧪 ========================================');
    console.log('🧪 TEST SUMMARY');
    console.log('🧪 ========================================');

    const allPassed = Object.values(results).every(r => r && r.pass);

    console.table({
        'All Checkpoints': {
            'Expected': results.all?.expected + 'px',
            'Calculated': results.all?.calculated + 'px',
            'Content Height': results.all?.contentHeight + 'px',
            'Logic Used': results.all?.usedCalculation,
            'Result': results.all?.pass ? '✅ PASS' : '❌ FAIL'
        },
        'Single (Default)': {
            'Expected': results.singleDefault?.expected + 'px',
            'Calculated': results.singleDefault?.calculated + 'px',
            'Content Height': results.singleDefault?.contentHeight + 'px',
            'Logic Used': results.singleDefault?.usedCalculation,
            'Result': results.singleDefault?.pass ? '✅ PASS' : '❌ FAIL'
        },
        'Single + Row': {
            'Expected': results.singleWithRow?.expected + 'px',
            'Calculated': results.singleWithRow?.calculated + 'px',
            'Content Height': results.singleWithRow?.contentHeight + 'px',
            'Logic Used': results.singleWithRow?.usedCalculation,
            'Result': results.singleWithRow?.pass ? '✅ PASS' : '❌ FAIL'
        }
    });

    console.log(`\n${allPassed ? '🎉 ALL TESTS PASSED!' : '⚠️ SOME TESTS FAILED'}\n`);

    return results;
};

// Placeholder for future scroll utilities
window.ScrollManager = {
    scheduleBufferUpdate: window.scheduleBufferUpdate,
    updateImmediate: window.updateBottomBufferImmediate,
    scheduleReportBufferUpdate: window.scheduleReportBufferUpdate,
    updateReportBuffer: window.updateReportBuffer,
    runBufferTests: window.testBufferCalculation
};
