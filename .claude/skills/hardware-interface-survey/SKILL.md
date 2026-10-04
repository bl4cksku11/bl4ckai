---
name: hardware-interface-survey
description: Document a device's physical and debug interfaces and whether they appear to be left open.
---

# Debug-interface survey

Plain name: Debug-interface survey. One thing, one skill. Work one device at a time, from the
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
SCOPE=acme-router-v2        # device / firmware image label
OUT="$ENG/checks/$SCOPE"; mkdir -p "$OUT"
[ -n "${KB_ROOT:-}" ] && echo "KB_ROOT set — read your notes relevant to this area under $KB_ROOT first." \
  || echo "No reference library configured; use the method below + public references."
```

## 2. Survey the board/firmware for interfaces
From the firmware and (operator-provided) board photos/notes, document serial, debug,
and storage interfaces and whether firmware references leave a console/shell enabled.

## 3. Record exposure, do not physically attack
This is documentation of apparent exposure (e.g. an enabled serial console, an
unlocked debug port per config). Any physical probing is the operator's step.

## Record → `checks/$SCOPE/interface_survey.md`
Write one entry per item checked: what was examined, what was observed, and an
evidence path under `$ENG/evidence/`. For anything safe, write "ruled out" with the
reason so a later pass does not re-walk it. For anything confirmed, capture the
proof and leave it for the operator — do not draft or submit here.

## Tick the box
Only after `interface_survey.md` accounts for every item in scope for this device (confirmed
or ruled out), tick the `Debug-interface survey` box for this device in `$ENG/00_ledger.md`.

## Example of good output — `interface_survey.md`

```markdown
### acme-router-v2 — interfaces — DOCUMENTED
init spawns a root shell on the serial console with no auth; debug port not disabled
in the referenced config. Physical probing deferred to operator.
Evidence: $OUT/interface_survey.md
```
