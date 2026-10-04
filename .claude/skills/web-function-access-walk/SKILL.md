---
name: web-function-access-walk
description: Check whether actions and administrative endpoints enforce the caller's role, by requesting them as a lower-privileged or unauthenticated caller. Records observations to the engagement folder.
---

# Function-level access control

Plain name: Function-level access control. One technique, one skill. Run it against one host at a time,
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
if [ -n "${KB_ROOT:-}" ] && ([ -d "$KB_ROOT/Web/Insecure Management Interface" ] || [ -d "$KB_ROOT/Web/Business Logic Errors" ]); then
  cat "$KB_ROOT/Web/Insecure Management Interface"/README.md 2>/dev/null || (ls "$KB_ROOT/Web/Insecure Management Interface"/ && cat "$KB_ROOT/Web/Insecure Management Interface"/*.md 2>/dev/null | head -400)
  cat "$KB_ROOT/Web/Business Logic Errors"/README.md 2>/dev/null || (ls "$KB_ROOT/Web/Business Logic Errors"/ && cat "$KB_ROOT/Web/Business Logic Errors"/*.md 2>/dev/null | head -400)
else
  echo "No reference library configured (KB_ROOT); using the method in this skill + public references."
fi
```

## 2. Build the endpoint inventory by role
From recon and the crawl, list privileged actions: admin panels, user-management,
role changes, config, export, impersonation, feature flags. Note which role is
supposed to reach each.

Pull the two live sessions from `test-identity` (`A_HDR=$(bash "$BL4CKAI_HOME/.claude/skills/test-identity/identity.sh" get A)`, same for B; `anon` = no auth header) and send each request via `$REQ` with `-H "$A_HDR"`. A single identity cannot confirm an access-control finding.

## 3. Request privileged actions as a lower role
Replay each privileged request with a basic-user session, then with no session.
Watch for server-side enforcement vs. UI-only hiding: a hidden menu that still
answers its API call is the finding. Check method confusion (GET where POST is
expected) and alternate routes (`/admin` vs `/api/admin`).

## 4. Check forced browsing to unlinked endpoints
Use the historical URLs and JS endpoints to request admin routes never shown to a
basic user.

## 5. Record per action
Action, intended role, result as basic user, result as anonymous, and the proof
request. Rule out actions that returned a correct authorization error.

## 6. Record → `checks/$HOST/function_access.md`
Write one entry per item checked: what was tested, the observed result, and an
evidence path under `$ENG/evidence/`. For items that are safe, write "ruled out"
with the reason so a later session does not re-walk them. For anything confirmed,
stop and hand to the operator — do not draft or submit here.

## 7. Tick the box
Only after `function_access.md` accounts for every item in scope for this host (each confirmed
or ruled out), tick the `Function-level access control walk` box for this host in `$ENG/00_ledger.md`.

## Example of good output — `function_access.md`

```markdown
### POST /api/admin/users/{id}/role  — CONFIRMED
Basic-user session can set own role to admin; server does not re-check caller role.
Proof: req with basic cookie, body {"role":"admin"} → 200, subsequent calls admin.
Evidence: .../evidence/acme-funcauth-role.txt
```
