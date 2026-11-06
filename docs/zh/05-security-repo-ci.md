# 04 · 安全、仓库、CI

> 这一章管三件事：**密钥别泄露、仓库别变垃圾场、检查别靠人记得**。

## 1. 密钥：不进仓库，是底线

### 1.1 什么算密钥

- API Key、访问令牌、OAuth secret
- 数据库密码、JWT 签名密钥
- SSH 私钥、证书私钥
- 云厂商凭证（AK/SK）
- 支付、短信、邮件、微信等第三方 secret
- 任何“拿到就能冒充你/花你钱”的字符串

### 1.2 规则

| 规则 | 说明 |
|---|---|
| 不进 Git | 包括 `.env`、`*.pem`、`*.key`、`id_rsa`、CI secrets |
| 不进前端 | 前端只有公开配置；密钥只放服务端 |
| 不进日志 | 日志/报错/截图里出现密钥，按泄露处理 |
| 不进示例 | `.env.example` 只放 `<change-me>` |
| 最小权限 | 每个服务一个 key；只给需要的权限 |
| 可轮换 | 换密钥不需要改代码 |
| 分环境 | 本地/测试/生产用不同 key；本地 key 设额度 |
| 定期轮换 | 至少每 6 个月；怀疑泄露立即换 |

### 1.3 仓库里只放模板

```env
# .env.example
DATABASE_URL=postgres://user:<change-me>@localhost:5432/app
API_KEY=<change-me>
APP_ENV=local
```

`.gitignore` 第一行就写：

```gitignore
.env
.env.*
!.env.example
*.pem
*.key
```

### 1.4 已经泄露了怎么办（30 分钟流程）

**顺序不能反：先轮换，再清理。**

1. **轮换/吊销密钥**。只删文件不轮换 = 没处理，历史里还在。
2. 查访问日志：有没有被使用？影响了什么？
3. 清理仓库历史：`git filter-repo` 或 BFG；通知协作者重新 clone。
4. 补 CI 密钥扫描，补一条事故记录。
5. 如果涉及用户数据，按法规/平台规则通知。

> 密钥进过 Git 历史，就当作已经泄露。不要心存侥幸。

## 2. 仓库卫生：别把仓库当网盘

### 2.1 永不入库

```
node_modules/   dist/   build/   target/   out/   coverage/
.env   .env.*   *.pem   *.key   id_rsa*
*.log   logs/   *.sqlite   *.db
*.zip   *.tar.gz   *.dmg   *.exe   *.apk
test-results/   playwright-report/   .vite/   .cache/
.DS_Store   Thumbs.db
```

已经提交过的：

```bash
git rm -r --cached <path>
# 补 .gitignore，再提交
```

密钥类还要**轮换**（见 §1.4）。

### 2.2 大文件与二进制

- 单文件 >5 MB：PR 里说明理由。
- 单文件 >20 MB：用 Git LFS 或 Release 附件。
- 图片：压缩后放 `docs/assets/`，命名 `<日期>-<主题>.png`，一图一用。
- 录屏/视频：外链或 Release，不进仓库。
- 每月看一次“仓库里最大的 10 个文件”：

```bash
git ls-files -z | xargs -0 du -h | sort -rh | head -10
```

### 2.3 根目录白名单

```
src/  tests/  docs/  scripts/  config/  public/  .github/  .git/
README.md  AGENTS.md  VERSION  CHANGELOG.md  LICENSE  .gitignore  package.json
```

新加一个根目录，先问：**为什么不能放进已有目录？**

反例：`new/`、`final/`、`backup/`、`v2/`、`20261106/`、`新建文件夹/`。

### 2.4 归档与删除

- 历史版本用 tag，不用 `archive/` 文件夹。
- 确需归档：`archive/<日期>-<原因>/`，里面必须有：
  - `README.md`：为什么、谁负责、到期日
  - 清单：文件 + sha256
  - 到期处理方式
- 默认保留 30 天，到期必须处理，不允许无限续期。
- 删除前：确认无引用、有 tag/备份、不是生产正在用的。
- 破坏性脚本：默认 dry-run；执行要 `--yes` + 打印影响清单 + 先备份。

### 2.5 README 最低标准

一个陌生人（或 AI）只看 README 就能：

