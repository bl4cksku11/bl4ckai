---
name: ai-tool-access-check
description: Check what actions a model-backed feature can trigger through its connected tools, and whether a user can push it past its intended limits.
---

# Model tool-access check

Plain name: Model tool-access check. One thing, one skill. Work one feature at a time, from the
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
GATE="$BL4CKAI_HOME/.claude/skills/scope-gate/scope_check.sh"
REQ="$BL4CKAI_HOME/.claude/skills/scope-gate/req.sh"
bash "$GATE" "$SCOPE" || exit 0   # REQUIRED before any request; send live requests via "$REQ"
[ -n "${KB_ROOT:-}" ] && echo "KB_ROOT set — read your notes relevant to this area under $KB_ROOT first." \
  || echo "No reference library configured; use the method below + public references."
```

## 2. Enumerate the connected tools/functions
List the actions the feature can invoke (search, email, file, code, purchase, admin)
and the guardrails that are supposed to bound each.

## 3. Probe the boundary (benign)
Test whether supplied input can make the feature invoke a tool it should not, with
arguments it should not, or at a scope it should not. Keep effects benign and
reversible; record which boundary gave way.

## Record → `checks/$SCOPE/tool_access.md`
Write one entry per item checked: what was examined, what was observed, and an
evidence path under `$ENG/evidence/`. For anything safe, write "ruled out" with the
reason so a later pass does not re-walk it. For anything confirmed, capture the
proof and leave it for the operator — do not draft or submit here.

## Tick the box
Only after `tool_access.md` accounts for every item in scope for this feature (confirmed
or ruled out), tick the `Model tool-access check` box for this feature in `$ENG/00_ledger.md`.

## Example of good output — `tool_access.md`

```markdown
### acme-assistant — tool access — CONFIRMED
User text can make the assistant call the internal "send_email" tool to an arbitrary
address; no recipient allowlist. Benign test mail to an owned address.
Evidence: $ENG/evidence/acme-ai-tool.txt
```
