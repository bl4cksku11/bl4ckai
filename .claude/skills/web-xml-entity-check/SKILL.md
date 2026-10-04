---
name: web-xml-entity-check
description: Check how a feature parses submitted XML and whether it resolves external references during parsing. Reads reference notes first and records observations to the engagement folder.
---

# XML entity processing (XXE)

Plain name: XML entity processing (XXE). One technique, one skill. Run it against one host at a time,
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
if [ -n "${KB_ROOT:-}" ] && ([ -d "$KB_ROOT/Web/XXE Injection" ]); then
  cat "$KB_ROOT/Web/XXE Injection"/README.md 2>/dev/null || (ls "$KB_ROOT/Web/XXE Injection"/ && cat "$KB_ROOT/Web/XXE Injection"/*.md 2>/dev/null | head -400)
else
  echo "No reference library configured (KB_ROOT); using the method in this skill + public references."
fi
```

## 2. Find XML entry points
Direct XML bodies, SOAP endpoints, SAML/XML SSO, file formats that are XML under
the hood (DOCX/XLSX/SVG), and any API that accepts `application/xml` or switches on
content-type.

## 3. Probe external-reference resolution with OOB
Submit a document that defines an external reference to a listener you own
(KB gives the forms). A callback confirms the parser resolves external entities.
Use OOB/blind confirmation; prefer it over trying to read local files.

## 4. Confirm minimally, then hand off
A callback is enough to prove the behavior. If local-file read is in scope, confirm
with a single non-sensitive file and stop; hand to the operator for scoping.

## 5. Record per entry point
Entry point, content-type, whether external references resolve (OOB proof), and the
submitted document.

## 6. Record → `checks/$HOST/xml_entity.md`
Write one entry per item checked: what was tested, the observed result, and an
evidence path under `$ENG/evidence/`. For items that are safe, write "ruled out"
with the reason so a later session does not re-walk them. For anything confirmed,
stop and hand to the operator — do not draft or submit here.

## 7. Tick the box
Only after `xml_entity.md` accounts for every item in scope for this host (each confirmed
or ruled out), tick the `XML entity processing check` box for this host in `$ENG/00_ledger.md`.

## Example of good output — `xml_entity.md`

```markdown
### POST /api/import (application/xml)  — CONFIRMED (OOB)
External-entity doc caused the parser to fetch from the OOB listener (server IP).
External references resolve. Stopped at OOB. Evidence: .../evidence/acme-xxe-import.txt
```
