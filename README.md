# AI Dev Standard

> **Let AI build your project — without letting it turn the project into a mess.**
> **No random rewrites. No lost versions. No release you can't undo. No junk pile-up.**

You only need to give instructions. The AI opens the draft, saves checkpoints, tags versions, and writes the release record. You review the evidence and click merge or publish.

It fixes six beginner problems:

- **AI changes too much to review** → one task at a time, with proof
- **“Which version is live?”** → one version number you can check
- **A bad release you can't undo** → keep the last 3 versions and a rollback command
- **Secrets pushed to GitHub** → checked before commit
- **A repo that grows into a junk pile** → weekly cleanup, with a 7-day trash
- **“What do I even say to the AI?”** → 12 copy-paste prompt cards

> Public beta 0.9.1 · not a formal standard yet · [简体中文](README.zh.md)
> New here? Read [START_HERE.zh.md](START_HERE.zh.md).

Built from **47 real engineering failures**, distilled into **30 patterns**, templates,
scripts, and a runnable example. Tool-agnostic: Cursor, Claude Code, Copilot, Codex,
or a plain chat window.

---

## The problem: five loops

Most teams don't fail because of one big mistake. They fail because of loops:

| # | Loop | How it starts | How it "ends" (badly) | What actually breaks it |
|---|---|---|---|---|
| 1 | **Copy loop** | Afraid to break things, copy the folder | Both copies change, nobody knows which is real, copy again | Git branches and tags; one working directory |
| 2 | **Config loop** | Change a port/path in one place | It fails, so edit the server by hand | One config source; print effective values; verify after deploy |
| 3 | **Test loop** | Skip tests to ship faster | Production breaks, roll back, rollback only goes one level | Gates before release; rollback target must be verified |
| 4 | **Doc loop** | Docs say one thing, scripts do another | AI follows the docs and breaks things; write another doc | Docs in Git; one entry point; same PR as code |
| 5 | **Detour loop** | "While I'm here", change a port/dependency/config | Cannot roll back one change, so roll back everything | One change at a time; one commit, one rollback |

> The standard exists to break these five loops, not to add paperwork.

---

## What this is

- A **default baseline** for solo developers, citizen developers, and small teams who use AI to write code.
- A **contract between you and the AI**: what to read, what to do, what not to touch, how to prove it is done.
- A **checkable** baseline: version format, tags, release notes, secrets, large files, unpushed commits, ledger drift, and live version can be verified by `preflight.sh`, `check-release-sync.sh`, and CI.
- A **starting point** you can fork, trim, or make stricter.

## Status (public beta)

- **0.9.1 public beta** — adopt it, but expect changes.
- **Stable enough to use:** templates, presets, `preflight.sh`, `cleanup.sh`, `init-project.sh`.
- **May change before 1.0:** rule names, level boundaries, wording, default scripts.
- **1.0 criteria:** 10 beginners complete the 30-minute path, 5 real friction issues closed,
  3 projects adopt it, plus a normative `SPEC.md` and a conformance check.
- **Not a formal standard or certification.** See [`GOVERNANCE.md`](GOVERNANCE.md).

## What this is not

- **Not a guarantee of product success.** It reduces process failures (version chaos, unrecoverable releases, leaked secrets). It does not validate your business rules, architecture, payments, printing, performance, or compliance.
- **Not an architecture or product spec.** It does not tell you how to model tenants, price a product, or design a database.
- **Not a replacement for linters/formatters.** Use ESLint, Prettier, Ruff, gofmt, etc. for style. This baseline covers the human + AI workflow and the non-negotiable code habits.
- **Not a certification.** A project can be stricter; a project that is looser should document why and accept the risk.

> Read [`docs/en/01-why.md`](docs/en/01-why.md) for the full story.

---

## Who it is for

- **Solo developers** who use AI every day and want to stop "vibe-shipping".
- **Citizen developers** who can build with AI but were never taught Git, releases, or rollbacks.
- **Small teams (1–5)** that need one shared way to work with multiple AI tools.
- **Open-source maintainers** who want contributors (human or AI) to follow the same rules.

You do **not** need to know Git internals. You need 30 minutes and a project.

## New to this? (中文小白入口)

If you are not a developer and only know how to give instructions:

- **[START_HERE.zh.md](START_HERE.zh.md)** — three sentences; no Git knowledge
- **[PROMPTS.zh.md](PROMPTS.zh.md)** — copy-paste instructions for common tasks
- **[TROUBLESHOOTING.zh.md](TROUBLESHOOTING.zh.md)** — what to say when something breaks

That path assumes **zero Git knowledge**. The rest of this README is the developer path.

---

## 5-minute start

### Option A: one command (recommended)

