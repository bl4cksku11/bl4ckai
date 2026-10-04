---
name: js-analysis
description: Fetch the client-side scripts of in-scope hosts and read them for hidden endpoints, API routes, and credentials left in the bundles — one of the richest sources of web findings. Active fetch, scope-checked and paced; parsing is offline.
---

# Client-side script analysis

Recon's `url-mining` works offline over URL lists; this goes one level deeper by
reading the actual script bodies, where API keys, hidden endpoints, and internal
routes hide. Fetching the scripts is active (scope-gate + pace + header); parsing
them is offline.

## Set up paths

```bash
: "${BL4CKAI_HOME:?}"; [ -f "$BL4CKAI_HOME/config.sh" ] && . "$BL4CKAI_HOME/config.sh"
export ENG="$ENGAGEMENTS_ROOT/A/<target>"
GATE="$BL4CKAI_HOME/.claude/skills/scope-gate/scope_check.sh"
JOB="$BL4CKAI_HOME/.claude/skills/job-runner/job.sh"
MINE="$BL4CKAI_HOME/.claude/skills/js-analysis/jsmine.py"
mkdir -p "$ENG/recon/js"
```

## 1. Scope-filter the script URLs

Start from `recon/js_files.txt` (from `web-recon`/katana). Keep only in-scope hosts.

```bash
: > "$ENG/recon/js_in_scope.txt"
while read -r u; do h="${u#*://}"; h="${h%%/*}"; h="${h%%:*}"
  bash "$GATE" "$h" >/dev/null 2>&1 && echo "$u" >> "$ENG/recon/js_in_scope.txt"
done < "$ENG/recon/js_files.txt"
wc -l < "$ENG/recon/js_in_scope.txt"
```

## 2. Fetch the bodies — paced, header (via job-runner)

One request per script, spaced to stay under `MAX_RPS`, carrying the program header.

`req.sh` enforces scope + the program header + `MAX_RPS` pacing on each fetch, so
the loop stays simple. Note the single-quoted job command to avoid nested quoting.

```bash
bash "$JOB" run js-fetch 'Fetch in-scope JS bodies (via req.sh: scope+header+rate)' \
  'REQ="$BL4CKAI_HOME/.claude/skills/scope-gate/req.sh"; i=0
   while read -r u; do i=$((i+1));
     bash "$REQ" -A Mozilla/5.0 --max-time 15 "$u" -o "$ENG/recon/js/$i.js" 2>/dev/null
   done < "$ENG/recon/js_in_scope.txt"; echo "fetched $i scripts"'
bash "$JOB" status js-fetch     # watch it; big sites take a while
```

## 3. Parse offline for endpoints + secrets

```bash
python3 "$MINE" "$ENG/recon" "$ENG/recon/js/"*.js
echo "--- top new endpoints ---"; sort -u "$ENG/recon/js_endpoints_parsed.txt" | head -30
echo "--- secret candidates ---"; cat "$ENG/recon/js_secrets.txt"
```

## 4. Act on the leads

- **Endpoints**: new API routes and internal paths feed the queue — object-reference
  walks, function-access walks, and parameter checks against those routes (still
  scope-gated at test time).
- **Secrets**: each candidate is a *lead*, not a confirmed finding, and many are
  false positives (public keys, example tokens, client-side-safe ids). Judge which
  look real and impactful; hand active-looking credentials to the operator — never
  authenticate with a found key yourself. Confirmed, impactful leaks go to
  `dedup-check` → `finding-draft`.

Record the notable results in `02_strategy.md` so they drive the next checks.

## Example of good output

```
endpoints: 418  secret-candidates: 3
--- secret candidates ---
google_api_key   app.3f2.js   AIzaSyB...          (maps key — usually low impact, verify restrictions)
generic_secret   admin.js     api_key:"a1b2c3..."  (internal API key in an admin bundle — verify, likely real)
jwt              vendor.js     eyJhbGciOi...        (example token — false positive)
```
