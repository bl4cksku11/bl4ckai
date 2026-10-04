---
name: hardware-service-review
description: Review the network services a device runs for weak configuration or components with known weaknesses.
---

# Device service review

Plain name: Device service review. One thing, one skill. Work one device at a time, from the
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

## 2. Enumerate the services from the firmware
List listening services and their versions from the extracted filesystem (web server,
cgi, telnet/ssh, upnp, custom daemons). Note versions against known advisories.

## 3. Read the custom bits
Read the custom cgi/daemon code for the same classes the web-*/source-* skills cover
(input into commands/queries, missing auth). Quote file:line; confirm on an operator-
owned device only.

## Record → `checks/$SCOPE/service_review.md`
Write one entry per item checked: what was examined, what was observed, and an
evidence path under `$ENG/evidence/`. For anything safe, write "ruled out" with the
reason so a later pass does not re-walk it. For anything confirmed, capture the
proof and leave it for the operator — do not draft or submit here.

## Tick the box
Only after `service_review.md` accounts for every item in scope for this device (confirmed
or ruled out), tick the `Device service review` box for this device in `$ENG/00_ledger.md`.

## Example of good output — `service_review.md`

```markdown
### acme-router-v2 — services — CONFIRMED
The custom cgi passes the `ping` host param into system() unsanitized (file:line).
lighttpd version carries a known advisory. Confirm on operator device.
Evidence: $OUT/service_review.md
```
