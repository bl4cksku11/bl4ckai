---
name: retest
description: Re-run the recorded proof of a validated finding after the program says it is fixed, and report whether it still works or is properly resolved. Programs ask for this; it closes the loop.
---

# Retest

Programs routinely ask the reporter to confirm a fix. This re-runs a finding's
recorded proof against the current target and emits a clear verdict, so the operator
can answer the retest request with evidence instead of guesswork.

## Set up paths

```bash
: "${BL4CKAI_HOME:?}"; [ -f "$BL4CKAI_HOME/config.sh" ] && . "$BL4CKAI_HOME/config.sh"
export ENG="$ENGAGEMENTS_ROOT/A/<target>"
SLUG=<finding-slug>      # the finding being retested
```

## 1. Reload the original proof

Read the finding's draft (`$ENG/reports/$SLUG.md`) and its evidence
(`$ENG/evidence/$SLUG*`) — the exact request/steps and the observed result that made
it valid. Scope-gate the host; refresh any needed session via `test-identity`
(a dead token can fake a "fixed" verdict — rule that out first).

## 2. Re-run exactly, through the same backend

Replay the exact reproduction with the same web backend (`burp-driver`/
`browser-interactor`), carrying the program header. Change nothing but what time it
is. Capture the fresh request/response.

## 3. Verdict

- **STILL VULNERABLE** — the proof reproduces. Capture the new evidence (dated) and
  note any change in behavior.
- **FIXED** — the proof no longer reproduces; describe what now blocks it (the
  response/behavior that changed), so the operator can confirm it is a real fix and
  not a transient error or a moved endpoint.
- **INCONCLUSIVE** — environment changed (endpoint gone, auth broken). Say so and
  what is needed; do not call it fixed.

## 4. Record → `reports/<slug>_retest_<date>.md`

Verdict, the re-run request/response, dated evidence paths, and a one-line summary
the operator can paste into the retest reply. Do not post it — the operator
responds to the program.

## Example of good output — `reports/idor-orders_retest_2026-11-02.md`

```markdown
# Retest — idor-orders-cross-account — 2026-11-02
Session refreshed (both owned accounts live). Re-ran GET /api/orders/{B's id} as A.
Verdict: FIXED — now returns 403 with an owner check; previously 200 with B's data.
Behavior change confirmed on 3 ids. Evidence: $ENG/evidence/idor-orders_retest.txt
Summary for reply: "Confirmed fixed — the endpoint now enforces ownership (403)."
```