1. 知道这是什么、给谁用。
2. 知道怎么装、怎么跑（3 条命令以内）。
3. 知道怎么配（指向 `.env.example`）。
4. 知道怎么发版（指向规范/脚本）。
5. 知道去哪看文档（文档表）。
6. 知道许可证。

## 3. CI：能自动检查的，别靠自觉

### 3.1 最小门禁集

| # | 检查 | 必须 | 说明 |
|---|---|---|---|
| 1 | 安装依赖（lockfile） | ✅ | `npm ci` / `pip install -r` |
| 2 | Lint / 格式 | 建议 | 没有就跳过，别花一周配 |
| 3 | 单元测试 | ✅ | 没有测试就先加 3 个核心用例 |
| 4 | 构建 | ✅ | 构建不过，一切免谈 |
| 5 | 规范自检（`preflight --ci`） | ✅ | 版本、tag、发布单、大文件、密钥 |
| 6 | 密钥扫描 | ✅ | 防泄露 |
| 7 | 冒烟（启动 + 健康检查） | 建议 | 有服务端就跑 |
| 8 | 依赖漏洞扫描 | 建议 | 每月看一次，不必卡每次提交 |

### 3.2 GitHub Actions 示例

```yaml
name: ci
on:
  push:
    branches: [main]
  pull_request:

jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0        # preflight 需要 tag 历史
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: npm
      - run: npm ci
      - run: npm run lint --if-present
      - run: npm test --if-present
      - run: npm run build --if-present
      - name: Standard self-check
        run: bash docs/standards/scripts/preflight.sh --ci
```

不是 GitHub 也一样：GitLab CI、Gitee Go、本地 `pre-commit` 都能跑同一套命令。关键是**本地和 CI 跑同一条命令**。

### 3.3 失败处理

- 红了先修，不许“用上次绿的记录”发版。
- flaky 测试：隔离并限时修（≤1 周），不许长期 `skip`。
- CI 挂了但确认是环境问题：在发布单写明原因 + 人工补跑等价命令。
- 门禁规则放宽必须走 PR + 记录理由。

### 3.4 分支保护（建议开启）

- `main` 禁止直接 push、禁止 force push。
- 合并前必须 CI 通过。
- 至少 1 个 approval（单人项目可用“PR + 自检清单”替代）。
- 合并后自动删分支。

## 4. 依赖与供应链

- 锁文件入库；CI 用 `npm ci` / `pip install -r`，不用“最新版”。
- 新增依赖：看许可证、体积、维护状态、是否有已知漏洞。
- 升级依赖单独提交，写清“为什么升、影响了什么”。
- 高危漏洞限期修；不能修的，写进发布单“风险与遗留”。
- 不引入来源不明的包/脚本；安装脚本要看一眼。

## 5. 服务器与权限

- 部署用**专用账号 + SSH key**；禁止 root 日常登录、禁止密码登录。
- 首次连接手工确认主机指纹；之后不允许 `StrictHostKeyChecking=no`。
- 生产端口只监听 `127.0.0.1`，对外统一走反向代理/网关。
- 数据库不对公网开放；只允许应用所在网络访问。
- 防火墙默认拒绝，按需开放。
- 所有生产变更走同一条流水线，保留日志；手工变更视为事故。

## 6. 备份与恢复

- 有状态的系统（数据库、上传目录）发布前必须备份。
- 备份要能恢复：每月在临时目录恢复一次，确认能启动。
- 备份文件带时间戳 + 版本号 + sha256。
- 明确 RPO/RTO：能接受丢多少数据、多久恢复。
- 备份保留策略：至少 14 天，重要版本单独归档。

## 7. 一页纸检查清单

### 提交前

- [ ] 没有 `.env` / 密钥 / 大文件
- [ ] `git ls-files | grep -E '\.env$|\.pem$|\.key$'` 为空
- [ ] 新配置进了 `.env.example`

### 发布前

- [ ] 密钥/配置清单齐全
- [ ] 备份完成，恢复演练过
- [ ] 回滚命令可用
- [ ] 生产只接受仓库构建的产物

### 每月

- [ ] 仓库大文件 Top 10
- [ ] 依赖漏洞
- [ ] 密钥轮换到期
- [ ] 备份恢复演练

---

**下一章**：[05 · 落地 →](06-adoption.md)
