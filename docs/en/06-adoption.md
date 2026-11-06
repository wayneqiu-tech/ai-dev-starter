# 05 · Adoption

> This chapter closes the gap between "I know" and "I do": how to start in 30 minutes, how to rescue a messy project, and how to keep it going.

## 1. 30-minute setup (new project)

### Fast path: one command

```bash
# from the standard repo
bash scripts/init-project.sh ../my-project --name "My App" --lang en
cd ../my-project
```

It creates the handbook, `AGENTS.md`, `.gitignore`, `VERSION`, `README.md`,
`standard.conf`, a stack-agnostic CI workflow, and a commit-msg hook. It also runs
`git init`, the first commit, the baseline tag, a baseline release note, and `preflight`.

Then spend 10 minutes editing `AGENTS.md`, `README.md`, and `standard.conf`.

### Manual path (what the script does)

Follow these steps if you cannot use the script, or if you are adding the
standard to an existing project.

### Step 0: Prepare (2 min)

- Git works (`git --version`)
- A remote repository (GitHub / GitLab / Gitee / self-hosted)
- The project builds (even if it is one `index.html`)

### Step 1: Add the standard (3 min)

```bash
mkdir -p docs
git clone <this-repo-url> docs/standards
rm -rf docs/standards/.git docs/standards/examples

cp -n docs/standards/templates/AGENTS.template.md ./AGENTS.md
cp -n docs/standards/templates/gitignore.txt ./.gitignore
mkdir -p docs/releases
cp -n docs/standards/templates/release-note.md docs/releases/TEMPLATE.md
```

### Step 2: Pick a preset (2 min)

```bash
cp docs/standards/presets/standard.conf ./standard.conf
```

Change three values:

- `PROJECT_NAME`
- `VERSION_SCHEME` (`dated` or `semver`)
- `DEFAULT_BRANCH`

### Step 3: Write `AGENTS.md` (10 min)

Do not just copy the template. Fill in:

- one-line project description
- directory map
- common commands (install/dev/test/build)
- hard constraints (what must not change)
- definition of done

### Step 4: First version (2 min)

```bash
printf 'R%s.01\n' "$(date +%Y%m%d)" > VERSION
git init && git branch -M main
git add -A
git commit -m "chore: initialize project with AI Dev Standard"
git tag -a "$(cat VERSION)" -m "baseline $(cat VERSION)"
```

### Step 5: CI (5 min)

Copy [`../../templates/github-workflows-ci.yml`](../../templates/github-workflows-ci.yml) to `.github/workflows/ci.yml` and adapt the install/test commands.

### Step 6: Self-check (2 min)

```bash
bash docs/standards/scripts/preflight.sh
```

No `FAIL` means setup is done. Record `WARN`s and fix them before release.

### Step 7: First release (5 min)

Write `docs/releases/<VERSION>.md` and run:

```bash
bash docs/standards/scripts/preflight.sh --release
```

Then follow the order in [`03-git-version-release.md`](03-git-version-release.md) §4.3.

## 2. Three presets: don't start at maximum

### Minimal

For: scripts, tiny tools, prototypes, one-off deliveries.

Required:

- Git repo + `.gitignore`
- `VERSION`
- commit format (one clear concern)
- a release note (one line: what changed, how to roll back)
- `preflight` (warnings allowed)

Can skip: branches, PR, CI, code conventions.

### Standard (recommended)

For: most web/AI apps, solo developers.

Adds:

- `main` + short branches
- 9-field release note
- test + build gates
- `AGENTS.md`
- secret scan
- release tag + version reconciliation

### Strict

For: open-source libraries, paid products, teams of 2+.

Adds:

- PR + review (one person, or "PR + self-check list")
- CHANGELOG
- branch protection (no direct push, no force push)
- monthly rollback drill
- dependency vulnerability scanning
- data migration drills

> Start with Standard. If a rule hurts, downgrade — don't ignore it. If it is not enough, move up.

