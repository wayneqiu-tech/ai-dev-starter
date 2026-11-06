# AI Dev Standard — Cheatsheet

> One page. Print it or pin it. Version 0.9.0 (public beta) · [中文](CHEATSHEET.zh.md) · [Full baseline](README.md)

## 1. Daily (30 seconds)

- [ ] `git status` — clean, or I know what is dirty
- [ ] `git pull` — I am on latest `main`
- [ ] I know which task I am doing, and what "done" means

## 2. Branch (one task, one branch)

| Type | Use for | Max age |
|---|---|---|
| `feat/<slug>` | new feature | 7 days |
| `fix/<slug>` | bug fix | 3 days |
| `docs/`, `chore/`, `refactor/`, `test/` | small changes | 3–7 days |
| `hotfix/<version>-<slug>` | production emergency | 1 day |

Rules: lowercase English slug; branch from `main`; merge back to `main`; delete after merge.

## 3. Commit (one thing)

```
<type>(<scope>): <subject>

Why this change? What was broken? What trade-off did you make?
```

Types: `feat` `fix` `docs` `refactor` `perf` `test` `build` `ci` `chore` `revert`

- Subject ≤ 50 chars, no period.
- Body explains **why**, not which files.
- AI-assisted? Add `Co-authored-by: <tool>`.
- If you cannot summarize it in one sentence, split it.

## 4. Version (one source)

```
VERSION  =  R20261106.01        (default, dated)
tag      =  R20261106.01        (annotated)
artifact =  app-R20261106.01.tar.gz + version.json
note     =  docs/releases/R20261106.01.md
```

- Never reuse a version. Never use `latest` / `final` / `v2-copy`.
- Rollback does **not** create a new version; it points back to a verified one.
- SemVer (`1.4.2`, tag `v1.4.2`) is the option for libraries/CLI/app-store apps.

## 5. Release (gate → build → tag → check → deploy → verify → note)

- [ ] clean tree, on `main`, up to date
- [ ] tests + build pass (CI green)
- [ ] `VERSION` updated; release note written
- [ ] `git tag -a "$(cat VERSION)"`
- [ ] `bash docs/standards/scripts/preflight.sh --release`
- [ ] backup (if stateful) + rollback command ready
- [ ] deploy, then `/health` and `/version` match `VERSION`
- [ ] observe 30 minutes; write actual results into the note

**If verification fails: stop. Do not run cleanup. Roll back first.**

## 6. AI task (the 6-step loop)

1. **Read** `AGENTS.md` + the files involved.
2. **Plan** in 3 steps: what files, how to verify.
3. **Change small**: one concern per commit; >400 lines → split.
4. **Verify**: run tests/build; do not claim without output.
5. **Self-prove**: files changed / why / commands + output / what you did not do.
6. **Human review**: scope, hardcoding, secrets, deleted tests, rollback.

### AI must never

> AI **may** create a task branch and commit on it (if `AGENTS.md` allows). It must stop before merge/push/release.

- merge into `main`, push, tag, deploy production, delete data, change DNS without your approval
- edit tests to make them pass, skip tests, remove logs
- hardcode secrets, real IPs, absolute paths
- copy code from another project/version folder
- add dependencies without asking

## 7. Never

- Commit `.env`, keys, `node_modules`, `dist`, installers, screenshots
- Force-push `main`
- Change production by hand
- "It works on my machine" as verification
- Delete a version or reuse a number

## 8. Commands

```bash
cat VERSION
bash docs/standards/scripts/preflight.sh --release
git tag -a "$(cat VERSION)" -m "release $(cat VERSION)"
git push origin main "$(cat VERSION)"
git worktree add "../look/$(cat VERSION)" "$(cat VERSION)"   # inspect old version
git ls-files | grep -E '\.env$|\.pem$|\.key$|id_rsa'         # secret check
git ls-files -z | xargs -0 du -h | sort -rh | head -10       # big files
bash docs/standards/scripts/cleanup.sh                                      # dry-run junk
bash docs/standards/scripts/cleanup.sh --schedule                           # weekly cleanup line
```

## 9. The five loops (why this exists)

1. Copy folder → two truths → copy again.
2. Change one config → mismatch → hand-edit server.
3. Skip tests → incident → one-level rollback.
4. Docs vs scripts → AI follows the wrong one.
5. "While I'm here" → cannot roll back one change.

**Break the loop, not just the symptom.**
