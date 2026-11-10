# AGENTS.md — standing rules for AI assistants

> **How to use:** copy this file to your repo root as `AGENTS.md`, then replace every `<...>`.
> Delete sections that do not apply, but keep §4 (hard constraints) and §8 (definition of done).
> Last updated: `<YYYY-MM-DD>` · Current version: `<read VERSION>` · Owner: `<name>`

## 1. Project in one sentence

`<What it is, who it is for, what problem it solves. Example: A web app that helps parents track a child's daily reading, built with React and a Node BFF.>`

## 2. Read first (in order)

1. `README.md` — how to run and configure.
2. `VERSION` — current version.
3. `docs/releases/` — the latest release note (what changed last).
4. `docs/standards/` — the engineering standard.
5. §4 of this file — hard constraints.

## 3. Directory map

```
src/            application code (most changes happen here)
tests/          tests
docs/           docs; releases/ = release notes, standards/ = rules
scripts/        build, release, checks; verify.sh = fixed-summary checks
STATUS.md       capability status table (README only links here)
config/         config templates (never real secrets)
public/         static assets
dist/           build output (never edit or commit)
```

> Before editing, confirm which directory owns the file. **Do not copy code from another project or an old version directory.**

## 4. Hard constraints (do not negotiate)

1. **No secrets or production config changes.** Do not read/write `.env`, `*.pem`, `*.key`, CI secrets. Do not put real IPs, domains, or passwords in code or docs.
2. **No cross-project copying.** Reuse by extracting a module, not by copying old code.
3. **Do not touch the test baseline.** Do not delete/skip tests or weaken assertions to make checks pass. Fix the code or explain why.
4. **No unrequested dependencies.** New dependencies, major upgrades, and build-tool changes require approval.
5. **No direct release actions.** Creating a task branch and committing on it is allowed (§6). Do not merge into `main`, push, tag, deploy production, delete data, or change DNS; the human does that.
6. **No hardcoding.** Paths, ports, domains, and secrets come from config. Examples use `<change-me>`.
7. **No scope creep.** Only change the files named in the task. Record other findings; do not fix them here.
8. **No fake verification.** Never claim a command ran if it did not. Paste the output.

## 5. How to work

1. **Plan first.** At most 3 steps: which files, how to verify. Wait for approval on large changes.
2. **Change small.** One concern per commit. Fast lane may batch 3–5 small changes in one PR; more than 10 files or 400 lines: split first.
3. **Verify as you go.** Run the relevant tests/build after each chunk.
4. **Self-prove.** At the end, provide:
   - files changed (one line each, why)
   - which task-card item it satisfies
   - commands run and key output
   - what you did not do / known limits
5. **Ask when unsure.** Do not guess business rules, ports, or "what the user probably wants".

### 5.1 Pick one lane (do not use one process for everything)

| Lane | Use when | Required |
|---|---|---|
| **Fast** | copy, styles, docs, small UI; **no** schema/auth/payment/PII | one branch/PR may batch 3–5 small changes; typecheck + build + relevant a11y; one self-proof; human confirms |
| **Controlled** | schema/migration, auth, billing/refund, PII, real external systems | independent branch/PR; tests + migration/rollback note; human review; staged release |

If unsure, choose **Controlled**. A Fast change that grows into schema/auth/payment/PII must switch lanes.

### 5.2 Gates, not repeated check-ins

Stop only at real gates:

- **Plan gate** — before a large/ambiguous change.
- **Merge gate** — after the feature is done and verified.
- **Release gate** — before deploy/tag, only for Controlled.

At each gate, output the block in `docs/standards/templates/GATE.md` and wait. One gate approves one action; never "always allow" merge/deploy/delete. Small steps inside a feature do not need a stop each.

## 6. Branch and commit

- One **feature** per branch: `feat/<slug>`, `fix/<slug>`, `docs/<slug>`, `chore/<slug>`. A feature may contain 5–8 commits; do not create a branch per interaction.
- Fast lane may batch 3–5 small changes in one branch/PR; Controlled lane gets its own branch/PR.
- You may run `git switch -c`, `git add`, and `git commit` **on that branch**.
- Stop before `git merge`, `git push`, `git tag`, or deploying. Ask the human; those actions are not yours.
- If this is not a Git repo, or you cannot run Git, stop and ask. Do not guess.
- Commits: `<type>(<scope>): <subject>`; the body explains **why**.
- AI-assisted commits include: `Co-authored-by: <tool> <noreply@example.com>`.

## 7. Common commands

```bash
# install
<npm install / pnpm install / pip install -r requirements.txt>

# dev
<npm run dev>

# test
<npm test>

# build
<npm run build>

# fixed-summary verification
bash scripts/verify.sh

# self-check
bash docs/standards/scripts/preflight.sh

# pre-release check
bash docs/standards/scripts/preflight.sh --release
```

## 8. Definition of done (all required)

- [ ] Acceptance criteria met
- [ ] Relevant tests pass (paste output)
- [ ] Build passes (paste output)
- [ ] `verify.sh` summary pasted (`typecheck/test/build/a11y`; skip is explicit)
- [ ] `STATUS.md` updated if a capability moved
- [ ] `preflight` has no new FAIL
- [ ] No secrets, hardcoding, or debug code
- [ ] Docs/release note updated if behavior/config/version changed
- [ ] I can explain how to roll this back

## 9. Current bans / known traps

- `<module being migrated; do not touch>`
- `<flaky test or environment>`
- `<frozen branch/directory>`
- `<old endpoint/config that must not be used>`

## 10. Related docs

| Doc | Purpose |
|---|---|
| `docs/standards/` | the full standard |
| `docs/standards/pitfalls/` | why these rules exist |
| `docs/releases/` | release notes |
| `docs/standards/templates/GATE.md` | one-decision gate card |
| `STATUS.md` | capability status, evidence, gaps |
