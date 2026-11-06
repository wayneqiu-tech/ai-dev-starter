# 01 · 和 AI 一起工作

> 这一章是整套规范的核心。Git、版本、发布都可以慢慢补；**如果 AI 的协作方式不对，其他规则都会被绕过**。

## 1. 先把 AI 当成一个“新人”

AI 不是同事，也不是工具。它更像一个**很快、很自信、但不记得昨天、也不会为后果负责的新人**。

这意味着三件事：

1. **它需要上下文**：不读 `AGENTS.md`、不看相关文件，它就会按“常见做法”猜。
2. **它需要边界**：不告诉它“不要做什么”，它就会顺手重构、顺手升级、顺手改配置。
3. **它需要验收**：它说“已修复”不算数，要有文件、命令、输出、版本。

> 你给 AI 的不是鼓励，是**边界 + 验收标准**。

## 2. 六步循环

每一次任务，都走这六步。小改动可以压缩，但不能跳步。

```
1. 读  →  2. 计划  →  3. 小步改  →  4. 验证  →  5. 自证  →  6. 人 review
```

### 第 1 步：读

AI 开始前必须读：

- `AGENTS.md`（项目规则）
- `VERSION`（当前版本）
- 最近一份发布单（最近改了什么）
- 任务相关的文件（不是整个仓库）

**你要做的**：在任务单里写清“先读哪几个文件”，不要让它自己猜。

### 第 2 步：计划

让 AI 先给 **3 步以内的计划**：

- 改哪些文件？
- 怎么验证？
- 有什么风险/不做哪些？

计划不对，直接打回，不要让它“边做边想”。

### 第 3 步：小步改

- 一次只做一件事。
- 超过 10 个文件或 400 行，先拆。
- 不顺手重构、不顺手升级依赖、不顺手改配置。
- 发现别的问题，先记录，不要当场修。

### 第 4 步：验证

- 跑相关测试（不是“全量测试太慢”）。
- 跑构建。
- 需要时启动服务，走一遍核心路径。
- 没跑过的命令，不许说“应该没问题”。

### 第 5 步：自证

AI 结束时必须给出四样东西（见 §5）。缺一项，就算没完成。

### 第 6 步：人 review

你看的是“证据 + diff”，不是它的语气。review 清单见 §6。

> 这六步看起来慢，实际上比“AI 改完你不敢合、合了又回滚”快得多。

## 3. `AGENTS.md`：给 AI 的常驻规则

在仓库根目录放一份 `AGENTS.md`。它是**工具无关**的：Cursor、Claude Code、Copilot、Codex 都能读；各工具自己的规则文件只做“引用 + 补充”。

它必须包含 7 件事：

1. **项目一句话**：是什么、给谁用、当前版本。
2. **目录地图**：哪个目录放什么，哪些是生成物。
3. **常用命令**：安装、开发、测试、构建、发布。
4. **硬约束**：不能改什么、不能碰哪里、不能引入什么。
5. **分支/提交规范**：摘要 + 指向完整规范。
6. **完成标准**：什么算“做完了”。
7. **当前禁止/已知坑**：正在迁移的模块、不稳定的测试、冻结的分支。

模板见 [`../../templates/AGENTS.template.md`](../../templates/AGENTS.template.md)（中文版 [`AGENTS.zh.md`](../../templates/AGENTS.zh.template.md)）。

### 工具适配

| 工具 | 怎么接 |
|---|---|
| Cursor | `.cursor/rules/*.mdc`，`alwaysApply: true`，内容只写“读 AGENTS.md + 工具特有补充” |
| Claude Code | `CLAUDE.md`，第一行写“Read AGENTS.md first” |
| GitHub Copilot | `.github/copilot-instructions.md`，指向 `AGENTS.md` |
| Codex / 其他 | 直接读 `AGENTS.md` |

**不要维护三份项目规则**。一份 `AGENTS.md` 是唯一真源，其他文件只做适配。

## 4. 任务单：每次给 AI 的说明书

任务单越具体，AI 越不容易“自由发挥”。

```markdown
## 任务
<一句话：做什么>

## 背景
<为什么要做；相关文件、issue、上一版行为>

## 范围
- 只改：<文件/目录>
- 不要改：<明确排除>

## 验收
- [ ] <可执行检查，如 npm test>
- [ ] <行为验证，如 打开 /login 能登录>
- [ ] 版本/发布单已更新（如果涉及发布）

## 风险
<可能影响的地方；兼容性；需要特别注意的>
```

复制模板：[`../../templates/task-card.zh.md`](../../templates/task-card.zh.md)。

### 一个填好的例子

```markdown
## 任务
登录失败时，不要把用户已经输入的邮箱清空。

## 背景
用户反馈：输错密码后，邮箱也被清空，需要重新输入。
相关文件：src/pages/Login.tsx、src/api/auth.ts。

## 范围
- 只改：Login.tsx 的错误处理分支
- 不要改：API 签名、路由、样式

## 验收
- [ ] npm test 通过
- [ ] 手动：输错密码 → 邮箱仍在 → 只提示密码错误
- [ ] 不新增依赖

## 风险
错误状态可能被表单重置逻辑覆盖；注意 useEffect 依赖。
```

## 5. 自证：AI 交付的四个证据

AI 完成时，必须按这个格式输出：

```markdown
## 改了什么
- `src/pages/Login.tsx`：错误时保留 email 状态
- `src/pages/Login.test.tsx`：补了一个回归用例

## 为什么
对应任务单“输错密码后邮箱不应清空”。

## 怎么验证的
- `npm test` → 42 passed, 0 failed
- `npm run build` → success
- 手动：Chrome 输入错误密码 → 邮箱保留 ✅

## 没做什么 / 已知限制
- 没有改 API
- 没有处理“网络错误”分支（另一个任务）
```

