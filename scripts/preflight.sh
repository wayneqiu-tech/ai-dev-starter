#!/usr/bin/env bash
# =============================================================================
# AI Dev Standard — preflight self-check (read-only)
#
# Usage:
#   bash scripts/preflight.sh                # daily check
#   bash scripts/preflight.sh --release      # before a release (tag + note + clean tree)
#   bash scripts/preflight.sh --ci           # CI (skip branch/worktree checks)
#   bash scripts/preflight.sh --strict       # treat WARN as FAIL
#
# Exit codes: 0 = pass, 1 = FAIL, 2 = cannot check (not a Git repo / bad args)
# Requires: git, bash 3.2+ (macOS built-in is fine)
# =============================================================================
set -uo pipefail

MODE="normal"
STRICT=0
ALLOW_DEFAULTS=0

usage() {
  cat <<'EOF'
Usage: preflight.sh [--release] [--ci] [--strict] [--allow-defaults] [--help]

  --release  Release mode: require tag, release note, clean worktree
  --ci       CI mode: skip worktree/branch checks (CI is often detached HEAD)
  --strict   Treat WARN as FAIL
  --allow-defaults  Allow missing standard.conf (demo only; never for release)
  --help     Show this help
EOF
}

for arg in "$@"; do
  case "$arg" in
    --release) MODE="release" ;;
    --ci)      MODE="ci" ;;
    --strict)  STRICT=1 ;;
    --allow-defaults) ALLOW_DEFAULTS=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $arg" >&2; usage; exit 2 ;;
  esac
done

if [ -t 1 ]; then
  C_GREEN=$'\033[32m'; C_YELLOW=$'\033[33m'; C_RED=$'\033[31m'; C_DIM=$'\033[2m'; C_RESET=$'\033[0m'
else
  C_GREEN=''; C_YELLOW=''; C_RED=''; C_DIM=''; C_RESET=''
fi

PASS=0; WARN=0; FAIL=0

pass() { PASS=$((PASS + 1)); printf '%s[PASS]%s %s\n' "$C_GREEN" "$C_RESET" "$1"; }
warn() { WARN=$((WARN + 1)); printf '%s[WARN]%s %s\n' "$C_YELLOW" "$C_RESET" "$1"; }
fail() { FAIL=$((FAIL + 1)); printf '%s[FAIL]%s %s\n' "$C_RED" "$C_RESET" "$1"; }
note() { printf '       %s%s%s\n' "$C_DIM" "$1" "$C_RESET"; }

# ---------------------------------------------------------------- repo & config
ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || {
  echo "FAIL: not inside a Git repository (run git init first)" >&2
  exit 2
}
cd "$ROOT" || exit 2

CONF=""
for candidate in \
  "$ROOT/standard.conf" \
  "$ROOT/docs/standards/standard.conf"; do
  if [ -f "$candidate" ]; then
    CONF="$(cd "$(dirname "$candidate")" && pwd)/$(basename "$candidate")"
    break
  fi
done

if [ -z "$CONF" ] && [ "$ALLOW_DEFAULTS" != "1" ]; then
  echo "FAIL: no standard.conf found." >&2
  echo "Create one: cp docs/standards/presets/standard.conf ./standard.conf" >&2
  echo "Then edit PROJECT_NAME / VERSION_SCHEME / DEFAULT_BRANCH." >&2
  echo "Refusing to guess with defaults (fail-closed). Use --allow-defaults only for a demo." >&2
  exit 2
fi

# Defaults (a config file can override)
PROJECT_NAME="my-project"
DEFAULT_BRANCH="main"
VERSION_SCHEME="dated"
VERSION_FILE="VERSION"
RELEASE_NOTE_DIR="docs/releases"
TAG_PREFIX=""
BRANCH_PREFIXES="feat fix docs chore refactor test perf build ci"
BRANCH_MAX_AGE_DAYS=7
REQUIRE_PR=0
REQUIRE_CLEAN_TREE=1
REQUIRE_TAG=1
MAX_FILE_MB=5
ALLOW_TRACKED_DIST=0
SECRET_SCAN=1
REMOTE="origin"
LEDGER_FILE=".release/current"
LIVE_VERSION_URL=""
TAG_PATTERN=""
MAX_COMMIT_FILES=20
MAX_COMMIT_LINES=400
DOCS_VERSIONING=1
CHANGELOG=0
MODULES=""
TIMEZONE="Asia/Shanghai"

