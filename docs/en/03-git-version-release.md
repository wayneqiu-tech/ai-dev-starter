# 02 · Git, version, release

> This chapter answers three questions: **how to isolate changes, how to define a version, and how to roll back a release.**
> Commands use the default dated scheme; swap the version format if you use SemVer.

## 1. Branches: trunk + short-lived branches

### 1.1 Default model

Only `main` lives forever. Everything else is short-lived and deleted after merge.

```
main ──●────●────●────●────●──→  always releasable
        \        /    \      /
         feat/x  ●      fix/y ●      ≤7 days, delete after merge
```

| Branch | From | Max age | Purpose | Merge into | Merge style |
|---|---|---|---|---|---|
| `main` | — | forever | always releasable | — | — |
| `feat/<slug>` | `main` | ≤7 days | new feature | `main` | Squash |
| `fix/<slug>` | `main` | ≤3 days | bug fix | `main` | Squash |
| `docs/<slug>` | `main` | ≤3 days | docs | `main` | Squash |
| `chore/<slug>` | `main` | ≤3 days | deps/config/chores | `main` | Squash |
| `refactor/<slug>` | `main` | ≤7 days | refactor, no behavior change | `main` | Squash |
| `test/<slug>` | `main` | ≤3 days | tests only | `main` | Squash |
| `release/<version>` | `main` | ≤3 days | freeze/acceptance (optional) | `main` + tag | Merge |
| `hotfix/<version>-<slug>` | the **tag** that broke | ≤1 day | production emergency | `main` + new tag | Merge |
| `wip/<date>-<slug>` | `main` | ≤7 days | parked work, never merged | promote or delete | — |

> **Why branch even when solo:** a branch isolates unfinished work. If you break `feat/`, `main` is still shippable.

### 1.2 Naming

```
<type>/<lowercase-english-slug>
```

- Slug: lowercase letters, digits, hyphens: `feat/voice-fallback`, `fix/login-500`.
- 2–40 chars. No Chinese, spaces, underscores, or date prefixes (dates only in `wip/`).
- One branch, one concern. The branch name is the title of that concern.

Regex (for CI/hooks):

```regex
^(main|(feat|fix|docs|chore|refactor|test|perf|build|ci)/[a-z0-9][a-z0-9.-]{1,39}|release/R20[0-9]{6}\.[0-9]{2}|hotfix/R20[0-9]{6}\.[0-9]{2}-[a-z0-9-]{2,30}|wip/[0-9]{8}-[a-z0-9-]{2,30})$
```

### 1.3 Lifecycle

1. **Cut:** `git switch main && git pull && git switch -c feat/xxx`
2. **Work:** small commits (§2), run tests after each chunk.
3. **Sync:** `git fetch && git rebase origin/main` daily (only your own branch).
4. **Check:** `preflight` + tests + build pass.
5. **Merge:** open a PR (even if you merge it yourself) with why / verified / rollback.
6. **Delete:** delete the branch after merge (local and remote).
7. **Expire:** a branch older than 7 days must be split and merged, or moved to `wip/` with a reason.

### 1.4 How to review when you are alone

No reviewer? Replace the person with a process:

1. **Overnight review:** read the diff the next morning. You will catch most low-level issues.
2. **AI second pass:** ask another AI session to review the diff and answer only: what changed? out of scope? security issues?
3. **Forced questions** (put them in the PR description):
   - Can I explain this change in one sentence?
   - If I roll it back, what else goes with it?
   - Any hardcoding, secrets, debug code?
   - Did I actually run tests/build? Where is the output?
4. **Diff threshold:** >400 lines or >20 files → split.

### 1.5 Special operations

| Operation | Do | Don't |
|---|---|---|
| Inspect an old version | `git worktree add ../look/<tag> <tag>` | `checkout <tag>` in the main worktree and commit there |
| Park work | `git stash push -m "reason"`, handle within 24h | anonymous stash, never cleaned |
| Sync main | `git rebase origin/main` on your branch | rebase someone else's branch on `main` |
| Undo a pushed commit | `git revert <sha>` (new commit) | `git reset --hard` + `push -f` on a shared branch |
| Edit an unpushed message | `git commit --amend` | rewrite a pushed commit others use |

### 1.6 Optional: when to use a `release/` branch

Only three cases:

1. Freeze 1–3 days for acceptance while `main` keeps moving.
2. Maintain two versions at once (v1 fixes, v2 development).
3. An app store or client requires "no changes after submission".

