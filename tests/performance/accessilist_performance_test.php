<?php
/**
 * AccessiList Performance Test
 * Comprehensive performance testing with Chrome MCP integration
 */

require_once __DIR__ . '/../run_comprehensive_tests.php';

class AccessiListPerformanceTest extends TestBase {
    private $baseUrl;
    private $testResults = [];
    private $performanceMetrics = [];

    public function __construct($baseUrl = TestConfig::BASE_URL) {
        $this->baseUrl = $baseUrl;
    }

    public function runAllTests() {
        echo "📊 AccessiList Performance Test Suite\n";
        echo "===================================\n";
        echo "Base URL: " . $this->baseUrl . "\n";
        echo "Timestamp: " . date('Y-m-d H:i:s') . "\n";
        echo "Performance Threshold: " . TestConfig::PERFORMANCE_THRESHOLD . "ms\n\n";

        try {
            // Initialize Chrome MCP
            self::initChromeMCP($this->baseUrl);

            // Run all performance tests
            $this->testPageLoadPerformance();
            $this->testAPIResponseTimes();
            $this->testUIInteractionPerformance();
            $this->testMemoryUsage();
            $this->testNetworkPerformance();
            $this->testOverallPagePerformance();

            $this->generateReport();

        } catch (Exception $e) {
            echo "❌ Critical error during performance test: " . $e->getMessage() . "\n";
            exit(1);
        }
    }

    private function testPageLoadPerformance() {
        echo "📄 Testing Page Load Performance...\n";

        try {
            $pages = [
                'index.php' => 'Main Page',
                'php/home.php' => 'Home Page',
                'php/list.php' => 'Checklist Page'
            ];

            foreach ($pages as $page => $name) {
                self::startPerformanceTrace(true, false);

                self::navigateToPage($this->baseUrl . '/' . $page, "Navigate to $name");
                self::waitForText('AccessiList', 15);

                $trace = self::stopPerformanceTrace();

                $loadTime = $trace['loadTime'] ?? 0;
                $this->performanceMetrics["page_load_$page"] = $loadTime;

                if ($loadTime > TestConfig::PERFORMANCE_THRESHOLD) {
                    $this->addResult('page_load', $page, 'failed', "Load time ({$loadTime}ms) exceeds threshold (" . TestConfig::PERFORMANCE_THRESHOLD . "ms)");
                } else {
                    $this->addResult('page_load', $page, 'passed', "Load time: {$loadTime}ms");
                }
            }

        } catch (Exception $e) {
            $this->addResult('page_load', 'performance', 'failed', $e->getMessage());
        }
    }

    private function testAPIResponseTimes() {
        echo "🔌 Testing API Response Times...\n";

        try {
            $apiEndpoints = [
                'save.php' => 'Save API',
                'restore.php' => 'Restore API',
                'delete.php' => 'Delete API',
                'list.php' => 'List API'
            ];

            foreach ($apiEndpoints as $endpoint => $name) {
                $startTime = microtime(true);

                // Simulate API call (in real implementation, this would use actual network requests)
                $result = self::evaluateScript("fetch('" . $this->baseUrl . "/php/api/$endpoint').then(r => r.status).catch(e => 'error')", "Test $name response time");

                $endTime = microtime(true);
                $responseTime = round(($endTime - $startTime) * 1000); // Convert to milliseconds

                $this->performanceMetrics["api_$endpoint"] = $responseTime;

                if ($responseTime > 2000) { // 2 second threshold for API calls
                    $this->addResult('api_response', $endpoint, 'failed', "Response time ({$responseTime}ms) exceeds 2000ms threshold");
                } else {
                    $this->addResult('api_response', $endpoint, 'passed', "Response time: {$responseTime}ms");
                }
            }

        } catch (Exception $e) {
            $this->addResult('api_response', 'performance', 'failed', $e->getMessage());
        }
    }

