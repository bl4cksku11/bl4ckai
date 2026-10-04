---
name: mobile-package-inspect
description: Unpack a mobile application package and read its manifest, declared permissions, components, and build settings to map what it exposes and talks to.
---

# Mobile package inspection

Plain name: Mobile package inspection. One thing, one skill. Work one app at a time, from the
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

## 2. Unpack and read the manifest
Decode the package (apktool for Android, extract the .ipa for iOS) into `$OUT`.
Read the manifest/Info.plist: declared permissions, exported activities/services/
receivers/providers, URL schemes and deep links, `debuggable`/ATS/cleartext flags,
and the backend hosts the app is built against.

## 3. Map the attack surface (document, don't test yet)
List every exported component, deep link, and backend host. These feed the other
mobile checks (`mobile-component-reach`, `mobile-traffic-inspect`) and the api-* skills.

## Record → `checks/$SCOPE/package_inspect.md`
Write one entry per item checked: what was examined, what was observed, and an
evidence path under `$ENG/evidence/`. For anything safe, write "ruled out" with the
reason so a later pass does not re-walk it. For anything confirmed, capture the
proof and leave it for the operator — do not draft or submit here.

## Tick the box
Only after `package_inspect.md` accounts for every item in scope for this app (confirmed
or ruled out), tick the `Mobile package inspection` box for this app in `$ENG/00_ledger.md`.

## Example of good output — `package_inspect.md`

```markdown
### com.acme.app — manifest — MAPPED
android:debuggable not set. Exported: 2 activities (DeepLinkActivity), 1 content
provider (no permission). Deep link scheme acme://. Backend: api.acme.com, cleartext
permitted for *.internal.acme.com. Feeds: mobile-component-reach, mobile-traffic-inspect.
Evidence: $ENG/evidence/acme-manifest.xml
```
