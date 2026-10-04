---
name: mobile-secret-scan
description: Scan an unpacked application package for keys, tokens, endpoints, and other credentials left inside the shipped files.
---

# Mobile package secret scan

Plain name: Mobile package secret scan. One thing, one skill. Work one app at a time, from the
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
SCOPE=com.acme.app        # package / bundle id of the in-scope app
OUT="$ENG/checks/$SCOPE"; mkdir -p "$OUT"
[ -n "${KB_ROOT:-}" ] && echo "KB_ROOT set — read your notes relevant to this area under $KB_ROOT first." \
  || echo "No reference library configured; use the method below + public references."
```

## 2. Scan the decoded package for embedded secrets
Run a secret scanner over `$OUT` (the decoded package) and grep strings, resources,
and native libs for API keys, cloud credentials, signing material, and hardcoded
hostnames. Note each hit's file and whether it looks active.

## 3. Confirm relevance, not validity against live services
Record what was found and where. Do not use a found credential against a live
service here — hand active-looking keys to the operator to scope.

## Record → `checks/$SCOPE/secret_scan.md`
Write one entry per item checked: what was examined, what was observed, and an
evidence path under `$ENG/evidence/`. For anything safe, write "ruled out" with the
reason so a later pass does not re-walk it. For anything confirmed, capture the
proof and leave it for the operator — do not draft or submit here.

## Tick the box
Only after `secret_scan.md` accounts for every item in scope for this app (confirmed
or ruled out), tick the `Mobile package secret scan` box for this app in `$ENG/00_ledger.md`.

## Example of good output — `secret_scan.md`

```markdown
### com.acme.app — secret scan — CONFIRMED (hardcoded key)
res/values/strings.xml holds a Google Maps key and a static `api_token` used as a
Bearer default. Third-party key present in a native lib. Not exercised against live.
Evidence: $ENG/evidence/acme-secrets.txt
```
