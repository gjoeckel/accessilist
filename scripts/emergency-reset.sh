#!/bin/bash
# AccessiList Emergency Reset Script
# Emergency rollback and reset functionality for critical issues

set -euo pipefail

echo "🚨 AccessiList Emergency Reset"
echo "=============================="
echo "Timestamp: $(date)"
echo ""
echo "⚠️  WARNING: This script will perform emergency reset operations!"
echo "   Use only in case of critical issues or system corruption."
echo ""

# Configuration
BACKUP_DIR="backup/emergency"
ROLLBACK_TAG="pre-emergency-reset"

# Function to confirm emergency reset
confirm_emergency_reset() {
    echo "🔴 EMERGENCY RESET CONFIRMATION"
    echo "==============================="
    echo ""
    echo "This will perform the following actions:"
    echo "  - Create emergency backup of current state"
    echo "  - Reset to last known good state"
    echo "  - Clean up corrupted files"
    echo "  - Restore from backup if needed"
    echo ""
    echo "⚠️  THIS ACTION CANNOT BE UNDONE!"
    echo ""

    read -p "Type 'EMERGENCY' to confirm: " confirmation
    if [ "$confirmation" != "EMERGENCY" ]; then
        echo "❌ Emergency reset cancelled"
        exit 0
    fi

    echo ""
    echo "🔴 EMERGENCY RESET CONFIRMED - PROCEEDING..."
    echo ""
}

# Function to create emergency backup
create_emergency_backup() {
    echo "💾 Creating Emergency Backup..."

    # Create backup directory
    mkdir -p "$BACKUP_DIR"

    # Create timestamp for backup
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local backup_path="$BACKUP_DIR/emergency_backup_$timestamp"

    echo "  📁 Backup path: $backup_path"

    # Create backup of current state
    mkdir -p "$backup_path"

    # Backup critical files
    local critical_files=(
        "index.php"
        "php/"
        "js/"
        "css/"
        "images/"
        "json/"
        "tests/"
        ".cursor/"
        "package.json"
        "config.json"
    )

    for item in "${critical_files[@]}"; do
        if [ -e "$item" ]; then
            echo "  📋 Backing up $item..."
            cp -r "$item" "$backup_path/" 2>/dev/null || true
        fi
    done

    # Create backup manifest
    cat > "$backup_path/BACKUP_MANIFEST.txt" << EOF
Emergency Backup Created: $(date)
Backup Path: $backup_path
Git Status: $(git status --porcelain 2>/dev/null || echo "Not a git repository")
Git Branch: $(git branch --show-current 2>/dev/null || echo "Not a git repository")
Git Commit: $(git rev-parse HEAD 2>/dev/null || echo "Not a git repository")
EOF

    echo "  ✅ Emergency backup created: $backup_path"
    echo "$backup_path"
}

# Function to reset to last known good state
reset_to_last_good_state() {
    echo "🔄 Resetting to Last Known Good State..."

    # Check if we're in a git repository
    if git rev-parse --git-dir >/dev/null 2>&1; then
        echo "  🔍 Git repository detected"

        # List available tags
        echo "  📋 Available rollback points:"
        git tag -l | grep -E "(pre-|rollback-|backup-)" | tail -5 | while read -r tag; do
            echo "    - $tag"
        done

        # Try to reset to last known good state
        local last_good_tag=$(git tag -l | grep -E "(pre-|rollback-|backup-)" | tail -1)

        if [ -n "$last_good_tag" ]; then
            echo "  🔄 Resetting to: $last_good_tag"
            git reset --hard "$last_good_tag" || {
                echo "  ❌ Failed to reset to $last_good_tag"
                return 1
            }
            echo "  ✅ Reset to $last_good_tag successful"
        else
            echo "  ⚠️  No rollback tags found, trying last commit"
            git reset --hard HEAD~1 || {
                echo "  ❌ Failed to reset to last commit"
                return 1
            }
            echo "  ✅ Reset to last commit successful"
        fi
    else
        echo "  ⚠️  Not a git repository, cannot perform git reset"
        return 1
    fi
}

