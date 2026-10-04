---
name: source-input-trace
description: Follow untrusted input through the code from where it enters to where it is used in a sensitive operation, by reading the code path.
---

# Input-to-sink trace

Plain name: Input-to-sink trace. One thing, one skill. Work one repo at a time, from the
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

## 2. Pick a source and a sink class
From intake, take an entry point (source) and a sensitive operation class (a query
builder, a command runner, a file path join, a template render, a deserializer).

## 3. Read the path between them
Trace the value by reading code, noting every transform and every place it is
validated or neutralized. A path with no effective neutralization before the sink
is the finding to record; quote the file:line of source, sink, and the gap.

## Record → `checks/$SCOPE/input_trace.md`
Write one entry per item checked: what was examined, what was observed, and an
evidence path under `$ENG/evidence/`. For anything safe, write "ruled out" with the
reason so a later pass does not re-walk it. For anything confirmed, capture the
proof and leave it for the operator — do not draft or submit here.

## Tick the box
Only after `input_trace.md` accounts for every item in scope for this repo (confirmed
or ruled out), tick the `Input-to-sink trace` box for this repo in `$ENG/00_ledger.md`.

## Example of good output — `input_trace.md`

```markdown
### acme-api — input trace — CONFIRMED gap
handlers/report.go:44 reads `q.Get("sort")` → builds a SQL ORDER BY via string
concat at store/report.go:91 with no allowlist. Source, sink, and the missing guard
quoted. (web-db-query-influence would confirm at runtime.)
Evidence: $ENG/checks/acme-api/input_trace.md
```
