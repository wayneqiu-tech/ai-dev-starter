#!/usr/bin/env bash
# =============================================================================
# cleanup.sh — safe, scheduled cleanup for AI Dev Standard projects
#
# Default is a dry run. Nothing is deleted until you pass --apply.
# Deleted items go to .trash/<timestamp>/ first and are purged after 7 days.
# Git-tracked files are never moved, even if they match a junk pattern.
#
# Usage:
#   bash scripts/cleanup.sh                     # dry run (report only)
#   bash scripts/cleanup.sh --apply             # move junk to .trash (asks first)
#   bash scripts/cleanup.sh --apply --yes       # no prompt (for a timer)
#   bash scripts/cleanup.sh --purge             # delete .trash entries older than 7 days
#   bash scripts/cleanup.sh --branches          # delete local merged branches
#   bash scripts/cleanup.sh --schedule          # print a ready-to-paste cron line
#   bash scripts/cleanup.sh --all --yes         # apply + purge + branches
# =============================================================================
set -uo pipefail

MODE="check"
YES=0
DO_PURGE=0
DO_BRANCHES=0
INCLUDE_NODE_MODULES=0
RETENTION_DAYS="${CLEANUP_RETENTION_DAYS:-7}"

usage() {
  cat <<'EOF'
Usage: cleanup.sh [options]

  (no option)          dry run: list junk and total size
  --check, --dry-run   same as no option (explicit dry run)
  --apply              move junk to .trash/<timestamp>/ (asks for confirmation)
  --apply --yes        no prompt (safe for a scheduled timer)
  --purge              delete .trash entries older than CLEANUP_RETENTION_DAYS (default 7)
  --branches           delete local branches already merged into main
  --all --yes          apply + purge + branches
  --include-node-modules  also move node_modules (slow; usually not needed)
  --schedule           print a cron line for weekly cleanup
  --help               show this help

Safety:
  - Git-tracked files are never moved.
  - Source, docs, VERSION, .git, release notes, and tags are never touched.
  - Deleted items stay in .trash for 7 days before --purge removes them.
EOF
}

for arg in "$@"; do
  case "$arg" in
    --check|--dry-run) MODE="check" ;;
    --apply) MODE="apply" ;;
    --purge) DO_PURGE=1 ;;
    --branches) DO_BRANCHES=1 ;;
    --all) MODE="apply"; DO_PURGE=1; DO_BRANCHES=1 ;;
    --yes) YES=1 ;;
    --include-node-modules) INCLUDE_NODE_MODULES=1 ;;
    --schedule) MODE="schedule" ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $arg" >&2; usage; exit 2 ;;
  esac
done

if [ "$MODE" = "check" ] && { [ "$DO_PURGE" = "1" ] || [ "$DO_BRANCHES" = "1" ]; }; then
  MODE="none"
fi

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
cd "$ROOT" || exit 1
TRASH="$ROOT/.trash"
LOG="$TRASH/cleanup.log"

is_git_repo() { git -C "$ROOT" rev-parse --git-dir >/dev/null 2>&1; }

is_tracked() {
  local rel="$1"
  is_git_repo || return 1
  [ -n "$(git -C "$ROOT" ls-files -- "$rel" 2>/dev/null | head -1)" ]
}

size_kb() {
  local p="$1"
  [ -e "$p" ] || { echo 0; return; }
  du -sk "$p" 2>/dev/null | awk '{print $1}' | head -1
}

# Conservative list: root-level build outputs + common front-end paths.
# Tracked paths are skipped later.
CANDIDATES=()
for rel in \
  dist build target coverage .next .nuxt \
  test-results playwright-report .pytest_cache __pycache__ \
  frontend/dist web/dist backend/target backend/build \
  frontend/node_modules/.vite node_modules/.cache; do
  [ -e "$ROOT/$rel" ] && CANDIDATES+=("$rel")
