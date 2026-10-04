---
name: dedup-check
description: Before writing up a confirmed result, judge how likely someone has already reported the same thing, by comparing it against the operator's own past write-ups, the program's public history, and this engagement's other results. Writes a short assessment with a verdict.
---

# Duplicate assessment

Runs after a technique skill confirms something, before `finding-draft`. The agent
does this itself — it decides whether the result is worth writing up as novel, a
variant worth reporting for higher impact, or a true duplicate to drop. The
operator sees the verdict and can overrule it.

## Set up paths

```bash
TARGET=acme
LETTER=$(echo "$TARGET" | cut -c1 | tr '[:lower:]' '[:upper:]')
: "${BL4CKAI_HOME:?set it to the harness repo root, e.g. export BL4CKAI_HOME=~/bl4ckai}"
[ -f "$BL4CKAI_HOME/config.sh" ] && . "$BL4CKAI_HOME/config.sh"
ENG="${ENGAGEMENTS_ROOT:-$BL4CKAI_HOME/engagements}/$LETTER/$TARGET"
SLUG=idor-orders-cross-account        # short finding slug
```

## 1. Self-duplicate — the operator's own history first

- This engagement: read `$ENG/reports/` for a near-match already drafted or
  submitted on this program.
  ```bash
  ls "$ENG/reports/" 2>/dev/null; grep -ril "orders" "$ENG/reports/" 2>/dev/null
  ```
- The operator's vault (past findings across programs):
  ```bash
  [ -n "${VAULT_ROOT:-}" ] && grep -ril "<class or endpoint keywords>" \
    "$VAULT_ROOT" 2>/dev/null || echo "(no vault configured; skip)"
  ```
- The operator's public platform history (read-only): if `PLATFORM_PROFILES` is
  set in config, fetch each profile URL it lists and check for a similar prior
  report on this program. If unset, skip this step.

If the operator already reported this on this program, it is a true duplicate —
drop it, unless the new result demonstrates meaningfully higher impact, in which
case frame it as an escalation/variant and say so.

## 2. Program public history

If the program discloses reports, scan its public disclosures for the same class on
the same surface. A match on the exact endpoint is a strong duplicate signal.

## 3. Score duplicate probability

Use the operator's heuristics.

HIGH probability (deprioritize, usually drop):
- Common issue on the main login/search/feedback surface of an established program
- Root-level redirect-parameter issues
- Anything commonly out of scope (transport, headers)
- Default credentials on well-known panels

LOW probability (prioritize, worth drafting):
- Recently deployed features (history shows they are new)
- Multi-step setups; unusual methods (PATCH, OPTIONS, PROPFIND)
- Edge-case encodings; endpoints found only via history/scripts
- Logic issues specific to this program's domain
- Chains of two or more lower-severity results becoming high impact
- Anything in a program-named "area of focus"

## 4. Write the assessment → `reports/$SLUG_dedup.md`

Record: the candidate (one line), self-dup result with what you checked, program
history result, `dup_probability: high | medium | low`, and the verdict with one
line of reasoning.

## 5. Tick and route

Tick the `Duplicate assessment` line for this finding in `$ENG/00_ledger.md`. Then:
- verdict NOVEL or VARIANT → continue to `finding-draft`
- verdict DUPLICATE → do not draft; note it in `$ENG/03_lessons.md` so it is not
  re-walked, and move on

## Example of good output — `reports/idor-orders-cross-account_dedup.md`

```markdown
# Dedup — idor-orders-cross-account

Candidate: sequential order id on GET /api/orders/{id} returns other accounts' orders.

Self-dup: no match in $ENG/reports/; no match in operator vault for acme; operator
HackerOne profile shows no prior acme report on orders. Not a self-dup.

Program history: acme discloses reports; nearest public report was an IDOR on
/api/invoices (different object, fixed 2024). Not the same object.

dup_probability: low  (object-reference issue on a money endpoint, specific object)
Verdict: NOVEL → draft it.
```
