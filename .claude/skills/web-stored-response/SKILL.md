---
name: web-stored-response
description: Check whether values submitted in one request are saved and later shown to a viewer in a place where the page treats them as markup rather than plain text. Reads reference notes first and records observations to the engagement folder.
---

# Stored script execution (stored XSS)

Plain name: Stored script execution (stored XSS). One technique, one skill. Run it against one host at a time,
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

## 2. Find inputs that are saved and shown back later
List every feature that stores input and renders it to someone later: profiles,
comments, names, support tickets, filenames, webhook/label fields, anything an
admin panel displays. For each, submit a unique benign marker (e.g. `zq7x41k`),
then load every view that could render it — including views seen by a *different*
account or role than the one that submitted it.

## 3. Classify the render context where the marker appears
Same contexts as the immediate-response case: element text, quoted/unquoted
attribute, script/JSON block, URL attribute, comment, style. Note the context per
sink, because the same stored value may render in several places.

## 4. Confirm interpretation with a minimal controlled marker
Build the smallest input that would make the stored value be treated as markup in
that context (KB gives the minimal form), submit it once, and confirm in a real
browser on the rendering view that it is interpreted, not escaped. Keep it a
benign observable proof; never target another real user's session.

## 5. Record who renders it
Stored issues are worth more when the render view belongs to another user or an
admin. Record the submitting role and every role/view that renders it.

## 6. Record → `checks/$HOST/stored_render.md`
Write one entry per item checked: what was tested, the observed result, and an
evidence path under `$ENG/evidence/`. For items that are safe, write "ruled out"
with the reason so a later session does not re-walk them. For anything confirmed,
stop and hand to the operator — do not draft or submit here.

## 7. Tick the box
Only after `stored_render.md` accounts for every item in scope for this host (each confirmed
or ruled out), tick the `Stored-and-rendered check` box for this host in `$ENG/00_ledger.md`.

## Example of good output — `stored_render.md`

```markdown
### field `displayName` on /profile  — CONFIRMED (admin view renders)
Stored via PATCH /api/profile; rendered unescaped in element text at /admin/users.
Submitting role: basic user. Rendering role: admin. Benign marker interpreted.
Evidence: $ENG/evidence/acme-admin-displayname.png
```
