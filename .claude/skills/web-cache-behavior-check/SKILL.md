---
name: web-cache-behavior-check
description: Review how shared caches decide what to store and serve, and whether one viewer can be served content meant for another. Reads reference notes first and records observations to the engagement folder.
---

# Cache behavior (deception/poisoning)

Plain name: Cache behavior (deception/poisoning). One technique, one skill. Run it against one host at a time,
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
if [ -n "${KB_ROOT:-}" ] && ([ -d "$KB_ROOT/Web/Web Cache Deception" ]); then
  cat "$KB_ROOT/Web/Web Cache Deception"/README.md 2>/dev/null || (ls "$KB_ROOT/Web/Web Cache Deception"/ && cat "$KB_ROOT/Web/Web Cache Deception"/*.md 2>/dev/null | head -400)
else
  echo "No reference library configured (KB_ROOT); using the method in this skill + public references."
fi
```

## 2. Learn the caching rules
From recon, note the CDN/cache and its cache headers. Identify what the cache keys
on (path, query, some headers) and what it ignores — the gap between keyed and
unkeyed inputs is where issues live.

## 3. Probe the two shapes safely
Deception: request a dynamic, personal page with a path suffix the cache treats as
static (e.g. a trailing `/x.css`) and see if the personal response gets cached and
then served to an unauthenticated fetch. Poisoning: vary an unkeyed input and see
if it influences a stored response. Use your own account's personal data as the
canary; do not cache another real user's data.

## 4. Confirm minimally
The proof is your own personal response being served from cache to a separate
unauthenticated request, or an unkeyed input persisting into a cached response.
Clean up by requesting the correct URL afterward where possible; hand to operator.

## 5. Record
Cache vendor, keyed vs unkeyed inputs, which shape was confirmed, and the paired
requests that prove it.

## 6. Record → `checks/$HOST/cache_behavior.md`
Write one entry per item checked: what was tested, the observed result, and an
evidence path under `$ENG/evidence/`. For items that are safe, write "ruled out"
with the reason so a later session does not re-walk them. For anything confirmed,
stop and hand to the operator — do not draft or submit here.

## 7. Tick the box
Only after `cache_behavior.md` accounts for every item in scope for this host (each confirmed
or ruled out), tick the `Cache behavior check` box for this host in `$ENG/00_ledger.md`.

## Example of good output — `cache_behavior.md`

```markdown
### /account  — CONFIRMED (deception)
/account/nonexistent.css returns the personal account page and the cache stores it;
a separate unauthenticated GET of that URL returns my cached personal data. Own
data as canary. Evidence: .../evidence/acme-cache-deception.txt
```
