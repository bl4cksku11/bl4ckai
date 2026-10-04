---
name: web-logic-flow-walk
description: Walk multi-step workflows for steps that can be reordered, repeated, or run at the same time to reach an unintended state. Reads reference notes first and records observations to the engagement folder.
---

# Business-logic and workflow

Plain name: Business-logic and workflow. One technique, one skill. Run it against one host at a time,
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
```

If a reference library is configured (`KB_ROOT`), read its notes for this technique
as a starting set, then adapt to what THIS target actually does. If not, rely on
the method in this skill plus public references.

```bash
if [ -n "${KB_ROOT:-}" ] && ([ -d "$KB_ROOT/Web/Business Logic Errors" ] || [ -d "$KB_ROOT/Web/Race Condition" ]); then
  cat "$KB_ROOT/Web/Business Logic Errors"/README.md 2>/dev/null || (ls "$KB_ROOT/Web/Business Logic Errors"/ && cat "$KB_ROOT/Web/Business Logic Errors"/*.md 2>/dev/null | head -400)
  cat "$KB_ROOT/Web/Race Condition"/README.md 2>/dev/null || (ls "$KB_ROOT/Web/Race Condition"/ && cat "$KB_ROOT/Web/Race Condition"/*.md 2>/dev/null | head -400)
else
  echo "No reference library configured (KB_ROOT); using the method in this skill + public references."
fi
```

## 2. Model the intended workflow
Pick money/value/limit-bearing flows: checkout, coupons, credit/points, invites,
quotas, tier limits. Write the intended step order and the server's assumed
invariants.

## 3. Break the assumptions
Reorder steps, skip a step, repeat a step, replay a consumed token, submit negative
or oversized quantities, and change currency/price fields the client sends. For
limit/quota flows, test concurrency: fire the same request many times at once to
see if a check-then-act gap lets you exceed the limit (the KB covers the
same-instant technique).

## 4. Confirm with the resulting state
The proof is the unintended state reached (e.g. coupon applied twice, limit
exceeded), shown with the requests and the resulting balance/record. Keep it to
your own account and values; do not cause real financial loss — hand to the
operator to scope.

## 5. Record per flow
Flow, the assumption broken, how, and the state reached.

## 6. Record → `checks/$HOST/logic_flow.md`
Write one entry per item checked: what was tested, the observed result, and an
evidence path under `$ENG/evidence/`. For items that are safe, write "ruled out"
with the reason so a later session does not re-walk them. For anything confirmed,
stop and hand to the operator — do not draft or submit here.

## 7. Tick the box
Only after `logic_flow.md` accounts for every item in scope for this host (each confirmed
or ruled out), tick the `Business-logic and workflow walk` box for this host in `$ENG/00_ledger.md`.

## Example of good output — `logic_flow.md`

```markdown
### coupon apply  — CONFIRMED (concurrency)
Single-use coupon applied N times by firing /apply concurrently; final cart shows
N discounts. Own account only. Evidence: .../evidence/acme-logic-coupon-race.txt
```