## 3. Seven steps out of chaos

> For projects with `v1/v2/final/copy` folders. **Do not rewrite history first.**

### Step 0: Freeze

Stop editing the old directories. Tell everyone (including AI): "from now on, only the new repo changes."

### Step 1: Choose one source

Pick the directory closest to production. Rename the others to `_frozen_<date>`, read-only.

### Step 2: Init and commit

```bash
cd <chosen-directory>
git init
git branch -M main
# write .gitignore first (node_modules/dist/.env/large files)
git add -A
git status --short          # confirm no node_modules/.env
git commit -m "chore: baseline import"
```

### Step 3: Baseline tag + note

```bash
printf 'R%s.01\n' "$(date +%Y%m%d)" > VERSION
git add VERSION && git commit -m "chore: establish version baseline"
git tag -a "$(cat VERSION)" -m "baseline $(cat VERSION)"
```

### Step 4: Handle secrets

1. Remove from the index: `git rm --cached .env`
2. **Rotate the keys**
3. Add `.env.example`
4. Then consider cleaning history (`git filter-repo`)

> Order matters: delete first, rotate second = the key is still valid.

### Step 5: CI + preflight

At minimum: build + tests + self-check. Turn "it runs on my machine" into "a machine can prove it".

### Step 6: Move old changes back one by one

One branch/PR per change, run tests, merge. Do not `cp -r` everything.

### Step 7: Delete `_frozen_` after 30 days

Confirm nothing is missing and tags/remote backups exist. Run the full test suite once more before deleting.

## 4. Daily checklists

### 4.1 Every session (30 sec)

- [ ] `git status` clean, or I know which branch I'm on
- [ ] `git pull` to latest
- [ ] `AGENTS.md` / current task card read

### 4.2 Every commit (2 min)

- [ ] One concern
- [ ] Message explains **why**
- [ ] No `console.log` / debug code / commented-out code
- [ ] No secrets, real IPs, absolute paths
- [ ] Tests/build run (at least the affected module)

### 4.3 Every merge (5 min)

- [ ] CI green
- [ ] Diff is in scope
- [ ] Tests cover the new behavior (or explain why not)
- [ ] Docs/release note updated if needed
- [ ] I know how to roll back

### 4.4 Every release (15 min)

- [ ] Clean tree, `main` up to date
- [ ] CI green; tests/build pass
- [ ] `VERSION` updated and valid
- [ ] Tag created and points to the right commit
- [ ] Release note has all 9 fields
- [ ] Rollback target + command + data impact written
- [ ] Backup done (stateful systems)
- [ ] Production config complete
- [ ] `/version` matches `VERSION` after deploy
- [ ] Core path verified; observe for 30 minutes

### 4.5 Monthly (30 min)

- [ ] Delete merged branches; clear stashes
- [ ] Run `bash docs/standards/scripts/cleanup.sh` (dry-run first); confirm the weekly cleanup is running
- [ ] Top 10 largest tracked files
- [ ] Broken links / stale docs
- [ ] Update `AGENTS.md`
- [ ] Dependency vulnerabilities/versions
- [ ] Rollback drill (staging)
- [ ] Key rotation reminders

### 4.6 Incident (first 10 min)

- [ ] Contain: rollback / feature flag / rate limit
- [ ] Record timeline and impact
- [ ] Notify if needed
- [ ] Do not debug in production while users are affected
- [ ] Post-mortem within 24 hours

## 5. FAQ

**Q1: I'm solo. Do I need branches and PRs?**
Branches: yes (isolate unfinished work). PRs: optional. Minimum: `main` + short `feat/fix` branches + `preflight` before merge. A PR leaves a "why" and self-check record; if you skip it, put that in the commit body and release note. If your AI tool can run commands, let it create the branch and commit; you only merge and release.

