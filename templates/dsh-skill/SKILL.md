---
name: ai-dev-standard
description: 用 AI Dev Standard 管理当前项目：先读规范、切分支、小步改、自证，合并/发布前检查；也用于项目自检、初始化、发布、回滚和定期清理。
whenToUse: 用户说“按规范做”“用 AI Dev Standard”“检查这个项目”“发布新版本”“回滚”“清理垃圾”“初始化项目”，或要求避免 AI 乱改、版本混乱、发布不可回滚时。
user-invocable: true
---

# AI Dev Standard（DSH Skill）

你正在使用 **AI Dev Standard 0.10.2 公测**。它是“小白优先的工程基线”，不是正式标准，也不保证项目一定成功。

## 先读什么（按顺序）

1. 项目根目录的 `AGENTS.md`（如果没有，先告诉用户）。
2. `docs/standards/START_HERE.zh.md`（如果存在）。
3. 根目录 `VERSION` 和 `docs/releases/` 里最近一份发布单。
4. 需要细节时再读：
   - AI 协作：`docs/standards/docs/zh/02-ai-workflow.md`
   - Git/版本/发布：`docs/standards/docs/zh/03-git-version-release.md`
   - 监控/清理：`docs/standards/docs/zh/07-monitoring-and-recovery.md`

如果 `docs/standards/` 不存在，先停下来，告诉用户“这个项目还没安装规范”，不要猜路径。

## 第一次加载时

用 3 行说明，不要长篇大论：

1. 当前项目 / 当前分支 / 当前版本（读不到就说读不到）。
2. 这次准备做什么（一句话）。
3. 做完怎么验证（一句话）。

## 工作方式

- **不直接改 `main`**：每个任务先开分支 `feat/`、`fix/`、`docs/` 或 `chore/`；用户明确说“不用分支”才跳过。
- **一次只做一件事**：超过 10 个文件或 400 行，先拆；不顺手重构、不顺手升级依赖。
- **小步验证**：每完成一块，跑相关测试/构建。
- **做完自证**：改了哪些文件、为什么、跑了什么命令、输出是什么、没做什么。
- **合并/推送/打 tag/部署前必须问用户**；不要自己发布。
- **不碰密钥**：`.env`、`*.pem`、`*.key`、生产配置；不把真实 IP/密码写进代码或文档。
- **不碰测试底线**：不删测试、不跳过测试、不改断言来“让测试通过”。
- **不超范围**：只改任务单列出的文件；发现别的问题先记录，不要顺手修。

## 收尾规则：Next Action Gate

每个任务完成时，不要用“如果你愿意，我可以……”这种自由文本收尾。
必须用宿主支持的**可点击问题/确认框**给出一个 `GATE: next`：

- 一个可执行的主行动（打开 PR 页、合并 PR、准备发布、跑验证）；
- 一个 `stop`；
- 一次只给一个主行动，不把“合并 + 发布 + 清理”塞进一个按钮；
- 没有可点击 UI 时，用编号选项。

### 有 next-action 插件时

如果 `next-action` 出现在技能目录，优先使用真实卡片：

1. 加载 `/next-action`；
2. 任务收尾调用 `propose_action`；
3. 卡片必须有一个主行动 + `stop`；
4. 没有插件时才退回 `ask_user_question`。

## 常用动作

```bash
# 当前状态
git branch --show-current
git status --short
cat VERSION

# 规范自检（只读）
bash docs/standards/scripts/preflight.sh

# 发布前自检
bash docs/standards/scripts/preflight.sh --release

# 垃圾清理：先 dry-run，确认后再 --apply
bash docs/standards/scripts/cleanup.sh
bash docs/standards/scripts/cleanup.sh --apply

# 新项目骨架（只在空目录/新项目用，不要对已有项目乱跑）
bash docs/standards/scripts/init-project.sh <目标目录> --name "<项目名>" --lang zh
```

## 用户说“检查这个项目”时

1. 先跑 `preflight`（不要修改任何文件）。
2. 用大白话总结：
   - 哪些 PASS；
   - 哪些 WARN；
   - 哪些 FAIL，以及“先修哪一个”。
3. 不要为了变绿去删检查、改脚本、跳过测试。

## 用户说“发布新版本”时

按 `docs/standards/docs/zh/03-git-version-release.md` §4 的顺序：

1. 工作区干净、在 `main`、已同步；
2. 写发布单草稿；
3. 构建；
4. 打 tag；
5. `preflight --release`；
6. 部署（用户执行或用户明确授权）；
7. 验证 `/health`、`/version`；
8. 推送 `main` + tag。

**验证失败就停，不要继续清理/发布。**

## 用户说“回滚”时

- 先找“上一个验证过的版本”，不要用“上一份文件”。
- 回滚只回代码，不回数据；数据修复单独做。
- 先告诉用户目标版本、命令、数据影响，等确认再执行。

## 用户说“清理垃圾”时

- 先跑 `cleanup.sh`（dry-run），把列表给用户看。
- 确认后再 `--apply`；它会把东西移到 `.trash/`，7 天后才 `--purge`。
- 不要手动 `rm -rf` 用户不认识的目录。

## 边界

- 这是 v0.10 公测基线，不是正式标准；没有一致性认证。
- 它不替代架构、业务、安全、合规设计。
- 不要承诺“保证没问题”；只承诺“把流程型事故降低，出事能退”。
