#!/bin/bash

# Comprehensive Root Directory File Analysis
# Analyzes ALL files in root and provides specific recommendations
# Output: Detailed JSON report with actionable recommendations

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Configuration
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_FILE="$PROJECT_ROOT/root-files-analysis.json"
TIMESTAMP=$(date -u +"%Y-%m-%d %H:%M:%S UTC")

echo -e "${BLUE}📋 Comprehensive Root Directory Analysis${NC}"
echo "=================================================="
echo "Analyzing ALL files in root directory"
echo "Timestamp: $TIMESTAMP"
echo ""

# Function to analyze a file and return recommendation
analyze_file() {
  local filename=$1
  local action=""
  local destination=""
  local reason=""
  local priority=""

  # === DOCUMENTATION FILES (.md) ===
  if [[ "$filename" =~ \.md$ ]]; then
    case "$filename" in
      "README.md"|"changelog.md"|"template.md")
        action="KEEP"
        destination="root"
        reason="Essential active documentation"
        priority="high"
        ;;
      "APACHE-SETUP-GUIDE.md"|"DEPLOYMENT-SETUP.md"|"SERVER-COMMANDS.md")
        action="KEEP"
        destination="root"
        reason="Active setup/reference guide"
        priority="high"
        ;;
      "ROOT-CLEANUP-SUMMARY.md")
        action="ARCHIVE"
        destination="docs/historical/reports/"
        reason="Cleanup report - historical record"
        priority="medium"
        ;;
      *)
        action="KEEP"
        destination="root"
        reason="Active documentation"
        priority="medium"
        ;;
    esac

  # === SHELL SCRIPTS (.sh) ===
  elif [[ "$filename" =~ \.sh$ ]]; then
    case "$filename" in
      # Session management scripts
      "session-start.sh"|"session-end.sh"|"session-update.sh"|"session-local.sh")
        action="MOVE"
        destination="scripts/session/"
        reason="Session management - belongs in scripts/session/"
        priority="medium"
        ;;
      # Setup scripts
      "setup-mcp-servers.sh"|"setup-mcp-simple.sh"|"setup-production-env.sh"|"srd-dev-setup.sh")
        action="MOVE"
        destination="scripts/setup/"
        reason="Setup script - belongs in scripts/setup/"
        priority="medium"
        ;;
      # Configuration/utility scripts
      "configure-cursor-autonomy.sh"|"compress-context.sh")
        action="MOVE"
        destination="scripts/utils/"
        reason="Utility script - belongs in scripts/utils/"
        priority="medium"
        ;;
      # Build/deployment scripts
      "github-push-gate.sh"|"start.sh")
        action="MOVE"
        destination="scripts/"
        reason="Already has scripts/ directory, should be organized there"
        priority="medium"
        ;;
      # Changelog automation
      "ai-changelog-master.sh")
        action="MOVE"
        destination="scripts/changelog/"
        reason="Changelog automation - belongs in scripts/changelog/"
        priority="low"
        ;;
      # Apache rollback
      "rollback-apache-setup.sh")
        action="MOVE"
        destination="scripts/apache/"
        reason="Apache-specific script - belongs in scripts/apache/"
        priority="low"
        ;;
      *)
        action="MOVE"
        destination="scripts/"
        reason="Script should be in scripts/ directory"
        priority="medium"
        ;;
    esac

  # === CONFIGURATION FILES (.json) ===
  elif [[ "$filename" =~ \.json$ ]]; then
    case "$filename" in
      "package.json"|"package-lock.json")
        action="KEEP"
        destination="root"
        reason="Essential npm configuration"
        priority="critical"
        ;;
      "cursor-settings.json")
        action="KEEP"
        destination="root"
        reason="Active Cursor IDE configuration"
        priority="high"
        ;;
      "cursor-settings-optimized.json")
        action="DELETE"
        destination=""
        reason="Duplicate - cursor-settings.json is active"
        priority="high"
        ;;
      "cleanup-analysis.json"|"cleanup-recommendations.json")
        action="DELETE"
        destination=""
        reason="Temporary analysis files - task complete"
        priority="medium"
        ;;
      *)
        action="REVIEW"
        destination=""
        reason="Configuration file - needs manual review"
        priority="medium"
        ;;
    esac

  # === DOCKER FILES ===
  elif [[ "$filename" == "docker-compose.yml" ]]; then
    action="KEEP"
    destination="root"
    reason="Essential Docker configuration"
    priority="critical"

  # === PHP FILES ===
  elif [[ "$filename" =~ \.php$ ]]; then
    case "$filename" in
      "index.php"|"router.php")
        action="KEEP"
        destination="root"
        reason="Essential entry point"
        priority="critical"
        ;;
      "test_url_parameter.php")
        action="DELETE"
        destination=""
        reason="Test file - no longer needed"
        priority="high"
        ;;
      *)
        action="KEEP"
        destination="root"
        reason="PHP entry point"
        priority="high"
        ;;
    esac

  # === JAVASCRIPT CONFIG ===
  elif [[ "$filename" == "jest.config.srd.js" ]]; then
    action="KEEP"
    destination="root"
    reason="Essential test configuration"
    priority="high"

  # === LOG FILES ===
  elif [[ "$filename" =~ \.log$ ]]; then
    action="MOVE"
    destination="logs/"
    reason="Log file - belongs in logs/ directory"
    priority="high"

  # === UNKNOWN ===
  else
    action="REVIEW"
    destination=""
    reason="Unknown file type - needs manual review"
    priority="low"
  fi

  echo "$action|$destination|$reason|$priority"
}

