---
name: url-mining
description: Process already-collected URL lists offline to extract parameter names, API endpoints, interesting paths, and per-host endpoint lists — turning raw recon into concrete targets without sending any new traffic.
---

# URL mining

Turns the bulk URL output from recon (`katana.txt`, `historical_urls.txt`) into
concrete targets for the per-surface checks. Pure local processing — it reads
files already on disk and sends nothing to the target.

## Run

```bash
: "${BL4CKAI_HOME:?}"; [ -f "$BL4CKAI_HOME/config.sh" ] && . "$BL4CKAI_HOME/config.sh"
export ENG="$ENGAGEMENTS_ROOT/A/<target>"
python3 "$BL4CKAI_HOME/.claude/skills/url-mining/mine.py" "$ENG"
```

## What it writes (into `$ENG/recon/` and `$ENG/checks/<host>/`)

- `params.txt` — distinct query-parameter names by frequency. Id-bearing names
  (`id`, `*_id`, `uid`, `user`, `pnr`, `guid`, `token`, `ref`) are object-reference
  leads; `ReturnTo`/`ReturnURL` are redirect leads; `ApiKey`-style names flag key
  handling to review in the historical data.
- `endpoints_api.txt` — URLs under `/api`, `/v<N>`, `/rest`, `graphql`.
- `interesting_paths.txt` — admin/internal/token/auth/upload/redirect/CMS/etc.
- `checks/<host>/endpoints.txt` — per-priority-surface endpoint lists that the
  technique skills draw their targets from.
- `url_mining.md` — a summary (counts + top parameters + per-surface counts).

## Then

Record the notable leads in `02_strategy.md` and let them drive which checks to
queue and with which parameters/endpoints. Fetching JS bodies for secret-mining is
a separate, opt-in step that DOES send traffic — do it through `browser-interactor`
with the program header, not here.

## Example of good output — `url_mining.md` excerpt

```
- unique URLs: 155617
- distinct parameters: 557   API endpoints: 804   interesting paths: 3803
Top parameters: incident_id×207, client_id×101, _id×69, user×63, guid×34, pnr×3 …
Priority surfaces: ssp 156, transfers 268, ops360 68 endpoints
```
