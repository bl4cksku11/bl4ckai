---
name: source-query-construction-review
description: Read how a codebase builds database queries and system commands, and look for places where input is concatenated instead of parameterized.
---

# Query construction review

Plain name: Query construction review. One thing, one skill. Work one repo at a time, from the
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

## 2. Find every query/command construction site
Grep for query builders, raw query execution, ORM raw escapes, and process/exec
calls. For each, read whether input is bound as a parameter or concatenated into the
statement/command.

## 3. Record the concatenation sites
A site that concatenates request-derived input into a query or command is the
finding. Quote file:line and the tainted variable; note whether `source-input-trace`
shows it reachable from an entry point.

## Record → `checks/$SCOPE/query_construction.md`
Write one entry per item checked: what was examined, what was observed, and an
evidence path under `$ENG/evidence/`. For anything safe, write "ruled out" with the
reason so a later pass does not re-walk it. For anything confirmed, capture the
proof and leave it for the operator — do not draft or submit here.

## Tick the box
Only after `query_construction.md` accounts for every item in scope for this repo (confirmed
or ruled out), tick the `Query construction review` box for this repo in `$ENG/00_ledger.md`.

## Example of good output — `query_construction.md`

```markdown
### acme-api — query construction — CONFIRMED
store/search.go:120 concatenates `filter` into a raw SQL WHERE; reachable from
/search (see input_trace). 2 exec.Command sites build args from request fields.
Evidence: $ENG/checks/acme-api/query_construction.md
```
