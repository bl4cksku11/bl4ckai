---
name: web-db-query-influence
description: Check whether request values change the shape or result of the database queries a feature runs, rather than being handled purely as data. Reads reference notes first and records observations to the engagement folder.
---

# Database query influence (SQL/NoSQL)

Plain name: Database query influence (SQL/NoSQL). One technique, one skill. Run it against one host at a time,
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
if [ -n "${KB_ROOT:-}" ] && ([ -d "$KB_ROOT/Web/SQL Injection" ] || [ -d "$KB_ROOT/Web/NoSQL Injection" ]); then
  cat "$KB_ROOT/Web/SQL Injection"/README.md 2>/dev/null || (ls "$KB_ROOT/Web/SQL Injection"/ && cat "$KB_ROOT/Web/SQL Injection"/*.md 2>/dev/null | head -400)
  cat "$KB_ROOT/Web/NoSQL Injection"/README.md 2>/dev/null || (ls "$KB_ROOT/Web/NoSQL Injection"/ && cat "$KB_ROOT/Web/NoSQL Injection"/*.md 2>/dev/null | head -400)
else
  echo "No reference library configured (KB_ROOT); using the method in this skill + public references."
fi
```

## 2. Map inputs that reach a query
List endpoints with filtering, search, sort, pagination, login, and id lookups —
anything likely backed by a query. Note the backend if known (SQL vs document
store) from recon.

## 3. Probe for query influence with safe markers
Use the KB's safe probes: values that change results only if interpreted as query
syntax (boolean-true vs boolean-false pairs, order/column probes for SQL; operator
objects for document stores). Compare the two responses — a consistent difference
means the input is interpreted, not escaped.

## 4. Confirm with a benign, reversible signal
Prefer boolean/behavioral or timing confirmation over extracting data. Confirm the
query is influenced, then stop and hand to the operator for controlled impact; do
not dump tables or modify data.

## 5. Record per endpoint
Endpoint, parameter, backend, the true/false pair that differed, and the observed
signal. Rule out parameters that are parameterized/escaped, with the evidence.

## 6. Record → `checks/$HOST/db_query.md`
Write one entry per item checked: what was tested, the observed result, and an
evidence path under `$ENG/evidence/`. For items that are safe, write "ruled out"
with the reason so a later session does not re-walk them. For anything confirmed,
stop and hand to the operator — do not draft or submit here.

## 7. Tick the box
Only after `db_query.md` accounts for every item in scope for this host (each confirmed
or ruled out), tick the `Database query influence check` box for this host in `$ENG/00_ledger.md`.

## Example of good output — `db_query.md`

```markdown
### GET /search?category=  — CONFIRMED (boolean)
category=1' AND '1'='1 vs ...'1'='2 return 42 vs 0 rows consistently → interpreted.
Backend: MySQL (error fingerprint). Confirmed by boolean behavior only; no dump.
Evidence: .../evidence/acme-sqli-search.txt
```
