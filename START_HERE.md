# Start Here (Beginner Edition)

> **First time? Do one thing: copy the message below to your AI.**
> You do not need to know code, Git, branches, commits, tags, or CI.

---

## Step 0: Copy this to your AI

```text
You are my AI development assistant. Follow "AI Dev Standard", but do not change any files yet.

Standard repo: https://github.com/wayneqiu-tech/ai-dev-starter

First inspect the current project read-only, then answer three things:
1. Does this project have the standard installed: docs/standards/, VERSION, docs/releases/, AGENTS.md?
2. What stage is it at (new project / existing project / already live)?
3. What is the smallest next action, and how will we verify it?

If the standard is not installed, say "not installed" directly. Do not guess paths and do not install anything yourself.
Wait for my confirmation, then do one thing at a time.
After each task, give me: which files changed, why, which commands ran, and the results.
Before merge, push, tag, or deploy, stop and ask me.
```

> This does not let the AI change code immediately. It only inspects and tells you the next step. You say "go" before it continues.
>
> If the AI starts changing code, say: **"Stop. Run the read-only check first."**

---

## What the AI should answer

It should give you three things:

1. Whether the standard is installed;
2. What stage the project is at;
3. The smallest next action, and how to verify it.

Then you only need to reply:

- "Not installed" → **"OK. Tell me how to install it. Do not change code yet."**
- "Installed" → **"OK. Do the next step you proposed, but show me the plan first."**
- "I don't know" → **"Read START_HERE.md in the standard repo, then answer me."**

---

## You only do three things

1. Tell the AI what to do.
2. Check whether it is done (it must show evidence).
3. Say "merge it" / "release it", or "no, redo it".

> **The AI does the work. You say "yes" or "no".**

---

## If you use DSH

When the skill is installed, type:

```text
/ai-dev-standard check this project
```

No plugin install and no permission prompt; it is a Skill.
If the skill is not available, use the prompt in Step 0.

> `init --lang en` installs an English DSH skill. If your workspace still has the Chinese version, use the English prompt above.

---

## New project: one command (optional)

If you have a terminal, run this in an **empty directory**:

```bash
git clone --depth 1 https://github.com/wayneqiu-tech/ai-dev-starter.git /tmp/ai-dev-standard
bash /tmp/ai-dev-standard/scripts/init-project.sh . --name "My Project" --lang en
```

It creates: the handbook, `AGENTS.md`, `VERSION`, release notes, CI, a commit hook,
a baseline tag, the DSH skill, the release-sync script, and runs a self-check.

> If you do not have a terminal, or do not know what an "empty directory" is:
> do not run it. Send the Step 0 prompt to your AI and let it guide you.

---

## Existing project: do not run init

If the project already has code, or is already live, **do not** use `init-project.sh`.

Copy this to your AI:

```text
This is an existing project, possibly already live. Do not run init and do not change code.

First inspect read-only:
1. Is it a Git repository, what branch is it on, and are there uncommitted changes?
2. Does it have docs/standards/, VERSION, docs/releases/, AGENTS.md?
3. Are there .env files, secrets, build artifacts, or frozen packages?
4. How are releases deployed and rolled back today?

Then give me an "install / do not install" plan, ordered by risk.
Do not execute anything until I confirm.
```

It only gives you a health report; it does not touch the project.

---

## Three sentences a day

### 1. Start a task

```text
Follow AGENTS.md and do: <one task>.
Create a branch first. Stop at the commit; do not merge or push.
Give me four pieces of evidence: files changed, why, commands run, and what you did not do.
```

Example:

```text
Follow AGENTS.md and build a "spending" page: enter an amount and a note, save it, and show it in a list.
Create a branch first. Stop at the commit; do not merge or push.
```

### 2. Merge

When you have reviewed the evidence and agree:

```text
I reviewed it. Merge into main and delete the branch.
```

### 3. Release

```text
Prepare a release following AI Dev Standard. Read-only first; do not deploy.
Give me the version number, tag, release-note draft, rollback target, and verification commands.
Wait for my confirmation before executing.
```

> Release only after you confirm. Do not let the AI "just deploy".

---

## Terms you do not need to memorize

| Term | Think of it as | Who does it |
|---|---|---|
| Branch | A scratch copy; a bad change does not affect the official version | AI |
| Commit | A save point, with a message | AI |
| Tag | A label for one version | AI |
| CI | Automatic checks after each commit | Automatic |
| Release note | A shipping note: what changed, how it was verified, how to roll back | AI drafts; you confirm |
| `preflight` | A pre-flight check: is everything required on board? | AI runs; you read |
| `check-release-sync` | A post-deploy reconciliation: does the record match production? | AI runs; you read |

Remember only this: **the AI does the work; you say "yes" or "no".**

---

## Three things not to do

1. **Do not say "refactor the whole project"** — one task at a time.
2. **Do not let it push or deploy automatically** — it must ask before merge/release.
3. **Do not accept "done" without evidence** — ask "where is the proof?".

---

## When something breaks

```text
I broke something. Do not change anything yet.
Tell me: which branch we are on, the last 3 commits, and whether the worktree is clean.
Then give me 2 recovery options, ordered from lowest to highest risk.
```

---

## Next

- Do not know what to say to the AI? See [`PROMPTS.md`](PROMPTS.md), card 0.
- Hit an error, conflict, or failed release? See [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md).
- Want weekly cleanup? See [`PROMPTS.md`](PROMPTS.md) card 13.
- Want monitoring and auto-restart? See [`docs/en/07-monitoring-and-recovery.md`](docs/en/07-monitoring-and-recovery.md).
- Want to understand "why these rules"? See [`docs/en/01-why.md`](docs/en/01-why.md).

---

**One sentence:** you do not need to become a programmer. You need to copy one prompt, read the evidence, and nod before merge/release.