**Q2: Multiple releases a day — isn't the version number too granular?**
It is, and that's fine. Dated versions are designed for frequent delivery. What matters is that every release answers: which version, what changed, how to roll back.

**Q3: Do docs-only changes need a version?**
Prefer yes (`docs` type); it is cheap. For tiny projects you can disable it, but state "docs do not get their own version" in README.

**Q4: Do I need to test all AI-generated code?**
Not "all", but: core paths need automated tests; modules AI touched must be tested; boundaries/error paths need at least one manual check.

**Q5: Can I push directly to `main`?**
Not recommended. Even solo, use "branch → self-check → merge"; `main` is the "always releasable" floor. In an emergency you can, but then add the commit, tests, and a record.

**Q6: What happens to data after a rollback?**
Code rolls back; data moves forward. If the new version wrote a new format, old code must read it (one step of compatibility); otherwise you can only fix forward. Be extra careful with schema changes.

**Q7: SemVer or dated for open source?**
Libraries people `npm install` → SemVer. Web apps/services → dated. You can do "SemVer externally + dated internally", but document the mapping.

**Q8: Secrets are already in history. What now?**
Rotate/revoke first, clean history second, tell collaborators to re-clone. Deleting the file without rotating is not a fix.

**Q9: Should a small project use a monorepo?**
If one package works, don't use a monorepo. Split when needed; use workspaces, not copied code.

**Q10: How do I start with no tests?**
Write 3 tests for the core path + one smoke script (start → health check → key endpoint). Don't chase coverage; chase "if I break it, I notice".

**Q11: Can I skip or reuse version numbers?**
Skip: yes (not recorded = never happened). Reuse: never (even if the release failed halfway). Rollback does not create a new number.

**Q12: How do I unify rules across Cursor/Claude/Codex?**
One `AGENTS.md` at the repo root is the single source. Tool-specific files only say "read AGENTS.md + tool-specific notes".

**Q13: Does a failed release count as a release?**
It is an attempt; the number is recorded and **not reused**. Note the failure; fix and release the next number.

**Q14: When is it okay not to release?**
When you only change comments/README and the artifact is unchanged. Use `docs:` in the commit and include it in the next release note. Config, dependencies, prompts, and thresholds always need a release.

## 6. Customizing

### 6.1 Parameters only

Edit `standard.conf`:

| Param | Purpose |
|---|---|
| `PROJECT_NAME` | display only |
| `VERSION_SCHEME` | `dated` / `semver` |
| `VERSION_FILE` | path to version file |
| `RELEASE_NOTE_DIR` | release-note directory |
| `DEFAULT_BRANCH` | main branch |
| `BRANCH_PREFIXES` | allowed branch prefixes |
| `REQUIRE_PR` | require PRs |
| `MAX_FILE_MB` | large-file threshold |
| `SECRET_SCAN` | enable secret scan |

### 6.2 Edit the standard

- You may copy, modify, and republish it (docs are CC BY 4.0; attribution required).
- Bump `STD-x.y`; record what/why/migration in `CHANGELOG.md`.
- A project can be stricter. The only five things it must not loosen:
  1. Secrets never enter the repo.
  2. A failed verification means no release.
  3. The rollback target must be verified.
  4. Production accepts only artifacts built from the repo.
  5. AI never operates production, deletes data, or changes keys.

### 6.3 Record deviations

In `docs/standards/DECISIONS.md`:

```markdown
## Why we don't use PRs
- Context: solo project; a PR would only be reviewed by me
- Replacement: run preflight + tests before every merge; explain why in the commit body
- Risk: no second pair of eyes; accepted
```

## 7. One last thing

A standard is not for looking professional. It has two jobs:

1. **Make fewer incidents happen.**
2. **When one happens, let you go back.**

If a rule does neither, it should not exist. Delete it.

---

**Back to:** [README](../../README.md) · [Cheatsheet](../../CHEATSHEET.md) · [Pitfalls](../../pitfalls/en.md)
