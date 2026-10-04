---
name: finding-triage
description: Skeptically re-examine a confirmed candidate before it is written up — reproduce it independently, verify every claim against evidence, hunt for the thing that makes it not count, re-score from scratch, and return a verdict. Stops inflated, not-applicable, or out-of-scope findings from ever reaching a report.
---

# Finding triage

The skeptical gate. A check confirmed something and `impact-escalation` pushed it;
this tries to **kill it** before the operator spends time reporting it. Its job is
to be the hostile triager on the program's side — reproduce independently, doubt
every claim, find the guard or the policy that negates it, and correct inflated
severity. A finding that cannot survive this should never ship.

Runs after `dedup-check`/`impact-escalation`, before `finding-draft`. A disproof
here is a *first-class result*, not a failure: it saves a wasted report and a hit
to the operator's signal with the program.

## Inputs

The candidate's check note (`checks/<scope>/<slug>.md`), its evidence under
`$ENG/evidence/`, and the impact note. If the proof or evidence is missing, that is
an immediate `NEEDS-EVIDENCE` — stop, do not reconstruct the case yourself.

## The checks (each can kill or downgrade it)

### 1. Reproduce it independently
Re-run the proof from scratch from the recorded steps (scope-gated, via `req.sh`/the
backend) — do not trust the note. If it does not reproduce cleanly and
deterministically, it is `NEEDS-EVIDENCE` or `INVALID`. A one-off that won't repeat
is not a finding.

### 2. Verify every claim — three gates
- **Defect is concrete**: the exact request, parameter, endpoint, file:line — named, not described.
- **Chain is traced**: every step observed in ONE run, same identity/session/deployment. Links demonstrated separately but never end-to-end = `NEEDS-EVIDENCE` (the joins are where these collapse).
- **Effect is observed**: captured response bytes / listener hit / state change — not inferred. Inference is not observation.

### 3. Hunt the guard that kills it (argue the defense)
Actively look for what makes it not count:
- Output encoded in the real render context; CSP blocks it; an auth check exists on another path; the value is already public.
- **Self-only** (attacker's own account/session/data); needs an admin/privileged role; needs MITM or local access; needs a non-default config; needs an unrealistic precondition.
- A class the program auto-dismisses: missing security headers, SPF/DMARC, self-XSS, clickjacking on non-sensitive actions, CSRF on logout, rate limiting, outdated library with no working PoC, pure best-practice. Check the brief's excluded classes.
Any that holds → `INVALID` (name the killing mechanism) or downgrade.

### 4. Scope & policy
Asset resolves `IN` via `scope-gate`; the class is not excluded by the brief; the
proof meets the program's stated bar. Out-of-scope or excluded-class → `INVALID`.

### 5. Prior art
Cross-check the `dedup-check` corpus: not a known accepted-risk, wontfix, or
duplicate.

### 6. Re-score severity from scratch
Score only what the evidence carries, independent of what the draft claims. A score
**one band above** the evidence → `VALID-DOWNGRADED` with the corrected CVSS vector
and the exact metric that was wrong. An honest Medium beats an inflated High with
the operator's name on it.

### 7. Attacker versus victim
Walk the victim side: does a real victim actually suffer, or does the attacker only
affect themselves? If no victim is harmed, it is not a finding regardless of how the
request looks.

## Verdict → `reports/<slug>_triage.md`

- **VALID** — all gates hold under independent check, survives the victim reading,
  score matches evidence, scope/policy clear. → proceed to `finding-draft`.
- **VALID-DOWNGRADED** — real but overstated. Give the corrected vector/band and the
  sentence that must change. → `finding-draft` at the corrected severity.
- **NEEDS-EVIDENCE** — might be real, one specific thing missing. Name the
  experiment, not the doubt ("repro against a stock instance with no config
  override and capture the response"). → run it, re-enter triage. Do NOT draft.
- **INVALID** — name the killing mechanism (file:line, policy quote, or the
  self-only/OOS/auto-dismiss reason). Record it as a disproof in `03_lessons.md` /
  the queue's `ruled_out` so no later pass re-walks it. Nothing ships.

## Discipline

- The verdict and this skeptical voice are **internal** — they never appear in any
  vendor-facing text (`finding-draft` reads the corrected facts, not the triage
  commentary).
- Do not soften an `INVALID` because effort was spent, the code looks bad, or the
  result felt exciting. Sunk effort is not evidence.

## Example of good output — `reports/<slug>_triage.md`

```markdown
# Triage — reflected-marker-on-search — INVALID
Reproduced: yes, the marker reflects. Gate 2 (effect): the marker is HTML-entity
encoded in the actual render context (captured: &lt;svg&gt;), so it is NOT
interpreted — the "execution" claim is inference, not observed. Killing mechanism:
contextual output encoding at render (response captured in evidence/reflect.resp).
Also: search is a classic high-dup surface. Verdict: INVALID (not interpretable).
Recorded in ruled_out so it is not re-walked. Nothing drafted.
```
