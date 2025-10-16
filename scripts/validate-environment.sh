#!/bin/bash
# AccessiList Environment Validation Script
# Validates development and production environment setup

set -euo pipefail

echo "🌍 AccessiList Environment Validation"
echo "===================================="
echo "Timestamp: $(date)"
echo ""

# Configuration
TOTAL_ISSUES=0
ENVIRONMENT="unknown"

# Function to detect environment
detect_environment() {
    if [[ "$(hostname)" == *"localhost"* ]] || [[ "$(hostname)" == *"local"* ]]; then
        ENVIRONMENT="local"
    elif [[ "$(pwd)" == *"/training/online/accessilist"* ]]; then
        ENVIRONMENT="production"
    else
        ENVIRONMENT="development"
    fi

    echo "📍 Detected Environment: $ENVIRONMENT"
    echo ""
}

# Function to check PHP environment
check_php_environment() {
    echo "🐘 Checking PHP Environment..."

    # Check if PHP is available
    if command -v php &> /dev/null; then
        local php_version=$(php -r "echo PHP_VERSION;")
        echo "  ✅ PHP is available (Version: $php_version)"

        # Check PHP version compatibility
        if php -r "exit(version_compare(PHP_VERSION, '7.4.0', '>=') ? 0 : 1);"; then
            echo "  ✅ PHP version is compatible (>= 7.4.0)"
        else
            echo "  ❌ PHP version is too old (requires >= 7.4.0)"
            TOTAL_ISSUES=$((TOTAL_ISSUES + 1))
        fi
    else
        echo "  ❌ PHP is not available"
        TOTAL_ISSUES=$((TOTAL_ISSUES + 1))
    fi

    # Check PHP extensions
    local required_extensions=("json" "mbstring" "fileinfo")
    for ext in "${required_extensions[@]}"; do
        if command -v php >/dev/null 2>&1 && php -m | grep -q "$ext"; then
            echo "  ✅ PHP extension $ext is loaded"
        else
            echo "  ⚠️  PHP extension $ext check skipped (PHP not in PATH or extension not found)"
        fi
    done
}

# Function to check file permissions
check_file_permissions() {
    echo "📁 Checking File Permissions..."

    # Check if saves directory is writable
    if [ -d "saves" ] && [ -w "saves" ]; then
        echo "  ✅ saves/ directory is writable"
    else
        echo "  ❌ saves/ directory is not writable"
        TOTAL_ISSUES=$((TOTAL_ISSUES + 1))
    fi

    # Check if saves directory (at root) is writable
    if [ -d "saves" ] && [ -w "saves" ]; then
        echo "  ✅ saves/ directory is writable"
    else
        echo "  ❌ saves/ directory is not writable or missing"
        TOTAL_ISSUES=$((TOTAL_ISSUES + 1))
    fi

    # Check if tests/screenshots directory is writable
    if [ -d "tests/screenshots" ] && [ -w "tests/screenshots" ]; then
        echo "  ✅ tests/screenshots/ directory is writable"
    else
        echo "  ❌ tests/screenshots/ directory is not writable"
        TOTAL_ISSUES=$((TOTAL_ISSUES + 1))
    fi
}

# Function to check required files
check_required_files() {
    echo "📄 Checking Required Files..."

    local required_files=(
        "index.php"
        "php/home.php"
        "php/admin.php"
        "php/list.php"
        "js/path-utils.js"
        "php/includes/api-utils.php"
        "tests/run_comprehensive_tests.php"
        "tests/start_server.sh"
    )

    for file in "${required_files[@]}"; do
        if [ -f "$file" ]; then
            echo "  ✅ $file exists"
        else
            echo "  ❌ $file is missing"
            TOTAL_ISSUES=$((TOTAL_ISSUES + 1))
        fi
    done
}

# Function to check API endpoints
check_api_endpoints() {
    echo "🔌 Checking API Endpoints..."

    local api_endpoints=("save.php" "restore.php" "delete.php" "list.php")

    for endpoint in "${api_endpoints[@]}"; do
        local file="php/api/$endpoint"
        if [ -f "$file" ]; then
            echo "  ✅ $endpoint exists"
        else
            echo "  ❌ $endpoint is missing"
            TOTAL_ISSUES=$((TOTAL_ISSUES + 1))
        fi
    done
}

# Function to check path configuration
check_path_configuration() {
    echo "🛤️  Checking Path Configuration..."

    # Check if path-utils.js exists and is readable
    if [ -f "js/path-utils.js" ] && [ -r "js/path-utils.js" ]; then
        echo "  ✅ path-utils.js exists and is readable"

        # Check for required path functions
        local required_functions=("getImagePath" "getJSONPath" "getCSSPath" "getPHPPath" "getAPIPath")
        for func in "${required_functions[@]}"; do
            if grep -q "window.$func" "js/path-utils.js"; then
                echo "  ✅ Function $func found in path-utils.js"
            else
                echo "  ❌ Function $func not found in path-utils.js"
                TOTAL_ISSUES=$((TOTAL_ISSUES + 1))
            fi
        done
    else
        echo "  ❌ path-utils.js is missing or not readable"
        TOTAL_ISSUES=$((TOTAL_ISSUES + 1))
    fi
}

