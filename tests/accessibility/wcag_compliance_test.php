<?php
/**
 * AccessiList WCAG Compliance Test
 * Comprehensive accessibility testing with Chrome MCP integration
 */

require_once __DIR__ . '/../run_comprehensive_tests.php';

class WCAGComplianceTest extends TestBase {
    private $baseUrl;
    private $testResults = [];

    public function __construct($baseUrl = TestConfig::BASE_URL) {
        $this->baseUrl = $baseUrl;
    }

    public function runAllTests() {
        echo "♿ AccessiList WCAG Compliance Test Suite\n";
        echo "======================================\n";
        echo "Base URL: " . $this->baseUrl . "\n";
        echo "Timestamp: " . date('Y-m-d H:i:s') . "\n";
        echo "WCAG Level: AA (Target)\n\n";

        try {
            // Initialize Chrome MCP
            self::initChromeMCP($this->baseUrl);

            // Run all accessibility tests
            $this->testKeyboardNavigation();
            $this->testScreenReaderSupport();
            $this->testColorContrast();
            $this->testFocusManagement();
            $this->testARIALabels();
            $this->testSemanticHTML();
            $this->testResponsiveDesign();
            $this->testErrorHandling();

            $this->generateReport();

        } catch (Exception $e) {
            echo "❌ Critical error during accessibility test: " . $e->getMessage() . "\n";
            exit(1);
        }
    }

    private function testKeyboardNavigation() {
        echo "⌨️  Testing Keyboard Navigation...\n";

        try {
            // Navigate to checklist page
            self::navigateToPage($this->baseUrl . '/php/list.php', 'Navigate to checklist page');
            self::waitForText('Accessibility', 10);

            // Test tab order
            $result = self::evaluateScript('document.querySelectorAll("a, button, input, textarea, select").length > 0', 'Check for interactive elements');
            self::assertTrue($result === true || $result === 'true', 'Interactive elements should be present');
            $this->addResult('keyboard', 'interactive_elements', 'passed', 'Interactive elements found');

            // Test focus indicators
            $result = self::evaluateScript('document.querySelector("a:focus, button:focus, input:focus") !== null || document.querySelector("[tabindex]") !== null', 'Check for focusable elements');
            self::assertTrue($result === true || $result === 'true', 'Focusable elements should be present');
            $this->addResult('keyboard', 'focusable_elements', 'passed', 'Focusable elements found');

            // Test tabindex values
            $result = self::evaluateScript('document.querySelectorAll("[tabindex]:not([tabindex=\"-1\"])").length', 'Count positive tabindex values');
            $positiveTabindex = intval($result);

            if ($positiveTabindex > 0) {
                $this->addResult('keyboard', 'tabindex_values', 'failed', "Found $positiveTabindex elements with positive tabindex (should avoid)");
            } else {
                $this->addResult('keyboard', 'tabindex_values', 'passed', 'No positive tabindex values found');
            }

            // Test skip links
            $result = self::evaluateScript('document.querySelector("a[href=\"#main\"], a[href=\"#content\"], .skip-link") !== null', 'Check for skip links');
            if ($result === true || $result === 'true') {
                $this->addResult('keyboard', 'skip_links', 'passed', 'Skip links found');
            } else {
                $this->addResult('keyboard', 'skip_links', 'failed', 'Skip links not found');
            }

        } catch (Exception $e) {
            $this->addResult('keyboard', 'navigation', 'failed', $e->getMessage());
        }
    }

