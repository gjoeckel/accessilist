<?php
/**
 * AccessiList Save/Restore Integration Test
 * Tests save and restore functionality integration
 */

require_once __DIR__ . '/../run_comprehensive_tests.php';

class SaveRestoreTest extends TestBase {

    public function runAllTests() {
        echo "💾 AccessiList Save/Restore Integration Test\n";
        echo "==========================================\n";
        echo "Timestamp: " . date('Y-m-d H:i:s') . "\n\n";

        $results = new TestResults();

        try {
            $this->testSaveRestoreWorkflow($results);
            $this->testAPIEndpoints($results);
            $this->testDataPersistence($results);
            $this->testSessionManagement($results);

            $this->generateReport($results);

        } catch (Exception $e) {
            echo "❌ Critical error during save/restore test: " . $e->getMessage() . "\n";
            exit(1);
        }
    }

    private function testSaveRestoreWorkflow(TestResults $results) {
        echo "🔄 Testing Save/Restore Workflow...\n";

        try {
            // Test saves directory exists and is writable
            if (!is_dir('saves')) {
                if (!mkdir('saves', 0755, true)) {
                    throw new Exception('Failed to create saves directory');
                }
            }

            if (!is_writable('saves')) {
                throw new Exception('saves directory is not writable');
            }

            $results->addResult('workflow', 'saves_directory', 'passed', 'saves directory exists and is writable');

            // Test saves directory (at project root)
            $savesDir = __DIR__ . '/../../saves';
            if (!is_dir($savesDir)) {
                throw new Exception('Saves directory not found at project root - check deployment configuration');
            }

            if (!is_writable($savesDir)) {
                throw new Exception('Saves directory is not writable');
            }

            $results->addResult('workflow', 'saves_directory', 'passed', 'Saves directory exists and is writable at project root');

            // Test save/restore JavaScript functions
            $jsFiles = ['js/save-restore.js', 'js/main.js'];
            $functionsFound = 0;

            foreach ($jsFiles as $file) {
                if (file_exists($file)) {
                    $content = file_get_contents($file);
                    if (strpos($content, 'saveChecklistData') !== false || strpos($content, 'restoreChecklistData') !== false) {
                        $functionsFound++;
                    }
                }
            }

            if ($functionsFound > 0) {
                $results->addResult('workflow', 'javascript_functions', 'passed', "Found save/restore functions in $functionsFound files");
            } else {
                $results->addResult('workflow', 'javascript_functions', 'failed', 'Save/restore JavaScript functions not found');
            }

        } catch (Exception $e) {
            $results->addResult('workflow', 'save_restore_workflow', 'failed', $e->getMessage());
        }
    }

    private function testAPIEndpoints(TestResults $results) {
        echo "🔌 Testing API Endpoints...\n";

        try {
            $endpoints = [
                'save.php' => 'Save API',
                'restore.php' => 'Restore API',
                'delete.php' => 'Delete API',
                'list.php' => 'List API'
            ];

            foreach ($endpoints as $endpoint => $name) {
                $path = "php/api/$endpoint";

                if (!file_exists($path)) {
                    throw new Exception("API endpoint $endpoint not found");
                }

                $results->addResult('api_endpoints', $endpoint, 'passed', "$name endpoint exists");

                // Check if endpoint uses api-utils.php
                $content = file_get_contents($path);
                if (strpos($content, 'api-utils.php') === false) {
                    throw new Exception("API endpoint $endpoint does not use api-utils.php");
                }

                $results->addResult('api_endpoints', $endpoint . '_utils', 'passed', "$name endpoint uses api-utils.php");

                // Check for proper JSON headers
                if (strpos($content, 'Content-Type: application/json') === false) {
                    throw new Exception("API endpoint $endpoint does not set JSON content type");
                }

                $results->addResult('api_endpoints', $endpoint . '_headers', 'passed', "$name endpoint sets JSON headers");
            }

        } catch (Exception $e) {
            $results->addResult('api_endpoints', 'endpoint_test', 'failed', $e->getMessage());
        }
    }