# Function to check testing infrastructure
check_testing_infrastructure() {
    echo "🧪 Checking Testing Infrastructure..."

    # Check if tests directory exists
    if [ -d "tests" ]; then
        echo "  ✅ tests/ directory exists"

        # Check for test subdirectories
        local test_dirs=("unit" "integration" "performance" "e2e" "accessibility" "puppeteer")
        for dir in "${test_dirs[@]}"; do
            if [ -d "tests/$dir" ]; then
                echo "  ✅ tests/$dir/ directory exists"
            else
                echo "  ❌ tests/$dir/ directory is missing"
                TOTAL_ISSUES=$((TOTAL_ISSUES + 1))
            fi
        done

        # Check for test files
        local test_files=("run_comprehensive_tests.php" "start_server.sh")
        for file in "${test_files[@]}"; do
            if [ -f "tests/$file" ]; then
                echo "  ✅ tests/$file exists"
            else
                echo "  ❌ tests/$file is missing"
                TOTAL_ISSUES=$((TOTAL_ISSUES + 1))
            fi
        done
    else
        echo "  ❌ tests/ directory is missing"
        TOTAL_ISSUES=$((TOTAL_ISSUES + 1))
    fi
}

# Function to check environment-specific settings
check_environment_settings() {
    echo "⚙️  Checking Environment-Specific Settings..."

    if [ "$ENVIRONMENT" = "production" ]; then
        echo "  🔍 Production Environment Checks:"

        # Check for production path configuration
        if grep -q "/training/online/accessilist" "js/path-utils.js"; then
            echo "    ✅ Production path configuration found"
        else
            echo "    ❌ Production path configuration missing"
            TOTAL_ISSUES=$((TOTAL_ISSUES + 1))
        fi

        # Check for security settings
        if [ -f ".htaccess" ]; then
            echo "    ✅ .htaccess file exists"
        else
            echo "    ⚠️  .htaccess file missing (may be intentional)"
        fi

    elif [ "$ENVIRONMENT" = "local" ]; then
        echo "  🔍 Local Environment Checks:"

        # Check for local development setup
        if [ -f "local-dev.php" ] || [ -f "local-index.php" ]; then
            echo "    ✅ Local development files found"
        else
            echo "    ⚠️  Local development files missing (may be intentional)"
        fi
    fi

    # Check MCP integration (common to all environments)
    echo "  🔧 MCP Integration Checks:"
    if [ -d ".cursor/rules" ]; then
        echo "    ✅ Cursor rules directory found"
        if grep -r "mcp\|MCP" ".cursor/rules" >/dev/null 2>&1; then
            echo "    ✅ MCP references found in Cursor rules"
        else
            echo "    ⚠️  No MCP references found in Cursor rules"
        fi
    else
        echo "    ⚠️  Cursor rules directory not found"
    fi

    # Check for MCP-specific scripts
    local mcp_scripts=("check-mcp-health.sh" "start-chrome-debug.sh" "restart-mcp-servers.sh" "emergency-reset.sh")
    for script in "${mcp_scripts[@]}"; do
        if [ -f "scripts/$script" ]; then
            echo "    ✅ MCP script $script found"
        else
            echo "    ⚠️  MCP script $script not found"
        fi
    done
}

# Function to generate summary report
generate_summary() {
    echo ""
    echo "📊 Environment Validation Summary"
    echo "================================"
    echo "Environment: $ENVIRONMENT"
    echo "Total Issues Found: $TOTAL_ISSUES"

    if [ "$TOTAL_ISSUES" -eq 0 ]; then
        echo "✅ Status: EXCELLENT - Environment is properly configured!"
        echo "🎯 All required components are available and working"
    elif [ "$TOTAL_ISSUES" -le 3 ]; then
        echo "✅ Status: GOOD - Minor environment issues detected"
        echo "💡 Consider addressing remaining issues for optimal setup"
    else
        echo "⚠️  Status: NEEDS ATTENTION - Multiple environment issues detected"
        echo "🔧 Consider fixing issues before proceeding with development"
    fi

    echo ""
    echo "💡 Recommendations:"
    echo "  - Ensure all required files and directories exist"
    echo "  - Check file permissions for writable directories"
    echo "  - Verify PHP extensions are loaded"
    echo "  - Test API endpoints are accessible"
    echo "  - Validate path configuration for current environment"
}

# Main execution
main() {
    detect_environment
    check_php_environment
    check_file_permissions
    check_required_files
    check_api_endpoints
    check_path_configuration
    check_testing_infrastructure
    check_environment_settings
    generate_summary

    # Exit with appropriate code
    if [ "$TOTAL_ISSUES" -gt 3 ]; then
        exit 1
    else
        exit 0
    fi
}

# Run main function
main "$@"
