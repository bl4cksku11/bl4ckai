---
name: web-path-resolution-check
description: Check how a feature resolves file paths and whether request values can reach files outside the intended directory. Reads reference notes first and records observations to the engagement folder.
---

# Path resolution / traversal + file inclusion

Plain name: Path resolution / traversal + file inclusion. One technique, one skill. Run it against one host at a time,
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
if [ -n "${KB_ROOT:-}" ] && ([ -d "$KB_ROOT/Web/Directory Traversal" ] || [ -d "$KB_ROOT/Web/File Inclusion" ]); then
  cat "$KB_ROOT/Web/Directory Traversal"/README.md 2>/dev/null || (ls "$KB_ROOT/Web/Directory Traversal"/ && cat "$KB_ROOT/Web/Directory Traversal"/*.md 2>/dev/null | head -400)
  cat "$KB_ROOT/Web/File Inclusion"/README.md 2>/dev/null || (ls "$KB_ROOT/Web/File Inclusion"/ && cat "$KB_ROOT/Web/File Inclusion"/*.md 2>/dev/null | head -400)
else
  echo "No reference library configured (KB_ROOT); using the method in this skill + public references."
fi
```

## 2. Find features that name a file
Downloads, document/report viewers, avatar/image loaders, template/language
selectors, log viewers, anything taking a filename, path, or template name.

## 3. Probe traversal and inclusion safely
Use the KB's encodings for traversal sequences (plain, encoded, double-encoded,
mixed separators). Aim first at a known-safe in-app file to prove the path is
influenced, then a benign out-of-root file that is non-sensitive. Note whether the
feature reads the file or includes/executes it.

## 4. Confirm minimally
Prove you reached an unintended but non-sensitive file (e.g. a world-readable,
non-secret system file the KB suggests). Do not read credentials, keys, or other
users' data; hand to the operator for impact scoping.

## 5. Record per feature
Feature, parameter, encoding that worked, whether read vs include, and the proof
request. Rule out features that correctly canonicalize/confine the path.

## 6. Record → `checks/$HOST/path_resolution.md`
Write one entry per item checked: what was tested, the observed result, and an
evidence path under `$ENG/evidence/`. For items that are safe, write "ruled out"
with the reason so a later session does not re-walk them. For anything confirmed,
stop and hand to the operator — do not draft or submit here.

## 7. Tick the box
Only after `path_resolution.md` accounts for every item in scope for this host (each confirmed
or ruled out), tick the `Path resolution check` box for this host in `$ENG/00_ledger.md`.

## Example of good output — `path_resolution.md`

```markdown
### GET /download?file=  — CONFIRMED (read, traversal)
file=../../../../etc/hostname returned host name → path influenced beyond root.
Read-only; stopped at non-sensitive file. Evidence: .../evidence/acme-traversal-download.txt
```
