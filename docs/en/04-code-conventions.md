# 03 · Code conventions

> This chapter does not decide tabs vs spaces; that is a formatter's job. It defines the **non-negotiable code baseline for humans and AI**: naming, size, errors, and traps.

## 1. Why code conventions matter more with AI

AI imitates the code already in the repo.

- If the repo is full of `data1`, `tmp`, `handle2`, AI will produce `data2`.
- If empty `catch` blocks are everywhere, AI will treat "swallow errors" as the house style.
- If a function is 800 lines, AI will add 200 more inside it.

**Conventions are not for beauty. They give AI something good to imitate and humans something reviewable.**

## 2. Six baselines

### 2.1 Readability first

Code is read by humans and executed by machines.

- Names should be readable: `remainingAttempts`, not `n`.
- Avoid "clever" code: a nested ternary is worse than three `if` lines.
- No private abbreviations unless they are domain-standard (`id`, `url`, `http`).

### 2.2 Small units

- One function, one job.
- One file, one topic.
- A function over 50 lines or a file over 400 lines: consider splitting.
- More than 3 levels of nesting: flatten with early returns.

### 2.3 Explicit over implicit

- Do not rely on a global that "happens to exist".
- Do not rely on a config default that "happens to be right".
- Do not rely on "this function probably never returns null".
- Make types, parameters, and return values explicit where the language allows.

### 2.4 Errors must be loud

- Fail loudly; do not silently return `null` / `[]` / `false`.
- If you cannot handle it, throw/return an error; do not swallow it.
- Error messages carry context: operation, ID, expected value.

### 2.5 No dead code

- Delete commented-out code (Git has history).
- Delete unused functions, variables, imports.
- A `TODO` must say why, who, and when; otherwise it is litter.

### 2.6 Dependencies need a reason

- Before adding one: can the standard library do it? Size? License? Maintenance?
- Do not add a framework for a five-line feature.
- Lockfiles (`package-lock.json`, `poetry.lock`) must be committed.

## 3. Naming

| Object | Rule | Good | Bad |
|---|---|---|---|
| File | lowercase, hyphens or project convention | `user-profile.ts` | `UserProfileFinal2.ts` |
| Variable | noun, readable | `pendingOrders` | `list1`, `tmp` |
| Function | verb-first | `calculateTotal()` | `total()`, `doIt()` |
| Boolean | `is/has/can/should` | `isReady`, `hasAccess` | `flag`, `status` |
| Constant | UPPER_SNAKE (per language) | `MAX_RETRIES` | `max` |
| Class/type | noun, singular | `OrderService` | `OrderManagerHelperUtil` |

Rules:

- No transliterated words unless the whole team knows the domain term.
- No meaningless prefixes: `IUser`, `CUser`, `BaseImpl`.
- One concept, one word. Don't use `user`, `member`, and `account` for the same thing.

## 4. Functions and files

### 4.1 Functions

```js
// Good: one job, explicit error
function parsePrice(raw) {
  const value = Number(raw)
  if (!Number.isFinite(value) || value < 0) {
    throw new Error(`Invalid price: ${raw}`)
  }
  return value
}
```

```js
// Bad: parse + validate + write + notify in one place
function handlePrice(raw, db, mailer) {
  const v = Number(raw)
  db.save(v)
  mailer.send('price updated')
  return v
}
```

- More than 4 parameters → use an object.
- No boolean parameters that switch behavior (`render(true, false)` is unreadable).
- Name side effects in the function name: `saveOrder`, `sendEmail`.

### 4.2 Files

- One topic per file; the filename matches the default export.
- Import order: stdlib → third-party → local (let the formatter sort).
- Don't put three unrelated classes in one file "for convenience".

## 5. Comments

Comments explain **why**, not **what**.

```js
// Good: explains a trade-off
// Store UTC: the database keeps UTC, the UI converts to local time.
const timestamp = new Date().toISOString()
```

```js
// Bad: restates the code
// Set timestamp to an ISO string
const timestamp = new Date().toISOString()
```

Rules:

- No "author/date" comments (Git has that).
- No commented-out code.
- `TODO` format: `// TODO(2026-12-31, @name): remove the old endpoint`.
- Public APIs, complex algorithms, and non-obvious boundaries need comments.

## 6. Error handling

### 6.1 Don't swallow

```js
// Bad
try {
  await saveOrder(order)
} catch (e) {
  // ignore
}
```