if [ -n "$CONF" ]; then
  # shellcheck disable=SC1090
  . "$CONF"
fi
: "${PROJECT_NAME:=my-project}"
: "${DEFAULT_BRANCH:=main}"
: "${VERSION_SCHEME:=dated}"
: "${VERSION_FILE:=VERSION}"
: "${RELEASE_NOTE_DIR:=docs/releases}"
: "${TAG_PREFIX:=}"
: "${BRANCH_PREFIXES:=feat fix docs chore refactor test perf build ci}"
: "${BRANCH_MAX_AGE_DAYS:=7}"
: "${REQUIRE_PR:=0}"
: "${REQUIRE_CLEAN_TREE:=1}"
: "${REQUIRE_TAG:=1}"
: "${MAX_FILE_MB:=5}"
: "${ALLOW_TRACKED_DIST:=0}"
: "${SECRET_SCAN:=1}"
: "${REMOTE:=origin}"
: "${LEDGER_FILE:=.release/current}"
: "${LIVE_VERSION_URL:=}"
: "${TAG_PATTERN:=}"
: "${MAX_COMMIT_FILES:=20}"
: "${MAX_COMMIT_LINES:=400}"
: "${DOCS_VERSIONING:=1}"
: "${CHANGELOG:=0}"
: "${MODULES:=}"
: "${TIMEZONE:=Asia/Shanghai}"

printf '\n%sAI Dev Standard preflight%s · %s · mode=%s\n' "$C_DIM" "$C_RESET" "$PROJECT_NAME" "$MODE"
printf '%srepo: %s%s\n\n' "$C_DIM" "$ROOT" "$C_RESET"
if [ -n "$CONF" ]; then note "config: ${CONF#$ROOT/}"; else note "no standard.conf found; --allow-defaults is active"; fi
note "scheme=$VERSION_SCHEME · main=$DEFAULT_BRANCH · tz=$TIMEZONE"

if [ "$ALLOW_DEFAULTS" != "1" ] && { [ -z "$PROJECT_NAME" ] || [ "$PROJECT_NAME" = "my-project" ]; }; then
  fail "standard.conf still has the placeholder PROJECT_NAME (my-project); edit it before checking"
fi
note "docs-versioning=$DOCS_VERSIONING · changelog=$CHANGELOG · modules=${MODULES:-single} · require-pr=$REQUIRE_PR"

# ---------------------------------------------------------------- branch & tree
pass "Git repository available"

BRANCH="$(git symbolic-ref --short -q HEAD 2>/dev/null || echo DETACHED)"

if [ "$MODE" = "ci" ]; then
  note "CI mode: skipping branch name and worktree checks"
elif [ "$BRANCH" = "DETACHED" ]; then
  warn "detached HEAD (use git worktree to inspect old versions; do not commit here)"
else
  prefix_re="$(printf '%s' "$BRANCH_PREFIXES" | tr ' ' '|')"
  allowed_re="^(${DEFAULT_BRANCH}|(${prefix_re})/[a-z0-9][a-z0-9._-]{1,39}|release/R[0-9]{8}\\.[0-9]{2}|hotfix/R[0-9]{8}\\.[0-9]{2}-[a-z0-9-]{2,30}|wip/[0-9]{8}-[a-z0-9-]{2,30})$"
  if [[ "$BRANCH" =~ $allowed_re ]]; then
    pass "branch name: $BRANCH"
  else
    fail "branch name not allowed: $BRANCH"
    note "allowed: $DEFAULT_BRANCH / <prefix>/<slug> / release/<version> / hotfix/<version>-<slug> / wip/<date>-<slug>"
    note "prefixes: $BRANCH_PREFIXES"
  fi

  if [ "$BRANCH" != "$DEFAULT_BRANCH" ]; then
    first_ts="$(git log --format=%ct "$DEFAULT_BRANCH..HEAD" 2>/dev/null | tail -1)"
    if [ -n "$first_ts" ]; then
      age_days=$(( ( $(date +%s) - first_ts ) / 86400 ))
      if [ "$age_days" -gt "$BRANCH_MAX_AGE_DAYS" ]; then
        warn "branch is ${age_days} days old (target <= ${BRANCH_MAX_AGE_DAYS})"
      else
        pass "branch age: ${age_days} days"
      fi
    fi
  fi
