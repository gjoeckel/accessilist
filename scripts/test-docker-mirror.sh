#!/bin/bash

# Docker-based Production Mirror Testing
# Unified workflow: start Docker, run tests, cleanup
#
# Usage: ./scripts/test-docker-mirror.sh

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

PROJECT_DIR="/Users/a00288946/Desktop/accessilist"
DOCKER_URL="http://127.0.0.1:8080"

echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Docker Production-Mirror Testing Workflow         ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# Step 1: Start Docker environment
echo -e "${BLUE}━━━ Step 1: Starting Docker Environment ━━━${NC}"
echo "  Starting Docker Compose..."
docker-compose -f "$PROJECT_DIR/docker-compose.yml" up -d

# Step 2: Wait for Apache to be ready
echo ""
echo -e "${BLUE}━━━ Step 2: Waiting for Apache ━━━${NC}"
echo -n "  Checking health status"

MAX_WAIT=30
ELAPSED=0
HEALTHY=false

while [ $ELAPSED -lt $MAX_WAIT ]; do
    if docker-compose -f "$PROJECT_DIR/docker-compose.yml" ps | grep -q "healthy"; then
        HEALTHY=true
        break
    fi
    echo -n "."
    sleep 1
    ELAPSED=$((ELAPSED + 1))
done

echo ""

if [ "$HEALTHY" = true ]; then
    echo -e "  ${GREEN}✅ Apache is healthy${NC}"
else
    echo -e "  ${YELLOW}⚠️  Health check timeout, proceeding anyway...${NC}"
fi

# Give it 2 more seconds to be sure
sleep 2

# Step 3: Run production-mirror tests
echo ""
echo -e "${BLUE}━━━ Step 3: Running Production-Mirror Tests ━━━${NC}"
echo ""

# Run tests with Docker-specific BASE_URL (no production path prefix)
TEST_EXIT_CODE=0
BASE_URL="$DOCKER_URL" "$PROJECT_DIR/scripts/test-production-mirror.sh" || TEST_EXIT_CODE=$?

# Step 4: Cleanup
echo ""
echo -e "${BLUE}━━━ Step 4: Cleaning Up ━━━${NC}"
echo "  Stopping Docker Compose..."
docker-compose -f "$PROJECT_DIR/docker-compose.yml" down

echo ""
if [ $TEST_EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  ✅ Docker testing workflow completed successfully! ✅ ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
else
    echo -e "${RED}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║  ❌ Docker testing workflow completed with failures ❌ ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════════════════════╝${NC}"
fi

exit $TEST_EXIT_CODE