Otherwise, don't. A `release/` branch allows bug fixes only, no features. Merge back to `main` and delete within 24 hours after release.

### 1.7 Branch anti-patterns

- ❌ Long-lived `develop`, `develop2`, `dev-new`, `test`, `backup` (unless the team explicitly uses Git Flow).
- ❌ Branch names as backups: `main-20261106`, `before-refactor`.
- ❌ Committing directly on `main` (even solo).
- ❌ `push --force` to `main` or someone else's branch.
- ❌ One branch with multiple unrelated features.

## 2. Commit: one thing at a time

### 2.1 Test

**You can explain it in one sentence, and rolling it back does not take anything else with it.**

- ✅ `fix(login): keep email when login fails`
- ❌ `fix: some fixes` (unclear)
- ❌ `feat: new home + upgrade deps + change port` (three things)

Split large changes: **refactor (no behavior change) → feature → docs**. Then a failure can be rolled back one step at a time.

### 2.2 Format

```
<type>(<scope>): <subject>

<body: why, what was broken, trade-offs>

<footer: Refs #12 / BREAKING CHANGE: ... / Co-authored-by: ...>
```

| Part | Rule |
|---|---|
| `type` | required, see table |
| `scope` | optional module: `login`, `api`, `docs`, `deploy` |
| `subject` | required, ≤50 chars, imperative, no trailing period |
| `body` | recommended; explain **why**, not which files (the diff shows that) |
| `footer` | issue refs, breaking changes, AI co-author |

### 2.3 Types

| Type | Use for | Example |
|---|---|---|
| `feat` | new feature | `feat(voice): support low-confidence retry` |
| `fix` | bug fix | `fix(api): release connection on timeout` |
| `docs` | docs only | `docs: add rollback steps` |
| `refactor` | no behavior change | `refactor(core): split hint ladder` |
| `perf` | performance | `perf(web): remove one request from first paint` |
| `test` | tests only | `test(core): add boundary cases` |
| `build` | build/deps | `build: upgrade vite to 5.4` |
| `ci` | CI config | `ci: add secret scan` |
| `chore` | chores (no artifact change) | `chore: remove temp script` |
| `revert` | revert a commit | `revert: revert feat(voice) ...` |

> `feat` / `fix` go into CHANGELOG; `chore` / `ci` / `test` usually do not.

### 2.4 Good and bad examples

**Good:**

```
fix(deploy): stop cleanup when verification fails

Verification failures used to print a warning and continue, so the cleanup
step could delete the previous artifact needed for rollback. Now it exits
non-zero and cleanup runs only after verification passes.

Refs #42
```

**Bad:**

```
update
```

```
fixed bugs, improved code, updated config
```

```
changed many files
```

### 2.5 Commits for AI-generated code

1. **A human must understand every line** before committing. If you can't, ask the AI to explain; if the explanation is unclear, don't merge.
2. When `AGENTS.md` allows it, AI may run `git switch -c`, `git add`, and `git commit` **on a task branch**. It must not merge into `main`, push, tag, or deploy without explicit approval — and never commit directly on `main`.
3. Disclose AI involvement in the footer:

   ```
   Co-authored-by: <tool name> <noreply@example.com>
   ```

4. If AI generates >400 lines, split before committing.
5. AI must never edit assertions, skip tests, or delete logs to make checks pass. If it does, revert it.

### 2.6 Commit template and hook (optional)

```bash
# use the template
git config commit.template docs/standards/templates/commit-message.txt

# message format check (.git/hooks/commit-msg)
#!/usr/bin/env bash
msg_file="$1"
head -1 "$msg_file" | grep -qE '^(feat|fix|docs|refactor|perf|test|build|ci|chore|revert)(\([a-z0-9-]+\))?: .{2,50}$' \
  || { echo "Bad commit message. See docs/standards/03-git-version-release.md"; exit 1; }
```

### 2.7 FAQ

- **Are WIP commits okay?** Yes, only on your branch. Squash before merging.
- **Keep merge commits?** Not for solo work; keep them for `release/` and `hotfix/`.
- **How big is a commit?** As big as one independently revertible change, usually <300 lines. >400 → split.
- **Chinese or English?** Whatever the team uses. For open source, English subject, body in either language.

## 3. Version: one source

### 3.1 Choose a scheme

#### Option A: dated `R<YYYYMMDD>.<NN>` (default)

```
R20261106.01
R20261106.02     ← second release that day
R20261107.01     ← next day starts at .01 again
```

