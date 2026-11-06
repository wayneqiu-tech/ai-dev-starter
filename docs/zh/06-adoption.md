# 05 · 落地

> 这一章解决“知道但做不到”：30 分钟怎么开始、老项目怎么救、日常怎么坚持。

## 1. 30 分钟开箱（新项目）

### 快速路径：一条命令

```bash
# 在规范仓库里执行
bash scripts/init-project.sh ../my-project --name "My App" --lang zh
cd ../my-project
```

它会生成：规范手册、`AGENTS.md`、`.gitignore`、`VERSION`、`README.md`、
`standard.conf`、一个与技术栈无关的 CI workflow、commit-msg 钩子；并自动执行
`git init`、首次提交、基线 tag、基线发布单和 `preflight`。

然后花 10 分钟改 `AGENTS.md`、`README.md`、`standard.conf`。

### 手动路径（脚本做的事）

用不了脚本，或者要把规范加进已有项目时，按下面的步骤来。

### 第 0 步：准备（2 分钟）

- Git 能跑（`git --version`）
- 一个远程仓库（GitHub / Gitee / 自建）
- 项目能构建（哪怕只有一个 `index.html`）

### 第 1 步：放规范（3 分钟）

```bash
mkdir -p docs
git clone <本仓库地址> docs/standards
rm -rf docs/standards/.git docs/standards/examples

cp -n docs/standards/templates/AGENTS.template.md ./AGENTS.md
cp -n docs/standards/templates/gitignore.txt ./.gitignore
mkdir -p docs/releases
cp -n docs/standards/templates/release-note.zh.md docs/releases/TEMPLATE.md
```

### 第 2 步：选预设（2 分钟）

```bash
cp docs/standards/presets/standard.conf ./standard.conf
```

改三个值：

- `PROJECT_NAME`
- `VERSION_SCHEME`（`dated` 或 `semver`）
- `DEFAULT_BRANCH`

### 第 3 步：写 `AGENTS.md`（10 分钟）

不要照抄模板。填上：

- 项目一句话
- 目录地图
- 常用命令（安装/开发/测试/构建）
- 硬约束（不能改什么）
- 完成标准

### 第 4 步：第一个版本（2 分钟）

```bash
printf 'R%s.01\n' "$(date +%Y%m%d)" > VERSION
git init && git branch -M main
git add -A
git commit -m "chore: initialize project with AI Dev Standard"
git tag -a "$(cat VERSION)" -m "baseline $(cat VERSION)"
```

### 第 5 步：接 CI（5 分钟）

把 [`../../templates/github-workflows-ci.yml`](../../templates/github-workflows-ci.yml) 复制到 `.github/workflows/ci.yml`，按你的技术栈改安装/测试命令。

### 第 6 步：自检（2 分钟）

```bash
bash docs/standards/scripts/preflight.sh
```

没有 `FAIL` 就算开箱完成。`WARN` 记下来，发布前处理。

### 第 7 步：第一次发布（5 分钟）

写 `docs/releases/<VERSION>.md`，跑：

```bash
bash docs/standards/scripts/preflight.sh --release
```

按 [`03-git-version-release.md`](03-git-version-release.md) §4.3 的顺序发布。

## 2. 三档预设：别一次上最严

### Minimal（极简）

适合：脚本、小工具、原型、一次性交付。

必须有：

- Git 仓库 + `.gitignore`
- `VERSION`
- commit 格式（能说清一件事）
- 发布单（可以只有 1 行：改了什么、怎么回滚）
- `preflight`（允许 WARN）

可以没有：分支、PR、CI、代码约定。

### Standard（标准，推荐）

适合：大多数 Web/AI 应用、独立开发者。

在 Minimal 基础上加：

- `main` + 短分支
- 9 项发布单
- 测试 + 构建门禁
- `AGENTS.md`
- 密钥扫描
- 发布 tag + 版本对账

### Strict（严格）

适合：开源库、收费产品、2 人以上团队。

在 Standard 基础上加：

- PR + review（至少 1 人，或“PR + 自检清单”）
- CHANGELOG
- 分支保护（禁直推、禁 force push）
- 回滚演练（每月）
- 依赖漏洞扫描
- 数据迁移演练

> 先用 Standard。觉得某条太麻烦，先降档，不要直接无视；觉得不够，再往上加。

## 3. 从混乱迁移的 7 步

