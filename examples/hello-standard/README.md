# hello-standard

A **runnable example** of AI Dev Standard. No dependencies, no framework. Node 18+.

It demonstrates the smallest complete loop:

```
change → test → build (version injected) → release note → tag → verify
```

## Run it

```bash
cd examples/hello-standard
npm test          # 3 tests, no install needed
npm run build     # writes dist/version.json from VERSION
cat dist/version.json
npm start         # http://127.0.0.1:3000
```

> `package.json` keeps a toolchain version (`0.1.0`) because npm requires one.
> The **delivery version** is `VERSION` (`R20261106.01`); the build reads it.

Endpoints:

- `GET /health` → `{"status":"ok"}`
- `GET /version` → `{"version":"R20261106.01"}`
- `GET /` → a greeting

## Try the workflow

1. Change the greeting in `src/server.js`.
2. Add or adjust a test in `test/server.test.js`.
3. Run `npm test` and `npm run build`.
4. Bump `VERSION` (for example `R20261106.02`).
5. Copy `docs/releases/TEMPLATE.md` to `docs/releases/<VERSION>.md` and fill it.
6. Commit, then:

   ```bash
   git tag -a "$(cat VERSION)" -m "release $(cat VERSION)"
   bash ../../scripts/preflight.sh --release
   ```

7. Inspect the version: `curl http://127.0.0.1:3000/version`.

## What to notice

| File | Why it exists |
|---|---|
| `VERSION` | the only version source; build reads it |
| `scripts/build.mjs` | injects the version into `dist/version.json`; fails on a bad format |
| `test/server.test.js` | core path + error path, no network mocking |
| `docs/releases/R20261106.01.md` | the 9-field release record |
| `AGENTS.md` | the rules an AI assistant must follow in this example |

## What this example is not

- A web framework or a production template.
- A replacement for your own tests, auth, database, or deployment.
- A claim that "following the standard guarantees success". It is a process example.

---

Part of [AI Dev Standard](../../README.md) · [中文](../../README.zh.md)