| Part | Rule |
|---|---|
| `R` | uppercase, no `v` |
| `YYYYMMDD` | the **release date** in the project timezone (default Asia/Shanghai) |
| `.NN` | the Nth release that day, two digits, starting at `01` |

**Best for:** web apps, SaaS, AI agents, internal tools, frequent delivery.
**Pros:** you instantly know the day and sequence; no "is this minor or patch?" debate.
**Cons:** cannot express breaking changes; library consumers cannot infer compatibility.

#### Option B: SemVer `MAJOR.MINOR.PATCH`

```
1.4.2
├─ MAJOR: breaking change
├─ MINOR: backward-compatible feature
└─ PATCH: backward-compatible fix
```

Tags are `v1.4.2`; prereleases are `v1.5.0-rc.1` (never production).

**Best for:** npm packages, SDKs, CLIs, plugins, app-store apps.
**Cons:** less obvious "which release is live this week" under continuous deployment.

#### Decision table

| Your project | Choose |
|---|---|
| Web / SaaS / AI app, continuous deploy | **A (dated)** |
| Open-source library, SDK, CLI, others depend on you | **B (SemVer)** |
| Desktop/mobile app in a store | **B + build number** |
| Client acceptance/delivery project | **A** (matches delivery dates) |
| Docs/content site | A or date, either |

> Do not mix schemes. One release-number scheme per project.

### 3.2 Single source and artifact self-report

**Single source:** a one-line `VERSION` file at the repo root.

```
R20261106.02
```

> `package.json` / `pyproject.toml` versions may remain (toolchains need them), but they are **not** the delivery-version source. Sync from `VERSION` at build time, or state clearly "VERSION wins". Do not edit both independently.

**Inject at build time; never hand-write:**

```bash
# first lines of the build script (dated example)
VERSION="$(cat VERSION)"
case "$VERSION" in
  R[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9].[0-9][0-9]) ;;
  *) echo "Bad VERSION: $VERSION" >&2; exit 1 ;;
esac
export APP_VERSION="$VERSION"
```

For SemVer, replace the check with `^[0-9]+\.[0-9]+\.[0-9]+`.

Every artifact must include a `version.json`:

```json
{
  "version": "R20261106.02",
  "git_sha": "a77748d2",
  "built_at": "2026-11-06T18:00:00+08:00",
  "modules": { "web": "R20261106.02-web" },
  "schema": { "data": 3 }
}
```

**Put the version in artifact names:**

```
dist/app-R20261106.02.tar.gz
MyApp-R20261106.02-mac.dmg
api-R20261106.02.jar
```

> Anti-pattern: `api-1.0.0.jar` never changes; `system.prev` is the only rollback. You cannot answer "which version is live?".

### 3.3 Git tags

- Use **annotated tags** (`git tag -a`), not lightweight tags.
- Tag name = `VERSION` (SemVer may add a `v` prefix; be consistent).
- Tag the **commit that produced the artifact**.
- Push: `git push origin <tag>`.
- Never move a pushed tag; release a new version.

```bash
V="$(cat VERSION)"
git tag -a "$V" -m "release $V
commit: $(git rev-parse --short HEAD)
notes: docs/releases/$V.md"
git push origin "$V"
```

### 3.4 Module versions (optional)

For a monorepo with `web` / `core` / `api`:

```
<release>-<module>        e.g. R20261106.02-web
```

- Changed modules get the new release; unchanged modules **inherit** their old version.
- Record in `config/module-versions.json`; builds read it.
- Small/single-module projects: **turn it off**.

### 3.5 Data schema and config versions

- Data structures (DB tables, local storage, file formats) get their own version: `schema.data = 3`.
- Forward-only: new code must read old data; old code must not crash on new data.
- Destructive changes in two steps: add new field (dual-write/compatible) → verify → remove old field.
- Config structure changes get a `config_version` and a release-note entry.

### 3.6 Where the version belongs

| ✅ Belongs | ❌ Does not belong |
|---|---|
| `VERSION` file | Directory names (`/opt/app-R20261106/`) |
| Git tag | Script names (`deploy-R20261106.sh`) |
| Release-note filename | Env var names (`R20261106_PORT`) |
| Artifact filename | Port numbers |
| `version.json` / `/version` | Long-lived branch names |
| Deploy manifest | Database table names |
| Download page | User-visible URL paths |

**Version blacklist** (never in tags, directories, filenames, notes):

