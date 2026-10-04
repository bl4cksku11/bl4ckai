---
name: contract-access-control-review
description: Read which contract functions change ownership, funds, or critical settings, and whether each restricts who may call it.
---

# Contract access-control review

Plain name: Contract access-control review. One thing, one skill. Work one contract at a time, from the
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
SCOPE=0xAcmeVault        # contract name or address in scope
OUT="$ENG/checks/$SCOPE"; mkdir -p "$OUT"
[ -n "${KB_ROOT:-}" ] && echo "KB_ROOT set — read your notes relevant to this area under $KB_ROOT first." \
  || echo "No reference library configured; use the method below + public references."
```

## 2. Match sensitive functions to their guards
For every function that moves value, changes ownership/roles, or alters critical
parameters, read whether it has the right modifier/check, and whether initializers
can be called more than once or front-run.

## 3. Record the gaps
A sensitive function missing its guard, or a role check on the wrong address, is the
finding. Quote the function and line.

## Record → `checks/$SCOPE/access_control.md`
Write one entry per item checked: what was examined, what was observed, and an
evidence path under `$ENG/evidence/`. For anything safe, write "ruled out" with the
reason so a later pass does not re-walk it. For anything confirmed, capture the
proof and leave it for the operator — do not draft or submit here.

## Tick the box
Only after `access_control.md` accounts for every item in scope for this contract (confirmed
or ruled out), tick the `Contract access-control review` box for this contract in `$ENG/00_ledger.md`.

## Example of good output — `access_control.md`

```markdown
### AcmeVault — access control — CONFIRMED
setFeeRecipient() lacks onlyOwner (siblings have it) → anyone can redirect fees.
initialize() is not guarded against a second call. Lines quoted.
Evidence: $ENG/checks/0xAcmeVault/access_control.md
```