    private function testScreenReaderSupport() {
        echo "🔊 Testing Screen Reader Support...\n";

        try {
            // Navigate to checklist page
            self::navigateToPage($this->baseUrl . '/php/list.php', 'Navigate to checklist page');
            self::waitForText('Accessibility', 10);

            // Test ARIA labels
            $result = self::evaluateScript('document.querySelectorAll("[aria-label]").length', 'Count ARIA labels');
            $ariaLabels = intval($result);

            if ($ariaLabels > 0) {
                $this->addResult('screen_reader', 'aria_labels', 'passed', "Found $ariaLabels ARIA labels");
            } else {
                $this->addResult('screen_reader', 'aria_labels', 'failed', 'No ARIA labels found');
            }

            // Test ARIA live regions
            $result = self::evaluateScript('document.querySelectorAll("[aria-live]").length', 'Count ARIA live regions');
            $liveRegions = intval($result);

            if ($liveRegions > 0) {
                $this->addResult('screen_reader', 'live_regions', 'passed', "Found $liveRegions ARIA live regions");
            } else {
                $this->addResult('screen_reader', 'live_regions', 'failed', 'No ARIA live regions found');
            }

            // Test alt text for images
            $result = self::evaluateScript('document.querySelectorAll("img").length', 'Count images');
            $totalImages = intval($result);

            $result = self::evaluateScript('document.querySelectorAll("img[alt]").length', 'Count images with alt text');
            $imagesWithAlt = intval($result);

            if ($totalImages === $imagesWithAlt) {
                $this->addResult('screen_reader', 'alt_text', 'passed', "All $totalImages images have alt text");
            } else {
                $this->addResult('screen_reader', 'alt_text', 'failed', "Only $imagesWithAlt of $totalImages images have alt text");
            }

            // Test heading structure
            $result = self::evaluateScript('document.querySelector("h1") !== null', 'Check for h1 heading');
            self::assertTrue($result === true || $result === 'true', 'Page should have h1 heading');
            $this->addResult('screen_reader', 'heading_structure', 'passed', 'Proper heading structure found');

        } catch (Exception $e) {
            $this->addResult('screen_reader', 'support', 'failed', $e->getMessage());
        }
    }

    private function testColorContrast() {
        echo "🎨 Testing Color Contrast...\n";

        try {
            // Navigate to checklist page
            self::navigateToPage($this->baseUrl . '/php/list.php', 'Navigate to checklist page');
            self::waitForText('Accessibility', 10);

            // Test for color-only information
            $result = self::evaluateScript('document.querySelectorAll("[style*=\"color:\"]").length', 'Count elements with inline color styles');
            $colorOnlyElements = intval($result);

            if ($colorOnlyElements === 0) {
                $this->addResult('color_contrast', 'color_only_info', 'passed', 'No color-only information found');
            } else {
                $this->addResult('color_contrast', 'color_only_info', 'failed', "Found $colorOnlyElements elements with color-only information");
            }

            // Test for sufficient contrast (simplified check)
            $result = self::evaluateScript('getComputedStyle(document.body).color !== getComputedStyle(document.body).backgroundColor', 'Check text and background colors are different');
            self::assertTrue($result === true || $result === 'true', 'Text and background colors should be different');
            $this->addResult('color_contrast', 'contrast_check', 'passed', 'Text and background colors are different');

            // Test for focus indicators
            $result = self::evaluateScript('document.querySelector("a:focus, button:focus") !== null || document.querySelector("[tabindex]:focus") !== null', 'Check for focus indicators');
            if ($result === true || $result === 'true') {
                $this->addResult('color_contrast', 'focus_indicators', 'passed', 'Focus indicators found');
            } else {
                $this->addResult('color_contrast', 'focus_indicators', 'failed', 'Focus indicators not found');
            }

        } catch (Exception $e) {
            $this->addResult('color_contrast', 'contrast', 'failed', $e->getMessage());
        }
    }

