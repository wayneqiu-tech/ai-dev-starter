# AGENTS.md — 给 AI 的常驻规则

> **用法**：复制到仓库根目录，改名为 `AGENTS.md`，把所有 `<...>` 换成你的项目信息。
> 不适用的段落可以删，但 §4（硬约束）和 §8（完成标准）要保留。
> 最后更新：`<YYYY-MM-DD>` · 当前版本：`<读取 VERSION>` · 维护人：`<名字>`

## 1. 项目一句话

`<是什么、给谁用、解决什么问题。例：帮助家长记录孩子每日阅读的 Web 应用，React + Node BFF。>`

## 2. 先读什么（按顺序）

1. `README.md` — 怎么跑、怎么配。
2. `VERSION` — 当前版本。
3. `docs/releases/` — 最近一份发布单（上次改了什么）。
4. `docs/standards/` — 工程规范。
5. 本文件 §4 — 硬约束。

## 3. 目录地图

```
src/            应用代码（主要改这里）
tests/          测试
docs/           文档；releases/ 是发布单，standards/ 是规范
scripts/        构建、发布、检查脚本；verify.sh 是固定摘要检查
STATUS.md       能力状态表（README 只放链接）
config/         配置模板（不要放真实密钥）
public/         静态资源
dist/           构建产物（不要手改，不要提交）
```

> 改代码前先确认文件属于哪个目录；**不要从其他项目或旧版本目录复制代码**。

## 4. 硬约束（不可协商）

1. **不改密钥/生产配置**：不读、不写 `.env`、`*.pem`、`*.key`、CI secrets；不把真实 IP/域名/密码写进代码或文档。
2. **不跨项目复制**：要复用就抽成模块，不要抄旧代码。
3. **不碰测试底线**：不删除/跳过测试，不改断言来“让测试通过”；测试不过就修代码或说明原因。
4. **不擅自加依赖**：新增依赖、升级大版本、改构建工具，必须先问。
5. **不直接发布**：可以在任务分支上提交（见 §6）；但不合并到 `main`、不 push、不打 tag、不部署生产、不删数据、不改 DNS；这些由人执行。
6. **不硬编码**：路径/端口/域名/密钥一律从配置读；示例值用 `<change-me>`。
7. **不超范围**：只改任务单列出的文件；发现别的问题先记录，不要顺手改。
8. **不伪造验证**：没跑过的命令不要说跑过；输出要原样贴。

## 5. 工作方式

1. **先说计划**：3 步以内，说明改哪些文件、怎么验证；大改等我确认。
2. **小步改**：一个提交只做一件事；Fast 通道可以在一个 PR 批量 3–5 个小改动；超过 10 个文件或 400 行，先拆。
3. **边改边验证**：每完成一块，跑相关测试/构建。
4. **自证**：结束时给出：
   - 改了哪些文件（每个一句话，为什么）
   - 对应任务单哪一条
   - 跑了什么命令、关键输出
   - 没做什么/已知限制
5. **不确定就问**：不要猜业务规则、不要猜端口、不要猜“用户大概想要”。

### 5.1 先选通道（不要所有项目一刀切）

| 通道 | 适用 | 要求 |
|---|---|---|
| **Fast** | 文案、样式、文档、小 UI；**不碰** schema/auth/payment/PII | 一个分支/PR 可批量 3–5 个小改动；typecheck + build + 相关 a11y；一次自证；人工确认 |
| **Controlled** | schema/迁移、认证、计费/退款、PII、真实外部系统 | 独立分支/PR；单测 + 迁移/回滚说明；人工 review；分阶段发布 |

不确定就选 **Controlled**。Fast 改动一旦碰到 schema/auth/payment/PII，必须切到 Controlled。

### 5.2 只在真正的门停

- **Plan Gate**：大改/需求不清时，确认方案。
- **Merge Gate**：功能完成、验证通过后，确认合并。
- **Release Gate**：部署/打 tag 前，仅 Controlled。

每个 Gate 输出 `docs/standards/templates/GATE.md` 的卡片并等待。一个 Gate 只批准一个动作；不允许“总是允许”合并/部署/删除。功能内部的子步骤不要每步都停。

## 6. 分支与提交

- **一个功能一个分支**：`feat/<slug>`、`fix/<slug>`、`docs/<slug>`、`chore/<slug>`；一个功能可以有 5–8 个提交，不要一个交互一个分支。
- Fast 通道可以在同一分支/PR 批量做 3–5 个小改动；Controlled 通道必须独立分支/PR。
- 你可以在**这个分支上**执行 `git switch -c`、`git add`、`git commit`。
- 合并、push、打 tag、部署之前必须停下来问我；这些不是你的权限。
- 如果目录不是 Git 仓库，或者你不能执行 Git，停下来问，不要猜。
- 提交：`<type>(<scope>): <subject>`；正文写**为什么**。
- AI 参与的提交加：`Co-authored-by: <工具名> <noreply@example.com>`。

## 7. 常用命令

```bash
# 安装
<npm install / pnpm install / pip install -r requirements.txt>

# 开发
<npm run dev>

# 测试
<npm test>

# 构建
<npm run build>

# 固定摘要验证
bash scripts/verify.sh

# 规范自检
bash docs/standards/scripts/preflight.sh

# 发布前自检
bash docs/standards/scripts/preflight.sh --release
```

## 8. 完成标准（缺一不可）

- [ ] 验收项全部满足
- [ ] 相关测试通过（贴输出）
- [ ] 构建通过（贴输出）
- [ ] `verify.sh` 摘要已贴（`typecheck/test/build/a11y`；skip 必须写明）
- [ ] 能力状态变化时已更新 `STATUS.md`
- [ ] `preflight` 没有新增 FAIL
- [ ] 没有密钥/硬编码/调试代码
- [ ] 涉及行为/配置/版本时，文档/发布单已更新
- [ ] 能说清“出问题怎么回滚”

## 9. 当前禁止 / 已知坑

- `<正在迁移的模块，暂时不要动>`
- `<不稳定的测试/环境>`
- `<冻结的分支/目录>`
- `<不要使用的旧接口/旧配置>`

## 10. 相关文档

| 文档 | 用途 |
|---|---|
| `docs/standards/` | 完整规范 |
| `docs/standards/pitfalls/` | 为什么有这些规则 |
| `docs/releases/` | 发布单 |
| `docs/standards/templates/GATE.md` | 一次决策的 Gate 卡片 |
| `STATUS.md` | 能力状态、证据、缺口 |
