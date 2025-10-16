#!/bin/bash
# Install git hooks for test enforcement

HOOKS_DIR=".git/hooks"
SCRIPT_DIR="scripts/git-hooks"

echo "📦 Installing git hooks for automated testing..."
echo ""

# Copy pre-commit hook
cp "$SCRIPT_DIR/pre-commit" "$HOOKS_DIR/pre-commit"
chmod +x "$HOOKS_DIR/pre-commit"
echo "✅ Installed pre-commit hook"
echo "   → Tests will run before EVERY commit"

# Copy pre-merge-commit hook
cp "$SCRIPT_DIR/pre-merge-commit" "$HOOKS_DIR/pre-merge-commit"
chmod +x "$HOOKS_DIR/pre-merge-commit"
echo "✅ Installed pre-merge-commit hook"
echo "   → Tests will run before merging to main"

echo ""
echo "🎉 Git hooks installed successfully!"
echo ""
echo "What happens now:"
echo "  • git commit → runs 75 tests automatically"
echo "  • git merge → runs 75 tests before merging to main"
echo "  • Commits blocked if tests fail"
echo ""
echo "To bypass (not recommended):"
echo "  git commit --no-verify"
echo ""

