---
name: cloud-identity-review
description: Review cloud credentials or roles found in scope for permissions broader than they should have.
---

# Cloud identity review

Plain name: Cloud identity review. One thing, one skill. Work one asset at a time, from the
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

## 2. Scope only credentials already found in-scope
Work only from keys/roles surfaced by other skills (source/mobile/secret scans) that
belong to the target and the operator is authorized to assess.

## 3. Enumerate effective permissions read-only
Enumerate what the identity can do with read-only/enumeration calls (no changes, no
data access). Record over-broad grants (wildcards, admin, cross-account trust).

## Record → `checks/$SCOPE/identity_review.md`
Write one entry per item checked: what was examined, what was observed, and an
evidence path under `$ENG/evidence/`. For anything safe, write "ruled out" with the
reason so a later pass does not re-walk it. For anything confirmed, capture the
proof and leave it for the operator — do not draft or submit here.

## Tick the box
Only after `identity_review.md` accounts for every item in scope for this asset (confirmed
or ruled out), tick the `Cloud identity review` box for this asset in `$ENG/00_ledger.md`.

## Example of good output — `identity_review.md`

```markdown
### acme-prod — identity — CONFIRMED over-broad
The CI key found in source has s3:* on all buckets + iam:PassRole. Enumerated via
read-only calls; nothing modified. Evidence: $ENG/evidence/acme-iam-enum.txt
```
