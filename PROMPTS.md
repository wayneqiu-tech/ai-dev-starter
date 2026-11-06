# AI Prompt Cards (Beginner Edition)

> Do not know what to say to the AI? Copy from here.
> Every card follows the same shape: **when to use → what to copy → what the AI should do → what you confirm**.

---

## 0. First time: copy this to your AI

**When**: you just opened this repo and do not know what to say.

**Copy**:

> You are my AI development assistant. Follow "AI Dev Standard", but do not change any files yet.
>
> Standard repo: https://github.com/wayneqiu-tech/ai-dev-starter
>
> First inspect the current project read-only, then answer:
> 1. Does it have docs/standards/, VERSION, docs/releases/, AGENTS.md?
> 2. What stage is it at (new / existing / already live)?
> 3. What is the smallest next action, and how will we verify it?
>
> If the standard is not installed, say "not installed". Do not guess paths and do not install anything yourself.
> Wait for my confirmation, then do one thing at a time.
> After each task, give me: files changed, why, commands run, results.
> Before merge, push, tag, or deploy, stop and ask me.

**AI should**: inspect read-only; report install state, stage, and next step.

**You confirm**: it inspected first instead of changing code.

---

## 1. Start a new project

**When**: you have an empty folder and want to build something.

**Copy**:

> I am a beginner. Read `START_HERE.md` and `AGENTS.md`.
> Help me start a project named **<name>**. It should **<one sentence>**.
> Tell me your plan in 3 steps first; wait for my confirmation before acting.

**AI should**: read the rules, scaffold the project, confirm the directory and commands.

**You confirm**: the name and the one-sentence purpose.

---

## 2. Add a feature

**When**: you want a page, button, export, reminder, etc.

**Copy**:

> Follow `AGENTS.md` and add: **<one sentence>**.
> Acceptance: **<what I can see or click>**.
> Create a branch first; only change related files. Stop at the commit; do not merge or push.
> Give me four pieces of evidence: files changed, why, commands run, what you did not do.

**AI should**: branch → change → test → commit → stop.

**You confirm**: it does what you asked and does not touch unrelated files.

---

## 3. Fix a bug

**When**: something is wrong, but you cannot point to the code.

**Copy**:

> Follow `AGENTS.md` and fix a bug.
> Symptom: **<what I see>**.
> Steps to reproduce: **<where I click, what I enter, what happens>**.
> Expected: **<what should happen>**.
> Reproduce first, then fix the root cause. Change only what is necessary; stop at the commit; do not merge or push.

**AI should**: reproduce → root cause → small fix → test → commit → stop.

**You confirm**: the original problem is gone and nothing else broke.

---

## 4. Ask the AI to explain code

**When**: you do not understand what it changed.

**Copy**:

> Explain this change in plain language, without jargon.
> Use this format: 1) what it was before; 2) what it is now; 3) why; 4) how to undo it if it breaks.

**AI should**: explain in plain language; no wall of code.

**You confirm**: you can repeat back "what changed".

---

## 5. Ask the AI to write tests

**When**: you want an automatic check so future changes do not break things.

**Copy**:

> Add tests for **<feature/file>**. First tell me the 3 most important behaviors you plan to test; wait for my confirmation.
> The tests must run independently, without a real network or database. Run them and paste the output.

**AI should**: list 3 behaviors → write tests → run → paste output.

**You confirm**: it tests the behavior you want, not just its own implementation.

---

## 6. Check current status

**When**: you do not know whether it is safe to continue.

**Copy**:

> Do not change anything. Tell me:
> 1) which branch we are on; 2) the last 3 commits; 3) whether the worktree is clean; 4) whether there are unpushed commits.
> Explain in plain language and recommend the next step.

**AI should**: inspect read-only; no file changes.

**You confirm**: you understand "where we are and whether to merge".

---

## 7. I messed up

**When**: you clicked wrong, merged wrong, or the AI changed too much.

**Copy**:

> I messed up. Do not change anything yet.
> Tell me: which branch we are on, the last 3 commits, and whether the worktree is clean.
> Then give me 2 recovery options, ordered from lowest to highest risk. Do not execute; wait for my choice.

**AI should**: diagnose → options → wait.

**You confirm**: choose an option you understand; ask it to explain if not.

---

## 8. Roll back to the previous version

**When**: the new version has a problem and you want the old one.

**Copy**:

> I want to roll back. First tell me: which previous version was actually verified, what is the rollback command, and will data be affected?
> Do not execute yet; wait for my confirmation. Roll back code only; do not touch data.

**AI should**: find the target version → give the command → explain data impact.

**You confirm**: the target version is right and data is safe.

---

## 9. Release a new version

**When**: the feature is done and users should get it.

**Copy**:

> Prepare a release. Follow `AGENTS.md` and `docs/en/03-git-version-release.md`:
> 1) update `VERSION`; 2) write the release note; 3) build; 4) tag; 5) run `preflight --release`.
> Tell me the result of each step; do not skip. Give me the rollback plan before deploying.

**AI should**: go in order, show evidence at each step, stop on failure.

**You confirm**: `/version` is right, the core path works, and you know how to roll back.

---

## 10. Hand off to another AI

**When**: you switch tools or start a new session.

**Copy**:

> Read `AGENTS.md`, `VERSION`, the latest release note, and `docs/wip/` if it exists.
> Then summarize in 5 lines: what the project is, where it is, what is next, what pitfalls exist, and what not to touch.
> Wait for my confirmation before starting.

**AI should**: read context → summarize → wait.

**You confirm**: its summary matches what you know.

---

## 11. The AI changed too much

**When**: it touched unrelated files, upgraded dependencies, or changed config.

**Copy**:

> Stop. Do not change anything else.
> List every file in this change and mark which ones are outside the task scope.
> Revert the out-of-scope changes, keep only the task changes, then rerun the tests.

**AI should**: list files → revert out-of-scope → rerun tests.

**You confirm**: only the changes you asked for remain.

---

## 12. Clean up after merging

**When**: the branch is merged and you want a clean repo.

**Copy**:

> The merge is done. Delete the merged local and remote branches, confirm `main` is clean, and tell me the current version.

**AI should**: delete merged branches → check status → report version.

**You confirm**: you are on `main` and the worktree is clean.

---

## 13. Set up weekly cleanup

**When**: the project keeps growing and you want to remove build junk, logs, and temp files.

**Copy**:

> Follow the "periodic cleanup" section of `docs/en/07-monitoring-and-recovery.md`.
> First run `bash docs/standards/scripts/cleanup.sh` and show me what it would remove.
> After I confirm, run `--apply`.
> Then help me install a weekly cleanup. Tell me what it deletes first; never delete source, docs, release notes, tags, or secrets.

**AI should**: dry-run → wait → `--apply` → install weekly job with `--schedule`.

**You confirm**: the list contains nothing you need; the job only runs inside the project.

---

## 14. Set up minimal monitoring

**When**: you want to be told when the service is down, instead of hearing it from users.

**Copy**:

> Follow chapter 6 of `docs/en/07-monitoring-and-recovery.md` and set up minimal monitoring:
> 1) confirm `/health` and `/version` exist; 2) add a healthcheck script; 3) tell me how to configure external uptime and error alerts; 4) make the process restart after a crash.
> Tell me which files you will change and whether production is affected; wait for my confirmation.

**AI should**: check endpoints → add script → give configuration steps → do not touch production.

**You confirm**: `/health` and `/version` are reachable; alerts reach your phone.

---

**Cannot remember all of them?** Start with cards 2, 3, 7, and 9: add a feature, fix a bug, recover, release.
