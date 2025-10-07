#!/bin/bash

# Root Directory Cleanup Analysis
# SRD-compliant script to identify documentation files for cleanup/archival
# Focus: Root-level .md files, config files, and organizational opportunities
# Output: JSON report for review

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Configuration
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_FILE="$PROJECT_ROOT/cleanup-analysis.json"
TIMESTAMP=$(date -u +"%Y-%m-%d %H:%M:%S UTC")

echo -e "${BLUE}🔍 Root Directory Cleanup Analysis${NC}"
echo "=================================================="
echo "Project: $PROJECT_ROOT"
echo "Timestamp: $TIMESTAMP"
echo ""

# Initialize JSON structure
cat > "$OUTPUT_FILE" << 'EOF'
{
  "analysis_date": "",
  "project_root": "",
  "categories": {
    "archival_candidates": {
      "completed_reports": [],
      "implementation_summaries": [],
      "analysis_documents": [],
      "verification_reports": []
    },
    "active_documentation": {
      "setup_guides": [],
      "readme_files": [],
      "current_processes": []
    },
    "configuration_files": {
      "cursor_configs": [],
      "deployment_configs": [],
      "review_recommended": []
    },
    "scripts_in_root": [],
    "misc_files": []
  },
  "statistics": {
    "total_md_files": 0,
    "archival_candidates": 0,
    "active_docs": 0,
    "config_files": 0,
    "scripts": 0
  },
  "recommendations": []
}
EOF

# Function to add file to category
add_to_category() {
  local category=$1
  local subcategory=$2
  local file=$3

  python3 -c "
import json
import sys

with open('$OUTPUT_FILE', 'r') as f:
    data = json.load(f)

if '$subcategory':
    data['categories']['$category']['$subcategory'].append('$file')
else:
    data['categories']['$category'].append('$file')

with open('$OUTPUT_FILE', 'w') as f:
    json.dump(data, f, indent=2)
"
}

echo -e "${BLUE}📋 Step 1: Analyzing Root-Level Markdown Files${NC}"
echo "=================================================="

# Count total markdown files in root
MD_FILES=$(find "$PROJECT_ROOT" -maxdepth 1 -name "*.md" -type f | sort)
MD_COUNT=$(echo "$MD_FILES" | grep -c "." || echo "0")

echo "Found $MD_COUNT markdown files in root directory"
echo ""

# Categorize markdown files
ARCHIVAL_COUNT=0
ACTIVE_COUNT=0

while IFS= read -r file; do
  if [ -z "$file" ]; then continue; fi

  filename=$(basename "$file")
  echo -e "${YELLOW}Analyzing:${NC} $filename"

  # Completed reports and summaries (archival candidates)
  if [[ "$filename" =~ (COMPLETE|REPORT|SUMMARY|SUCCESS|VERIFICATION|RESULTS)\.md$ ]]; then
    echo "  → Category: Archival Candidate (Completed Report)"
    add_to_category "archival_candidates" "completed_reports" "$filename"
    ((ARCHIVAL_COUNT++))

  # Implementation summaries
  elif [[ "$filename" =~ IMPLEMENTATION.*\.md$ ]]; then
    echo "  → Category: Archival Candidate (Implementation Summary)"
    add_to_category "archival_candidates" "implementation_summaries" "$filename"
    ((ARCHIVAL_COUNT++))

  # Analysis documents
  elif [[ "$filename" =~ (ANALYSIS|PROPOSAL|EVALUATION|FIX|ISSUES|DIFFICULTY)\.md$ ]]; then
    echo "  → Category: Archival Candidate (Analysis Document)"
    add_to_category "archival_candidates" "analysis_documents" "$filename"
    ((ARCHIVAL_COUNT++))

  # Setup/guide documents (active)
  elif [[ "$filename" =~ (SETUP|GUIDE|README|COMMANDS)\.md$ ]]; then
    echo "  → Category: Active Documentation (Setup/Guide)"
    add_to_category "active_documentation" "setup_guides" "$filename"
    ((ACTIVE_COUNT++))

  # README files (active)
  elif [[ "$filename" =~ ^README ]]; then
    echo "  → Category: Active Documentation (README)"
    add_to_category "active_documentation" "readme_files" "$filename"
    ((ACTIVE_COUNT++))

  # Process documentation (active)
  elif [[ "$filename" =~ (changelog|template)\.md$ ]]; then
    echo "  → Category: Active Documentation (Current Process)"
    add_to_category "active_documentation" "current_processes" "$filename"
    ((ACTIVE_COUNT++))

  else
    echo "  → Category: Review Required (Uncategorized)"
    add_to_category "archival_candidates" "verification_reports" "$filename"
    ((ARCHIVAL_COUNT++))
  fi

