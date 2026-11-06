# Security Policy

## Supported versions

| Version | Status |
|---|---|
| `0.9.x` | public beta, supported |
| `< 0.9` | not released |

This project is a **baseline / starter kit** (docs, templates, scripts). It does
not run your production service. Security reports about the scripts and
templates are still welcome.

## Reporting a vulnerability

**Please do not open a public issue with exploit details or secrets.**

1. Use GitHub's private vulnerability reporting:
   **Security → Report a vulnerability** on this repository.
2. If that is unavailable, open a minimal public issue asking for a private
   channel. Do not include the details, keys, tokens, or personal data.
3. Include:
   - affected version (`VERSION`) and file/script
   - impact (what an attacker could do)
   - minimal reproduction
   - suggested fix, if you have one

## What to expect

- Acknowledgement within **7 days**.
- Triage within **14 days**.
- Fix target depends on severity; there is no bug bounty.
- Credit in the release note if you want it.

## Scope

In scope:

- `scripts/preflight.sh` (secret/large-file checks, false negatives)
- `scripts/cleanup.sh` (deleting something it should not)
- `scripts/init-project.sh` (overwriting files, unsafe paths)
- templates that could cause a secret leak or destructive command

Out of scope:

- vulnerabilities in your own application
- misconfiguration of your server/cloud
- social engineering
- denial of service against this GitHub repository

## Safe harbor

We support good-faith security research. Do not access other people's data,
do not run destructive tests against systems you do not own, and give us a
reasonable window to fix before publishing details.

## 中文摘要

- 支持版本：`0.9.x` 公测。
- 报漏洞：用 GitHub 的 **Security → Report a vulnerability**，不要公开贴细节/密钥。
- 7 天内确认，14 天内分级；没有赏金。
- 范围：`preflight.sh`、`cleanup.sh`、`init-project.sh` 和模板；
  不管你自己的业务代码或服务器配置。
- 善意研究可以，但不要碰别人的数据、不要做破坏性测试。
