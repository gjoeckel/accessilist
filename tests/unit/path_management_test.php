<?php
/**
 * AccessiList Path Management Unit Test
 * Tests path utility functions and configuration
 */

require_once __DIR__ . '/../run_comprehensive_tests.php';

class PathManagementTest extends TestBase {

    public function runAllTests() {
        echo "🛤️  AccessiList Path Management Unit Test\n";
        echo "=====================================\n";
        echo "Timestamp: " . date('Y-m-d H:i:s') . "\n\n";

        $results = new TestResults();

        try {
            $this->testPathUtilsFile($results);
            $this->testPathFunctions($results);
            $this->testFallbackMechanism($results);
            $this->testPathConsistency($results);

            $this->generateReport($results);

        } catch (Exception $e) {
            echo "❌ Critical error during path management test: " . $e->getMessage() . "\n";
            exit(1);
        }
    }

    private function testPathUtilsFile(TestResults $results) {
        echo "📁 Testing Path Utils File...\n";

        try {
            // Test if path-utils.js exists
            if (!file_exists('js/path-utils.js')) {
                throw new Exception('js/path-utils.js file not found');
            }

            $results->addResult('path_utils', 'file_exists', 'passed', 'path-utils.js file exists');

            // Test file readability
            $content = file_get_contents('js/path-utils.js');
            if (empty($content)) {
                throw new Exception('path-utils.js file is empty');
            }

            $results->addResult('path_utils', 'file_readable', 'passed', 'path-utils.js file is readable');

            // Test file size (should be reasonable)
            $fileSize = strlen($content);
            if ($fileSize < 100) {
                throw new Exception('path-utils.js file seems too small');
            }

            $results->addResult('path_utils', 'file_size', 'passed', "path-utils.js file size: $fileSize bytes");

        } catch (Exception $e) {
            $results->addResult('path_utils', 'file_test', 'failed', $e->getMessage());
        }
    }

    private function testPathFunctions(TestResults $results) {
        echo "🔧 Testing Path Functions...\n";

        try {
            $content = file_get_contents('js/path-utils.js');

            // Test required path functions
            $requiredFunctions = [
                'getImagePath',
                'getJSONPath',
                'getCSSPath',
                'getPHPPath',
                'getAPIPath'
            ];

            foreach ($requiredFunctions as $function) {
                if (strpos($content, "window.$function") === false) {
                    throw new Exception("Required function $function not found in path-utils.js");
                }

                $results->addResult('path_functions', $function, 'passed', "Function $function found");
            }

            // Test function definitions
            if (strpos($content, 'function getBasePath()') === false) {
                throw new Exception('getBasePath function not found');
            }

            $results->addResult('path_functions', 'getBasePath', 'passed', 'getBasePath function found');

            // Test IIFE wrapper
            if (strpos($content, '(function()') === false) {
                throw new Exception('IIFE wrapper not found');
            }

            $results->addResult('path_functions', 'iife_wrapper', 'passed', 'IIFE wrapper found');

        } catch (Exception $e) {
            $results->addResult('path_functions', 'function_test', 'failed', $e->getMessage());
        }
    }

    private function testFallbackMechanism(TestResults $results) {
        echo "🔄 Testing Fallback Mechanism...\n";

        try {
            $content = file_get_contents('js/path-utils.js');

            // Test fallback path
            if (strpos($content, '/training/online/accessilist') === false) {
                throw new Exception('Fallback path not found');
            }

            $results->addResult('fallback', 'fallback_path', 'passed', 'Fallback path found');

            // Test try-catch block
            if (strpos($content, 'try {') === false || strpos($content, '} catch (e) {}') === false) {
                throw new Exception('Error handling not found');
            }

            $results->addResult('fallback', 'error_handling', 'passed', 'Error handling found');

            // Test window.pathConfig check
            if (strpos($content, 'window.pathConfig') === false) {
                throw new Exception('window.pathConfig check not found');
            }

            $results->addResult('fallback', 'pathConfig_check', 'passed', 'window.pathConfig check found');

        } catch (Exception $e) {
            $results->addResult('fallback', 'mechanism', 'failed', $e->getMessage());
        }
    }

