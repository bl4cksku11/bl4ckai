---
name: api-object-reference-walk
description: Check whether one account can reach another account's records by changing the identifiers an API request carries.
---

# API object-reference walk

Plain name: API object-reference walk. One thing, one skill. Work one service at a time, from the
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

## 2. Cross-use identifiers between two owned accounts
For each id-bearing operation from the surface map, replay account A's request with
account B's identifier (and unauthenticated), keeping A's credentials. Cover path,
query, body, and nested/batch/GraphQL node ids.

## 3. Record per operation
Whether cross-account read/modify/delete succeeded, with the exact two requests.
Rule out operations that correctly returned an authorization error.

## Record → `checks/$SCOPE/object_reference.md`
Write one entry per item checked: what was examined, what was observed, and an
evidence path under `$ENG/evidence/`. For anything safe, write "ruled out" with the
reason so a later pass does not re-walk it. For anything confirmed, capture the
proof and leave it for the operator — do not draft or submit here.

## Tick the box
Only after `object_reference.md` accounts for every item in scope for this service (confirmed
or ruled out), tick the `API object-reference walk` box for this service in `$ENG/00_ledger.md`.

## Example of good output — `object_reference.md`

```markdown
### GET /v3/orders/{id} — CONFIRMED
Sequential id; account A reading B's order id returns B's PII. Proof: req as A with
B's id → 200 with B data. Two owned accounts. Evidence: $ENG/evidence/api-idor-orders.txt
```
