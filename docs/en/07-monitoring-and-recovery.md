# 06 · Monitoring, auto-recovery, and cleanup

> This chapter is not for an ops team. It is for "one person + a few AI tools".
> The goal is not enterprise observability. It is: **know before your users do, and be able to go back.**

## 1. Why a beginner needs monitoring

Users do not report "the API returns 502". They simply:

- stop opening your app;
- ask in a group chat "is it down?";
- or uninstall it.

Monitoring means **you know before they do**. Keep it to four questions:

| Question | Answer with |
|---|---|
| Is it alive? | `/health` + an external uptime monitor |
| Which version is live? | `/version` + the release note |
| Does the core path work? | one smoke script / synthetic check |
| Where do I look when it breaks? | structured logs + error alerts |

## 2. Minimum monitoring: four questions, four actions

### 2.1 `/health`: alive

Return 200 and a tiny JSON body:

```json
{ "status": "ok" }
```

Do not query the database or call third parties here; a dependency hiccup would turn everything red. If you need dependency checks, add `/ready`.

### 2.2 `/version`: which release

Return the current `VERSION`:

```json
{ "version": "R20261106.01" }
```

After a deploy, compare it with the `VERSION` file first.

### 2.3 Smoke: does the core path work

One script, 3–5 checks:

- `/health` returns 200
- `/version` matches `VERSION`
- login returns a token
- one core read endpoint returns 200
- home/login page returns 200

Template: [`../../templates/healthcheck.sh`](../../templates/healthcheck.sh).

### 2.4 Alerts: who tells you

Minimum:

- an external uptime service (UptimeRobot / Better Stack / Cloudflare, etc.) hitting `/health` every 1–5 minutes;
- an error alert (Sentry free tier / email / chat webhook);
- every alert includes: **time, URL, status code, current version**.

> Logs without alerts are not monitoring.

## 3. What we learned from a real multi-surface project

> A post-mortem from a real project. No business details.

### 3.1 What it did right (borrow these)

| Practice | Why it matters |
|---|---|
| `/api/health` endpoint | one signal for deploy checks, monitoring, and load balancers |
| fixed post-deploy verification script | not "the page opens", but item-by-item checks |
| online smoke (login/auth/core read/public entry) | catches "health is green but the business is down" |
| backup before deploy + rollback script | roll back first, diagnose second |
| systemd-managed process | restarts on crash; more reliable than `nohup` |
| versioned directories/ports | old and new versions coexist; switch the entry point |
| public-entry URL checks | catches Nginx changes that break login/signup |

### 3.2 What it did wrong (do not copy)

| Problem | Consequence | Our fix |
|---|---|---|
| Verification failure only printed a warning and continued | production 502 while the log said "done" | verification failure = release failure; stop |
| health checks but no metrics/alerts | users noticed first | external uptime + error alerts |
| rollback had one `prev` level | two releases in a row and there is no way back | keep the last 3 versions + tags |
| no runbook | incidents depended on memory | one page: alert → check → restart/rollback → record |
| releases needed manual `export` | another machine failed | config from env vars, validated at startup |
| secrets in the repo | leaks are hard to contain | secrets out of Git; rotate on leak |
| no auto-recovery | a 3 a.m. crash waited for a human | start with crash restart, not auto-rollback |

### 3.3 Conclusion

**Fix "verification must block" and "alerts" first. Auto-recovery comes last, not first.**

## 4. Roll it out in stages

| Stage | Time | What | Done when |
|---|---|---|---|
| **L0 alive** | 30 min | `/health`, `/version`, external uptime | you get an alert within 5 minutes of a failure |
| **L1 verified** | half a day | smoke script, post-deploy check, logs | a deploy can automatically say success/failure |
| **L2 diagnosable** | 1–2 days | error alerts, request IDs, key metrics | you can locate the failing endpoint within 10 minutes |
| **L3 self-healing** | later | crash restart, health-based restart, conditional rollback | common failures need no human |

Beginners: do L0 + L1 first. Add L2 slowly. Do not do L3 without the first two.

## 5. Auto-recovery: levels, not "auto-rollback on day one"

| Level | Action | Safety | Recommendation |
|---|---|---|---|
| **A0** | process crash → systemd/Docker restart | high | on by default |
| **A1** | `/health` fails repeatedly → restart once with backoff | medium-high | optional, cap attempts |
| **A2** | repeated failure → alert, change nothing | high | on by default |
| **A3** | repeated failure + new release → auto-rollback | medium | off by default, with guardrails |
| **A4** | auto-change data/DNS/secrets/scaling | low | do not do it |

### Guardrails for A3 auto-rollback (all required)

1. Roll back only to the **last verified** version.
2. The artifact still exists and has a backup.
3. Three consecutive health-check failures, ≥30 seconds apart.
4. No incomplete database migration from this release.
5. At most one rollback per hour.
6. Write an incident record and send an alert.
7. `AUTO_ROLLBACK=0` by default; turn it on explicitly.