fi

if [ "$MODE" != "ci" ] && [ "$REQUIRE_CLEAN_TREE" = "1" ]; then
  dirty_count="$(git status --porcelain | wc -l | tr -d ' ')"
  if [ "$dirty_count" -eq 0 ]; then
    pass "worktree is clean"
  else
    fail "worktree is dirty: ${dirty_count} file(s) uncommitted/untracked"
    git status --short | head -10 | sed 's/^/       /'
  fi
fi

if [ -n "$(git remote 2>/dev/null)" ]; then
  pass "remote configured"
else
  warn "no remote configured (a dead disk loses everything)"
fi

# ---------------------------------------------------------------- version
VERSION=""
if [ -f "$VERSION_FILE" ]; then
  VERSION="$(tr -d '[:space:]' < "$VERSION_FILE")"
fi

if [ -z "$VERSION" ]; then
  fail "missing or empty version file: $VERSION_FILE"
  note "create one: printf 'R%s.01\\n' \"\$(date +%Y%m%d)\" > $VERSION_FILE"
else
  case "$VERSION_SCHEME" in
    dated)  version_re='^R[0-9]{8}\.[0-9]{2,3}$' ;;
    semver) version_re='^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]+)?$' ;;
    *)      version_re='^.+$' ;;
  esac
  if [[ "$VERSION" =~ $version_re ]]; then
    pass "version format: $VERSION"
  else
    fail "version format invalid: $VERSION (scheme=$VERSION_SCHEME)"
    if [ "$VERSION_SCHEME" = "dated" ]; then
      note "expected: R<YYYYMMDD>.<NN>, e.g. R20261106.01"
    else
      note "expected: MAJOR.MINOR.PATCH, e.g. 1.4.2"
    fi
  fi

  if git ls-files --error-unmatch "$VERSION_FILE" >/dev/null 2>&1; then
    pass "$VERSION_FILE is tracked"
  else
    warn "$VERSION_FILE is not tracked (a new machine or clean clone loses the version)"
  fi
fi

TAG="${TAG_PREFIX}${VERSION}"
NOTE_PATH="${RELEASE_NOTE_DIR}/${VERSION}.md"

if [ -n "$VERSION" ] && [ -f "$NOTE_PATH" ]; then
  note_bytes="$(wc -c < "$NOTE_PATH" | tr -d ' ')"
  if [ "$note_bytes" -gt 200 ]; then
    pass "release note: $NOTE_PATH"
  else
    warn "release note is very short (${note_bytes} bytes); probably incomplete"
  fi
else
  if [ "$MODE" = "release" ]; then
    fail "missing release note: $NOTE_PATH"
    note "template: templates/release-note.md"
  else
    warn "no release note yet: $NOTE_PATH (required before release)"
  fi
fi

if [ "$MODE" = "release" ] && [ "$REQUIRE_TAG" = "1" ]; then
  if git rev-parse -q --verify "refs/tags/${TAG}" >/dev/null 2>&1; then
    tag_type="$(git cat-file -t "$TAG" 2>/dev/null || echo unknown)"
    if [ "$tag_type" = "tag" ]; then
      pass "annotated tag exists: $TAG"
    else
      fail "tag is lightweight (type=$tag_type); recreate with git tag -a"
    fi

    head_sha="$(git rev-parse HEAD)"
    tag_sha="$(git rev-parse "${TAG}^{commit}" 2>/dev/null || echo none)"
    if [ "$head_sha" = "$tag_sha" ]; then
      pass "tag points to HEAD"
    else
      fail "tag does not point to HEAD (tag the release commit, not a later one)"
    fi
  else
    fail "tag does not exist: $TAG"
    note "create: git tag -a \"$TAG\" -m \"release $TAG\""
  fi
fi

