#!/bin/bash

set -euo pipefail

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"

wait_for_url() {
  local url="$1"
  local retries="${2:-30}"
  local delay="${3:-0.5}"
  for i in $(seq 1 "$retries"); do
    if curl -fsS "$url" >/dev/null 2>&1; then
      return 0
    fi
    sleep "$delay"
  done
  return 1
}

test_endpoints() {
  local base="$1"
  local label="$2"
  echo -e "${BLUE}🔎 Testing routes on ${label}:${NC} ${base}"
  local -a paths=(
    "/home"
    "/admin"
    "/php/api/list"
  )
  local ok=0
  local fail=0
  for p in "${paths[@]}"; do
    if curl -fsS "${base}${p}" >/dev/null 2>&1; then
      echo -e "${GREEN}✅ ${p}${NC}"
      ok=$((ok+1))
    else
      echo -e "${RED}❌ ${p}${NC}"
      fail=$((fail+1))
    fi
  done
  echo -e "${YELLOW}Result:${NC} ${ok} OK, ${fail} Failed"
  [[ $fail -eq 0 ]]
}

run_php_mode() {
  echo -e "${BLUE}▶ PHP mode (router.php)${NC}"
  pushd "$BASE_DIR" >/dev/null
  if ! command -v php >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  PHP not available; skipping PHP mode${NC}"
    popd >/dev/null
    return 0
  fi
  local host="127.0.0.1"
  local port=8000
  local url="http://${host}:${port}"
  # Start server
  php -S "${host}:${port}" router.php >/dev/null 2>&1 &
  local php_pid=$!
  trap 'kill "$php_pid" >/dev/null 2>&1 || true' EXIT
  if ! wait_for_url "${url}/index.php" 40 0.25; then
    echo -e "${RED}❌ PHP server failed to start${NC}"
    kill "$php_pid" >/dev/null 2>&1 || true
    popd >/dev/null
    return 1
  fi
  test_endpoints "$url" "PHP"
  kill "$php_pid" >/dev/null 2>&1 || true
  trap - EXIT
  popd >/dev/null
}

run_docker_mode() {
  echo -e "${BLUE}▶ Docker mode (php:8.1-apache)${NC}"
  pushd "$BASE_DIR" >/dev/null
  if ! command -v docker >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Docker not available; skipping Docker mode${NC}"
    popd >/dev/null
    return 0
  fi
  docker compose up -d
  local url="http://127.0.0.1:8080"
  if ! wait_for_url "${url}/index.php" 60 0.5; then
    echo -e "${RED}❌ Docker web service failed to become healthy${NC}"
    docker compose logs --no-color web || true
    popd >/dev/null
    return 1
  fi
  test_endpoints "$url" "Docker"
  popd >/dev/null
}

run_apache_mode() {
  echo -e "${BLUE}▶ macOS Apache mode (port 80)${NC}"
  local url="http://localhost"
  if curl -fsS "${url}/index.php" >/dev/null 2>&1; then
    test_endpoints "$url" "Apache"
  else
    echo -e "${YELLOW}⚠️  Apache not responding; run 'npm run apache-start' then retry${NC}"
  fi
}

mode="${1:-all}"
case "$mode" in
  all)
    run_php_mode || true
    run_docker_mode || true
    run_apache_mode || true
    ;;
  php)
    run_php_mode ;;
  docker)
    run_docker_mode ;;
  apache)
    run_apache_mode ;;
  *)
    echo "Usage: $0 [all|php|docker|apache]" && exit 1 ;;
 esac

 echo -e "${GREEN}✅ Verification complete${NC}"