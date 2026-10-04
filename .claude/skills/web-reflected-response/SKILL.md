---
name: web-reflected-response
description: Check how values from a request appear in the server's immediate response, and whether the page treats those values as markup rather than plain text. Reads any configured reference notes first and records observations to the engagement folder.
---

# Immediate-response reflection (reflected XSS)

Plain name: Immediate-response reflection (reflected XSS). One technique, one skill. Run it against one host at a time,
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
if [ -n "${KB_ROOT:-}" ] && ([ -d "$KB_ROOT/Web/XSS Injection" ]); then
  cat "$KB_ROOT/Web/XSS Injection"/README.md 2>/dev/null || (ls "$KB_ROOT/Web/XSS Injection"/ && cat "$KB_ROOT/Web/XSS Injection"/*.md 2>/dev/null | head -400)
else
  echo "No reference library configured (KB_ROOT); using the method in this skill + public references."
fi
```

## 2. Find where request values land in the response
Enumerate parameters on the host (query, body, header, path), then for each send a
unique benign marker that is not a special character, e.g. `zq7x41k`, and locate it
in the response. A marker that never appears means no reflection — record that.

```bash
grep "$HOST" "$ENG/recon/historical_urls.txt" 2>/dev/null | grep '='   | sort -u > "$OUT/params.txt"
```

## 3. Classify the context of each reflection
Where the marker lands decides everything. Record which: element text; quoted or
unquoted attribute; `<script>`/JSON block the page evaluates; URL attribute
(`href`/`src`); comment; or style context.

## 4. Confirm interpretation with a minimal controlled marker
Using the context, construct the smallest input that would make the marker be
treated as markup rather than text, and confirm in a real browser (or via a proxy)
that it is interpreted, not merely echoed. Keep it a benign observable proof; never
target another real user.

## 5. Note the filtering and any bypass actually needed
If the controlled marker is stripped or encoded, record exactly what happened, then
consult the reference notes (if configured) for the matching context.

## 6. Record → `checks/$HOST/reflected_response.md`
Write one entry per item checked: what was tested, the observed result, and an
evidence path under `$ENG/evidence/`. For items that are safe, write "ruled out"
with the reason so a later session does not re-walk them. For anything confirmed,
stop and hand to the operator — do not draft or submit here.

## 7. Tick the box
Only after `reflected_response.md` accounts for every item in scope for this host (each confirmed
or ruled out), tick the `Immediate-response reflection check` box for this host in `$ENG/00_ledger.md`.

## Example of good output — `reflected_response.md`

```markdown
### param `q` on /search  — CONFIRMED
Context: element text between result tags. Smallest input rendered as an element
and its benign marker ran in a controlled test. No filtering on this parameter.
Evidence: $ENG/evidence/acme-q-search.png

### param `ref` on /go  — RULED OUT
Context: inside href="" — quotes and angle brackets entity-encoded on output every
time. Not interpretable.

### param `lang` on /  — NO REFLECTION
Marker zq7x41k never appeared in the response.
```
