---
name: source-auth-logic-review
description: Read how a codebase decides who may do what, and look for actions that are missing the check or check the wrong thing.
---

# Authorization logic review

Plain name: Authorization logic review. One thing, one skill. Work one repo at a time, from the
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

## 2. Locate the enforcement points
Find the middleware/guards/decorators that enforce authentication and authorization,
and the places that should use them. Build a table of sensitive actions vs. the check
that protects each.

## 3. Find the gaps by reading
Look for actions with no check, checks that compare the wrong field (role vs owner),
checks that run after the effect, and object lookups that ignore the caller. Quote
file:line for each gap.

## Record → `checks/$SCOPE/auth_logic.md`
Write one entry per item checked: what was examined, what was observed, and an
evidence path under `$ENG/evidence/`. For anything safe, write "ruled out" with the
reason so a later pass does not re-walk it. For anything confirmed, capture the
proof and leave it for the operator — do not draft or submit here.

## Tick the box
Only after `auth_logic.md` accounts for every item in scope for this repo (confirmed
or ruled out), tick the `Authorization logic review` box for this repo in `$ENG/00_ledger.md`.

## Example of good output — `auth_logic.md`

```markdown
### acme-api — authz review — CONFIRMED
handlers/admin.go:/users/{id}/role has no RequireRole middleware (every sibling route
does). store fetch by id ignores tenant on 3 endpoints. file:line quoted.
Evidence: $ENG/checks/acme-api/auth_logic.md
```
