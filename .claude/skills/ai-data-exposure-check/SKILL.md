---
name: ai-data-exposure-check
description: Check whether a model-backed feature can be made to reveal data from its context, training, or other users that the requester should not see.
---

# Model data-exposure check

Plain name: Model data-exposure check. One thing, one skill. Work one feature at a time, from the
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
SCOPE=acme-assistant        # the model-backed feature under test
OUT="$ENG/checks/$SCOPE"; mkdir -p "$OUT"
[ -n "${KB_ROOT:-}" ] && echo "KB_ROOT set — read your notes relevant to this area under $KB_ROOT first." \
  || echo "No reference library configured; use the method below + public references."
```

## 2. Map what sits in the model's reach
Note the context the feature assembles: retrieved documents, other users' data,
system configuration, or tool results. Identify what the current requester is
entitled to.

## 3. Probe for over-disclosure (own accounts)
With the operator's own accounts, test whether the feature can be led to reveal
another tenant's retrieved content or its configuration. Record what leaked and the
entitlement gap; keep to own data.

## Record → `checks/$SCOPE/data_exposure.md`
Write one entry per item checked: what was examined, what was observed, and an
evidence path under `$ENG/evidence/`. For anything safe, write "ruled out" with the
reason so a later pass does not re-walk it. For anything confirmed, capture the
proof and leave it for the operator — do not draft or submit here.

## Tick the box
Only after `data_exposure.md` accounts for every item in scope for this feature (confirmed
or ruled out), tick the `Model data-exposure check` box for this feature in `$ENG/00_ledger.md`.

## Example of good output — `data_exposure.md`

```markdown
### acme-assistant — data exposure — CONFIRMED
A retrieval query returns chunks from another tenant's documents in the answer; the
retriever is not tenant-filtered. Own accounts. Evidence: $ENG/evidence/acme-ai-xtenant.txt
```
