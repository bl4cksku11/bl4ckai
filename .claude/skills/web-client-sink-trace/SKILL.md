---
name: web-client-sink-trace
description: Trace how values the page reads from its own URL or inputs reach browser interfaces that build or run page content, without the server being involved. Reads reference notes first and records observations to the engagement folder.
---

# Client-side sink execution (DOM XSS)

Plain name: Client-side sink execution (DOM XSS). One technique, one skill. Run it against one host at a time,
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
if [ -n "${KB_ROOT:-}" ] && ([ -d "$KB_ROOT/Web/XSS Injection" ] || [ -d "$KB_ROOT/Web/Dom Clobbering" ]); then
  cat "$KB_ROOT/Web/XSS Injection"/README.md 2>/dev/null || (ls "$KB_ROOT/Web/XSS Injection"/ && cat "$KB_ROOT/Web/XSS Injection"/*.md 2>/dev/null | head -400)
  cat "$KB_ROOT/Web/Dom Clobbering"/README.md 2>/dev/null || (ls "$KB_ROOT/Web/Dom Clobbering"/ && cat "$KB_ROOT/Web/Dom Clobbering"/*.md 2>/dev/null | head -400)
else
  echo "No reference library configured (KB_ROOT); using the method in this skill + public references."
fi
```

## 2. Collect the page's own scripts
Use the inventory from recon (`.../recon/js_files.txt`). For each in-scope page,
list the scripts it loads and inline scripts it defines.

## 3. Find sources and sinks
Sources are values the page reads itself: `location`, `location.hash`,
`location.search`, `document.referrer`, `postMessage` data, `localStorage`,
cookies. Sinks are interfaces that turn a string into content or code:
`innerHTML`/`outerHTML`, `document.write`, `insertAdjacentHTML`, `eval`,
`setTimeout`/`setInterval` with a string, `Function`, framework HTML bindings,
`location`/`href` assignment.

## 4. Trace source → sink by reading the code
For each sink, read backward to see whether a source reaches it without being
neutralized on the client. The server is not involved, so confirm entirely in the
browser: set the source (e.g. a `#...` fragment) and observe the sink act on it.

## 5. Confirm with a benign observable change
Prove the path with the smallest observable client-side effect; do not use a
destructive or cross-user proof.

## 6. Record → `checks/$HOST/client_sink.md`
Write one entry per item checked: what was tested, the observed result, and an
evidence path under `$ENG/evidence/`. For items that are safe, write "ruled out"
with the reason so a later session does not re-walk them. For anything confirmed,
stop and hand to the operator — do not draft or submit here.

## 7. Tick the box
Only after `client_sink.md` accounts for every item in scope for this host (each confirmed
or ruled out), tick the `Client-side sink trace` box for this host in `$ENG/00_ledger.md`.

## Example of good output — `client_sink.md`

```markdown
### sink `innerHTML` in app.js:842  — CONFIRMED
Source: location.hash, read at app.js:860 and written to #banner via innerHTML
with no sanitizer. Server not involved. Benign marker rendered as an element from
a crafted #fragment. Evidence: .../evidence/acme-domsink-banner.png
```
