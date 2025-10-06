#!/bin/bash
# AccessiList Testing Server Startup Script
# Starts PHP development server for testing

set -euo pipefail

# Configuration
PORT=8000
HOST=localhost
BASE_URL="http://${HOST}:${PORT}"

echo "🚀 Starting AccessiList Testing Server..."
echo "📍 Server will be available at: ${BASE_URL}"
echo "📁 Document root: $(pwd)"
echo ""

# Check if port is already in use
if netstat -an 2>/dev/null | grep -q ":${PORT} "; then
    echo "⚠️  Port ${PORT} is already in use. Attempting to kill existing process..."
    # Try to kill process using port 8000
    PID=$(netstat -ano 2>/dev/null | grep ":${PORT} " | awk '{print $5}' | head -1)
    if [ ! -z "$PID" ] && [ "$PID" != "0" ]; then
        echo "🔪 Killing process ${PID} on port ${PORT}..."
        taskkill //PID "$PID" //F 2>/dev/null || true
        sleep 2
    fi
fi

# Verify PHP is available
if ! command -v php &> /dev/null; then
    echo "❌ Error: PHP is not installed or not in PATH"
    echo "Please install PHP and ensure it's available in your PATH"
    exit 1
fi

# Check PHP version
PHP_VERSION=$(php -r "echo PHP_VERSION;")
echo "🐘 PHP Version: ${PHP_VERSION}"

# Verify required files exist
REQUIRED_FILES=("index.php" "php/home.php" "php/mychecklist.php" "js/path-utils.js")
for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo "❌ Error: Required file missing: $file"
        exit 1
    fi
done

echo "✅ All required files present"
echo ""

# Start the server
echo "🌐 Starting PHP development server..."
echo "Press Ctrl+C to stop the server"
echo ""

# Start server in background and capture PID
php -S "${HOST}:${PORT}" &
SERVER_PID=$!

# Function to cleanup on exit
cleanup() {
    echo ""
    echo "🛑 Stopping server (PID: ${SERVER_PID})..."
    kill $SERVER_PID 2>/dev/null || true
    echo "✅ Server stopped"
    exit 0
}

# Set up signal handlers
trap cleanup SIGINT SIGTERM

# Wait a moment for server to start
sleep 2

# Test if server is responding
echo "🔍 Testing server response..."
if curl -s -f "${BASE_URL}/index.php" > /dev/null 2>&1; then
    echo "✅ Server is responding correctly"
else
    echo "⚠️  Server started but may not be responding correctly"
    echo "   You can still proceed with testing"
fi

echo ""
echo "🎯 Server is ready for testing!"
echo "📋 Available test commands:"
echo "   php tests/run_comprehensive_tests.php"
echo "   php tests/chrome-mcp/run_chrome_mcp_tests.php"
echo ""

# Keep the script running
wait $SERVER_PID
