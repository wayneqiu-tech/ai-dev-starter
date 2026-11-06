# AI Dev Standard · 开发过程规范

> **它是一套“开发过程规范”，不是“项目诊断工具”。**
>
> 它不判断业务、架构、安全、性能；
> 它只保证 AI 按规矩开发、发布可回滚、记录可查。

你只需要会给 AI 下指令。开草稿、存档、贴版本号、写发布记录，这些事 AI 按规则做；你只负责看证据，点“合并”或“发布”。

**具体管**：AI 一次改多少、版本号、发布单、回滚、旧分支和垃圾清理。
**不负责**：业务规则、架构设计、安全审计、性能优化、合规判断。

> 公测 0.9.2 · 还不是正式标准 · [English](README.md)
> 第一次来？看 [START_HERE.zh.md](START_HERE.zh.md)。

来自 **47 次真实工程事故**，提炼成 **30 个踩坑模式** + 模板/脚本/示例。不绑定工具：Cursor、Claude Code、Copilot、Codex、普通聊天窗口都能用。

---

## 要解决的问题：五个循环

大多数项目不是被一个大错误搞垮的，而是被循环拖垮的：

| # | 循环 | 怎么开始 | 怎么“结束”（错误方式） | 真正该做的 |
|---|---|---|---|---|
| 1 | **复制循环** | 怕改坏，复制一份文件夹 | 两份都改了，不知道哪份对，再复制一份 | 用 Git 分支/tag；只保留一个工作目录 |
| 2 | **配置循环** | 改端口/路径只改一处 | 联调失败，直接上服务器手工改 | 一个配置真源；启动打印生效值；部署后校验 |
| 3 | **测试循环** | 赶时间，跳过测试 | 上线出错，紧急回滚，回滚只有一层 | 门禁前置；回滚目标必须验证过 |
| 4 | **文档循环** | 文档写一套，脚本做另一套 | AI 按文档做错，再补一份新文档 | 文档入 Git；一个入口；和代码同一个 PR |
| 5 | **顺手循环** | “来都来了”，顺手改端口/依赖/配置 | 无法单独回滚，只能全部重来 | 一次只做一件事；一个提交只回滚一件事 |

> 这套标准存在的目的，是打断这五个循环，而不是增加流程负担。

---

## 它是什么

- 给**独立开发者、公民开发者、1–5 人小团队**的默认基线。
- 一份**你和 AI 之间的合同**：先读什么、做什么、不许碰什么、怎么证明做完了。
- 一套**可检查**的规则：版本格式、tag、发布单、密钥、大文件、未推送提交、账本漂移、线上版本，都能用 `preflight.sh`、`check-release-sync.sh` 和 CI 查。
- 一个**可以 fork、裁剪、加严**的起点。

## 状态（公测）

- **0.9.2 公测**：可以马上用，但要有“还会变”的心理准备。
- **可以放心用的**：模板、预设、`preflight.sh`、`cleanup.sh`、`init-project.sh`。
- **1.0 前可能变的**：规则名、层级边界、措辞、默认脚本。
- **1.0 的条件**：10 个小白走完 30 分钟路径、关掉 5 个真实摩擦 issue、3 个项目采用，再加上正式的 `SPEC.md` 和一致性检查。
- **不是正式标准，也不是认证。** 见 [`GOVERNANCE.md`](GOVERNANCE.md)。

## 它不是什么

- **不保证产品成功。** 它降低的是流程型事故（版本混乱、发布不可回滚、密钥泄露），不验证你的业务规则、架构、支付、打印、性能、合规。
- **不是架构/产品文档。** 它不教你怎么设计租户、怎么定价、怎么建表。
- **不替代 Lint/格式化工具。** 代码风格交给 ESLint、Prettier、Ruff、gofmt；这套基线管“人 + AI 的协作方式”和“不可协商的代码底线”。
- **不是认证。** 项目可以比它更严；比它更松的，要写清原因并接受风险。

> 完整来龙去脉见 [`docs/zh/01-why.md`](docs/zh/01-why.md)。

---

## 给谁用

- **独立开发者**：每天用 AI 写代码，但不想再“凭感觉发布”。
- **公民开发者**：会用 AI 做出东西，但没人教过 Git、发布、回滚。
- **1–5 人小团队**：多个 AI 工具、多个人，需要一套共同规则。
- **开源维护者**：希望人类和 AI 贡献者都按同一套规则来。

你**不需要**懂 Git 底层原理。你只需要 30 分钟和一个项目。

## 第一次用？小白入口

如果你只会下指令、不懂代码或 Git：

- **[START_HERE.zh.md](START_HERE.zh.md)** —— 先复制一段话，不用懂 Git
- **[PROMPTS.zh.md](PROMPTS.zh.md)** —— 15 张复制即用的指令卡
- **[TROUBLESHOOTING.zh.md](TROUBLESHOOTING.zh.md)** —— 报错、冲突、发布失败时说什么

这条路径假设你**完全不懂 Git**；下面的内容才是给开发者的。

---

## 5 分钟上手

