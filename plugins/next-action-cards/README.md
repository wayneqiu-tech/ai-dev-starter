# Next Action Cards（DSH 插件）

把 AI Dev Standard 的 `GATE: next` 从文字规则变成真正的可点击卡片。

## 它做什么

- 注册 `next-action` Skill；
- 注册 `next_action` Action Card；
- 任务收尾时，模型调用 `propose_action`；
- 卡片显示一个主行动和一个 `停止`；
- 点击 URL 动作会直接打开链接；
- 点击后决定写回会话，模型在下一轮收到 `accepted` / `stopped` 回执。

## 安装

在 DSH 中把本目录作为 bundle 安装：

```text
plugin_manager install_bundle
target: <absolute-path-to-this-directory>
```

安装后：

```text
/next-action
```

应该出现在技能目录中。

> 本 bundle 会插入 `@deepseek-ai/dsh-action-cards` 和
> `@deepseek-ai/dsh-client-ui-action-cards`。如果已经安装
> `@deepseek-ai/dsh-personalized-recommendations`，不要同时启用两者的
> action-cards 行，否则会重复注册同一个服务。

## Profile 级 system prompt

安装插件后，Host 会向整个 DSH profile 注入一条 system prompt：

> 每个任务收尾必须使用 Next Action Gate；有 `next-action` 就用卡片，否则用
> `ask_user_question`；禁止“如果你愿意，我可以……”式收尾。

所以同一个 profile 下的所有工作区都会收到这条规则，不需要每个项目重复配置。

## 点击后会发生什么

1. 卡片立即显示“正在提交…”；
2. `act` 记录 `accepted` / `stopped`；
3. 接受时构造完整 `UserMessage`（`id` + `role: "user"` + `content` + `source`）并调用 `agent.followup()`；
4. AI 被唤醒，下一轮收到状态回执并继续执行。

只记录不唤醒会导致“已提交: settled 但 AI 没反应”；0.1.5 已修复。

## 什么时候用

- 任务完成，且下一步可以立刻执行时；
- 需要用户在“继续 / 停止”之间做一个明确选择时；
- 不要用它做“合并 + 发布 + 清理”三合一批准；
- 一个 turn 只允许一个卡片。

## GitHub Release 预填

卡片支持 `title` / `body` 字段。Client 识别 `github.com/.../releases/new`
链接后，会把它们编码进 URL：

```json
{
  "label": "打开 Release 页面",
  "url": "https://github.com/wayneqiu-tech/ai-dev-starter/releases/new?tag=v0.10.3",
  "title": "v0.10.3 - card wake fix",
  "body": "## 0.10.3 ..."
}
```

打开后标题/正文已预填，只需点 `Publish release`；同时正文会写入剪贴板作为兜底。

## 卡片字段

```json
{
  "action": "next_action",
  "title": "Open 0.10.0 Release page",
  "brief": "打开 GitHub Release 页面，继续发布。",
  "details": {
    "label": "打开 Release 页面",
    "url": "https://github.com/..."
  }
}
```

`url` 动作由浏览器直接打开；`command` 只作为文字透传，不会自动执行。

## 验证

1. `/next-action` 出现在技能目录；
2. 触发一次 `propose_action`；
3. 卡片显示标题、说明、主按钮和停止；
4. 点 URL 按钮应打开新标签；
5. 点停止后，下一轮收到 `phase: "stopped"` 回执。

## 当前限制

- 需要 DSH 的 `actionCards` 服务；不是纯 Markdown Skill 能提供的能力；
- 只验证了当前 DSH profile，尚需全新 profile 安装测试；
- 本插件是 0.10.1 的附加组件，不是核心规范的替代品。
