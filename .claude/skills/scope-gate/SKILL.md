---
name: scope-gate
description: Resolve a host or address against the engagement's authorized scope and return in / out / ask, so no step sends traffic to something it should not. Every skill that touches the network calls this first.
---

# Scope gate

The authorization check that runs before any network traffic. It answers one
question — "are we allowed to touch this host?" — from the engagement's own scope
file, and the caller obeys the verdict. For a public tool, this is what keeps the
operator inside authorization and out of trouble (CONVENTIONS §12).

## Use (every network-touching skill calls this before its first request)

```bash
: "${BL4CKAI_HOME:?}"; [ -f "$BL4CKAI_HOME/config.sh" ] && . "$BL4CKAI_HOME/config.sh"
export ENG="$ENGAGEMENTS_ROOT/A/<target>"
GATE="$BL4CKAI_HOME/.claude/skills/scope-gate/scope_check.sh"

if bash "$GATE" "$TARGET_HOST"; then
  :   # IN — proceed
else case $? in
  1) echo "OUT of scope — record 'skipped, out of scope' and move on"; exit 0;;
  2) echo "ASK — stop and confirm with the operator before any traffic";;
esac; fi
```

Verdicts: `IN` (exit 0) proceed · `OUT` (exit 1) never send, record and skip ·
`ASK` (exit 2) stop and ask the operator — never assume authorization at the edge.

## The scope file

`engagement-setup` writes `$ENG/scope.txt` from the program policy. One pattern per
line; plain = in-scope, leading `-` = out-of-scope; `#` comments ignored. Patterns
are globs over the hostname. **Deny wins** over allow.

```
*.acme.com
api.acme.io
-blog.acme.com
-*.marketing.acme.com
```

Keep it current: when recon finds a new host, resolve it here before testing, and
when the operator clarifies scope, update the file.

## Notes

- `*.acme.com` matches subdomains (`api.acme.com`) but NOT the bare apex
  `acme.com` — if the apex is in scope, add it as its own line, or it resolves ASK.
- Precedence is deny-wins (verified): a host matching both an allow glob and a `-`
  deny is OUT. So `*.acme.com` + `-admin.acme.com` keeps `admin.acme.com` out.
- Out-of-scope is a first-class, recorded outcome — it is not an error. Write it to
  the check note so a later pass does not re-walk it.
- This gate is about authorization, not reachability; a host can be in scope and
  down. Pair with recon, not instead of it.

## Example of good output

```
$ scope_check.sh https://api.acme.com/v3/users
IN   api.acme.com  (matches *.acme.com)
$ scope_check.sh blog.acme.com
OUT  blog.acme.com  (matches -blog.acme.com)
$ scope_check.sh partner.example.net
ASK  partner.example.net  (no in-scope pattern matched — confirm with operator)
```
