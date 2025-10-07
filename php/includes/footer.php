<?php
/**
 * Footer Templates
 *
 * Renders footer markup with support for different footer types.
 *
 * @param string $type - 'standard' or 'status' (default: 'standard')
 */
function renderFooter($type = 'standard') {
    global $basePath;

    if ($type === 'status') {
        // Status footer with live region for dynamic updates
        ?>
<!-- Status Footer -->
<div class="status-footer" role="contentinfo" aria-live="polite">
    <p class="copyright-text">
        © 2025 NCADEMI
        <span class="cc-license">
            <span class="cc-icon">
                <svg viewBox="0 0 30 30">
                    <use href="<?php echo $basePath; ?>/images/cc-icons.svg#cc-logo"></use>
                </svg>
            </span>
            <span class="cc-icon">
                <svg viewBox="0 0 30 30">
                    <use href="<?php echo $basePath; ?>/images/cc-icons.svg#cc-by"></use>
                </svg>
            </span>
            <span class="cc-icon">
                <svg viewBox="0 0 30 30">
                    <use href="<?php echo $basePath; ?>/images/cc-icons.svg#cc-sa"></use>
                </svg>
            </span>
            <span class="cc-text">CC BY-SA 4.0</span>
        </span>
    </p>
    <div class="status-content"></div>
</div>
        <?php
    } else {
        // Standard footer
        ?>
<!-- Footer -->
<footer role="contentinfo">
    <p>
        © 2025 NCADEMI
        <span class="cc-license">
            <span class="cc-icon">
                <svg viewBox="0 0 30 30">
                    <use href="<?php echo $basePath; ?>/images/cc-icons.svg#cc-logo"></use>
                </svg>
            </span>
            <span class="cc-icon">
                <svg viewBox="0 0 30 30">
                    <use href="<?php echo $basePath; ?>/images/cc-icons.svg#cc-by"></use>
                </svg>
            </span>
            <span class="cc-icon">
                <svg viewBox="0 0 30 30">
                    <use href="<?php echo $basePath; ?>/images/cc-icons.svg#cc-sa"></use>
                </svg>
            </span>
            <span class="cc-text">CC BY-SA 4.0</span>
        </span>
    </p>
</footer>
        <?php
    }
}
?>

