<?php
/**
 * Footer Template
 *
 * Renders footer markup with status support for dynamic updates.
 * The status-content div has aria-live for accessibility announcements.
 */
function renderFooter() {
    global $basePath;
    ?>
<!-- Footer with Status Support -->
<footer class="status-footer" role="contentinfo">
    <div class="footer-left">
        <a href="https://creativecommons.org/licenses/by-sa/4.0/" class="cc-license" target="_blank" rel="noopener noreferrer" aria-label="Licensed under Creative Commons Attribution-ShareAlike 4.0 International">
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
        </a>
        <span class="copyright-text"><a href="https://ncademi.org/" class="ncademi-link" target="_blank" rel="noopener noreferrer">NCADEMI</a></span>
    </div>
    <div class="status-content" aria-live="polite"></div>
</footer>
    <?php
}
?>

