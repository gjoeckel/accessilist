<?php
/**
 * Footer Templates
 *
 * Renders footer markup with support for different footer types.
 *
 * @param string $type - 'standard' or 'status' (default: 'standard')
 */
function renderFooter($type = 'standard') {
    if ($type === 'status') {
        // Status footer with live region for dynamic updates
        ?>
<!-- Status Footer -->
<div class="status-footer" role="contentinfo" aria-live="polite">
    <p class="copyright-text">© 2025 NCADEMI. All rights reserved.</p>
    <div class="status-content"></div>
</div>
        <?php
    } else {
        // Standard footer
        ?>
<!-- Footer -->
<footer role="contentinfo">
    <p>© 2025 NCADEMI. All rights reserved.</p>
</footer>
        <?php
    }
}
?>

