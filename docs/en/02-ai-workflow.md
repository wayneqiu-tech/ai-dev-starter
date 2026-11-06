# 01 · Working with AI

> This is the core chapter. Git, versions, and releases can wait. **If AI collaboration is wrong, every other rule will be bypassed.**

## 1. Treat AI as a new teammate

AI is not a colleague and not just a tool. It is closer to a **very fast, very confident newcomer who does not remember yesterday and does not own the consequences**.

That means three things:

1. **It needs context.** Without `AGENTS.md` and the relevant files, it guesses based on "common practice".
2. **It needs boundaries.** Without "do not do this", it refactors, upgrades, and changes config "while it's there".
3. **It needs acceptance.** "Fixed" is not evidence. Files, commands, output, and version are.

> What you give AI is not encouragement. It is **boundaries + acceptance criteria**.

## 2. The six-step loop

Every task goes through six steps. Small changes can compress them, but do not skip them.

```
1. Read → 2. Plan → 3. Change small → 4. Verify → 5. Self-prove → 6. Human review
```

### Step 1: Read

Before doing anything, AI must read:

- `AGENTS.md` (project rules)
- `VERSION` (current version)
- the latest release note (what changed last time)
- the files involved (not the whole repo)

**Your job:** name the files in the task card. Do not let it guess.

### Step 2: Plan

Ask for a plan of **at most 3 steps**:

- Which files?
- How will it verify?
- What are the risks / what will it not do?

If the plan is wrong, reject it. Do not let it "figure it out while coding".

### Step 3: Change small

- One concern at a time.
- More than 10 files or 400 lines → split.
- No opportunistic refactor, dependency upgrade, or config change.
- If it finds another problem, write it down; do not fix it in the same change.

### Step 4: Verify

- Run the relevant tests (not "the full suite is too slow").
- Run the build.
- If needed, start the app and walk the core path.
- Never say "should be fine" for a command you did not run.

### Step 5: Self-prove

AI must provide the four pieces of evidence in §5. Missing one = not done.

### Step 6: Human review

Review evidence and diff, not tone. Checklist in §6.

> This feels slower. It is much faster than "AI changed it, you don't dare merge, you merge and roll back".

## 3. `AGENTS.md`: the standing contract

Put `AGENTS.md` at the repo root. It is **tool-agnostic**: Cursor, Claude Code, Copilot, and Codex can all read it. Tool-specific files should only point to it and add tool-specific notes.

It must contain 7 things:

1. **One-line project description**: what it is, who it is for, current version.
2. **Directory map**: what lives where; which directories are generated.
3. **Common commands**: install, dev, test, build, release.
4. **Hard constraints**: what must not change, what must not be touched, what must not be added.
5. **Branch/commit rules**: summary + link to the full standard.
6. **Definition of done**: what counts as complete.
7. **Current bans / known traps**: modules being migrated, flaky tests, frozen branches.

Templates: [`../../templates/AGENTS.template.md`](../../templates/AGENTS.template.md) (Chinese: [`AGENTS.zh.md`](../../templates/AGENTS.zh.template.md)).

### Tool adapters

| Tool | How to connect |
|---|---|
| Cursor | `.cursor/rules/*.mdc` with `alwaysApply: true`; content = "read AGENTS.md + tool-specific notes" |
| Claude Code | `CLAUDE.md`; first line "Read AGENTS.md first" |
| GitHub Copilot | `.github/copilot-instructions.md`, pointing to `AGENTS.md` |
| Codex / others | read `AGENTS.md` directly |

**Do not maintain three copies of project rules.** `AGENTS.md` is the single source; other files adapt it.

## 4. Task card: the brief for each AI task

The more specific the task card, the less the AI "improvises".

```markdown
## Task
<one sentence: what to do>

## Context
<why; relevant files, issue, previous behavior>

## Scope
- Only change: <files/directories>
- Do not change: <explicit exclusions>

## Acceptance
- [ ] <executable check, e.g. npm test>
- [ ] <behavior check, e.g. open /login and sign in>
- [ ] version/release note updated (if releasing)

## Risks
<what could be affected; compatibility; special care>
```

Copy the template: [`../../templates/task-card.md`](../../templates/task-card.md).

### A filled-in example

```markdown
## Task
Do not clear the email field when login fails.

## Context
Users report: after a wrong password, the email is cleared too.
Files: src/pages/Login.tsx, src/api/auth.ts.

## Scope
- Only change: the error branch in Login.tsx
- Do not change: API signature, routing, styles

## Acceptance
- [ ] npm test passes
- [ ] Manual: wrong password → email still there → only "wrong password" shown
- [ ] No new dependencies

## Risks
The error state may be overwritten by form reset logic; check useEffect deps.
```

## 5. Self-proof: the four pieces of evidence

When AI finishes, it must output this format:

```markdown
## Changed
- `src/pages/Login.tsx`: keep email state on error
- `src/pages/Login.test.tsx`: added a regression test

## Why
Matches the task card: "email must not be cleared after a wrong password".

## Verified
- `npm test` → 42 passed, 0 failed
- `npm run build` → success
- Manual: Chrome, wrong password → email preserved ✅

## Not done / known limits
- API untouched
- Network-error branch not handled (separate task)
```

