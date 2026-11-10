#!/usr/bin/env bash
# Fixed-summary verification. Run from the repo root:
#   bash scripts/verify.sh
#
# Override any step with:
#   VERIFY_TYPECHECK_CMD="..." VERIFY_TEST_CMD="..." \
#   VERIFY_BUILD_CMD="..." VERIFY_A11Y_CMD="..." bash scripts/verify.sh
#
# For Node projects it auto-detects package.json scripts.
# A step that is not configured is reported as "skip", never silently "pass".
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT" || exit 2

TYPECHECK=skip; TEST=skip; BUILD=skip; A11Y=skip
TMP="$(mktemp -d 2>/dev/null || mktemp -d -t verify)"
trap 'rm -rf "$TMP"' EXIT

PM=""
if [ -f package.json ]; then
  if [ -f pnpm-lock.yaml ]; then PM=pnpm
  elif [ -f yarn.lock ]; then PM=yarn
  else PM=npm
  fi
fi

has_script() {
  [ -n "$PM" ] && node -e "
    const p=require('./package.json');
    process.exit(p.scripts && p.scripts['$1'] ? 0 : 1)
  " 2>/dev/null
}

run_step() {
  local name="$1" cmd="${2:-}"
  if [ -z "$cmd" ]; then
    printf '  [%s] skip (not configured)\n' "$name"
    return 1
  fi
  printf '  [%s] %s\n' "$name" "$cmd"
  local out="$TMP/$name.log"
  if CI=1 bash -c "$cmd" >"$out" 2>&1; then
    tail -n 5 "$out" | sed 's/^/    /'
    return 0
  else
    tail -n 40 "$out" | sed 's/^/    /'
    return 2
  fi
}

if [ -n "${VERIFY_TYPECHECK_CMD:-}" ]; then
  run_step typecheck "$VERIFY_TYPECHECK_CMD"; case $? in 0) TYPECHECK=pass;; 2) TYPECHECK=fail;; esac
elif has_script typecheck; then
  run_step typecheck "$PM run typecheck"; case $? in 0) TYPECHECK=pass;; 2) TYPECHECK=fail;; esac
elif [ -f tsconfig.json ] && [ -x node_modules/.bin/tsc ]; then
  run_step typecheck "./node_modules/.bin/tsc --noEmit"; case $? in 0) TYPECHECK=pass;; 2) TYPECHECK=fail;; esac
fi

if [ -n "${VERIFY_TEST_CMD:-}" ]; then
  run_step test "$VERIFY_TEST_CMD"; case $? in 0) TEST=pass;; 2) TEST=fail;; esac
elif has_script test; then
  run_step test "$PM test"; case $? in 0) TEST=pass;; 2) TEST=fail;; esac
fi

if [ -n "${VERIFY_BUILD_CMD:-}" ]; then
  run_step build "$VERIFY_BUILD_CMD"; case $? in 0) BUILD=pass;; 2) BUILD=fail;; esac
elif has_script build; then
  run_step build "$PM run build"; case $? in 0) BUILD=pass;; 2) BUILD=fail;; esac
fi

if [ -n "${VERIFY_A11Y_CMD:-}" ]; then
  run_step a11y "$VERIFY_A11Y_CMD"; case $? in 0) A11Y=pass;; 2) A11Y=fail;; esac
elif has_script a11y; then
  run_step a11y "$PM run a11y"; case $? in 0) A11Y=pass;; 2) A11Y=fail;; esac
fi

printf '\nVERIFY typecheck=%s test=%s build=%s a11y=%s\n' "$TYPECHECK" "$TEST" "$BUILD" "$A11Y"
case "$TYPECHECK/$TEST/$BUILD/$A11Y" in
  *fail*) exit 1 ;;
  *) exit 0 ;;
esac