### 方式 A：一条命令（推荐）

```bash
git clone <本仓库地址> ai-dev-standard
cd ai-dev-standard
bash scripts/init-project.sh ../my-project --name "My App" --lang zh
cd ../my-project
```

这条命令会生成：规范手册、`AGENTS.md`、`.gitignore`、`VERSION`、`README.md`、
`standard.conf`、CI workflow、commit-msg 钩子；并自动执行 `git init`、首次提交、
基线 tag、基线发布单和 `preflight` 自检。

```bash
# 改 AGENTS.md / README.md / standard.conf
git remote add origin <你的仓库地址>
git push -u origin main --tags
```

常用参数：

| 参数 | 作用 |
|---|---|
| `--lang zh` | 中文 `AGENTS.md`、发布单、PR 模板 |
| `--semver` | 从 `0.1.0` 开始，tag 为 `v0.1.0` |
| `--no-ci` | 不安装 `.github/workflows/ci.yml` |
| `--no-hooks` | 不安装 commit-msg 钩子 |
| `--no-git` | 只生成文件，不执行 git init/commit/tag |

### 方式 B：把规范加进已有项目

```bash
# 1) 把规范克隆到 docs/standards（也可以用 submodule）
mkdir -p docs
git clone <本仓库地址> docs/standards
rm -rf docs/standards/.git docs/standards/examples

# 2) 放模板
cp -n docs/standards/templates/AGENTS.template.md ./AGENTS.md
cp -n docs/standards/templates/gitignore.txt ./.gitignore
mkdir -p docs/releases
cp -n docs/standards/templates/release-note.zh.md docs/releases/TEMPLATE.md

# 3) 选一档预设放到项目根目录，再改三个值
cp docs/standards/presets/standard.conf ./standard.conf
#    PROJECT_NAME / VERSION_SCHEME / DEFAULT_BRANCH

# 4) 写第一个版本号
printf 'R%s.01\n' "$(date +%Y%m%d)" > VERSION

# 5) 首次提交 + 基线 tag
git add -A
git commit -m "chore: adopt AI Dev Standard"
git tag -a "$(cat VERSION)" -m "baseline $(cat VERSION)"

# 6) 自检
bash docs/standards/scripts/preflight.sh
```

期望：没有 `FAIL`。`WARN` 可以稍后处理（常见是“还没配远程仓库”“还没有发布单”）。

---

## 在 DSH 里用（可选）

如果你用 DeepSeek Harness，`init-project.sh` 会自动装一个 Skill：

```
.dsh/skills/ai-dev-standard/SKILL.md
```

在 DSH 里打开项目，输入：

```text
/ai-dev-standard 检查当前项目
```

或者：

```text
/ai-dev-standard 帮我初始化一个新项目
```

它是 **Skill，不是插件**：不用安装、不会在 Host 里跑代码、没有授权弹窗。
不用 DSH 的话，忽略 `.dsh/` 目录即可。

---

## 补上 preflight 看不到的三件事

`preflight.sh` 是本地只读检查，它不知道发布有没有推到远程、账本和线上是否一致、HEAD 有没有 tag。所以再加一个对账：

```bash
bash scripts/check-release-sync.sh
```

它只查三样：

1. `HEAD` 是否等于 `origin/<branch>`（发布不只在这台笔记本上）；
2. 账本 / `VERSION` 是否等于线上 `/version`（账本没漂移）；
3. `HEAD` 是否有 tag，且 tag 与账本一致（发布可复现）。

`LIVE_VERSION_URL` 可选；在 `standard.conf` 或环境变量里设置。

---

## 三档预设：先选一档

| 档位 | 适合 | 你会得到 | 可以跳过 |
|---|---|---|---|
| **Minimal** | 脚本、小工具、原型 | Git、`VERSION`、提交格式、一行发布单、自检 | 分支、PR、CI、代码约定 |
| **Standard** | 大多数 Web/AI 应用 | Minimal + 短分支 + 9 项发布单 + 测试/构建门禁 + `AGENTS.md` | 正式架构文档、多模块版本 |
| **Strict** | 开源库、收费产品、团队 | Standard + PR review + CHANGELOG + 密钥扫描 + 回滚演练 + 分支保护 | 没有推荐跳过的 |

预设见 [`presets/`](presets/)。先用 `standard.conf`，觉得疼了再升级。

---

## 仓库里有什么

