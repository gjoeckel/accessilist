#!/bin/bash
set -euo pipefail

HOST=127.0.0.1
PORT=8010
BASE_URL="http://${HOST}:${PORT}"

echo "Starting simulated production server on ${BASE_URL}..."
php -S ${HOST}:${PORT} -t . tests/router.php >/dev/null 2>&1 &
SERVER_PID=$!
trap 'kill ${SERVER_PID} 2>/dev/null || true' EXIT
sleep 1

echo "Validating endpoints..."

status() {
  local url=$1
  curl -s -o /dev/null -w "%{http_code}" "$url"
}

failures=0

check() {
  local name=$1
  local url=$2
  local expect=$3
  code=$(status "$url") || code="000"
  if [[ "$code" == "$expect" || ("$expect" == "200|404" && ("$code" == "200" || "$code" == "404")) ]]; then
    echo "[OK] $name -> $code"
  else
    echo "[FAIL] $name -> $code (expected $expect)"
    failures=$((failures+1))
  fi
}

check "index"               "$BASE_URL/"                    302
check "home extless"        "$BASE_URL/php/home"            200
check "health .php"          "$BASE_URL/php/api/health.php"  200
check "health extless"       "$BASE_URL/php/api/health"      200
check "image asset"          "$BASE_URL/images/add-1.svg"    200

# Restore will be 404 locally unless saved
check "restore .php"         "$BASE_URL/php/api/restore.php?sessionKey=ABC" "200|404"
check "restore extless"      "$BASE_URL/php/api/restore?sessionKey=ABC"     "200|404"

# Perform a minimal save to create the file, then re-check restore
echo "Attempting minimal save..."
curl -s -X POST -H 'Content-Type: application/json' \
  -d '{"sessionKey":"ABC","timestamp":1690000000000,"type":"Test","typeSlug":"test","state":{}}' \
  "$BASE_URL/php/api/save" > /dev/null || true

sleep 0.5
check "restore extless after save" "$BASE_URL/php/api/restore?sessionKey=ABC" 200

echo "Summary: $failures failures"
exit $failures


