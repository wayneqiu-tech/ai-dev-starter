#!/usr/bin/env bash
# Release sync check: catches the three failures a local preflight cannot see.
#   1. HEAD is not pushed to origin (the release exists only on this laptop)
#   2. the ledger / VERSION disagrees with the live /version endpoint
#   3. HEAD is not tagged (a release without a tag)
#
# Usage:
#   bash scripts/check-release-sync.sh
#   bash scripts/check-release-sync.sh --no-fetch
#   LIVE_VERSION_URL=https://example.com/api/version bash scripts/check-release-sync.sh
#
# Exit: 0 = all checks pass, 1 = at least one FAIL, 2 = cannot run.

set -u
MODE="check"
FETCH=1

usage() {
  cat <<'EOF'
Usage: check-release-sync.sh [--no-fetch] [--help]

  --no-fetch  Do not run git fetch (use the local remote-tracking ref)
  --help      Show this help

Environment:
  REMOTE            remote name (default: origin)
  BRANCH            branch name (default: current branch)
  LEDGER_FILE       ledger file (default: .release/current; fallback: VERSION)
  LIVE_VERSION_URL  e.g. https://example.com/api/version (optional)
  TAG_PATTERN       optional regex for the tag name
EOF
}

for arg in "$@"; do
  case "$arg" in
    --no-fetch) FETCH=0 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $arg" >&2; usage; exit 2 ;;
  esac
done

ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || {
  echo "FAIL: not inside a Git repository" >&2
  exit 2
}
cd "$ROOT" || exit 2

REMOTE="${REMOTE:-origin}"
BRANCH="${BRANCH:-$(git symbolic-ref --short -q HEAD 2>/dev/null || true)}"
LEDGER_FILE="${LEDGER_FILE:-.release/current}"
LIVE_VERSION_URL="${LIVE_VERSION_URL:-}"
TAG_PATTERN="${TAG_PATTERN:-}"

PASS=0; WARN=0; FAIL=0
pass() { PASS=$((PASS + 1)); printf '[PASS] %s\n' "$1"; }
warn() { WARN=$((WARN + 1)); printf '[WARN] %s\n' "$1"; }
fail() { FAIL=$((FAIL + 1)); printf '[FAIL] %s\n' "$1"; }

printf '\nRelease sync check · %s · branch=%s\n\n' "$(basename "$ROOT")" "${BRANCH:-DETACHED}"

# 1) local HEAD == origin/<branch>, and no uncommitted changes
if [ -z "$BRANCH" ]; then
  fail "detached HEAD: cannot compare with a branch"
else
  if [ "$FETCH" = "1" ]; then
    export GIT_SSH_COMMAND="${GIT_SSH_COMMAND:-ssh -o BatchMode=yes -o ConnectTimeout=10}"
    GIT_TERMINAL_PROMPT=0 git fetch --quiet "$REMOTE" "$BRANCH" 2>/dev/null \
      || warn "git fetch failed; comparing with the last known $REMOTE/$BRANCH"
  fi
  if ! git rev-parse -q --verify "$REMOTE/$BRANCH" >/dev/null 2>&1; then
    fail "no $REMOTE/$BRANCH ref; push -u $REMOTE $BRANCH first"
  else
    local_sha="$(git rev-parse HEAD)"
    remote_sha="$(git rev-parse "$REMOTE/$BRANCH")"
    if [ "$local_sha" = "$remote_sha" ]; then
      pass "HEAD == $REMOTE/$BRANCH ($local_sha)"
    else
      fail "HEAD differs from $REMOTE/$BRANCH (local=$local_sha remote=$remote_sha)"
    fi
  fi

  dirty="$(git status --porcelain | wc -l | tr -d ' ')"
  if [ "$dirty" -eq 0 ]; then
    pass "worktree is clean"
  else
    fail "worktree has ${dirty} uncommitted/untracked file(s)"
  fi
fi

# 2) ledger / VERSION == live /version
ledger=""
if [ -n "$LEDGER_FILE" ] && [ -f "$LEDGER_FILE" ]; then
  ledger="$(tr -d '[:space:]' < "$LEDGER_FILE")"
elif [ -f VERSION ]; then
  ledger="$(tr -d '[:space:]' < VERSION)"
fi

if [ -z "$ledger" ]; then
  warn "no ledger found ($LEDGER_FILE or VERSION); skip ledger check"
else
  pass "ledger: $ledger"
fi

if [ -z "$LIVE_VERSION_URL" ]; then
  warn "LIVE_VERSION_URL not set; skip live version check"
else
  body="$(curl -fsS --max-time 8 "$LIVE_VERSION_URL" 2>/dev/null)" || {
    fail "cannot fetch $LIVE_VERSION_URL"
    body=""
  }
  if [ -n "$body" ]; then
    live="$(printf '%s' "$body" | sed -n 's/.*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)"
    if [ -z "$live" ]; then
      live="$(printf '%s' "$body" | tr -d '[:space:]')"
    fi
    if [ "$live" = "$ledger" ]; then
      pass "live version == ledger ($live)"
    else
      fail "live version != ledger (live=$live ledger=$ledger)"
    fi
  fi
fi

# 3) HEAD has a tag, and the tag matches the ledger
tag="$(git describe --tags --exact-match HEAD 2>/dev/null || true)"
if [ -z "$tag" ]; then
  fail "HEAD is not tagged (a release without a tag is not reproducible)"
else
  pass "HEAD is tagged: $tag"
  if [ -n "$TAG_PATTERN" ] && ! [[ "$tag" =~ $TAG_PATTERN ]]; then
    fail "tag does not match TAG_PATTERN: $tag"
  fi
  if [ -n "$ledger" ]; then
    tag_norm="${tag#v}"
    ledger_norm="${ledger#v}"
    if [ "$tag_norm" = "$ledger_norm" ]; then
      pass "tag matches ledger ($tag / $ledger)"
    else
      fail "tag != ledger (tag=$tag ledger=$ledger)"
    fi
  fi
fi

printf '\nResult: PASS %s / WARN %s / FAIL %s\n' "$PASS" "$WARN" "$FAIL"
[ "$FAIL" -eq 0 ]
