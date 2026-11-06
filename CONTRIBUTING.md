# Contributing to AI Dev Standard

Thanks for helping. This standard is only useful if it keeps meeting real projects.

## What is most valuable

1. **A pitfall you actually hit.** Use the "Pitfall report" issue template.
   Include: what happened, harm, how you fixed it, and which rule would have caught it.
2. **A rule that is unclear, too strict, or missing.** Use the "Rule proposal" template.
3. **A translation fix.** Chinese and English must say the same thing.

## Principles

- **Plain language.** A citizen developer should understand it without a glossary.
- **No project-specific details.** Describe the pattern, not your company's ports, domains, or modules.
- **One rule per PR.** Do not mix a rule change with a typo fix and a translation update.
- **Show the failure.** A rule without a real incident behind it is a guess; say so if it is a guess.
- **Keep both languages in sync.** If you change `docs/en/...`, update `docs/zh/...` (or open a translation-only follow-up and say so).

## Workflow

1. Open an issue first for anything larger than a typo.
2. Fork, branch from `main`: `docs/<slug>` or `feat/<slug>`.
3. Make the change.
4. Run the checks:

   ```bash
   bash scripts/preflight.sh --ci
   # if you changed shell scripts:
   bash -n scripts/preflight.sh scripts/init-project.sh
   ```

5. Open a PR. Fill in the template. Link the issue.
6. One approval is required. A second pair of eyes is the point.

## Style

- Prefer short sentences and tables.
- Define a term the first time it appears.
- Use `MUST` / `SHOULD` / `MAY` sparingly; plain "must / should / can" is fine.
- Commands must be copy-pasteable; show expected output.
- Do not add a rule that cannot be checked or explained in one paragraph.

## License

By contributing, you agree that:

- code, scripts, and templates are licensed under the MIT License;
- documentation is licensed under CC BY 4.0.

Do not paste content you do not have the right to license.
