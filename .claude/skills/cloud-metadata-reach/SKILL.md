---
name: cloud-metadata-reach
description: Check whether a server-side fetch feature in scope can reach the cloud instance metadata service.
---

# Metadata reachability

Plain name: Metadata reachability. One thing, one skill. Work one asset at a time, from the
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
GATE="$BL4CKAI_HOME/.claude/skills/scope-gate/scope_check.sh"
REQ="$BL4CKAI_HOME/.claude/skills/scope-gate/req.sh"
bash "$GATE" "$SCOPE" || exit 0   # REQUIRED before any request; send live requests via "$REQ"
[ -n "${KB_ROOT:-}" ] && echo "KB_ROOT set — read your notes relevant to this area under $KB_ROOT first." \
  || echo "No reference library configured; use the method below + public references."
```

## 2. Reuse the server-fetch surface
This is the cloud-specific case of `web-server-fetch-probe`. Where a confirmed
server-side fetch exists, test (carefully, operator-gated) whether the internal
metadata endpoint is reachable and what category of response returns.

## 3. Confirm reach, not credential theft
Confirm reachability by a benign signal (a non-secret metadata field or a timing/
error difference). Do NOT pull credentials; hand to the operator.

## Record → `checks/$SCOPE/metadata_reach.md`
Write one entry per item checked: what was examined, what was observed, and an
evidence path under `$ENG/evidence/`. For anything safe, write "ruled out" with the
reason so a later pass does not re-walk it. For anything confirmed, capture the
proof and leave it for the operator — do not draft or submit here.

## Tick the box
Only after `metadata_reach.md` accounts for every item in scope for this asset (confirmed
or ruled out), tick the `Metadata reachability` box for this asset in `$ENG/00_ledger.md`.

## Example of good output — `metadata_reach.md`

```markdown
### acme — metadata — CONFIRMED reachable (blind)
Via the /unfurl server-fetch, the instance metadata host responds (timing + 200 on a
non-secret field). Credentials not retrieved; handed to operator.
Evidence: $ENG/evidence/acme-metadata-reach.txt
```