# ---------------------------------------------------------------- traceability
if [ "$MODE" != "ci" ]; then
  upstream="$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null || true)"
  if [ -n "$upstream" ]; then
    ahead="$(git rev-list --count "$upstream..HEAD" 2>/dev/null || echo 0)"
    behind="$(git rev-list --count "HEAD..$upstream" 2>/dev/null || echo 0)"
    if [ "$ahead" -gt 0 ]; then
      if [ "$MODE" = "release" ]; then
        fail "unpushed commits: HEAD is ${ahead} commit(s) ahead of $upstream"
      else
        warn "unpushed commits: HEAD is ${ahead} commit(s) ahead of $upstream"
      fi
    else
      pass "HEAD is pushed to $upstream"
    fi
    if [ "$behind" -gt 0 ]; then
      warn "behind $upstream by ${behind} commit(s); fetch/rebase before release"
    fi
  else
    warn "branch has no upstream (push -u once, or this repo only exists locally)"
  fi
fi

if [ -n "$LEDGER_FILE" ] && [ -f "$LEDGER_FILE" ] && [ -n "$VERSION" ]; then
  ledger="$(tr -d '[:space:]' < "$LEDGER_FILE")"
  if [ "$ledger" = "$VERSION" ]; then
    pass "ledger matches version: $LEDGER_FILE"
  else
    if [ "$MODE" = "release" ]; then
      fail "ledger drift: $LEDGER_FILE=$ledger, $VERSION_FILE=$VERSION"
    else
      warn "ledger drift: $LEDGER_FILE=$ledger, $VERSION_FILE=$VERSION"
    fi
  fi
fi

if [ -z "$TAG_PATTERN" ]; then
  case "$VERSION_SCHEME" in
    dated)  TAG_PATTERN='^R[0-9]{8}\.[0-9]{2,3}$' ;;
    semver) TAG_PATTERN='^v?[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]+)?$' ;;
  esac
fi
tag_to_check=""
if [ "$MODE" = "release" ] && [ -n "$TAG" ]; then
  tag_to_check="$TAG"
else
  tag_to_check="$(git describe --tags --abbrev=0 2>/dev/null || true)"
fi
if [ -n "$tag_to_check" ] && [ -n "$TAG_PATTERN" ]; then
  if [[ "$tag_to_check" =~ $TAG_PATTERN ]]; then
    pass "tag naming: $tag_to_check"
  else
    if [ "$MODE" = "release" ]; then
      fail "tag naming does not match scheme: $tag_to_check (pattern=$TAG_PATTERN)"
    else
      warn "latest tag does not match scheme: $tag_to_check (pattern=$TAG_PATTERN)"
    fi
  fi
fi

if git rev-parse --verify HEAD >/dev/null 2>&1; then
  head_subject="$(git log -1 --format=%s)"
  if [[ "$head_subject" =~ ^(feat|fix|docs|refactor|perf|test|build|ci|chore|revert)(\([a-z0-9._-]+\))?:\ .{2,} ]] || [[ "$head_subject" =~ ^(Merge|Revert|Reapply)\  ]]; then
    pass "commit message: conventional"
  else
    warn "commit message is not Conventional Commits: $head_subject"
  fi

  if [ "$(git rev-list --count HEAD)" -gt 1 ]; then
    read -r changed_files changed_lines < <(git show --numstat --format='' HEAD | awk 'NF>=3 {f++; l += $1+$2} END {print f+0, l+0}')
    if [ "$changed_files" -gt "$MAX_COMMIT_FILES" ] || [ "$changed_lines" -gt "$MAX_COMMIT_LINES" ]; then
      warn "last commit is large: ${changed_files} files / ${changed_lines} lines (target <= ${MAX_COMMIT_FILES}/${MAX_COMMIT_LINES})"
    else
      pass "commit size: ${changed_files} files / ${changed_lines} lines"
    fi
  fi
fi

if [ "$MODE" = "release" ] && [ "$REQUIRE_PR" = "1" ]; then
  note "REQUIRE_PR=1: confirm this release was merged through a PR (cannot be checked locally)"
fi

if [ "$CHANGELOG" = "1" ]; then
  if [ -f CHANGELOG.md ]; then
    pass "CHANGELOG.md exists"
  else
    warn "CHANGELOG=1 but CHANGELOG.md is missing"
  fi
fi