# Initialize JSON structure
cat > "$OUTPUT_FILE" << 'EOF'
{
  "analysis_date": "",
  "total_files": 0,
  "recommendations": {
    "keep": [],
    "move": [],
    "delete": [],
    "archive": [],
    "review": []
  },
  "by_priority": {
    "critical": [],
    "high": [],
    "medium": [],
    "low": []
  },
  "summary": {
    "keep_count": 0,
    "move_count": 0,
    "delete_count": 0,
    "archive_count": 0,
    "review_count": 0
  }
}
EOF

# Update metadata
python3 -c "
import json
with open('$OUTPUT_FILE', 'r') as f:
    data = json.load(f)
data['analysis_date'] = '$TIMESTAMP'
with open('$OUTPUT_FILE', 'w') as f:
    json.dump(data, f, indent=2)
"

echo -e "${YELLOW}Analyzing files...${NC}"
echo ""

# Get all files in root
ROOT_FILES=$(find "$PROJECT_ROOT" -maxdepth 1 -type f ! -name ".*" -exec basename {} \; | sort)

FILE_COUNT=0
KEEP_COUNT=0
MOVE_COUNT=0
DELETE_COUNT=0
ARCHIVE_COUNT=0
REVIEW_COUNT=0

while IFS= read -r filename; do
  if [ -z "$filename" ]; then continue; fi

  ((FILE_COUNT++))

  result=$(analyze_file "$filename")
  action=$(echo "$result" | cut -d'|' -f1)
  destination=$(echo "$result" | cut -d'|' -f2)
  reason=$(echo "$result" | cut -d'|' -f3)
  priority=$(echo "$result" | cut -d'|' -f4)

  # Display recommendation
  case "$action" in
    "KEEP")
      echo -e "${GREEN}✅ KEEP:${NC} $filename"
      ((KEEP_COUNT++))
      ;;
    "MOVE")
      echo -e "${BLUE}📦 MOVE:${NC} $filename → $destination"
      ((MOVE_COUNT++))
      ;;
    "DELETE")
      echo -e "${RED}🗑️  DELETE:${NC} $filename"
      ((DELETE_COUNT++))
      ;;
    "ARCHIVE")
      echo -e "${YELLOW}📚 ARCHIVE:${NC} $filename → $destination"
      ((ARCHIVE_COUNT++))
      ;;
    "REVIEW")
      echo -e "${YELLOW}🔍 REVIEW:${NC} $filename"
      ((REVIEW_COUNT++))
      ;;
  esac
  echo -e "    ${YELLOW}Reason:${NC} $reason"
  echo -e "    ${YELLOW}Priority:${NC} $priority"
  echo ""

  # Add to JSON
  python3 << PYTHON_ADD
import json

with open('$OUTPUT_FILE', 'r') as f:
    data = json.load(f)

# Add to action category
rec = {
    'file': '$filename',
    'action': '$action',
    'destination': '$destination',
    'reason': '''$reason''',
    'priority': '$priority'
}

action_key = '$action'.lower()
data['recommendations'][action_key].append(rec)

# Add to priority category
data['by_priority']['$priority'].append(rec)

with open('$OUTPUT_FILE', 'w') as f:
    json.dump(data, f, indent=2)
PYTHON_ADD

done <<< "$ROOT_FILES"

# Update summary
python3 << PYTHON_SUMMARY
import json

with open('$OUTPUT_FILE', 'r') as f:
    data = json.load(f)

data['total_files'] = $FILE_COUNT
data['summary']['keep_count'] = $KEEP_COUNT
data['summary']['move_count'] = $MOVE_COUNT
data['summary']['delete_count'] = $DELETE_COUNT
data['summary']['archive_count'] = $ARCHIVE_COUNT
data['summary']['review_count'] = $REVIEW_COUNT

with open('$OUTPUT_FILE', 'w') as f:
    json.dump(data, f, indent=2)

# Print summary
print("\n" + "="*50)
print("📊 Analysis Summary")
print("="*50)
print(f"Total files analyzed: {$FILE_COUNT}")
print(f"  ✅ KEEP in root: {$KEEP_COUNT}")
print(f"  📦 MOVE to organized location: {$MOVE_COUNT}")
print(f"  🗑️  DELETE (obsolete): {$DELETE_COUNT}")
print(f"  📚 ARCHIVE (historical): {$ARCHIVE_COUNT}")
print(f"  🔍 REVIEW (manual needed): {$REVIEW_COUNT}")
print("="*50)
PYTHON_SUMMARY

echo ""
echo -e "${GREEN}✅ Analysis Complete!${NC}"
echo ""
echo -e "${YELLOW}📄 Full report saved to:${NC} root-files-analysis.json"
echo ""
echo -e "${BLUE}💡 Next Steps:${NC}"
echo "  1. Review root-files-analysis.json"
echo "  2. Check high-priority recommendations"
echo "  3. Create execution script to implement changes"
echo ""