```bash
git clone <this-repo-url> ai-dev-standard
cd ai-dev-standard
bash scripts/init-project.sh ../my-project --name "My App" --lang en
cd ../my-project
```

That command creates the handbook, `AGENTS.md`, `.gitignore`, `VERSION`,
`README.md`, `standard.conf`, a CI workflow, and a commit-msg hook. It also runs
`git init`, the first commit, the baseline tag, a baseline release note, and `preflight`.

```bash
# edit AGENTS.md, README.md, standard.conf
git remote add origin <your-repo-url>
git push -u origin main --tags
```

Useful flags:

| Flag | Effect |
|---|---|
| `--lang zh` | Chinese `AGENTS.md`, release note, and PR template |
| `--semver` | start at `0.1.0`, tag `v0.1.0` |
| `--no-ci` | do not install `.github/workflows/ci.yml` |
| `--no-hooks` | do not install the commit-msg hook |
| `--no-git` | only create files (no git init/commit/tag) |

### Option B: add the standard to an existing project

```bash
# 1) clone the standard into docs/standards (or use a submodule)
mkdir -p docs
git clone <this-repo-url> docs/standards
rm -rf docs/standards/.git docs/standards/examples

# 2) copy the files you need
cp -n docs/standards/templates/AGENTS.template.md ./AGENTS.md
cp -n docs/standards/templates/gitignore.txt ./.gitignore
mkdir -p docs/releases
cp -n docs/standards/templates/release-note.md docs/releases/TEMPLATE.md

# 3) choose a preset at the project root, then edit three values
cp docs/standards/presets/standard.conf ./standard.conf
#    PROJECT_NAME / VERSION_SCHEME / DEFAULT_BRANCH

# 4) create the first version
printf 'R%s.01\n' "$(date +%Y%m%d)" > VERSION

# 5) commit and tag
git add -A
git commit -m "chore: adopt AI Dev Standard"
git tag -a "$(cat VERSION)" -m "baseline $(cat VERSION)"

# 6) self-check
bash docs/standards/scripts/preflight.sh
```

Expected: no `FAIL`. Warnings are fine to fix later (common ones: no remote, no release note yet).

---

## Use it in DSH (optional)

If you use DeepSeek Harness, `init-project.sh` installs a Skill at
`.dsh/skills/ai-dev-standard/SKILL.md`.

Open the project in DSH and type:

```text
/ai-dev-standard 检查当前项目
```

or:

```text
/ai-dev-standard 帮我初始化一个新项目
```

It is a **Skill, not a plugin**: no install, no Host code, no permission prompt.
If you don't use DSH, ignore the `.dsh/` folder.

---

## Check what preflight cannot see

`preflight.sh` is local and read-only. It cannot know whether the release is on
the remote, whether the ledger matches the live service, or whether HEAD is
tagged. Use the sync check too:

```bash
bash scripts/check-release-sync.sh
```

It checks three things:

1. `HEAD` equals `origin/<branch>` (the release is not only on this laptop).
2. the ledger / `VERSION` equals the live `/version` endpoint (no ledger drift).
3. `HEAD` has a tag, and the tag matches the ledger (a release is reproducible).

`LIVE_VERSION_URL` is optional; set it in `standard.conf` or the environment.

---

## Three levels: pick one

| Level | For | What you get | What you can skip |
|---|---|---|---|
| **Minimal** | scripts, tiny tools, prototypes | Git, `VERSION`, commit format, release note (1 line), preflight | branches, PR, CI, code conventions |
| **Standard** | most web/AI apps | everything in Minimal + short branches + 9-field release note + tests/build gates + `AGENTS.md` | formal architecture docs, multi-module versions |
| **Strict** | open-source libs, paid products, teams | everything in Standard + PR review + CHANGELOG + secret scan + rollback drill + branch protection | nothing recommended |

Presets live in [`presets/`](presets/). Start with `standard.conf`; move up only when it hurts.

---

## What's inside

```
.
├─ README.md / README.zh.md       # this file
├─ START_HERE.zh.md               # beginner entry: three sentences, no Git
├─ PROMPTS.zh.md                  # copy-paste instructions for common tasks
├─ TROUBLESHOOTING.zh.md          # what to say when something breaks
├─ CHEATSHEET.md / .zh.md         # one-page printable summary
├─ VERSION                        # the baseline's own version (0.9.1)
├─ standard.conf                 # repo config for preflight
├─ docs/
│  ├─ en/  zh/                    # 7 guides, bilingual
│  └─ releases/                   # release notes for the standard itself
├─ pitfalls/                      # 30 patterns distilled from 47 real failures
├─ templates/                     # AGENTS, commit, PR, release note, CI, healthcheck, systemd, Docker, DSH skill
├─ presets/                       # minimal / standard / strict
├─ scripts/
│  ├─ preflight.sh                # read-only self-check
│  ├─ check-release-sync.sh       # remote / ledger / live / tag sync
│  ├─ cleanup.sh                  # weekly junk cleanup + 7-day trash
│  └─ init-project.sh             # one-command bootstrap (git/commit/tag/CI/hook)
├─ examples/hello-standard/       # a runnable example (Node, no dependencies)
├─ .github/                       # issue templates, PR template, CI
├─ SECURITY.md                    # how to report a vulnerability
├─ GOVERNANCE.md                  # who decides, how 1.0 happens
├─ LICENSE                        # MIT (code and templates)
└─ LICENSE-docs                   # CC BY 4.0 (documentation)
```

