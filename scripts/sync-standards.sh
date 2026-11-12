#!/usr/bin/env bash
# =============================================================================
# sync-standards.sh — 把当前 AI Dev Standard 同步进一个已装规范的项目
#
# 背景：`init-project.sh` 是把规范**复制**进项目的，之后两边各自漂移。
# 本项目（starter）升级后，已装项目不会自动更新，而手动复制迟早会出现
# "三个项目三个版本"。本脚本提供唯一一条明确的升级通道。
#
# 用法：
#   bash scripts/sync-standards.sh <项目目录>            # 只看差异（默认）
#   bash scripts/sync-standards.sh <项目目录> --apply    # 真正写入
#
# 只同步这些：
#   <项目>/docs/standards/**        （规范正文、模板、脚本）
#
# 绝不碰这些（项目自己的东西）：
#   <项目>/standard.conf            （项目配置）
#   <项目>/AGENTS.md README.md STATUS.md
#   <项目>/docs/releases/**         （项目的发布史）
#   <项目>/src docs/en docs/zh ...  （项目自己的代码与文档）
#
# 写入前先备份；写入后跑一次 preflight，FAIL 就自动回滚。
# 退出码：0 = 无变化或已完成；1 = 有 FAIL 已回滚；2 = 用法/环境错误
# =============================================================================
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TARGET="${1:-}"
MODE="${2:-}"

if [ -z "$TARGET" ]; then
  echo "用法：bash scripts/sync-standards.sh <项目目录> [--apply]" >&2
  exit 2
fi
TARGET="$(cd "$TARGET" 2>/dev/null && pwd)" || { echo "项目目录不存在：$1" >&2; exit 2; }

if [ ! -d "$TARGET/docs/standards" ]; then
  echo "目标项目没有 docs/standards/：$TARGET" >&2
  echo "这个项目大概没装规范。装法：bash scripts/init-project.sh \"$TARGET\"" >&2
  exit 2
fi

for dep in git bash diff rsync mktemp; do
  command -v "$dep" >/dev/null 2>&1 || { echo "缺少依赖：$dep" >&2; exit 2; }
done

WORK="$(mktemp -d "${TMPDIR:-/tmp}/sync-standards-XXXXXX")"
cleanup() { rm -rf "$WORK"; }
trap cleanup EXIT

# 用生成器本身当"标准答案"：跑一次 init，拿它产出的 docs/standards 当基准。
# 这样不必在这里重复一遍文件映射，生成器改了这里自动跟上。
export GIT_AUTHOR_NAME="sync-standards" GIT_AUTHOR_EMAIL="sync@example.com"
export GIT_COMMITTER_NAME="sync-standards" GIT_COMMITTER_EMAIL="sync@example.com"
if ! bash "$ROOT/scripts/init-project.sh" "$WORK/ref" --name ref --lang zh \
       --no-git --no-ci --no-hooks >"$WORK/init.log" 2>&1; then
  echo "生成基准失败，日志：" >&2
  tail -20 "$WORK/init.log" >&2
  exit 2
fi
REF="$WORK/ref/docs/standards"

echo "sync-standards: $TARGET"
echo "基准:           $ROOT (被 init 生成的标准副本)"
echo

# ---- 差异 -------------------------------------------------------------------
DIFF_OUT="$WORK/diff.txt"
diff -rq "$REF" "$TARGET/docs/standards" >"$DIFF_OUT" 2>&1 || true

if [ ! -s "$DIFF_OUT" ]; then
  echo "✓ 无差异：该项目的规范副本与当前版本一致。"
  exit 0
fi

CHANGED=$(grep -cE '^Files .* differ$' "$DIFF_OUT" || true)
# 用基准路径里独有的 /ref/docs/standards 区分"新增"与"仅存在于项目"
ONLY_REF=$(grep -E '^Only in ' "$DIFF_OUT" | grep -c '/ref/docs/standards' || true)
ONLY_TGT=$(grep -E '^Only in ' "$DIFF_OUT" | grep -vc '/ref/docs/standards' || true)

echo "差异："
echo "  内容不同   $CHANGED 个文件"
echo "  新增（新版）$ONLY_REF 个"
echo "  仅存在于项目（将删除）$ONLY_TGT 个"
echo
sed -n '1,40p' "$DIFF_OUT" | sed 's/^/  /'
TOTAL=$((CHANGED + ONLY_REF + ONLY_TGT))
[ "$TOTAL" -gt 40 ] && echo "  ...（共 $TOTAL 条，以上只显示前 40 条）"
echo

if [ "$MODE" != "--apply" ]; then
  echo "这是预览。要真正写入请加 --apply："
  echo "  bash scripts/sync-standards.sh \"$TARGET\" --apply"
  exit 0
fi

# ---- 备份 -------------------------------------------------------------------
BACKUP="$WORK/backup"
cp -R "$TARGET/docs/standards" "$BACKUP"
echo "已备份到：$BACKUP（写在 $WORK，脚本结束前保留）"

# ---- 写入 -------------------------------------------------------------------
rsync -a --delete "$REF/" "$TARGET/docs/standards/"
echo "已写入：$TARGET/docs/standards/"

# ---- 验证，失败回滚 ----------------------------------------------------------
# 注意：同步本身就会让工作区变脏，preflight 必然报 worktree is dirty。
# 那是**预期的**，不算同步失败；只有其它 FAIL 才回滚。
echo
echo "验证：跑一次 preflight"
bash "$TARGET/docs/standards/scripts/preflight.sh" >"$WORK/pf.log" 2>&1 || true
RESULT="$(grep -E '^Result: ' "$WORK/pf.log" | tail -1)"

OTHER_FAILS="$(grep -E '^\[FAIL\]' "$WORK/pf.log" | grep -v 'worktree is dirty' || true)"
if [ -z "$OTHER_FAILS" ]; then
  echo "  ✓ ${RESULT:-（无 Result 行）}"
  echo "  （同步导致的工作区变脏属预期，提交后即恢复干净）"
  echo
  echo "同步完成。下一步："
  echo "  cd \"$TARGET\" && git switch -c chore/sync-standards"
  echo "  git add docs/standards && git commit -m \"chore(standards): sync to latest\""
  exit 0
fi

echo "  ✗ 同步引入了新的 FAIL，正在回滚" >&2
printf '%s\n' "$OTHER_FAILS" >&2
rm -rf "$TARGET/docs/standards"
cp -R "$BACKUP" "$TARGET/docs/standards"
echo "已回滚到同步前状态。" >&2
exit 1
