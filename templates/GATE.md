# Gate card

> Copy this block into a PR comment, chat, or release note when you need a human decision.
> A gate is **one decision**, not a blanket approval. It expires when the commit or checks change.

```text
GATE: <plan | merge | release>
branch: <branch>
commit: <short sha>
checks: typecheck=<pass|fail|skip> test=<pass|fail|skip> build=<pass|fail|skip> a11y=<pass|fail|skip>
risk: <low | medium | high> — <why>
evidence: <link or one-line proof>
options: [<primary action>] [show diff] [stop]
```

## Rules

- One gate = one action. Do not use a single "continue" to approve merge + deploy.
- The primary action must name the action: `Merge PR`, `Deploy R...`, `Roll back to R...`.
- Never offer "always allow" for merge, deploy, delete, or production changes.
- If the commit or checks change, the gate is stale: ask again.
- Always include a `stop` option.
- Fast lane: one gate at the end of the feature (and one plan gate if the change is not obvious).
- Controlled lane: plan gate, merge gate, release gate.

## Example

```text
GATE: merge
branch: feat/report-chart-interactions
commit: a1b2c3d
checks: typecheck=pass test=pass build=pass a11y=pass
risk: low — docs/UI only, no schema/auth/payment/PII
evidence: PR #42, verify summary in comment
options: [Merge PR] [show diff] [stop]
```
