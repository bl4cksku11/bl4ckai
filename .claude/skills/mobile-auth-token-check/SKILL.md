---
name: mobile-auth-token-check
description: Review how a mobile application obtains, stores, and refreshes its session, and whether a changed or reused token is still accepted.
---

# Mobile session handling

Plain name: Mobile session handling. One thing, one skill. Work one app at a time, from the
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
SCOPE=com.acme.app        # package / bundle id of the in-scope app
OUT="$ENG/checks/$SCOPE"; mkdir -p "$OUT"
GATE="$BL4CKAI_HOME/.claude/skills/scope-gate/scope_check.sh"
REQ="$BL4CKAI_HOME/.claude/skills/scope-gate/req.sh"
bash "$GATE" "$SCOPE" || exit 0   # REQUIRED before any request; send live requests via "$REQ"
[ -n "${KB_ROOT:-}" ] && echo "KB_ROOT set — read your notes relevant to this area under $KB_ROOT first." \
  || echo "No reference library configured; use the method below + public references."
```

## 2. Trace the session lifecycle
From captured traffic + storage, record how the app logs in, where it keeps the
session, how it refreshes, and whether logout truly invalidates server-side.

## 3. Probe acceptance of altered/reused sessions (own accounts)
With the operator's own accounts, test whether an expired, modified, or another-
account token is accepted by the backend. Prove acceptance with one request; stop.

## Record → `checks/$SCOPE/auth_token.md`
Write one entry per item checked: what was examined, what was observed, and an
evidence path under `$ENG/evidence/`. For anything safe, write "ruled out" with the
reason so a later pass does not re-walk it. For anything confirmed, capture the
proof and leave it for the operator — do not draft or submit here.

## Tick the box
Only after `auth_token.md` accounts for every item in scope for this app (confirmed
or ruled out), tick the `Mobile session handling` box for this app in `$ENG/00_ledger.md`.

## Example of good output — `auth_token.md`

```markdown
### com.acme.app — session — CONFIRMED (no server-side logout)
JWT access token valid 24h; refresh token never rotated; logout only clears local
storage — the old token keeps working after logout. Own accounts.
Evidence: $ENG/evidence/acme-token-postlogout.txt
```
