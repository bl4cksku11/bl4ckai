---
name: graphql-probe
description: Examine a GraphQL endpoint for its distinctive behaviors — schema disclosure, per-field access gaps, batching, and alias-based limit bypass — which a generic API map does not cover. Reads reference notes first and records to the engagement folder.
---

# GraphQL probe

GraphQL is a different surface from a REST map, and a profitable one. `api-schema-map`
covers it generically; this handles the behaviors specific to it. Active → scope-gate
first, pace it, carry the program header. One endpoint at a time.

## Set up paths

```bash
: "${BL4CKAI_HOME:?}"; [ -f "$BL4CKAI_HOME/config.sh" ] && . "$BL4CKAI_HOME/config.sh"
export ENG="$ENGAGEMENTS_ROOT/A/<target>"
SCOPE=api.acme.com; OUT="$ENG/checks/$SCOPE"; mkdir -p "$OUT"
# scope-gate $SCOPE before any request (CONVENTIONS §12)
```

## 2. Schema disclosure (introspection)

Try an introspection query. If it answers, you have the full type/field/mutation
map — save it; it drives everything below. If introspection is disabled, try field
suggestions (the "did you mean" error leak) to recover names.

## 3. Per-field authorization

GraphQL authz is per-resolver; a single query can mix allowed and forbidden fields.
With `test-identity`, request sensitive fields/types as a low-privileged and anon
identity and see which resolve. This is the BOLA/BFLA of GraphQL and the most
common real finding.

## 4. Batching and aliasing

- Batched operations (array of queries, or many aliases in one document) can bypass
  per-request rate/attempt limits — test whether a limited action (login, OTP,
  coupon) can be retried many times in a single request.
- Deeply nested/cyclic queries can be disproportionately expensive — probe gently
  for missing depth/complexity limits (do NOT run a cost attack; one over-limit
  document is enough to record).

## 5. Mutations

Enumerate mutations from the schema and apply the access-control walk to the
state-changing ones (own accounts).

## 6. Record → `checks/$SCOPE/graphql.md`

Per behavior: introspection on/off, fields that resolved for the wrong identity,
whether batching/aliasing bypassed a limit, and any unauthenticated mutation.
Confirmed → `dedup-check` → `finding-draft`. Reference notes: if `KB_ROOT` is set,
read its GraphQL section first.

## Example of good output

```markdown
### api.acme.com/graphql — CONFIRMED (field authz + alias bypass)
Introspection ON (full schema saved). Field `user.email` resolves for anon on
`node(id:…)`. 100 aliased `login` mutations in one document bypass the 5/min limit.
Own accounts. Evidence: $ENG/evidence/acme-graphql.txt
```
