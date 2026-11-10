# <PROJECT_NAME>

<One sentence: what it is, who it is for, what problem it solves.>

> **第一次用 / New to this?** 中文：`docs/standards/START_HERE.zh.md` · English: `docs/standards/START_HERE.md`
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

## Status and verification

- Capability status: `STATUS.md` (one table; README only links here).
- Verify summary: `bash scripts/verify.sh`
  (`typecheck` / `test` / `build` / `a11y`; skip is explicit).
- Human gates: Plan / Merge / Release / Next; use `docs/standards/templates/GATE.md`.
- Every task ends with one clickable `GATE: next` (one action + stop); no free-text "if you want" endings.

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