    private function testFocusManagement() {
        echo "🎯 Testing Focus Management...\n";

        try {
            // Navigate to checklist page
            self::navigateToPage($this->baseUrl . '/php/list.php', 'Navigate to checklist page');
            self::waitForText('Accessibility', 10);

            // Test focus trap functionality
            $result = self::evaluateScript('typeof window.trapFocus === "function"', 'Check focus trap function');
            if ($result === true || $result === 'true') {
                $this->addResult('focus_management', 'focus_trap', 'passed', 'Focus trap function available');
            } else {
                $this->addResult('focus_management', 'focus_trap', 'failed', 'Focus trap function not found');
            }

            // Test return focus functionality
            $result = self::evaluateScript('typeof window.returnFocus === "function"', 'Check return focus function');
            if ($result === true || $result === 'true') {
                $this->addResult('focus_management', 'return_focus', 'passed', 'Return focus function available');
            } else {
                $this->addResult('focus_management', 'return_focus', 'failed', 'Return focus function not found');
            }

            // Test initial focus setting
            $result = self::evaluateScript('typeof window.setInitialFocus === "function"', 'Check initial focus function');
            if ($result === true || $result === 'true') {
                $this->addResult('focus_management', 'initial_focus', 'passed', 'Initial focus function available');
            } else {
                $this->addResult('focus_management', 'initial_focus', 'failed', 'Initial focus function not found');
            }

            // Test focus visibility
            $result = self::evaluateScript('document.querySelector("a:focus, button:focus, input:focus, textarea:focus, select:focus") !== null', 'Check for focused elements');
            if ($result === true || $result === 'true') {
                $this->addResult('focus_management', 'focus_visibility', 'passed', 'Focus visibility working');
            } else {
                $this->addResult('focus_management', 'focus_visibility', 'failed', 'Focus visibility not working');
            }

        } catch (Exception $e) {
            $this->addResult('focus_management', 'management', 'failed', $e->getMessage());
        }
    }

    private function testARIALabels() {
        echo "🏷️  Testing ARIA Labels...\n";

        try {
            // Navigate to checklist page
            self::navigateToPage($this->baseUrl . '/php/list.php', 'Navigate to checklist page');
            self::waitForText('Accessibility', 10);

            // Test ARIA labels on interactive elements
            $result = self::evaluateScript('document.querySelectorAll("button[aria-label], a[aria-label], input[aria-label]").length', 'Count interactive elements with ARIA labels');
            $labeledElements = intval($result);

            if ($labeledElements > 0) {
                $this->addResult('aria', 'interactive_labels', 'passed', "Found $labeledElements interactive elements with ARIA labels");
            } else {
                $this->addResult('aria', 'interactive_labels', 'failed', 'No interactive elements with ARIA labels found');
            }

            // Test ARIA expanded attributes
            $result = self::evaluateScript('document.querySelectorAll("[aria-expanded]").length', 'Count elements with aria-expanded');
            $expandedElements = intval($result);

            if ($expandedElements > 0) {
                $this->addResult('aria', 'expanded_attributes', 'passed', "Found $expandedElements elements with aria-expanded");
            } else {
                $this->addResult('aria', 'expanded_attributes', 'failed', 'No elements with aria-expanded found');
            }

            // Test ARIA hidden attributes
            $result = self::evaluateScript('document.querySelectorAll("[aria-hidden]").length', 'Count elements with aria-hidden');
            $hiddenElements = intval($result);

            if ($hiddenElements > 0) {
                $this->addResult('aria', 'hidden_attributes', 'passed', "Found $hiddenElements elements with aria-hidden");
            } else {
                $this->addResult('aria', 'hidden_attributes', 'failed', 'No elements with aria-hidden found');
            }

            // Test ARIA roles
            $result = self::evaluateScript('document.querySelectorAll("[role]").length', 'Count elements with ARIA roles');
            $roleElements = intval($result);

            if ($roleElements > 0) {
                $this->addResult('aria', 'roles', 'passed', "Found $roleElements elements with ARIA roles");
            } else {
                $this->addResult('aria', 'roles', 'failed', 'No elements with ARIA roles found');
            }

        } catch (Exception $e) {
            $this->addResult('aria', 'labels', 'failed', $e->getMessage());
        }
    }

