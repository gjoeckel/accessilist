#!/bin/bash
# Fix Apache Symlink - Point to Projects directory
# Run this manually: sudo bash scripts/fix-apache-symlink.sh

set -e

echo "🔧 Fixing Apache Symlink for AccessiList"
echo "=========================================="
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "❌ This script must be run with sudo"
    echo "Run: sudo bash scripts/fix-apache-symlink.sh"
    exit 1
fi

# Current symlink info
echo "Current symlink:"
ls -la /Library/WebServer/Documents/accessilist 2>/dev/null || echo "  (not found)"
echo ""

# Remove old symlink
echo "Removing old symlink..."
rm -f /Library/WebServer/Documents/accessilist
echo "✅ Old symlink removed"
echo ""

# Create new symlink pointing to Projects directory
echo "Creating new symlink..."
ln -sf /Users/a00288946/Projects/accessilist /Library/WebServer/Documents/accessilist
echo "✅ New symlink created"
echo ""

# Verify
echo "Verification:"
ls -la /Library/WebServer/Documents/accessilist
echo ""

# Test if project files are accessible
if [ -f /Library/WebServer/Documents/accessilist/index.php ]; then
    echo "✅ Project files accessible via symlink"
else
    echo "❌ Project files NOT accessible"
    exit 1
fi

# Restart Apache to clear any caches
echo ""
echo "Restarting Apache..."
apachectl restart
sleep 2
echo "✅ Apache restarted"
echo ""

# Test endpoint
echo "Testing endpoint..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/training/online/accessilist/home)
echo "  http://localhost/training/online/accessilist/home → HTTP $HTTP_CODE"

if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "302" ]; then
    echo ""
    echo "╔════════════════════════════════════════════════════════╗"
    echo "║  ✅ APACHE SYMLINK FIX COMPLETE!                   ✅  ║"
    echo "╚════════════════════════════════════════════════════════╝"
    echo ""
    echo "You can now run: proj-test-mirror"
else
    echo ""
    echo "⚠️  Apache responding but returned HTTP $HTTP_CODE"
    echo "Check Apache error logs: tail -20 /private/var/log/apache2/error_log"
fi
