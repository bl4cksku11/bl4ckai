---
name: api-input-validation-check
description: Check whether API parameters are validated, or whether values pass through into a backend operation that interprets them.
---

# API input-validation check

Plain name: API input-validation check. One thing, one skill. Work one service at a time, from the
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

## 2. Probe each parameter class with safe markers
For parameters that reach a query, filter, lookup, or template, use the safe probes
from the technique skills (boolean pairs for query influence, arithmetic markers for
template evaluation, a benign marker for reflection) and compare responses.

## 3. Hand confirmed interpretation to the matching web-* skill
When a parameter clearly interprets input, record it and continue in the specific
check (`web-db-query-influence`, `web-template-eval-check`, …). Do not escalate here.

## Record → `checks/$SCOPE/input_validation.md`
Write one entry per item checked: what was examined, what was observed, and an
evidence path under `$ENG/evidence/`. For anything safe, write "ruled out" with the
reason so a later pass does not re-walk it. For anything confirmed, capture the
proof and leave it for the operator — do not draft or submit here.

## Tick the box
Only after `input_validation.md` accounts for every item in scope for this service (confirmed
or ruled out), tick the `API input-validation check` box for this service in `$ENG/00_ledger.md`.

## Example of good output — `input_validation.md`

```markdown
### GET /v3/search?sort= — CONFIRMED influences query
sort=name/**/ vs sort=1 change row order/error consistently → interpreted, not
validated. Routed to web-db-query-influence. Evidence: $ENG/evidence/api-sort-probe.txt
```
