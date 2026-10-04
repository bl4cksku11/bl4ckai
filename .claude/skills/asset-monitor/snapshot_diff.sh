#!/usr/bin/env bash
# Snapshot the current recon set and diff it against the previous snapshot, so a
# re-run surfaces only what is NEW (hosts, live endpoints, JS). Continuity is the
# real edge in bounty — new surface is where the un-found bugs are.
#   snapshot_diff.sh            take a snapshot + diff vs the last one
# Needs $ENG. Snapshots live in $ENG/monitor/<timestamp>/.
set -uo pipefail
: "${ENG:?export ENG first}"
R="$ENG/recon"; M="$ENG/monitor"; now=$(date +%Y%m%d-%H%M%S)
SNAP="$M/$now"; mkdir -p "$SNAP"
for f in subdomains.txt live_urls.txt js_files.txt endpoints_api.txt; do
  [ -f "$R/$f" ] && sort -u "$R/$f" > "$SNAP/$f" || : > "$SNAP/$f"
done
prev=$(ls -1d "$M"/*/ 2>/dev/null | grep -v "/$now/" | tail -1)
echo "snapshot: $SNAP"
if [ -z "$prev" ]; then echo "(first snapshot — nothing to diff against yet)"; exit 0; fi
echo "previous: $prev"
echo "=== NEW since last run ==="
for f in subdomains.txt live_urls.txt js_files.txt endpoints_api.txt; do
  nw=$(comm -13 "$prev/$f" "$SNAP/$f" 2>/dev/null)
  cnt=$(printf '%s' "$nw" | grep -c . || true)
  echo "## $f: +$cnt new"
  [ "$cnt" -gt 0 ] && printf '%s\n' "$nw" | sed 's/^/   + /'
done | tee "$SNAP/diff.md"
