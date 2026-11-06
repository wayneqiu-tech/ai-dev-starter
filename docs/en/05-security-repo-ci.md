# 04 · Security, repo, CI

> Three concerns: **don't leak secrets, don't turn the repo into a dump, don't rely on memory for checks.**

## 1. Secrets: not in the repo

### 1.1 What counts as a secret

- API keys, access tokens, OAuth secrets
- Database passwords, JWT signing keys
- SSH private keys, certificate private keys
- Cloud credentials (AK/SK)
- Payment, SMS, email, messaging platform secrets
- Anything that lets someone impersonate you or spend your money

### 1.2 Rules

| Rule | Detail |
|---|---|
| Not in Git | `.env`, `*.pem`, `*.key`, `id_rsa`, CI secrets |
| Not in the frontend | only public config; secrets stay server-side |
| Not in logs | secrets in logs/errors/screenshots are treated as a leak |
| Not in examples | `.env.example` uses `<change-me>` only |
| Least privilege | one key per service; only the permissions it needs |
| Rotatable | rotating a key does not require code changes |
| Per environment | local/test/prod use different keys; local keys have quotas |
| Rotate regularly | at least every 6 months; immediately on suspicion |

### 1.3 Keep only a template in the repo

```env
# .env.example
DATABASE_URL=postgres://user:<change-me>@localhost:5432/app
API_KEY=<change-me>
APP_ENV=local
```

First lines of `.gitignore`:

```gitignore
.env
.env.*
!.env.example
*.pem
*.key
```

### 1.4 If a secret leaked (30-minute response)

**Order matters: rotate first, clean second.**

1. **Rotate/revoke the key.** Deleting the file without rotating changes nothing; it is still in history.
2. Check access logs: was it used? What was affected?
3. Clean history: `git filter-repo` or BFG; tell collaborators to re-clone.
4. Add secret scanning to CI; write an incident record.
5. If user data is involved, notify per regulations/platform rules.

> If a secret ever entered Git history, assume it is compromised. Don't gamble.

## 2. Repo hygiene: it is not a file dump

### 2.1 Never commit

```
node_modules/   dist/   build/   target/   out/   coverage/
.env   .env.*   *.pem   *.key   id_rsa*
*.log   logs/   *.sqlite   *.db
*.zip   *.tar.gz   *.dmg   *.exe   *.apk
test-results/   playwright-report/   .vite/   .cache/
.DS_Store   Thumbs.db
```

Already committed?

```bash
git rm -r --cached <path>
# add .gitignore, commit
```

For secrets, also **rotate** (§1.4).

### 2.2 Large files and binaries

- File >5 MB: explain in the PR.
- File >20 MB: Git LFS or Release attachment.
- Images: compress, put in `docs/assets/`, name `<date>-<topic>.png`, one image per use.
- Screen recordings/video: external link or Release, not the repo.
- Once a month, list the largest tracked files:

```bash
git ls-files -z | xargs -0 du -h | sort -rh | head -10
```

### 2.3 Root directory whitelist

```
src/  tests/  docs/  scripts/  config/  public/  .github/  .git/
README.md  AGENTS.md  VERSION  CHANGELOG.md  LICENSE  .gitignore  package.json
```

Before adding a root directory, answer: **why can't this live in an existing one?**

Anti-patterns: `new/`, `final/`, `backup/`, `v2/`, `20261106/`, `untitled folder/`.

### 2.4 Archive and delete

- Use tags for old versions, not `archive/` directories.
- If you truly need an archive: `archive/<date>-<reason>/` with:
  - `README.md`: why, owner, expiry
  - a file list + sha256
  - what happens at expiry
- Keep for 30 days by default; expiry must be processed, not renewed forever.
- Before deleting: no references, tag/backup exists, not used in production.
- Destructive scripts: dry-run by default; execution needs `--yes`, prints the impact list, and backs up first.

### 2.5 README minimum

A stranger (or an AI) can learn from README alone:

1. What this is, who it is for.
2. How to install and run (≤3 commands).
3. How to configure (point to `.env.example`).
4. How to release (point to the standard/script).
5. Where the docs are (a docs table).
6. The license.

## 3. CI: automate what can be checked

### 3.1 Minimum gates

| # | Check | Required | Notes |
|---|---|---|---|
| 1 | Install with lockfile | ✅ | `npm ci` / `pip install -r` |
| 2 | Lint/format | Recommended | skip if absent; don't spend a week configuring |
| 3 | Unit tests | ✅ | no tests? add 3 core cases first |
| 4 | Build | ✅ | no build, no release |
| 5 | Standard self-check (`preflight --ci`) | ✅ | version, tag, note, big files, secrets |
| 6 | Secret scan | ✅ | prevents leaks |
| 7 | Smoke (start + health) | Recommended | if there is a server |
| 8 | Dependency audit | Recommended | monthly, not necessarily every push |

### 3.2 GitHub Actions example

```yaml
name: ci
on:
  push:
    branches: [main]
  pull_request:

jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0        # preflight needs tag history
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: npm
      - run: npm ci
      - run: npm run lint --if-present
      - run: npm test --if-present
      - run: npm run build --if-present
      - name: Standard self-check
        run: bash docs/standards/scripts/preflight.sh --ci
```

Not on GitHub? GitLab CI, Gitee Go, or a local `pre-commit` hook can run the same commands. The key is **local and CI run the same command**.

### 3.3 When it fails

- Fix it. Never release using "it was green last time".
- Flaky tests: isolate and fix within a week; no permanent `skip`.
- CI failure that is genuinely environmental: note it in the release note and run the equivalent command manually.
- Loosening a gate requires a PR + a recorded reason.

### 3.4 Branch protection (recommended)

- `main`: no direct push, no force push.
- CI must pass before merge.
- At least 1 approval (solo projects can use "PR + self-check list").
- Delete branches after merge.

## 4. Dependencies and supply chain

- Commit lockfiles; CI uses `npm ci` / `pip install -r`, not "latest".
- New dependency: check license, size, maintenance, known vulnerabilities.
- Upgrade separately, with "why and impact" in the commit.
- High-severity vulnerabilities: fix within a deadline; if you can't, list it under "risks" in the release note.
- Don't install unknown packages/scripts; read install scripts before running.

## 5. Servers and permissions

- Deploy with a **dedicated account + SSH key**; no root for daily work, no password login.
- Verify host fingerprints on first connect; never use `StrictHostKeyChecking=no`.
- Production ports listen on `127.0.0.1` only; expose through a reverse proxy/gateway.
- Databases are not public; only the app network can reach them.
- Firewall denies by default; open only what is needed.
- All production changes go through one pipeline with logs; manual changes are incidents.

## 6. Backup and restore

- Stateful systems (DB, uploads) must be backed up before a release.
- A backup is only a backup if it restores: restore into a temp directory monthly and confirm it starts.
- Backups carry timestamp + version + sha256.
- Define RPO/RTO: how much data can you lose, how fast must you recover?
- Retention: at least 14 days; archive important versions separately.

## 7. One-page checklist

### Before commit

- [ ] No `.env` / secrets / large files
- [ ] `git ls-files | grep -E '\.env$|\.pem$|\.key$'` is empty
- [ ] New config is in `.env.example`

### Before release

- [ ] Secrets/config list complete
- [ ] Backup done; restore drilled
- [ ] Rollback command works
- [ ] Production accepts only artifacts built from the repo

### Monthly

- [ ] Largest tracked files Top 10
- [ ] Dependency vulnerabilities
- [ ] Key rotation due dates
- [ ] Backup restore drill

---

**Next:** [05 · Adoption →](06-adoption.md)
