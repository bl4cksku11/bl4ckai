---
name: source-secret-scan
description: Scan a repository and its history for committed keys, tokens, and credentials.
---

# Repository secret scan

Plain name: Repository secret scan. One thing, one skill. Work one repo at a time, from the
plan in `02_strategy.md`. Stay in scope. This skill observes and records only — it
never drafts, submits, or contacts anyone. A confirmed result flows to `dedup-check`
→ `finding-draft`; the operator validates and submits.

## 1. Set up paths, then read any configured reference notes

```bash
: "${BL4CKAI_HOME:?set it to the harness repo root, e.g. export BL4CKAI_HOME=~/bl4ckai}"
[ -f "$BL4CKAI_HOME/config.sh" ] && . "$BL4CKAI_HOME/config.sh"
: "${ENGAGEMENTS_ROOT:=$BL4CKAI_HOME/engagements}"
TARGET=acme
LETTER=$(printf %s "$TARGET" | cut -c1 | tr '[:lower:]' '[:upper:]')
ENG="$ENGAGEMENTS_ROOT/$LETTER/$TARGET"
SCOPE=acme-api        # repo or module name under src/
OUT="$ENG/checks/$SCOPE"; mkdir -p "$OUT"
[ -n "${KB_ROOT:-}" ] && echo "KB_ROOT set — read your notes relevant to this area under $KB_ROOT first." \
  || echo "No reference library configured; use the method below + public references."
```

## 2. Scan tree and history
Run a secret scanner over the working tree AND the full git history (secrets are
often removed from HEAD but remain in old commits). Record each hit: file, commit,
kind, and whether it looks active.

## 3. Hand active-looking secrets to the operator
Do not test a found credential against a live service. Note validity signals only.

## Record → `checks/$SCOPE/secret_scan.md`
Write one entry per item checked: what was examined, what was observed, and an
evidence path under `$ENG/evidence/`. For anything safe, write "ruled out" with the
reason so a later pass does not re-walk it. For anything confirmed, capture the
proof and leave it for the operator — do not draft or submit here.

## Tick the box
Only after `secret_scan.md` accounts for every item in scope for this repo (confirmed
or ruled out), tick the `Repository secret scan` box for this repo in `$ENG/00_ledger.md`.

## Example of good output — `secret_scan.md`

```markdown
### acme-api — secret scan — CONFIRMED (in history)
Commit 9f8e (removed in HEAD) added config/prod.env with an AWS key + DB password.
A Slack webhook is live in HEAD. Not exercised. Handed to operator.
Evidence: $ENG/checks/acme-api/secret_scan.md
```
