# AI Dev Standard · 一页纸

> 打印出来，或者钉在编辑器旁边。版本 0.9.3（公测） · [English](CHEATSHEET.md) · [完整基线](README.zh.md)
>
> **第一次用？** 先看 [START_HERE.zh.md](START_HERE.zh.md) —— 你只需要会说三句话。

## 1. 每天开工（30 秒）

- [ ] `git status`：干净，或者我知道哪些文件在改
- [ ] `git pull`：我在最新的 `main` 上
- [ ] 我知道今天做哪件事、什么算“做完”

## 2. 分支（一件事，一个分支）

| 类型 | 用途 | 最长寿命 |
|---|---|---|
| `feat/<slug>` | 新功能 | 7 天 |
| `fix/<slug>` | 修 bug | 3 天 |
| `docs/`、`chore/`、`refactor/`、`test/` | 小改动 | 3–7 天 |
| `hotfix/<版本>-<slug>` | 线上紧急修复 | 1 天 |

规则：英文小写 slug；从 `main` 切；合回 `main`；合并后删除。

## 3. 提交（一次一件事）

```
<type>(<scope>): <subject>

为什么改？改前什么问题？做了什么取舍？
```

类型：`feat` `fix` `docs` `refactor` `perf` `test` `build` `ci` `chore` `revert`

- 标题 ≤ 50 字，句末不加句号。
- 正文写**为什么**，不要罗列文件。
- AI 参与：加 `Co-authored-by: <工具名>`。
- 一句话说不清，就拆。

## 4. 版本（一个真源）

```
VERSION  =  R20261106.01        （默认，日期号）
tag      =  R20261106.01        （annotated）
产物     =  app-R20261106.01.tar.gz + version.json
发布单   =  docs/releases/R20261106.01.md
```

- 号永不复用；不要 `latest` / `final` / `v2-copy`。
- 回滚**不产生新号**，指回一个验证过的版本。
- 库/CLI/上架应用可用 SemVer（`1.4.2`，tag `v1.4.2`）。

## 5. 发布（门禁 → 构建 → tag → 自检 → 部署 → 验证 → 发布单）

- [ ] 工作区干净、在 `main`、已同步
- [ ] 测试 + 构建通过（CI 绿）
- [ ] `VERSION` 已更新；发布单已写
- [ ] `git tag -a "$(cat VERSION)"`
- [ ] `bash docs/standards/scripts/preflight.sh --release`
- [ ] 有状态系统先备份；回滚命令已就绪
- [ ] 部署后 `/health`、`/version` 与 `VERSION` 一致
- [ ] 观察 30 分钟；把实际结果补进发布单

**验证失败：立即停，不要清理，先回滚。**

## 6. AI 任务（六步循环）

1. **读**：`AGENTS.md` + 相关文件。
2. **计划**：3 步以内，改哪些文件、怎么验证。
3. **小步改**：一次一件事；超过 400 行先拆。
4. **验证**：跑测试/构建；没输出就不要说“通过”。
5. **自证**：改了哪些文件 / 为什么 / 命令和输出 / 没做什么。
6. **人 review**：范围、硬编码、密钥、被删的测试、回滚方式。

### AI 绝对不许

> AI **可以**开任务分支并在分支上提交（前提：`AGENTS.md` 授权）。合并/push/发布前必须停。

- 未经你同意，合并到 `main`、push、打 tag、部署生产、删数据、改 DNS
- 为了让测试通过而改断言、跳过测试、删日志
- 硬编码密钥、真实 IP、绝对路径
- 从其他项目/旧版本目录复制代码
- 未经确认新增依赖

## 7. 永远不要

- 提交 `.env`、密钥、`node_modules`、`dist`、安装包、截图
- 对 `main` 强推
- 手工改生产
- 用“我本机能跑”当验证
- 删除版本或复用版本号

## 8. 常用命令

```bash
cat VERSION
bash docs/standards/scripts/preflight.sh --release
git tag -a "$(cat VERSION)" -m "release $(cat VERSION)"
git push origin main "$(cat VERSION)"
git worktree add "../look/$(cat VERSION)" "$(cat VERSION)"   # 看历史版本
git ls-files | grep -E '\.env$|\.pem$|\.key$|id_rsa'         # 查密钥
git ls-files -z | xargs -0 du -h | sort -rh | head -10       # 查大文件
bash docs/standards/scripts/cleanup.sh                                      # 垃圾清理（dry-run）
bash docs/standards/scripts/cleanup.sh --schedule                           # 每周清理的 cron 行
```

## 9. 五个循环（为什么有这套规范）

1. 复制文件夹 → 两个真相 → 再复制。
2. 只改一处配置 → 不一致 → 手工改服务器。
3. 跳过测试 → 线上事故 → 回滚只有一层。
4. 文档和脚本各说各话 → AI 按错的做。
5. “来都来了”顺手改 → 无法单独回滚。

**打断循环，而不是只压症状。**
