#!/bin/bash

# Session Local Commit Script - Commit changes to local branch
# Commits current changes with intelligent commit message

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}💾 Committing Changes to Local Branch${NC}"
echo -e "${BLUE}=====================================${NC}"
echo ""

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}❌ Not a git repository${NC}"
    echo -e "${YELLOW}💡 Initialize git repository first: git init${NC}"
    exit 1
fi

# Get current branch
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "main")
echo -e "${YELLOW}🌿 Current branch: $CURRENT_BRANCH${NC}"

# Check for changes
if git diff --quiet && git diff --cached --quiet; then
    echo -e "${YELLOW}⚠️  No changes to commit${NC}"
    echo -e "${GREEN}✅ Working directory is clean${NC}"
    exit 0
fi

# Get status of changes
echo -e "${YELLOW}🔍 Analyzing changes...${NC}"

# Staged changes
STAGED_FILES=$(git diff --cached --name-only 2>/dev/null || echo "")
STAGED_COUNT=$(echo "$STAGED_FILES" | grep -c . || echo "0")

# Unstaged changes
UNSTAGED_FILES=$(git diff --name-only 2>/dev/null || echo "")
UNSTAGED_COUNT=$(echo "$UNSTAGED_FILES" | grep -c . || echo "0")

# Untracked files
UNTRACKED_FILES=$(git ls-files --others --exclude-standard 2>/dev/null || echo "")
UNTRACKED_COUNT=$(echo "$UNTRACKED_FILES" | grep -c . || echo "0")

echo -e "${GREEN}📊 Changes detected:${NC}"
echo -e "   ${GREEN}✅ Staged: $STAGED_COUNT files${NC}"
echo -e "   ${YELLOW}📝 Unstaged: $UNSTAGED_COUNT files${NC}"
echo -e "   ${BLUE}🆕 Untracked: $UNTRACKED_COUNT files${NC}"

# Add all changes if there are unstaged or untracked files
if [ "$UNSTAGED_COUNT" -gt 0 ] || [ "$UNTRACKED_COUNT" -gt 0 ]; then
    echo -e "${YELLOW}📦 Adding all changes to staging...${NC}"

    # Add all files
    git add .

    # Update counts
    STAGED_FILES=$(git diff --cached --name-only 2>/dev/null || echo "")
    STAGED_COUNT=$(echo "$STAGED_FILES" | grep -c . || echo "0")

    echo -e "${GREEN}✅ Added $STAGED_COUNT files to staging${NC}"
fi

# Generate intelligent commit message
echo -e "${YELLOW}📝 Generating commit message...${NC}"

# Get file types and changes
FILE_TYPES=$(echo "$STAGED_FILES" | sed 's/.*\.//' | sort | uniq -c | sort -nr | head -3 | awk '{print $2}' | tr '\n' ' ')
MAJOR_CHANGES=$(echo "$STAGED_FILES" | head -5 | tr '\n' ' ')

# Create commit message based on changes
TIMESTAMP=$(date +%Y-%m-%d\ %H:%M:%S)
COMMIT_PREFIX=""

# Determine commit type based on file patterns
if echo "$STAGED_FILES" | grep -q "test"; then
    COMMIT_PREFIX="test: "
elif echo "$STAGED_FILES" | grep -q "\.md$"; then
    COMMIT_PREFIX="docs: "
elif echo "$STAGED_FILES" | grep -q "package\.json\|\.sh$"; then
    COMMIT_PREFIX="config: "
elif echo "$STAGED_FILES" | grep -q "\.css$"; then
    COMMIT_PREFIX="style: "
elif echo "$STAGED_FILES" | grep -q "\.js$"; then
    COMMIT_PREFIX="feat: "
else
    COMMIT_PREFIX="update: "
fi

# Create commit message
COMMIT_MESSAGE="${COMMIT_PREFIX}Update ${FILE_TYPES}files

- Modified: $STAGED_COUNT files
- Types: $FILE_TYPES
- Key files: $MAJOR_CHANGES
- Timestamp: $TIMESTAMP

Auto-committed by ai-local"

echo -e "${GREEN}📝 Commit message:${NC}"
echo -e "${BLUE}$COMMIT_MESSAGE${NC}"
echo ""

# Confirm commit
echo -e "${YELLOW}💾 Committing changes...${NC}"
git commit -m "$COMMIT_MESSAGE"

# Get commit hash
COMMIT_HASH=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
echo -e "${GREEN}✅ Commit successful: $COMMIT_HASH${NC}"

# Show commit summary
echo ""
echo -e "${BLUE}📊 Commit Summary${NC}"
echo -e "${BLUE}================${NC}"
echo -e "${GREEN}✅ Branch: $CURRENT_BRANCH${NC}"
echo -e "${GREEN}✅ Commit: $COMMIT_HASH${NC}"
echo -e "${GREEN}✅ Files: $STAGED_COUNT${NC}"
echo -e "${GREEN}✅ Types: $FILE_TYPES${NC}"

# Show recent commits
echo ""
echo -e "${YELLOW}📜 Recent commits:${NC}"
git log --oneline -3 2>/dev/null || echo "No recent commits"

# Check if there are still uncommitted changes
REMAINING_CHANGES=$(git status --porcelain 2>/dev/null | wc -l || echo "0")
if [ "$REMAINING_CHANGES" -gt 0 ]; then
    echo ""
    echo -e "${YELLOW}⚠️  $REMAINING_CHANGES files still have uncommitted changes${NC}"
    echo -e "${YELLOW}💡 Run 'ai-local' again to commit remaining changes${NC}"
else
    echo ""
    echo -e "${GREEN}🎉 All changes committed successfully!${NC}"
fi

echo ""
echo -e "${YELLOW}💡 Session continues... Use 'ai-end' when finished${NC}"
