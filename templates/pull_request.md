## Why

<!-- One sentence: whose problem, what scenario, what breaks if we don't change it. Refs #123 -->

## Lane

- [ ] **Fast** — copy/styles/docs/small UI; no schema/auth/payment/PII; one branch may batch 3–5 changes
- [ ] **Controlled** — schema/auth/payment/PII/real integrations; independent PR + review + staged release

## What changed

<!-- By module. Describe behavior changes and trade-offs, not a file list. -->

-

## How it was verified

<!-- Paste commands and key output. Never write "should work". -->

- [ ] `bash scripts/verify.sh` (paste the `VERIFY ...` summary)
- [ ] Manual: <steps + result>
- [ ] `preflight` has no new FAIL
- [ ] Gate: merge approval recorded (`docs/standards/templates/GATE.md`)

## Risk and rollback

| Item | Value |
|---|---|
| Risk | <what could be affected> |
| Rollback | `git revert <sha>` / back to `<version>` |
| Data impact | <none / describe compatibility> |

## Checklist

- [ ] Only the scope described above
- [ ] No secrets, real IPs, or debug code
- [ ] No tests deleted or skipped
- [ ] Docs/release note updated if needed
- [ ] `STATUS.md` updated if a capability moved
- [ ] New dependency reviewed (license, size, necessity)

## AI involvement

<!-- Which tool, which parts, did you read every line? -->

- Tool: <Cursor / Claude Code / Copilot / none>
- Scope: <generation / refactor / tests / docs>
- Human review: <read every line / skimmed the diff>