```
latest  stable  final  new  v2  copy  final-final  fixed
1.0.0 as a delivery version (in dated mode)  R2026-11-06  R20261106-1
R20261106.01-fix  R20261106.01-hotfix  R20261106.01-rollback
```

### 3.7 Reconciliation equations (all must pass before release)

| # | Equation | How to check |
|---|---|---|
| E1 | `VERSION` exists and matches the format | `preflight` |
| E2 | tag exists, is annotated, points to the release commit | `git cat-file -t <tag>` |
| E3 | artifact `version.json.version` == `VERSION` | read the artifact |
| E4 | release-note filename == `VERSION` | `test -f docs/releases/<V>.md` |
| E5 | live `manifest.version` == artifact version; hashes match | verify after deploy |
| E6 | clean tree, `main` pushed | `git status --short` |

### 3.8 Version discipline

| Case | Rule |
|---|---|
| A number was used | Never reuse it, even if the release failed halfway |
| Multiple releases per day | `.01 .02 .03`, never `-hotfix` |
| Rollback | **No new number**; point back to an old version that still exists |
| Fix | New number; never overwrite the old one |
| Skipping numbers | Allowed; if it is not recorded, it did not happen |
| Prerelease | `-rc.1` (SemVer) or branch-only (dated); never production |
| Docs-only change | Prefer a new number (`docs`); configurable |
| Config-only change | New number + name the variable in the release note |

## 4. Release: be able to go back before going live

### 4.1 Cadence

| Cadence | Best for | Version | Notes |
|---|---|---|---|
| **Continuous** (default) | web/SaaS/AI apps, solo | a number per merge if needed | small, fast, easy rollback |
| **Milestone** | external acceptance/app stores/teams | one number per 1–2 weeks | freeze period, longer checklist |

Continuous does not mean "deploy every commit". Merge five times a day if you like, release when convenient; **every release still goes through §4.2–§4.4**.

### 4.2 Pre-release gates (all required)

| # | Check | Command/evidence | If it fails |
|---|---|---|---|
| 1 | Clean tree | `git status --short` empty | commit or stash; don't ship half-done work |
| 2 | On `main`, up to date | `git pull --ff-only` | sync, rerun |
| 3 | CI green | latest pipeline passed | fix it; "it was green last time" is not a gate |
| 4 | Tests pass | `npm test` / `pytest` / equivalent | fix; no skipping |
| 5 | Build passes | `npm run build` | fix |
| 6 | Version reconciliation E1–E4 | `preflight --release` | add `VERSION`/tag/release note |
| 7 | Release note draft | `docs/releases/<V>.md` | write what/verified/rollback |
| 8 | Rollback plan | target version + one command + data impact | no plan, no release |
| 9 | Backup (stateful systems) | DB/upload snapshot + verification | back up first |
| 10 | Production config complete | required env vars list | one missing = no release |

> Run gates in two phases: 1–5 and 7–10 before building; item 6 (including the tag) after building and tagging. Any FAIL stops the release. No "ship first, fix later".

> **No tests?** At minimum you need a smoke script: build + start + health check + one core path. "I clicked it manually" is not a gate.

### 4.3 Release steps

> Order matters: **write and commit the release note → build → tag → preflight → deploy**. Then the tagged commit both builds the artifact and contains the record.

```bash
# 0) on main, clean, up to date
git switch main
git status --short          # must be empty
git pull --ff-only

# 1) write the release-note draft (fill 1–4, 6, 8, 9; 5 and 7 after deploy)
#    file: docs/releases/$(cat VERSION).md

# 2) commit the note (so the tag points to a commit that builds and records)
git add "docs/releases/$(cat VERSION).md"
git commit -m "docs(release): $(cat VERSION)"

# 3) build (read VERSION, inject version.json)
npm run build
test -f dist/version.json || { echo "missing version.json"; exit 1; }

# 4) package (version in the filename)
tar -czf "dist/app-$(cat VERSION).tar.gz" -C dist .

# 5) tag (points to the commit just built)
git tag -a "$(cat VERSION)" -m "release $(cat VERSION)"

# 6) self-check (tag==HEAD, release note, clean tree, secrets/large files)
bash docs/standards/scripts/preflight.sh --release

# 7) deploy (example: switch a symlink, keep the last 3 versions)
#    scripts/deploy.sh should: backup → upload → switch → health check → auto-rollback on failure

# 8) verify
curl -fsS https://<your-domain>/health
curl -fsS https://<your-domain>/version    # must equal VERSION

# 9) push main + tag
git push origin main
git push origin "$(cat VERSION)"

# 10) after deploy: fill the actual results into the note (new commit; do not move the tag)
```