```js
// Good
try {
  await saveOrder(order)
} catch (error) {
  logger.error('saveOrder failed', { orderId: order.id, error })
  throw new Error(`Failed to save order ${order.id}`, { cause: error })
}
```

### 6.2 Errors must be locatable

- Include what was attempted, which object, and what was expected.
- Never put secrets, tokens, or full user data in error messages.
- Separate user-facing errors ("Save failed, try again") from log errors (stack + ID).

### 6.3 Don't use exceptions for normal flow

- "Not found" is normal: return `null`/`undefined` and reflect it in types.
- "Invalid argument" is exceptional: throw.
- Do not wrap an entire function in `try/catch` "just in case".

## 7. Logging

- Use structured logs (JSON or key-value), not string concatenation.
- Levels: `debug` (dev), `info` (key events), `warn` (recoverable), `error` (needs a human).
- Every log carries context: request ID, user ID (masked), operation, duration.
- **Never** log: passwords, tokens, keys, full ID/phone/card numbers, sensitive personal data.

## 8. Config

- No hardcoding: ports, domains, paths, flags, secrets.
- Read from env/config files; validate required values at startup.
- Defaults may only be "local development, obviously unsafe" values, with a startup warning.
- New config must be added to `.env.example` and noted in the release note.

```js
const required = ['DATABASE_URL', 'API_KEY']
const missing = required.filter((key) => !process.env[key])
if (missing.length) {
  console.error(`Missing env: ${missing.join(', ')}`)
  process.exit(1)
}
```

## 9. Dependencies

- Before adding: can the standard library do it? Size? License? Maintained in the last year?
- Do not add a "kitchen sink" for one function.
- Commit lockfiles; upgrade dependencies in a separate `build:` commit.
- Removing a dependency is also a change; don't just delete the import.
- Watch vulnerability alerts; fix high severity within a deadline.

## 10. Tests

### 10.1 Minimum coverage

1. **Core path**: the thing users do most.
2. **Boundaries**: empty, zero, negative, very long, duplicate.
3. **Error paths**: network failure, permission denied, timeout.
4. **Regression**: every bug fix gets a test that reproduces it.

### 10.2 How to write them

- One behavior per test.
- The name says "under what condition, what is expected": `rejects negative price`.
- Unit tests do not hit real network/database; integration tests are a separate layer.
- Tests must be repeatable: no dependency on current time, randomness, or order.
- No empty tests written for coverage.

### 10.3 AI test traps

- AI may assert the current implementation instead of the requirement.
- AI may loosen assertions to make tests pass.
- AI may mock the exact thing that should be tested.
- If you see any of these, send it back.

## 11. Extra checks for AI-generated code

| Problem | Symptom | Prevention |
|---|---|---|
| **Invented API** | Calls a function/parameter that does not exist | Check official docs; run type check/tests |
| **Fake import** | `import { x } from 'some-lib'` that isn't exported | Build/test fails; don't ignore it |
| **Silent fallback** | Returns empty array/default on error | Require explicit error/log |
| **Copy-paste** | Code from an old project with old config/paths | Search for hardcoding; ask why it's needed |
| **Over-abstraction** | One feature split into 8 files | Make it work first; abstract later |
| **"Should work"** | Claims done without running | Require command + output |
| **Edited tests** | Failed assertions changed to pass | Tests are requirements, not obstacles |

## 12. What this standard does not dictate

- **Formatting**: tabs/spaces, quotes, line width → Prettier/Black/gofmt.
- **Framework choice**: React/Vue/Svelte → project/team decision.
- **Directory layout**: differs by language/framework → write it in `AGENTS.md`.
- **Naming case**: follow the language community (JS `camelCase`, Python `snake_case`).

> This standard covers "non-negotiable baseline" and "how to work with AI", not personal taste.

## 13. One-page code review checklist

- [ ] Names are readable; no `tmp` / `data1` / `doIt`
- [ ] Functions <50 lines, files <400 lines, nesting <3
- [ ] No commented-out code, no unused imports
- [ ] Errors are not swallowed; messages are locatable
- [ ] No hardcoded IPs/ports/paths/secrets
- [ ] New config is in `.env.example`
- [ ] New dependencies have a reason; lockfile updated
- [ ] Core/boundary/error paths have tests
- [ ] AI did not invent APIs or edit assertions
- [ ] I can explain how to roll this back

---

**Next:** [04 · Security, repo, CI →](05-security-repo-ci.md)
