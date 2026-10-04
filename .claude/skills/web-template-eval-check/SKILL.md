---
name: web-template-eval-check
description: Check whether values placed into server-rendered templates are evaluated as expressions rather than printed as text. Reads reference notes first and records observations to the engagement folder.
---

# Server-side template evaluation (SSTI)

Plain name: Server-side template evaluation (SSTI). One technique, one skill. Run it against one host at a time,
from the surface list in `02_strategy.md`. Stay in scope. This skill tests and
records only — it never drafts, submits, or contacts the program. A confirmed
result is handed to the operator and the finding path.

## 1. Set up paths and read any configured reference notes first

```bash
: "${BL4CKAI_HOME:?set it to the harness repo root, e.g. export BL4CKAI_HOME=~/bl4ckai}"
[ -f "$BL4CKAI_HOME/config.sh" ] && . "$BL4CKAI_HOME/config.sh"
: "${ENGAGEMENTS_ROOT:=$BL4CKAI_HOME/engagements}"
TARGET=acme
LETTER=$(printf %s "$TARGET" | cut -c1 | tr '[:lower:]' '[:upper:]')
ENG="$ENGAGEMENTS_ROOT/$LETTER/$TARGET"
HOST=app.acme.com
OUT="$ENG/checks/$HOST"; mkdir -p "$OUT"
GATE="$BL4CKAI_HOME/.claude/skills/scope-gate/scope_check.sh"
REQ="$BL4CKAI_HOME/.claude/skills/scope-gate/req.sh"
bash "$GATE" "$HOST" || exit 0   # REQUIRED: OUT of scope → stop; ASK → confirm with operator
```

If a reference library is configured (`KB_ROOT`), read its notes for this technique
as a starting set, then adapt to what THIS target actually does. If not, rely on
the method in this skill plus public references. Send EVERY live request in
this skill through `$REQ` (it enforces scope + the program header + the rate
cap) — never raw curl; bulk tools get a scope-filtered input list and `-rl`.

```bash
if [ -n "${KB_ROOT:-}" ] && ([ -d "$KB_ROOT/Web/Server Side Template Injection" ]); then
  cat "$KB_ROOT/Web/Server Side Template Injection"/README.md 2>/dev/null || (ls "$KB_ROOT/Web/Server Side Template Injection"/ && cat "$KB_ROOT/Web/Server Side Template Injection"/*.md 2>/dev/null | head -400)
else
  echo "No reference library configured (KB_ROOT); using the method in this skill + public references."
fi
```

## 2. Find values that land in server-rendered output
Anywhere user input is placed into a page the server renders: names in emails/PDFs,
templated error messages, report/label generators, theme or notification
templates.

## 3. Probe with arithmetic markers per engine
Send a benign arithmetic marker that only differs from text if evaluated (the KB
lists the per-engine forms). If the output shows the computed result instead of
the literal, the value is being evaluated. Identify the engine from which marker
fires.

## 4. Confirm scope of evaluation safely
Confirm expression evaluation with a harmless read (e.g. a constant or a benign
object), enough to prove evaluation. Do not run system commands or read secrets;
record the engine and hand to the operator for impact scoping.

## 5. Record per sink
Sink, engine identified, the marker that evaluated, and the benign confirmation.

## 6. Record → `checks/$HOST/template_eval.md`
Write one entry per item checked: what was tested, the observed result, and an
evidence path under `$ENG/evidence/`. For items that are safe, write "ruled out"
with the reason so a later session does not re-walk them. For anything confirmed,
stop and hand to the operator — do not draft or submit here.

## 7. Tick the box
Only after `template_eval.md` accounts for every item in scope for this host (each confirmed
or ruled out), tick the `Server-side template evaluation check` box for this host in `$ENG/00_ledger.md`.

## Example of good output — `template_eval.md`

```markdown
### `name` in password-reset email  — CONFIRMED (Jinja2)
Marker {{7*7}} rendered as 49 in the delivered email body. Engine: Jinja2 (confirmed
by engine-specific marker). Benign object read confirmed evaluation. No command run.
Evidence: .../evidence/acme-ssti-reset.txt
```