**During the release:**

- Verification failure = release failure. **Stop immediately.** Do not "clean up first".
- Cleanup/deletion only runs after verification passes.
- Production accepts only artifacts built from a tag in the repo. Never edit code/config on the server and restart.
- Build once, deploy many times (same artifact to multiple machines).

### 4.4 Post-deploy verification (5 minutes)

1. `/health` returns 200.
2. `/version` equals `VERSION`.
3. Home/login page loads (key entry).
4. One core path works end to end.
5. No new ERROR/stack traces in logs.
6. Static assets return 200 (no 404 JS/CSS).
7. Spot-check mobile/target browser if relevant.
8. Watch for 30 minutes; roll back on alerts or error-rate spikes.

### 4.5 Release note (9 fields, all required)

File: `docs/releases/<version>.md`; template: [`../../templates/release-note.md`](../../templates/release-note.md).

| # | Field | What to write |
|---|---|---|
| 1 | Basics | version, time (with timezone), type |
| 2 | Commit | commit SHA, tag, branch |
| 3 | Change | one sentence: whose problem → what changed |
| 4 | Verification | what ran, result, where the evidence is |
| 5 | Build/deploy commands | paste verbatim, runnable |
| 6 | Rollback | target version + one command + data impact |
| 7 | Risks/open issues | known issues, what to watch |
| 8 | Data/config changes | schema, env vars, migration steps |
| 9 | Scope | modules/entry points/users affected |

Forbidden: "fixed several issues", "improved UX", "tested locally, looks fine", "latest code".

### 4.6 Rollback playbook

**Principle: roll back first, diagnose second.** Do not debug while users are down.

```
Incident
  ├─ Users affected? → roll back to the last verified version now
  ├─ Only the new feature? → turn off the feature flag
  └─ Data corrupted? → stop writes → snapshot → roll back code → fix data separately
```

**Know before you roll back:**

- Target version (the last **verified** one).
- One executable command.
- Data impact: any schema change? Can old code read new data?
- Do you need to rebuild (was the artifact kept)?

**Rules:**

1. Rollback does **not** create a new version; point production back and record the event.
2. Old versions must still exist (keep the last 3 artifacts/images).
3. Code can roll back; **data only moves forward**. Data repair is a separate script + approval.
4. After rollback, release a new version with the fix. Do not edit the old version in place.
5. Rehearse rollback in staging monthly; confirm the command actually runs.

### 4.7 Hotfix

```bash
# 1) branch from the broken tag (not from main)
git switch -c hotfix/R20261106.02-login-500 R20261106.02

# 2) minimal fix + targeted tests + full smoke
# 3) commit, merge back to main (do not push directly to main)
# 4) release a new number (today + next NN), tag it
# 5) release-note type = hotfix; include root cause and prevention
```

- A hotfix fixes the issue; no features or refactors.
- Merge back to `main`, or the next release reintroduces the bug.
- Write the incident record within 24 hours.

### 4.8 Database and data changes

| Rule | Detail |
|---|---|
| Migrations in the repo | `migrations/`, numbered, append-only |
| Forward-only | No down migrations (or don't rely on them); compatibility, not deletion |
| One step of backward compatibility | New code reads old data; old code does not crash on new data |
| Destructive changes in two steps | Add field + dual-write → verify → remove old field |
| Backup before release | DB snapshot + restore drill record |
| No manual production edits | All changes via migrations; emergency data fixes are separate scripts + approval |
| Large tables | Estimate lock time, choose low traffic, use online tools if needed |

### 4.9 Incidents

1. **Contain** (0–5 min): rollback / feature flag / rate limit. Restore usability first.
2. **Record** (5–15 min): timeline, impact, current state.
3. **Fix** (15 min–hours): root cause, through the normal release process.
4. **Post-mortem** (within 24h): symptom, impact, timeline, root cause, response, prevention.
5. **Improve** (within a week): turn prevention into tests/gates/docs, not "be more careful".

Post-mortems are blameless, but must answer "which gate should have caught this?" If the answer is "there was no gate", add one.

### 4.10 When not to release

- Dirty tree / CI not green / no rollback plan.
- Friday, one hour before the end of the day (unless it is a hotfix).
- You are tired, rushed, or doing three things at once.
- You cannot write "what changed" in the release note — you don't understand it well enough.
- Production is alerting or someone is already debugging.

---

**Next:** [03 · Code conventions →](04-code-conventions.md)