done <<< "$MD_FILES"

echo ""
echo -e "${GREEN}✓ Markdown Analysis Complete${NC}"
echo "  Archival Candidates: $ARCHIVAL_COUNT"
echo "  Active Documentation: $ACTIVE_COUNT"
echo ""

echo -e "${BLUE}📋 Step 2: Analyzing Configuration Files${NC}"
echo "=================================================="

CONFIG_COUNT=0

# Cursor configuration files
if [ -f "$PROJECT_ROOT/cursor-settings.json" ]; then
  echo "Found: cursor-settings.json"
  add_to_category "configuration_files" "cursor_configs" "cursor-settings.json"
  ((CONFIG_COUNT++))
fi

if [ -f "$PROJECT_ROOT/cursor-settings-optimized.json" ]; then
  echo "Found: cursor-settings-optimized.json"
  add_to_category "configuration_files" "cursor_configs" "cursor-settings-optimized.json"
  ((CONFIG_COUNT++))
fi

# Deployment configs
if [ -f "$PROJECT_ROOT/config.json" ]; then
  echo "Found: config.json"
  add_to_category "configuration_files" "review_recommended" "config.json"
  ((CONFIG_COUNT++))
fi

# IDE template files
IDE_TEMPLATES=$(find "$PROJECT_ROOT" -maxdepth 1 -name "*cursor*template*.md" -type f)
if [ -n "$IDE_TEMPLATES" ]; then
  while IFS= read -r file; do
    if [ -z "$file" ]; then continue; fi
    filename=$(basename "$file")
    echo "Found: $filename (IDE template)"
    add_to_category "configuration_files" "review_recommended" "$filename"
    ((CONFIG_COUNT++))
  done <<< "$IDE_TEMPLATES"
fi

echo ""
echo -e "${GREEN}✓ Configuration Analysis Complete${NC}"
echo "  Configuration files: $CONFIG_COUNT"
echo ""

echo -e "${BLUE}📋 Step 3: Analyzing Root-Level Scripts${NC}"
echo "=================================================="

SCRIPT_COUNT=0

# Shell scripts in root
ROOT_SCRIPTS=$(find "$PROJECT_ROOT" -maxdepth 1 -name "*.sh" -type f)
if [ -n "$ROOT_SCRIPTS" ]; then
  while IFS= read -r file; do
    if [ -z "$file" ]; then continue; fi
    filename=$(basename "$file")
    echo "Found: $filename"
    add_to_category "scripts_in_root" "" "$filename"
    ((SCRIPT_COUNT++))
  done <<< "$ROOT_SCRIPTS"
fi

echo ""
echo -e "${GREEN}✓ Script Analysis Complete${NC}"
echo "  Root scripts: $SCRIPT_COUNT"
echo ""

echo -e "${BLUE}📋 Step 4: Analyzing Miscellaneous Files${NC}"
echo "=================================================="

MISC_COUNT=0

