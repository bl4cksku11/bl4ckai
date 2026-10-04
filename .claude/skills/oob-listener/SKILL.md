---
name: oob-listener
description: Provide an out-of-band callback host the agent can plant in a request and later check for hits, so blind, no-response-visible behaviors can still be confirmed. Works whichever web backend the operator uses.
---

# Out-of-band listener

Some behaviors return nothing visible — a server fetches a URL, a parser resolves an
external reference, a command runs — and the only proof is a callback to a host you
control. This skill gives every path a backend-agnostic way to get that callback,
so blind checks are not dead for non-Burp users (the review's gap).

Chosen by `OOB_BACKEND`:

- `collaborator` — Burp users: use `burp-driver`'s `mcp__burpsuite__generate_collaborator_payload`
  and `get_collaborator_interactions`. Nothing else needed.
- `interactsh` — anyone: a client you run locally that mints a unique callback host
  and polls for interactions. Install via `tool-setup` (it is in the core set).

## interactsh usage

```bash
: "${BL4CKAI_HOME:?}"; [ -f "$BL4CKAI_HOME/config.sh" ] && . "$BL4CKAI_HOME/config.sh"
export PATH="/usr/local/bin:$HOME/go/bin:$PATH"
# start a session; it prints a unique host like c4ca...oast.pro and streams hits
interactsh-client -v ${OOB_SERVER:+-s "$OOB_SERVER"} -o "$ENG/evidence/oob.log" &
```

Take the printed callback host, plant it in the parameter under test (as a URL, an
external entity target, a command that resolves DNS/HTTP to it), then read
`$ENG/evidence/oob.log` for an interaction from the target's IP.

## What a hit proves (and what it doesn't)

- A DNS or HTTP interaction from the target's infrastructure confirms the behavior
  is real and server-side. That is the finding to record.
- It does not by itself show impact depth — stop at the callback, capture it, and
  hand to the operator to scope further. Do not pull cloud credentials or pivot.

## Which checks use this

`web-server-fetch-probe`, `web-xml-entity-check`, `web-os-command-influence`, and
`cloud-metadata-reach` confirm through here. Record the callback host used, the
planted request, and the matching line from `oob.log` (its IP + timestamp) under
`$ENG/evidence/`.

## Privacy

A public interactsh server sees your callback hostnames and the target's resolver
IPs. For sensitive engagements, self-host interactsh and set `OOB_SERVER` to it.

## Example of good output

```
backend=interactsh host=c4ca4238a0b9.oast.pro
Planted in POST /api/unfurl {"url":"http://c4ca4238a0b9.oast.pro"}
oob.log: [DNS] c4ca4238a0b9.oast.pro from 203.0.113.9 @ 13:40:22  → server-side fetch CONFIRMED
Evidence: $ENG/evidence/oob.log
```
