---
name: cloud-storage-exposure
description: Check whether an organization's object-storage containers that are in scope are readable or writable by anyone.
---

# Cloud storage exposure

Plain name: Cloud storage exposure. One thing, one skill. Work one asset at a time, from the
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

## 2. Discover in-scope storage names
From recon (hosts, JS, historical URLs) collect bucket/container names tied to the
in-scope org. Only names clearly belonging to the target.

## 3. Check access without touching data
Test read/list/write permission on each with benign, non-destructive probes (list a
prefix; do not download personal data, do not overwrite). Record public-read,
public-write, or listable.

## Record → `checks/$SCOPE/storage_exposure.md`
Write one entry per item checked: what was examined, what was observed, and an
evidence path under `$ENG/evidence/`. For anything safe, write "ruled out" with the
reason so a later pass does not re-walk it. For anything confirmed, capture the
proof and leave it for the operator — do not draft or submit here.

## Tick the box
Only after `storage_exposure.md` accounts for every item in scope for this asset (confirmed
or ruled out), tick the `Cloud storage exposure` box for this asset in `$ENG/00_ledger.md`.

## Example of good output — `storage_exposure.md`

```markdown
### acme-prod — storage — CONFIRMED (public list)
s3://acme-media-public lists all objects to anonymous; s3://acme-backups denies.
No objects downloaded. Evidence: $ENG/evidence/acme-bucket-list.txt
```