> 适用：已经有一堆 `v1/v2/final/副本` 的项目。**不要一上来就重写历史。**

### 第 0 步：冻结

停止在旧目录上直接改；告诉大家（包括 AI）“现在开始只改新仓库”。

### 第 1 步：选唯一源

挑一个“最接近线上”的目录作为源；其他目录改名 `_frozen_<日期>`，设为只读。

### 第 2 步：建仓 + 首次提交

```bash
cd <选定的目录>
git init
git branch -M main
# 先写 .gitignore（node_modules/dist/.env/大文件）
git add -A
git status --short          # 确认没有 node_modules/.env
git commit -m "chore: baseline import"
```

### 第 3 步：打基线 tag + 写基线发布单

```bash
printf 'R%s.01\n' "$(date +%Y%m%d)" > VERSION
git add VERSION && git commit -m "chore: establish version baseline"
git tag -a "$(cat VERSION)" -m "baseline $(cat VERSION)"
```

### 第 4 步：处理密钥

1. 把 `.env` 从索引移除：`git rm --cached .env`
2. **轮换密钥**
3. 补 `.env.example`
4. 再考虑清理历史（`git filter-repo`）

> 顺序不能反：先删文件后轮换 = 密钥仍然有效。

### 第 5 步：接 CI + preflight

至少跑构建 + 测试 + 自检；把“本地能跑”变成“机器能证明”。

### 第 6 步：逐个搬回 `_frozen_` 里的改动

每个改动一个分支/PR，跑测试，合入；不要一次性 `cp -r`。

### 第 7 步：30 天后删除 `_frozen_`

确认没有遗漏、有 tag/远程备份后删除；删之前再跑一次全量测试。

## 4. 日常清单

### 4.1 每次开工（30 秒）

- [ ] `git status` 干净，或知道自己在哪个分支
- [ ] `git pull` 到最新
- [ ] 读一眼 `AGENTS.md` / 当前任务单

### 4.2 每次提交（2 分钟）

- [ ] 只做了一件事
- [ ] 提交信息能说清“为什么”
- [ ] 没有 `console.log` / 调试代码 / 注释掉的代码
- [ ] 没有密钥、真实 IP、绝对路径
- [ ] 测试/构建跑过（至少受影响的模块）

### 4.3 每次合并（5 分钟）

- [ ] CI 绿
- [ ] diff 没有超范围
- [ ] 测试覆盖了新行为（或说明为什么没有）
- [ ] 文档/发布单已更新（如涉及）
- [ ] 知道怎么回滚

### 4.4 每次发布（15 分钟）

- [ ] 工作区干净，`main` 最新
- [ ] CI 绿，测试/构建通过
- [ ] `VERSION` 已更新，格式正确
- [ ] tag 已打，指向正确 commit
- [ ] 发布单 9 项齐全
- [ ] 回滚目标 + 命令 + 数据影响写清
- [ ] 备份完成（有状态系统）
- [ ] 生产配置齐全
- [ ] 部署后 `/version` 与 `VERSION` 一致
- [ ] 核心路径验证通过，观察 30 分钟

### 4.5 每月（30 分钟）

- [ ] 删已合并分支、清 stash
- [ ] 跑一次 `bash docs/standards/scripts/cleanup.sh`（先 dry-run），确认每周自动清理在跑
- [ ] 仓库体积 Top 10 检查
- [ ] 死链检查、文档过期检查
- [ ] `AGENTS.md` 更新
- [ ] 依赖漏洞/版本检查
- [ ] 回滚演练（staging）
- [ ] 密钥轮换提醒（按周期）

### 4.6 紧急故障（前 10 分钟）

- [ ] 先止损：回滚 / 关开关 / 限流
- [ ] 记录时间线和影响面
- [ ] 通知相关人（如有）
- [ ] 不要在故障现场调试
- [ ] 恢复后 24 小时内复盘

## 5. 常见问题

**Q1：我一个人开发，也要开分支、写 PR 吗？**
分支建议开（隔离未完成品），PR 可选。单人最低配：`main` + `feat/fix` 短分支 + 合并前跑 `preflight`。PR 的好处是留下“为什么”和自检记录；不想用就写提交正文 + 发布单。如果你用能执行命令的 AI 工具，可以让它开分支、提交；你只负责合并/发布。

