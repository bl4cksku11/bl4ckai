# Progress ledger — {{TARGET}}

Program: {{PROGRAM}}  |  Platform: {{PLATFORM}}  |  Type: {{bbp|vdp}}
Engagement root: $BL4CKAI_HOME/engagements/{{A-Z}}/{{TARGET}}/
Started: {{DATE}}

A box is ticked ONLY when the named artifact exists and is real. No tick = not
done = re-run. `progress-review` verifies ticks against disk.

## Setup
- [ ] Scope and rules captured → `.../00_program_brief.md`
- [ ] Engagement folder tree created
- [ ] Task queue initialized → `.../_queue.json`
- [ ] Reference topics listed in the brief → `.../00_program_brief.md`

## Recon (web)
- [ ] Hosts enumerated → `.../recon/subdomains.txt`
- [ ] Live hosts + tech fingerprint → `.../recon/httpx.json`
- [ ] Historical endpoints collected → `.../recon/historical_urls.txt`
- [ ] Client-side scripts inventoried → `.../recon/js_endpoints.txt`
- [ ] Defensive-filter fingerprint → `.../recon/filter_fingerprint.txt`
- [ ] Surface map + strategy written → `.../02_strategy.md`

## Per-surface checks (web)
<!--
  web-recon seeds one block per in-scope host here, copying labels + files verbatim
  from $BL4CKAI_HOME/templates/technique_menu.md. The example
  below is commented so it is NOT counted as outstanding work — real seeded lines are
  live checkboxes, this is not. Shape of a seeded block:

  ### api.example.com
  - [ ] Object-reference access control walk → `.../checks/api.example.com/object_reference.md`
  - [ ] Database query influence check → `.../checks/api.example.com/db_query.md`
-->

## Review
- [ ] `progress-review` run, all boxes verified or re-queued → `.../00_review.md`

## Findings (agent drafts; operator validates before submission)
<!--
  dedup-check / finding-draft append one live block per confirmed candidate here.
  The example below is commented so it is NOT counted as outstanding work until a
  real finding exists. Shape of a seeded block:

  ### cross-account-order-access
  - [ ] Duplicate assessment → `.../reports/cross-account-order-access_dedup.md`
  - [ ] Triage verdict VALID/VALID-DOWNGRADED → `.../reports/cross-account-order-access_triage.md`
  - [ ] Report draft written by agent → `.../reports/cross-account-order-access.md`
  - [ ] Vault mirror written (only if VAULT_ROOT set) → `$VAULT_ROOT/<bbp|vdp>/<program>/cross-account-order-access.md`
  - [ ] Operator validated this finding and approved submission
-->
