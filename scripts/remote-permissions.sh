#!/usr/bin/env bash
set -euo pipefail

# Usage: remote-permissions.sh [DEPLOY_PATH]
# Mirrors otter's chmod-only approach (no chown) and creates writable dirs

DEPLOY_PATH="${1:-/var/websites/webaim/htdocs/training/online/accessilist}"

echo "[permissions] Using DEPLOY_PATH=$DEPLOY_PATH"

# Create writable directories for this app
mkdir -p "$DEPLOY_PATH/saves"

# Baseline permissions
find "$DEPLOY_PATH" -type f -exec chmod 644 {} \;
find "$DEPLOY_PATH" -type d -exec chmod 755 {} \;

# Writable app-managed directories
chmod -R 775 "$DEPLOY_PATH/php/saves" "$DEPLOY_PATH/saves"

echo "[permissions] Completed chmod adjustments without chown"


