---
name: source-crypto-review
description: Read how a codebase uses cryptography and randomness, and look for weak choices or misuse.
---

# Cryptography usage review

Plain name: Cryptography usage review. One thing, one skill. Work one repo at a time, from the
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

## 2. Find crypto and randomness usage
Locate hashing, encryption, signing, token generation, and random-value usage. Note
algorithms, modes, key handling, IV/nonce handling, and the RNG used for security
values.

## 3. Flag weak or misused constructs
Record: predictable randomness for tokens, ECB/static IV, unauthenticated
encryption, home-grown crypto, hardcoded keys, weak hashes for passwords. Quote
file:line.

## Record → `checks/$SCOPE/crypto_review.md`
Write one entry per item checked: what was examined, what was observed, and an
evidence path under `$ENG/evidence/`. For anything safe, write "ruled out" with the
reason so a later pass does not re-walk it. For anything confirmed, capture the
proof and leave it for the operator — do not draft or submit here.

## Tick the box
Only after `crypto_review.md` accounts for every item in scope for this repo (confirmed
or ruled out), tick the `Cryptography usage review` box for this repo in `$ENG/00_ledger.md`.

## Example of good output — `crypto_review.md`

```markdown
### acme-api — crypto review — CONFIRMED
auth/token.go uses math/rand (not crypto/rand) for password-reset tokens → guessable.
pkg/crypt uses AES-ECB for stored PII. file:line quoted.
Evidence: $ENG/checks/acme-api/crypto_review.md
```
