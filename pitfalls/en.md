# Pitfalls: 30 patterns

> Distilled from **47 engineering incidents** in a real multi-surface project. Deduplicated and grouped into **30 patterns**.
> Project details are anonymized: no specific ports, file names, or business modules. Every pattern maps to a rule in the standard.

## How to read

Each entry has four parts:

- **What happened**: the pattern, not the project details
- **Harm**: why it hurts
- **Fix**: what to do instead
- **See**: the chapter in the standard

> If you only fix one area, fix **version, release, rollback, secrets**.

---

## A. Version and naming (6)

### A1. Folders or zip files as versions

**What happened:** One project had `v1`, `v2`, `final`, `final-2`, `copy` directories. Every release copied a folder or produced a zip.

**Harm:** Editing the wrong copy; nobody knows what is live; disk/backup costs multiply; AI cannot tell which copy is current.

**Fix:** One repo, one working directory; versions are tags, not folders; freeze old directories read-only and delete them on a schedule.

**See:** Chapter 3 §3.3; Chapter 6 §3

### A2. Multiple version numbers for one project

**What happened:** `package.json` had one version, artifact names another, docs another, releases had none. Rollback used "the previous file".

**Harm:** Artifacts cannot self-report; nobody can answer "which version is live"; one overwrite destroys the rollback point.

**Fix:** One `VERSION` source; inject `version.json` at build; tag, release note, artifact, and live manifest agree; keep the last 3 versioned artifacts.

**See:** Chapter 3 §3.2, §3.7

### A3. Version baked into paths, script names, and ports

**What happened:** Directory `app-v3`, script `deploy-v3.sh`, ports allocated per version. Upgrading meant changing a dozen places.

**Harm:** One missed spot; port conflicts and wrong environments; docs never catch up.

**Fix:** Stable paths; environment differences via env vars; stable ports or one config override; script names without versions.

**See:** Chapter 3 §3.6

### A4. Three values for one config

**What happened:** Docs said one port, the env file another, production a third. Releases required a manual `export` override.

**Harm:** Following the docs breaks things; the proxy points at a dead port; debugging starts with "is the config right?".

**Fix:** One config source; print effective values at startup; verify actual values after deploy; docs name variables, not instance values.

**See:** Chapter 3 §3.2; Chapter 5 §2

### A5. Standards lost, scattered, or contradictory

**What happened:** Four or five deployment docs, three or four technical standards; ports and paths disagreed; referenced files were deleted; the most important standard lived on one laptop.

**Harm:** Newcomers and AI follow the wrong doc; "the authoritative doc" means nothing; experience cannot be handed over.

**Fix:** Standards in Git; one entry point; link, don't copy; deprecated docs leave a signpost; quarterly broken-link check.

**See:** Chapter 5 §2.5; Chapter 6 §3

### A6. Artifacts, installers, and screenshots in the repo

**What happened:** Build outputs, hundreds of test screenshots, installers of hundreds of MB, and old zips all lived in the repo.

**Harm:** Slow clones; noisy diffs; binary conflicts; the repo becomes a file dump.

**Fix:** No artifacts in the repo; compress and limit screenshots; installers via Release/LFS; write `.gitignore` on day one.

**See:** Chapter 5 §2

---

## B. Git and collaboration (6)

### B1. No Git at all

**What happened:** The project directory had no `.git`; versions were copies and zips; a mistake was "copy again".

**Harm:** No "who changed this and why"; no recovery; no parallel work; backup equals copy, and a bad copy overwrites everything.

**Fix:** `git init` on day one; small commits; push to a remote; zips are offline archives only.

**See:** Chapter 6 §1, §3

### B2. No tags; rollback by "the previous file"

**What happened:** Releases were not tagged; rollback kept one `prev` file/directory; the next release overwrote the rollback point.

**Harm:** No "past" to return to; release history lives in doc dates; reproducing an old version means digging through zips.

**Fix:** Annotated tag per release; keep the last 3 versions; rollback by tag/version artifact.

**See:** Chapter 3 §3.3, §4.6

### B3. No branch model

**What happened:** Everyone (and every AI session) edited the same directory; CI listened to both `main` and `master`; no naming convention.

**Harm:** Overwritten work; uncertain default branch; no isolation for unfinished changes.

**Fix:** Fix `main`; short-lived branches; delete after merge; CI watches `main` + PR only.

**See:** Chapter 3 §1

### B4. Directories instead of branches

**What happened:** `backup/`, `archive/`, `old/`, `snapshot-2026-xx/` accumulated; each was a copy of the code.

**Harm:** Temporary directories nobody dares delete; no diff/merge; expiry cleanup can delete a file still in use.

**Fix:** History belongs to Git; archives only for artifacts that must be reproducible offline, with a manifest and expiry; expiry must be processed.

