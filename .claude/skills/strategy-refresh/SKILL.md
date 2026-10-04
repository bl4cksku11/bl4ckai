---
name: strategy-refresh
description: Periodically step back, review what has worked on this program so far, re-order the task queue by value, and add new tasks that observations have made worth doing. Keeps the plan matched to what the target actually is.
---

# Strategy refresh

The self-adjusting step. Run it after about every five completed checks, and
whenever recon or a result changes the picture. It does not test anything — it
reads the engagement's own record and rewrites the plan so the agent keeps
spending effort where it pays. The operator sees the revised plan and can steer it.

## Set up paths

```bash
TARGET=acme
LETTER=$(echo "$TARGET" | cut -c1 | tr '[:lower:]' '[:upper:]')
: "${BL4CKAI_HOME:?set it to the harness repo root, e.g. export BL4CKAI_HOME=~/bl4ckai}"
[ -f "$BL4CKAI_HOME/config.sh" ] && . "$BL4CKAI_HOME/config.sh"
ENG="${ENGAGEMENTS_ROOT:-$BL4CKAI_HOME/engagements}/$LETTER/$TARGET"
```

## 1. Read the current state

```bash
cat "$ENG/02_strategy.md"      # current plan + priority surfaces
cat "$ENG/_queue.json"         # tasks: completed / active / flagged / ruled_out
cat "$ENG/03_lessons.md" 2>/dev/null   # what has worked / not worked here (may not exist yet)
```

## 2. Record lessons from the last batch

Append to `$ENG/03_lessons.md` (create it if missing) what the last ~5 checks
taught: which classes are present/absent here, which filters are in play, which
surfaces responded interestingly. A class confirmed absent is a lesson — it stops
a re-walk. Mark anything the operator should keep for future programs with a
`knowledge_base_candidate: true` line so they can promote it to the KB later.

## 3. Re-prioritize the active queue

Recompute each active task's score with the operator's formula and process
highest-first:

```
priority_score = (impact_potential*3) + (dup_unlikely*3) + (exploitability*2) + bounty_tier_weight
  impact_potential   1-10  how bad if it exists
  dup_unlikely       1-10  inverse of how common this is on this kind of target
  exploitability     1-10  likelihood given the surface actually observed
  bounty_tier_weight critical=20 high=15 medium=10 low=5 vdp=0
```

Move anything disproved into `ruled_out` with a reason. Deprioritize high
duplicate-probability tasks (see `dedup-check`'s heuristics).

## 4. Expand the queue from triggers

Add new tasks the observations justify. Triggers (reason about why each matters
*here*, this is not a checklist):

- **Recon**: new subdomain → fingerprint + add; CNAME to a third party → takeover
  check; script with an API path → probe it; history-only endpoint still live →
  test it; staging/dev/admin host → prioritize.
- **Behavioral**: value echoed into a response → queue the reflection check; value
  in a database error → queue the query-influence check; value in a filesystem
  error → queue the path-resolution check; numeric id in a URL → queue the
  object-reference walk; origin reflected → queue the cross-origin check; token in
  traffic → queue the token-handling check.
- **Program-named**: brief mentions uploads → queue upload handling; payments →
  queue logic + concurrency; federated/SSO → queue the auth-flow walk; webhooks →
  queue the server-fetch probe; AI features → queue an `ai-*` check when that
  vertical exists.
- **Uniqueness (high value)**: custom (non-off-the-shelf) feature; recently
  deployed feature; multi-step workflow; anything touching money, permissions, or
  data sharing.
- **Chains (multipliers)**: a low-severity result plus an auth mechanism → can it
  reach account takeover? an open redirect plus a federated flow? a request
  boundary issue plus a shared cache? Queue the chain explicitly as its own task.

For each new task set `origin` (recon | inference | lesson:Lxxx | manual) and the
`skill` that performs it, using the names from `README.md`. For the canonical ledger label + output file of each check (so a seeded line matches what the skill ticks), copy from `$BL4CKAI_HOME/templates/technique_menu.md` (web) or `$BL4CKAI_HOME/templates/technique_menu_verticals.md` (mobile/source/api/cloud/ai/contract/hardware).

## 5. Rewrite the plan and tell the operator

Update `$ENG/02_strategy.md` with the new priority order and the reasoning. Then
give the operator a short delta: what moved up, what was ruled out, what was newly
queued and why. No ledger box — this skill runs many times per engagement.

## Example of good output — delta to the operator

```
Strategy refresh after batch 2 (5 checks done):
  Up:   api.acme.com/v2/billing logic walk  (program-named focus + money) 78→to top
  New:  server-fetch probe on /api/unfurl   (webhook-style feature found in JS)
  New:  chain: open-redirect(/login?next) + OAuth callback → account takeover check
  Out:  app.acme.com reflected-response     (output encoded in every context; ruled out)
  Lesson: WAF strips angle brackets in query but not in JSON bodies (kb candidate).
```
