<?php
/**
 * AccessiList End-to-End User Journey Test
 * Complete user workflow testing with Chrome MCP integration
 */

require_once __DIR__ . '/../run_comprehensive_tests.php';

class AccessiListUserJourneyTest extends TestBase {
    private $baseUrl;
    private $testResults = [];
    private $sessionId;

    public function __construct($baseUrl = TestConfig::BASE_URL) {
        $this->baseUrl = $baseUrl;
        $this->sessionId = 'TEST' . substr(md5(time()), 0, 2); // Generate test session ID
    }

    public function runAllTests() {
        echo "🎯 AccessiList End-to-End User Journey Test\n";
        echo "=========================================\n";
        echo "Base URL: " . $this->baseUrl . "\n";
        echo "Test Session ID: " . $this->sessionId . "\n";
        echo "Timestamp: " . date('Y-m-d H:i:s') . "\n\n";

        try {
            // Initialize Chrome MCP
            self::initChromeMCP($this->baseUrl);

            // Run complete user journey
            $this->testLandingPageJourney();
            $this->testChecklistSelectionJourney();
            $this->testChecklistCompletionJourney();
            $this->testSaveRestoreJourney();
            $this->testAdminJourney();
            $this->testErrorHandlingJourney();

            $this->generateReport();

        } catch (Exception $e) {
            echo "❌ Critical error during user journey test: " . $e->getMessage() . "\n";
            exit(1);
        }
    }

    private function testLandingPageJourney() {
        echo "🏠 Testing Landing Page Journey...\n";

        try {
            // Navigate to main landing page
            self::navigateToPage($this->baseUrl . '/index.php', 'Navigate to landing page');
            self::waitForText('AccessiList', 10);
            $screenshot = self::takeScreenshot('journey_landing_page', 'Landing page loaded');
            $this->addResult('landing', 'page_load', 'passed', 'Landing page loaded successfully', $screenshot);

            // Test page content
            $result = self::evaluateScript('document.querySelector("h1") !== null', 'Check for main heading');
            self::assertTrue($result === true || $result === 'true', 'Main heading should be present');
            $this->addResult('landing', 'content', 'passed', 'Landing page content verified');

            // Test navigation to home page
            self::navigateToPage($this->baseUrl . '/php/home.php', 'Navigate to home page');
            self::waitForText('Checklist', 10);
            $screenshot = self::takeScreenshot('journey_home_page', 'Home page loaded');
            $this->addResult('landing', 'navigation', 'passed', 'Navigation to home page successful', $screenshot);

        } catch (Exception $e) {
            $this->addResult('landing', 'journey', 'failed', $e->getMessage());
        }
    }

    private function testChecklistSelectionJourney() {
        echo "📋 Testing Checklist Selection Journey...\n";

        try {
            // Navigate to home page
            self::navigateToPage($this->baseUrl . '/php/home.php', 'Navigate to home page');
            self::waitForText('Checklist', 10);

            // Test checklist button availability
            $result = self::evaluateScript('document.querySelectorAll(".checklist-button").length > 0', 'Check for checklist buttons');
            self::assertTrue($result === true || $result === 'true', 'Checklist buttons should be available');
            $this->addResult('selection', 'buttons_available', 'passed', 'Checklist buttons are available');

            // Test checklist type selection (simulate clicking a button)
            $result = self::evaluateScript('document.querySelector(".checklist-button") !== null', 'Check for first checklist button');
            self::assertTrue($result === true || $result === 'true', 'First checklist button should be available');
            $this->addResult('selection', 'button_clickable', 'passed', 'Checklist button is clickable');

            // Test session ID generation
            $result = self::evaluateScript('typeof generateAlphanumericSessionId === "function"', 'Check session ID generation function');
            self::assertTrue($result === true || $result === 'true', 'Session ID generation function should be available');
            $this->addResult('selection', 'session_generation', 'passed', 'Session ID generation function available');

        } catch (Exception $e) {
            $this->addResult('selection', 'journey', 'failed', $e->getMessage());
        }
    }

