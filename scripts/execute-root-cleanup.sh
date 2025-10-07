#!/bin/bash

# Root Directory Cleanup Execution
# Intelligently categorizes files as DELETE or ARCHIVE based on analysis
# Provides reasoning and requires approval before executing

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Configuration
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ANALYSIS_FILE="$PROJECT_ROOT/cleanup-analysis.json"
RECOMMENDATIONS_FILE="$PROJECT_ROOT/cleanup-recommendations.json"
TIMESTAMP=$(date -u +"%Y-%m-%d_%H%M%S")

echo -e "${BLUE}🧹 Root Directory Cleanup Execution${NC}"
echo "=================================================="
echo "Project: $PROJECT_ROOT"
echo ""

# Check if analysis file exists
if [ ! -f "$ANALYSIS_FILE" ]; then
  echo -e "${RED}❌ Analysis file not found!${NC}"
  echo "Run: bash scripts/analyze-root-cleanup.sh first"
  exit 1
fi

# Function to categorize a single file
categorize_file() {
  local filename=$1

  # === DELETE CANDIDATES (no future value) ===

  # Test/debug artifacts
  if [[ "$filename" =~ ^(test\.html|debug_.*\.png)$ ]]; then
    echo "DELETE|Temporary test/debug file with no historical value"
    return
  fi

  # Duplicate configuration files
  if [[ "$filename" == "cursor-settings-optimized.json" ]]; then
    echo "DELETE|Duplicate config - cursor-settings.json is active version"
    return
  fi

  # Test deployment files
  if [[ "$filename" =~ (test-deploy|deployment-test)\.md$ ]]; then
    echo "DELETE|Temporary test documentation, no historical value"
    return
  fi

  # Quick fix notes
  if [[ "$filename" =~ ^(env-fix|fixes)\.md$ ]]; then
    echo "DELETE|Quick notes superseded by proper documentation"
    return
  fi

  # Time-specific verification reports
  if [[ "$filename" =~ (autonomy-test-results|autonomous-execution-verification)\.md$ ]]; then
    echo "DELETE|Time-specific test results, completed and verified"
    return
  fi

  # === ARCHIVE CANDIDATES (potential future reference) ===

  # Completed implementation reports
  if [[ "$filename" =~ (COMPLETE|SUMMARY|SUCCESS)\.md$ ]]; then
    echo "ARCHIVE|Completed implementation report - historical record"
    return
  fi

  # Analysis/evaluation documents
  if [[ "$filename" =~ (ANALYSIS|EVALUATION|PROPOSAL)\.md$ ]]; then
    echo "ARCHIVE|Analysis document - explains past decisions"
    return
  fi

  # Technical fix documentation
  if [[ "$filename" =~ (APACHE-403-FIX|SUDO-AUTHORIZATION-OPTIONS|apache-server-mac-native)\.md$ ]]; then
    echo "ARCHIVE|Technical setup documentation - valuable reference"
    return
  fi

  # Migration records
  if [[ "$filename" =~ (MIGRATION|DEPLOYMENT-PACKAGE|REPOSITORY-MIGRATION)\.md$ ]]; then
    echo "ARCHIVE|Migration record - important historical reference"
    return
  fi

  # Solution documentation
  if [[ "$filename" =~ (SOLUTION|FIX|ISSUES|DIFFICULTY)\.md$ ]]; then
    echo "ARCHIVE|Problem-solution documentation - troubleshooting reference"
    return
  fi

  # Validation reports
  if [[ "$filename" =~ (VALIDATION|VERIFICATION)\.md$ ]]; then
    echo "ARCHIVE|Validation report - documents testing approach"
    return
  fi

  # Server configuration
  if [[ "$filename" =~ (CONNECTION|REMOTE-CONFIGURATION|PRODUCTION-APACHE-CONFIG)\.md$ ]]; then
    echo "ARCHIVE|Server configuration - may be needed for reference"
    return
  fi

  # Rollback plans
  if [[ "$filename" =~ ROLLBACK.*\.md$ ]]; then
    echo "ARCHIVE|Rollback procedure - keep as safety reference"
    return
  fi

  # Process/workflow documentation
  if [[ "$filename" =~ (ai-changelog.*|mcp-tool-strategy|cursor-ide-template)\.md$ ]]; then
    echo "ARCHIVE|Workflow documentation - may inform future decisions"
    return
  fi

  # Planning documents
  if [[ "$filename" =~ (CHECKLIST|DRYing-types|port-accessilist)\.md$ ]]; then
    echo "ARCHIVE|Planning document - context for project evolution"
    return
  fi

  # Default to archive for safety
  echo "ARCHIVE|Default to archive for safety - contains project context"
}

