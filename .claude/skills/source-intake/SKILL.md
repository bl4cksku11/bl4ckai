---
name: source-intake
description: Set up a code review: get the source at a pinned version, identify its language, build, dependencies, and entry points, and write the map the other review skills work from.
---

# Source intake

Plain name: Source intake. One thing, one skill. Work one repo at a time, from the
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

## 2. Get and pin the source
Clone the in-scope source into `$ENG/src/<repo>` at a named commit/tag (never work
against a moving branch). Record the exact revision.

## 3. Map it
Identify language(s), build system, frameworks, and dependencies. List the entry
points where untrusted input enters (HTTP handlers, CLI, message consumers, file
parsers). Write the map to `$OUT/intake.md`; it drives every other source-* skill.

## Record → `checks/$SCOPE/intake.md`
Write one entry per item checked: what was examined, what was observed, and an
evidence path under `$ENG/evidence/`. For anything safe, write "ruled out" with the
reason so a later pass does not re-walk it. For anything confirmed, capture the
proof and leave it for the operator — do not draft or submit here.

## Tick the box
Only after `intake.md` accounts for every item in scope for this repo (confirmed
or ruled out), tick the `Source intake` box for this repo in `$ENG/00_ledger.md`.

## Example of good output — `intake.md`

```markdown
### acme-api @ v2.3.1 (commit a1b2c3) — intake — MAPPED
Go 1.22, chi router, 41 HTTP handlers; input entry points: handlers/*, a Kafka
consumer, a CSV importer. 180 deps. Feeds source-input-trace, source-dependency-audit.
Evidence: $ENG/src/acme-api/
```
