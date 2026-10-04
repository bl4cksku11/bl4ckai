---
name: contract-upgrade-review
description: Read a contract's upgrade or proxy mechanism for ways it can be hijacked or can corrupt its own storage.
---

# Upgrade/proxy review

Plain name: Upgrade/proxy review. One thing, one skill. Work one contract at a time, from the
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

## 2. Read the upgrade mechanism
Identify the proxy pattern, who may upgrade, the initializer, and the storage layout.
Check for unprotected upgrade authority, uninitialized proxies, storage-layout
clashes between versions, and selector collisions.

## 3. Record the weakness
An upgrade path callable by the wrong party, or a layout change that corrupts state,
is the finding. Quote the relevant slots/functions.

## Record → `checks/$SCOPE/upgrade_review.md`
Write one entry per item checked: what was examined, what was observed, and an
evidence path under `$ENG/evidence/`. For anything safe, write "ruled out" with the
reason so a later pass does not re-walk it. For anything confirmed, capture the
proof and leave it for the operator — do not draft or submit here.

## Tick the box
Only after `upgrade_review.md` accounts for every item in scope for this contract (confirmed
or ruled out), tick the `Upgrade/proxy review` box for this contract in `$ENG/00_ledger.md`.

## Example of good output — `upgrade_review.md`

```markdown
### AcmeVault — upgrade — CONFIRMED
The UUPS implementation's initialize() is unguarded and the impl is uninitialized →
anyone can become owner of the implementation and brick upgrades. Slots quoted.
Evidence: $ENG/checks/0xAcmeVault/upgrade_review.md
```
