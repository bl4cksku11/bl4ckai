---
name: contract-external-call-order-review
description: Check whether a contract calls out to another contract before it finishes updating its own state, so the call can re-enter and act on stale state.
---

# External-call ordering review

Plain name: External-call ordering review. One thing, one skill. Work one contract at a time, from the
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

## 2. Find external calls and the state around them
For every call to another address (token transfer, callback, low-level call), read
whether the contract updates its own balances/flags BEFORE or AFTER the call, and
whether a guard is present.

## 3. Record stale-state windows
A state update that happens after an external call, with no guard, is the finding.
Trace the re-entry path and the state it would act on.

## Record → `checks/$SCOPE/call_order.md`
Write one entry per item checked: what was examined, what was observed, and an
evidence path under `$ENG/evidence/`. For anything safe, write "ruled out" with the
reason so a later pass does not re-walk it. For anything confirmed, capture the
proof and leave it for the operator — do not draft or submit here.

## Tick the box
Only after `call_order.md` accounts for every item in scope for this contract (confirmed
or ruled out), tick the `External-call ordering review` box for this contract in `$ENG/00_ledger.md`.

## Example of good output — `call_order.md`

```markdown
### AcmeVault — call ordering — CONFIRMED
withdraw() sends ETH before zeroing the balance and has no guard; the receive hook
can re-enter withdraw() against the old balance. Path traced.
Evidence: $ENG/checks/0xAcmeVault/call_order.md
```
