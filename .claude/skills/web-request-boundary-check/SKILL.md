---
name: web-request-boundary-check
description: Check whether a front-end and back-end disagree on where one request ends and the next begins. Reads reference notes first and records observations to the engagement folder.
---

# Request boundary parsing (smuggling/desync)

Plain name: Request boundary parsing (smuggling/desync). One technique, one skill. Run it against one host at a time,
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
if [ -n "${KB_ROOT:-}" ] && ([ -d "$KB_ROOT/Web/Request Smuggling" ] || [ -d "$KB_ROOT/Web/CRLF Injection" ]); then
  cat "$KB_ROOT/Web/Request Smuggling"/README.md 2>/dev/null || (ls "$KB_ROOT/Web/Request Smuggling"/ && cat "$KB_ROOT/Web/Request Smuggling"/*.md 2>/dev/null | head -400)
  cat "$KB_ROOT/Web/CRLF Injection"/README.md 2>/dev/null || (ls "$KB_ROOT/Web/CRLF Injection"/ && cat "$KB_ROOT/Web/CRLF Injection"/*.md 2>/dev/null | head -400)
else
  echo "No reference library configured (KB_ROOT); using the method in this skill + public references."
fi
```

## 2. Identify the chain
Note the front-end/CDN and back-end from recon. Boundary issues need a proxy in
front of an origin; record the stack before probing.

## 3. Probe boundary disagreement safely
Use the KB's timing-based detection first (it is the safe, non-poisoning signal):
send requests whose framing is ambiguous and measure whether the back-end waits
for more bytes. Prefer a dedicated tool over hand-crafting. Do not run a live
poisoning payload against shared infrastructure.

## 4. Confirm with timing, then stop
A reproducible timing differential is the finding to record; escalation to actual
request capture is operator-gated because it can affect other users. Also note any
header/CRLF reflection into the response line that could split responses.

## 5. Record
Stack, detection method, the timing signal observed, and whether header/CR-LF
reflection was present. Explicitly note that no cross-user poisoning was run.

## 6. Record → `checks/$HOST/request_boundary.md`
Write one entry per item checked: what was tested, the observed result, and an
evidence path under `$ENG/evidence/`. For items that are safe, write "ruled out"
with the reason so a later session does not re-walk them. For anything confirmed,
stop and hand to the operator — do not draft or submit here.

## 7. Tick the box
Only after `request_boundary.md` accounts for every item in scope for this host (each confirmed
or ruled out), tick the `Request boundary parsing check` box for this host in `$ENG/00_ledger.md`.

## Example of good output — `request_boundary.md`

```markdown
### acme.com (CDN → origin)  — CONFIRMED (timing, CL.TE)
Ambiguous framing causes back-end to wait 5s consistently vs 0s baseline → desync
present. Timing only; no poisoning run; handed to operator. Evidence: .../evidence/acme-desync-timing.txt
```
