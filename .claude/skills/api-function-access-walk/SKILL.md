---
name: api-function-access-walk
description: Check whether privileged API operations enforce the caller's role, by calling them as a lower-privileged or unauthenticated client.
---

# API function-access walk

Plain name: API function-access walk. One thing, one skill. Work one service at a time, from the
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
GATE="$BL4CKAI_HOME/.claude/skills/scope-gate/scope_check.sh"
REQ="$BL4CKAI_HOME/.claude/skills/scope-gate/req.sh"
bash "$GATE" "$SCOPE" || exit 0   # REQUIRED before any request; send live requests via "$REQ"
[ -n "${KB_ROOT:-}" ] && echo "KB_ROOT set — read your notes relevant to this area under $KB_ROOT first." \
  || echo "No reference library configured; use the method below + public references."
```

## 2. Call privileged operations as a low/anon client

Pull the two live sessions from `test-identity` (`A_HDR=$(bash "$BL4CKAI_HOME/.claude/skills/test-identity/identity.sh" get A)`, same for B; `anon` = no auth header) and send each request via `$REQ` with `-H "$A_HDR"`. A single identity cannot confirm an access-control finding.
For each admin/privileged operation from the map, replay it with a basic-user token
and with none. Watch for server-side enforcement vs. docs-only restriction; test
method confusion and alternate versions (/v2 vs /v3).

## 3. Record per operation
Result as basic user, result as anonymous, and the proof request. Rule out
operations that enforced correctly.

## Record → `checks/$SCOPE/function_access.md`
Write one entry per item checked: what was examined, what was observed, and an
evidence path under `$ENG/evidence/`. For anything safe, write "ruled out" with the
reason so a later pass does not re-walk it. For anything confirmed, capture the
proof and leave it for the operator — do not draft or submit here.

## Tick the box
Only after `function_access.md` accounts for every item in scope for this service (confirmed
or ruled out), tick the `API function-access walk` box for this service in `$ENG/00_ledger.md`.

## Example of good output — `function_access.md`

```markdown
### POST /v3/admin/users/{id}/role — CONFIRMED
Basic-user token can set its own role to admin; server does not re-check caller role.
Proof request captured. Own account. Evidence: $ENG/evidence/api-bfla-role.txt
```
