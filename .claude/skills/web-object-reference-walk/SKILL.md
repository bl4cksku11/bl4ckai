---
name: web-object-reference-walk
description: Walk the identifiers a request uses to select records, and check whether one account can reach another account's records by changing them. Reads reference notes first and records observations to the engagement folder.
---

# Object-reference access control (IDOR/BOLA)

Plain name: Object-reference access control (IDOR/BOLA). One technique, one skill. Run it against one host at a time,
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
if [ -n "${KB_ROOT:-}" ] && ([ -d "$KB_ROOT/Web/Insecure Direct Object References" ]); then
  cat "$KB_ROOT/Web/Insecure Direct Object References"/README.md 2>/dev/null || (ls "$KB_ROOT/Web/Insecure Direct Object References"/ && cat "$KB_ROOT/Web/Insecure Direct Object References"/*.md 2>/dev/null | head -400)
else
  echo "No reference library configured (KB_ROOT); using the method in this skill + public references."
fi
```

## 2. Enumerate identifier-bearing requests with two accounts
You need two accounts (or one account + unauthenticated). Capture every request

Pull the two live sessions from `test-identity` (`A_HDR=$(bash "$BL4CKAI_HOME/.claude/skills/test-identity/identity.sh" get A)`, same for B; `anon` = no auth header) and send each request via `$REQ` with `-H "$A_HDR"`. A single identity cannot confirm an access-control finding.
that names a record by id: path ids, query ids, body ids, and ids hidden in
headers or tokens. Note the id format (sequential, UUID, hashed).

## 3. Cross-use identifiers between accounts
For each request, replay account A's request substituting account B's identifier
(and vice versa), keeping A's credentials. Record whether B's record is returned,
modified, or deleted. Repeat for the unauthenticated case.

## 4. Check indirect and nested references
Look for ids inside nested JSON, batch endpoints, export/report features, and
GraphQL node lookups — these are often missed by per-route checks.

## 5. Record per endpoint
For each endpoint: the id parameter, format, whether cross-account access
succeeded, and the exact two requests that prove it. Rule out endpoints that
correctly returned an authorization error, with that observation.

## 6. Record → `checks/$HOST/object_reference.md`
Write one entry per item checked: what was tested, the observed result, and an
evidence path under `$ENG/evidence/`. For items that are safe, write "ruled out"
with the reason so a later session does not re-walk them. For anything confirmed,
stop and hand to the operator — do not draft or submit here.

## 7. Tick the box
Only after `object_reference.md` accounts for every item in scope for this host (each confirmed
or ruled out), tick the `Object-reference access control walk` box for this host in `$ENG/00_ledger.md`.

## Example of good output — `object_reference.md`

```markdown
### GET /api/orders/{id}  — CONFIRMED
id is sequential. Account A (cookie A) requesting B's order id 10432 returns B's
full order incl. address + last4. Proof: req as A with id=10432 → 200 with B data.
Evidence: .../evidence/acme-idor-orders.txt

### GET /api/users/{uuid}  — RULED OUT
UUID id; A requesting B's uuid returns 403 with correct owner check. Not vulnerable.
```
