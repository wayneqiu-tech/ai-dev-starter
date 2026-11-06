# Governance

> Status: **0.9.2 public beta**. This is a small open-source project, not a
> formal standards body. It does not certify anyone.

## Maintainer

- Current maintainer: the repository owner (`@<your-handle>`).
- The maintainer makes the final call on rule changes and releases.
- A second maintainer will be added after **3 external contributors** have had
  PRs merged, or earlier if the owner chooses.

## How decisions are made

| Change | Process |
|---|---|
| Typo, translation fix, broken link | PR, one approval, merge |
| New template/script that does not change a rule | PR + a short rationale |
| New rule, or a change to an existing rule | Issue first; **7 days** for comments; maintainer decision; PR |
| Breaking change to a rule or level | RFC issue; **14 days**; migration note; release note |
| Security report | Private channel (see `SECURITY.md`) |
| Code of conduct issue | Private message to the maintainer |

Silence is not consent for breaking changes. If no one comments in the window,
the maintainer may still decide, but must write the reason in the issue.

## Versioning and releases

- The project uses **SemVer** for its own releases: `MAJOR.MINOR.PATCH`.
- `0.x` is public beta: rules, levels, and wording may change.
- Every release has a tag (`vX.Y.Z`), a release note in `docs/releases/`, and
  an entry in `CHANGELOG.md`.
- A release is not "done" until `preflight --release` passes in a clean clone.
- Security fixes may be released without a long comment window.

## Scope

In scope: AI-assisted development workflow, Git/version/release hygiene, beginner
entry points, templates, scripts, and lightweight monitoring/cleanup guidance.

Out of scope: architecture, product management, legal/compliance advice,
framework-specific style guides, and certification.

## How we get to 1.0

`1.0.0` requires all of:

1. **10 beginners** complete the 30-minute path without private help.
2. **5 real friction issues** from those users are closed.
3. **3 projects** adopt the baseline (a link or a short case study).
4. A normative `SPEC.md` with numbered requirements and MUST/SHOULD/MAY.
5. A `CONFORMANCE.md` plus a command that checks at least the Standard level.
6. A security posture: `SECURITY.md`, secret scanning, and a release process
   with a clear rollback path.

If these are not met, the project stays on `0.x`. That is a feature, not a failure.

## 中文摘要

- 现在 **0.9.2 公测**，不是正式标准，也不做认证。
- 当前由仓库所有者维护；3 个外部贡献者合并后再加第二维护者。
- 改规则：先开 issue，7 天评论期；破坏性变更 14 天 + 迁移说明。
- 版本用 SemVer；0.x 允许变；每次发布有 tag、发布单、CHANGELOG。
- 1.0 的条件：10 个小白走通、关 5 个摩擦 issue、3 个项目采用、
  `SPEC.md` + 一致性检查 + 安全基线。
- 达不到就继续 0.x；这不是失败，是诚实。