**没有输出的“已完成”，等于没完成。**

## 6. 人 review：看这 10 条

按顺序看，不要只看 AI 的总结。

1. `git diff --stat`：改了哪些文件？有没有超范围？
2. `git diff`：逐行看；重点看配置、依赖、删除、异常处理。
3. **硬编码**：IP、绝对路径、密码、端口、`localhost`。
4. **偷懒**：`skip`、`only`、`TODO`、`any`、空 `catch`、注释掉的测试。
5. **测试**：有没有删测试、改断言、把失败改成跳过？
6. **依赖**：有没有新增/升级？为什么？许可证和体积可以接受吗？
7. **错误处理**：失败时是报错、重试、还是静默吞掉？
8. **配置**：新配置有没有写进 `.env.example`？默认值安全吗？
9. **回滚**：如果这次改动出问题，怎么退？数据会不会受影响？
10. **证据**：测试/构建/手动的输出在哪？版本/发布单更新了吗？

> 任何一条答不上来，就先别合。

### 6.1 谁来做哪一步（给普通人的默认）

你**不需要**手动敲分支命令。只要你的 AI 工具能执行终端命令，并且 `AGENTS.md`
里授权了，开分支、提交这些机械动作可以交给它：

| 动作 | AI | 你 |
|---|---|---|
| 开任务分支 | ✅ | — |
| 改代码、跑测试 | ✅ | — |
| 在分支上提交 | ✅ | — |
| 合并到 `main` | ⛔ 等你 | 说“合并”/点合并 |
| push、打 tag、发布 | ⛔ 等你 | 你做或你点头 |
| 改密钥、删数据 | ❌ | 只能你来做，且要小心 |

所以循环是：你说“做这个任务” → AI 开分支、改、测、提交 → AI 停下 → 你看一眼，
说“可以合并”。

> 前提是工具能执行 Git 命令（Cursor Agent、Claude Code、Codex CLI 等）。
> 纯聊天工具碰不到你的仓库，需要你自己敲命令或用 Git 图形界面。

## 7. AI 禁止清单

这些事不要让 AI 做；即使它“能做”，也不要授权。

- ❌ 直接 `git push` 到 `main`
- ❌ 直接部署生产、重启生产服务
- ❌ 删除数据、改数据库结构、改 DNS
- ❌ 读取/写入 `.env`、密钥、CI secrets
- ❌ 修改测试断言、跳过测试、删日志来“让检查通过”
- ❌ 把真实 IP、域名、密钥写进代码/文档/示例
- ❌ 从其他项目/旧版本目录复制代码
- ❌ 未经确认新增依赖、升级大版本、换构建工具
- ❌ 大规模重构混在功能提交里
- ❌ 为了让用户满意而谎报“已验证”

**AI 可以建议，但不能替你决定。**

## 8. 多会话、多工具协作

AI 没有长期记忆。你需要在仓库里给它“外置记忆”。

### 交接文件

长任务写 `docs/wip/<任务>.md`：

```markdown
# 任务：登录错误不清空邮箱
## 做到哪了
- [x] 复现
- [x] 改 Login.tsx
- [ ] 补测试
## 下一步
- 在 Login.test.tsx 加回归用例
## 坑
- useEffect 依赖数组会重置 email，别直接删
```

新会话开始前：`git status` + 读 `AGENTS.md` + 读交接文件。

### 决策记录

关键决策写 `docs/DECISIONS.md`，一页一条：

```markdown
## 2026-11-06 用日期号而不是 SemVer
- 背景：持续部署，一天可能发多次
- 选项：SemVer / 日期号 / 混合
- 结论：日期号 RYYYYMMDD.NN
- 影响：库的使用者无法从版本号判断兼容性；本项目不是库
```

### 同一时间只有一个写入者

- 一个任务一个分支。
- 不要两个 AI 会话同时改同一个目录。
- 会话结束前：提交或还原，不留半成品在工作区。

## 9. 四个常用 Prompt 模板

### 修 bug

```
Read AGENTS.md first.
Problem: <现象>
Repro: <步骤>
Expected: <期望>

Only fix the root cause in <files>. Do not refactor unrelated code.
Before editing, give a 3-step plan.
When done, provide: files changed, root cause, commands + output, rollback.
```

### 加功能

```
Read AGENTS.md and <files>.
Goal: <一句话>
Acceptance: <可执行标准>

Give a 3-step plan first. Only touch <scope>. Do not change <exclusions>.
If you need a new dependency, ask before adding it.
```

### 重构

```
Refactor only; behavior must not change. Scope: <files>.
Add tests first where coverage is missing. Run the existing tests after each step.
Do not mix feature changes into this refactor.
```

### Review

```
Act as a strict reviewer. Review this diff only; do not rewrite it.
Look for: scope creep, secrets, hardcoded values, deleted/skipped tests,
missing error handling, dependency changes, rollback risk.
List findings by severity (blocker / should-fix / nit), with file:line.
```

## 10. 一个完整的例子

**你**：

> 读 `AGENTS.md`。问题：登录失败后邮箱被清空。复现：输错密码 → 邮箱没了。期望：邮箱保留，只提示密码错误。只改 `Login.tsx`，不要动 API。先给 3 步计划。

**AI**：

> 计划：1) 找到表单重置逻辑；2) 只在密码错误时保留 email；3) 补一个回归用例并跑测试。

**你**：可以，做吧。

**AI**：（改完，按 §5 自证）

**你**：看 `git diff` → 只改了 2 个文件 → 跑 `npm test` → 看输出 → 合并。

这就是一次标准的 AI 协作。没有惊喜，也没有惊吓。

---

**下一章**：[02 · Git、版本、发布 →](03-git-version-release.md)