echo -e "${BLUE}📋 Generating Recommendations${NC}"
echo "=================================================="
echo ""

# Initialize recommendation arrays
DELETE_COUNT=0
ARCHIVE_COUNT=0

# Start JSON output
cat > "$RECOMMENDATIONS_FILE" << 'EOF'
{
  "timestamp": "",
  "delete": [],
  "archive": []
}
EOF

# Update timestamp
python3 -c "
import json
with open('$RECOMMENDATIONS_FILE', 'r') as f:
    data = json.load(f)
data['timestamp'] = '$TIMESTAMP'
with open('$RECOMMENDATIONS_FILE', 'w') as f:
    json.dump(data, f, indent=2)
"

# Process files from analysis
echo -e "${YELLOW}Analyzing files for recommendations...${NC}"
echo ""

# Get all archival candidate files
python3 << 'PYTHON_PROCESS' > /tmp/files_to_categorize.txt
import json

with open('/Users/a00288946/Desktop/accessilist/cleanup-analysis.json', 'r') as f:
    data = json.load(f)

# Collect all files to process
all_files = []

# Archival candidates
for category, subcategories in data['categories']['archival_candidates'].items():
    all_files.extend(subcategories)

# Misc files
all_files.extend(data['categories']['misc_files'])

# Config files that should be reviewed
all_files.extend(data['categories']['configuration_files']['review_recommended'])

# Output list
for filename in all_files:
    print(filename)
PYTHON_PROCESS

# Process each file
while IFS= read -r filename; do
  if [ -z "$filename" ]; then continue; fi

  result=$(categorize_file "$filename")
  action=$(echo "$result" | cut -d'|' -f1)
  reason=$(echo "$result" | cut -d'|' -f2)

  if [ "$action" == "DELETE" ]; then
    echo -e "${RED}🗑️  DELETE:${NC} $filename"
    echo -e "    ${YELLOW}Reason:${NC} $reason"
    ((DELETE_COUNT++))

    # Add to JSON
    python3 -c "
import json
with open('$RECOMMENDATIONS_FILE', 'r') as f:
    data = json.load(f)
data['delete'].append({'file': '$filename', 'reason': '''$reason'''})
with open('$RECOMMENDATIONS_FILE', 'w') as f:
    json.dump(data, f, indent=2)
"
  else
    echo -e "${BLUE}📦 ARCHIVE:${NC} $filename"
    echo -e "    ${YELLOW}Reason:${NC} $reason"
    ((ARCHIVE_COUNT++))

    # Add to JSON
    python3 -c "
import json
with open('$RECOMMENDATIONS_FILE', 'r') as f:
    data = json.load(f)
data['archive'].append({'file': '$filename', 'reason': '''$reason'''})
with open('$RECOMMENDATIONS_FILE', 'w') as f:
    json.dump(data, f, indent=2)
"
  fi
  echo ""

done < /tmp/files_to_categorize.txt

# Cleanup temp file
rm -f /tmp/files_to_categorize.txt

echo "=================================================="
echo -e "${GREEN}📊 Summary:${NC}"
echo "  Files recommended for DELETION: $DELETE_COUNT"
echo "  Files recommended for ARCHIVE: $ARCHIVE_COUNT"
echo "  Total files: $((DELETE_COUNT + ARCHIVE_COUNT))"
echo "=================================================="
echo ""

echo -e "${YELLOW}📄 Recommendations saved to:${NC} cleanup-recommendations.json"
echo ""
echo -e "${YELLOW}⚠️  REVIEW BEFORE EXECUTING${NC}"
echo "=================================================="
echo ""
echo "1. Open and review: cleanup-recommendations.json"
echo "2. Verify DELETE candidates are truly disposable"
echo "3. Check ARCHIVE candidates for accuracy"
echo ""
echo -e "${BLUE}To execute cleanup:${NC}"
echo "  bash scripts/execute-root-cleanup.sh --execute"
echo ""

# Check if --execute flag is present
if [ "$1" != "--execute" ]; then
  echo -e "${GREEN}✅ Dry run complete - no files modified${NC}"
  exit 0
fi

# === EXECUTION MODE ===
echo ""
echo -e "${RED}⚠️  EXECUTING CLEANUP${NC}"
echo "=================================================="
echo ""
echo -e "${YELLOW}This will modify your project structure!${NC}"
echo -e "${YELLOW}Deletions are PERMANENT!${NC}"
echo -e "${YELLOW}Press Ctrl+C within 5 seconds to cancel...${NC}"
sleep 5
echo ""

