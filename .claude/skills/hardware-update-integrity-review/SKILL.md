---
name: hardware-update-integrity-review
description: Check whether a device verifies the authenticity of a firmware update before installing it.
---

# Update-integrity review

Plain name: Update-integrity review. One thing, one skill. Work one device at a time, from the
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

## 2. Read the update path
From the firmware, find how updates are fetched and applied: transport (plain vs
TLS), and whether the image is signature-verified before flashing.

## 3. Record the gap
An update fetched over cleartext, or installed without a verified signature, is the
finding. Describe the mechanism; no live device modification.

## Record → `checks/$SCOPE/update_integrity.md`
Write one entry per item checked: what was examined, what was observed, and an
evidence path under `$ENG/evidence/`. For anything safe, write "ruled out" with the
reason so a later pass does not re-walk it. For anything confirmed, capture the
proof and leave it for the operator — do not draft or submit here.

## Tick the box
Only after `update_integrity.md` accounts for every item in scope for this device (confirmed
or ruled out), tick the `Update-integrity review` box for this device in `$ENG/00_ledger.md`.

## Example of good output — `update_integrity.md`

```markdown
### acme-router-v2 — update integrity — CONFIRMED
Updater fetches fw over HTTP and checks only a CRC (no signature) before flashing →
a network-positioned party could supply firmware. Mechanism described.
Evidence: $OUT/update_integrity.md
```
