---
name: web-markup-gadget-survey
description: Survey a page's existing scripts and markup for reusable fragments that influence how later content is assembled, and document the available building blocks. Reads reference notes first and records observations to the engagement folder.
---

# Markup/script gadget survey (gadget gathering)

Plain name: Markup/script gadget survey (gadget gathering). One technique, one skill. Run it against one host at a time,
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
if [ -n "${KB_ROOT:-}" ] && ([ -d "$KB_ROOT/Web/Dom Clobbering" ] || [ -d "$KB_ROOT/Web/Prototype Pollution" ]); then
  cat "$KB_ROOT/Web/Dom Clobbering"/README.md 2>/dev/null || (ls "$KB_ROOT/Web/Dom Clobbering"/ && cat "$KB_ROOT/Web/Dom Clobbering"/*.md 2>/dev/null | head -400)
  cat "$KB_ROOT/Web/Prototype Pollution"/README.md 2>/dev/null || (ls "$KB_ROOT/Web/Prototype Pollution"/ && cat "$KB_ROOT/Web/Prototype Pollution"/*.md 2>/dev/null | head -400)
else
  echo "No reference library configured (KB_ROOT); using the method in this skill + public references."
fi
```

## 2. Inventory the client-side libraries and their versions
From the loaded scripts, list each framework/library and version. Known versions
often ship documented building blocks that turn a limited foothold into script
execution; the KB notes which libraries have them.

## 3. Catalogue usable fragments
Record: HTML sanitizer in use and its config, any template/binding engine, object
merge/extend utilities (relevant to property-pollution chains), named-element
lookups the code relies on (relevant to clobbering), and any global config object
the page reads at runtime.

## 4. Map which fragments pair with which sink
This skill does not confirm execution on its own — it produces the catalogue that
`web-client-sink-trace` and the response-rendering checks draw on. For each
fragment, note the sink it could feed and the precondition it needs.

## 5. Record as a reusable table
One row per fragment: library/version, fragment, precondition, the sink it pairs
with, KB reference.

## 6. Record → `checks/$HOST/gadget_survey.md`
Write one entry per item checked: what was tested, the observed result, and an
evidence path under `$ENG/evidence/`. For items that are safe, write "ruled out"
with the reason so a later session does not re-walk them. For anything confirmed,
stop and hand to the operator — do not draft or submit here.

## 7. Tick the box
Only after `gadget_survey.md` accounts for every item in scope for this host (each confirmed
or ruled out), tick the `Markup/script gadget survey` box for this host in `$ENG/00_ledger.md`.

## Example of good output — `gadget_survey.md`

```markdown
| Fragment | Library | Precondition | Pairs with | KB |
| global `window.__cfg` merged from query | app bundle | query param reflected into config | property-pollution → client sink | Prototype Pollution/README.md |
| sanitizer allows `<img>` with event attrs (old config) | DOMPurify 2.0.1 | stored value rendered | stored-render | XSS Injection/README.md |
```
