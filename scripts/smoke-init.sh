#!/usr/bin/env bash
# =============================================================================
# smoke-init.sh — 生成器冒烟测试（只读，不碰工作区）
#
# 目的：验证 `init-project.sh` 生成出来的仓库**真的能用**，而不只是脚本语法正确。
# 背景：2026-11-12 实测发现，starter 的 CI 只检查脚本语法与自身规范，
#       从不验证生成物能否通过 preflight、commit-msg 钩子是否真的拦得住坏提交。
#
# 做三件事：
#   1. 临时目录里跑 init-project.sh，生成一个完整项目
#   2. 在生成物里跑 docs/standards/scripts/preflight.sh，要求 FAIL 0
#   3. 故意提交一条不合规的 commit，要求被 commit-msg 钩子拦下；再提交一条合规的，要求通过
#
# 用法：
#   bash scripts/smoke-init.sh            # 默认
#   bash scripts/smoke-init.sh --keep     # 保留临时目录以便排查
#
# 退出码：0 = 全过；1 = 有断言失败；2 = 环境缺依赖
# =============================================================================
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
KEEP=0
[ "${1:-}" = "--keep" ] && KEEP=1

for dep in git bash mktemp; do
  command -v "$dep" >/dev/null 2>&1 || { echo "缺少依赖：$dep" >&2; exit 2; }
done

# ---- 环境归一化（macOS 与 GitHub Actions 的差异点） ----------------------
# CI runner 默认没有 git user.name/email，且 git init 默认分支是 master 而非 main。
# 这里用环境变量兜住：不写用户全局配置，只影响本次进程与其子进程。
export GIT_AUTHOR_NAME="${GIT_AUTHOR_NAME:-smoke-init}"
export GIT_AUTHOR_EMAIL="${GIT_AUTHOR_EMAIL:-smoke-init@example.com}"
export GIT_COMMITTER_NAME="${GIT_COMMITTER_NAME:-smoke-init}"
export GIT_COMMITTER_EMAIL="${GIT_COMMITTER_EMAIL:-smoke-init@example.com}"
export GIT_CONFIG_COUNT="${GIT_CONFIG_COUNT:-1}"
export GIT_CONFIG_KEY_0="init.defaultBranch"
export GIT_CONFIG_VALUE_0="main"

WORK="$(mktemp -d "${TMPDIR:-/tmp}/smoke-init-XXXXXX")"
cleanup() {
  if [ "$KEEP" = "1" ]; then
    echo "临时目录保留在：$WORK"
  else
    rm -rf "$WORK"
  fi
}
trap cleanup EXIT

PASS=0
FAIL=0
ok()   { PASS=$((PASS + 1)); echo "  [PASS] $1"; }
bad()  { FAIL=$((FAIL + 1)); echo "  [FAIL] $1"; }

echo "smoke-init: 生成器冒烟测试"
echo "starter:   $ROOT"
echo "workspace: $WORK"
echo "git:       $(git --version)"
echo "default:   branch=${GIT_CONFIG_VALUE_0:-unset} author=${GIT_AUTHOR_EMAIL:-unset}"
echo

# ---- 1. 生成 ----------------------------------------------------------------
echo "[1/3] 生成新项目"
if bash "$ROOT/scripts/init-project.sh" "$WORK/demo" --name smoke-demo --lang zh --no-ci \
     >"$WORK/init.log" 2>&1; then
  ok "init-project.sh 退出码 0"
else
  bad "init-project.sh 失败，日志："
  tail -20 "$WORK/init.log"
fi

PROJ="$WORK/demo"
for f in AGENTS.md README.md STATUS.md VERSION standard.conf \
         docs/standards/scripts/preflight.sh docs/releases .gitignore; do
  if [ -e "$PROJ/$f" ]; then ok "生成物存在：$f"; else bad "生成物缺失：$f"; fi
done

# starter 自身专属工具不应出现在下游项目里
for f in docs/standards/scripts/smoke-init.sh docs/standards/scripts/sync-standards.sh; do
  if [ -e "$PROJ/$f" ]; then bad "不应出现在生成物里：$f"; else ok "已正确排除：$f"; fi
done

if [ "$FAIL" -gt 0 ]; then
  echo; echo "生成阶段已失败，后续跳过。"; exit 1
fi

cd "$PROJ" || exit 1

# ---- 2. 生成的仓库要能通过自己的规范检查 -----------------------------------
echo
echo "[2/3] 生成物跑 preflight"
if bash docs/standards/scripts/preflight.sh >"$WORK/preflight.log" 2>&1; then
  ok "preflight 退出码 0"
else
  bad "preflight 退出码非 0"
fi

RESULT_LINE="$(grep -E '^Result: ' "$WORK/preflight.log" | tail -1)"
echo "       $RESULT_LINE"
if printf '%s' "$RESULT_LINE" | grep -q 'FAIL 0'; then
  ok "preflight FAIL 0"
else
  bad "preflight 有 FAIL"
  grep -E '^\[FAIL\]' "$WORK/preflight.log" | head -5
fi

# ---- 3. commit-msg 钩子真的拦得住坏消息 ------------------------------------
echo
echo "[3/3] commit-msg 钩子"
git config user.name  "smoke-init"            >/dev/null 2>&1 || true
git config user.email "smoke-init@example.com" >/dev/null 2>&1 || true

if git commit --allow-empty -m "bad message without type" >"$WORK/hook-bad.log" 2>&1; then
  bad "不合规提交竟然通过了（钩子没生效）"
else
  ok "不合规提交被拦下"
fi

if git commit --allow-empty -m "chore(smoke): hook accepts conventional message" \
     >"$WORK/hook-good.log" 2>&1; then
  ok "合规提交通过"
else
  bad "合规提交被误拦"
  tail -10 "$WORK/hook-good.log"
fi

# ---- 汇总 -------------------------------------------------------------------
echo
echo "结果：PASS $PASS / FAIL $FAIL"
if [ "$FAIL" -eq 0 ]; then
  echo "冒烟测试通过：生成器产出的项目可直接使用。"
  exit 0
fi
echo "冒烟测试失败：生成器有回归，先修模板再发版。"
echo
echo "---- init-project.sh 输出（末 15 行）----"
tail -15 "$WORK/init.log" 2>/dev/null || echo "(无)"
echo "---- preflight 输出（末 15 行）----"
tail -15 "$WORK/preflight.log" 2>/dev/null || echo "(无)"
exit 1
