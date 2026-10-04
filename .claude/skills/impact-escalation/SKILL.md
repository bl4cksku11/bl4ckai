---
name: impact-escalation
description: Take a confirmed result and push it to its strongest honest demonstration, including combining it with other confirmed results, before it is written up — because reports are rewarded on demonstrated impact, not on the raw issue.
---

# Impact escalation

A confirmed issue is the start, not the end. Programs pay on demonstrated impact, so
before `finding-draft` runs, this takes a confirmed result and asks: what is the
strongest consequence I can actually show, and does it combine with anything else
already confirmed? It escalates evidence, never severity on paper.

Runs after a check confirms, before (or feeding) `finding-draft`.

## 1. Push the single finding to its real ceiling

For the confirmed result, ask what an attacker actually reaches from it, and
demonstrate the furthest honest point (own accounts, no data theft):

- reflected/stored script execution → what action can it drive for another user
  (a state change), not just `alert(1)`.
- object-reference read → is write/delete of another account's record also exposed.
- open redirect → does it land in a federated/login flow (token capture shape).
- info leak → does the leaked value unlock another request.
- SSRF reach → internal service reachable (stop at reach; operator scopes depth).

Demonstrate the ceiling you can reach safely; record where you deliberately stopped
and why.

## 2. Chain with other confirmed results

Read `$ENG/checks/**` for other confirmed items and test realistic combinations:

- low-severity + an auth mechanism → account takeover?
- open redirect + OAuth/SSO callback → token theft?
- request-boundary issue + a shared cache → cross-user impact?
- IDOR + mass-assignment → privilege change on another account?

A chain is one finding (report it as the chain), with each link's evidence.

## 3. Record the escalation

Write `$ENG/checks/<scope>/<slug>_impact.md`: the base result, the demonstrated
ceiling (with evidence paths), any chain and its links, and the honest severity the
demonstration supports. This becomes the Impact + Severity backbone of the draft.

## Discipline

Escalate the demonstration, not the claim. An honest Medium with a crisp PoC beats
an inflated High the evidence does not carry — the operator's name is on it. Keep
everything to owned accounts; stop before real harm and say so.

## Example of good output — `<slug>_impact.md`

```markdown
Base: IDOR read on GET /api/orders/{id} (confirmed).
Ceiling: PUT /api/orders/{id} also ignores owner → can MODIFY another user's order
(shipping address) — demonstrated on two owned accounts. Stopped before any real
order change on a third party.
Chain: + stored-name render on /admin → modified order surfaces in admin view.
Severity the demo supports: High (CVSS 8.1 — integrity of other users' records).
Evidence: $ENG/evidence/idor-orders-write.txt, admin-render.png
```
