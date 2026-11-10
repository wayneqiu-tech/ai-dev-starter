---
name: ai-dev-standard
description: Use AI Dev Standard to manage this project: read the rules, create a branch, make one small change, prove it, and check before merge or release.
whenToUse: The user says "follow the standard", "check this project", "release a new version", "roll back", "clean up", or asks to prevent AI overreach, version confusion, or an unrecoverable release.
user-invocable: true
---

# AI Dev Standard (DSH Skill)

You are using **AI Dev Standard 0.10 public beta**. It is a beginner-first process standard, not a formal standard, and it does not guarantee project success.

## Read first (in order)

1. `AGENTS.md` at the project root (if missing, tell the user).
2. `docs/standards/START_HERE.md` (if it exists).
3. `VERSION` at the root and the latest release note in `docs/releases/`.
4. Read only when needed:
   - AI workflow: `docs/standards/docs/en/02-ai-workflow.md`
   - Git/version/release: `docs/standards/docs/en/03-git-version-release.md`
   - Monitoring/cleanup: `docs/standards/docs/en/07-monitoring-and-recovery.md`

If `docs/standards/` does not exist, stop and tell the user "this project does not have the standard installed". Do not guess paths.

## First load

Use 3 lines, not an essay:

1. Current project / branch / version (say "unknown" if unreadable).
2. What you are about to do (one sentence).
3. How it will be verified (one sentence).

## How to work

- **Do not change `main` directly**: create `feat/`, `fix/`, `docs/`, or `chore/` first; skip only if the user explicitly says so.
- **One thing at a time**: if a change touches more than 10 files or 400 lines, split it; no drive-by refactors or dependency upgrades.
- **Verify in small steps**: run the relevant tests/build after each piece.
- **Prove it**: list files changed, why, commands run, output, and what you did not do.
- **Stop before merge/push/tag/deploy** and ask the user.
- **Never touch secrets**: `.env`, `*.pem`, `*.key`, production config; never write real IPs/passwords into code or docs.
- **Never weaken tests**: do not delete, skip, or rewrite assertions to make a test pass.
- **Stay in scope**: change only the files named in the task; record other issues instead of fixing them.

## Closing rule: Next Action Gate

When a task is done, do **not** end with "if you want, I can..." prose.
End with exactly one `GATE: next` using the host's clickable question/approval UI:

- one executable primary action (open PR page, merge PR, prepare release, run verify);
- one `stop`;
- one primary action per gate; never bundle merge + release + cleanup into one button;
- if no clickable UI exists, print numbered options.

## Common actions

```bash
# status
git branch --show-current
git status --short
cat VERSION

# read-only self-check
bash docs/standards/scripts/preflight.sh

# release check
bash docs/standards/scripts/preflight.sh --release

# cleanup: dry-run first, then --apply
bash docs/standards/scripts/cleanup.sh
bash docs/standards/scripts/cleanup.sh --apply

# new project only: do not run this on an existing project
bash docs/standards/scripts/init-project.sh <target> --name "<name>" --lang en
```

## When the user says "check this project"

1. Run `preflight` (read-only; change nothing).
2. Summarize in plain language:
   - what passes;
   - what warns;
   - what fails, and what to fix first.
3. Never delete checks, edit the script, or skip tests to make it green.

## When the user says "release a new version"

Follow `docs/standards/docs/en/03-git-version-release.md` §4:

1. clean tree, on `main`, up to date;
2. write the release note;
3. build;
4. tag;
5. `preflight --release`;
6. deploy (the user runs it, or explicitly authorizes you);
7. verify `/health` and `/version`;
8. push `main` + tag.

**If verification fails, stop. Do not continue cleanup or deploy.**

## When the user says "roll back"

- Find the last **verified** version, not "the previous file".
- Roll back code only, not data; handle data repair separately.
- Before executing, state the target version, command, and data impact; wait for confirmation.

## When the user says "clean up"

- Run `cleanup.sh` (dry-run) and show the list.
- After confirmation, `--apply`; it moves files to `.trash/` for 7 days before `--purge`.
- Never `rm -rf` a directory the user does not recognize.

## Boundaries

- 0.10 public beta, not a formal standard and not a certification.
- It does not replace architecture, business, security, or compliance review.
- Do not promise "nothing will go wrong"; promise "process accidents are less likely, and releases can be rolled back".