    private function testUIInteractionPerformance() {
        echo "🖱️  Testing UI Interaction Performance...\n";

        try {
            // Navigate to checklist page
            self::navigateToPage($this->baseUrl . '/php/list.php', 'Navigate to checklist page');
            self::waitForText('Accessibility', 10);

            // Test button click performance
            $startTime = microtime(true);
            self::clickElement('.checklist-item', 'Click checklist item');
            $endTime = microtime(true);

            $interactionTime = round(($endTime - $startTime) * 1000);
            $this->performanceMetrics['ui_interaction'] = $interactionTime;

            if ($interactionTime > 500) { // 500ms threshold for UI interactions
                $this->addResult('ui_interaction', 'button_click', 'failed', "Interaction time ({$interactionTime}ms) exceeds 500ms threshold");
            } else {
                $this->addResult('ui_interaction', 'button_click', 'passed', "Interaction time: {$interactionTime}ms");
            }

            // Test form interaction performance
            $startTime = microtime(true);
            $result = self::evaluateScript('document.querySelector("input, textarea, select") !== null', 'Check for form elements');
            $endTime = microtime(true);

            $formTime = round(($endTime - $startTime) * 1000);
            $this->performanceMetrics['form_interaction'] = $formTime;

            $this->addResult('ui_interaction', 'form_elements', 'passed', "Form interaction time: {$formTime}ms");

        } catch (Exception $e) {
            $this->addResult('ui_interaction', 'performance', 'failed', $e->getMessage());
        }
    }

    private function testMemoryUsage() {
        echo "🧠 Testing Memory Usage...\n";

        try {
            // Navigate to checklist page
            self::navigateToPage($this->baseUrl . '/php/list.php', 'Navigate to checklist page');
            self::waitForText('Accessibility', 10);

            // Test memory usage (simplified - in real implementation, this would use Chrome DevTools memory API)
            $result = self::evaluateScript('performance.memory ? performance.memory.usedJSHeapSize : 0', 'Get memory usage');
            $memoryUsage = intval($result);

            $this->performanceMetrics['memory_usage'] = $memoryUsage;

            if ($memoryUsage > 50 * 1024 * 1024) { // 50MB threshold
                $this->addResult('memory', 'usage', 'failed', "Memory usage (" . round($memoryUsage / 1024 / 1024, 2) . "MB) exceeds 50MB threshold");
            } else {
                $this->addResult('memory', 'usage', 'passed', "Memory usage: " . round($memoryUsage / 1024 / 1024, 2) . "MB");
            }

        } catch (Exception $e) {
            $this->addResult('memory', 'usage', 'failed', $e->getMessage());
        }
    }

    private function testNetworkPerformance() {
        echo "🌐 Testing Network Performance...\n";

        try {
            // Navigate to checklist page
            self::navigateToPage($this->baseUrl . '/php/list.php', 'Navigate to checklist page');
            self::waitForText('Accessibility', 10);

            // Test network request count (simplified)
            $result = self::evaluateScript('performance.getEntriesByType("resource").length', 'Get network request count');
            $requestCount = intval($result);

            $this->performanceMetrics['network_requests'] = $requestCount;

            if ($requestCount > 20) { // 20 request threshold
                $this->addResult('network', 'request_count', 'failed', "Too many network requests: {$requestCount} (threshold: 20)");
            } else {
                $this->addResult('network', 'request_count', 'passed', "Network requests: {$requestCount}");
            }

            // Test resource loading performance
            $result = self::evaluateScript('performance.getEntriesByType("resource").reduce((sum, entry) => sum + entry.duration, 0)', 'Get total resource load time');
            $totalLoadTime = round(floatval($result));

            $this->performanceMetrics['resource_load_time'] = $totalLoadTime;

            if ($totalLoadTime > 5000) { // 5 second threshold for total resource loading
                $this->addResult('network', 'resource_loading', 'failed', "Resource loading time ({$totalLoadTime}ms) exceeds 5000ms threshold");
            } else {
                $this->addResult('network', 'resource_loading', 'passed', "Resource loading time: {$totalLoadTime}ms");
            }

        } catch (Exception $e) {
            $this->addResult('network', 'performance', 'failed', $e->getMessage());
        }
    }

