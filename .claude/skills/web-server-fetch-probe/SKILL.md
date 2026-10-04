---
name: web-server-fetch-probe
description: Check whether a feature that fetches a URL on the server's behalf can be pointed at internal or unintended destinations, and what the response reveals. Reads reference notes first and records observations to the engagement folder.
---

# Server-initiated request behavior (SSRF)

Plain name: Server-initiated request behavior (SSRF). One technique, one skill. Run it against one host at a time,
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
if [ -n "${KB_ROOT:-}" ] && ([ -d "$KB_ROOT/Web/Server Side Request Forgery" ]); then
  cat "$KB_ROOT/Web/Server Side Request Forgery"/README.md 2>/dev/null || (ls "$KB_ROOT/Web/Server Side Request Forgery"/ && cat "$KB_ROOT/Web/Server Side Request Forgery"/*.md 2>/dev/null | head -400)
else
  echo "No reference library configured (KB_ROOT); using the method in this skill + public references."
fi
```

## 2. Find features that fetch a URL for you
Webhooks, URL preview/unfurl, import-from-URL, PDF/screenshot/thumbnail
generators, avatar-by-URL, integrations that call back. List each and the
parameter that holds the destination.

## 3. Point them at a destination you control
Use an out-of-band listener you own. Confirm the server actually makes the request
and record the source IP, headers, and any credentials it sends. This proves the
fetch is server-side before anything else.

## 4. Probe reachability without harm
Test whether internal names/addresses and non-HTTP schemes are reachable, and
whether the response (or its timing/error) is returned to you. Observe only; do
not pull cloud credential endpoints or move laterally — record reachability and
hand to the operator. The KB lists the safe confirmation set.

## 5. Record per feature
Feature, destination parameter, whether the fetch is server-side (OOB proof),
what internal reachability was observed, and whether responses are reflected.

## 6. Record → `checks/$HOST/server_fetch.md`
Write one entry per item checked: what was tested, the observed result, and an
evidence path under `$ENG/evidence/`. For items that are safe, write "ruled out"
with the reason so a later session does not re-walk them. For anything confirmed,
stop and hand to the operator — do not draft or submit here.

## 7. Tick the box
Only after `server_fetch.md` accounts for every item in scope for this host (each confirmed
or ruled out), tick the `Server-initiated request probe` box for this host in `$ENG/00_ledger.md`.

## Example of good output — `server_fetch.md`

```markdown
### POST /api/unfurl {url}  — CONFIRMED server-side fetch
OOB listener received GET from 10.x server IP with internal UA. Internal host
names resolve and 200/timeouts differ (blind). Response body not reflected.
Handed to operator for scope-safe internal reachability. Evidence: .../evidence/acme-ssrf-oob.txt
```