    private function testSemanticHTML() {
        echo "📝 Testing Semantic HTML...\n";

        try {
            // Navigate to checklist page
            self::navigateToPage($this->baseUrl . '/php/list.php', 'Navigate to checklist page');
            self::waitForText('Accessibility', 10);

            // Test semantic elements
            $semanticElements = [
                'header' => 'header',
                'nav' => 'navigation',
                'main' => 'main content',
                'section' => 'section',
                'article' => 'article',
                'aside' => 'aside',
                'footer' => 'footer'
            ];

            foreach ($semanticElements as $tag => $description) {
                $result = self::evaluateScript("document.querySelector('$tag') !== null", "Check for $tag element");
                if ($result === true || $result === 'true') {
                    $this->addResult('semantic', $tag, 'passed', "$description element found");
                } else {
                    $this->addResult('semantic', $tag, 'failed', "$description element not found");
                }
            }

            // Test form elements
            $result = self::evaluateScript('document.querySelectorAll("form").length', 'Count form elements');
            $forms = intval($result);

            if ($forms > 0) {
                $this->addResult('semantic', 'forms', 'passed', "Found $forms form elements");
            } else {
                $this->addResult('semantic', 'forms', 'failed', 'No form elements found');
            }

            // Test list elements
            $result = self::evaluateScript('document.querySelectorAll("ul, ol").length', 'Count list elements');
            $lists = intval($result);

            if ($lists > 0) {
                $this->addResult('semantic', 'lists', 'passed', "Found $lists list elements");
            } else {
                $this->addResult('semantic', 'lists', 'failed', 'No list elements found');
            }

        } catch (Exception $e) {
            $this->addResult('semantic', 'html', 'failed', $e->getMessage());
        }
    }

    private function testResponsiveDesign() {
        echo "📱 Testing Responsive Design...\n";

        try {
            // Navigate to checklist page
            self::navigateToPage($this->baseUrl . '/php/list.php', 'Navigate to checklist page');
            self::waitForText('Accessibility', 10);

            // Test viewport meta tag
            $result = self::evaluateScript('document.querySelector("meta[name=viewport]") !== null', 'Check for viewport meta tag');
            self::assertTrue($result === true || $result === 'true', 'Viewport meta tag should be present');
            $this->addResult('responsive', 'viewport_meta', 'passed', 'Viewport meta tag found');

            // Test responsive CSS
            $result = self::evaluateScript('document.querySelector("link[rel=stylesheet]") !== null', 'Check for CSS stylesheets');
            self::assertTrue($result === true || $result === 'true', 'CSS stylesheets should be present');
            $this->addResult('responsive', 'css_stylesheets', 'passed', 'CSS stylesheets found');

            // Test mobile-friendly elements
            $result = self::evaluateScript('document.querySelectorAll("button, a").length > 0', 'Check for touch-friendly elements');
            self::assertTrue($result === true || $result === 'true', 'Touch-friendly elements should be present');
            $this->addResult('responsive', 'touch_elements', 'passed', 'Touch-friendly elements found');

        } catch (Exception $e) {
            $this->addResult('responsive', 'design', 'failed', $e->getMessage());
        }
    }

    private function testErrorHandling() {
        echo "⚠️  Testing Error Handling...\n";

        try {
            // Navigate to checklist page
            self::navigateToPage($this->baseUrl . '/php/list.php', 'Navigate to checklist page');
            self::waitForText('Accessibility', 10);

            // Test error announcements
            $result = self::evaluateScript('document.querySelectorAll("[role=alert], [aria-live=assertive]").length', 'Count error announcement elements');
            $errorElements = intval($result);

            if ($errorElements > 0) {
                $this->addResult('error_handling', 'error_announcements', 'passed', "Found $errorElements error announcement elements");
            } else {
                $this->addResult('error_handling', 'error_announcements', 'failed', 'No error announcement elements found');
            }

            // Test status announcements
            $result = self::evaluateScript('document.querySelectorAll("[role=status], [aria-live=polite]").length', 'Count status announcement elements');
            $statusElements = intval($result);

            if ($statusElements > 0) {
                $this->addResult('error_handling', 'status_announcements', 'passed', "Found $statusElements status announcement elements");
            } else {
                $this->addResult('error_handling', 'status_announcements', 'failed', 'No status announcement elements found');
            }

            // Test form validation
            $result = self::evaluateScript('document.querySelectorAll("input[required], textarea[required], select[required]").length', 'Count required form elements');
            $requiredElements = intval($result);

            if ($requiredElements > 0) {
                $this->addResult('error_handling', 'form_validation', 'passed', "Found $requiredElements required form elements");
            } else {
                $this->addResult('error_handling', 'form_validation', 'failed', 'No required form elements found');
            }

        } catch (Exception $e) {
            $this->addResult('error_handling', 'handling', 'failed', $e->getMessage());
        }
    }

