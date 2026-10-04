---
name: web-recon
description: Enumerate an organization's internet-facing hosts and services for an authorized assessment, using exact commands, and write an inventory and surface map to the engagement folder.
---

# Web recon

Builds the host and surface inventory for an in-scope program. Runs after
`engagement-setup`. Every command is given in full so a complete enumeration runs,
not a shallow one. Stay within the scope captured in `00_program_brief.md`.

Set these once at the top of the session; every block below reuses them.

```bash
TARGET=acme
LETTER=$(echo "$TARGET" | cut -c1 | tr '[:lower:]' '[:upper:]')
ENG="$BL4CKAI_HOME/engagements/$LETTER/$TARGET"
ROOT=acme.com          # in-scope apex; repeat the block per in-scope apex
```

Verify tools first; install any that are missing (see the tooling notes in
`$BL4CKAI_HOME/docs/tooling.md`):

```bash
which subfinder amass dnsx httpx katana gau waybackurls wafw00f 2>/dev/null
```

## 1. Host enumeration → `recon/subdomains.txt`

```bash
subfinder -d "$ROOT" -all -recursive -silent -o "$ENG/recon/subfinder.txt"
amass enum -passive -d "$ROOT" -o "$ENG/recon/amass.txt"
curl -s "https://crt.sh/?q=%25.$ROOT&output=json" | jq -r '.[].name_value' \
  | sed 's/\*\.//g' | sort -u > "$ENG/recon/crtsh.txt"
cat "$ENG/recon/subfinder.txt" "$ENG/recon/amass.txt" "$ENG/recon/crtsh.txt" \
  2>/dev/null | sort -u > "$ENG/recon/subdomains.txt"
wc -l "$ENG/recon/subdomains.txt"
```

## 2. Resolve + live hosts + fingerprint → `recon/httpx.json`

Full httpx check — ports, title, status, tech, server, IP, CDN, redirects, retries,
random agent. Not `httpx -l subs.txt`.

```bash
dnsx -l "$ENG/recon/subdomains.txt" -silent -a -resp \
  -o "$ENG/recon/resolved.txt"
httpx -l "$ENG/recon/subdomains.txt" \
  -ports 80,443,8080,8443,8000,8888,3000,5000 \
  -title -status-code -tech-detect -web-server -ip -cdn -location \
  -follow-redirects -random-agent -retries 2 -timeout 10 -threads 50 \
  -o "$ENG/recon/httpx.txt" -json -o "$ENG/recon/httpx.json"
```

## 3. Historical endpoints → `recon/historical_urls.txt`

```bash
gau --threads 5 --subs "$ROOT" > "$ENG/recon/gau.txt"
echo "$ROOT" | waybackurls > "$ENG/recon/wayback.txt"
cat "$ENG/recon/gau.txt" "$ENG/recon/wayback.txt" 2>/dev/null \
  | sort -u > "$ENG/recon/historical_urls.txt"
```

## 4. Client-side script inventory → `recon/js_endpoints.txt`

```bash
katana -list "$ENG/recon/httpx.txt" -jc -kf all -d 3 -silent \
  | grep -Ei '\.js(\?|$)' | sort -u > "$ENG/recon/js_files.txt"
# extract endpoints/paths referenced inside those scripts
while read -r u; do
  curl -s "$u" | grep -Eo '["'\''"]/[a-zA-Z0-9_/.?=&-]+' ;
done < "$ENG/recon/js_files.txt" | sort -u > "$ENG/recon/js_endpoints.txt"
```

## 5. Defensive-filter fingerprint → `recon/filter_fingerprint.txt`

Knowing the filtering layer up front shapes later checks.

```bash
wafw00f -i "$ENG/recon/httpx.txt" -o "$ENG/recon/filter_fingerprint.txt"
```

## 6. Surface map + strategy → `02_strategy.md`

Write `$ENG/02_strategy.md`: the live hosts grouped by technology, the custom
and recently-changed features (these deserve the deepest attention), the
program-named focus areas from the brief, and for each surface which technique
skills to queue and which KB file to read first. Add the chosen checks to
`_queue.json` with priority scores.

Then seed the ledger's per-surface block. For each in-scope host and each
technique chosen for it, insert one line INTO the `## Per-surface checks (web)`
section of `$ENG/00_ledger.md` (not appended at end of file — that strands the
blocks after Review/Findings), copying the label and output file verbatim from the
canonical menu so the wording matches exactly what the technique skill will tick:

```bash
cat $BL4CKAI_HOME/templates/technique_menu.md
```

Line shape (one per technique, per host):
`- [ ] <label> → ` + `` `.../checks/<host>/<file>` ``

## 7. Tick the Recon boxes

Only after each artifact exists AND is non-trivial (e.g. `httpx.json` has as many
entries as there are live hosts — a near-empty file means the run was shallow,
re-run it), edit `$ENG/00_ledger.md` and tick the `## Recon (web)` boxes.

## Examples of good output

`recon/httpx.txt` line:
```
https://api.acme.com [200] [Acme API] [nginx] [192.0.2.10] [cloudflare]
```

`02_strategy.md` excerpt:
```markdown
## Priority surfaces
1. api.acme.com/v2/billing  — program-named focus, custom, handles money.
   Queue: parameter-reflection check, stored-render check, access-control walk.
   KB first: Web/Business Logic Errors/README.md
2. app.acme.com  — large SPA, many client-side routes from js_endpoints.txt.
   Queue: client-side sink trace. KB first: Web/Dom Clobbering/README.md
## Ruled out for now
- marketing host (OOS per brief)
```
