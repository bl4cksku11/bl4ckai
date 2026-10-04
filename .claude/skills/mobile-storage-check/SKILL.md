---
name: mobile-storage-check
description: Check what a mobile application leaves stored on the device after use, and whether anything sensitive is kept unprotected.
---

# Mobile local-storage check

Plain name: Mobile local-storage check. One thing, one skill. Work one app at a time, from the
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

## 2. Inspect what the app writes at rest
On a device the operator controls, after exercising the app, inspect its sandbox:
preferences, local databases, caches, and the keychain/keystore entries it creates.

## 3. Judge protection of anything sensitive
Record whether session tokens, personal data, or secrets are stored in clear,
world-readable, or backup-included locations. Own accounts only.

## Record → `checks/$SCOPE/storage_check.md`
Write one entry per item checked: what was examined, what was observed, and an
evidence path under `$ENG/evidence/`. For anything safe, write "ruled out" with the
reason so a later pass does not re-walk it. For anything confirmed, capture the
proof and leave it for the operator — do not draft or submit here.

## Tick the box
Only after `storage_check.md` accounts for every item in scope for this app (confirmed
or ruled out), tick the `Mobile local-storage check` box for this app in `$ENG/00_ledger.md`.

## Example of good output — `storage_check.md`

```markdown
### com.acme.app — storage — CONFIRMED (token in clear)
shared_prefs/auth.xml stores the refresh token in plaintext, included in auto-backup.
Local SQLite caches full profile. Own test account only.
Evidence: $ENG/evidence/acme-storage.txt
```
