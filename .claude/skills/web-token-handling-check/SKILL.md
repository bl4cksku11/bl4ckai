---
name: web-token-handling-check
description: Review how session tokens are formed, signed, and validated, and whether a changed token is still accepted. Reads reference notes first and records observations to the engagement folder.
---

# Session token handling (JWT etc.)

Plain name: Session token handling (JWT etc.). One technique, one skill. Run it against one host at a time,
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
if [ -n "${KB_ROOT:-}" ] && ([ -d "$KB_ROOT/Web/JSON Web Token" ]); then
  cat "$KB_ROOT/Web/JSON Web Token"/README.md 2>/dev/null || (ls "$KB_ROOT/Web/JSON Web Token"/ && cat "$KB_ROOT/Web/JSON Web Token"/*.md 2>/dev/null | head -400)
else
  echo "No reference library configured (KB_ROOT); using the method in this skill + public references."
fi
```

## 2. Capture and decode the tokens
Collect session/access tokens. If they are self-describing (e.g. signed tokens),
decode header and body and note algorithm, claims, expiry, and key id.

## 3. Probe validation weaknesses (KB-guided)
Test the documented set: algorithm set to none, algorithm confusion
(asymmetric→symmetric), unverified signature, missing expiry enforcement, accepting
a token from another user/audience, and weak/guessable signing secret. Change one
property at a time and see if the server still accepts it.

## 4. Confirm minimally
Acceptance of a token you modified (that should be rejected) is the finding. Prove
it with one request using the altered token against an authenticated endpoint; do
not forge another real user's session beyond what proves the flaw.

## 5. Record
Token type, algorithm, which modification was accepted, and the request/response
proving acceptance. Rule out properly validated tokens.

## 6. Record → `checks/$HOST/token_handling.md`
Write one entry per item checked: what was tested, the observed result, and an
evidence path under `$ENG/evidence/`. For items that are safe, write "ruled out"
with the reason so a later session does not re-walk them. For anything confirmed,
stop and hand to the operator — do not draft or submit here.

## 7. Tick the box
Only after `token_handling.md` accounts for every item in scope for this host (each confirmed
or ruled out), tick the `Session token handling check` box for this host in `$ENG/00_ledger.md`.

## Example of good output — `token_handling.md`

```markdown
### access token  — CONFIRMED (alg=none accepted)
Resigning with alg=none and no signature is accepted on GET /api/me; server returns
the identity from the unsigned body. Evidence: .../evidence/acme-jwt-none.txt
```
