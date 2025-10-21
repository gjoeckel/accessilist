<?php
/**
 * STATELESS CSRF TEST PAGE
 *
 * This version uses stateless CSRF (no cookies required)
 * Test with: https://webaim.org/training/online/accessilist2/home-stateless-test
 */
require_once __DIR__ . '/includes/config.php';
require_once __DIR__ . '/includes/html-head.php';
require_once __DIR__ . '/includes/footer.php';
require_once __DIR__ . '/includes/security-headers.php';

// USE STATELESS CSRF (no cookies!)
require_once __DIR__ . '/includes/csrf-stateless.php';
$GLOBALS['csrfToken'] = generate_stateless_csrf_token();

// Set security headers AFTER token generation
set_security_headers();

renderHTMLHead('Accessibility Checklists - Stateless CSRF Test');
?>
<body>
<h1>Stateless CSRF Test</h1>
<p>This page uses stateless CSRF tokens (no cookies required).</p>

<div style="padding: 20px; background: #f0f0f0; margin: 20px;">
  <h2>Diagnostics</h2>
  <p><strong>CSRF Token:</strong> <code><?php echo $GLOBALS['csrfToken']; ?></code></p>
  <p><strong>Cookies Required:</strong> ❌ No</p>
  <p><strong>Works with Cookie Blockers:</strong> ✅ Yes</p>
</div>

<button id="testButton" style="padding: 10px 20px; font-size: 16px; cursor: pointer;">
  Test Stateless CSRF
</button>

<div id="result" style="margin-top: 20px;"></div>

<script src="<?php echo $basePath; ?>/js/debug-utils.js?v=<?php echo time(); ?>"></script>
<script src="<?php echo $basePath; ?>/js/csrf-utils.js?v=<?php echo time(); ?>"></script>
<script>
  document.getElementById('testButton').addEventListener('click', async function() {
    console.log('Testing stateless CSRF...');

    const apiPath = '<?php echo $basePath; ?>/php/api/test-stateless-csrf.php';
    const response = await fetchWithCsrf(apiPath, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ test: 'stateless' })
    });

    const data = await response.json();
    document.getElementById('result').innerHTML = `
      <h3>Result:</h3>
      <pre>${JSON.stringify(data, null, 2)}</pre>
    `;
  });
</script>
</body>
</html>