**Q2：一天发好几次，版本号会不会很碎？**
会，但没关系。日期号本来就是给“高频交付”用的。真正重要的是每次发布都能回答“哪版、改了什么、怎么回滚”。

**Q3：只改文档也要发版吗？**
建议发（类型 `docs`），成本很低。如果项目很小，可关掉，但要在 README 写明“文档不单独发版”。

**Q4：AI 写的代码要全部测试吗？**
不需要“全部”，但需要：核心路径有自动化测试；AI 改过的模块必须跑；边界/异常路径至少人工验一次。

**Q5：能不能直接 push `main`？**
不建议。哪怕一个人，也走“分支 → 自检 → 合并”，因为 `main` 是“随时能发”的底线。紧急情况可以直接改，但改完必须补提交 + 补测试 + 记录。

**Q6：回滚后数据怎么办？**
代码回滚，数据只前滚。如果新版本写了新格式数据，旧代码要能读（兼容一格）；读不了就只能“前滚修复”。所以 schema 变更要特别小心。

**Q7：开源项目用 SemVer 还是日期号？**
别人要 `npm install` 的库用 SemVer；Web 应用/服务用日期号。也可以“对外 SemVer + 对内日期号”，但要在文档写清映射。

**Q8：历史里已经有密钥了怎么办？**
先轮换/吊销，再清理历史，再通知协作者重新 clone。只删文件不轮换 = 没处理。

**Q9：小项目要不要 monorepo？**
单包能解决就不要 monorepo。需要多包时再拆；拆的时候用 workspace，不要复制代码。

**Q10：没有测试的项目怎么开始？**
先写 3 个“核心路径”测试 + 1 个冒烟脚本（启动 → 健康检查 → 关键接口）。不要追求覆盖率，先追求“改坏了能发现”。

**Q11：版本号能跳号/复用吗？**
能跳（没记录 = 没发生）；不能复用（哪怕只发了一半）。回滚不产生新号。

**Q12：多个 AI 工具（Cursor/Claude/Codex）规则怎么统一？**
仓库根目录放一份 `AGENTS.md` 作为唯一规则源；各工具自己的文件只写“读 AGENTS.md + 工具特有补充”。

**Q13：发布失败算“发过”吗？**
算一次尝试，号也留痕、**不复用**。发布单记录失败原因；修好后发下一个号。

**Q14：什么时候可以不发版？**
只改注释/README 且不影响产物时，可以不发；但要在提交信息里写 `docs:`，并在下一次发布单带上。涉及配置、依赖、Prompt、阈值的改动，一律发版。

## 6. 怎么定制

### 6.1 只改参数

编辑 `standard.conf`：

| 参数 | 用途 |
|---|---|
| `PROJECT_NAME` | 提示用 |
| `VERSION_SCHEME` | `dated` / `semver` |
| `VERSION_FILE` | 版本文件路径 |
| `RELEASE_NOTE_DIR` | 发布单目录 |
| `DEFAULT_BRANCH` | 主分支 |
| `BRANCH_PREFIXES` | 允许的分支前缀 |
| `REQUIRE_PR` | 是否要求 PR |
| `MAX_FILE_MB` | 大文件阈值 |
| `SECRET_SCAN` | 是否扫密钥 |

### 6.2 改规范正文

- 可以整份复制、修改、再发布（文档 CC BY 4.0，需署名）。
- 升 `STD-x.y`，在 `CHANGELOG.md` 写清“改了什么、为什么、要不要迁移”。
- 项目可以比标准更严，不能更松的只有五条：
  1. 密钥不进仓库
  2. 验证失败不发布
  3. 回滚目标必须验证过
  4. 生产只接受仓库构建的产物
  5. AI 不直接操作生产/删数据/改密钥

### 6.3 记录偏离

在 `docs/standards/DECISIONS.md` 写：

```markdown
## 我们为什么不用 PR
- 背景：单人项目，PR 只给自己看
- 替代：每次合并前跑 preflight + 测试，提交正文写 why
- 风险：没有第二双眼睛；接受
```

## 7. 最后一句

规范不是用来“显得专业”的。它只有两个作用：

1. **让事故少发生**；
2. **让事故发生时，你能退回去**。

如果一条规则既不能减少事故，也不能帮你回退，那它就不该存在。删掉它。

---

**回到**：[README](../../README.zh.md) · [一页纸](../../CHEATSHEET.zh.md) · [踩坑清单](../../pitfalls/zh.md)
