---
name: api-auth-token-check
description: Review how an API forms, signs, and validates its session tokens or keys, and whether a changed token is still accepted.
---

# API token handling

Plain name: API token handling. One thing, one skill. Work one service at a time, from the
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
SCOPE=api.acme.com        # API host or service name
OUT="$ENG/checks/$SCOPE"; mkdir -p "$OUT"
[ -n "${KB_ROOT:-}" ] && echo "KB_ROOT set — read your notes relevant to this area under $KB_ROOT first." \
  || echo "No reference library configured; use the method below + public references."
```

## 2. Decode and probe the token
Decode self-describing tokens (note algorithm, claims, expiry, audience). Probe the
documented weaknesses one change at a time: algorithm none/confusion, unverified
signature, missing expiry, wrong-audience acceptance, weak signing secret, API keys
with no scope.

## 3. Record what the server wrongly accepted
Prove acceptance of a token that should be rejected with one request; stop there.

## Record → `checks/$SCOPE/auth_token.md`
Write one entry per item checked: what was examined, what was observed, and an
evidence path under `$ENG/evidence/`. For anything safe, write "ruled out" with the
reason so a later pass does not re-walk it. For anything confirmed, capture the
proof and leave it for the operator — do not draft or submit here.

## Tick the box
Only after `auth_token.md` accounts for every item in scope for this service (confirmed
or ruled out), tick the `API token handling` box for this service in `$ENG/00_ledger.md`.

## Example of good output — `auth_token.md`

```markdown
### api.acme.com — token — CONFIRMED (alg=none)
Access JWT re-signed with alg=none and no signature is accepted on GET /v3/me.
Own account. Evidence: $ENG/evidence/api-jwt-none.txt
```