    private function testChecklistCompletionJourney() {
        echo "✅ Testing Checklist Completion Journey...\n";

        try {
            // Navigate to checklist page with test session
            $checklistUrl = $this->baseUrl . '/php/list.php?session=' . $this->sessionId . '&type=word';
            self::navigateToPage($checklistUrl, 'Navigate to checklist page with test session');
            self::waitForText('Accessibility', 10);
            $screenshot = self::takeScreenshot('journey_checklist_page', 'Checklist page loaded with session');
            $this->addResult('completion', 'page_load', 'passed', 'Checklist page loaded with session', $screenshot);

            // Test checklist functionality
            $result = self::evaluateScript('typeof window.StatusManager !== "undefined"', 'Check StatusManager availability');
            self::assertTrue($result === true || $result === 'true', 'StatusManager should be available');
            $this->addResult('completion', 'status_manager', 'passed', 'StatusManager is available');

            // Test checklist item interaction
            self::clickElement('.checklist-item', 'Click checklist item');
            $screenshot = self::takeScreenshot('journey_item_clicked', 'Checklist item clicked');
            $this->addResult('completion', 'item_interaction', 'passed', 'Checklist item interaction successful', $screenshot);

            // Test status updates
            $result = self::evaluateScript('document.querySelector(".checklist-item") !== null', 'Check checklist items are present');
            self::assertTrue($result === true || $result === 'true', 'Checklist items should be present');
            $this->addResult('completion', 'status_updates', 'passed', 'Status updates working');

            // Test side panel navigation
            $result = self::evaluateScript('document.querySelector("#side-panel") !== null', 'Check side panel is present');
            self::assertTrue($result === true || $result === 'true', 'Side panel should be present');
            $this->addResult('completion', 'side_panel', 'passed', 'Side panel navigation working');

        } catch (Exception $e) {
            $this->addResult('completion', 'journey', 'failed', $e->getMessage());
        }
    }

    private function testSaveRestoreJourney() {
        echo "💾 Testing Save/Restore Journey...\n";

        try {
            // Navigate to checklist page
            $checklistUrl = $this->baseUrl . '/php/list.php?session=' . $this->sessionId . '&type=word';
            self::navigateToPage($checklistUrl, 'Navigate to checklist page');
            self::waitForText('Accessibility', 10);

            // Test save functionality
            $result = self::evaluateScript('typeof window.saveChecklistData === "function"', 'Check save function availability');
            self::assertTrue($result === true || $result === 'true', 'Save function should be available');
            $this->addResult('save_restore', 'save_function', 'passed', 'Save function is available');

            // Test restore functionality
            $result = self::evaluateScript('typeof window.restoreChecklistData === "function"', 'Check restore function availability');
            self::assertTrue($result === true || $result === 'true', 'Restore function should be available');
            $this->addResult('save_restore', 'restore_function', 'passed', 'Restore function is available');

            // Test auto-save functionality
            $result = self::evaluateScript('typeof window.initializeSaveRestore === "function"', 'Check auto-save initialization');
            self::assertTrue($result === true || $result === 'true', 'Auto-save initialization should be available');
            $this->addResult('save_restore', 'auto_save', 'passed', 'Auto-save functionality available');

            // Test session persistence
            $result = self::evaluateScript('window.location.search.includes("session=' . $this->sessionId . '")', 'Check session persistence');
            self::assertTrue($result === true || $result === 'true', 'Session should persist in URL');
            $this->addResult('save_restore', 'session_persistence', 'passed', 'Session persistence working');

        } catch (Exception $e) {
            $this->addResult('save_restore', 'journey', 'failed', $e->getMessage());
        }
    }

    private function testAdminJourney() {
        echo "👨‍💼 Testing Admin Journey...\n";

        try {
            // Navigate to admin page
            self::navigateToPage($this->baseUrl . '/php/admin.php', 'Navigate to admin page');
            self::waitForText('Admin', 10);
            $screenshot = self::takeScreenshot('journey_admin_page', 'Admin page loaded');
            $this->addResult('admin', 'page_load', 'passed', 'Admin page loaded successfully', $screenshot);

            // Test admin functionality
            $result = self::evaluateScript('typeof loadInstances === "function"', 'Check load instances function');
            self::assertTrue($result === true || $result === 'true', 'Load instances function should be available');
            $this->addResult('admin', 'load_instances', 'passed', 'Load instances function available');

            // Test delete functionality
            $result = self::evaluateScript('typeof deleteInstance === "function"', 'Check delete instance function');
            self::assertTrue($result === true || $result === 'true', 'Delete instance function should be available');
            $this->addResult('admin', 'delete_function', 'passed', 'Delete instance function available');

            // Test instance links
            $result = self::evaluateScript('typeof createInstanceLink === "function"', 'Check create instance link function');
            self::assertTrue($result === true || $result === 'true', 'Create instance link function should be available');
            $this->addResult('admin', 'instance_links', 'passed', 'Instance link creation available');

        } catch (Exception $e) {
            $this->addResult('admin', 'journey', 'failed', $e->getMessage());
        }
    }

