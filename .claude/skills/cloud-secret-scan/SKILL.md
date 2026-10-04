---
name: cloud-secret-scan
description: Scan the organization's public artifacts in scope for leaked cloud keys and credentials.
---

# Cloud secret scan

Plain name: Cloud secret scan. One thing, one skill. Work one asset at a time, from the
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
SCOPE=acme-prod        # in-scope cloud account/project/asset label
OUT="$ENG/checks/$SCOPE"; mkdir -p "$OUT"
[ -n "${KB_ROOT:-}" ] && echo "KB_ROOT set — read your notes relevant to this area under $KB_ROOT first." \
  || echo "No reference library configured; use the method below + public references."
```

## 2. Scan public artifacts tied to the org
Scan in-scope public sources already collected (JS bundles, historical responses,
public repos/images in scope) for cloud keys and credential patterns.

## 3. Record hits, don't use them
Note each hit's source and whether it looks active (format/metadata only). Hand
active-looking keys to the operator; never authenticate with a found key here.

## Record → `checks/$SCOPE/secret_scan.md`
Write one entry per item checked: what was examined, what was observed, and an
evidence path under `$ENG/evidence/`. For anything safe, write "ruled out" with the
reason so a later pass does not re-walk it. For anything confirmed, capture the
proof and leave it for the operator — do not draft or submit here.

## Tick the box
Only after `secret_scan.md` accounts for every item in scope for this asset (confirmed
or ruled out), tick the `Cloud secret scan` box for this asset in `$ENG/00_ledger.md`.

## Example of good output — `secret_scan.md`

```markdown
### acme — cloud secrets — CONFIRMED
A main.js bundle embeds a long-lived access key id + secret. Format valid; not used.
Handed to operator. Evidence: $ENG/evidence/acme-js-key.txt
```
