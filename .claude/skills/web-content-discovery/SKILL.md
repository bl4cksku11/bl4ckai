---
name: web-content-discovery
description: Find the paths, parameters, and client-side scripts of in-scope live hosts — from historical datasets, crawling, and directory discovery — to build the list of places later checks will look at. Active parts are scope-checked and paced.
---

# Web content discovery

The third piece of recon: once hosts are known and live (from `web-asset-discovery`
and `web-recon`), find the *content* — endpoints, parameters, and scripts. Passive
pulls (historical URLs) send nothing to the target; crawling and directory discovery
do, so scope-gate + pace + header those.

```bash
: "${BL4CKAI_HOME:?}"; [ -f "$BL4CKAI_HOME/config.sh" ] && . "$BL4CKAI_HOME/config.sh"
export ENG="$ENGAGEMENTS_ROOT/A/<target>"
GATE="$BL4CKAI_HOME/.claude/skills/scope-gate/scope_check.sh"
JOB="$BL4CKAI_HOME/.claude/skills/job-runner/job.sh"
export PATH="/usr/local/bin:$HOME/go/bin:$PATH"
```

## 1. Historical endpoints (passive) → `recon/historical_urls.txt`

```bash
printf '%s\n' acme.com olympicair.com | gau --threads 5 --subs | sort -u > "$ENG/recon/historical_urls.txt"
```

## 2. Crawl live hosts for endpoints + scripts (active, paced)

Build an in-scope live list first, then crawl via job-runner.

```bash
: > "$ENG/recon/live_in_scope.txt"
while read -r u; do h="${u#*://}"; h="${h%%/*}"; h="${h%%:*}"
  bash "$GATE" "$h" >/dev/null 2>&1 && echo "$u" >> "$ENG/recon/live_in_scope.txt"; done \
  < "$ENG/recon/live_urls.txt"
bash "$JOB" run content-crawl "Crawl in-scope hosts for endpoints + JS (paced, header)" \
  "export PATH=/usr/local/bin:\$PATH; katana -list '$ENG/recon/live_in_scope.txt' \
     -H '$RESEARCH_HEADER' -jc -kf all -d 2 -c ${MAX_CONCURRENCY:-10} -rl ${MAX_RPS:-5} -silent \
     -o '$ENG/recon/katana.txt'; grep -Ei '\\.js(\\?|\$)' '$ENG/recon/katana.txt' | sort -u > '$ENG/recon/js_files.txt'"
```

Then mine it offline with `url-mining`, and read the script bodies with
`js-analysis`.

## 3. Directory discovery where it pays (active, paced)

On interesting hosts, brute known paths with a sane wordlist — paced, header, and
only in-scope. Favor small, targeted lists over mega-lists on a WAF'd host.

```bash
# example per host (scope-gate $H first):
# ffuf -u "https://$H/FUZZ" -w <wordlist> -H "$RESEARCH_HEADER" -rate ${MAX_RPS:-5} \
#   -mc 200,204,301,302,307,401,403 -o "$ENG/recon/ffuf_$H.json"
```

## 4. Record

`historical_urls.txt`, `katana.txt`, `js_files.txt`, and any `ffuf_*` results are
the inputs to `url-mining`, `js-analysis`, and the per-surface checks. Tick the
ledger's content/scripts boxes once they are real.

## Example of good output

```
historical_urls.txt: 144k URLs   js_files.txt: 2,040 scripts   content-crawl: DONE 30m
→ next: url-mining (offline), js-analysis (fetch bodies), then queue checks per host
```