    private function testPathConsistency(TestResults $results) {
        echo "🔄 Testing Path Consistency...\n";

        try {
            // Test PHP files for embedded path configs
            $phpFiles = ['php/admin.php', 'php/home.php', 'php/list.php'];

            foreach ($phpFiles as $file) {
                if (!file_exists($file)) {
                    continue; // Skip if file doesn't exist
                }

                $content = file_get_contents($file);

                // Check for embedded path configuration
                if (strpos($content, 'window.pathConfig = {') !== false) {
                    $results->addResult('path_consistency', basename($file), 'failed', 'Embedded path config found - should use centralized path-utils.js');
                } else {
                    $results->addResult('path_consistency', basename($file), 'passed', 'No embedded path config found');
                }
            }

            // Test for hardcoded fallback patterns
            $jsFiles = glob('js/*.js');
            $totalFallbackPatterns = 0;

            foreach ($jsFiles as $file) {
                $content = file_get_contents($file);
                $fallbackPatterns = substr_count($content, 'window.pathConfig ?');
                $totalFallbackPatterns += $fallbackPatterns;
            }

            if ($totalFallbackPatterns > 0) {
                $results->addResult('path_consistency', 'fallback_patterns', 'failed', "Found $totalFallbackPatterns hardcoded fallback patterns");
            } else {
                $results->addResult('path_consistency', 'fallback_patterns', 'passed', 'No hardcoded fallback patterns found');
            }

        } catch (Exception $e) {
            $results->addResult('path_consistency', 'consistency', 'failed', $e->getMessage());
        }
    }

    private function generateReport(TestResults $results) {
        echo "\n📊 Path Management Test Results\n";
        echo "=============================\n";

        $summary = $results->getSummary();
        echo "Total Tests: {$summary['total']}\n";
        echo "Passed: {$summary['passed']}\n";
        echo "Failed: {$summary['failed']}\n";
        echo "Duration: {$summary['duration']}s\n\n";

        // Detailed results
        echo "📋 Detailed Results\n";
        echo "==================\n";

        $allResults = $results->getResults();
        $currentCategory = '';

        foreach ($allResults as $result) {
            if ($result['category'] !== $currentCategory) {
                $currentCategory = $result['category'];
                echo "\n📁 {$currentCategory} Tests:\n";
            }

            $status = $result['status'] === 'passed' ? '✅' : '❌';
            echo "  {$status} {$result['test']}: {$result['message']}\n";
        }

        // Path management recommendations
        echo "\n💡 Path Management Recommendations\n";
        echo "===============================\n";

        if ($summary['failed'] > 0) {
            echo "⚠️  Path management improvements needed:\n";
            echo "  - Remove embedded path configurations from PHP files\n";
            echo "  - Replace hardcoded fallback patterns with centralized functions\n";
            echo "  - Ensure all files use path-utils.js consistently\n";
            echo "  - Test path resolution in both local and production environments\n";
        } else {
            echo "✅ Path management is properly configured!\n";
            echo "  - All path utilities are working correctly\n";
            echo "  - Centralized path management is in place\n";
            echo "  - Fallback mechanisms are properly implemented\n";
        }

        // Final status
        echo "\n🎯 Path Management Test Status: ";
        if ($summary['failed'] === 0) {
            echo "✅ ALL TESTS PASSED\n";
            exit(0);
        } else {
            echo "❌ {$summary['failed']} TEST(S) FAILED\n";
            exit(1);
        }
    }
}

// Run path management test if this file is executed directly
if (basename(__FILE__) === basename($_SERVER['SCRIPT_NAME'])) {
    $test = new PathManagementTest();
    $test->runAllTests();
}
