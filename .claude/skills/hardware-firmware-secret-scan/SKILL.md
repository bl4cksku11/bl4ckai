---
name: hardware-firmware-secret-scan
description: Scan an unpacked firmware image for keys, certificates, credentials, and hardcoded access.
---

# Firmware secret scan

Plain name: Firmware secret scan. One thing, one skill. Work one device at a time, from the
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

## 2. Scan the extracted filesystem
Grep and secret-scan the carved filesystem for private keys, certificates, hardcoded
passwords (/etc/passwd, shadow, config defaults), API tokens, and backdoor-style
accounts.

## 3. Record each hit
Note file, kind, and whether it looks usable (e.g. a default admin hash). Do not
test against a live device here; hand to the operator.

## Record → `checks/$SCOPE/secret_scan.md`
Write one entry per item checked: what was examined, what was observed, and an
evidence path under `$ENG/evidence/`. For anything safe, write "ruled out" with the
reason so a later pass does not re-walk it. For anything confirmed, capture the
proof and leave it for the operator — do not draft or submit here.

## Tick the box
Only after `secret_scan.md` accounts for every item in scope for this device (confirmed
or ruled out), tick the `Firmware secret scan` box for this device in `$ENG/00_ledger.md`.

## Example of good output — `secret_scan.md`

```markdown
### acme-router-v2 — firmware secrets — CONFIRMED
/etc/shadow ships a crackable root hash; a vendor TLS private key + a hardcoded
"support" account in the cgi. Not tested live. Evidence: $OUT/secret_scan.md
```
