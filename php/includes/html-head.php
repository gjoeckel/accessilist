<?php
/**
 * HTML Head Template
 *
 * Renders the complete HTML head section with all CSS stylesheets.
 * CSS files are loaded in a specific order for proper cascade.
 *
 * @param string $pageTitle - The page title to display
 * @param bool $includeLoadingStyles - Whether to include loading overlay styles (default: false)
 */
function renderHTMLHead($pageTitle = 'Accessibility Checklists', $includeLoadingStyles = false) {
    global $basePath, $envConfig;
    ?>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<!-- Added viewport meta for responsiveness -->
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title><?php echo htmlspecialchars($pageTitle, ENT_QUOTES, 'UTF-8'); ?></title>

<!-- Environment Configuration (Injected from PHP .env) -->
<script>
window.ENV = <?php echo json_encode($envConfig); ?>;
window.basePath = window.ENV.basePath;
</script>

<link rel="stylesheet" href="<?php echo $basePath; ?>/css/simple-modal.css<?php echo $includeLoadingStyles ? '' : '?v=' . time(); ?>">
<link rel="stylesheet" href="<?php echo $basePath; ?>/css/focus.css?v=<?php echo time(); ?>">
<link rel="stylesheet" href="<?php echo $basePath; ?>/css/landing.css<?php echo $includeLoadingStyles ? '' : '?v=' . time(); ?>">
<link rel="stylesheet" href="<?php echo $basePath; ?>/css/reports.css<?php echo $includeLoadingStyles ? '' : '?v=' . time(); ?>">
<link rel="stylesheet" href="<?php echo $basePath; ?>/css/form-elements.css<?php echo $includeLoadingStyles ? '' : '?v=' . time(); ?>">
<link rel="stylesheet" href="<?php echo $basePath; ?>/css/table.css<?php echo $includeLoadingStyles ? '' : '?v=' . time(); ?>">
<link rel="stylesheet" href="<?php echo $basePath; ?>/css/list.css<?php echo $includeLoadingStyles ? '' : '?v=' . time(); ?>">
<link rel="stylesheet" href="<?php echo $basePath; ?>/css/scroll.css<?php echo $includeLoadingStyles ? '' : '?v=' . time(); ?>">
<link rel="stylesheet" href="<?php echo $basePath; ?>/css/footer.css<?php echo $includeLoadingStyles ? '' : '?v=' . time(); ?>">
<link rel="stylesheet" href="<?php echo $basePath; ?>/css/header.css<?php echo $includeLoadingStyles ? '' : '?v=' . time(); ?>">
<link rel="stylesheet" href="<?php echo $basePath; ?>/css/base.css<?php echo $includeLoadingStyles ? '' : '?v=' . time(); ?>">
<?php if ($includeLoadingStyles): ?>
<link rel="stylesheet" href="<?php echo $basePath; ?>/css/loading.css">
<?php endif; ?>
</head>
    <?php
}
?>