done
for p in "$ROOT"/apps/*/dist; do
  [ -e "$p" ] && CANDIDATES+=("${p#$ROOT/}")
done
if [ "$INCLUDE_NODE_MODULES" = "1" ] && [ -e "$ROOT/node_modules" ]; then
  CANDIDATES+=("node_modules")
fi

# Junk files: logs, temp, OS files. Never look inside .git/.trash/node_modules.
FILE_CANDIDATES=""
while IFS= read -r f; do
  [ -n "$f" ] || continue
  FILE_CANDIDATES="${FILE_CANDIDATES}${f#$ROOT/}"$'\n'
done < <(find "$ROOT" -type f \
  \( -name '*.log' -o -name 'npm-debug.log*' -o -name 'yarn-error.log*' \
     -o -name '*.tmp' -o -name '*.bak' -o -name '*.swp' \
     -o -name '.DS_Store' -o -name 'Thumbs.db' \) \
  -not -path "$ROOT/.git/*" -not -path "$TRASH/*" -not -path "*/node_modules/*" 2>/dev/null)

list_items() {
  local total=0 count=0 rel kb
  echo "Project: $ROOT"
  echo ""
  if [ "${#CANDIDATES[@]}" -gt 0 ]; then
    echo "Build/cache directories:"
    for rel in "${CANDIDATES[@]}"; do
      [ -e "$ROOT/$rel" ] || continue
      if is_tracked "$rel"; then
        echo "  skip (tracked): $rel"
        continue
      fi
      kb="$(size_kb "$ROOT/$rel")"
      total=$((total + kb)); count=$((count + 1))
      printf '  %-40s %8s KB\n' "$rel" "$kb"
    done
  fi

  if [ -n "$FILE_CANDIDATES" ]; then
    echo "Log/temp files:"
    while IFS= read -r rel; do
      [ -n "$rel" ] || continue
      if is_tracked "$rel"; then
        echo "  skip (tracked): $rel"
        continue
      fi
      kb="$(size_kb "$ROOT/$rel")"
      total=$((total + kb)); count=$((count + 1))
      printf '  %-40s %8s KB\n' "$rel" "$kb"
    done <<EOF
$FILE_CANDIDATES
EOF
  fi

  echo ""
  echo "Total: $count item(s), $((total / 1024)) MB"
}

do_apply() {
  list_items
  echo ""
  if [ "${#CANDIDATES[@]}" -eq 0 ] && [ -z "$FILE_CANDIDATES" ]; then
    echo "Nothing to clean."
    return 0
  fi

  if [ "$YES" != "1" ]; then
    printf 'Move the items above to .trash? [y/N] '
    read -r answer
    case "$answer" in y|Y|yes|YES) ;; *) echo "Cancelled."; return 0 ;; esac
  fi

  local stamp dest rel moved=0
  stamp="$(date +%Y%m%d-%H%M%S)"
  dest="$TRASH/$stamp"
  mkdir -p "$dest" "$TRASH"
  echo "$(date '+%Y-%m-%d %H:%M:%S') apply $stamp" >> "$LOG"

  for rel in "${CANDIDATES[@]}"; do
    [ -e "$ROOT/$rel" ] || continue
    is_tracked "$rel" && continue
    mkdir -p "$dest/$(dirname "$rel")"
    if mv "$ROOT/$rel" "$dest/$rel" 2>/dev/null; then
      echo "  moved: $rel"
      moved=$((moved + 1))
    else
      echo "  FAILED to move: $rel" >&2
    fi
  done

  while IFS= read -r rel; do
    [ -n "$rel" ] || continue
    is_tracked "$rel" && continue
    mkdir -p "$dest/$(dirname "$rel")"
    if mv "$ROOT/$rel" "$dest/$rel" 2>/dev/null; then
      echo "  moved: $rel"
      moved=$((moved + 1))
    else
      echo "  FAILED to move: $rel" >&2
    fi
  done <<EOF
$FILE_CANDIDATES
EOF

  echo ""
  echo "Moved $moved item(s) to .trash/$stamp"
  echo "They will be deleted by --purge after ${RETENTION_DAYS} days."
}

do_purge() {
  [ -d "$TRASH" ] || { echo "No .trash directory."; return 0; }
  local removed=0
  while IFS= read -r d; do
    [ -n "$d" ] || continue
    rm -rf "$d" && { echo "  purged: ${d#$ROOT/}"; removed=$((removed + 1)); }
  done < <(find "$TRASH" -mindepth 1 -maxdepth 1 -type d -mtime +"$RETENTION_DAYS" 2>/dev/null)
  echo "Purged $removed item(s) older than ${RETENTION_DAYS} days."
}

do_branches() {
  is_git_repo || { echo "Not a Git repository."; return 0; }
  local current merged base
  current="$(git symbolic-ref --short -q HEAD 2>/dev/null || echo DETACHED)"
  base="main"
  git rev-parse --verify main >/dev/null 2>&1 || base="master"
  git rev-parse --verify "$base" >/dev/null 2>&1 || { echo "No main/master branch."; return 0; }
  merged="$(git branch --merged "$base" 2>/dev/null | sed 's/^..//' | grep -v "^${base}$" | grep -v "^${current}$" || true)"
  if [ -z "$merged" ]; then
    echo "No merged local branches to delete."
    return 0
  fi
  echo "Merged local branches:"
  printf '%s\n' "$merged" | sed 's/^/  /'
  if [ "$YES" != "1" ]; then
    printf 'Delete these local branches? [y/N] '
    read -r answer
    case "$answer" in y|Y|yes|YES) ;; *) echo "Cancelled."; return 0 ;; esac
  fi
  printf '%s\n' "$merged" | while IFS= read -r b; do
    [ -n "$b" ] || continue
    git branch -d "$b" && echo "  deleted: $b"
  done
}

print_schedule() {
  echo "Weekly cleanup (Monday 03:00). Add this line with 'crontab -e':"
  echo ""
  echo "0 3 * * 1 cd \"$ROOT\" && bash \"$SCRIPT_PATH\" --apply --yes --purge"
  echo ""
  echo "Windows: Task Scheduler -> weekly -> bash docs/standards/scripts/cleanup.sh --apply --yes --purge"
  echo ""
  echo "Tune retention with CLEANUP_RETENTION_DAYS (default 7)."
}

case "$MODE" in
  check) list_items ;;
  apply) do_apply ;;
  schedule) print_schedule ;;
  none) ;;
esac

[ "$DO_PURGE" = "1" ] && do_purge
[ "$DO_BRANCHES" = "1" ] && do_branches

exit 0
