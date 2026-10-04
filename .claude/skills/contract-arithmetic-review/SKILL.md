---
name: contract-arithmetic-review
description: Read a contract's value math for rounding, truncation, or unit mistakes that let balances or shares be computed wrongly.
---

# Contract arithmetic review

Plain name: Contract arithmetic review. One thing, one skill. Work one contract at a time, from the
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

## 2. Read every value computation
Examine share/price/fee/interest math: division-before-multiplication, rounding
direction, decimal/unit mismatches, unchecked blocks, and casts that can truncate.

## 3. Record exploitable mistakes
A rounding or unit error that lets a caller gain value or drain others is the
finding. Show the expression and a worked number.

## Record → `checks/$SCOPE/arithmetic.md`
Write one entry per item checked: what was examined, what was observed, and an
evidence path under `$ENG/evidence/`. For anything safe, write "ruled out" with the
reason so a later pass does not re-walk it. For anything confirmed, capture the
proof and leave it for the operator — do not draft or submit here.

## Tick the box
Only after `arithmetic.md` accounts for every item in scope for this contract (confirmed
or ruled out), tick the `Contract arithmetic review` box for this contract in `$ENG/00_ledger.md`.

## Example of good output — `arithmetic.md`

```markdown
### AcmeVault — arithmetic — CONFIRMED
withdraw() computes shares with division before multiplication; a small deposit
rounds the first depositor's shares so a later caller can claim their balance.
Worked example included. Evidence: $ENG/checks/0xAcmeVault/arithmetic.md
```