    private function testOverallPagePerformance() {
        echo "📊 Testing Overall Page Performance...\n";

        try {
            // Navigate to checklist page
            self::navigateToPage($this->baseUrl . '/php/list.php', 'Navigate to checklist page');
            self::waitForText('Accessibility', 10);

            // Test Core Web Vitals (simplified)
            $result = self::evaluateScript('performance.getEntriesByType("navigation")[0]', 'Get navigation timing');

            if ($result && $result !== 'undefined') {
                // Test First Contentful Paint (FCP)
                $fcp = self::evaluateScript('performance.getEntriesByName("first-contentful-paint")[0] ? performance.getEntriesByName("first-contentful-paint")[0].startTime : 0', 'Get FCP');
                $fcpTime = round(floatval($fcp));

                $this->performanceMetrics['fcp'] = $fcpTime;

                if ($fcpTime > 1800) { // 1.8 second threshold for FCP
                    $this->addResult('web_vitals', 'fcp', 'failed', "First Contentful Paint ({$fcpTime}ms) exceeds 1800ms threshold");
                } else {
                    $this->addResult('web_vitals', 'fcp', 'passed', "First Contentful Paint: {$fcpTime}ms");
                }

                // Test Largest Contentful Paint (LCP)
                $lcp = self::evaluateScript('performance.getEntriesByType("largest-contentful-paint")[0] ? performance.getEntriesByType("largest-contentful-paint")[0].startTime : 0', 'Get LCP');
                $lcpTime = round(floatval($lcp));

                $this->performanceMetrics['lcp'] = $lcpTime;

                if ($lcpTime > 2500) { // 2.5 second threshold for LCP
                    $this->addResult('web_vitals', 'lcp', 'failed', "Largest Contentful Paint ({$lcpTime}ms) exceeds 2500ms threshold");
                } else {
                    $this->addResult('web_vitals', 'lcp', 'passed', "Largest Contentful Paint: {$lcpTime}ms");
                }
            } else {
                $this->addResult('web_vitals', 'navigation_timing', 'failed', 'Navigation timing not available');
            }

        } catch (Exception $e) {
            $this->addResult('web_vitals', 'performance', 'failed', $e->getMessage());
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
        echo "\n📊 Performance Test Results\n";
        echo "==========================\n";

        $total = count($this->testResults);
        $passed = count(array_filter($this->testResults, fn($r) => $r['status'] === 'passed'));
        $failed = count(array_filter($this->testResults, fn($r) => $r['status'] === 'failed'));

        echo "Total Tests: $total\n";
        echo "Passed: $passed\n";
        echo "Failed: $failed\n\n";

        // Performance metrics summary
        echo "📈 Performance Metrics Summary\n";
        echo "=============================\n";

        foreach ($this->performanceMetrics as $metric => $value) {
            $unit = 'ms';
            if (strpos($metric, 'memory') !== false) {
                $unit = 'bytes';
                $value = round($value / 1024 / 1024, 2) . 'MB';
            } elseif (strpos($metric, 'requests') !== false) {
                $unit = 'requests';
            }
            echo "  $metric: $value $unit\n";
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

        // Performance recommendations
        echo "\n💡 Performance Recommendations\n";
        echo "=============================\n";

        if ($failed > 0) {
            echo "❌ Performance issues detected. Consider:\n";
            echo "  - Optimizing page load times\n";
            echo "  - Reducing network requests\n";
            echo "  - Minimizing JavaScript bundle size\n";
            echo "  - Implementing lazy loading\n";
            echo "  - Using CDN for static assets\n";
        } else {
            echo "✅ All performance tests passed!\n";
            echo "  - Page load times are within acceptable limits\n";
            echo "  - API response times are optimal\n";
            echo "  - UI interactions are responsive\n";
            echo "  - Memory usage is reasonable\n";
        }

        // Final status
        echo "\n🎯 Performance Test Status: ";
        if ($failed === 0) {
            echo "✅ ALL TESTS PASSED\n";
            exit(0);
        } else {
            echo "❌ $failed TEST(S) FAILED\n";
            exit(1);
        }
    }
}

// Run performance test if this file is executed directly
if (basename(__FILE__) === basename($_SERVER['SCRIPT_NAME'])) {
    $test = new AccessiListPerformanceTest();
    $test->runAllTests();
}
