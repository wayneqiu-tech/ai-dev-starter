# GitHub 上线工具包（v0.9.0 公测）

> 这是上线当天用的操作单，不是规范正文。
> 目标：**1 小时内把仓库发出去，并且知道接下来 30 天看什么。**

---

## 1. 仓库名与简介

**建议仓库名**：`ai-dev-standard`（备选：`ai-dev-baseline`、`ai-coding-baseline`）

**GitHub About（英文，≤160 字符）**：

```
A beginner-first engineering baseline for people building software with AI. Templates, Git/version/release rules, cleanup & monitoring. Public beta.
```

**GitHub About（中文，放 README 第一段即可）**：

```
给「用 AI 写代码的人」的小白优先工程基线：模板、Git/版本/发布规则、清理与监控。0.9 公测，不是正式标准。
```

**Topics**：

```
ai
ai-coding
coding-agents
engineering
git
semantic-versioning
conventional-commits
beginner
chinese
developer-tools
```

> 不要用 `standard`、`best-practices` 当唯一话题；会让人以为是正式标准。

---

## 2. 发布 v0.9.0

```bash
# 在标准仓库根目录
git init && git branch -M main
git add -A
git commit -m "docs: initial AI Dev Standard 0.9.0 public beta"
git tag -a v0.9.0 -m "release v0.9.0 (public beta)"
git remote add origin <你的仓库地址>
git push -u origin main --tags
```

**Release 标题**：

```
v0.9.0 — public beta: a beginner-first engineering baseline
```

**Release 正文**（直接复制，按需改）：

```markdown
This is the first public beta of AI Dev Standard.

It is **not a formal standard yet**. It is an opinionated engineering baseline:
7 bilingual guides, 30 pitfall patterns, templates, presets, a preflight
self-check, a safe cleanup script, a one-command project bootstrap, monitoring
guidance, and a runnable example.

Start here:
- 中文小白入口: START_HERE.zh.md
- 5-minute setup: README.md
- Pitfalls: pitfalls/en.md / pitfalls/zh.md

What we need from you:
- Try the 30-minute path and tell us where you got stuck.
- If you adopt it, open an issue and tell us what you changed.
- If a rule is wrong or too strict, propose a change.

Not a formal standard. No certification. See GOVERNANCE.md.
```

---

## 3. 置顶 issue（发布后第一件事）

**标题**：

```
v0.9 公测：你用这套基线时，卡在哪一步？
```

**正文**：

```markdown
这是 v0.9 公测的反馈帖。只回三件事，不用写长文：

1. **你是谁**：完全新手 / 独立开发者 / 小团队 / 只是看看
2. **你做了什么**：项目类型（Web / 脚本 / Agent / 其他），用了哪几步
3. **你卡在哪**：哪一步看不懂、哪条规则太麻烦、哪个脚本报错（贴输出）

不需要 star，不需要客气。卡住的地方就是我们要改的地方。

已知限制（不用重复报）：
- 脚本输出是英文
- Windows 需要 Git Bash
- 还没有正式 SPEC / 一致性测试
```

---

## 4. 上线当天 1 小时清单

| 时间 | 动作 | 完成标志 |
|---|---|---|
| 0–10 分钟 | 建仓库，推 `main` + `v0.9.0` tag | GitHub 上能看到 tag |
| 10–20 分钟 | 填 About、Topics、Release | 仓库首页能看懂“是什么/不是什么” |
| 20–30 分钟 | 发置顶反馈 issue | 链接能打开 |
| 30–40 分钟 | 用无痕窗口走一遍：clone → `init` → `preflight` → 示例 | 不依赖你的本机缓存 |
| 40–50 分钟 | 发 2 个地方（V2EX / 掘金 / X / 即刻，选两个） | 有 1 条真实评论或 issue |
| 50–60 分钟 | 记下 3 个卡点，写进 `docs/launch/feedback.md` | 明天有得改 |

**不要做**：不要群发、不要买 star、不要@所有人、不要承诺“保证你的项目成功”。

---

## 5. 公告文案（短，可直接改）

### 中文（V2EX / 掘金 / 即刻）

```
发一个给「用 AI 写代码的人」的小白优先工程基线（0.9 公测）。

不是又一个提示词合集，也不是正式标准。它解决的是：
- 版本混乱：一个 VERSION + tag + 发布单
- 发布靠手：门禁 → 构建 → tag → 自检 → 部署
- AI 改太多：任务单 + 自证 + 人 review
- 垃圾堆积：7 天回收站 + 每周自动清理
- 小白上手：三句话 + 12 张指令卡

一条命令生成项目骨架，自带 CI、钩子、基线发布单。

如果你只用过网页版 AI，也能看懂 START_HERE；如果你有 Cursor/Claude Code，AI 可以帮你开分支和提交，你只负责合并/发布。

求真实反馈：你在哪一步卡住？不要说“挺好”，说卡点。
<链接>
```

### English（X / Reddit / HN，简短）

```
I built a beginner-first engineering baseline for AI-assisted development (v0.9 public beta).

Not another prompt collection, and not a formal standard. It covers:
- one VERSION + tag + release note
- release gates, rollback, version self-report
- AI task cards + self-proof + human review
- 7-day trash + weekly cleanup
- a 3-sentence beginner path + 12 copy-paste prompts

One command scaffolds a project with CI, a commit hook, and a baseline release note.

Looking for real friction: where did you get stuck?
<link>
```

---

## 6. 30 天看什么（别看 star）

| 指标 | 目标 | 怎么记 |
|---|---|---|
| 小白完整走完 30 分钟路径 | ≥10 人 | 反馈 issue 里问“走到第几步” |
| 真实摩擦 issue | ≥5 个 | 标签 `friction` |
| 项目采用 | ≥3 个 | 标签 `adopter`，收链接/截图 |
| 外部 PR | ≥1 个 | 翻译/模板/脚本都算 |
| “名不副实/误导”投诉 | 0 | 有就改文案 |

达到 3/5 以上，再准备 `v1.0.0`；否则继续改小白路径。

---

## 7. 上线后两周做什么

1. 每天花 15 分钟回 issue，只问“你卡在哪”，不辩解。
2. 把重复出现的卡点合并成一个 issue，标 `friction`。
3. 每周发一次 `v0.9.x` 小版本，只修卡点，不加新章节。
4. 第 14 天写一份 `docs/launch/feedback.md`：
   - 谁用了
   - 卡在哪
   - 改了什么
   - 还没改什么
5. 第 30 天决定：够 1.0 条件就发 `v1.0.0`；不够就继续 `0.x`。

---

## 8. 一句话

**上线不是“发布一个标准”，是“开始收集真实卡点”。**
v0.9 的任务不是完美，是让 10 个小白走一遍，然后活着回来告诉你哪里疼。