# PNG/image files in root
ROOT_IMAGES=$(find "$PROJECT_ROOT" -maxdepth 1 -name "*.png" -o -name "*.jpg" -o -name "*.gif" -type f 2>/dev/null || true)
if [ -n "$ROOT_IMAGES" ]; then
  while IFS= read -r file; do
    if [ -z "$file" ]; then continue; fi
    filename=$(basename "$file")
    echo "Found: $filename (image)"
    add_to_category "misc_files" "" "$filename"
    ((MISC_COUNT++))
  done <<< "$ROOT_IMAGES"
fi

# HTML files in root
ROOT_HTML=$(find "$PROJECT_ROOT" -maxdepth 1 -name "*.html" -type f)
if [ -n "$ROOT_HTML" ]; then
  while IFS= read -r file; do
    if [ -z "$file" ]; then continue; fi
    filename=$(basename "$file")
    echo "Found: $filename"
    add_to_category "misc_files" "" "$filename"
    ((MISC_COUNT++))
  done <<< "$ROOT_HTML"
fi

echo ""
echo -e "${GREEN}✓ Miscellaneous Analysis Complete${NC}"
echo "  Misc files: $MISC_COUNT"
echo ""

# Update statistics and add recommendations
python3 << PYTHON_SCRIPT
import json

with open('$OUTPUT_FILE', 'r') as f:
    data = json.load(f)

# Update metadata
data['analysis_date'] = '$TIMESTAMP'
data['project_root'] = '$PROJECT_ROOT'

# Calculate statistics
stats = data['statistics']
stats['total_md_files'] = $MD_COUNT
stats['archival_candidates'] = $ARCHIVAL_COUNT
stats['active_docs'] = $ACTIVE_COUNT
stats['config_files'] = $CONFIG_COUNT
stats['scripts'] = $SCRIPT_COUNT

# Add recommendations
recommendations = []

if $ARCHIVAL_COUNT > 0:
    recommendations.append({
        "priority": "high",
        "action": "Create docs/historical/ directory",
        "reason": f"Move {$ARCHIVAL_COUNT} completed reports and analyses out of root",
        "files": $ARCHIVAL_COUNT
    })

if $SCRIPT_COUNT > 5:
    recommendations.append({
        "priority": "medium",
        "action": "Review root-level scripts",
        "reason": f"Consider if {$SCRIPT_COUNT} scripts should move to scripts/ directory",
        "files": $SCRIPT_COUNT
    })

if $CONFIG_COUNT > 2:
    recommendations.append({
        "priority": "low",
        "action": "Consolidate configuration files",
        "reason": f"Review {$CONFIG_COUNT} config files for redundancy",
        "files": $CONFIG_COUNT
    })

if $MISC_COUNT > 0:
    recommendations.append({
        "priority": "medium",
        "action": "Move test/debug files",
        "reason": f"Move {$MISC_COUNT} images/HTML to appropriate directories",
        "files": $MISC_COUNT
    })

data['recommendations'] = recommendations

# Write final output
with open('$OUTPUT_FILE', 'w') as f:
    json.dump(data, f, indent=2)

print(json.dumps(data, indent=2))
PYTHON_SCRIPT

echo ""
echo -e "${GREEN}✅ Analysis Complete!${NC}"
echo "=================================================="
echo ""
echo -e "${BLUE}📊 Summary:${NC}"
echo "  Total MD files analyzed: $MD_COUNT"
echo "  Archival candidates: $ARCHIVAL_COUNT"
echo "  Active documentation: $ACTIVE_COUNT"
echo "  Configuration files: $CONFIG_COUNT"
echo "  Root scripts: $SCRIPT_COUNT"
echo "  Miscellaneous files: $MISC_COUNT"
echo ""
echo -e "${YELLOW}📄 Full report saved to:${NC}"
echo "  $OUTPUT_FILE"
echo ""
echo -e "${BLUE}💡 Next Steps:${NC}"
echo "  1. Review cleanup-analysis.json"
echo "  2. Approve archival candidates"
echo "  3. Run: scripts/execute-root-cleanup.sh (to be created)"
echo ""