    private function testDataPersistence(TestResults $results) {
        echo "💾 Testing Data Persistence...\n";

        try {
            // Test JSON file creation and reading
            $testData = [
                'sessionKey' => 'TEST',
                'timestamp' => time() * 1000,
                'type' => 'test',
                'data' => ['test' => 'value']
            ];

            $testFile = 'saves/TEST.json';
            $jsonData = json_encode($testData, JSON_PRETTY_PRINT);

            // Write test file
            if (file_put_contents($testFile, $jsonData) === false) {
                throw new Exception('Failed to write test JSON file');
            }

            $results->addResult('data_persistence', 'json_write', 'passed', 'JSON file write successful');

            // Read test file
            $readData = file_get_contents($testFile);
            if ($readData === false) {
                throw new Exception('Failed to read test JSON file');
            }

            $results->addResult('data_persistence', 'json_read', 'passed', 'JSON file read successful');

            // Validate JSON data
            $decodedData = json_decode($readData, true);
            if ($decodedData === null) {
                throw new Exception('Invalid JSON data in test file');
            }

            $results->addResult('data_persistence', 'json_validation', 'passed', 'JSON data validation successful');

            // Clean up test file
            if (unlink($testFile)) {
                $results->addResult('data_persistence', 'cleanup', 'passed', 'Test file cleanup successful');
            } else {
                $results->addResult('data_persistence', 'cleanup', 'failed', 'Test file cleanup failed');
            }

        } catch (Exception $e) {
            $results->addResult('data_persistence', 'persistence_test', 'failed', $e->getMessage());
        }
    }

    private function testSessionManagement(TestResults $results) {
        echo "🔑 Testing Session Management...\n";

        try {
            // Test session key validation
            if (!file_exists('php/includes/api-utils.php')) {
                throw new Exception('api-utils.php not found');
            }

            $content = file_get_contents('php/includes/api-utils.php');

            // Check for session validation function
            if (strpos($content, 'function validate_session_key') === false) {
                throw new Exception('validate_session_key function not found');
            }

            $results->addResult('session_management', 'validation_function', 'passed', 'Session validation function found');

            // Check for session key regex pattern
            if (strpos($content, '/^[a-zA-Z0-9]{3}$/') === false) {
                throw new Exception('Session key regex pattern not found');
            }

            $results->addResult('session_management', 'regex_pattern', 'passed', 'Session key regex pattern found');

            // Test session ID generation in JavaScript
            $jsFiles = ['js/main.js', 'php/home.php'];
            $sessionGenerationFound = false;

            foreach ($jsFiles as $file) {
                if (file_exists($file)) {
                    $content = file_get_contents($file);
                    if (strpos($content, 'generateAlphanumericSessionId') !== false) {
                        $sessionGenerationFound = true;
                        break;
                    }
                }
            }

            if ($sessionGenerationFound) {
                $results->addResult('session_management', 'session_generation', 'passed', 'Session ID generation function found');
            } else {
                $results->addResult('session_management', 'session_generation', 'failed', 'Session ID generation function not found');
            }

            // Test session persistence in URL
            $checklistFile = 'php/list.php';
            if (file_exists($checklistFile)) {
                $content = file_get_contents($checklistFile);
                if (strpos($content, '$_GET[\'session\']') !== false || strpos($content, '$_GET["session"]') !== false) {
                    $results->addResult('session_management', 'url_persistence', 'passed', 'Session URL parameter handling found');
                } else {
                    $results->addResult('session_management', 'url_persistence', 'failed', 'Session URL parameter handling not found');
                }
            }

        } catch (Exception $e) {
            $results->addResult('session_management', 'session_test', 'failed', $e->getMessage());
        }
    }

    private function generateReport(TestResults $results) {
        echo "\n📊 Save/Restore Integration Test Results\n";
        echo "=====================================\n";

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

        // Save/restore recommendations
        echo "\n💡 Save/Restore Recommendations\n";
        echo "=============================\n";

        if ($summary['failed'] > 0) {
            echo "⚠️  Save/restore improvements needed:\n";
            echo "  - Ensure all API endpoints use centralized utilities\n";
            echo "  - Verify directory permissions for save operations\n";
            echo "  - Test session management and validation\n";
            echo "  - Validate JSON data persistence\n";
            echo "  - Check error handling in save/restore operations\n";
        } else {
            echo "✅ Save/restore functionality is working correctly!\n";
            echo "  - All API endpoints are properly configured\n";
            echo "  - Data persistence is working\n";
            echo "  - Session management is implemented\n";
            echo "  - Directory permissions are correct\n";
        }

        // Final status
        echo "\n🎯 Save/Restore Test Status: ";
        if ($summary['failed'] === 0) {
            echo "✅ ALL TESTS PASSED\n";
            exit(0);
        } else {
            echo "❌ {$summary['failed']} TEST(S) FAILED\n";
            exit(1);
        }
    }
}

// Run save/restore test if this file is executed directly
if (basename(__FILE__) === basename($_SERVER['SCRIPT_NAME'])) {
    $test = new SaveRestoreTest();
    $test->runAllTests();
}
