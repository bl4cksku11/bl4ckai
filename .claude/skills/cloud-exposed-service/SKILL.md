---
name: cloud-exposed-service
description: Check for in-scope managed cloud services that are reachable when they should not be.
---

# Exposed-service check

Plain name: Exposed-service check. One thing, one skill. Work one asset at a time, from the
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

## 2. Enumerate exposed managed endpoints
From recon, identify managed services tied to the org (databases, search clusters,
dashboards, message brokers, container registries, k8s API) that answer from the
internet.

## 3. Confirm exposure without using the data
Confirm each is reachable and whether it requires auth, with a benign connection/
banner check. Do not read or change data. Record service, auth state, endpoint.

## Record → `checks/$SCOPE/exposed_service.md`
Write one entry per item checked: what was examined, what was observed, and an
evidence path under `$ENG/evidence/`. For anything safe, write "ruled out" with the
reason so a later pass does not re-walk it. For anything confirmed, capture the
proof and leave it for the operator — do not draft or submit here.

## Tick the box
Only after `exposed_service.md` accounts for every item in scope for this asset (confirmed
or ruled out), tick the `Exposed-service check` box for this asset in `$ENG/00_ledger.md`.

## Example of good output — `exposed_service.md`

```markdown
### acme — exposed service — CONFIRMED
An Elasticsearch node answers /_cat/indices unauthenticated from the internet.
No documents read. Evidence: $ENG/evidence/acme-es-open.txt
```
