---
name: web-cross-origin-policy-check
description: Review the response rules that decide which other sites may read a response, and whether they are broader than intended. Reads reference notes first and records observations to the engagement folder.
---

# Cross-origin sharing policy

Plain name: Cross-origin sharing policy. One technique, one skill. Run it against one host at a time,
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
if [ -n "${KB_ROOT:-}" ] && ([ -d "$KB_ROOT/Web/CORS Misconfiguration" ]); then
  cat "$KB_ROOT/Web/CORS Misconfiguration"/README.md 2>/dev/null || (ls "$KB_ROOT/Web/CORS Misconfiguration"/ && cat "$KB_ROOT/Web/CORS Misconfiguration"/*.md 2>/dev/null | head -400)
else
  echo "No reference library configured (KB_ROOT); using the method in this skill + public references."
fi
```

## 2. Map endpoints that return user-specific data
Focus on authenticated JSON endpoints — those are where an over-broad sharing
policy actually matters.

## 3. Probe the origin-reflection behavior
Send requests with varied `Origin` values (an arbitrary external origin, a
subdomain, `null`, a look-alike) and read the response's access-control headers.
The risky combination is a reflected/over-broad allowed origin together with
credentials allowed. The KB lists the header combinations that matter.

## 4. Confirm impact minimally
If an arbitrary origin is reflected with credentials allowed on an endpoint that
returns the caller's own data, that is the finding. Demonstrate with a request
showing the reflected header; do not host a live cross-site read against a real
victim.

## 5. Record per endpoint
Endpoint, which origins are reflected/allowed, whether credentials are allowed, and
the response headers that prove it.

## 6. Record → `checks/$HOST/cross_origin.md`
Write one entry per item checked: what was tested, the observed result, and an
evidence path under `$ENG/evidence/`. For items that are safe, write "ruled out"
with the reason so a later session does not re-walk them. For anything confirmed,
stop and hand to the operator — do not draft or submit here.

## 7. Tick the box
Only after `cross_origin.md` accounts for every item in scope for this host (each confirmed
or ruled out), tick the `Cross-origin sharing policy check` box for this host in `$ENG/00_ledger.md`.

## Example of good output — `cross_origin.md`

```markdown
### GET /api/me  — CONFIRMED
Arbitrary Origin reflected into Access-Control-Allow-Origin with
Allow-Credentials: true on an endpoint returning the caller's profile.
Evidence: .../evidence/acme-cors-me.txt
```