# ---------------------------------------------------------------- secrets
if [ "$SECRET_SCAN" = "1" ]; then
  secret_files="$(git ls-files | grep -Ev '(\.example$|\.sample$|/templates/)' \
    | grep -E '(^|/)\.env($|\.)|\.pem$|\.key$|\.p12$|(^|/)id_(rsa|ed25519)|\.npmrc$' || true)"
  if [ -z "$secret_files" ]; then
    pass "no obvious secret files tracked"
  else
    fail "secret-like files are tracked by Git"
    printf '%s\n' "$secret_files" | head -10 | sed 's/^/       /'
    note "fix: git rm --cached <file> + rotate the key + add .gitignore"
  fi

  secret_hits="$(git grep -I -n -E 'BEGIN (RSA |OPENSSH |EC |DSA )?PRIVATE KEY|AKIA[0-9A-Z]{16}|gh[pousr]_[A-Za-z0-9]{20,}|xox[baprs]-[A-Za-z0-9-]{10,}|sk-[A-Za-z0-9_-]{20,}' -- . \
    ':(exclude)*.example' ':(exclude)*.sample' 2>/dev/null || true)"
  if [ -z "$secret_hits" ]; then
    pass "no obvious hardcoded secrets"
  else
    fail "possible hardcoded secret/token"
    printf '%s\n' "$secret_hits" | head -5 | sed 's/^/       /'
    note "rotate the key first, then clean history; deleting the file is not enough"
  fi
fi

# ---------------------------------------------------------------- repo hygiene
big_files=""
while IFS= read -r f; do
  [ -f "$f" ] || continue
  size="$(wc -c < "$f" 2>/dev/null | tr -d ' ')"
  [ -n "$size" ] || continue
  if [ "$size" -gt "$((MAX_FILE_MB * 1024 * 1024))" ]; then
    big_files="${big_files}${f} ($((size / 1024 / 1024)) MB)\n"
  fi
done < <(git ls-files)

if [ -z "$big_files" ]; then
  pass "no tracked file over ${MAX_FILE_MB} MB"
else
  warn "tracked files over ${MAX_FILE_MB} MB (use Release/LFS)"
  printf '%b' "$big_files" | head -10 | sed 's/^/       /'
fi

bad_dirs="$(git ls-files | grep -E '(^|/)(node_modules|target|coverage|\.next|\.nuxt)/' || true)"
if [ -z "$bad_dirs" ]; then
  pass "no obvious build caches tracked"
else
  fail "build cache/dependency directories are tracked"
  printf '%s\n' "$bad_dirs" | head -5 | sed 's/^/       /'
  note "fix: git rm -r --cached <dir> + .gitignore"
fi

dist_files="$(git ls-files | grep -E '(^|/)dist/' || true)"
if [ -z "$dist_files" ]; then
  pass "no dist/ tracked"
elif [ "$ALLOW_TRACKED_DIST" = "1" ]; then
  warn "dist/ is tracked (allowed by config; confirm it is intentional)"
else
  fail "dist/ is tracked (build output should not be in Git)"
  printf '%s\n' "$dist_files" | head -5 | sed 's/^/       /'
  note "if you need it (e.g. GitHub Pages), set ALLOW_TRACKED_DIST=1"
fi

binary_files="$(git ls-files | grep -Ei '\.(zip|tar\.gz|tgz|dmg|exe|apk|ipa|7z|rar)$' || true)"
if [ -z "$binary_files" ]; then
  pass "no installers/archives tracked"
else
  warn "installers/archives are tracked (prefer Release attachments)"
  printf '%s\n' "$binary_files" | head -5 | sed 's/^/       /'
fi

# ---------------------------------------------------------------- summary
echo
printf 'Result: PASS %s / WARN %s / FAIL %s\n' "$PASS" "$WARN" "$FAIL"

if [ "$FAIL" -gt 0 ]; then
  printf '%sFAILED: fix FAILs before releasing.%s\n' "$C_RED" "$C_RESET"
  exit 1
fi

if [ "$STRICT" = "1" ] && [ "$WARN" -gt 0 ]; then
  printf '%sSTRICT: WARN counts as FAIL.%s\n' "$C_RED" "$C_RESET"
  exit 1
fi

printf '%sPASS. Before release: backup, rollback command, release note.%s\n' "$C_GREEN" "$C_RESET"
exit 0
