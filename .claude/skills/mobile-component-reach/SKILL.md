---
name: mobile-component-reach
description: Check whether another application on the device can reach a mobile app's exported components or links and make it act without authorization.
---

# Mobile component reachability

Plain name: Mobile component reachability. One thing, one skill. Work one app at a time, from the
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
GATE="$BL4CKAI_HOME/.claude/skills/scope-gate/scope_check.sh"
REQ="$BL4CKAI_HOME/.claude/skills/scope-gate/req.sh"
bash "$GATE" "$SCOPE" || exit 0   # REQUIRED before any request; send live requests via "$REQ"
[ -n "${KB_ROOT:-}" ] && echo "KB_ROOT set — read your notes relevant to this area under $KB_ROOT first." \
  || echo "No reference library configured; use the method below + public references."
```

## 2. Exercise exported components and links from outside
For each exported component / deep link from `mobile-package-inspect`, invoke it
from a separate app or an OS command as an unprivileged caller and observe whether
it performs a sensitive action, discloses data, or loads attacker-supplied input.

## 3. Record what crosses the boundary
Note which components enforce a permission/caller check and which do not.

## Record → `checks/$SCOPE/component_reach.md`
Write one entry per item checked: what was examined, what was observed, and an
evidence path under `$ENG/evidence/`. For anything safe, write "ruled out" with the
reason so a later pass does not re-walk it. For anything confirmed, capture the
proof and leave it for the operator — do not draft or submit here.

## Tick the box
Only after `component_reach.md` accounts for every item in scope for this app (confirmed
or ruled out), tick the `Mobile component reachability` box for this app in `$ENG/00_ledger.md`.

## Example of good output — `component_reach.md`

```markdown
### com.acme.app — component reach — CONFIRMED
Exported ContentProvider returns the message DB to any app (no permission). Deep
link acme://pay?to=… starts a transfer screen prefilled from the link. Own device.
Evidence: $ENG/evidence/acme-provider-dump.txt
```