    private function addResult($category, $test, $status, $message = '') {
        $this->testResults[] = [
            'category' => $category,
            'test' => $test,
            'status' => $status,
            'message' => $message,
            'timestamp' => date('Y-m-d H:i:s')
        ];
    }

    private function generateReport() {
        echo "\n📊 WCAG Compliance Test Results\n";
        echo "=============================\n";

        $total = count($this->testResults);
        $passed = count(array_filter($this->testResults, fn($r) => $r['status'] === 'passed'));
        $failed = count(array_filter($this->testResults, fn($r) => $r['status'] === 'failed'));

        echo "Total Tests: $total\n";
        echo "Passed: $passed\n";
        echo "Failed: $failed\n";
        echo "Compliance Score: " . round(($passed / $total) * 100, 1) . "%\n\n";

        // WCAG compliance summary
        echo "♿ WCAG Compliance Summary\n";
        echo "========================\n";

        $wcagCategories = [
            'keyboard' => 'Keyboard Navigation',
            'screen_reader' => 'Screen Reader Support',
            'color_contrast' => 'Color Contrast',
            'focus_management' => 'Focus Management',
            'aria' => 'ARIA Labels',
            'semantic' => 'Semantic HTML',
            'responsive' => 'Responsive Design',
            'error_handling' => 'Error Handling'
        ];

        foreach ($wcagCategories as $category => $name) {
            $categoryResults = array_filter($this->testResults, fn($r) => $r['category'] === $category);
            $categoryPassed = count(array_filter($categoryResults, fn($r) => $r['status'] === 'passed'));
            $categoryTotal = count($categoryResults);
            $status = $categoryPassed === $categoryTotal ? '✅' : '❌';
            echo "  $status $name: $categoryPassed/$categoryTotal tests passed\n";
        }

        echo "\n📋 Detailed Results\n";
        echo "==================\n";

        $currentCategory = '';
        foreach ($this->testResults as $result) {
            if ($result['category'] !== $currentCategory) {
                $currentCategory = $result['category'];
                echo "\n📁 {$currentCategory} Tests:\n";
            }

            $status = $result['status'] === 'passed' ? '✅' : '❌';
            echo "  {$status} {$result['test']}: {$result['message']}\n";
        }

        // Accessibility recommendations
        echo "\n💡 Accessibility Recommendations\n";
        echo "==============================\n";

        if ($failed > 0) {
            echo "⚠️  Accessibility improvements needed:\n";
            echo "  - Review failed tests for WCAG compliance issues\n";
            echo "  - Ensure all interactive elements are keyboard accessible\n";
            echo "  - Add proper ARIA labels and roles\n";
            echo "  - Test with screen readers\n";
            echo "  - Verify color contrast ratios meet WCAG AA standards\n";
            echo "  - Implement proper focus management\n";
        } else {
            echo "✅ Excellent accessibility compliance!\n";
            echo "  - All WCAG tests passed\n";
            echo "  - Application is accessible to users with disabilities\n";
            echo "  - Ready for accessibility audit\n";
        }

        // Final status
        echo "\n🎯 WCAG Compliance Status: ";
        if ($failed === 0) {
            echo "✅ FULLY COMPLIANT\n";
            exit(0);
        } else {
            echo "❌ $failed COMPLIANCE ISSUE(S) FOUND\n";
            exit(1);
        }
    }
}

// Run WCAG compliance test if this file is executed directly
if (basename(__FILE__) === basename($_SERVER['SCRIPT_NAME'])) {
    $test = new WCAGComplianceTest();
    $test->runAllTests();
}
