---
name: cloud-subdomain-takeover
description: Check whether a DNS name that still points at a decommissioned cloud service can be claimed by someone else.
---

# Dangling-DNS takeover check

Plain name: Dangling-DNS takeover check. One thing, one skill. Work one asset at a time, from the
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

## 2. Find dangling pointers
From the resolved recon set, find names whose CNAME/ALIAS points at a cloud service
whose target no longer exists (the provider returns a claim-me fingerprint).

## 3. Confirm claimability safely
Confirm the service is unclaimed by its fingerprint only — do NOT register the
resource. Record the name, the provider, and the fingerprint; hand to the operator.

## Record → `checks/$SCOPE/subdomain_takeover.md`
Write one entry per item checked: what was examined, what was observed, and an
evidence path under `$ENG/evidence/`. For anything safe, write "ruled out" with the
reason so a later pass does not re-walk it. For anything confirmed, capture the
proof and leave it for the operator — do not draft or submit here.

## Tick the box
Only after `subdomain_takeover.md` accounts for every item in scope for this asset (confirmed
or ruled out), tick the `Dangling-DNS takeover check` box for this asset in `$ENG/00_ledger.md`.

## Example of good output — `subdomain_takeover.md`

```markdown
### acme — takeover — CONFIRMED (claimable)
assets.acme.com → CNAME to a deleted CDN distribution returning the provider's
"NoSuchBucket" claim fingerprint. Not registered. Evidence: $ENG/evidence/acme-dangling.txt
```
