#!/usr/bin/env bash
# =============================================================================
# init-project.sh — one command to bootstrap a project with AI Dev Standard
#
# Usage:
#   bash scripts/init-project.sh <target-dir> [options]
#
# Options:
#   --name <name>    project name (default: target directory name)
#   --lang en|zh     language for AGENTS.md and release note (default: en)
#   --semver         start at 0.1.0 with SemVer + v-prefixed tags
#   --no-git         do not git init / commit / tag
#   --no-ci          do not install .github/workflows/ci.yml
#   --no-hooks       do not install the commit-msg hook
#   -h, --help       show this help
#
# It never overwrites existing files (except appending config overrides).
# =============================================================================
set -euo pipefail

NAME=""
LANG_CODE="en"
SEMVER=0
DO_GIT=1
DO_CI=1
DO_HOOKS=1
TARGET=""

usage() {
  cat <<'EOF'
Usage: init-project.sh <target-dir> [--name <name>] [--lang en|zh] [--semver]
                       [--no-git] [--no-ci] [--no-hooks]

  --name <name>   project name (default: target directory name)
  --lang en|zh    language for AGENTS.md and release note (default: en)
  --semver        start at 0.1.0 with SemVer + v-prefixed tags
  --no-git        do not git init / commit / tag
  --no-ci         do not install .github/workflows/ci.yml
  --no-hooks      do not install the commit-msg hook
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --name)
      shift
      [ $# -gt 0 ] || { echo "--name needs a value" >&2; exit 2; }
      NAME="$1"
      ;;
    --lang)
      shift
      [ $# -gt 0 ] || { echo "--lang needs a value" >&2; exit 2; }
      LANG_CODE="$1"
      ;;
    --semver) SEMVER=1 ;;
    --no-git) DO_GIT=0 ;;
    --no-ci) DO_CI=0 ;;
    --no-hooks) DO_HOOKS=0 ;;
    -h|--help) usage; exit 0 ;;
    -*)
      echo "Unknown option: $1" >&2
      usage
      exit 2
      ;;
    *)
      if [ -n "$TARGET" ]; then
        echo "Only one target directory is supported" >&2
        exit 2
      fi
      TARGET="$1"
      ;;
  esac
  shift
done

[ -n "$TARGET" ] || { usage; exit 2; }
case "$LANG_CODE" in en|zh) ;; *) echo "--lang must be en or zh" >&2; exit 2 ;; esac

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
mkdir -p "$TARGET"
TARGET="$(cd "$TARGET" && pwd)"