**See:** Chapter 5 §2.4

### B5. Rules forbid cross-project copying; reality depends on it

**What happened:** A rule said "never copy from an old version", but config/scripts still pointed at the old directory; the build failed on a new machine.

**Harm:** Rules and reality fight; AI either breaks the rule or cannot do the task.

**Fix:** Isolate with repo boundaries/package management; dependencies in a manifest; rules describe what the current project can do.

**See:** Chapter 2 §7; Chapter 3 §1.7

### B6. Releasing with a dirty worktree

**What happened:** The deploy script inferred scope from `git diff HEAD~1`; untracked files were ignored; uncommitted changes shipped anyway.

**Harm:** Missing files or extra files; "works locally, not in production"; the release is not reproducible.

**Fix:** Clean tree before release; diff "last tag..HEAD"; verify key file hashes after deploy.

**See:** Chapter 3 §4.2, §4.3

---

## C. Commits and repo hygiene (6)

### C1. Commit messages without "why"

**What happened:** Messages were "update", "fix bug", "changed many files"; the reason lived in a chat or someone's head.

**Harm:** Three months later nobody knows why; rollback cannot identify the right commit; AI learns the wrong reason.

**Fix:** Explain why, what was broken, and the trade-off; one concern per commit; reference the issue.

**See:** Chapter 3 §2

### C2. One commit or script does too much

**What happened:** One commit changed a port, upgraded a dependency, and edited the UI; one deploy script handled build, backup, Nginx, and the database.

**Harm:** Cannot roll back one thing; review is impossible; a small change triggers a chain of side effects.

**Fix:** One commit, one concern; one script, one job; dangerous operations get their own script and a second confirmation.

**See:** Chapter 3 §2.1; Chapter 4 §2.2

### C3. Real secrets in the repo

**What happened:** `.env`, email passwords, third-party secrets, and default DB credentials were in the repo. `.gitignore` was updated, but files were already tracked.

**Harm:** Repo access = production access; deleting a file is not a fix; history keeps it forever.

**Fix:** Secrets only in env/key management; repo has `.env.example` only; scan in CI; on leak, rotate before cleaning history.

**See:** Chapter 5 §1

### C4. `.gitignore` does not untrack existing files

**What happened:** The team believed `*.env` was safe. The file had been committed long ago, so `git status` showed nothing, but it stayed in the repo.

**Harm:** False sense of safety; a real leak; newcomers clone secrets they should not have.

**Fix:** Check with `git ls-files`; `git rm --cached` + rotate + add ignore; put the check in preflight/CI.

**See:** Chapter 5 §1.2, §1.4

### C5. Large files and screenshots pollute the repo

**What happened:** Hundreds of screenshots at the root; several near-duplicates; installers and zips committed.

**Harm:** Repo bloat; slow clone/push; binary conflicts; finding an image means browsing.

**Fix:** Test screenshots stay out; evidence goes to `docs/assets/` with naming rules; large files via Release/LFS; monthly Top 10 check.

**See:** Chapter 5 §2.2

### C6. No tests before commit; tests skipped at release

**What happened:** "Should be fine" locally; deploy scripts used `-DskipTests` / `--no-verify`; CI had tests, but releases bypassed CI.

**Harm:** CI green does not mean the release is green; regressions are found in production; tests decay.

**Fix:** Release only CI artifacts or run the same commands as CI; no skip in deploy scripts; fix failures first.

**See:** Chapter 3 §4.2; Chapter 5 §3

---

## D. Release and rollback (7)

### D1. A checklist that cannot be executed

**What happened:** The checklist hardcoded old ports, old paths, and files that no longer existed. People ticked boxes without verifying anything.

**Harm:** The checklist becomes a placebo; newcomers fail; the checks that matter (version, rollback, secrets) are missing.

**Fix:** Only executable commands with expected output; paths as variables; automate what can be automated.

**See:** Chapter 3 §4.2; Chapter 6 §4.4

### D2. Verification failure does not block

**What happened:** The deploy ended with a verification step that printed a warning and continued to cleanup. `SKIP_SMOKE=1` became normal.

**Harm:** Production returns 502 while the log says "done"; cleanup deletes the files needed for rollback.

**Fix:** Verification failure = release failure; stop immediately; skipping requires an explicit flag and a note; cleanup only after success.

**See:** Chapter 3 §4.3

### D3. One-level rollback with destructive side effects

**What happened:** Only one `prev` existed; the rollback script also ran `UPDATE`/`DELETE`; one rollback restored deleted data.

**Harm:** Two releases in a row and there is no "version before last"; rollback causes a new incident; data promises break.

**Fix:** Roll back to a versioned artifact, keep 3; code only, not data; data repair is separate + approved; rehearse.

