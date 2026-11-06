# AGENTS.md — hello-standard example

This is a **runnable example** of AI Dev Standard. Read the root `AGENTS.md` template
and `docs/en/02-ai-workflow.md` for the reasoning.

## Project

A tiny Node HTTP server used to demonstrate the standard's release loop. No dependencies.

## Commands

```bash
npm test          # node --test
npm run build     # writes dist/version.json from VERSION
npm start         # http://127.0.0.1:3000
```

## Hard constraints

1. Do not add dependencies. This example must stay dependency-free.
2. Do not hardcode the version in source; read `VERSION`.
3. Keep the server and tests small; this is an example, not a framework.
4. Do not change the release note format; it follows the 9-field template.
5. Do not commit `dist/` or `node_modules/`.

## Definition of done

- [ ] `npm test` passes
- [ ] `npm run build` passes and `dist/version.json` matches `VERSION`
- [ ] Release note updated if the version changed
- [ ] No secrets, hardcoding, or debug output

## Workflow

One branch, one change. Self-prove with files, commands, output, and what you did not do.
