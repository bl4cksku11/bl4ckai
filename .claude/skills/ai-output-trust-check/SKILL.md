---
name: ai-output-trust-check
description: Check whether an application acts on a model's output without validating it, so the output can drive an unintended action.
---

# Model output-trust check

Plain name: Model output-trust check. One thing, one skill. Work one feature at a time, from the
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

## 2. Find where model output is consumed
Identify what the app does with the model's output: renders it as HTML, runs it as a
query/command, calls a tool/function, or follows a URL. Each is a trust boundary.

## 3. Probe whether unvalidated output flows through
Steer the model (via benign supplied input) to produce output in that sink's form
and observe whether the app acts on it unchecked. This often chains into a web-*
check (render → client-sink, output → db-query); route it there to confirm.

## Record → `checks/$SCOPE/output_trust.md`
Write one entry per item checked: what was examined, what was observed, and an
evidence path under `$ENG/evidence/`. For anything safe, write "ruled out" with the
reason so a later pass does not re-walk it. For anything confirmed, capture the
proof and leave it for the operator — do not draft or submit here.

## Tick the box
Only after `output_trust.md` accounts for every item in scope for this feature (confirmed
or ruled out), tick the `Model output-trust check` box for this feature in `$ENG/00_ledger.md`.

## Example of good output — `output_trust.md`

```markdown
### acme-assistant — output trust — CONFIRMED (renders HTML)
Model output is inserted into the page with innerHTML; supplied input makes it emit
markup that the page renders. Routed to web-client-sink-trace.
Evidence: $ENG/evidence/acme-ai-outputrender.txt
```