# Function to clean up corrupted files
cleanup_corrupted_files() {
    echo "🧹 Cleaning Up Corrupted Files..."

    # Remove temporary files (exclude node_modules)
    find . -name "*.tmp" -not -path "./node_modules/*" -delete 2>/dev/null || true
    find . -name "*.temp" -not -path "./node_modules/*" -delete 2>/dev/null || true
    find . -name "*.lock" -not -path "./node_modules/*" -delete 2>/dev/null || true

    # Remove corrupted test files
    find tests/screenshots -name "*.png" -size 0 -delete 2>/dev/null || true

    # Clean up PHP session files (exclude node_modules)
    find . -name "sess_*" -not -path "./node_modules/*" -delete 2>/dev/null || true

    # Clean up log files (exclude node_modules)
    find . -name "*.log" -size 0 -not -path "./node_modules/*" -delete 2>/dev/null || true

    echo "  ✅ Corrupted files cleaned up"
}

# Function to restore from backup
restore_from_backup() {
    local backup_path="$1"

    echo "📦 Restoring from Emergency Backup..."
    echo "  📁 Backup path: $backup_path"

    if [ ! -d "$backup_path" ]; then
        echo "  ❌ Backup directory not found: $backup_path"
        return 1
    fi

    # Restore critical files
    local critical_files=(
        "index.php"
        "php/"
        "js/"
        "css/"
        "images/"
        "json/"
        "tests/"
        ".cursor/"
        "package.json"
        "config.json"
    )

    for item in "${critical_files[@]}"; do
        if [ -e "$backup_path/$item" ]; then
            echo "  📋 Restoring $item..."
            rm -rf "$item" 2>/dev/null || true
            cp -r "$backup_path/$item" "./" 2>/dev/null || true
        fi
    done

    echo "  ✅ Restore from backup completed"
}

# Function to validate system integrity
validate_system_integrity() {
    echo "🔍 Validating System Integrity..."

    local total_issues=0

    # Check critical files
    local critical_files=(
        "index.php"
        "php/home.php"
        "php/admin.php"
        "php/list.php"
        "js/path-utils.js"
        "php/includes/api-utils.php"
    )

    for file in "${critical_files[@]}"; do
        if [ -f "$file" ]; then
            echo "  ✅ $file exists"
        else
            echo "  ❌ $file missing"
            total_issues=$((total_issues + 1))
        fi
    done

    # Check directory structure
    local critical_dirs=(
        "php/"
        "js/"
        "css/"
        "images/"
        "json/"
        "tests/"
    )

    for dir in "${critical_dirs[@]}"; do
        if [ -d "$dir" ]; then
            echo "  ✅ $dir/ directory exists"
        else
            echo "  ❌ $dir/ directory missing"
            total_issues=$((total_issues + 1))
        fi
    done

    # Check file permissions
    if [ -w "." ]; then
        echo "  ✅ Write permissions OK"
    else
        echo "  ❌ Write permissions issue"
        total_issues=$((total_issues + 1))
    fi

    return $total_issues
}

# Function to run basic tests
run_basic_tests() {
    echo "🧪 Running Basic Tests..."

    # Test PHP syntax
    if command -v php &> /dev/null; then
        echo "  🔍 Testing PHP syntax..."
        local php_files=$(find php/ -name "*.php" 2>/dev/null || true)
        local syntax_errors=0

        for file in $php_files; do
            if ! php -l "$file" >/dev/null 2>&1; then
                echo "    ❌ Syntax error in $file"
                syntax_errors=$((syntax_errors + 1))
            fi
        done

        if [ $syntax_errors -eq 0 ]; then
            echo "  ✅ PHP syntax OK"
        else
            echo "  ❌ $syntax_errors PHP syntax errors found"
        fi
    else
        echo "  ⚠️  PHP not available for syntax testing"
    fi

    # Test JavaScript syntax (basic check)
    if command -v node &> /dev/null; then
        echo "  🔍 Testing JavaScript syntax..."
        local js_files=$(find js/ -name "*.js" 2>/dev/null || true)
        local js_errors=0

        for file in $js_files; do
            if ! node -c "$file" >/dev/null 2>&1; then
                echo "    ❌ Syntax error in $file"
                js_errors=$((js_errors + 1))
            fi
        done

        if [ $js_errors -eq 0 ]; then
            echo "  ✅ JavaScript syntax OK"
        else
            echo "  ❌ $js_errors JavaScript syntax errors found"
        fi
    else
        echo "  ⚠️  Node.js not available for JavaScript testing"
    fi
}

