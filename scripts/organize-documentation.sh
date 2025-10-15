#!/bin/bash
# Documentation Organization Script
# Moves and organizes documentation into proper structure

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOCS_DIR="$PROJECT_ROOT/docs"

echo "📚 Organizing Documentation Structure"
echo "===================================="

# Create documentation structure
mkdir -p "$DOCS_DIR"/{architecture,development,deployment,api,user-guides}

echo "✅ Created documentation directory structure"

# Move architecture documentation
echo "🏗️  Organizing architecture documentation..."
if [ -f "$PROJECT_ROOT/architecture_diagram.html" ]; then
    mv "$PROJECT_ROOT/architecture_diagram.html" "$DOCS_DIR/architecture/"
    echo "  ✅ Moved architecture_diagram.html"
fi

if [ -f "$PROJECT_ROOT/autonomous-mcp.md" ]; then
    mv "$PROJECT_ROOT/autonomous-mcp.md" "$DOCS_DIR/architecture/"
    echo "  ✅ Moved autonomous-mcp.md"
fi

# Move development documentation
echo "🔧 Organizing development documentation..."
if [ -f "$PROJECT_ROOT/AI-AUTONOMY-SETUP.md" ]; then
    mv "$PROJECT_ROOT/AI-AUTONOMY-SETUP.md" "$DOCS_DIR/development/"
    echo "  ✅ Moved AI-AUTONOMY-SETUP.md"
fi

if [ -f "$PROJECT_ROOT/MCP-TROUBLESHOOTING.md" ]; then
    mv "$PROJECT_ROOT/MCP-TROUBLESHOOTING.md" "$DOCS_DIR/development/"
    echo "  ✅ Moved MCP-TROUBLESHOOTING.md"
fi

if [ -f "$PROJECT_ROOT/srd-development-tools.md" ]; then
    mv "$PROJECT_ROOT/srd-development-tools.md" "$DOCS_DIR/development/"
    echo "  ✅ Moved srd-development-tools.md"
fi

# Move deployment documentation
echo "🚀 Organizing deployment documentation..."
if [ -f "$PROJECT_ROOT/DEPLOYMENT.md" ]; then
    mv "$PROJECT_ROOT/DEPLOYMENT.md" "$DOCS_DIR/deployment/"
    echo "  ✅ Moved DEPLOYMENT.md"
fi

if [ -f "$PROJECT_ROOT/ROLLBACK_PLAN.md" ]; then
    mv "$PROJECT_ROOT/ROLLBACK_PLAN.md" "$DOCS_DIR/deployment/"
    echo "  ✅ Moved ROLLBACK_PLAN.md"
fi

# Create documentation index
echo "📋 Creating documentation index..."
cat > "$DOCS_DIR/README.md" << 'EOF'
# AccessiList Documentation

This directory contains all project documentation organized by category.

## 📁 Directory Structure

- **`architecture/`** - System architecture, diagrams, and design documents
- **`development/`** - Development setup, tools, and troubleshooting guides
- **`deployment/`** - Deployment guides, rollback plans, and production setup
- **`api/`** - API documentation and integration guides
- **`user-guides/`** - User manuals and feature documentation

## 🚀 Quick Start

1. **Development Setup**: See `development/AI-AUTONOMY-SETUP.md`
2. **Architecture Overview**: See `architecture/architecture_diagram.html`
3. **Deployment Guide**: See `deployment/DEPLOYMENT.md`
4. **Troubleshooting**: See `development/MCP-TROUBLESHOOTING.md`

## 📚 Documentation Standards

- Use Markdown (`.md`) for text documentation
- Use HTML (`.html`) for interactive diagrams
- Include table of contents for long documents
- Keep documentation up-to-date with code changes
- Use clear, descriptive filenames

## 🔄 Maintenance

Run `./scripts/organize-documentation.sh` to reorganize documentation after adding new files.
EOF

echo "✅ Created documentation index"

# Create .gitignore for docs (if needed)
if [ ! -f "$DOCS_DIR/.gitignore" ]; then
    cat > "$DOCS_DIR/.gitignore" << 'EOF'
# Documentation-specific ignores
*.tmp
*.bak
.DS_Store
EOF
    echo "✅ Created docs .gitignore"
fi

echo ""
echo "🎯 Documentation Organization Complete!"
echo "====================================="
echo "✅ Organized documentation into logical structure"
echo "✅ Created documentation index"
echo "✅ Moved files to appropriate directories"
echo ""
echo "📚 Documentation is now accessible via MCP tools"
echo "🔍 Use: mcp_filesystem_list_directory with path: /Users/a00288946/Projects/accessilist/docs"