**"Done" without output is not done.**

## 6. Human review: 10 checks

Go in order. Do not just read the AI's summary.

1. `git diff --stat`: which files? Any out-of-scope changes?
2. `git diff`: line by line; focus on config, dependencies, deletions, error handling.
3. **Hardcoding**: IPs, absolute paths, passwords, ports, `localhost`.
4. **Shortcuts**: `skip`, `only`, `TODO`, `any`, empty `catch`, commented-out tests.
5. **Tests**: deleted, weakened, or skipped? Assertions changed to pass?
6. **Dependencies**: added/upgraded? Why? License and size acceptable?
7. **Error handling**: does it fail loudly, retry, or silently swallow?
8. **Config**: new settings in `.env.example`? Are defaults safe?
9. **Rollback**: if this breaks, how do we go back? Does data change?
10. **Evidence**: where are the test/build/manual outputs? Version/release note updated?

> If any answer is missing, do not merge yet.

### 6.1 Who does what (the beginner default)

You do **not** have to type branch commands. If your AI tool can run a terminal
and `AGENTS.md` allows it, AI can do the mechanical parts:

| Action | AI | You |
|---|---|---|
| Create a task branch | ✅ | — |
| Edit code, run tests | ✅ | — |
| Commit on the branch | ✅ | — |
| Merge into `main` | ⛔ wait | say "merge" / click merge |
| Push, tag, deploy | ⛔ wait | do it or approve |
| Change secrets / delete data | ❌ | only you, carefully |

The loop: you say "do this task" → AI branches, edits, tests, commits → AI stops →
you review and say "merge".

> This requires a tool that can execute Git commands (Cursor Agent, Claude Code,
> Codex CLI, etc.). A chat-only tool cannot touch your repo; you run the commands
> or use a Git GUI.

## 7. Never let AI do these

Even if it can, do not authorize it.

- ❌ `git push` to `main`
- ❌ deploy to production or restart production services
- ❌ delete data, change database schema, change DNS
- ❌ read/write `.env`, secrets, CI secrets
- ❌ edit tests, skip tests, or delete logs to "make checks pass"
- ❌ put real IPs, domains, or secrets into code/docs/examples
- ❌ copy code from another project or an old version directory
- ❌ add dependencies, upgrade majors, or change build tools without asking
- ❌ mix a large refactor into a feature commit
- ❌ claim "verified" to please the user

**AI can suggest. It cannot decide for you.**

## 8. Multi-session, multi-tool collaboration

AI has no long-term memory. Give it external memory in the repo.

### Handoff file

For long tasks, write `docs/wip/<task>.md`:

```markdown
# Task: keep email on login error
## Done
- [x] reproduced
- [x] changed Login.tsx
- [ ] add test
## Next
- add a regression test in Login.test.tsx
## Traps
- the useEffect dep array resets email; don't just delete it
```

Before a new session: `git status` + read `AGENTS.md` + read the handoff file.

### Decision log

Write key decisions in `docs/DECISIONS.md`, one page per decision:

```markdown
## 2026-11-06 Use dated versions instead of SemVer
- Context: continuous deployment, multiple releases per day possible
- Options: SemVer / dated / hybrid
- Decision: dated RYYYYMMDD.NN
- Impact: library consumers cannot infer compatibility; this is not a library
```

### One writer at a time

- One task, one branch.
- Do not run two AI sessions on the same directory.
- End a session by committing or reverting; never leave half-done work.

## 9. Four prompt templates

### Fix a bug

```
Read AGENTS.md first.
Problem: <symptom>
Repro: <steps>
Expected: <behavior>

Only fix the root cause in <files>. Do not refactor unrelated code.
Before editing, give a 3-step plan.
When done, provide: files changed, root cause, commands + output, rollback.
```

### Add a feature

```
Read AGENTS.md and <files>.
Goal: <one sentence>
Acceptance: <executable criteria>

Give a 3-step plan first. Only touch <scope>. Do not change <exclusions>.
If you need a new dependency, ask before adding it.
```

### Refactor

```
Refactor only; behavior must not change. Scope: <files>.
Add tests first where coverage is missing. Run the existing tests after each step.
Do not mix feature changes into this refactor.
```

### Review

```
Act as a strict reviewer. Review this diff only; do not rewrite it.
Look for: scope creep, secrets, hardcoded values, deleted/skipped tests,
missing error handling, dependency changes, rollback risk.
List findings by severity (blocker / should-fix / nit), with file:line.
```

## 10. A complete example

**You:**

> Read `AGENTS.md`. Problem: email is cleared after a failed login. Repro: wrong password → email gone. Expected: keep email, show only "wrong password". Only change `Login.tsx`; don't touch the API. Give me a 3-step plan first.

**AI:**

> Plan: 1) find the form reset logic; 2) keep email only on a wrong-password error; 3) add a regression test and run tests.

**You:** Go ahead.

**AI:** (changes, then self-proof per §5)

**You:** `git diff` → only 2 files → run `npm test` → check output → merge.

That is a standard AI collaboration: no surprises, no scares.

---

**Next:** [02 · Git, version, release →](03-git-version-release.md)
