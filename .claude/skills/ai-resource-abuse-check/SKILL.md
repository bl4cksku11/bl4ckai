---
name: ai-resource-abuse-check
description: Check whether a model-backed feature can be driven to consume unbounded resources or cost.
---

# Model resource-abuse check

Plain name: Model resource-abuse check. One thing, one skill. Work one feature at a time, from the
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

## 2. Find the limits (or absence of them)
Identify per-user rate limits, token/length caps, and recursion/tool-loop bounds on
the feature.

## 3. Probe gently for missing bounds
With small, controlled requests, check whether limits exist and are enforced server-
side — do NOT run a sustained cost attack. A single request that is accepted far
beyond a sane cap is enough to record; stop and hand to the operator.

## Record → `checks/$SCOPE/resource_abuse.md`
Write one entry per item checked: what was examined, what was observed, and an
evidence path under `$ENG/evidence/`. For anything safe, write "ruled out" with the
reason so a later pass does not re-walk it. For anything confirmed, capture the
proof and leave it for the operator — do not draft or submit here.

## Tick the box
Only after `resource_abuse.md` accounts for every item in scope for this feature (confirmed
or ruled out), tick the `Model resource-abuse check` box for this feature in `$ENG/00_ledger.md`.

## Example of good output — `resource_abuse.md`

```markdown
### acme-assistant — resource abuse — CONFIRMED (no cap)
A single request with a 2M-char input is accepted and processed; no length or rate
limit server-side. One probe only; not sustained. Evidence: $ENG/evidence/acme-ai-nocap.txt
```