**See:** Chapter 3 §4.6

### D4. Incomplete backups, never restore-tested

**What happened:** Incremental deploys backed up only overwritten paths; backup could be skipped; kept for 14 days but never restored.

**Harm:** On a real incident, a directory is missing; a corrupt backup goes unnoticed; "we have backups" is a feeling.

**Fix:** Back up the minimum runtime set; keep a manifest; monthly restore drill; timestamp/version/sha256.

**See:** Chapter 5 §6; Chapter 3 §4.2

### D5. Releases depend on manual exports and one machine

**What happened:** Releases required manual env exports; scripts depended on a local JDK, cache, SSH key, or tool; another machine failed.

**Harm:** Only one person/machine can release; "it worked last time"; CI and local differ.

**Fix:** Containerize/script the release environment; one command to install, build, deploy; validate required vars; CI and local run the same command.

**See:** Chapter 3 §4.3; Chapter 5 §3

### D6. Release scope by memory or diff guessing

**What happened:** Four entry points (site, SPA, backend, Nginx); scope set by hand; missing one looked like "done".

**Harm:** Nginx changed but not deployed → 404; frontend deployed without backend → 404; release not reproducible.

**Fix:** Scope explicitly in the release note; script executes and verifies per scope; each entry point has a health check.

**See:** Chapter 3 §4.2, §4.5

### D7. No release note; evidence scattered

**What happened:** Only scattered screenshots and chat logs; no single record of what changed, how it was verified, how to roll back.

**Harm:** Cannot identify the change that caused an incident; cannot prove verification; experience is lost.

**Fix:** One release note per release (9 fields); same name as the tag; in Git; fill actual results within 24 hours.

**See:** Chapter 3 §4.5

---

## E. AI collaboration (5)

### E1. No standing rules for AI

**What happened:** Constraints lived only in one tool's rule file; switching tools lost them; a new session had to guess structure, commands, and release process.

**Harm:** Re-explaining every time; AI follows "common practice" and conflicts with the project; inconsistent style across tools.

**Fix:** `AGENTS.md` at the repo root (tool-agnostic); tool files only reference + add; update rules in the same PR as code.

**See:** Chapter 2 §3

### E2. Rules conflict with reality

**What happened:** A rule said "no cross-directory copying", but config pointed at an old directory; a rule said "don't change ports", but docs required a manual export.

**Harm:** AI either violates the rule or cannot do the task; people teach "this time is an exception"; rules become decoration.

**Fix:** Rules describe current reality; change reality first; document exceptions and compensation; monthly review.

**See:** Chapter 2 §7

### E3. AI hardcodes everything

**What happened:** To "make it run", AI wrote IPs, absolute paths, DB passwords, and ports into scripts; it broke on the next environment.

**Harm:** Non-portable scripts; leaked secrets; looks done, is disposable.

**Fix:** Rules say paths/ports/secrets come from config; grep for hardcoding before delivery; require a config example and a clear missing-config error.

**See:** Chapter 2 §6; Chapter 4 §8

### E4. AI says "fixed", but the artifact did not change

**What happened:** AI edited source without rebuilding; edited `dist/` directly; changed only docs and claimed the feature shipped.

**Harm:** Believed fixed, production unchanged; debugging starts with "is the code right?"; trust collapses.

**Fix:** Require four pieces of evidence (files/why/command output/not done); verify artifacts and versions; build injects the version.

**See:** Chapter 2 §5

### E5. AI changes too much; review is impossible

**What happened:** One prompt said "optimize the project"; AI changed directory structure, dependencies, config, and a dozen files; the diff was thousands of lines.

**Harm:** Bugs cannot be located; no single rollback; humans give up reviewing.

**Fix:** Task card says "only this / not that"; split large changes; require split above 400 lines; check `diff --stat` first.

**See:** Chapter 2 §4, §6

---

## If you only fix 10 things

| # | Action | Patterns |
|---|---|---|
| 1 | Choose one directory; freeze the rest read-only | A1, B1, B4 |
| 2 | `git init` + `.gitignore` + first commit + push | B1, C3, C4 |
| 3 | Move secrets out; rotate them | C3, C4 |
| 4 | One `VERSION` + first annotated tag | A2, B2 |
| 5 | Write a release note (9 fields) per release | D7 |
| 6 | Versioned artifact names; keep the last 3 | A2, D3 |
| 7 | Stop the release when verification fails | D2 |
| 8 | Roll back code only; data moves forward | D3, D4 |
| 9 | Write `AGENTS.md` at the repo root | E1, E2 |
| 10 | Run preflight + tests before merge | C6, D1 |

---

**Back to:** [README](../README.md) · [Full standard](../docs/en/01-why.md) · [Cheatsheet](../CHEATSHEET.md)
