---
name: api-mass-assignment-check
description: Check whether an API write accepts fields the client should not be able to set, letting a caller change protected attributes.
---

# Mass-assignment check

Plain name: Mass-assignment check. One thing, one skill. Work one service at a time, from the
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

## 2. Compare the model to what the write accepts
For create/update operations, compare the documented fields to the underlying model
(from schema/source if available). Add protected-looking fields (role, is_admin,
balance, owner_id, verified) to the body with the operator's own account.

## 3. Record accepted protected fields
Note which extra fields the server honored and the effect. One proof write; stop.

## Record → `checks/$SCOPE/mass_assignment.md`
Write one entry per item checked: what was examined, what was observed, and an
evidence path under `$ENG/evidence/`. For anything safe, write "ruled out" with the
reason so a later pass does not re-walk it. For anything confirmed, capture the
proof and leave it for the operator — do not draft or submit here.

## Tick the box
Only after `mass_assignment.md` accounts for every item in scope for this service (confirmed
or ruled out), tick the `Mass-assignment check` box for this service in `$ENG/00_ledger.md`.

## Example of good output — `mass_assignment.md`

```markdown
### PATCH /v3/users/me — CONFIRMED
Body {"role":"admin","verified":true} is honored though neither is a documented
field; account becomes admin. Own account. Evidence: $ENG/evidence/api-massassign.txt
```