```
.
├─ README.md / README.zh.md       # 本文件
├─ START_HERE.zh.md               # 小白入口：先复制一段话，不用懂 Git
├─ PROMPTS.zh.md                  # 复制即用的指令卡
├─ TROUBLESHOOTING.zh.md          # 出问题说什么
├─ CHEATSHEET.md / .zh.md         # 一页纸，可打印
├─ VERSION                        # 基线自身的版本（0.9.2）
├─ standard.conf                 # 本仓库的 preflight 配置
├─ docs/
│  ├─ en/  zh/                    # 7 篇，中英双语
│  └─ releases/                   # 规范自身的发布单
├─ pitfalls/                      # 47 次事故提炼的 30 个模式
├─ templates/                     # AGENTS、commit、PR、发布单、CI、健康检查、systemd、Docker、DSH Skill
├─ presets/                       # minimal / standard / strict
├─ scripts/
│  ├─ preflight.sh                # 只读自检
│  ├─ check-release-sync.sh       # 远程 / 账本 / 线上 / tag 对账
│  ├─ cleanup.sh                  # 每周清理 + 7 天回收站
│  └─ init-project.sh             # 一条命令初始化（git/提交/tag/CI/钩子）
├─ examples/hello-standard/       # 可运行示例（Node，无依赖）
├─ .github/                       # issue 模板、PR 模板、CI
├─ SECURITY.md                    # 怎么报漏洞
├─ GOVERNANCE.md                  # 谁决策、1.0 怎么来
├─ LICENSE                        # MIT（代码与模板）
└─ LICENSE-docs                   # CC BY 4.0（文档）
```

---

## 规则速览

| 主题 | 默认做法 | 详见 |
|---|---|---|
| 分支 | `main` + 短分支 `feat/ fix/ docs/ chore/ refactor/ test/`，≤7 天 | [第 3 章](docs/zh/03-git-version-release.md) |
| 提交 | `type(scope): subject`，正文写**为什么** | [第 3 章](docs/zh/03-git-version-release.md) |
| 版本 | 默认 `RYYYYMMDD.NN`，可选 SemVer | [第 3 章](docs/zh/03-git-version-release.md) |
| Tag | annotated，与 `VERSION` 同名，指向被构建的提交 | [第 3 章](docs/zh/03-git-version-release.md) |
| 发布 | 门禁 → 构建 → tag → 自检 → 部署 → 验证 → 发布单 | [第 3 章](docs/zh/03-git-version-release.md) |
| 回滚 | 指回验证过的版本；数据只前滚 | [第 3 章](docs/zh/03-git-version-release.md) |
| AI | 读 `AGENTS.md`；任务单；小步改；自证；人 review | [第 2 章](docs/zh/02-ai-workflow.md) |
| 密钥 | 不进 Git、不进前端、不进日志、不进截图 | [第 5 章](docs/zh/05-security-repo-ci.md) |
| 代码 | 小单元、显式错误、别玩魔法、别留死代码 | [第 4 章](docs/zh/04-code-conventions.md) |
| CI | 测试 + 构建 + 自检；失败即停 | [第 5 章](docs/zh/05-security-repo-ci.md) |
| 监控 | `/health` + `/version` + 外部 uptime + 告警；崩溃自动重启 | [第 6 章](docs/zh/07-monitoring-and-recovery.md) |
| 清理 | 每周 `cleanup.sh`，7 天回收站，不动 Git 跟踪的文件 | [第 6 章](docs/zh/07-monitoring-and-recovery.md) |

---

## 阅读顺序

| 简体中文 | English |
|---|---|
| [00 · 为什么需要它](docs/zh/01-why.md) | [00 · Why this exists](docs/en/01-why.md) |
| [01 · 和 AI 一起工作](docs/zh/02-ai-workflow.md) | [01 · Working with AI](docs/en/02-ai-workflow.md) |
| [02 · Git、版本、发布](docs/zh/03-git-version-release.md) | [02 · Git, version, release](docs/en/03-git-version-release.md) |
| [03 · 代码约定](docs/zh/04-code-conventions.md) | [03 · Code conventions](docs/en/04-code-conventions.md) |
| [04 · 安全、仓库、CI](docs/zh/05-security-repo-ci.md) | [04 · Security, repo, CI](docs/en/05-security-repo-ci.md) |
| [05 · 落地](docs/zh/06-adoption.md) | [05 · Adoption](docs/en/06-adoption.md) |
| [06 · 监控、自动修复与清理](docs/zh/07-monitoring-and-recovery.md) | [06 · Monitoring, recovery, cleanup](docs/en/07-monitoring-and-recovery.md) |
| [踩坑清单（30 个模式）](pitfalls/zh.md) | [Pitfalls (30 patterns)](pitfalls/en.md) |

---

## 参与贡献

这是一份“活的基线”。最有价值的贡献：

1. **你真踩过的坑** —— 用 “Pitfall report” issue 模板。
2. **说不清/太严的规则** —— 用 “Rule proposal” 模板。
3. **翻译修正** —— 中英文必须表达同一件事。

提 PR 前请读 [`CONTRIBUTING.md`](CONTRIBUTING.md)。一个 PR 只改一条规则。
决策方式见 [`GOVERNANCE.md`](GOVERNANCE.md)；安全问题见 [`SECURITY.md`](SECURITY.md)。

---

## 许可证

- **代码、脚本、模板**：[MIT](LICENSE)
- **文档（README、`docs/`、`pitfalls/`）**：[CC BY 4.0](LICENSE-docs)

模板可以用于商业项目。代码不强制署名；如果转载文档，需要署名。

---

**从这里开始**：[为什么需要它](docs/zh/01-why.md) · [一页纸](CHEATSHEET.zh.md) · [English](README.md)
