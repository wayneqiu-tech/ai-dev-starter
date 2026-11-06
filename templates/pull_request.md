## Why

<!-- One sentence: whose problem, what scenario, what breaks if we don't change it. Refs #123 -->

## What changed

<!-- By module. Describe behavior changes and trade-offs, not a file list. -->

-

## How it was verified

<!-- Paste commands and key output. Never write "should work". -->

- [ ] `npm test` (passed / failed counts)
- [ ] `npm run build`
- [ ] Manual: <steps + result>
- [ ] `preflight` has no new FAIL

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
- [ ] New dependency reviewed (license, size, necessity)

## AI involvement

<!-- Which tool, which parts, did you read every line? -->

- Tool: <Cursor / Claude Code / Copilot / none>
- Scope: <generation / refactor / tests / docs>
- Human review: <read every line / skimmed the diff>
