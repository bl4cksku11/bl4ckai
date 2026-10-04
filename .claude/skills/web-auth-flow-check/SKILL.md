---
name: web-auth-flow-check
description: Walk sign-in, password reset, federated sign-in, and second-factor steps for parts that can be skipped, reused, or confused. Reads reference notes first and records observations to the engagement folder.
---

# Authentication flow (reset, OAuth/OIDC, SAML, MFA)

Plain name: Authentication flow (reset, OAuth/OIDC, SAML, MFA). One technique, one skill. Run it against one host at a time,
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
if [ -n "${KB_ROOT:-}" ] && ([ -d "$KB_ROOT/Web/OAuth Misconfiguration" ] || [ -d "$KB_ROOT/Web/SAML Injection" ] || [ -d "$KB_ROOT/Web/Account Takeover" ]); then
  cat "$KB_ROOT/Web/OAuth Misconfiguration"/README.md 2>/dev/null || (ls "$KB_ROOT/Web/OAuth Misconfiguration"/ && cat "$KB_ROOT/Web/OAuth Misconfiguration"/*.md 2>/dev/null | head -400)
  cat "$KB_ROOT/Web/SAML Injection"/README.md 2>/dev/null || (ls "$KB_ROOT/Web/SAML Injection"/ && cat "$KB_ROOT/Web/SAML Injection"/*.md 2>/dev/null | head -400)
  cat "$KB_ROOT/Web/Account Takeover"/README.md 2>/dev/null || (ls "$KB_ROOT/Web/Account Takeover"/ && cat "$KB_ROOT/Web/Account Takeover"/*.md 2>/dev/null | head -400)
else
  echo "No reference library configured (KB_ROOT); using the method in this skill + public references."
fi
```

## 2. Map every authentication flow present
Password login, password reset/recovery, email change, federated sign-in
(OAuth/OIDC), enterprise SSO (SAML), and second-factor enrolment/verification.

## 3. Walk each flow for skippable or reusable steps
Reset: token predictability, token not bound to the account, host-header driven
reset links, token reuse. Federated: redirect_uri handling, state/nonce checks,
code reuse, account linking by email without proof. SAML: signature checked,
assertion replay, audience. MFA: the verify step enforced server-side, backup-code
limits, enrolment bypass. The KB details each.

## 4. Confirm minimally on accounts you own
Use two accounts you control. Prove a step can be skipped or a token reused without
touching any real third-party account; hand to the operator before any broader
demonstration.

## 5. Record per flow
Flow, the step that failed to enforce, and the proof across your own accounts.

## 6. Record → `checks/$HOST/auth_flow.md`
Write one entry per item checked: what was tested, the observed result, and an
evidence path under `$ENG/evidence/`. For items that are safe, write "ruled out"
with the reason so a later session does not re-walk them. For anything confirmed,
stop and hand to the operator — do not draft or submit here.

## 7. Tick the box
Only after `auth_flow.md` accounts for every item in scope for this host (each confirmed
or ruled out), tick the `Authentication flow walk` box for this host in `$ENG/00_ledger.md`.

## Example of good output — `auth_flow.md`

```markdown
### password reset  — CONFIRMED (host-header link)
Reset link host derived from Host header; setting it to a domain I control delivers
a valid reset token for the victim-role account I own. Proven on own accounts.
Evidence: .../evidence/acme-reset-hostheader.txt
```
