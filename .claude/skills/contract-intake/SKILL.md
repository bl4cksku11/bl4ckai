---
name: contract-intake
description: Set up a smart-contract review: get the source at a pinned version, compile it, identify the toolchain and dependencies, and map the externally callable surface.
---

# Contract intake

Plain name: Contract intake. One thing, one skill. Work one contract at a time, from the
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

## 2. Get, pin, and compile
Fetch the in-scope contract source at a named commit/tag into `$ENG/src/<name>`.
Identify the language (Solidity/Vyper) and framework (Foundry/Hardhat); compile and
record the exact versions.

## 3. Map the surface
List external/public functions, who may call each, the state they touch, external
calls they make, and the value they move. This map drives every other contract-*
skill.

## Record → `checks/$SCOPE/intake.md`
Write one entry per item checked: what was examined, what was observed, and an
evidence path under `$ENG/evidence/`. For anything safe, write "ruled out" with the
reason so a later pass does not re-walk it. For anything confirmed, capture the
proof and leave it for the operator — do not draft or submit here.

## Tick the box
Only after `intake.md` accounts for every item in scope for this contract (confirmed
or ruled out), tick the `Contract intake` box for this contract in `$ENG/00_ledger.md`.

## Example of good output — `intake.md`

```markdown
### 0xAcmeVault @ commit a1b2 — intake — MAPPED
Solidity 0.8.19, Foundry. 14 external fns; deposit/withdraw move value; 2 onlyOwner.
External calls to a price feed + a token. Feeds the review skills.
Evidence: $ENG/src/AcmeVault/
```
