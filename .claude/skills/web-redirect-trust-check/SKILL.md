---
name: web-redirect-trust-check
description: Check whether a feature that forwards the browser to another address will forward to an arbitrary external destination supplied in the request. Reads reference notes first and records observations to the engagement folder.
---

# Redirect destination trust (open redirect)

Plain name: Redirect destination trust (open redirect). One technique, one skill. Run it against one host at a time,
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
if [ -n "${KB_ROOT:-}" ] && ([ -d "$KB_ROOT/Web/Open Redirect" ] || [ -d "$KB_ROOT/Web/Tabnabbing" ]); then
  cat "$KB_ROOT/Web/Open Redirect"/README.md 2>/dev/null || (ls "$KB_ROOT/Web/Open Redirect"/ && cat "$KB_ROOT/Web/Open Redirect"/*.md 2>/dev/null | head -400)
  cat "$KB_ROOT/Web/Tabnabbing"/README.md 2>/dev/null || (ls "$KB_ROOT/Web/Tabnabbing"/ && cat "$KB_ROOT/Web/Tabnabbing"/*.md 2>/dev/null | head -400)
else
  echo "No reference library configured (KB_ROOT); using the method in this skill + public references."
fi
```

## 2. Find redirect carriers
Login/logout `next`/`returnTo`/`redirect` params, SSO callbacks, link trackers,
language/region switches, and any `Location`-setting endpoint.

## 3. Probe destination control
Supply an external destination you control and check whether the browser is sent
there. Test the KB's bypass forms for weak allowlists (scheme-relative `//`,
`\`, `@` userinfo, encoded hosts, whitelisted-substring tricks). Note whether the
redirect also opens in a new context (tab-trust concern).

## 4. Confirm minimally
A redirect to a domain you control is the proof; no further action. Record whether
it is unauthenticated (more useful in a chain).

## 5. Record per carrier
Carrier parameter, the exact value that redirected off-site, whether auth was
required, and the request.

## 6. Record → `checks/$HOST/redirect_trust.md`
Write one entry per item checked: what was tested, the observed result, and an
evidence path under `$ENG/evidence/`. For items that are safe, write "ruled out"
with the reason so a later session does not re-walk them. For anything confirmed,
stop and hand to the operator — do not draft or submit here.

## 7. Tick the box
Only after `redirect_trust.md` accounts for every item in scope for this host (each confirmed
or ruled out), tick the `Redirect destination trust check` box for this host in `$ENG/00_ledger.md`.

## Example of good output — `redirect_trust.md`

```markdown
### GET /login?next=  — CONFIRMED (unauthenticated)
next=//attacker-controlled.example sends the browser off-site after login page load.
Allowlist bypassed via scheme-relative form. Evidence: .../evidence/acme-openredirect-next.txt
```
