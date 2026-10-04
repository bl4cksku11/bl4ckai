---
name: asset-monitor
description: Re-run discovery for a target over time and surface only what is new since last time — new hosts, live endpoints, and scripts — so continuous coverage keeps finding fresh surface. Pairs well with a scheduled run.
---

# Asset monitor

The sustained-coverage skill. A one-shot assessment finds what exists today; the
real edge is noticing what appears next week — a new subdomain, a freshly deployed
endpoint, a changed JS bundle. New surface is the least-tested surface. This takes a
snapshot of recon and diffs it against the previous one, so each re-run hands you a
short "what's new" list instead of the whole haystack.

## Run

```bash
: "${BL4CKAI_HOME:?}"; [ -f "$BL4CKAI_HOME/config.sh" ] && . "$BL4CKAI_HOME/config.sh"
export ENG="$ENGAGEMENTS_ROOT/A/<target>"
# 1) refresh recon (passive discovery + a scope-gated httpx pass) — see web-recon /
#    web-asset-discovery; then:
bash "$BL4CKAI_HOME/.claude/skills/asset-monitor/snapshot_diff.sh"
```

The diff is written to `$ENG/monitor/<timestamp>/diff.md` and printed. It compares
`subdomains.txt`, `live_urls.txt`, `js_files.txt`, and `endpoints_api.txt` against
the last snapshot.

## Act on the delta

For each new item, scope-gate it, then queue the checks its kind warrants:

- new host → fingerprint (httpx), `known-cve-check`, then the usual per-surface checks
- new live endpoint → object-reference / parameter checks
- new/changed JS → `js-analysis` on just those files

Only the new surface gets worked — that is the whole point. Record the delta and
the queued follow-ups in `02_strategy.md`.

## Running it continuously

This is a good fit for a scheduled run (e.g. a daily cron/agent). Keep it gentle
(`MAX_RPS`), carry the program header, and only alert the operator when the diff is
non-empty — a quiet run should stay quiet.

## Example of good output — `diff.md`

```
## subdomains.txt: +2 new
   + payments-v2.acme.com
   + status.acme.com
## live_urls.txt: +1 new
   + https://payments-v2.acme.com
## js_files.txt: +0 new
## endpoints_api.txt: +3 new
   + /api/v3/payouts
   ...
→ queued: known-cve-check + object-reference walk on payments-v2.acme.com
```
