# <PROJECT_NAME>

<One sentence: what it is, who it is for, what problem it solves.>

> **第一次用 / New to this?** 中文小白入口：`docs/standards/START_HERE.zh.md` —— 你只需要会说三句话。
>
> **DSH:** `/ai-dev-standard 检查当前项目`

## Quick start

```bash
# install
<command>

# develop
<command>

# test
<command>

# build
<command>
```

## Before release

```bash
bash docs/standards/scripts/preflight.sh --release
bash scripts/check-release-sync.sh
```

The first checks the local repo; the second checks that HEAD is pushed, the
ledger matches the live `/version`, and HEAD is tagged.

## Configuration

Copy `.env.example` to `.env` (or use environment variables) and fill in the
values. Never commit real secrets.

## Docs

| Doc | Purpose |
|---|---|
| `AGENTS.md` | rules for AI assistants |
| `docs/standards/` | engineering standard |
| `docs/releases/` | release notes |
| `CONTRIBUTING.md` | how to contribute (add one if missing) |

## Release

1. Update `VERSION`.
2. Write `docs/releases/<version>.md`.
3. Build, tag, and run:

   ```bash
   bash docs/standards/scripts/preflight.sh --release
   ```

## License

<add your license here; the copied handbook license covers the handbook only>