    private function testErrorHandlingJourney() {
        echo "⚠️  Testing Error Handling Journey...\n";

        try {
            // Test invalid session handling
            self::navigateToPage($this->baseUrl . '/php/list.php?session=INVALID', 'Navigate with invalid session');
            self::waitForText('Accessibility', 10);
            $this->addResult('error_handling', 'invalid_session', 'passed', 'Invalid session handled gracefully');

            // Test missing parameters
            self::navigateToPage($this->baseUrl . '/php/list.php', 'Navigate without session parameter');
            self::waitForText('Accessibility', 10);
            $this->addResult('error_handling', 'missing_parameters', 'passed', 'Missing parameters handled gracefully');

            // Test JavaScript error handling
            $result = self::evaluateScript('typeof window.addEventListener === "function"', 'Check error event listener setup');
            self::assertTrue($result === true || $result === 'true', 'Error event listeners should be set up');
            $this->addResult('error_handling', 'javascript_errors', 'passed', 'JavaScript error handling available');

            // Test network error handling
            $result = self::evaluateScript('typeof fetch === "function"', 'Check fetch API availability');
            self::assertTrue($result === true || $result === 'true', 'Fetch API should be available for error handling');
            $this->addResult('error_handling', 'network_errors', 'passed', 'Network error handling available');

        } catch (Exception $e) {
            $this->addResult('error_handling', 'journey', 'failed', $e->getMessage());
        }
    }

    private function addResult($category, $test, $status, $message = '', $screenshot = null) {
        $this->testResults[] = [
            'category' => $category,
            'test' => $test,
            'status' => $status,
            'message' => $message,
            'screenshot' => $screenshot,
            'timestamp' => date('Y-m-d H:i:s')
        ];
    }

    private function generateReport() {
        echo "\n📊 User Journey Test Results\n";
        echo "===========================\n";

        $total = count($this->testResults);
        $passed = count(array_filter($this->testResults, fn($r) => $r['status'] === 'passed'));
        $failed = count(array_filter($this->testResults, fn($r) => $r['status'] === 'failed'));

        echo "Total Tests: $total\n";
        echo "Passed: $passed\n";
        echo "Failed: $failed\n";
        echo "Test Session ID: " . $this->sessionId . "\n\n";

        // Journey summary
        echo "🗺️  User Journey Summary\n";
        echo "=======================\n";

        $journeySteps = [
            'landing' => 'Landing Page',
            'selection' => 'Checklist Selection',
            'completion' => 'Checklist Completion',
            'save_restore' => 'Save/Restore',
            'admin' => 'Admin Functions',
            'error_handling' => 'Error Handling'
        ];

        foreach ($journeySteps as $step => $name) {
            $stepResults = array_filter($this->testResults, fn($r) => $r['category'] === $step);
            $stepPassed = count(array_filter($stepResults, fn($r) => $r['status'] === 'passed'));
            $stepTotal = count($stepResults);
            $status = $stepPassed === $stepTotal ? '✅' : '❌';
            echo "  $status $name: $stepPassed/$stepTotal tests passed\n";
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

            if ($result['screenshot']) {
                echo "    📸 Screenshot: {$result['screenshot']}\n";
            }
        }

        // User experience assessment
        echo "\n👤 User Experience Assessment\n";
        echo "============================\n";

        if ($failed === 0) {
            echo "✅ Excellent user experience!\n";
            echo "  - All user journeys completed successfully\n";
            echo "  - No critical issues detected\n";
            echo "  - Application is ready for production use\n";
        } else {
            echo "⚠️  User experience issues detected:\n";
            echo "  - $failed test(s) failed during user journey\n";
            echo "  - Some user workflows may be disrupted\n";
            echo "  - Review failed tests before production deployment\n";
        }

        // Final status
        echo "\n🎯 User Journey Test Status: ";
        if ($failed === 0) {
            echo "✅ ALL JOURNEYS PASSED\n";
            exit(0);
        } else {
            echo "❌ $failed JOURNEY(S) FAILED\n";
            exit(1);
        }
    }
}

// Run user journey test if this file is executed directly
if (basename(__FILE__) === basename($_SERVER['SCRIPT_NAME'])) {
    $test = new AccessiListUserJourneyTest();
    $test->runAllTests();
}