> Auto-rollback is a tourniquet, not a fix. After it, release a new version with the root-cause fix.

## 6. A minimum viable monitoring stack (beginner)

```bash
# 1) post-deploy check (copy the template, then run)
cp docs/standards/templates/healthcheck.sh scripts/healthcheck.sh
bash scripts/healthcheck.sh https://<your-domain>

# 2) external uptime (push notification to your phone)
#    URL: https://<your-domain>/health
#    interval: 1–5 minutes

# 3) error alerts (Sentry free / email / chat webhook)
#    include version, URL, status code

# 4) process supervision: systemd or Docker restart policy
#    templates: templates/systemd-service.txt / templates/docker-healthcheck.yml
```

### Minimal systemd restart config

```ini
[Service]
Restart=always
RestartSec=5
StartLimitIntervalSec=300
StartLimitBurst=5
```

> `Restart=always` handles "the process died". It cannot handle "the process is alive but returns 500". That is what health checks and alerts are for.

## 7. Incident runbook (one page)

```
Alert
  ↓
1. Check /health and /version: dead, or new release broken?
  ↓
2. Check the last 30 minutes of logs: any new ERROR/stack trace?
  ↓
3. Are users affected?
   ├─ yes → roll back to the last verified version
   └─ no  → disable the feature flag / rate limit
  ↓
4. After rollback, verify /health, /version, core path
  ↓
5. Write an incident record within 24h: symptom/impact/root cause/prevention
```

**Roll back first, diagnose second. Do not debug while users are down.**

## 8. Scheduled cleanup: automatic junk removal

### 8.1 Why

Over time projects accumulate:

- build output (`dist/`, `build/`, `target/`);
- logs, temp files, OS junk (`.DS_Store`);
- test reports and caches;
- merged branches nobody deleted.

Consequences: full disk, slow clones, larger backups, AI drowning in noise.

### 8.2 Safety boundaries (important)

**Automatic cleanup may remove**:

- build output not tracked by Git;
- logs, temp files, OS junk;
- test reports/caches;
- local merged branches (only with `--branches`).

**Never removed automatically**:

- files tracked by Git (the script checks and skips them);
- `src/`, `docs/`, `VERSION`, release notes, tags, `.git/`;
- secrets (a leak requires **rotation**, not deletion).

### 8.3 Usage

```bash
# dry run (default; deletes nothing)
bash docs/standards/scripts/cleanup.sh

# move to .trash/<timestamp>/ (7-day recycle bin)
bash docs/standards/scripts/cleanup.sh --apply

# for a timer: no prompt
bash docs/standards/scripts/cleanup.sh --apply --yes --purge

# delete .trash entries older than 7 days
bash docs/standards/scripts/cleanup.sh --purge

# delete local merged branches
bash docs/standards/scripts/cleanup.sh --branches

# print a weekly cron line
bash docs/standards/scripts/cleanup.sh --schedule
```

### 8.4 Weekly automatic cleanup

`--schedule` prints a cron line:

```
0 3 * * 1 cd "/your-project" && bash "<absolute path to cleanup.sh>" --apply --yes --purge
```

- macOS/Linux: paste into `crontab -e`;
- no cron? copy the `--schedule` output to AI and say "install this as a weekly task";
- Windows: Task Scheduler → weekly → run `bash docs/standards/scripts/cleanup.sh --apply --yes --purge`.

> The script does not modify your system's scheduled tasks. It only prints a line; install it after you confirm. Deleting things should never silently change your machine.

> Run `bash docs/standards/scripts/cleanup.sh` manually once before enabling the timer; confirm nothing you need is on the list.

### 8.5 Prompt for AI

> Follow "scheduled cleanup" in `docs/en/07-monitoring-and-recovery.md`:
> run `bash docs/standards/scripts/cleanup.sh` and show me what would be removed;
> wait for my confirmation, then `--apply`;
> then install a weekly cleanup (tell me what it will delete; never delete source/docs/release notes).

## 9. Beginner checklist

- [ ] `/health` and `/version` are reachable
- [ ] external uptime is configured; your phone gets alerts
- [ ] error alerts are configured (email/chat at minimum)
- [ ] the process restarts on crash (systemd/Docker)
- [ ] backup before release; the rollback command works
- [ ] weekly cleanup is enabled (dry-run first)
- [ ] a one-page runbook: alert → check → rollback → record

## 10. One sentence

**Monitoring is not "more dashboards". It is "knowing before your users do".**
Auto-recovery is not "let AI do whatever". It is "bring the most common crash back, in the most conservative way".

---

**Previous:** [05 · Adoption](06-adoption.md) · **Back to:** [README](../../README.md)