case "$TARGET" in
  "$SRC"|"$SRC"/*)
    echo "Target must be outside the standard repo (got: $TARGET)" >&2
    exit 2
    ;;
esac

if [ -z "$NAME" ]; then
  NAME="$(basename "$TARGET")"
fi
case "$NAME" in
  *'"'*|*'\'*|*'&'*)
    echo "Project name must not contain quotes, backslashes, or '&'" >&2
    exit 2
    ;;
esac

copy_if_absent() {
  local src="$1" dst="$2"
  if [ -e "$dst" ]; then
    echo "  skip (exists): ${dst#$TARGET/}"
  else
    cp "$src" "$dst"
    echo "  created: ${dst#$TARGET/}"
  fi
}

copy_dir_if_absent() {
  local src="$1" dst="$2"
  if [ -e "$dst" ]; then
    echo "  skip (exists): ${dst#$TARGET/}"
  else
    cp -R "$src" "$dst"
    echo "  created: ${dst#$TARGET/}"
  fi
}

echo "AI Dev Standard → $TARGET"
echo "  project: $NAME · lang: $LANG_CODE · version: $([ "$SEMVER" = "1" ] && echo semver || echo dated)"

mkdir -p "$TARGET/docs/standards/docs" "$TARGET/docs/releases" "$TARGET/.github/workflows"

# --- handbook ---------------------------------------------------------------
copy_if_absent "$SRC/README.md" "$TARGET/docs/standards/README.md"
copy_if_absent "$SRC/README.zh.md" "$TARGET/docs/standards/README.zh.md"
copy_if_absent "$SRC/CHEATSHEET.md" "$TARGET/docs/standards/CHEATSHEET.md"
copy_if_absent "$SRC/CHEATSHEET.zh.md" "$TARGET/docs/standards/CHEATSHEET.zh.md"
copy_if_absent "$SRC/START_HERE.zh.md" "$TARGET/docs/standards/START_HERE.zh.md"
copy_if_absent "$SRC/PROMPTS.zh.md" "$TARGET/docs/standards/PROMPTS.zh.md"
copy_if_absent "$SRC/TROUBLESHOOTING.zh.md" "$TARGET/docs/standards/TROUBLESHOOTING.zh.md"
copy_if_absent "$SRC/LICENSE" "$TARGET/docs/standards/LICENSE"
copy_if_absent "$SRC/LICENSE-docs" "$TARGET/docs/standards/LICENSE-docs"
copy_if_absent "$SRC/CONTRIBUTING.md" "$TARGET/docs/standards/CONTRIBUTING.md"
copy_if_absent "$SRC/CHANGELOG.md" "$TARGET/docs/standards/CHANGELOG.md"

copy_dir_if_absent "$SRC/docs/en" "$TARGET/docs/standards/docs/en"
copy_dir_if_absent "$SRC/docs/zh" "$TARGET/docs/standards/docs/zh"
copy_dir_if_absent "$SRC/pitfalls" "$TARGET/docs/standards/pitfalls"
copy_dir_if_absent "$SRC/templates" "$TARGET/docs/standards/templates"
copy_dir_if_absent "$SRC/presets" "$TARGET/docs/standards/presets"
copy_dir_if_absent "$SRC/scripts" "$TARGET/docs/standards/scripts"

# --- project files ----------------------------------------------------------
if [ "$LANG_CODE" = "zh" ]; then
  copy_if_absent "$SRC/templates/AGENTS.zh.template.md" "$TARGET/AGENTS.md"
  copy_if_absent "$SRC/templates/release-note.zh.md" "$TARGET/docs/releases/TEMPLATE.md"
  copy_if_absent "$SRC/templates/pull_request.zh.md" "$TARGET/.github/pull_request_template.md"
else
  copy_if_absent "$SRC/templates/AGENTS.template.md" "$TARGET/AGENTS.md"
  copy_if_absent "$SRC/templates/release-note.md" "$TARGET/docs/releases/TEMPLATE.md"
  copy_if_absent "$SRC/templates/pull_request.md" "$TARGET/.github/pull_request_template.md"
fi

copy_if_absent "$SRC/templates/gitignore.txt" "$TARGET/.gitignore"
copy_if_absent "$SRC/presets/standard.conf" "$TARGET/standard.conf"

# Project name and optional SemVer override (last assignment wins)
if grep -q "generated by init-project.sh" "$TARGET/standard.conf" 2>/dev/null; then
  echo "  skip (exists): standard.conf overrides"
else
  {
    echo ""
    echo "# --- generated by init-project.sh ---"
    echo "PROJECT_NAME=\"$NAME\""
    if [ "$SEMVER" = "1" ]; then
      echo 'VERSION_SCHEME="semver"'
      echo 'TAG_PREFIX="v"'
    fi
  } >> "$TARGET/standard.conf"
fi

if [ -e "$TARGET/README.md" ]; then
  echo "  skip (exists): README.md"
else
  awk -v name="$NAME" '{ gsub(/<PROJECT_NAME>/, name); print }' \
    "$SRC/templates/README.project.md" > "$TARGET/README.md"
  echo "  created: README.md"
fi

if [ -e "$TARGET/VERSION" ]; then
  echo "  skip (exists): VERSION"
elif [ "$SEMVER" = "1" ]; then
  printf '0.1.0\n' > "$TARGET/VERSION"
  echo "  created: VERSION (0.1.0)"
else
  printf 'R%s.01\n' "$(date +%Y%m%d)" > "$TARGET/VERSION"
  echo "  created: VERSION ($(cat "$TARGET/VERSION"))"
fi

if [ "$DO_CI" = "1" ]; then
  copy_if_absent "$SRC/templates/github-workflows-preflight.yml" "$TARGET/.github/workflows/ci.yml"
fi

# --- git + hook -------------------------------------------------------------
OWN_REPO=0
COMMITTED=0
TAG_PREFIX=""
[ "$SEMVER" = "1" ] && TAG_PREFIX="v"
VERSION_VALUE="$(cat "$TARGET/VERSION")"
TAG="${TAG_PREFIX}${VERSION_VALUE}"

BASELINE_NOTE="$TARGET/docs/releases/${VERSION_VALUE}.md"
if [ -e "$BASELINE_NOTE" ]; then
  echo "  skip (exists): docs/releases/${VERSION_VALUE}.md"
else
  TIME_VALUE="$(date '+%Y-%m-%d %H:%M %z')"
  awk -v v="$VERSION_VALUE" -v t="$TIME_VALUE" -v tag="$TAG" -v name="$NAME" '{
    gsub(/<VERSION>/, v)
    gsub(/<TIME>/, t)
    gsub(/<TAG>/, tag)
    gsub(/<NAME>/, name)
    print
  }' "$SRC/templates/release-note-baseline.md" > "$BASELINE_NOTE"
  echo "  created: docs/releases/${VERSION_VALUE}.md (baseline)"
fi

if [ "$DO_GIT" = "1" ]; then
  TOP="$(git -C "$TARGET" rev-parse --show-toplevel 2>/dev/null || true)"
  if [ "$TOP" = "$TARGET" ]; then
    OWN_REPO=1
    echo "  git: existing repository"
  elif [ -n "$TOP" ]; then
    echo "  git: target is inside another repository ($TOP); skipping git init/commit"
  else
    git -C "$TARGET" init -q
    git -C "$TARGET" branch -M main 2>/dev/null || true
    OWN_REPO=1
    echo "  git: initialized (main)"
  fi

  if [ "$OWN_REPO" = "1" ] && ! git -C "$TARGET" rev-parse --verify HEAD >/dev/null 2>&1; then
    git -C "$TARGET" add -A
    if git -C "$TARGET" commit -q -m "chore: initialize project with AI Dev Standard"; then
      COMMITTED=1
      echo "  git: initial commit created"
    else
      echo "  git: initial commit FAILED (check user.name/user.email)" >&2
    fi
  fi

  if [ "$COMMITTED" = "1" ] && ! git -C "$TARGET" rev-parse -q --verify "refs/tags/$TAG" >/dev/null 2>&1; then
    if git -C "$TARGET" tag -a "$TAG" -m "baseline $TAG"; then
      echo "  git: tag created ($TAG)"
    else
      echo "  git: tag creation FAILED" >&2
    fi
  fi
else
  echo "  git: skipped (--no-git)"
fi

if [ "$DO_HOOKS" = "1" ] && [ "$OWN_REPO" = "1" ]; then
  GIT_DIR="$(git -C "$TARGET" rev-parse --absolute-git-dir 2>/dev/null || true)"
  HOOK_DIR=""
  [ -n "$GIT_DIR" ] && HOOK_DIR="$GIT_DIR/hooks"
  if [ -n "$HOOK_DIR" ]; then
    mkdir -p "$HOOK_DIR"
    if [ -e "$HOOK_DIR/commit-msg" ]; then
      echo "  hook: commit-msg exists; not overwritten"
    else
      cp "$SRC/templates/commit-msg-hook.sh" "$HOOK_DIR/commit-msg"
      chmod 755 "$HOOK_DIR/commit-msg"
      echo "  hook: commit-msg installed"
    fi
  fi
fi

# --- self-check -------------------------------------------------------------
if [ "$OWN_REPO" = "1" ] && git -C "$TARGET" rev-parse --verify HEAD >/dev/null 2>&1; then
  echo ""
  if [ "$COMMITTED" = "1" ]; then
    ( cd "$TARGET" && bash docs/standards/scripts/preflight.sh --release ) || true
  else
    ( cd "$TARGET" && bash docs/standards/scripts/preflight.sh ) || true
  fi
fi

# --- next steps -------------------------------------------------------------
echo ""
echo "Next:"
echo "  cd \"$TARGET\""
echo "  # edit AGENTS.md, README.md, and standard.conf"
echo "  # add your own LICENSE at the repo root (the copied one covers the handbook only)"
if [ "$DO_GIT" = "1" ] && [ "$OWN_REPO" = "1" ]; then
  echo "  git remote add origin <your-repo-url>"
  echo "  git push -u origin main --tags"
else
  echo "  git init && git branch -M main"
  echo "  git add -A && git commit -m \"chore: initialize project with AI Dev Standard\""
  echo "  git tag -a \"\$(cat VERSION)\" -m \"baseline \$(cat VERSION)\""
fi
echo "  # next release: copy docs/releases/TEMPLATE.md to docs/releases/<version>.md"
echo "  bash docs/standards/scripts/preflight.sh --release"