---

## The rules at a glance

| Topic | Default | Where |
|---|---|---|
| Branch | `main` + short-lived `feat/ fix/ docs/ chore/ refactor/ test/`, ≤7 days | [Chapter 3](docs/en/03-git-version-release.md) |
| Commit | `type(scope): subject`, body explains **why** | [Chapter 3](docs/en/03-git-version-release.md) |
| Version | `RYYYYMMDD.NN` (default) or SemVer | [Chapter 3](docs/en/03-git-version-release.md) |
| Tag | annotated, same as `VERSION`, points to the built commit | [Chapter 3](docs/en/03-git-version-release.md) |
| Release | gate → build → tag → preflight → deploy → verify → note | [Chapter 3](docs/en/03-git-version-release.md) |
| Rollback | point back to a verified version; never roll back data | [Chapter 3](docs/en/03-git-version-release.md) |
| AI | read `AGENTS.md`; task card; small steps; self-proof; human review | [Chapter 2](docs/en/02-ai-workflow.md) |
| Secrets | never in Git, frontend, logs, or screenshots | [Chapter 5](docs/en/05-security-repo-ci.md) |
| Code | small units, explicit errors, no magic, no dead code | [Chapter 4](docs/en/04-code-conventions.md) |
| CI | test + build + preflight; fail closed | [Chapter 5](docs/en/05-security-repo-ci.md) |
| Monitoring | `/health` + `/version` + uptime + alerts; restart on crash | [Chapter 6](docs/en/07-monitoring-and-recovery.md) |
| Cleanup | weekly `cleanup.sh`, 7-day trash, never tracked files | [Chapter 6](docs/en/07-monitoring-and-recovery.md) |

---

## Read the standard

| English | 简体中文 |
|---|---|
| [00 · Why this exists](docs/en/01-why.md) | [00 · 为什么需要它](docs/zh/01-why.md) |
| [01 · Working with AI](docs/en/02-ai-workflow.md) | [01 · 和 AI 一起工作](docs/zh/02-ai-workflow.md) |
| [02 · Git, version, release](docs/en/03-git-version-release.md) | [02 · Git、版本、发布](docs/zh/03-git-version-release.md) |
| [03 · Code conventions](docs/en/04-code-conventions.md) | [03 · 代码约定](docs/zh/04-code-conventions.md) |
| [04 · Security, repo, CI](docs/en/05-security-repo-ci.md) | [04 · 安全、仓库、CI](docs/zh/05-security-repo-ci.md) |
| [05 · Adoption](docs/en/06-adoption.md) | [05 · 落地](docs/zh/06-adoption.md) |
| [06 · Monitoring, recovery, cleanup](docs/en/07-monitoring-and-recovery.md) | [06 · 监控、自动修复与清理](docs/zh/07-monitoring-and-recovery.md) |
| [Pitfalls (30 patterns)](pitfalls/en.md) | [踩坑清单（30 个模式）](pitfalls/zh.md) |

---

## Contributing

This is a living baseline. The best contributions are:

1. **A pitfall you actually hit** — use the "Pitfall report" issue template.
2. **A rule that is unclear or too strict** — use the "Rule proposal" template.
3. **A translation fix** — Chinese and English must say the same thing.

Read [`CONTRIBUTING.md`](CONTRIBUTING.md) before opening a PR. One rule per PR, please.
How decisions are made: [`GOVERNANCE.md`](GOVERNANCE.md). Security reports: [`SECURITY.md`](SECURITY.md).

---

## License

- **Code, scripts, templates:** [MIT](LICENSE)
- **Documentation (this README, `docs/`, `pitfalls/`):** [CC BY 4.0](LICENSE-docs)

You can use the templates in commercial projects. Attribution is appreciated but not required for the code; it is required if you republish the documentation.

---

**Start here:** [Why this exists](docs/en/01-why.md) · [Cheatsheet](CHEATSHEET.md) · [中文版](README.zh.md)