# Create archive directories
echo -e "${BLUE}📁 Creating archive structure${NC}"
mkdir -p "$PROJECT_ROOT/docs/historical/reports"
mkdir -p "$PROJECT_ROOT/docs/historical/analysis"
mkdir -p "$PROJECT_ROOT/docs/historical/deployment"
mkdir -p "$PROJECT_ROOT/docs/historical/configuration"
echo -e "${GREEN}✓ Archive directories created${NC}"
echo ""

# Execute deletions
echo -e "${BLUE}🗑️  Executing deletions...${NC}"
python3 << 'PYTHON_DELETE'
import json
import os

with open('/Users/a00288946/Desktop/accessilist/cleanup-recommendations.json', 'r') as f:
    data = json.load(f)

deleted = 0
for item in data['delete']:
    filepath = f"/Users/a00288946/Desktop/accessilist/{item['file']}"
    if os.path.exists(filepath):
        os.remove(filepath)
        print(f"  ✓ Deleted: {item['file']}")
        deleted += 1
    else:
        print(f"  ⚠ Not found: {item['file']}")

print(f"\nDeleted {deleted} files")
PYTHON_DELETE
echo ""

# Execute archival
echo -e "${BLUE}📦 Executing archival...${NC}"
python3 << 'PYTHON_ARCHIVE'
import json
import shutil
import os

with open('/Users/a00288946/Desktop/accessilist/cleanup-recommendations.json', 'r') as f:
    data = json.load(f)

archived = 0
for item in data['archive']:
    filename = item['file']
    source = f"/Users/a00288946/Desktop/accessilist/{filename}"

    if not os.path.exists(source):
        print(f"  ⚠ Not found: {filename}")
        continue

    # Determine destination based on filename patterns
    if any(x in filename for x in ['REPORT', 'SUMMARY', 'COMPLETE', 'SUCCESS']):
        dest_dir = "/Users/a00288946/Desktop/accessilist/docs/historical/reports"
    elif any(x in filename for x in ['ANALYSIS', 'EVALUATION', 'PROPOSAL']):
        dest_dir = "/Users/a00288946/Desktop/accessilist/docs/historical/analysis"
    elif any(x in filename for x in ['DEPLOYMENT', 'MIGRATION', 'PACKAGE']):
        dest_dir = "/Users/a00288946/Desktop/accessilist/docs/historical/deployment"
    else:
        dest_dir = "/Users/a00288946/Desktop/accessilist/docs/historical/configuration"

    dest = f"{dest_dir}/{filename}"
    shutil.move(source, dest)
    print(f"  ✓ Archived: {filename} → {os.path.basename(dest_dir)}/")
    archived += 1

print(f"\nArchived {archived} files")
PYTHON_ARCHIVE
echo ""

# Create README in historical directory
cat > "$PROJECT_ROOT/docs/historical/README.md" << 'EOF'
# Historical Documentation Archive

This directory contains historical documentation archived during root directory cleanup.

## Directory Structure

- **reports/** - Completed implementation and test reports
- **analysis/** - Analysis documents and problem investigations
- **deployment/** - Deployment and migration records
- **configuration/** - Configuration documentation and setup guides

## Purpose

These documents are preserved to provide:

1. **Historical Context** - Understanding how the project evolved over time
2. **Decision Reference** - Why certain technical choices were made
3. **Troubleshooting** - Solutions to problems that may recur
4. **Onboarding** - Context for new contributors learning the project

## Usage

These documents are for **reference only**. For current documentation:

- See the main project **README.md**
- Check **docs/** for active guides
- Review **changelog.md** for recent changes

---

*Last updated: 2025-10-07*
EOF

echo -e "${GREEN}✅ Cleanup Complete!${NC}"
echo "=================================================="
echo ""
echo -e "${BLUE}📊 Results:${NC}"
echo "  Files deleted: $DELETE_COUNT"
echo "  Files archived: $ARCHIVE_COUNT"
echo "  Archive location: docs/historical/"
echo ""
echo -e "${YELLOW}💡 Next Steps:${NC}"
echo "  1. Review changes: git status"
echo "  2. Verify active docs still work"
echo "  3. Commit if satisfied: git add -A && git commit -m 'docs: organize root directory'"
echo ""
echo -e "${BLUE}📝 Archive README created at:${NC}"
echo "  docs/historical/README.md"
echo ""
