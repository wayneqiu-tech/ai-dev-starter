# 00 · Why this standard exists

> This chapter explains **why**. If you just want to start, read [`../06-adoption.md`](06-adoption.md).

## 1. A real starting point

This standard was not designed in a meeting room. It came from a real multi-surface project: a web admin, a desktop client, a backend API, and several external integrations. The project went through many "versions" and several AI tools.

It shipped. It also accumulated engineering debt:

- Multiple "versions" of the same project existed; nobody could answer "which version is in production?" instantly.
- One config had three different values in three places; following the docs could break things.
- There was no traceable Git history; the fallback was copying a folder.
- Releases were manual scripts. Verification failures printed a warning and continued.
- Rollback had exactly one level ("the previous file"), and the rollback script also changed data.
- Secrets lived in the repo. `.gitignore` was updated, but already-tracked files stayed tracked.
- Four or five deployment docs contradicted each other. A newcomer — or an AI — could follow any of them and be wrong.

A post-mortem produced **47 incidents**. Deduplicated and grouped, they became **30 reusable patterns** (see [`../../pitfalls/en.md`](../../pitfalls/en.md)); abstracted further, they became this standard.

> This is not a "best practices encyclopedia". It is a **rulebook built from a medical record**.

## 2. Five loops

The 47 incidents were not isolated. They came from five loops. If you don't break the loop, more rules won't help.

### Loop 1: Copy

Afraid to break things → copy the folder → both copies change → nobody knows which is real → copy again.

**Result:** versions are never clear; the disk fills with code that "looks right".

**Break it:** one repo, one working directory; versions are tags, not folders.

### Loop 2: Config

Change a port/path in one place → it fails → edit the server by hand → server and repo drift further apart.

**Result:** environment drift; local and production behave differently; debugging starts with "is the config right?".

**Break it:** one config source; print effective values at startup; verify actual values after deploy.

### Loop 3: Test

Skip tests to ship faster → production breaks → emergency rollback → rollback only goes one level → incomplete fix → even less confidence in tests.

**Result:** releases become gambling; rollback becomes a second incident.

**Break it:** gates before release; rollback target must be verified; roll back code, not data.

### Loop 4: Docs

Docs say one thing, scripts do another → AI follows the docs and breaks things → write another doc → three docs contradict each other.

**Result:** docs lose trust; nobody reads them; AI learns the wrong thing.

**Break it:** docs in Git; one entry point; docs and code in the same PR; deprecated docs leave a signpost.

### Loop 5: Detour

"While I'm here", change a port/dependency/config → cannot roll back one change → roll back everything.

**Result:** commits grow; risk concentrates; review becomes a formality.

**Break it:** one change at a time; one commit, one rollback; split large changes.

> These five loops matter more than any single rule. Rules can be trimmed; loops must be broken.

## 3. Three principles

### Principle 1: Single source of truth

One piece of information has exactly one authoritative place.

- Version: the `VERSION` file, not a folder name, not `package.json`.
- Config: one `.env.example` + environment variables, not one copy per environment.
- Docs: the table in README, not ten "latest" documents.
- Production state: a deploy manifest, not "I remember we shipped...".

**Self-check:** point at any fact and ask, "where is its only source?" If you can't answer, it's a pit.

### Principle 2: Small and reversible

Every change is small enough to explain, test, and roll back on its own.

- One commit, one concern.
- A branch lives ≤7 days (configurable).
- One release, one theme.
- The rollback target is a **verified version**, not "the previous file".

**Self-check:** if this change breaks something, can I roll back only it in 5 minutes?

### Principle 3: Machine-checkable

If a script or CI can check it, don't rely on memory.

- Version format, tag, release note → script.
- Secrets, large files, build artifacts → CI.
- Tests, build, health checks → pipeline.

**Self-check:** can this rule be written as one command? If yes, write it. If not, simplify until it can.

## 4. What this is, and what it is not

**It is:**

- A default baseline for solo developers, citizen developers, and small teams.
- A contract between you and the AI: what to read, what to do, what not to touch, how to prove it is done.
- A checkable set of rules, not "I think I ran the tests".
- A starting point you can fork, trim, or make stricter.

**It is not:**

- **A guarantee of product success.** It reduces process failures; it does not validate business rules, architecture, payments, printing, performance, or compliance.
- **An architecture or product spec.** It does not tell you how to model tenants, price a product, or design a database.
- **A replacement for linters/formatters.** Style belongs to tools. This standard covers collaboration and non-negotiable code habits.
- **A certification.** A project can be stricter. A looser project must document why and accept the risk.

> Anyone who says "follow this and nothing can go wrong" is not being honest. A standard lowers probability; it does not remove risk.

## 5. Who it is for

| You are | You get |
|---|---|
| A solo developer | Releases no longer depend on memory; version, rollback, secrets have a floor |
| A citizen developer | A readable Git/release/rollback flow; no need for Git internals |
| A 1–5 person team | One rule set for multiple people and multiple AI tools |
| An open-source maintainer | Humans and AI contributors follow the same rules |

You do not need to know Git internals or how to write CI. You need:

1. a project;
2. 30 minutes;
3. willingness to do the "minimum five things" in [`../06-adoption.md`](06-adoption.md).

## 6. How to use it

### Path A: a new project

1. Read "30-minute setup" in [`../06-adoption.md`](06-adoption.md).
2. Generate the skeleton with `scripts/init-project.sh`.
3. Pick a preset in `standard.conf`.
4. Before the first release, run `preflight --release`.

### Path B: an existing, messy project

1. Read "7 steps out of chaos" in [`../06-adoption.md`](06-adoption.md).
2. Do not rewrite history. Freeze, init, tag a baseline.
3. Fix version + rollback + secrets first; everything else later.

### Path C: just the checklist

Read the checklists in [`../06-adoption.md`](06-adoption.md), or [`../../CHEATSHEET.md`](../../CHEATSHEET.md).

## 7. One request

This is v1.0, not the final word. It will not fit every project perfectly.

- Too strict? Downgrade (strict → standard → minimal). Do not ignore it.
- Too loose? Add rules, but write down why.
- Hit a new pitfall? Open an issue with "what happened / harm / how you fixed it".

A standard stays alive not because it is complete, but because people use it and it has actually stopped incidents.

---

**Next:** [01 · Working with AI →](02-ai-workflow.md)
