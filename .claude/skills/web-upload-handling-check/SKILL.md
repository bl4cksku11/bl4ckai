---
name: web-upload-handling-check
description: Check how uploaded files are validated, stored, and served, and whether a file can be served or processed in an unintended way. Reads reference notes first and records observations to the engagement folder.
---

# File upload handling

Plain name: File upload handling. One technique, one skill. Run it against one host at a time,
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
if [ -n "${KB_ROOT:-}" ] && ([ -d "$KB_ROOT/Web/Upload Insecure Files" ]); then
  cat "$KB_ROOT/Web/Upload Insecure Files"/README.md 2>/dev/null || (ls "$KB_ROOT/Web/Upload Insecure Files"/ && cat "$KB_ROOT/Web/Upload Insecure Files"/*.md 2>/dev/null | head -400)
else
  echo "No reference library configured (KB_ROOT); using the method in this skill + public references."
fi
```

## 2. Map upload features and their rules
For each upload, record accepted types, how type is checked (extension, declared
content-type, content sniffing), where the file is stored, and at what URL it is
served.

## 3. Probe the validation and the serving path
Test the KB's cases: extension/content-type mismatch, double extensions, content
that sniffs as something else, path/filename control in the stored name, and
whether the served response has a content-type that causes the browser to run the
file in the app's origin. Also note archive handling (entries that escape the
extract dir).

## 4. Confirm minimally
The proof is a file that is stored and then served/processed in an unintended way —
e.g. served with an active content-type from an in-origin path. Use a benign marker
file; do not plant executable server-side code beyond what proves the gap, and hand
to the operator.

## 5. Record per feature
Feature, validation observed, the case that passed, the served URL + content-type,
and the proof.

## 6. Record → `checks/$HOST/upload_handling.md`
Write one entry per item checked: what was tested, the observed result, and an
evidence path under `$ENG/evidence/`. For items that are safe, write "ruled out"
with the reason so a later session does not re-walk them. For anything confirmed,
stop and hand to the operator — do not draft or submit here.

## 7. Tick the box
Only after `upload_handling.md` accounts for every item in scope for this host (each confirmed
or ruled out), tick the `File upload handling check` box for this host in `$ENG/00_ledger.md`.

## Example of good output — `upload_handling.md`

```markdown
### avatar upload  — CONFIRMED (served as active content)
A benign .html disguised as .png is stored and served from the app origin with
text/html, so the browser renders it in-origin. Benign marker only.
Evidence: .../evidence/acme-upload-htmlavatar.txt
```
