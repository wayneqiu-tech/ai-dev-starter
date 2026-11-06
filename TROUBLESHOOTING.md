# Troubleshooting (Beginner Edition)

> Principle: **stop first, ask second, do not click around.**
> Most "it looks broken" situations can be rolled back; the dangerous move is to keep changing things in a panic.

---

## 1. The AI says "no Git" or "git is not a command"

**You see**:

```text
git: command not found
```

**Say to the AI**:

> I am a beginner and my computer does not have Git. Teach me the simplest way to install it (macOS / Windows), step by step. Check it after I install it.

**Do not**: download random "Git installers" from search results.

---

## 2. The AI says "I do not have permission to run commands"

**Why**: you may be using a web chat, or the tool has no terminal/agent permission.

**Say to the AI**:

> Can you run terminal commands? If not, list the commands I need to run, in order, and tell me what I should see after each one.

**Do not**: let it pretend to run commands and invent the output.

---

## 3. `preflight` fails (red FAIL)

**You see**: a wall of English ending in `FAILED`.

**Say to the AI**:

> Here is the full `preflight` output. Explain it line by line in plain language. Change only what is necessary; do not touch unrelated files.
> Run it again after the fix and paste the result.
>
> ```text
> <paste the full output here>
> ```

**Do not**: delete checks, edit the script, or skip tests just to make it green.

---

## 4. Merge conflict

**You see**: `CONFLICT`, `merge conflict`, or the AI says "there is a conflict".

**Say to the AI**:

> There is a merge conflict. Do not delete anything yet.
> Explain in plain language: which two versions conflict, and what each one wants.
> Then give me 2 options, ordered from lowest to highest risk. Do not execute until I choose.

**Do not**: choose "use mine for everything" or "use theirs for everything" unless you are sure the other side is not needed.

---

## 5. The page is down / API returns 502 after release

**First**: roll back; do not debug in production.

**Say to the AI**:

> The release broke something. Roll back to the last verified version first, then investigate.
> Roll back code only; do not touch data. Tell me which version we rolled back to and how to verify recovery.

**Do not**: edit code/config on the server and restart it in place.

---

## 6. I cannot find the project / do not know which folder I am in

**Say to the AI**:

> I do not know which directory I am in. Tell me: current directory, whether this is a Git repo, current branch, and the last commit.
> If this is not my project directory, tell me where to `cd`.

**Do not**: run delete/reset commands in an unknown directory.

---

## 7. I forgot the release note

**Say to the AI**:

> This release has no release note yet. Draft `docs/releases/<VERSION>.md` from the recent commits and test results:
> what changed, how it was verified, how to roll back, and what the risks are.
> Show it to me first; commit only after I confirm.

**Do not**: write empty lines like "fixed several issues" or "improved the experience".

---

## 8. A secret was committed

**Order matters**: rotate first, clean second.

**Say to the AI**:

> I may have committed a secret. Do not delete files yet.
> First tell me how to rotate/revoke the key; second, how to clean the Git history; third, how to prevent it from happening again.

**Do not**: delete the file and assume you are safe — it is still in history.

---

## 9. The AI changed files it should not have

**Say to the AI**:

> Stop. Do not change anything else.
> List every file in this change and mark which ones are outside the task scope.
> Revert the out-of-scope changes, keep only the task changes, then rerun the tests.

**Do not**: "undo everything"; you may undo the work you wanted.

---

## 10. I do not know which version is live

**Say to the AI**:

> Tell me: what is in `VERSION`, what is the latest tag, and what does the live `/version` return?
> If the three disagree, tell me which one is authoritative and how to fix it.

**Do not**: use "latest" or "final" instead of a version number.

---

## 11. The AI says "done" but shows no evidence

**Say to the AI**:

> Do not just say "done". Follow `AGENTS.md` and give me four pieces of evidence:
> 1) files changed; 2) why; 3) commands run and their output; 4) what you did not do / known limits.

**Do not**: believe it just because it sounds confident.

---

## 12. I want to start over

**Say to the AI**:

> I want a clean state, but I do not want to lose code.
> First tell me: current branch, uncommitted changes, and the last 3 commits.
> Give me a plan to "keep the code and return to main"; do not execute until I confirm.

**Do not**: run `git reset --hard` or delete folders directly.

---

## 13. Disk is full / the project keeps growing

**Say to the AI**:

> Do not delete anything yet. Follow the "periodic cleanup" section of `docs/en/07-monitoring-and-recovery.md`:
> run `bash docs/standards/scripts/cleanup.sh` and show me what it would remove and how much space it would free.
> After I confirm, run `--apply` (move to a 7-day trash; do not delete permanently).

**Do not**: run `rm -rf` on directories you do not recognize; do not delete `src/`, `docs/`, release notes, or tags.

---

## Last rule

If you do not understand the AI's explanation, say:

> Explain it again as if I were 10 years old. No jargon.

You have the right to understand. Not understanding is not your fault; it is the explanation's fault.