# Function to generate emergency report
generate_emergency_report() {
    local backup_path="$1"
    local total_issues="$2"

    echo ""
    echo "📊 Emergency Reset Report"
    echo "========================"
    echo "Timestamp: $(date)"
    echo "Backup Path: $backup_path"
    echo "Total Issues Found: $total_issues"
    echo ""

    if [ "$total_issues" -eq 0 ]; then
        echo "✅ Status: EMERGENCY RESET SUCCESSFUL"
        echo "🎯 System integrity restored"
        echo "💡 System is ready for normal operation"
    else
        echo "⚠️  Status: EMERGENCY RESET PARTIALLY SUCCESSFUL"
        echo "🔧 $total_issues issues remain"
        echo "💡 Manual intervention may be required"
    fi

    echo ""
    echo "📋 Next Steps:"
    echo "  1. Test basic functionality"
    echo "  2. Run comprehensive test suite"
    echo "  3. Check logs for any remaining issues"
    echo "  4. Consider restoring from backup if needed"
    echo ""
    echo "💾 Backup Location: $backup_path"
    echo "🔄 Rollback Tag: $ROLLBACK_TAG"
}

# Function to display usage information
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -f, --force           Skip confirmation prompt"
    echo "  -b, --backup-only     Only create backup (don't reset)"
    echo "  -r, --restore PATH    Restore from specific backup path"
    echo "  -h, --help            Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                    # Full emergency reset with confirmation"
    echo "  $0 -f                 # Force emergency reset without confirmation"
    echo "  $0 -b                 # Create backup only"
    echo "  $0 -r /path/backup    # Restore from specific backup"
}

# Main execution
main() {
    local force_reset=false
    local backup_only=false
    local restore_path=""

    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -f|--force)
                force_reset=true
                shift
                ;;
            -b|--backup-only)
                backup_only=true
                shift
                ;;
            -r|--restore)
                restore_path="$2"
                shift 2
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done

    # Handle restore operation
    if [ -n "$restore_path" ]; then
        echo "📦 Restoring from backup: $restore_path"
        restore_from_backup "$restore_path"
        validate_system_integrity
        local total_issues=$?
        generate_emergency_report "$restore_path" $total_issues
        exit $total_issues
    fi

    # Handle backup-only operation
    if [ "$backup_only" = true ]; then
        echo "💾 Creating emergency backup only..."
        local backup_path=$(create_emergency_backup)
        echo "✅ Emergency backup created: $backup_path"
        exit 0
    fi

    # Confirm emergency reset unless forced
    if [ "$force_reset" = false ]; then
        confirm_emergency_reset
    fi

    # Create emergency backup
    local backup_path=$(create_emergency_backup)

    # Create rollback tag
    if git rev-parse --git-dir >/dev/null 2>&1; then
        git tag -a "$ROLLBACK_TAG" -m "Emergency reset point - $(date)"
    fi

    # Perform emergency reset
    if ! reset_to_last_good_state; then
        echo "⚠️  Git reset failed, attempting file restoration..."
        restore_from_backup "$backup_path"
    fi

    # Clean up corrupted files
    cleanup_corrupted_files

    # Validate system integrity
    validate_system_integrity
    local total_issues=$?

    # Run basic tests
    run_basic_tests

    # Generate emergency report
    generate_emergency_report "$backup_path" $total_issues

    exit $total_issues
}

# Run main function
main "$@"
