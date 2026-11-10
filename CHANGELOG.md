# Changelog

All notable changes to **AI Dev Standard** are documented here.

The project uses SemVer for its own releases: `MAJOR.MINOR.PATCH`.
The version lives in `VERSION`; tags are `vX.Y.Z`.

## [Unreleased]

## [0.10.0] — 2026-11-10 (public beta)

### Added

- Two delivery lanes: **Fast** (docs/copy/small UI, no schema/auth/payment/PII)
  and **Controlled** (schema/auth/payment/PII/external systems).
- One-decision Gate protocol (`templates/GATE.md`): Plan / Merge / Release;
  one gate approves one action, never "always allow".
- `templates/STATUS.md`: one capability table (status/evidence/gap) instead of a
  long README status chain.
- `templates/GATE.md` now includes `GATE: next`; every task must end with one
  executable next action plus `stop`, not free-text "if you want" prose.
- `templates/verify.sh`: fixed-summary check
  (`VERIFY typecheck=... test=... build=... a11y=...`); installed to
  `scripts/verify.sh` by `init-project.sh`.
- `init-project.sh` installs `STATUS.md` and `scripts/verify.sh`.

### Changed

- AGENTS (EN/ZH): one feature per branch (5–8 commits, one PR), lane selection,
  three gates, and explicit skip reporting.
- PR templates: lane, verify summary, gate approval, STATUS update.

## [0.9.3] — 2026-11-07 (public beta)

### Added

- English beginner layer: `START_HERE.md`, `PROMPTS.md`, and
  `TROUBLESHOOTING.md`. The English README now links to these instead of the
  Chinese-only files.
- English DSH skill template (`templates/dsh-skill/SKILL.en.md`);
  `init-project.sh --lang en` installs it as
  `.dsh/skills/ai-dev-standard/SKILL.md`.
- `init-project.sh` now copies both English and Chinese beginner docs, so an
  English generated project links to English files.

### Changed

- `START_HERE.zh.md` now starts with one copy-paste prompt for the AI instead of
  Git/terminal preparation. The rest explains what the AI should answer, how to
  use DSH, and what a beginner should not do.
- `PROMPTS.zh.md` gains card 0 with the same first-use prompt.

## [0.9.2] — 2026-11-07 (public beta)

### Changed

- Positioning: **a development-process standard, not a project diagnostic tool.**
  README (EN/ZH), GitHub About, and the release description now state what it
  covers and does not cover (business, architecture, security audit, performance,
  compliance).

## [0.9.1] — 2026-11-07 (public beta)

### Added

- DSH Skill template (`templates/dsh-skill/SKILL.md`). `init-project.sh` installs
  it at `.dsh/skills/ai-dev-standard/SKILL.md`, so a generated project can use
  `/ai-dev-standard` immediately (a Skill, not a Host plugin).
- `scripts/check-release-sync.sh`: checks HEAD == origin, ledger == live
  `/version`, and HEAD is tagged. Installed to `scripts/` in new projects.
- `preflight.sh` now checks unpushed commits, ledger drift, tag naming, commit
  message, and commit size.
- Environment dimension (dev / CI / prod isolation) in the release chapter.

### Changed

- `preflight.sh` **fails closed** when `standard.conf` is missing or still has
  the placeholder `PROJECT_NAME="my-project"`; no more silent preset fallback.

## [0.9.0] — 2026-11-06 (public beta)

First public beta. This is an **engineering baseline**, not a formal standard yet.
The 1.0 line will follow after real-world feedback (see `GOVERNANCE.md`).

### Added

- 7 guides (bilingual): why, AI workflow, Git/version/release, code conventions,
  security/repo/CI, adoption, monitoring/auto-recovery/cleanup.
- 30 pitfall patterns distilled from 47 real incidents.
- Beginner layer: `START_HERE.zh.md` (three sentences, no Git), `PROMPTS.zh.md`
  (copy-paste instructions), `TROUBLESHOOTING.zh.md` (what to say when broken).
- Templates: `AGENTS.md` (EN/ZH), `CLAUDE.md`, Cursor rule, commit message,
  pull request, release note, `.gitignore`, CI workflow, healthcheck, systemd,
  Docker healthcheck.
- Presets: minimal, standard, strict.
- `SECURITY.md` and `GOVERNANCE.md` for the public beta (reporting, decision process, 1.0 criteria).
- `preflight.sh` (read-only self-check), `cleanup.sh` (7-day trash + weekly
  schedule), and `init-project.sh` (one-command bootstrap: handbook, AGENTS.md,
  README, VERSION, git init/commit/tag, stack-agnostic CI, commit-msg hook,
  baseline release note).
- A runnable example in `examples/hello-standard/`.

### Notes

- Default version scheme: dated `RYYYYMMDD.NN`; SemVer is supported.
- Default branch model: trunk + short-lived branches.
- Documentation: CC BY 4.0. Code and templates: MIT.

## How to propose a change

1. Open an issue using the "Rule proposal" or "Pitfall report" template.
2. One rule per PR.
3. Update both languages if the meaning changes.
4. Add a changelog entry under `Unreleased`.
