#!/usr/bin/env bash
# healthcheck.sh — minimal post-deploy / uptime check
#
# Usage:
#   bash scripts/healthcheck.sh http://127.0.0.1:3000
#   BASE_URL=https://example.com bash scripts/healthcheck.sh
#
# Exits non-zero if /health fails or the reported version does not match VERSION.
set -euo pipefail

BASE_URL="${1:-${BASE_URL:-http://127.0.0.1:3000}}"
HEALTH_PATH="${HEALTH_PATH:-/health}"
VERSION_PATH="${VERSION_PATH:-/version}"
TIMEOUT="${HEALTHCHECK_TIMEOUT:-5}"

curl -fsS --max-time "$TIMEOUT" "${BASE_URL}${HEALTH_PATH}" >/dev/null
echo "health: OK (${BASE_URL}${HEALTH_PATH})"

body="$(curl -fsS --max-time "$TIMEOUT" "${BASE_URL}${VERSION_PATH}")"
echo "version response: ${body}"

if [ -f VERSION ]; then
  expected="$(tr -d '[:space:]' < VERSION)"
  if ! printf '%s' "$body" | grep -q "$expected"; then
    echo "FAIL: version mismatch; expected ${expected}" >&2
    exit 1
  fi
  echo "version: OK (${expected})"
fi
