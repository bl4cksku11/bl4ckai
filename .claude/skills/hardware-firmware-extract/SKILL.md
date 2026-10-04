---
name: hardware-firmware-extract
description: Obtain and unpack a device's firmware image into its filesystem and components so it can be examined.
---

# Firmware extraction

Plain name: Firmware extraction. One thing, one skill. Work one device at a time, from the
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

## 2. Get and carve the image
Obtain the in-scope firmware (vendor download or an operator-provided dump) into
`$ENG/evidence`. Carve it (binwalk/unblob) to recover the filesystem(s), bootloader,
and embedded blobs into `$OUT`.

## 3. Map it
Identify the OS/init, filesystem type, architecture, and the services/binaries
present. This map drives the other hardware-* skills.

## Record → `checks/$SCOPE/firmware_extract.md`
Write one entry per item checked: what was examined, what was observed, and an
evidence path under `$ENG/evidence/`. For anything safe, write "ruled out" with the
reason so a later pass does not re-walk it. For anything confirmed, capture the
proof and leave it for the operator — do not draft or submit here.

## Tick the box
Only after `firmware_extract.md` accounts for every item in scope for this device (confirmed
or ruled out), tick the `Firmware extraction` box for this device in `$ENG/00_ledger.md`.

## Example of good output — `firmware_extract.md`

```markdown
### acme-router-v2 — firmware — EXTRACTED
SquashFS carved from fw 2.1.0; Linux/MIPS, BusyBox init, lighttpd + a custom cgi.
Feeds hardware-firmware-secret-scan, hardware-service-review.
Evidence: $ENG/evidence/acme-fw-2.1.0.bin  → $OUT/
```
