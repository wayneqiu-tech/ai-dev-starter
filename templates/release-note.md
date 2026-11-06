# <version, e.g. R20261106.01 or 1.4.2>

> Usage: copy to `docs/releases/<version>.md`; fill 1–4, 6, 8, 9 before release; fill 5, 7 after.
> Order: write this note → commit → build → tag → `preflight --release` → deploy. Do not move the tag afterwards.
> Standard: `docs/standards/03-git-version-release.md` §4.5. Missing fields = invalid.

## 1. Basics

| Item | Value |
|---|---|
| Version | `<version>` |
| Time | `<YYYY-MM-DD HH:MM +08:00>` |
| Type | `feature` / `fix` / `hotfix` / `docs` / `deploy` |
| Released by | `<name>` |
| Previous | `<version>` or "none (baseline)" |
| Environment | `local` / `staging` / `prod` |

## 2. Commit and tag

| Item | Value |
|---|---|
| Commit | `<sha>` |
| Tag | `<tag>` |
| Branch | `<branch>` |

## 3. Change summary

One sentence: **whose problem, changed to what.**

-

> Forbidden: "fixed several issues", "improved UX", "tested locally, looks fine".

## 4. Verification evidence

| Check | Result | Evidence |
|---|---|---|
| Unit tests | `<N passed / 0 failed>` | `<command/log path>` |
| Build | `<success>` | `<command/artifact path>` |
| Version reconciliation | `VERSION / tag / version.json / note` agree | `preflight` output |
| Health check | `<200>` | `<URL/screenshot>` |
| Core path | `<steps → result>` | `<screenshot/recording>` |
| Rollback drill (if any) | `<passed>` | `<record>` |

## 5. Build / deploy commands

```bash
# paste verbatim; must be runnable
<commands>
```

Duration: `<N seconds>`　Exit code: `<0>`

## 6. Rollback

| Item | Value |
|---|---|
| Target | `<last verified version>` |
| Command | `<one executable command>` |
| Artifact | `<where it is kept>` |
| Data impact | `<none / describe compatibility>` |

## 7. Risks and open issues

- <known issue, what to monitor>

## 8. Data / config changes

| Item | Value |
|---|---|
| Schema | `<none / version + migration file>` |
| Env vars | `<added/changed/removed>` |
| Dependencies | `<added/upgraded/removed>` |
| Migration steps | `<command + rollback compatibility>` |

## 9. Scope

- Modules: `<web / api / core / ...>`
- Entry points: `<home / login / admin / ...>`
- Users: `<all / some / internal>`

## 10. Incident record (only if one happened)

- Symptom:
- Impact:
- Timeline:
- Root cause:
- Response:
- Prevention (which gate/test/doc changed):
