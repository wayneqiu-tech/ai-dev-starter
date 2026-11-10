# Gate card

> Copy this block into a PR comment, chat, or release note when you need a human decision.
> A gate is **one decision**, not a blanket approval. It expires when the commit or checks change.

```text
GATE: <plan | merge | release | next>
branch: <branch>
commit: <short sha>
checks: typecheck=<pass|fail|skip> test=<pass|fail|skip> build=<pass|fail|skip> a11y=<pass|fail|skip>
risk: <low | medium | high> — <why>
evidence: <link or one-line proof>
options: [<primary action>] [show diff] [stop]
```

## Rules

- **Every finished task ends with exactly one `GATE: next`.** The primary option is the next executable action (open PR page, merge PR, prepare release, run verify); never end with "if you want, I can..." prose.
- If the host supports clickable questions/approvals, render the options as buttons. If not, print numbered options.
- A `next` gate has one primary action and `stop`; do not bundle three unrelated choices.
- One gate = one action. Do not use a single "continue" to approve merge + deploy.
- The primary action must name the action: `Merge PR`, `Deploy R...`, `Roll back to R...`.
- Never offer "always allow" for merge, deploy, delete, or production changes.
- If the commit or checks change, the gate is stale: ask again.
- Always include a `stop` option.
- Fast lane: one gate at the end of the feature (and one plan gate if the change is not obvious).
- Controlled lane: plan gate, merge gate, release gate.

## Example: next

```text
GATE: next
done: feat/lanes-gates 0866804 pushed
checks: verify=pass links=0
recommended: open the PR page
options: [Open PR page] [stop]
```

## Example: merge

```text
GATE: merge
branch: feat/report-chart-interactions
commit: a1b2c3d
checks: typecheck=pass test=pass build=pass a11y=pass
risk: low — docs/UI only, no schema/auth/payment/PII
evidence: PR #42, verify summary in comment
options: [Merge PR] [show diff] [stop]
```
