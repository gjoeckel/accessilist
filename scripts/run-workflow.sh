#!/bin/bash

# Workflow Executor
# Ensures workflows from .cursor/workflows.json are executed correctly
# Usage: ./scripts/run-workflow.sh <workflow-name>

set -e

WORKFLOW_NAME="$1"
WORKFLOWS_FILE=".cursor/workflows.json"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

if [ -z "$WORKFLOW_NAME" ]; then
    echo -e "${RED}❌ Error: Workflow name required${NC}"
    echo "Usage: $0 <workflow-name>"
    echo ""
    echo "Available workflows:"
    jq -r 'keys[]' "$WORKFLOWS_FILE" 2>/dev/null | sed 's/^/  - /'
    exit 1
fi

if [ ! -f "$WORKFLOWS_FILE" ]; then
    echo -e "${RED}❌ Error: Workflow file not found: $WORKFLOWS_FILE${NC}"
    exit 1
fi

# Check if workflow exists
if ! jq -e ".[\"$WORKFLOW_NAME\"]" "$WORKFLOWS_FILE" >/dev/null 2>&1; then
    echo -e "${RED}❌ Error: Workflow '$WORKFLOW_NAME' not found${NC}"
    echo ""
    echo "Available workflows:"
    jq -r 'keys[]' "$WORKFLOWS_FILE" | sed 's/^/  - /'
    exit 1
fi

# Get workflow details
DESCRIPTION=$(jq -r ".[\"$WORKFLOW_NAME\"].description // \"No description\"" "$WORKFLOWS_FILE")
COMMANDS=$(jq -r ".[\"$WORKFLOW_NAME\"].commands[]" "$WORKFLOWS_FILE")

echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Workflow Executor                                     ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Workflow:${NC} $WORKFLOW_NAME"
echo -e "${YELLOW}Description:${NC} $DESCRIPTION"
echo ""

# Count total commands
TOTAL_COMMANDS=$(echo "$COMMANDS" | wc -l | tr -d ' ')
CURRENT=0
FAILED=0

echo -e "${BLUE}━━━ Executing $TOTAL_COMMANDS commands ━━━${NC}"
echo ""

# Execute each command
while IFS= read -r cmd; do
    CURRENT=$((CURRENT + 1))
    echo -e "${BLUE}[$CURRENT/$TOTAL_COMMANDS]${NC} $cmd"

    if eval "$cmd"; then
        echo -e "${GREEN}  ✅ Success${NC}"
    else
        EXIT_CODE=$?
        echo -e "${RED}  ❌ Failed (exit code: $EXIT_CODE)${NC}"
        FAILED=$((FAILED + 1))

        # Check on_error setting
        ON_ERROR=$(jq -r ".[\"$WORKFLOW_NAME\"].on_error // \"stop\"" "$WORKFLOWS_FILE")
        if [ "$ON_ERROR" = "stop" ]; then
            echo -e "${RED}Workflow stopped due to error${NC}"
            exit $EXIT_CODE
        fi
    fi
    echo ""
done <<< "$COMMANDS"

# Summary
echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}║  ✅ Workflow completed successfully                   ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
    exit 0
else
    echo -e "${YELLOW}║  ⚠️  Workflow completed with $FAILED failures            ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
    exit 1
fi
