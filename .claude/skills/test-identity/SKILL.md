---
name: test-identity
description: Provision and keep track of the separate accounts an access-control check needs (account A, account B, unauthenticated, admin), storing each one's live session so other skills can act as a chosen account. Set this up before any cross-account check.
---

# Test identity

Access-control checks are only real with more than one live session. One account
cannot prove that it can reach another account's data — you need account A, account
B, and often an unauthenticated baseline, each with a working session. This skill
provisions and tracks them so `web-object-reference-walk`, `web-function-access-walk`,
`api-object-reference-walk`, and `api-function-access-walk` can actually confirm
instead of guessing.

Credentials are secrets. They live only under the engagement folder (gitignored)
and are never committed or sent anywhere but the target.

## Set up paths

```bash
: "${BL4CKAI_HOME:?}"; [ -f "$BL4CKAI_HOME/config.sh" ] && . "$BL4CKAI_HOME/config.sh"
export ENG="$ENGAGEMENTS_ROOT/A/<target>"
ID="$BL4CKAI_HOME/.claude/skills/test-identity/identity.sh"
```

## 1. The operator provisions the accounts (human-in-the-loop)

The operator creates the accounts the program allows — only accounts they own, and
using their program alias where required (e.g. an H1 alias). The agent does not
create accounts or solve login challenges. The operator logs each account in
through the web backend (`burp-driver` / `browser-interactor`) so a live session
exists.

## 2. Register each session here

Capture each account's on-the-wire auth (the `Cookie:` or `Authorization:` header
from a logged-in request in proxy history / the browser) and store it by name:

```bash
bash "$ID" set A     user  "Cookie: session=<A's cookie>"
bash "$ID" set B     user  "Authorization: Bearer <B's token>"
bash "$ID" set admin admin "Cookie: session=<admin cookie>"
# 'anon' needs no entry — it means "send no auth header"
bash "$ID" list
```

## 3. Checks pull identities by name

An access-control check acts as one account while holding another's identifier:

```bash
A_HDR=$(bash "$ID" get A)      # e.g. "Cookie: session=..."
# baseline as A on A's own object, then as A on B's object id, then anon:
# curl -s -H "$A_HDR" -H "$RESEARCH_HEADER" "https://$HOST/api/orders/<B's id>"
```

Pass `RESEARCH_HEADER` too, and resolve `$HOST` through `scope-gate` first.

## 4. Keep sessions fresh

Sessions expire. When a request that should succeed starts returning a login
redirect/401, the token is stale: ask the operator to re-log that account and
`identity.sh set` it again. Note in the check whether a negative result might be a
dead token rather than real enforcement — a stale session fakes a "secure" verdict.

## Rules

- Only the operator's own / authorized accounts. Never use a real third party's.
- Store nothing sensitive outside `$ENG/identities/` (gitignored, mode 700/600).
- One proof request per finding; do not trawl another account's data wholesale.

## Example of good output — `identity.sh list`

```
  A          role=user     age=4m
  B          role=user     age=4m
  admin      role=admin    age=2m
```
