---
name: progress-review
description: Read an engagement's progress ledger, confirm each finished item actually has a real saved artifact on disk, and list everything still outstanding so it can be finished. Run it at the end of a pass and before any write-up.
---

# Progress review

The completion gate. It catches the failure where a step was ticked but produced
nothing real, or a scan "finished" fast because it ran shallow. It does not test
anything itself — it audits the ledger against disk and re-queues gaps.

## Run the verifier

```bash
TARGET=acme
LETTER=$(echo "$TARGET" | cut -c1 | tr '[:lower:]' '[:upper:]')
: "${BL4CKAI_HOME:?set it to the harness repo root, e.g. export BL4CKAI_HOME=~/bl4ckai}"
[ -f "$BL4CKAI_HOME/config.sh" ] && . "$BL4CKAI_HOME/config.sh"
ENG="${ENGAGEMENTS_ROOT:-$BL4CKAI_HOME/engagements}/$LETTER/$TARGET"
bash $BL4CKAI_HOME/.claude/skills/progress-review/verify_ledger.sh \
  "$ENG/00_ledger.md"
```

The script scans the ledger for lines of the form `- [x] ... → <path>` and for each:

- missing artifact, empty artifact, or artifact below a sane minimum size → reports
  `SUSPECT` (the tick is not backed by real output)
- unticked box `- [ ]` → reports `OUTSTANDING`

## Act on the result

1. Write the full report to `$ENG/00_review.md`.
2. For every `SUSPECT`, un-tick that box in `$ENG/00_ledger.md` (change `[x]`
   back to `[ ]`) — it was not really done.
3. For every `OUTSTANDING` and newly un-ticked box, add or re-add a task to
   `$ENG/_queue.json` naming the skill that produces that artifact.
4. Report to the operator: how many boxes are genuinely complete, how many were
   demoted, and the exact list of skills to re-run. Only when every box is ticked
   AND backed by a real artifact is the pass complete.

## Example of good output — `00_review.md`

```markdown
# Review — acme — 2026-10-03

Complete and verified: 9 / 14
Demoted (ticked but no real artifact): 1
Outstanding: 4

## Demoted
- [recon] httpx.json was 0 bytes — scan did not run. Re-queue web-recon step 2.

## Outstanding
- [checks/app.acme.com] stored-render check — artifact missing. Run web-stored-response.
- [checks/api.acme.com] reflected-response check — artifact missing. Run web-reflected-response.
- [review] this file (now written).
- [findings] no draft yet (expected — no confirmed finding).

## Re-run, in order
1. web-recon (step 2 only, httpx)
2. web-reflected-response on api.acme.com
3. web-stored-response on app.acme.com
```
