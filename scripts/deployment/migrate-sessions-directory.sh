#!/bin/bash
# Automated script to migrate saves/ to sessions/ on production server
# Runs via SSH with the accessilist_deploy key

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Sessions Directory Migration - Production Server     ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# Configuration - UPDATE THESE
SERVER_USER="${SSH_USER:-YOUR_USERNAME}"  # Set SSH_USER env var or update here
SERVER_HOST="${SSH_HOST:-webaim.org}"     # Set SSH_HOST env var or update here
DEPLOY_PATH="/var/websites/webaim/htdocs/training/online/accessilist"
SSH_KEY="$HOME/.ssh/accessilist_deploy"

# Check if SSH key exists
if [ ! -f "$SSH_KEY" ]; then
    echo -e "${RED}❌ SSH key not found: $SSH_KEY${NC}"
    echo "Run: ssh-keygen -t ed25519 -f ~/.ssh/accessilist_deploy"
    exit 1
fi

echo -e "${YELLOW}📋 Migration Configuration:${NC}"
echo "  Server: $SERVER_USER@$SERVER_HOST"
echo "  Path: $DEPLOY_PATH"
echo "  SSH Key: $SSH_KEY"
echo ""

# Confirm before proceeding
read -p "Proceed with migration? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Migration cancelled${NC}"
    exit 0
fi

echo -e "${BLUE}🚀 Starting migration...${NC}"
echo ""

# Run migration commands on server
ssh -i "$SSH_KEY" "$SERVER_USER@$SERVER_HOST" << 'ENDSSH'
set -e

cd /var/websites/webaim/htdocs/training/online/accessilist

echo "📁 Current directory: $(pwd)"
echo ""

# 1. Backup existing saves directory
if [ -d "saves" ]; then
  BACKUP_NAME="saves.backup.$(date +%Y%m%d-%H%M%S)"
  echo "📦 Backing up saves/ → $BACKUP_NAME"
  cp -r saves "$BACKUP_NAME"
  echo "✅ Backup created: $BACKUP_NAME"
else
  echo "ℹ️  No saves/ directory found - nothing to backup"
fi
echo ""

# 2. Create sessions directory
echo "📁 Creating sessions/ directory..."
mkdir -p sessions
chmod 755 sessions
echo "✅ Created sessions/ with 755 permissions"
echo ""

# 3. Copy .htaccess if exists
if [ -f "saves/.htaccess" ]; then
  echo "📄 Copying .htaccess..."
  cp saves/.htaccess sessions/.htaccess
  chmod 644 sessions/.htaccess
  echo "✅ Copied .htaccess to sessions/"
else
  echo "ℹ️  No .htaccess in saves/ - will use repository version"
fi
echo ""

# 4. Move session files
if [ -d "saves" ] && [ "$(ls -A saves/*.json 2>/dev/null)" ]; then
  echo "📦 Moving session files..."
  COUNT=$(ls -1 saves/*.json 2>/dev/null | wc -l)
  mv saves/*.json sessions/ 2>/dev/null || true
  echo "✅ Moved $COUNT session files to sessions/"
else
  echo "ℹ️  No session files to move"
fi
echo ""

# 5. Delete saves directory
if [ -d "saves" ]; then
  echo "🗑️  Deleting saves/ directory..."
  rm -rf saves
  echo "✅ Deleted saves/"
else
  echo "ℹ️  saves/ already removed"
fi
echo ""

# 6. Verify sessions directory
echo "📊 Sessions directory status:"
ls -la sessions/ | head -5
echo "..."
FILE_COUNT=$(ls -1 sessions/*.json 2>/dev/null | wc -l || echo 0)
echo "Total session files: $FILE_COUNT"
echo ""

# 7. Set proper permissions on session files
if [ "$FILE_COUNT" -gt 0 ]; then
  chmod 644 sessions/*.json 2>/dev/null || true
  echo "✅ Set permissions on session files (644)"
fi
echo ""

# 8. Test write access
echo "🧪 Testing write access..."
if echo '{"test": true}' > sessions/_write_test.json; then
  rm sessions/_write_test.json
  echo "✅ Write access confirmed"
else
  echo "❌ Write access failed!"
  exit 1
fi
echo ""

echo "✅ Migration complete!"

ENDSSH

MIGRATION_EXIT=$?

echo ""
if [ $MIGRATION_EXIT -eq 0 ]; then
    echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  ✅ Migration Completed Successfully!                 ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BLUE}Next steps:${NC}"
    echo "1. Deploy your code: npm run deploy"
    echo "2. Test production: https://webaim.org/training/online/accessilist/home"
    echo "3. Verify session save/restore works"
else
    echo -e "${RED}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║  ❌ Migration Failed - Check errors above             ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════════════════════╝${NC}"
    exit 1
fi
