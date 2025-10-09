/**
 * side-panel-generator.js
 *
 * Dynamically generates side panel checkpoint navigation buttons
 * based on JSON checkpoint data (2-10 checkpoints supported)
 *
 * Requirements:
 * - Minimum: checkpoint-1 must exist
 * - Range: 2-10 checkpoints
 * - Icons: number-N-0.svg (inactive) and number-N-1.svg (active)
 * - Height: Dynamic with 15px spacing
 * - Position: Top position maintained from CSS
 */

/**
 * Generate side panel checkpoint buttons dynamically
 * @param {Object} jsonData - The checklist JSON data
 */
function generateSidePanel(jsonData) {
    console.log('Generating side panel from JSON data');

    // 1. Find all checkpoint-* keys in JSON
    const checkpoints = Object.keys(jsonData)
        .filter(key => key.startsWith('checkpoint-'))
        .sort((a, b) => {
            const numA = parseInt(a.split('-')[1]);
            const numB = parseInt(b.split('-')[1]);
            return numA - numB;
        });

    console.log(`Found ${checkpoints.length} checkpoints:`, checkpoints);

    // 2. Validate minimum requirement (checkpoint-1 must exist)
    if (!checkpoints.includes('checkpoint-1')) {
        console.error('ERROR: No checkpoint-1 found in JSON - side panel cannot be rendered');
        console.warn('Side panel requires at least checkpoint-1 to display');
        return;
    }

    // 3. Validate checkpoint count (2-10)
    if (checkpoints.length < 2) {
        console.error(`ERROR: Only ${checkpoints.length} checkpoint(s) found - minimum is 2`);
        return;
    }

    if (checkpoints.length > 10) {
        console.warn(`WARNING: ${checkpoints.length} checkpoints found - maximum is 10, truncating`);
        checkpoints.splice(10); // Keep only first 10
    }

    // 4. Calculate dynamic height
    const count = checkpoints.length;
    const buttonHeight = 36; // px (icon size)
    const spacing = 15; // px (between buttons)
    const topPadding = 15; // px
    const bottomPadding = 15; // px

    const totalHeight = topPadding +
                       (count * buttonHeight) +
                       ((count - 1) * spacing) +
                       bottomPadding;

    console.log(`Side panel configuration:`);
    console.log(`  Checkpoint count: ${count}`);
    console.log(`  Calculated height: ${totalHeight}px`);
    console.log(`  Formula: ${topPadding} + (${count} × ${buttonHeight}) + (${count-1} × ${spacing}) + ${bottomPadding}`);

    // 5. Apply height to side panel and toggle strip
    const sidePanel = document.querySelector('.side-panel');
    const toggleStrip = document.querySelector('.toggle-strip');

    if (sidePanel) {
        sidePanel.style.height = `${totalHeight}px`;
        console.log(`  Applied height to .side-panel: ${totalHeight}px`);
    } else {
        console.error('ERROR: .side-panel element not found');
        return;
    }

    if (toggleStrip) {
        toggleStrip.style.height = `${totalHeight}px`;
        console.log(`  Applied height to .toggle-strip: ${totalHeight}px`);
    } else {
        console.warn('WARNING: .toggle-strip element not found');
    }

    // 6. Generate checkpoint buttons dynamically
    const sidePanelUl = document.getElementById('side-panel');
    if (!sidePanelUl) {
        console.error('ERROR: #side-panel <ul> element not found');
        return;
    }

    // Clear any existing content
    sidePanelUl.innerHTML = '';
    console.log('Cleared existing side panel content');

    // Generate a button for each checkpoint
    checkpoints.forEach((checkpointKey, index) => {
        const num = checkpointKey.split('-')[1];
        const isFirst = (index === 0);
        const isLast = (index === checkpoints.length - 1);

        console.log(`  Generating button ${index + 1}/${count}: ${checkpointKey}`);

        // Create list item
        const li = document.createElement('li');

        // Last checkpoint gets special ID for visibility toggling
        if (isLast && count >= 4) {
            li.id = `${checkpointKey}-section`;
            li.setAttribute('role', 'region');
            li.setAttribute('aria-live', 'polite');
            li.setAttribute('aria-label', `Checkpoint ${num} table`);
        }

        // Create anchor link
        const a = document.createElement('a');
        a.href = 'javascript:void(0)';
        a.setAttribute('data-target', checkpointKey);
        a.setAttribute('aria-label', `Checkpoint ${num}`);
        a.setAttribute('title', `View Checkpoint ${num}`);

        // First checkpoint is active by default
        if (isFirst) {
            a.className = 'infocus';
        }

        // Create active state icon (number-N-1.svg)
        const activeImg = document.createElement('img');
        activeImg.src = window.getImagePath
            ? window.getImagePath(`number-${num}-1.svg`)
            : `/images/number-${num}-1.svg`;
        activeImg.alt = `Checkpoint ${num} table`;
        activeImg.className = 'active-state';
        activeImg.width = 36;
        activeImg.height = 36;

        // Create inactive state icon (number-N-0.svg)
        const inactiveImg = document.createElement('img');
        inactiveImg.src = window.getImagePath
            ? window.getImagePath(`number-${num}-0.svg`)
            : `/images/number-${num}-0.svg`;
        inactiveImg.alt = `Checkpoint ${num} table`;
        inactiveImg.className = 'inactive-state';
        inactiveImg.width = 36;
        inactiveImg.height = 36;

        // Assemble elements
        a.appendChild(activeImg);
        a.appendChild(inactiveImg);
        li.appendChild(a);
        sidePanelUl.appendChild(li);
    });

    console.log(`✅ Side panel generated successfully with ${count} checkpoint buttons`);
    console.log(`   Height: ${totalHeight}px`);
    console.log(`   Checkpoints: ${checkpoints.join(', ')}`);
}

// Make function globally available
window.generateSidePanel = generateSidePanel;

console.log('✅ side-panel-generator.js loaded');

