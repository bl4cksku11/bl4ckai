---
name: web-recon
description: Resolve and fingerprint the live services of already-discovered hosts for an authorized assessment, using exact commands, and write the surface inventory and plan the engagement works from.
---

# Web recon (surface inventory)

The middle piece of recon: take the hosts from `web-asset-discovery`, find which are
live, fingerprint them, and write the surface map + plan. Passive host discovery is
`web-asset-discovery`; finding paths/params/scripts is `web-content-discovery`. This
one does the live fingerprint and the strategy. Every command is given in full so a
complete pass runs, not a shallow one. Stay within scope.

```bash
TARGET=acme
LETTER=$(printf %s "$TARGET" | cut -c1 | tr '[:lower:]' '[:upper:]')
ENG="${ENGAGEMENTS_ROOT:-$BL4CKAI_HOME/engagements}/$LETTER/$TARGET"
# input: $ENG/recon/subdomains.txt from web-asset-discovery
which dnsx httpx wafw00f 2>/dev/null   # install any missing: $BL4CKAI_HOME/docs/tooling.md
```

## 1. Resolve + live hosts + fingerprint → `recon/httpx.json`

Full httpx check — ports, title, status, tech, server, IP, CDN, redirects, retries,
random agent. Carry the program header. Not `httpx -l subs.txt`.

```bash
dnsx -l "$ENG/recon/subdomains.txt" -silent -a -resp -o "$ENG/recon/resolved.txt"
httpx -l "$ENG/recon/subdomains.txt" \
  -H "$RESEARCH_HEADER" \
  -ports 80,443,8080,8443,8000,8888,3000,5000 \
  -title -status-code -tech-detect -web-server -ip -cdn -location \
  -follow-redirects -random-agent -retries 2 -timeout 10 -threads "${MAX_CONCURRENCY:-40}" \
  -rate-limit "${MAX_RPS:-5}" \
  -json -o "$ENG/recon/httpx.json"
jq -r '.url' "$ENG/recon/httpx.json" | sort -u > "$ENG/recon/live_urls.txt"
```

Hosts here were discovered passively; resolve any that were not already scope-checked
through `scope-gate` before treating them as targets.

## 2. Defensive-filter fingerprint → `recon/filter_fingerprint.txt`

```bash
wafw00f -i "$ENG/recon/live_urls.txt" -o "$ENG/recon/filter_fingerprint.txt"
```

## 3. Surface map + plan → `02_strategy.md`

Write `$ENG/02_strategy.md`: live hosts grouped by technology, the custom and
recently-changed features (deepest attention), the program-named focus areas, and
for each surface which technique skills to queue and which KB file to read first.
Add the chosen checks to `_queue.json` with priority scores.

Then seed the ledger's per-surface block: for each in-scope host and chosen
technique, insert one line INTO the `## Per-surface checks (web)` section of
`$ENG/00_ledger.md` (not appended at EOF), copying the label + output file verbatim
from the canonical menu so it matches what the skill ticks:

```bash
cat $BL4CKAI_HOME/templates/technique_menu.md
```

Line shape: `- [ ] <label> → ` + `` `.../checks/<host>/<file>` ``

## 4. Tick the Recon boxes

Only after each artifact exists AND is non-trivial (`httpx.json` has ~as many
entries as there are live hosts — a near-empty file means a shallow run, re-run it),
tick the `## Recon (web)` boxes in `$ENG/00_ledger.md`.

## Examples of good output

`recon/live_urls.txt` + fingerprint:
```
https://api.acme.com [200] [Acme API] [nginx] [192.0.2.10] [cloudflare]
```

`02_strategy.md` excerpt:
```markdown
## Priority surfaces
1. api.acme.com/v2/billing — program-named, custom, handles money.
   Queue: object-reference walk, logic walk. KB first: Web/Business Logic Errors/README.md
2. app.acme.com — large SPA. Queue: client-side sink trace.
## Ruled out for now
- marketing host (OOS per brief)
```
