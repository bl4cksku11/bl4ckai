---
name: contract-oracle-review
description: Read how a contract gets external prices or values, and whether that source can be moved to mislead it.
---

# Contract price-source review

Plain name: Contract price-source review. One thing, one skill. Work one contract at a time, from the
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

## 2. Find the value sources
Identify where the contract reads prices/values (an AMM spot reading, a single feed,
a user-supplied value) and how it is used in value math.

## 3. Judge manipulability
A spot reading usable within one transaction, a single unchecked feed, or a stale-
price acceptance is the finding. Describe how the source would be moved and the
effect; no live funds.

## Record → `checks/$SCOPE/oracle_review.md`
Write one entry per item checked: what was examined, what was observed, and an
evidence path under `$ENG/evidence/`. For anything safe, write "ruled out" with the
reason so a later pass does not re-walk it. For anything confirmed, capture the
proof and leave it for the operator — do not draft or submit here.

## Tick the box
Only after `oracle_review.md` accounts for every item in scope for this contract (confirmed
or ruled out), tick the `Contract price-source review` box for this contract in `$ENG/00_ledger.md`.

## Example of good output — `oracle_review.md`

```markdown
### AcmeVault — price source — CONFIRMED
Collateral is valued from a DEX pair spot price read in the same tx as the borrow →
a flash-funded swap moves it. No TWAP/deviation check. Mechanism described.
Evidence: $ENG/checks/0xAcmeVault/oracle_review.md
```
