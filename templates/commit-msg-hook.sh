#!/usr/bin/env bash
# Commit message check — installed by scripts/init-project.sh
# Allows merge/revert commits; enforces <type>(<scope>): <subject> otherwise.
set -uo pipefail

msg_file="${1:-}"
[ -n "$msg_file" ] && [ -f "$msg_file" ] || exit 0

first_line="$(head -1 "$msg_file")"

case "$first_line" in
  Merge\ *|Revert\ *|Reapply\ *) exit 0 ;;
esac

if printf '%s\n' "$first_line" | grep -qE '^(feat|fix|docs|refactor|perf|test|build|ci|chore|revert)(\([a-z0-9-]+\))?: .{2,50}$'; then
  exit 0
fi

cat >&2 <<'EOF'
Bad commit message.

Expected:
  <type>(<scope>): <subject>

Types: feat fix docs refactor perf test build ci chore revert
Subject: 2–50 characters, no trailing period.

Example:
  fix(login): keep email when login fails
EOF
exit 1
