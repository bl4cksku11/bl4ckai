---
name: source-dependency-audit
description: Check a project's third-party dependencies against known advisories, and whether the affected code is actually reachable from this project.
---

# Dependency audit

Plain name: Dependency audit. One thing, one skill. Work one repo at a time, from the
plan in `02_strategy.md`. Stay in scope. This skill observes and records only — it
never drafts, submits, or contacts anyone. A confirmed result flows to `dedup-check`
→ `finding-draft`; the operator validates and submits.

## 1. Set up paths, then read any configured reference notes

```bash
: "${BL4CKAI_HOME:?set it to the harness repo root, e.g. export BL4CKAI_HOME=~/bl4ckai}"
[ -f "$BL4CKAI_HOME/config.sh" ] && . "$BL4CKAI_HOME/config.sh"
: "${ENGAGEMENTS_ROOT:=$BL4CKAI_HOME/engagements}"
TARGET=acme
LETTER=$(printf %s "$TARGET" | cut -c1 | tr '[:lower:]' '[:upper:]')
ENG="$ENGAGEMENTS_ROOT/$LETTER/$TARGET"
SCOPE=acme-api        # repo or module name under src/
OUT="$ENG/checks/$SCOPE"; mkdir -p "$OUT"
[ -n "${KB_ROOT:-}" ] && echo "KB_ROOT set — read your notes relevant to this area under $KB_ROOT first." \
  || echo "No reference library configured; use the method below + public references."
```

## 2. Enumerate and match dependencies
List direct and transitive dependencies with versions (osv-scanner / govulncheck /
the ecosystem's audit tool). Match against advisory databases.

## 3. Judge reachability — the part that matters
For each flagged dependency, read whether the vulnerable function is actually called
from this project's reachable paths. A match with no reachable call is noise; record
it as such. Note vendored/forked deps that may have missed upstream fixes.

## Record → `checks/$SCOPE/dependency_audit.md`
Write one entry per item checked: what was examined, what was observed, and an
evidence path under `$ENG/evidence/`. For anything safe, write "ruled out" with the
reason so a later pass does not re-walk it. For anything confirmed, capture the
proof and leave it for the operator — do not draft or submit here.

## Tick the box
Only after `dependency_audit.md` accounts for every item in scope for this repo (confirmed
or ruled out), tick the `Dependency audit` box for this repo in `$ENG/00_ledger.md`.

## Example of good output — `dependency_audit.md`

```markdown
### acme-api — dependencies — CONFIRMED reachable
lib/xmlparse 1.2 (advisory GHSA-xxxx) IS reached from the /import handler's parse
path. 6 other advisories present but not reachable (recorded). Vendored crypto/x is
3 commits behind an upstream fix.
Evidence: $ENG/checks/acme-api/dependency_audit.md
```
