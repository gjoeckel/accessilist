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
<link rel="stylesheet" href="<?php echo $basePath; ?>/css/admin.css<?php echo $includeLoadingStyles ? '' : '?v=' . time(); ?>">
<link rel="stylesheet" href="<?php echo $basePath; ?>/css/form-elements.css<?php echo $includeLoadingStyles ? '' : '?v=' . time(); ?>">
<link rel="stylesheet" href="<?php echo $basePath; ?>/css/table.css<?php echo $includeLoadingStyles ? '' : '?v=' . time(); ?>">
<link rel="stylesheet" href="<?php echo $basePath; ?>/css/section.css<?php echo $includeLoadingStyles ? '' : '?v=' . time(); ?>">
<link rel="stylesheet" href="<?php echo $basePath; ?>/css/status.css<?php echo $includeLoadingStyles ? '' : '?v=' . time(); ?>">
<link rel="stylesheet" href="<?php echo $basePath; ?>/css/side-panel.css<?php echo $includeLoadingStyles ? '' : '?v=' . time(); ?>">
<link rel="stylesheet" href="<?php echo $basePath; ?>/css/header.css<?php echo $includeLoadingStyles ? '' : '?v=' . time(); ?>">
<link rel="stylesheet" href="<?php echo $basePath; ?>/css/base.css<?php echo $includeLoadingStyles ? '' : '?v=' . time(); ?>">
<?php if ($includeLoadingStyles): ?>
<style>
  /* Loading overlay styles */
  #loadingOverlay {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background-color: rgba(255, 255, 255, 0.9);
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    z-index: 9999;
  }

  #loadingSpinner {
    width: 50px;
    height: 50px;
    border: 5px solid #f3f3f3;
    border-top: 5px solid #3498db;
    border-radius: 50%;
    margin-bottom: 20px;
    animation: spin 1s linear infinite;
  }

  @keyframes spin {
    0% { transform: rotate(0deg); }
    100% { transform: rotate(360deg); }
  }

  #loadingText {
    font-size: 18px;
    color: #333;
  }
</style>
<?php endif; ?>
</head>
    <?php
}
?>

